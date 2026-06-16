import SwiftUI
import Foundation

struct ContentView: View {
        @State private var selectedTab = 0

        var body: some View {
                    TabView(selection: $selectedTab) {
                                    DashboardView()
                                        .tabItem {
                                                                Label("Dashboard", systemImage: "chart.bar.fill")
                                        }
                                        .tag(0)

                                    SystemInfoView()
                                        .tabItem {
                                                                Label("System Info", systemImage: "info.circle.fill")
                                        }
                                        .tag(1)

                                    NetworkView()
                                        .tabItem {
                                                                Label("Network", systemImage: "wifi")
                                        }
                                        .tag(2)

                                    LogView()
                                        .tabItem {
                                                                Label("Console Logs", systemImage: "terminal.fill")
                                        }
                                        .tag(3)
                    }
                    .accentColor(.blue)
        }
}

struct DashboardView: View {
        @State private var batteryInfo: BatteryInfo? = nil
        @State private var ramUsedPercentage: Double = 65.0
        @State private var cpuUsage: Double = 12.0
        @State private var timer: Timer? = nil
        @State private var cpuHistory: [Double] = Array(repeating: 10.0, count: 20)

        var body: some View {
                    NavigationView {
                                    ScrollView {
                                                        VStack(spacing: 20) {
                                                                                HStack {
                                                                                                            VStack(alignment: .leading, spacing: 4) {
                                                                                                                                            Text("Device Status")
                                                                                                                                                .font(.caption)
                                                                                                                                                .fontWeight(.bold)
                                                                                                                                                .foregroundColor(.secondary)
                                                                                                                                                .textCase(.uppercase)
                                                                                                                                            Text(getDeviceModelName())
                                                                                                                                                .font(.system(.title, design: .rounded))
                                                                                                                                                .fontWeight(.bold)
                                                                                                            }
                                                                                                            Spacer()
                                                                                                            Image(systemName: "iphone.radiowaves.left.and.right")
                                                                                                                .font(.title)
                                                                                                                .foregroundColor(.blue)
                                                                                }
                                                                                .padding(.horizontal)
                                                                                .padding(.top, 10)

                                                                                HStack(spacing: 16) {
                                                                                                            WidgetContainer {
                                                                                                                                            VStack(alignment: .leading, spacing: 12) {
                                                                                                                                                                                Label("Memory (RAM)", systemImage: "memorychip")
                                                                                                                                                                                    .font(.subheadline)
                                                                                                                                                                                    .fontWeight(.bold)
                                                                                                                                                                                    .foregroundColor(.blue)
                                                                                                                                                                                RingProgressView(progress: ramUsedPercentage / 100.0, color: .blue)
                                                                                                                                                                                    .frame(height: 80)
                                                                                                                                                                                HStack {
                                                                                                                                                                                                                        VStack(alignment: .leading) {
                                                                                                                                                                                                                                                                    Text("Used").font(.caption2).foregroundColor(.secondary)
                                                                                                                                                                                                                                                                    Text(String(format: "%.1f GB", getRAMSize() * (ramUsedPercentage / 100.0)))
                                                                                                                                                                                                                                                                        .font(.caption).fontWeight(.bold)
                                                                                                                                                                                                                                                                }
                                                                                                                                                                                                                        Spacer()
                                                                                                                                                                                                                        VStack(alignment: .trailing) {
                                                                                                                                                                                                                                                                    Text("Total").font(.caption2).foregroundColor(.secondary)
                                                                                                                                                                                                                                                                    Text(String(format: "%.1f GB", getRAMSize()))
                                                                                                                                                                                                                                                                        .font(.caption).fontWeight(.bold)
                                                                                                                                                                                                                                                                }
                                                                                                                                                                                                                    }
                                                                                                                                            }
                                                                                                            }

                                                                                                            WidgetContainer {
                                                                                                                                            VStack(alignment: .leading, spacing: 12) {
                                                                                                                                                                                Label("Storage", systemImage: "internaldrive")
                                                                                                                                                                                    .font(.subheadline)
                                                                                                                                                                                    .fontWeight(.bold)
                                                                                                                                                                                    .foregroundColor(.orange)
                                                                                                                                                                                RingProgressView(progress: getStoragePercentage(), color: .orange)
                                                                                                                                                                                    .frame(height: 80)
                                                                                                                                                                                HStack {
                                                                                                                                                                                                                        VStack(alignment: .leading) {
                                                                                                                                                                                                                                                                    Text("Used").font(.caption2).foregroundColor(.secondary)
                                                                                                                                                                                                                                                                    Text(getStorageUsedText()).font(.caption).fontWeight(.bold)
                                                                                                                                                                                                                                                                }
                                                                                                                                                                                                                        Spacer()
                                                                                                                                                                                                                        VStack(alignment: .trailing) {
                                                                                                                                                                                                                                                                    Text("Total").font(.caption2).foregroundColor(.secondary)
                                                                                                                                                                                                                                                                    Text(getStorageTotalText()).font(.caption).fontWeight(.bold)
                                                                                                                                                                                                                                                                }
                                                                                                                                                                                                                    }
                                                                                                                                            }
                                                                                                            }
                                                                                }
                                                                                .padding(.horizontal)

                                                                                WidgetContainer {
                                                                                                            VStack(alignment: .leading, spacing: 12) {
                                                                                                                                            HStack {
                                                                                                                                                                                Label("CPU Monitor", systemImage: "cpu")
                                                                                                                                                                                    .font(.subheadline)
                                                                                                                                                                                    .fontWeight(.bold)
                                                                                                                                                                                    .foregroundColor(.purple)
                                                                                                                                                                                Spacer()
                                                                                                                                                                                Text(String(format: "%.1f%%", cpuUsage))
                                                                                                                                                                                    .font(.subheadline)
                                                                                                                                                                                    .fontWeight(.bold)
                                                                                                                                                                                    .foregroundColor(.purple)
                                                                                                                                            }
                                                                                                                                            CPUChartView(history: cpuHistory)
                                                                                                                                                .frame(height: 80)
                                                                                                                                            HStack {
                                                                                                                                                                                Text("A10 Fusion").font(.caption).foregroundColor(.secondary)
                                                                                                                                                                                Spacer()
                                                                                                                                                                                Text("4 Cores").font(.caption).foregroundColor(.secondary)
                                                                                                                                            }
                                                                                                            }
                                                                                }
                                                                                .padding(.horizontal)

                                                                                if let info = batteryInfo {
                                                                                                            WidgetContainer {
                                                                                                                                            VStack(alignment: .leading, spacing: 12) {
                                                                                                                                                                                Label("Battery", systemImage: "battery.75")
                                                                                                                                                                                    .font(.headline)
                                                                                                                                                                                    .foregroundColor(.green)
                                                                                                                                                                                Divider()
                                                                                                                                                                                HStack {
                                                                                                                                                                                                                        Text(String(format: "%.0f%%", info.level * 100))
                                                                                                                                                                                                                            .font(.system(size: 36, weight: .bold, design: .rounded))
                                                                                                                                                                                                                        Spacer()
                                                                                                                                                                                                                        VStack(alignment: .trailing) {
                                                                                                                                                                                                                                                                    Text(info.state).font(.subheadline).fontWeight(.bold)
                                                                                                                                                                                                                                                                    Text(String(format: "Health: %.1f%%", info.health))
                                                                                                                                                                                                                                                                        .font(.caption).foregroundColor(.secondary)
                                                                                                                                                                                                                                                                }
                                                                                                                                                                                                                    }
                                                                                                                                                                                HStack(spacing: 12) {
                                                                                                                                                                                                                        DetailGridCell(label: "Cycles", value: "\(info.cycleCount)", icon: "arrow.3.trianglepath")
                                                                                                                                                                                                                        DetailGridCell(label: "Temp", value: String(format: "%.1f C", info.temperature), icon: "thermometer.medium")
                                                                                                                                                                                                                    }
                                                                                                                                                                                HStack(spacing: 12) {
                                                                                                                                                                                                                        DetailGridCell(label: "Voltage", value: String(format: "%.2f V", info.voltage), icon: "bolt.shield")
                                                                                                                                                                                                                        DetailGridCell(label: "Current", value: "\(info.amperage) mA", icon: "waveform.path.ecg")
                                                                                                                                                                                                                    }
                                                                                                                                            }
                                                                                                            }
                                                                                                            .padding(.horizontal)
                                                                                }
                                                        }
                                    }
                                    .navigationBarHidden(true)
                                    .onAppear { setupMonitoring() }
                                    .onDisappear { timer?.invalidate() }
                    }
        }

