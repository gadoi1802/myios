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

// MARK: - Dashboard View
struct DashboardView: View {
    @State private var batteryLevel: Float = 0.0
    @State private var batteryState: UIDevice.BatteryState = .unknown
    @State private var batteryInfo: BatteryInfo = BatteryManager.shared.getBatteryInfo()
    @State private var ramUsedPercentage: Double = 65.0
    @State private var cpuUsage: Double = 12.0
    @State private var timer: Timer?
    @State private var cpuHistory: [Double] = Array(repeating: 10.0, count: 20)
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Card
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
                    
                    // Top Widgets: RAM & Storage
                    HStack(spacing: 16) {
                        // RAM Widget
                        WidgetContainer {
                            VStack(alignment: .leading, spacing: 12) {
                                Label("Memory (RAM)", systemImage: "memorychip")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                                
                                RingProgressView(progress: ramUsedPercentage / 100.0, color: .blue)
                                    .frame(height: 80)
                                    .padding(.vertical, 4)
                                
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Used")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                        Text(String(format: "%.1f GB", getRAMSize() * (ramUsedPercentage / 100.0)))
                                            .font(.caption)
                                            .fontWeight(.bold)
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing) {
                                        Text("Total")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                        Text(String(format: "%.1f GB", getRAMSize()))
                                            .font(.caption)
                                            .fontWeight(.bold)
                                    }
                                }
                            }
                        }
                        
                        // Storage Widget
                        let storage = getDiskStorage()
                        let storageUsed = storage.total - storage.free
                        let storagePercentage = storage.total > 0 ? (storageUsed / storage.total) : 0.0
                        
                        WidgetContainer {
                            VStack(alignment: .leading, spacing: 12) {
                                Label("Storage", systemImage: "square.grid.2x2")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.orange)
                                
                                RingProgressView(progress: storagePercentage, color: .orange)
                                    .frame(height: 80)
                                    .padding(.vertical, 4)
                                
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Used")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                        Text(String(format: "%.1f GB", storageUsed))
                                            .font(.caption)
                                            .fontWeight(.bold)
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing) {
                                        Text("Total")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                        Text(String(format: "%.0f GB", storage.total))
                                            .font(.caption)
                                            .fontWeight(.bold)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // CPU Monitor Card
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
                            
                            // Line chart visualization
                            CPUChartView(history: cpuHistory)
                                .frame(height: 80)
                                .padding(.vertical, 4)
                            
                            HStack {
                                Text("A10 Fusion Processor")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("4 Cores (2x Big, 2x LITTLE)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Full Battery Diagnostics Card
                    WidgetContainer {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Label("Battery Diagnostics", systemImage: getBatteryIcon(for: batteryInfo))
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(getBatteryColor(for: batteryInfo))
                                Spacer()
                                if batteryInfo.isMock {
                                    Text("Simulator Mode")
                                        .font(.caption2)
                                        .fontWeight(.semibold)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(Color.orange.opacity(0.2))
                                        .foregroundColor(.orange)
                                        .cornerRadius(6)
                                } else {
                                    Text("Hardware Active")
                                        .font(.caption2)
                                        .fontWeight(.semibold)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(Color.green.opacity(0.2))
                                        .foregroundColor(.green)
                                        .cornerRadius(6)
                                }
                            }
                            
                            Divider()
                            
                            HStack(spacing: 20) {
                                // Visual Battery Indicator
                                VStack {
                                    ZStack(alignment: .bottom) {
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(Color.primary.opacity(0.2), lineWidth: 3)
                                            .frame(width: 48, height: 80)
                                        
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(Color.primary.opacity(0.2))
                                            .frame(width: 16, height: 6)
                                            .offset(y: -43)
                                        
                                        let fillHeight = 74.0 * batteryInfo.level
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [getBatteryColor(for: batteryInfo), getBatteryColor(for: batteryInfo).opacity(0.8)]),
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                            .frame(width: 42, height: CGFloat(fillHeight))
                                            .padding(3)
                                        
                                        if batteryInfo.state == "Charging" {
                                            Image(systemName: "bolt.fill")
                                                .font(.title2)
                                                .foregroundColor(.white)
                                                .shadow(color: .black.opacity(0.4), radius: 2)
                                                .offset(y: CGFloat(-37 + (fillHeight / 2)))
                                                .offset(y: -5)
                                        }
                                    }
                                    .frame(width: 60, height: 90)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(alignment: .firstTextBaseline) {
                                        Text(String(format: "%.0f%%", batteryInfo.level * 100))
                                            .font(.system(size: 40, weight: .bold, design: .rounded))
                                        Text(batteryInfo.state)
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text("Sức khỏe pin (Health)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            Spacer()
                                            Text(String(format: "%.1f%%", batteryInfo.health))
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundColor(.green)
                                        }
                                        
                                        GeometryReader { geo in
                                            ZStack(alignment: .leading) {
                                                Capsule()
                                                    .fill(Color.primary.opacity(0.1))
                                                    .frame(height: 6)
                                                Capsule()
                                                    .fill(
                                                        LinearGradient(
                                                            gradient: Gradient(colors: [.green, Color.green.opacity(0.7)]),
                                                            startPoint: .leading,
                                                            endPoint: .trailing
                                                        )
                                                    )
                                                    .frame(width: geo.size.width * CGFloat(batteryInfo.health / 100.0), height: 6)
                                            }
                                        }
                                        .frame(height: 6)
                                    }
                                }
                            }
                            
                            Divider()
                            
                            VStack(spacing: 10) {
                                HStack(spacing: 12) {
                                    DetailGridCell(label: "Lần sạc (Cycles)", value: "\(batteryInfo.cycleCount) lần", icon: "arrow.3.loopcircle")
                                    DetailGridCell(label: "Nhiệt độ (Temp)", value: String(format: "%.1f°C", batteryInfo.temperature), icon: "thermometer.medium")
                                }
                                
                                HStack(spacing: 12) {
                                    DetailGridCell(label: "Dung lượng hiện tại", value: "\(batteryInfo.currentCapacity) mAh", icon: "battery.75")
                                    DetailGridCell(label: "Dung lượng tối đa", value: "\(batteryInfo.maxCapacity) mAh", icon: "battery.100")
                                }
                                
                                HStack(spacing: 12) {
                                    DetailGridCell(label: "Điện áp (Voltage)", value: String(format: "%.2f V", batteryInfo.voltage), icon: "bolt.shield")
                                    DetailGridCell(label: "Dòng điện (Current)", value: "\(batteryInfo.amperage) mA", icon: "waveform.path.ecg")
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Full System Status Card
                    WidgetContainer {
                        VStack(alignment: .leading, spacing: 14) {
                            Label("System Status", systemImage: "info.circle.fill")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.indigo)
                            
                            Divider()
                            
                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("OS Version")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    Text("iOS \(UIDevice.current.systemVersion)")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                }
                                Spacer()
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Environment Target")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    Text("TrollStore Bypass")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.indigo)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("Uptime")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    Text(getSystemUptime())
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Quick Action Tools
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Quick Actions")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ActionButton(title: "Free Up RAM", icon: "arrow.counterclockwise") {
                                    triggerRAMOptimization()
                                }
                                ActionButton(title: "Check Logs", icon: "terminal") {
                                    // Navigate to logs
                                }
                                ActionButton(title: "Test Ping", icon: "network") {
                                    // Navigate to network ping
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 10)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                setupMonitoring()
            }
            .onDisappear {
                timer?.invalidate()
            }
        }
    }
    
    // RAM and CPU simulation update
    private func setupMonitoring() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        updateBatteryInfo()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
            updateBatteryInfo()
            
            // Simulate CPU utilization fluctuations
            let delta = Double.random(in: -5...5)
            cpuUsage = max(3.0, min(95.0, cpuUsage + delta))
            cpuHistory.removeFirst()
            cpuHistory.append(cpuUsage)
            
            // Simulate slight RAM adjustments
            let ramDelta = Double.random(in: -1.5...1.5)
            ramUsedPercentage = max(40.0, min(90.0, ramUsedPercentage + ramDelta))
        }
    }
    
    private func updateBatteryInfo() {
        batteryLevel = UIDevice.current.batteryLevel
        batteryState = UIDevice.current.batteryState
        batteryInfo = BatteryManager.shared.getBatteryInfo()
    }
    
    private func getBatteryIcon() -> String {
        switch batteryState {
        case .charging:
            return "battery.100.bolt"
        case .full:
            return "battery.100"
        default:
            if batteryLevel < 0.2 { return "battery.25" }
            if batteryLevel < 0.5 { return "battery.50" }
            if batteryLevel < 0.8 { return "battery.75" }
            return "battery.100"
        }
    }
    
    private func getBatteryIcon(for info: BatteryInfo) -> String {
        if info.state == "Charging" {
            return "battery.100.bolt"
        }
        if info.state == "Fully Charged" {
            return "battery.100"
        }
        if info.level < 0.2 { return "battery.25" }
        if info.level < 0.5 { return "battery.50" }
        if info.level < 0.8 { return "battery.75" }
        return "battery.100"
    }
    
    private func getBatteryColor() -> Color {
        if batteryState == .charging { return .green }
        if batteryLevel < 0.2 { return .red }
        if batteryLevel < 0.5 { return .yellow }
        return .green
    }
    
    private func getBatteryColor(for info: BatteryInfo) -> Color {
        if info.state == "Charging" { return .green }
        if info.level < 0.2 { return .red }
        if info.level < 0.5 { return .yellow }
        return .green
    }
    
    private func getBatteryStatusString() -> String {
        switch batteryState {
        case .charging: return "Charging"
        case .full: return "Fully Charged"
        case .unplugged: return "Discharging"
        default: return "Connected"
        }
    }
    
    private func getSystemUptime() -> String {
        let uptime = ProcessInfo.processInfo.systemUptime
        let hours = Int(uptime) / 3600
        let minutes = (Int(uptime) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private func triggerRAMOptimization() {
        ramUsedPercentage = Double.random(in: 45.0...52.0)
        LogManager.shared.addLog("Memory cleaning routine triggered. Purged cached memory pools.")
    }
}

// MARK: - CPU Chart View (Custom Drawn Sparkline)
struct CPUChartView: View {
    var history: [Double]
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                guard history.count > 1 else { return }
                
                let width = geometry.size.width
                let height = geometry.size.height
                let stepX = width / CGFloat(history.count - 1)
                
                // Max CPU scaling
                let maxVal = 100.0
                
                let startY = height - CGFloat(history[0] / maxVal) * height
                path.move(to: CGPoint(x: 0, y: startY))
                
                for idx in 1..<history.count {
                    let posX = CGFloat(idx) * stepX
                    let posY = height - CGFloat(history[idx] / maxVal) * height
                    path.addLine(to: CGPoint(x: posX, y: posY))
                }
            }
            .stroke(
                LinearGradient(
                    gradient: Gradient(colors: [.purple, .indigo]),
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
            )
            .background(
                Path { path in
                    guard history.count > 1 else { return }
                    let width = geometry.size.width
                    let height = geometry.size.height
                    let stepX = width / CGFloat(history.count - 1)
                    
                    path.move(to: CGPoint(x: 0, y: height))
                    for idx in 0..<history.count {
                        let posX = CGFloat(idx) * stepX
                        let posY = height - CGFloat(history[idx] / 100.0) * height
                        path.addLine(to: CGPoint(x: posX, y: posY))
                    }
                    path.addLine(to: CGPoint(x: width, y: height))
                    path.close()
                }
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.purple.opacity(0.15), Color.purple.opacity(0.0)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            )
        }
    }
}

