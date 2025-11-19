import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';

/// Helper para gerenciar anúncios rewarded (com recompensa)
/// Use para oferecer recompensas aos usuários que assistirem anúncios
class RewardedAdHelper {
  static final RewardedAdHelper _instance = RewardedAdHelper._internal();
  factory RewardedAdHelper() => _instance;
  RewardedAdHelper._internal();

  final AdService _adService = AdService();
  RewardedAd? _rewardedAd;
  bool _isLoading = false;

  /// Carrega um anúncio rewarded
  Future<void> load() async {
    if (_isLoading || _rewardedAd != null) return;

    _isLoading = true;

    await _adService.loadRewardedAd(
      onAdLoaded: (ad) {
        _rewardedAd = ad;
        _isLoading = false;
      },
      onAdFailedToLoad: (error) {
        print('Rewarded ad failed to load: $error');
        _isLoading = false;
      },
    );
  }

  /// Mostra o anúncio rewarded se estiver carregado
  /// [onRewarded] é chamado quando o usuário ganha a recompensa
  /// [onAdDismissed] é chamado quando o anúncio é fechado
  Future<void> show({
    required Function(int amount, String type) onRewarded,
    Function? onAdDismissed,
  }) async {
    if (_rewardedAd == null) {
      print('Rewarded ad not ready yet');
      // Tenta carregar para a próxima vez
      load();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        print('Rewarded ad showed full screen');
      },
      onAdDismissedFullScreenContent: (ad) {
        print('Rewarded ad dismissed');
        ad.dispose();
        _rewardedAd = null;
        onAdDismissed?.call();
        // Carrega o próximo anúncio
        load();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('Rewarded ad failed to show: $error');
        ad.dispose();
        _rewardedAd = null;
        onAdDismissed?.call();
        // Carrega o próximo anúncio
        load();
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        print('User earned reward: ${reward.amount} ${reward.type}');
        onRewarded(reward.amount.toInt(), reward.type);
      },
    );

    _rewardedAd = null;
  }

  /// Verifica se o anúncio está pronto para ser exibido
  bool get isReady => _rewardedAd != null;

  /// Libera recursos
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}