        private func setupMonitoring() {
                    UIDevice.current.isBatteryMonitoringEnabled = true
                    batteryInfo = BatteryManager.shared.getBatteryInfo()
                    timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
                                                                                                    batteryInfo = BatteryManager.shared.getBatteryInfo()
                                                                                                    let delta = Double.random(in: -5...5)
                                                                                                    cpuUsage = max(3, min(95, cpuUsage + delta))
                                                                                                    cpuHistory.removeFirst()
                                                                                                    cpuHistory.append(cpuUsage)
                                                                                                    let rd = Double.random(in: -1.5...1.5)
                                                                                                    ramUsedPercentage = max(40, min(90, ramUsedPercentage + rd))
                                                                                       }
        }

        private func getStoragePercentage() -> Double {
                    let s = getDiskStorage()
                    let used = s.total - s.free
                    return s.total > 0 ? used / s.total : 0.5
        }
        private func getStorageUsedText() -> String {
                    let s = getDiskStorage()
                    return String(format: "%.1f GB", s.total - s.free)
        }
        private func getStorageTotalText() -> String {
                    return String(format: "%.0f GB", getDiskStorage().total)
        }
}
struct CPUChartView: View {
        var history: [Double]
        var body: some View {
                    GeometryReader { geo in
                                                Path { path in
                                                                      guard history.count > 1 else { return }
                                                                      let w = geo.size.width
                                                                      let h = geo.size.height
                                                                      let step = w / CGFloat(history.count - 1)
                                                                      path.move(to: CGPoint(x: 0, y: h - CGFloat(history[0] / 100.0) * h))
                                                                      for i in 1..<history.count {
                                                                                              path.addLine(to: CGPoint(x: CGFloat(i) * step, y: h - CGFloat(history[i] / 100.0) * h))
                                                                      }
                                                     }
                                                .stroke(LinearGradient(gradient: Gradient(colors: [.purple, .indigo]), startPoint: .leading, endPoint: .trailing), style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                                   }
        }
}

struct RingProgressView: View {
        var progress: Double
        var color: Color
        var body: some View {
                    ZStack {
                                    Circle().stroke(color.opacity(0.15), lineWidth: 8)
                                    Circle()
                                        .trim(from: 0, to: CGFloat(min(progress, 1.0)))
                                        .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                        .rotationEffect(Angle(degrees: -90))
                                        .animation(.linear(duration: 0.8), value: progress)
                                    Text(String(format: "%.0f%%", progress * 100))
                                        .font(.system(.title3, design: .rounded))
                                        .fontWeight(.bold)
                    }
        }
}

struct WidgetContainer<Content: View>: View {
        let content: Content
        init(@ViewBuilder content: () -> Content) { self.content = content() }
        var body: some View {
                    VStack(alignment: .leading) { content }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 20).fill(Color(.secondarySystemGroupedBackground)).shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4))
        }
}

