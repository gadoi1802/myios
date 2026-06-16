import Foundation
import UIKit

struct BatteryInfo {
        let level: Double
        let state: String
        let cycleCount: Int
        let health: Double
        let currentCapacity: Int
        let maxCapacity: Int
        let designCapacity: Int
        let voltage: Double
        let temperature: Double
        let amperage: Int
        let isMock: Bool
}

class BatteryManager: ObservableObject {
        static let shared = BatteryManager()

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

                    let mockDesignCapacity = 2900
                    let mockHealth = 88.0
                    let mockMaxCapacity = Int(Double(mockDesignCapacity) * (mockHealth / 100.0))
                    let mockCurrentCapacity = Int(deviceLevel * Double(mockMaxCapacity))
                    let mockCycleCount = 428
                    let mockVoltage = 3.7 + (0.5 * deviceLevel)
                    let mockTemp = 28.5 + (sin(Date().timeIntervalSince1970 / 10.0) * 0.4)

                    let mockAmperage: Int
                    if deviceState == .charging {
                                    mockAmperage = 450 + Int(sin(Date().timeIntervalSince1970) * 20.0)
                    } else if deviceState == .full {
                                    mockAmperage = 0
                    } else {
                                    mockAmperage = -120 - Int(Double.random(in: 0...30))
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
}