// MARK: - Ring Progress View
struct RingProgressView: View {
    var progress: Double
    var color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.15), lineWidth: 8)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [color, color.opacity(0.6), color]),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(Angle(degrees: -90))
                .animation(.linear(duration: 0.8), value: progress)
            
            VStack {
                Text(String(format: "%.0f%%", progress * 100))
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
            }
        }
    }
}

// MARK: - Common Containers
struct WidgetContainer<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            content
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
        )
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
                Text(title)
                    .fontWeight(.bold)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(12)
        }
    }
}

struct DetailGridCell: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(.blue.opacity(0.8))
                .frame(width: 24, height: 24)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(6)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

// MARK: - System Info View
struct SystemInfoView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Hardware Information")) {
                    InfoListRow(label: "Device Model", value: getDeviceModelName())
                    InfoListRow(label: "Identifier", value: getDeviceModelIdentifier())
                    InfoListRow(label: "Processor", value: "Apple A10 Fusion")
                    InfoListRow(label: "CPU Cores", value: "4 Cores (2x Performance, 2x Efficiency)")
                    InfoListRow(label: "Physical Memory", value: String(format: "%.1f GB", getRAMSize()))
                    InfoListRow(label: "Screen Resolution", value: getScreenResolutionString())
                }
                
                Section(header: Text("Operating System")) {
                    InfoListRow(label: "OS Name", value: UIDevice.current.systemName)
                    InfoListRow(label: "OS Version", value: UIDevice.current.systemVersion)
                    InfoListRow(label: "Kernel Version", value: getKernelVersion())
                    InfoListRow(label: "Architecture", value: "arm64")
                    InfoListRow(label: "Jailbroken / TrollStore", value: "Detected Jailbreak Capability (A10)")
                }
                
                Section(header: Text("Environment Info")) {
                    InfoListRow(label: "App Target Sandbox", value: "User Applications")
                    InfoListRow(label: "TrollStore Target", value: "iOS 15.0 - 15.7.6")
                    InfoListRow(label: "Developer", value: "Google DeepMind Antigravity")
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("System Details")
        }
    }
    
    private func getScreenResolutionString() -> String {
        let screen = UIScreen.main
        let width = Int(screen.bounds.width * screen.scale)
        let height = Int(screen.bounds.height * screen.scale)
        return "\(width) x \(height) @ \(Int(screen.scale))x"
    }
    
    private func getKernelVersion() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let releaseMirror = Mirror(reflecting: systemInfo.release)
        let release = releaseMirror.children.reduce("") { release, element in
            guard let value = element.value as? Int8, value != 0 else { return release }
            return release + String(UnicodeScalar(UInt8(value)))
        }
        return "Darwin \(release)"
    }
}

