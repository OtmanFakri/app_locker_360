import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Helper class for managing Google Mobile Ads
/// Uses only TEST ad unit IDs for development
class AdHelper {
  // Private constructor to prevent instantiation
  AdHelper._();

  /// Initialize Mobile Ads SDK
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  /// Get Banner Ad Unit ID (Test ID)
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      // Test banner ad unit ID for Android
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      // Test banner ad unit ID for iOS
      return 'ca-app-pub-3940256099942544/2934735716';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  /// Get Interstitial Ad Unit ID (Test ID)
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      // Test interstitial ad unit ID for Android
      return 'ca-app-pub-3940256099942544/1033173712';
    } else if (Platform.isIOS) {
      // Test interstitial ad unit ID for iOS
      return 'ca-app-pub-3940256099942544/4411468910';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  /// Get Rewarded Ad Unit ID (Test ID)
  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      // Test rewarded ad unit ID for Android
      return 'ca-app-pub-3940256099942544/5224354917';
    } else if (Platform.isIOS) {
      // Test rewarded ad unit ID for iOS
      return 'ca-app-pub-3940256099942544/1712485313';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  /// Create and load a banner ad
  static BannerAd createBannerAd({
    required AdSize adSize,
    required void Function(Ad, LoadAdError) onAdFailedToLoad,
    required void Function(Ad) onAdLoaded,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
        onAdOpened: (Ad ad) => print('Ad opened.'),
        onAdClosed: (Ad ad) => print('Ad closed.'),
      ),
    );
  }

  /// Load an interstitial ad
  static Future<InterstitialAd?> loadInterstitialAd() async {
    InterstitialAd? interstitialAd;

    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          interstitialAd = ad;
          print('Interstitial ad loaded.');
        },
        onAdFailedToLoad: (error) {
          print('InterstitialAd failed to load: $error');
        },
      ),
    );

    return interstitialAd;
  }

  /// Load a rewarded ad
  static Future<RewardedAd?> loadRewardedAd() async {
    RewardedAd? rewardedAd;

    await RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          rewardedAd = ad;
          print('Rewarded ad loaded.');
        },
        onAdFailedToLoad: (error) {
          print('RewardedAd failed to load: $error');
        },
      ),
    );

    return rewardedAd;
  }
}
