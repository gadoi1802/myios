import Foundation
import UIKit

struct BatteryInfo {
    let level: Double          // 0.0 - 1.0
    let state: String          // Charging, Fully Charged, Discharging, Connected
    let cycleCount: Int        // Lần sạc
    let health: Double         // Sức khỏe pin (%)
    let currentCapacity: Int   // Dung lượng hiện tại (mAh)
    let maxCapacity: Int       // Dung lượng tối đa (mAh)
    let designCapacity: Int    // Dung lượng thiết kế (mAh)
    let voltage: Double        // Điện áp (V)
    let temperature: Double    // Nhiệt độ (°C)
    let amperage: Int          // Dòng điện (mA)
    let isMock: Bool           // Sử dụng dữ liệu giả lập (để test trên Simulator/Sandbox)
}

class BatteryManager: ObservableObject {
    static let shared = BatteryManager()
    
    // IOKit Private types
    private typealias io_object_t = mach_port_t
    private typealias io_registry_entry_t = io_object_t
    private typealias io_service_t = io_object_t
    
    // Function signatures
    private typealias IOServiceMatching_t = @convention(c) (UnsafePointer<CChar>?) -> CFMutableDictionary?
    private typealias IOServiceGetMatchingService_t = @convention(c) (mach_port_t, CFDictionary?) -> io_service_t
    private typealias IORegistryEntryCreateCFProperties_t = @convention(c) (io_registry_entry_t, UnsafeMutablePointer<Unmanaged<CFMutableDictionary>?>?, CFAllocator?, UInt32) -> kern_return_t
    private typealias IOObjectRelease_t = @convention(c) (io_object_t) -> kern_return_t
    
    private var ioKitHandle: UnsafeMutableRawPointer? = nil
    private var ioServiceMatchingFn: IOServiceMatching_t? = nil
    private var ioServiceGetMatchingServiceFn: IOServiceGetMatchingService_t? = nil
    private var ioRegistryEntryCreateCFPropertiesFn: IORegistryEntryCreateCFProperties_t? = nil
    private var ioObjectReleaseFn: IOObjectRelease_t? = nil
    
    init() {
        // Dynamically open IOKit framework
        ioKitHandle = dlopen("/System/Library/Frameworks/IOKit.framework/IOKit", RTLD_NOW)
        if let handle = ioKitHandle {
            if let sym = dlsym(handle, "IOServiceMatching") {
                ioServiceMatchingFn = unsafeBitCast(sym, to: IOServiceMatching_t.self)
            }
            if let sym = dlsym(handle, "IOServiceGetMatchingService") {
                ioServiceGetMatchingServiceFn = unsafeBitCast(sym, to: IOServiceGetMatchingService_t.self)
            }
            if let sym = dlsym(handle, "IORegistryEntryCreateCFProperties") {
                ioRegistryEntryCreateCFPropertiesFn = unsafeBitCast(sym, to: IORegistryEntryCreateCFProperties_t.self)
            }
            if let sym = dlsym(handle, "IOObjectRelease") {
                ioObjectReleaseFn = unsafeBitCast(sym, to: IOObjectRelease_t.self)
            }
        }
    }
    
    deinit {
        if let handle = ioKitHandle {
            dlclose(handle)
        }
    }
    
