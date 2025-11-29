import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';

/// Helper para gerenciar anúncios intersticiais
/// Use para exibir anúncios em tela cheia entre telas
class InterstitialAdHelper {
  static final InterstitialAdHelper _instance =
      InterstitialAdHelper._internal();
  factory InterstitialAdHelper() => _instance;
  InterstitialAdHelper._internal();

  final AdService _adService = AdService();
  InterstitialAd? _interstitialAd;
  bool _isLoading = false;

  /// Carrega um anúncio intersticial
  Future<void> load() async {
    if (_isLoading || _interstitialAd != null) return;

    _isLoading = true;

    await _adService.loadInterstitialAd(
      onAdLoaded: (ad) {
        _interstitialAd = ad;
        _isLoading = false;

        _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdShowedFullScreenContent: (ad) {

          },
          onAdDismissedFullScreenContent: (ad) {

            ad.dispose();
            _interstitialAd = null;
            // Carrega o próximo anúncio
            load();
          },
          onAdFailedToShowFullScreenContent: (ad, error) {

            ad.dispose();
            _interstitialAd = null;
            // Carrega o próximo anúncio
            load();
          },
        );
      },
      onAdFailedToLoad: (error) {

        _isLoading = false;
      },
    );
  }

  /// Mostra o anúncio intersticial se estiver carregado
  /// Retorna true se o anúncio foi exibido
  Future<bool> show() async {
    if (_interstitialAd == null) {

      // Tenta carregar para a próxima vez
      load();
      return false;
    }

    // Verifica se pode mostrar (respeitando intervalo mínimo)
    if (!_adService.canShowInterstitial()) {

      return false;
    }

    await _interstitialAd!.show();
    _adService.registerInterstitialShown();
    _interstitialAd = null;

    return true;
  }

  /// Libera recursos
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}