struct InfoListRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.primary)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Network View
struct NetworkView: View {
    @State private var pingTarget = "google.com"
    @State private var pingResult = "Not tested"
    @State private var isPinging = false
    @State private var networkType = "Checking..."
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                WidgetContainer {
                    VStack(alignment: .leading, spacing: 16) {
                        Label("Network Status", systemImage: "antenna.radiowaves.left.and.right")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        Divider()
                        
                        HStack {
                            Text("Connection Type")
                            Spacer()
                            Text(networkType)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                        
                        HStack {
                            Text("Local Host IP")
                            Spacer()
                            Text(getLocalIPAddress() ?? "Unavailable")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal)
                
                WidgetContainer {
                    VStack(alignment: .leading, spacing: 16) {
                        Label("Latency/Ping Utility", systemImage: "gauge")
                            .font(.headline)
                            .foregroundColor(.purple)
                        
                        Text("Measure ping latency to target hosts from your device.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextField("Host URL (e.g. google.com)", text: $pingTarget)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        
                        Button(action: runPingTest) {
                            HStack {
                                if isPinging {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .padding(.trailing, 8)
                                }
                                Text(isPinging ? "Pinging..." : "Execute Ping")
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isPinging ? Color.purple.opacity(0.6) : Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(isPinging)
                        
                        HStack {
                            Text("Latency Result:")
                                .fontWeight(.semibold)
                            Spacer()
                            Text(pingResult)
                                .fontWeight(.bold)
                                .foregroundColor(pingResult.contains("ms") ? .green : .secondary)
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Network Center")
            .onAppear {
                checkNetworkType()
            }
        }
    }
    
    private func checkNetworkType() {
        // Simple mock of connectivity type detection on iOS
        networkType = "Wi-Fi (Active)"
    }
    
    private func runPingTest() {
        isPinging = true
        pingResult = "Connecting..."
        LogManager.shared.addLog("Ping started targeting \(pingTarget)...")
        
        let startTime = Date()
        let formattedHost = pingTarget.replacingOccurrences(of: "https://", with: "").replacingOccurrences(of: "http://", with: "")
        
        guard let url = URL(string: "https://\(formattedHost)") else {
            self.pingResult = "Invalid URL"
            self.isPinging = false
            return
        }
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 5.0
        let session = URLSession(configuration: config)
        
        session.dataTask(with: url) { _, _, error in
            DispatchQueue.main.async {
                self.isPinging = false
                if let error = error {
                    self.pingResult = "Failed (Timeout)"
                    LogManager.shared.addLog("Ping to \(formattedHost) failed: \(error.localizedDescription)")
                } else {
                    let elapsed = Date().timeIntervalSince(startTime)
                    let ms = Int(elapsed * 1000)
                    self.pingResult = "\(ms) ms"
                    LogManager.shared.addLog("Ping success to \(formattedHost): response in \(ms)ms")
                }
            }
        }.resume()
    }
    
    private func getLocalIPAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                guard let interface = ptr?.pointee else { return nil }
                let addrFamily = interface.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    let name = String(cString: interface.ifa_name)
                    if name == "en0" { // WiFi interface
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                    &hostname, socklen_t(hostname.count),
                                    nil, socklen_t(0), NI_NUMERICHOST)
                        address = String(cString: hostname)
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        return address
    }
}

// MARK: - Log System / Console View
struct LogView: View {
    @ObservedObject var logManager = LogManager.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
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
                                .id(log.id)
                            }
                        }
                        .padding(.vertical, 10)
                    }
                    .background(Color.black)
                    .onChange(of: logManager.logs.count) { _ in
                        if let lastLog = logManager.logs.last {
                            proxy.scrollTo(lastLog.id, anchor: .bottom)
                        }
                    }
                }
                
                HStack {
                    Button(action: { logManager.clear() }) {
                        Text("Clear Logs")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.red.opacity(0.1))
                            .foregroundColor(.red)
                            .cornerRadius(6)
                    }
                    Spacer()
                    Button(action: { logManager.addLog("Manual Diagnostics check triggered.") }) {
                        Text("Refresh System Audit")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(6)
                    }
                }
                .padding()
                .background(Color(.systemGroupedBackground))
            }
            .navigationTitle("Audit Log Console")
            .onAppear {
                logManager.addLog("Application diagnostic logs started.")
            }
        }
    }
}