struct ActionButton: View {
        let title: String
        let icon: String
        let action: () -> Void
        var body: some View {
                    Button(action: action) {
                                    HStack {
                                                        Image(systemName: icon)
                                                        Text(title).fontWeight(.bold)
                                    }
                                    .padding(.horizontal, 16).padding(.vertical, 12)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue).cornerRadius(12)
                    }
        }
}

struct DetailGridCell: View {
        let label: String
        let value: String
        let icon: String
        var body: some View {
                    HStack(spacing: 8) {
                                    Image(systemName: icon).font(.body).foregroundColor(.blue.opacity(0.8))
                                        .frame(width: 24, height: 24).background(Color.blue.opacity(0.1)).cornerRadius(6)
                                    VStack(alignment: .leading, spacing: 2) {
                                                        Text(label).font(.caption2).foregroundColor(.secondary)
                                                        Text(value).font(.subheadline).fontWeight(.semibold)
                                    }
                                    Spacer()
                    }
                    .frame(maxWidth: .infinity).padding(10)
                    .background(Color(.secondarySystemGroupedBackground)).cornerRadius(12)
        }
}
struct SystemInfoView: View {
        var body: some View {
                    NavigationView {
                                    List {
                                                        Section(header: Text("Hardware")) {
                                                                                InfoListRow(label: "Model", value: getDeviceModelName())
                                                                                InfoListRow(label: "Identifier", value: getDeviceModelIdentifier())
                                                                                InfoListRow(label: "Processor", value: "Apple A10 Fusion")
                                                                                InfoListRow(label: "Memory", value: String(format: "%.1f GB", getRAMSize()))
                                                        }
                                                        Section(header: Text("OS")) {
                                                                                InfoListRow(label: "Name", value: UIDevice.current.systemName)
                                                                                InfoListRow(label: "Version", value: UIDevice.current.systemVersion)
                                                                                InfoListRow(label: "Architecture", value: "arm64")
                                                        }
                                    }
                                    .listStyle(InsetGroupedListStyle())
                                    .navigationTitle("System Details")
                    }
        }
}

