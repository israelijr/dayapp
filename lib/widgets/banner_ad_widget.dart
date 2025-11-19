import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';

/// Widget para exibir anúncio banner
/// Carrega e exibe automaticamente um banner AdMob
class BannerAdWidget extends StatefulWidget {
  final AdSize adSize;

  const BannerAdWidget({super.key, this.adSize = AdSize.banner});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  final AdService _adService = AdService();
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  Future<void> _loadAd() async {
    _bannerAd = await _adService.loadBannerAd(
      adSize: widget.adSize,
      onAdLoaded: (ad) {
        if (mounted) {
          setState(() {
            _isLoaded = true;
          });
        }
      },
      onAdFailedToLoad: (ad, error) {
        print('Banner ad failed to load: $error');
        ad.dispose();
      },
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