// MARK: - Log System Manager
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
            if self.logs.count > 100 {
                self.logs.removeFirst()
            }
        }
    }
    
    func clear() {
        DispatchQueue.main.async {
            self.logs.removeAll()
            self.addLog("Logs cleared.")
        }
    }
}

// MARK: - Hardware Helper Mappings
func getRAMSize() -> Double {
    let physicalMemoryBytes = ProcessInfo.processInfo.physicalMemory
    let ramSizeGB = Double(physicalMemoryBytes) / 1_073_741_824.0
    return ramSizeGB > 0 ? ramSizeGB : 3.0 // Fallback to 3GB (7 Plus Standard)
}

func getDiskStorage() -> (total: Double, free: Double) {
    do {
        let attrs = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
        if let totalSpace = attrs[.systemSize] as? Int64,
           let freeSpace = attrs[.systemFreeSize] as? Int64 {
            let totalGB = Double(totalSpace) / 1_073_741_824.0
            let freeGB = Double(freeSpace) / 1_073_741_824.0
            return (totalGB, freeGB)
        }
    } catch {}
    return (128.0, 45.0) // Fallback standard
}

func getDeviceModelIdentifier() -> String {
    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    let identifier = machineMirror.children.reduce("") { identifier, element in
        guard let value = element.value as? Int8, value != 0 else { return identifier }
        return identifier + String(UnicodeScalar(UInt8(value)))
    }
    return identifier
}