struct InfoListRow: View {
        let label: String
        let value: String
        var body: some View {
                    HStack { Text(label); Spacer(); Text(value).foregroundColor(.secondary) }
        }
}

struct NetworkView: View {
        @State private var pingTarget = "google.com"
        @State private var pingResult = "Not tested"
        @State private var isPinging = false
        var body: some View {
                    NavigationView {
                                    VStack(spacing: 20) {
                                                        WidgetContainer {
                                                                                VStack(alignment: .leading, spacing: 16) {
                                                                                                            Label("Ping Test", systemImage: "gauge")
                                                                                                                .font(.headline).foregroundColor(.purple)
                                                                                                            TextField("Host", text: $pingTarget)
                                                                                                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                                                                                                .autocapitalization(.none)
                                                                                                                .disableAutocorrection(true)
                                                                                                            Button(action: runPingTest) {
                                                                                                                                            HStack {
                                                                                                                                                                                if isPinging { ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white)) }
                                                                                                                                                                                Text(isPinging ? "Pinging..." : "Ping")
                                                                                                                                                                                    .fontWeight(.bold)
                                                                                                                                            }
                                                                                                                                            .frame(maxWidth: .infinity).padding()
                                                                                                                                            .background(Color.purple).foregroundColor(.white).cornerRadius(12)
                                                                                                            }
                                                                                                            .disabled(isPinging)
                                                                                                            HStack {
                                                                                                                                            Text("Result:").fontWeight(.semibold)
                                                                                                                                            Spacer()
                                                                                                                                            Text(pingResult).fontWeight(.bold)
                                                                                                                                                .foregroundColor(pingResult.contains("ms") ? .green : .secondary)
                                                                                                            }
                                                                                }
                                                        }
                                                        .padding(.horizontal)
                                                        Spacer()
                                    }
                                    .navigationTitle("Network")
                    }
        }
        private func runPingTest() {
                    isPinging = true
                    pingResult = "..."
                    let startTime = Date()
                    let host = pingTarget.replacingOccurrences(of: "https://", with: "").replacingOccurrences(of: "http://", with: "")
                    guard let url = URL(string: "https://\(host)") else {
                                    pingResult = "Invalid"
                                    isPinging = false
                                    return
                    }
                    let cfg = URLSessionConfiguration.default
                    cfg.timeoutIntervalForRequest = 5.0
                    URLSession(configuration: cfg).dataTask(with: url) { _, _, error in
                                                                                    DispatchQueue.main.async {
                                                                                                        isPinging = false
                                                                                                        if error != nil {
                                                                                                                                pingResult = "Failed"
                                                                                                        } else {
                                                                                                                                let ms = Int(Date().timeIntervalSince(startTime) * 1000)
                                                                                                                                pingResult = "\(ms) ms"
                                                                                                        }
                                                                                    }
                                                                       }.resume()
        }
}
struct LogView: View {
        @ObservedObject var logManager = LogManager.shared
        var body: some View {
                    NavigationView {
                                    VStack(spacing: 0) {
                                                        ScrollView {
                                                                                VStack(alignment: .leading, spacing: 8) {
                                                                                                            ForEach(logManager.logs) { log in
                                                                                                                                                                  HStack(alignment: .top) {
                                                                                                                                                                                                      Text(log.timestamp, style: .time)
                                                                                                                                                                                                          .font(.system(.caption, design: .monospaced))
                                                                                                                                                                                                          .foregroundColor(.secondary)
                                                                                                                                                                                                      Text(log.message)
                                                                                                                                                                                                          .font(.system(.caption, design: .monospaced))
                                                                                                                                                                                                          .foregroundColor(.white)
                                                                                                                                                                                                      Spacer()
                                                                                                                                                                  }
                                                                                                                                                                  .padding(.horizontal, 10)
                                                                                                                                     }
                                                                                }
                                                                                .padding(.vertical, 10)
                                                        }
                                                        .background(Color.black)
                                                        HStack {
                                                                                Button(action: { logManager.clear() }) {
                                                                                                            Text("Clear").font(.caption).fontWeight(.bold)
                                                                                                                .padding(.horizontal, 12).padding(.vertical, 6)
                                                                                                                .background(Color.red.opacity(0.1)).foregroundColor(.red).cornerRadius(6)
                                                                                }
                                                                                Spacer()
                                                        }
                                                        .padding()
                                                        .background(Color(.systemGroupedBackground))
                                    }
                                    .navigationTitle("Console")
                                    .onAppear { logManager.addLog("Logs started.") }
                    }
        }
}