    /// Retrieve battery info from hardware IOKit or fallback to simulation if sandboxed/on simulator.
    func getBatteryInfo() -> BatteryInfo {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let deviceLevel = UIDevice.current.batteryLevel >= 0 ? Double(UIDevice.current.batteryLevel) : 0.85
        let deviceState = UIDevice.current.batteryState
        
        let stateString: String
        switch deviceState {
        case .charging:
            stateString = "Charging"
        case .full:
            stateString = "Fully Charged"
        case .unplugged:
            stateString = "Discharging"
        default:
            stateString = "Connected"
        }
        
        // Try reading AppleSmartBattery registry
        if let properties = getAppleSmartBatteryProperties() {
            // Read properties with multiple fallback keys just in case
            let cycleCount = (properties["CycleCount"] as? Int) ?? 0
            
            // Capacity
            let designCap = (properties["DesignCapacity"] as? Int) ?? 2900
            let maxCap = (properties["AppleRawMaxCapacity"] as? Int) ?? (properties["MaxCapacity"] as? Int) ?? (properties["NominalChargeCapacity"] as? Int) ?? designCap
            let currentCap = (properties["AppleRawCurrentCapacity"] as? Int) ?? (properties["CurrentCapacity"] as? Int) ?? Int(deviceLevel * Double(maxCap))
            
            // Health percentage
            let health = designCap > 0 ? (Double(maxCap) / Double(designCap)) * 100.0 : 100.0
            
            // Voltage (usually in millivolts, e.g. 4200 mV)
            let rawVoltage = (properties["Voltage"] as? Int) ?? 3800
            let voltageVolts = Double(rawVoltage) / 1000.0
            
            // Temperature (often in 10ths of a degree Celsius or Kelvin, e.g. 2950 or 295)
            let rawTemp = (properties["Temperature"] as? Int) ?? 250
            var tempCelsius = Double(rawTemp)
            if tempCelsius > 1000 {
                // Kelvin? (e.g. 298.15K) or 100ths of Celsius (e.g. 2950 -> 29.5)
                if tempCelsius > 20000 { // 1000ths of Kelvin or Celsius
                    tempCelsius = tempCelsius / 100.0
                } else if tempCelsius > 2000 { // 100ths of Celsius
                    tempCelsius = tempCelsius / 100.0
                } else {
                    tempCelsius = tempCelsius / 10.0
                }
            } else if tempCelsius > 100 { // 10ths of Celsius (e.g. 295 -> 29.5)
                tempCelsius = tempCelsius / 10.0
            }
            
            // Amperage (current draw in mA)
            let amperageVal = (properties["InstantAmperage"] as? Int) ?? (properties["Amperage"] as? Int) ?? 0
            
            return BatteryInfo(
                level: Double(currentCap) / Double(maxCap),
                state: stateString,
                cycleCount: cycleCount,
                health: min(100.0, max(0.0, health)),
                currentCapacity: currentCap,
                maxCapacity: maxCap,
                designCapacity: designCap,
                voltage: voltageVolts,
                temperature: tempCelsius,
                amperage: amperageVal,
                isMock: false
            )
        }
        
        // --- FALLBACK MOCK DATA FOR SIMULATOR OR SECURE SANDBOX ---
        let mockDesignCapacity = 2900 // iPhone 7 Plus standard capacity
        let mockHealth = 88.0 // Premium battery state
        let mockMaxCapacity = Int(Double(mockDesignCapacity) * (mockHealth / 100.0)) // 2552 mAh
        let mockCurrentCapacity = Int(deviceLevel * Double(mockMaxCapacity))
        
        let mockCycleCount = 428
        let mockVoltage = 3.7 + (0.5 * deviceLevel) // Realistic voltage range 3.7V - 4.2V
        
        // Temperature fluctuations around 28.5°C
        let mockTemp = 28.5 + (sin(Date().timeIntervalSince1970 / 10.0) * 0.4)
        
        // Amperage based on state
        let mockAmperage: Int
        if deviceState == .charging {
            mockAmperage = 450 + Int(sin(Date().timeIntervalSince1970) * 20.0) // ~450 mA charging
        } else if deviceState == .full {
            mockAmperage = 0
        } else {
            mockAmperage = -120 - Int(Double.random(in: 0...30)) // ~120-150 mA consumption
        }
        
        return BatteryInfo(
            level: deviceLevel,
            state: stateString,
            cycleCount: mockCycleCount,
            health: mockHealth,
            currentCapacity: mockCurrentCapacity,
            maxCapacity: mockMaxCapacity,
            designCapacity: mockDesignCapacity,
            voltage: mockVoltage,
            temperature: mockTemp,
            amperage: mockAmperage,
            isMock: true
        )
    }
    
    private func getAppleSmartBatteryProperties() -> [String: Any]? {
        guard let matchingFn = ioServiceMatchingFn,
              let getMatchingServiceFn = ioServiceGetMatchingServiceFn,
              let createPropertiesFn = ioRegistryEntryCreateCFPropertiesFn,
              let releaseFn = ioObjectReleaseFn else {
            return nil
        }
        
        let matchingDict = matchingFn("AppleSmartBattery")
        guard matchingDict != nil else { return nil }
        
        // 0 matches kIOMasterPortDefault / kIOMainPortDefault in iOS
        let service = getMatchingServiceFn(0, matchingDict)
        guard service != 0 else { return nil }
        defer { _ = releaseFn(service) }
        
        var properties: Unmanaged<CFMutableDictionary>? = nil
        let result = createPropertiesFn(service, &properties, kCFAllocatorDefault, 0)
        
        if result == 0, let props = properties {
            let cfDict = props.takeRetainedValue()
            let swiftDict = cfDict as Dictionary
            var resultDict: [String: Any] = [:]
            for (key, value) in swiftDict {
                if let keyStr = key as? String {
                    resultDict[keyStr] = value
                }
            }
            return resultDict
        }
        
        return nil
    }
}
