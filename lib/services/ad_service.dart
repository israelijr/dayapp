import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Serviço para gerenciar anúncios do Google AdMob
/// Centraliza IDs de anúncios e lógica de carregamento
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Verifica se a plataforma atual suporta anúncios
  /// Google Mobile Ads só está disponível em Android e iOS
  bool get isSupported => Platform.isAndroid || Platform.isIOS;

  // IDs de teste do AdMob (substitua pelos seus IDs de produção)
  // Obtenha seus IDs em: https://admob.google.com
  static const String _testBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';

  // TODO: Substituir pelos IDs reais de produção
  static const String _prodBannerAdUnitId =
      'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
  static const String _prodInterstitialAdUnitId =
      'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
  static const String _prodRewardedAdUnitId =
      'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';

  // Flag para usar IDs de teste ou produção
  static const bool _useTestIds = true; // Altere para false em produção

  /// Inicializa o SDK do Google Mobile Ads
  /// Só inicializa em plataformas suportadas (Android e iOS)
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Não inicializa em plataformas não suportadas (Windows, Linux, macOS, Web)
    if (!isSupported) {
      _isInitialized = false;
      return;
    }

    await MobileAds.instance.initialize();
    _isInitialized = true;
  }

  /// Obtém o ID do anúncio banner baseado na plataforma
  String get bannerAdUnitId {
    if (_useTestIds) {
      return _testBannerAdUnitId;
    }
    return Platform.isAndroid
        ? _prodBannerAdUnitId
        : _prodBannerAdUnitId; // iOS usa o mesmo ou outro ID
  }

  /// Obtém o ID do anúncio intersticial baseado na plataforma
  String get interstitialAdUnitId {
    if (_useTestIds) {
      return _testInterstitialAdUnitId;
    }
    return Platform.isAndroid
        ? _prodInterstitialAdUnitId
        : _prodInterstitialAdUnitId;
  }

  /// Obtém o ID do anúncio rewarded baseado na plataforma
  String get rewardedAdUnitId {
    if (_useTestIds) {
      return _testRewardedAdUnitId;
    }
    return Platform.isAndroid ? _prodRewardedAdUnitId : _prodRewardedAdUnitId;
  }

  /// Carrega um anúncio banner
  Future<BannerAd?> loadBannerAd({
    required Function(Ad ad) onAdLoaded,
    required Function(Ad ad, LoadAdError error) onAdFailedToLoad,
    AdSize adSize = AdSize.banner,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
        onAdOpened: (Ad ad) {},
        onAdClosed: (Ad ad) {},
      ),
    );

    await bannerAd.load();
    return bannerAd;
  }

  /// Carrega um anúncio intersticial
  Future<InterstitialAd?> loadInterstitialAd({
    required Function(InterstitialAd ad) onAdLoaded,
    required Function(LoadAdError error) onAdFailedToLoad,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    InterstitialAd? interstitialAd;

    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          interstitialAd = ad;
          onAdLoaded(ad);
        },
        onAdFailedToLoad: (error) {
          onAdFailedToLoad(error);
        },
      ),
    );

    return interstitialAd;
  }

  /// Carrega um anúncio rewarded
  Future<RewardedAd?> loadRewardedAd({
    required Function(RewardedAd ad) onAdLoaded,
    required Function(LoadAdError error) onAdFailedToLoad,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    RewardedAd? rewardedAd;

    await RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          rewardedAd = ad;
          onAdLoaded(ad);
        },
        onAdFailedToLoad: (error) {
          onAdFailedToLoad(error);
        },
      ),
    );

    return rewardedAd;
  }

  /// Configuração para mostrar anúncios intersticiais com frequência controlada
  DateTime? _lastInterstitialShownTime;
  static const Duration _interstitialMinInterval = Duration(minutes: 3);

  /// Verifica se pode mostrar um anúncio intersticial (respeitando intervalo mínimo)
  bool canShowInterstitial() {
    if (_lastInterstitialShownTime == null) return true;

    final now = DateTime.now();
    final difference = now.difference(_lastInterstitialShownTime!);

    return difference >= _interstitialMinInterval;
  }

  /// Registra que um anúncio intersticial foi exibido
  void registerInterstitialShown() {
    _lastInterstitialShownTime = DateTime.now();
  }

  /// Descarta todos os recursos de anúncios
  void dispose() {
    // Implementar limpeza se necessário
  }
}