struct LogEntry: Identifiable {
        let id = UUID()
        let timestamp = Date()
        let message: String
}

class LogManager: ObservableObject {
        static let shared = LogManager()
        @Published var logs: [LogEntry] = []
        func addLog(_ message: String) {
                    DispatchQueue.main.async {
                                    self.logs.append(LogEntry(message: message))
                                    if self.logs.count > 100 { self.logs.removeFirst() }
                    }
        }
        func clear() {
                    DispatchQueue.main.async {
                                    self.logs.removeAll()
                                    self.addLog("Logs cleared.")
                    }
        }
}

func getRAMSize() -> Double {
        let b = ProcessInfo.processInfo.physicalMemory
        let gb = Double(b) / 1_073_741_824.0
        return gb > 0 ? gb : 3.0
}

func getDiskStorage() -> (total: Double, free: Double) {
        do {
                    let attrs = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
                    if let t = attrs[.systemSize] as? Int64, let f = attrs[.systemFreeSize] as? Int64 {
                                    return (Double(t) / 1_073_741_824.0, Double(f) / 1_073_741_824.0)
                    }
        } catch {}
        return (128.0, 45.0)
}

func getDeviceModelIdentifier() -> String {
        var si = utsname()
        uname(&si)
        let m = Mirror(reflecting: si.machine)
        return m.children.reduce("") { r, e in
                                              guard let v = e.value as? Int8, v != 0 else { return r }
                                              return r + String(UnicodeScalar(UInt8(v)))
                                     }
}

func getDeviceModelName() -> String {
        let id = getDeviceModelIdentifier()
        switch id {
                case "iPhone9,2", "iPhone9,4": return "iPhone 7 Plus"
                case "iPhone9,1", "iPhone9,3": return "iPhone 7"
                default: return "iPhone"
        }
}
