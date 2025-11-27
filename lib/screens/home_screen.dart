import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/auth_provider.dart';
import '../providers/pin_provider.dart';
import 'edit_profile_screen.dart';
import 'groups_maintenance_screen.dart';
import 'groups_screen.dart';
import 'home_content.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isCardView = true;
  static const String _prefKeyIsCardView = 'home_isCardView';

  @override
  void initState() {
    super.initState();
    _loadLayoutPreference();
  }

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
            const Text('DayApp', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
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
                                color: Theme.of(context).colorScheme.secondary,
                                width: 1.2,
                              )
                            : null,
                        boxShadow: active
                            ? [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.secondary
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
                            const Text(
                              'DayApp',
                              style: TextStyle(
                                color: Colors.white,
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
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.white,
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
              leading: const Icon(Icons.settings),
              title: const Text('Configurações'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
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
                await auth.logout();
                // Atualiza o status de login no PinProvider
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
          : const GroupsScreen(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/create_historia');
        },
        icon: const Icon(Icons.add),
        label: const Text('Nova História'),
      ),
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
        ],
      ),
    );
  }
}
