//
//  ContentView.swift
//  MathGraph Lab
//
//  Main container with TabView (Graph Lab + Settings)
//  Implements IDD Section 3.1 Screen Architecture
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        TabView {
            NavigationStack {
                GraphLabView()
            }
            .tabItem {
                Label("Graph Lab", systemImage: "function")
            }
            
            // Settings Tab
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
        // Force appearance to match theme if needed, but TabView usually adapts
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
