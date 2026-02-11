//
//  BannerAdView.swift
//  MathGraph Lab
//
//  UIViewRepresentable wrapper for Google Mobile Ads banner
//

import SwiftUI
import GoogleMobileAds

struct BannerAdView: UIViewRepresentable {
    
    // テスト広告ID（本番環境では実際のIDに置き換える）
    private let adUnitID = "ca-app-pub-3940256099942544/2934735716"
    
    // エラー修正: GADAdSizeBanner -> AdSizeBanner
    private let adSize = AdSizeBanner // 320x50
    
    // エラー修正: GADBannerView -> GoogleMobileAds.BannerView
    func makeUIView(context: Context) -> GoogleMobileAds.BannerView {
        let bannerView = GoogleMobileAds.BannerView(adSize: adSize)
        bannerView.adUnitID = adUnitID
        bannerView.delegate = context.coordinator
        
        // Root view controllerを設定
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            bannerView.rootViewController = rootViewController
        }
        
        // 広告をロード
        // エラー修正: GADRequest -> GoogleMobileAds.Request
        let request = GoogleMobileAds.Request()
        bannerView.load(request)
        
        return bannerView
    }
    
    // エラー修正: GADBannerView -> GoogleMobileAds.BannerView
    func updateUIView(_ bannerView: GoogleMobileAds.BannerView, context: Context) {
        // 必要に応じて更新処理
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    // エラー修正: GADBannerViewDelegate -> BannerViewDelegate
    class Coordinator: NSObject, BannerViewDelegate {
        
        // エラー修正: GADBannerView -> GoogleMobileAds.BannerView
        func bannerViewDidReceiveAd(_ bannerView: GoogleMobileAds.BannerView) {
            print("✅ Banner ad loaded successfully")
        }
        
        func bannerView(_ bannerView: GoogleMobileAds.BannerView, didFailToReceiveAdWithError error: Error) {
            print("❌ Banner ad failed to load: \(error.localizedDescription)")
        }
        
        func bannerViewDidRecordImpression(_ bannerView: GoogleMobileAds.BannerView) {
            print("📊 Banner ad impression recorded")
        }
        
        func bannerViewWillPresentScreen(_ bannerView: GoogleMobileAds.BannerView) {
            print("📱 Banner ad will present full screen")
        }
        
        func bannerViewWillDismissScreen(_ bannerView: GoogleMobileAds.BannerView) {
            print("📱 Banner ad will dismiss full screen")
        }
        
        func bannerViewDidDismissScreen(_ bannerView: GoogleMobileAds.BannerView) {
            print("📱 Banner ad dismissed full screen")
        }
    }
}

#Preview {
    VStack {
        Spacer()
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .overlay(
                Text("App Content")
                    .font(.title)
            )
        BannerAdView()
            .frame(height: 60)
    }
}
