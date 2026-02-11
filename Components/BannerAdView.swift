//
//  BannerAdView.swift
//  MathGraph Lab
//
//  UIViewRepresentable wrapper for Google Mobile Ads banner
//  Implements IDD Section 6 (AdMob Implementation)
//

import SwiftUI
import GoogleMobileAds

// MARK: - Banner Ad View
/// Displays Google AdMob banner at bottom of screen
/// Hidden when user has purchased ad removal
struct BannerAdView: UIViewRepresentable {
    
    // IDD Section 6: Test Ad Unit ID
    // Production app should use real Ad Unit ID from AdMob console
    private let adUnitID = "ca-app-pub-3940256099942544/2934735716"
    
    // Standard banner size
    private let adSize = GADAdSizeBanner  // 320x50
    
    // MARK: - UIViewRepresentable
    
    func makeUIView(context: Context) -> GADBannerView {
        let bannerView = GADBannerView(adSize: adSize)
        bannerView.adUnitID = adUnitID
        bannerView.delegate = context.coordinator
        
        // Get root view controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            bannerView.rootViewController = rootViewController
        }
        
        // Load ad
        let request = GADRequest()
        bannerView.load(request)
        
        return bannerView
    }
    
    func updateUIView(_ bannerView: GADBannerView, context: Context) {
        // Update if needed (e.g., when orientation changes)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, GADBannerViewDelegate {
        
        func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
            print("✅ Banner ad loaded successfully")
        }
        
        func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
            print("❌ Banner ad failed to load: \(error.localizedDescription)")
        }
        
        func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
            print("📊 Banner ad impression recorded")
        }
        
        func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
            print("📱 Banner ad will present full screen")
        }
        
        func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
            print("📱 Banner ad will dismiss full screen")
        }
        
        func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
            print("📱 Banner ad dismissed full screen")
        }
    }
}

// MARK: - Banner Container View
/// Container that handles visibility based on ad removal status
struct BannerAdContainer: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 0) {
            if !appState.isAdRemoved {
                BannerAdView()
                    .frame(height: 50)
                    .background(Color(uiColor: .systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 5, y: -2)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    VStack {
        Spacer()
        
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .overlay(
                Text("App Content Area")
                    .font(.title)
            )
        
        BannerAdContainer()
    }
    .environmentObject(AppState())
}
