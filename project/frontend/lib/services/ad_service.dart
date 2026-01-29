import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'purchase_service.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // Test IDs
  final String _bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  final String _interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    _loadInterstitialAd();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _loadInterstitialAd(); // Reload for next time
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          print('InterstitialAd failed to load: $error');
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  /// Show interstitial ad if user is not premium.
  /// Returns immediately if user is premium or ad not ready.
  /// Use [onAdDismissed] to continue flow after ad.
  Future<void> showInterstitialAd(VoidCallback onAdDismissed) async {
    // 1. Premium Check
    if (PurchaseService.isPremium) {
      onAdDismissed();
      return;
    }

    // 2. Ad Readiness Check
    if (_isInterstitialAdReady && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadInterstitialAd();
          onAdDismissed();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _loadInterstitialAd();
          onAdDismissed(); // Fail-safe: continue even if ad fails
        },
      );
      _interstitialAd!.show();
      _isInterstitialAdReady = false;
    } else {
      // Fail-safe: continue if ad not ready
      print('Ad not ready, skipping');
      onAdDismissed();
    }
  }

  /// Returns a BannerAd widget if not premium, else SizedBox.
  Widget getBannerAd() {
    if (PurchaseService.isPremium) {
      return const SizedBox.shrink(); // No ad space for premium
    }

    return _BannerAdWidget(adUnitId: _bannerAdUnitId);
  }
}

class _BannerAdWidget extends StatefulWidget {
  final String adUnitId;

  const _BannerAdWidget({required this.adUnitId});

  @override
  State<_BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<_BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: widget.adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('BannerAd failed to load: $error');
        },
      ),
    );
    _bannerAd!.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isAdLoaded && _bannerAd != null) {
      return SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    return const SizedBox.shrink();
  }
}