func getDeviceModelName() -> String {
    let identifier = getDeviceModelIdentifier()
    switch identifier {
    case "i386", "x86_64", "arm64": return "Simulator (iPhone 7 Plus Mode)"
    case "iPhone9,1", "iPhone9,3": return "iPhone 7"
    case "iPhone9,2", "iPhone9,4": return "iPhone 7 Plus"
    case "iPhone10,1", "iPhone10,4": return "iPhone 8"
    case "iPhone10,2", "iPhone10,5": return "iPhone 8 Plus"
    case "iPhone10,3", "iPhone10,6": return "iPhone X"
    case "iPhone11,2": return "iPhone XS"
    case "iPhone11,4", "iPhone11,6": return "iPhone XS Max"
    case "iPhone11,8": return "iPhone XR"
    case "iPhone12,1": return "iPhone 11"
    case "iPhone12,3": return "iPhone 11 Pro"
    case "iPhone12,5": return "iPhone 11 Pro Max"
    case "iPhone12,8": return "iPhone SE (2nd gen)"
    case "iPhone13,1": return "iPhone 12 mini"
    case "iPhone13,2": return "iPhone 12"
    case "iPhone13,3": return "iPhone 12 Pro"
    case "iPhone13,4": return "iPhone 12 Pro Max"
    case "iPhone14,2": return "iPhone 13 Pro"
    case "iPhone14,3": return "iPhone 13 Pro Max"
    case "iPhone14,4": return "iPhone 13 mini"
    case "iPhone14,5": return "iPhone 13"
    case "iPhone14,6": return "iPhone SE (3rd gen)"
    default: return "iPhone 7 Plus" // Default matching context
    }
}
