import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/auth_provider.dart';
import '../providers/pin_provider.dart';
import '../services/auto_backup_service.dart';
import '../db/database_helper.dart';
// import '../services/battery_optimization_service.dart';
// import '../widgets/battery_optimization_dialog.dart';
import 'edit_profile_screen.dart';
import 'groups_maintenance_screen.dart';
import 'groups_screen.dart';
import 'home_content.dart';
import 'search_screen.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isCardView = true;
  // Flag estática para garantir que a sugestão de backup seja mostrada
  // apenas uma vez por inicialização do app.
  static bool _backupSuggestionShown = false;
  static const String _prefKeyIsCardView = 'home_isCardView';

  @override
  void initState() {
    super.initState();
    _loadLayoutPreference();
    // Executar a checagem de histórias não salvas apenas na primeira
    // construção após o carregamento do app.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_backupSuggestionShown) {
        _checkUnsavedStories();
        _backupSuggestionShown = true;
      }
    });
    // _checkBatteryOptimization();
  }

  Future<void> _checkUnsavedStories() async {
    // Pequeno delay para não competir com o carregamento inicial
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    try {
      final db = await DatabaseHelper().database;
      final res = await db.rawQuery(
        "SELECT COUNT(*) as cnt FROM historia WHERE (backed_up IS NULL OR backed_up = 0) AND excluido IS NULL",
      );
      final cnt = (res.first['cnt'] ?? 0) as int;
      if (cnt > 0 && mounted) {
        // Mostrar diálogo amigável com imagem e opções
        showDialog<void>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Imagem amigável para sugerir backup
                  Image.asset(
                    'assets/image/Fazendo backup de maneira amigável.png',
                    height: 140,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Você tem $cnt histórias não salvas em backup.',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Recomendamos fazer backup para não perder seus dados.',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    Navigator.pushNamed(context, '/backup-manager');
                  },
                  child: const Text('Fazer backup'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Silencia erros durante a checagem inicial
    }
  }

  /// Verifica se a otimização de bateria está desabilitada
  /// e mostra o dialog se necessário
  // Future<void> _checkBatteryOptimization() async {
  //   // Aguarda um pouco para não atrapalhar o carregamento inicial
  //   await Future.delayed(const Duration(seconds: 2));

  //   if (!mounted) return;

  //   final batteryService = BatteryOptimizationService();
  //   final shouldShow = await batteryService.shouldShowBatteryWarning();

  //   if (shouldShow && mounted) {
  //     await BatteryOptimizationDialog.show(context);
  //   }
  // }

  Future<void> _loadLayoutPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final val = prefs.getBool(_prefKeyIsCardView);
      if (val != null) {
        setState(() {
          _isCardView = val;
        });
      }
    } catch (_) {
      // ignore errors and keep default
    }
  }

  Future<void> _saveLayoutPreference(bool isCard) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKeyIsCardView, isCard);
    } catch (_) {
      // ignore
    }
  }

  // screens list is built dynamically in the body to reflect current view mode

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/icon/icon.png', width: 32, height: 32),
            const SizedBox(width: 12),
            Text(
              _selectedIndex == 0
                  ? 'DayApp'
                  : _selectedIndex == 1
                  ? 'Grupos'
                  : 'Pesquisar',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          // Só mostra os botões de visualização na aba Home
          if (_selectedIndex == 0)
            Builder(
              builder: (context) {
                const duration = Duration(milliseconds: 300);
                Widget buildToggle(
                  String asset,
                  bool active,
                  String tooltip,
                  VoidCallback onTap,
                ) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        onTap();
                      },
                      child: AnimatedContainer(
                        duration: duration,
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: active
                              ? Theme.of(
                                  context,
                                ).colorScheme.secondary.withValues(alpha: 0.14)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: active
                              ? Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                  width: 1.2,
                                )
                              : null,
                          boxShadow: active
                              ? [
                                  BoxShadow(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary
                                        .withValues(alpha: 0.08),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: AnimatedScale(
                          duration: duration,
                          curve: Curves.easeOutBack,
                          scale: active ? 1.05 : 1.0,
                          child: Image.asset(asset, width: 28, height: 28),
                        ),
                      ),
                    ),
                  );
                }

                return Row(
                  children: [
                    buildToggle(
                      'assets/image/card.png',
                      _isCardView,
                      'Ver em cards grandes',
                      () {
                        setState(() {
                          _isCardView = true;
                        });
                        _saveLayoutPreference(true);
                      },
                    ),
                    buildToggle(
                      'assets/image/icone_pequeno.png',
                      !_isCardView,
                      'Ver em cards reduzidos',
                      () {
                        setState(() {
                          _isCardView = false;
                        });
                        _saveLayoutPreference(false);
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          Navigator.pushNamed(context, '/calendar');
                        },
                        child: Tooltip(
                          message: 'Ver calendário',
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Image.asset(
                              'assets/image/calendario.png',
                              width: 28,
                              height: 28,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Builder(
                builder: (context) {
                  final user = Provider.of<AuthProvider>(context).user;
                  ImageProvider profileImage;
                  if (user != null &&
                      user.fotoPerfil != null &&
                      user.fotoPerfil!.isNotEmpty) {
                    final fp = user.fotoPerfil!;
                    if (fp.startsWith('http') || fp.startsWith('https')) {
                      profileImage = NetworkImage(fp);
                    } else {
                      try {
                        final file = File(fp);
                        if (file.existsSync()) {
                          profileImage = FileImage(file);
                        } else {
                          profileImage = const AssetImage(
                            'assets/image/icone_pequeno.png',
                          );
                        }
                      } catch (_) {
                        profileImage = const AssetImage(
                          'assets/image/icone_pequeno.png',
                        );
                      }
                    }
                  } else {
                    profileImage = const AssetImage(
                      'assets/image/icone_pequeno.png',
                    );
                  }

                  return Row(
                    children: [
                      Image.asset(
                        'assets/icon/icon.png',
                        width: 48,
                        height: 48,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'DayApp',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              user?.nome ?? '',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                            Text(
                              user?.email ?? '',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Mostrar foto ampliada em um diálogo
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                backgroundColor: Colors.transparent,
                                child: Stack(
                                  children: [
                                    Center(
                                      child: Container(
                                        constraints: BoxConstraints(
                                          maxWidth:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.9,
                                          maxHeight:
                                              MediaQuery.of(
                                                context,
                                              ).size.height *
                                              0.9,
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child:
                                              user?.fotoPerfil != null &&
                                                  user!.fotoPerfil!.isNotEmpty
                                              ? (user.fotoPerfil!.startsWith(
                                                          'http',
                                                        ) ||
                                                        user.fotoPerfil!
                                                            .startsWith('https')
                                                    ? Image.network(
                                                        user.fotoPerfil!,
                                                        fit: BoxFit.contain,
                                                        errorBuilder:
                                                            (
                                                              context,
                                                              error,
                                                              stackTrace,
                                                            ) {
                                                              return Image.asset(
                                                                'assets/image/icone_pequeno.png',
                                                                fit: BoxFit
                                                                    .contain,
                                                              );
                                                            },
                                                      )
                                                    : (File(
                                                            user.fotoPerfil!,
                                                          ).existsSync()
                                                          ? Image.file(
                                                              File(
                                                                user.fotoPerfil!,
                                                              ),
                                                              fit: BoxFit
                                                                  .contain,
                                                            )
                                                          : Image.asset(
                                                              'assets/image/icone_pequeno.png',
                                                              fit: BoxFit
                                                                  .contain,
                                                            )))
                                              : Image.asset(
                                                  'assets/image/icone_pequeno.png',
                                                  fit: BoxFit.contain,
                                                ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.close,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                          size: 30,
                                        ),
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: CircleAvatar(
                          radius: 24,
                          backgroundImage: profileImage,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Editar Perfil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics_outlined),
              title: const Text('Estatísticas'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StatisticsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Gerenciar Grupos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GroupsMaintenanceScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Lixeira'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/trash');
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Ajuda'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/help');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configurações'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Sobre'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/about');
              },
            ),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sair'),
              onTap: () async {
                final navigator = Navigator.of(context);
                final auth = Provider.of<AuthProvider>(context, listen: false);
                final pinProvider = Provider.of<PinProvider>(
                  context,
                  listen: false,
                );

                // Fecha o drawer antes de iniciar o backup
                navigator.pop();

                // Executa backup automático ao fazer logout
                final autoBackup = AutoBackupService();
                final configured = await autoBackup.isConfigured();
                if (configured && mounted) {
                  final zipPath = await _showAutoBackupProgress(autoBackup);
                  // Abre a tela de compartilhamento para o usuário escolher onde salvar
                  if (zipPath != null) {
                    try {
                      // Evita bloqueio ao voltar do share sheet
                      pinProvider.isPickingExternalMedia = true;
                      // ignore: deprecated_member_use
                      await Share.shareXFiles(
                        [XFile(zipPath)],
                        subject: 'Backup Automático DayApp',
                        text: 'Backup automático do DayApp',
                      );
                    } catch (e) {
                      // Silencia erro se o usuário cancelar o compartilhamento
                    } finally {
                      pinProvider.isPickingExternalMedia = false;
                    }
                  }
                }

                await auth.logout();
                pinProvider.updateUserLoginStatus(false);
                if (!mounted) return;
                navigator.pushReplacementNamed('/login');
              },
            ),
          ],
        ),
      ),
      body: _selectedIndex == 0
          ? HomeContent(isCardView: _isCardView)
          : _selectedIndex == 1
          ? const GroupsScreen()
          : const SearchScreen(),
      // Mostra o FAB apenas nas abas Home e Grupos
      floatingActionButton: _selectedIndex != 2
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushNamed(context, '/create_historia');
              },
              icon: const Icon(Icons.add),
              label: const Text('Nova História'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.group_outlined),
            selectedIcon: Icon(Icons.group),
            label: 'Grupos',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Pesquisar',
          ),
        ],
      ),
    );
  }

  /// Exibe dialog de progresso durante o backup automático ao fazer logout.
  /// Retorna o caminho do ZIP criado, ou null em caso de erro/cancelamento.
  Future<String?> _showAutoBackupProgress(AutoBackupService autoBackup) async {
    // Controlador para atualizar o texto de progresso
    final progressNotifier = ValueNotifier<String>('Iniciando backup...');
    String? resultPath;

    // Inicia o backup antes de abrir o dialog
    final backupFuture = autoBackup.executeBackup(
      onProgress: (message) {
        progressNotifier.value = message;
      },
    );

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        // Fecha o dialog quando o backup terminar
        backupFuture.then((zipPath) {
          resultPath = zipPath;
          if (dialogContext.mounted) {
            Navigator.of(dialogContext).pop();
          }
        });

        return PopScope(
          canPop: false,
          child: AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                const Text(
                  'Backup Automático',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder<String>(
                  valueListenable: progressNotifier,
                  builder: (context, message, _) {
                    return Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    progressNotifier.dispose();
    return resultPath;
  }
}
