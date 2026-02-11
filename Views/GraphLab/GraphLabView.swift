//
//  GraphLabView.swift
//  MathGraph Lab
//
//  Main interactive workspace that orchestrates all graph layers
//  Implements IDD Section 3.1 and 3.2 (Graph Lab View Structure)
//

import SwiftUI

// MARK: - Graph Lab View
/// Main workspace view that stacks all interactive layers
/// IDD Section 3.2: ZStack Layering (5 layers + controls + ads)
struct GraphLabView: View {
    
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 0) {
            // Main graph area with all layers
            ZStack {
                // LAYER 1: Background grid and axes
                GridBackgroundView()
                
                // LAYER 2: Graph rendering (parabola and line with ghosting)
                GraphCanvasView()
                
                // LAYER 3: Analysis overlay (intersections, droplines, area)
                AnalysisOverlayView()
                
                // LAYER 4: Touch interaction (rubber banding and geometry drawing)
                TouchInteractionView()
                
                // LAYER 5: Control panel overlay (bottom-aligned)
                VStack {
                    Spacer()
                    ControlPanelOverlay()
                }
            }
            .ignoresSafeArea(edges: .top) // Full screen graph area
            
            // Banner ad at the very bottom (outside main ZStack)
            // IDD Section 6: Place at bottom of ContentView ZStack/VStack
            if !appState.isAdRemoved {
                BannerAdView()
                    .frame(height: 50)
                    .background(Color(uiColor: .systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 5, y: -2)
            }
        }
        .background(getBackgroundColor())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("MathGraph Lab")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        // TODO: Implement share functionality
                        shareGraphImage()
                    }) {
                        Label("Share Graph", systemImage: "square.and.arrow.up")
                    }
                    
                    Divider()
                    
                    Toggle(isOn: $appState.isGridSnapEnabled) {
                        Label("Snap to Grid", systemImage: "grid")
                    }
                    
                    Toggle(isOn: $appState.isHapticsEnabled) {
                        Label("Haptics", systemImage: "hand.tap")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 18))
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Get background color based on current theme
    private func getBackgroundColor() -> Color {
        switch appState.appTheme {
        case "dark":
            return Color.black
        case "blackboard":
            return Color(red: 0, green: 0.3, blue: 0)  // Dark green #004d00
        default:  // "light"
            return Color.white
        }
    }
    
    /// Share graph as image (placeholder)
    /// IDD Section 4.4: Use ImageRenderer to capture Layers 1, 2, and 3 only
    private func shareGraphImage() {
        // TODO: Implement actual share functionality
        // This would use ImageRenderer to capture the graph
        print("📸 Share graph image - Not yet implemented")
        
        if appState.isHapticsEnabled {
            HapticManager.shared.impact(style: .light)
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        GraphLabView()
            .environmentObject(AppState())
    }
}
