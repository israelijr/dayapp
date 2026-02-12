import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '1.0.0';
  String _buildNumber = '1';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _version = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
      });
    } catch (e) {
      // Mantém valores padrão em caso de erro
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sobre'), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Logo e Nome do App
          _buildAppHeader(context),

          const SizedBox(height: 24),

          // Descrição do App
          _buildSection(
            context,
            'Sobre o DayApp',
            'O DayApp é um aplicativo de diário pessoal moderno e seguro que permite registrar suas histórias, memórias e pensamentos de forma organizada e privada. Com interface intuitiva e recursos avançados, o DayApp ajuda você a preservar suas experiências mais importantes.',
            Icons.description,
          ),

          const SizedBox(height: 24),

          // Funcionalidades Principais
          _buildSection(
            context,
            'Funcionalidades',
            '',
            Icons.star,
            children: [
              _buildFeatureItem(
                'Editor Rico',
                'Crie histórias com formatação avançada, imagens, vídeos e áudios',
              ),
              _buildFeatureItem(
                'Organização Inteligente',
                'Categorize suas histórias em grupos temáticos personalizados',
              ),
              _buildFeatureItem(
                'Pesquisa Avançada',
                'Encontre rapidamente qualquer história por conteúdo ou data',
              ),
              _buildFeatureItem(
                'Backup Seguro',
                'Proteja seus dados com backup automático e manual',
              ),
              _buildFeatureItem(
                'Privacidade Total',
                'Seus dados ficam armazenados localmente e criptografados',
              ),
              _buildFeatureItem(
                'Interface Adaptável',
                'Tema claro/escuro e layouts personalizáveis',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Versão e Build
          _buildSection(
            context,
            'Versão',
            'Versão $_version (Build $_buildNumber)',
            Icons.info,
          ),

          const SizedBox(height: 24),

          // Tecnologias
          _buildSection(
            context,
            'Tecnologias',
            '',
            Icons.code,
            children: [
              _buildTechItem(
                'Flutter',
                'Framework para desenvolvimento multiplataforma',
              ),
              _buildTechItem(
                'Dart',
                'Linguagem de programação moderna e eficiente',
              ),
              _buildTechItem(
                'SQLite',
                'Banco de dados local robusto e confiável',
              ),
              _buildTechItem('Provider', 'Gerenciamento de estado reativo'),
              _buildTechItem(
                'Material Design 3',
                'Design system moderno e acessível',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Desenvolvedor
          _buildSection(
            context,
            'Desenvolvimento',
            'Desenvolvido com dedicação para oferecer a melhor experiência em registro de memórias pessoais.',
            Icons.person,
          ),

          const SizedBox(height: 24),

          // Privacidade e Segurança
          _buildSection(
            context,
            'Privacidade e Segurança',
            '',
            Icons.security,
            children: [
              _buildPrivacyItem(
                'Dados Locais',
                'Todas as suas histórias ficam armazenadas apenas no seu dispositivo',
              ),
              _buildPrivacyItem(
                'Criptografia',
                'Conteúdo sensível é protegido com criptografia avançada',
              ),
              _buildPrivacyItem(
                'Sem Rastreamento',
                'Não coletamos dados pessoais nem rastreamos seu uso',
              ),
              _buildPrivacyItem(
                'PIN de Segurança',
                'Proteja o acesso ao app com PIN ou biometria',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Contato e Suporte
          _buildContactSection(context),

          const SizedBox(height: 24),

          // Agradecimentos
          _buildSection(
            context,
            'Agradecimentos',
            'Agradecemos por escolher o DayApp para registrar suas memórias mais preciosas. Sua confiança e feedback são essenciais para continuarmos melhorando.',
            Icons.favorite,
          ),

          const SizedBox(height: 32),

          // Copyright
          Center(
            child: Text(
              '© 2026 DayApp. Todos os direitos reservados.',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(
                  context,
                ).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.support_agent,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Contato e Suporte',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Para dúvidas, sugestões ou suporte técnico:',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final Uri emailUri = Uri(
                  scheme: 'mailto',
                  path: 'israelijr.app@gmail.com',
                  queryParameters: {
                    'subject': 'Suporte DayApp',
                    'body':
                        'Olá, preciso de ajuda com o DayApp...\n\nVersão: $_version\n',
                  },
                );
                if (await canLaunchUrl(emailUri)) {
                  await launchUrl(emailUri);
                }
              },
              child: Row(
                children: [
                  Icon(
                    Icons.email,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'israelijr.app@gmail.com',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Política de Privacidade:',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                const url =
                    'https://sites.google.com/view/politicadeprivacidade-dayapp/início';
                final Uri uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: Row(
                children: [
                  Icon(
                    Icons.policy,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Política de Privacidade',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const Icon(Icons.open_in_new, size: 16, color: Colors.grey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppHeader(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Image.asset('assets/icon/icon.png', width: 80, height: 80),
            const SizedBox(height: 16),
            const Text(
              'DayApp',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Seu Diário Pessoal',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Versão $_version',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(
                  context,
                ).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    String description,
    IconData icon, {
    List<Widget>? children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                ),
              ),
            ],
            if (children != null) ...[const SizedBox(height: 16), ...children],
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechItem(String name, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shield,
                size: 16,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Text(
              description,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
