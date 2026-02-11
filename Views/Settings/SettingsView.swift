import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: - Preferences
                Section("環境設定") {
                    Toggle(isOn: $appState.isGridSnapEnabled) {
                        Label {
                            Text("グリッド吸着")
                            Text("整数座標にスナップします")
                                .font(.caption).foregroundColor(.secondary)
                        } icon: {
                            Image(systemName: "grid")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Toggle(isOn: $appState.isHapticsEnabled) {
                        Label("触覚フィードバック", systemImage: "iphone.radiowaves.left.and.right")
                    }
                }
                
                // MARK: - Appearance
                Section("外観") {
                    Picker("テーマ", selection: $appState.appTheme) {
                        Text("ノート (Light)").tag("light")
                        Text("ダークモード").tag("dark")
                        Text("黒板 (Pro)").tag("blackboard")
                    }
                    .pickerStyle(.menu)
                    .onChange(of: appState.appTheme) { oldValue, newValue in
                        if newValue == "blackboard" && !appState.isProEnabled {
                            // Revert if locked
                            appState.appTheme = "light"
                        }
                    }
                }
                
                // MARK: - Shop (Mock)
                Section("アップグレード") {
                    IAPRow(
                        title: "Proモード",
                        description: "平行移動(p, q)、黒板テーマ、作図機能",
                        icon: "star.fill",
                        color: .orange,
                        price: "¥480",
                        isPurchased: $appState.isProEnabled
                    )
                    
                    IAPRow(
                        title: "広告を非表示",
                        description: "画面下部のバナー広告を削除",
                        icon: "xmark.bin.fill",
                        color: .red,
                        price: "¥320",
                        isPurchased: $appState.isAdRemoved
                    )
                }
                
                // MARK: - About
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0 (Beta)")
                            .foregroundColor(.secondary)
                    }
                } footer: {
                    Text("Designed for Junior High School Mathematics")
                }
            }
            .navigationTitle("設定")
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
}
