import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajuda'), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Introdução
          _buildSection(
            context,
            'Sobre o DayApp',
            'O DayApp é um aplicativo de diário pessoal que permite registrar suas histórias, memórias e pensamentos de forma organizada e segura.',
            Icons.info_outline,
          ),

          const SizedBox(height: 24),

          // Navegação Principal
          _buildSection(
            context,
            'Navegação Principal',
            '',
            Icons.navigation,
            children: [
              _buildHelpItem(
                'Home',
                'Visualize suas histórias em cards ou lista. Toque em uma história para visualizar, manter pressionado para opções.',
              ),
              _buildHelpItem(
                'Grupos',
                'Organize suas histórias em grupos temáticos. Crie grupos personalizados para categorizar suas memórias.',
              ),
              _buildHelpItem(
                'Pesquisar',
                'Encontre histórias rapidamente por título, conteúdo ou data.',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Criando Histórias
          _buildSection(
            context,
            'Criando Histórias',
            '',
            Icons.create,
            children: [
              _buildHelpItem(
                'Nova História',
                'Toque no botão flutuante (+) para criar uma nova história. Adicione título, texto rico, imagens, vídeos e áudios.',
              ),
              _buildHelpItem(
                'Editor de Texto',
                'Use formatação rica: negrito, itálico, listas, links e muito mais.',
              ),
              _buildHelpItem(
                'Mídias',
                'Adicione fotos da galeria ou câmera, grave vídeos e áudios diretamente no app.',
              ),
              _buildHelpItem(
                'Grupos',
                'Associe cada história a um ou mais grupos para melhor organização.',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Calendário
          _buildSection(
            context,
            'Calendário',
            'Visualize suas histórias organizadas por data. Toque em uma data para ver todas as histórias daquele dia.',
            Icons.calendar_today,
          ),

          const SizedBox(height: 24),

          // Grupos
          _buildSection(
            context,
            'Gerenciando Grupos',
            '',
            Icons.group,
            children: [
              _buildHelpItem(
                'Criar Grupo',
                'Acesse "Gerenciar Grupos" no menu lateral para criar novos grupos com cores personalizadas.',
              ),
              _buildHelpItem(
                'Editar Grupo',
                'Mantenha pressionado em um grupo para editar nome, cor ou excluir.',
              ),
              _buildHelpItem(
                'Associar Histórias',
                'Ao criar ou editar uma história, selecione os grupos relacionados.',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Backup e Segurança
          _buildSection(
            context,
            'Backup e Segurança',
            '',
            Icons.security,
            children: [
              _buildHelpItem(
                'Backup Automático',
                'Configure backup automático no logout nas Configurações. O backup será criado e você poderá escolher onde salvar.',
              ),
              _buildHelpItem(
                'Backup Manual',
                'Acesse "Gerenciar Backup" nas Configurações para criar backup completo com todas as mídias.',
              ),
              _buildHelpItem(
                'Restauração',
                'Use "Restaurar de Arquivo" para recuperar dados de um backup anterior.',
              ),
              _buildHelpItem(
                'PIN de Segurança',
                'Configure PIN para proteger o acesso ao app. Use biometria se disponível.',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Configurações
          _buildSection(
            context,
            'Configurações',
            '',
            Icons.settings,
            children: [
              _buildHelpItem(
                'Tema',
                'Alterne entre tema claro, escuro ou automático.',
              ),
              _buildHelpItem(
                'Notificações',
                'Configure lembretes para escrever no diário.',
              ),
              _buildHelpItem(
                'Bloqueio Automático',
                'Defina tempo de inatividade para bloqueio automático.',
              ),
              _buildHelpItem(
                'Backup',
                'Gerencie configurações de backup e restauração.',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Lixeira
          _buildSection(
            context,
            'Lixeira',
            'Histórias excluídas ficam na lixeira por 30 dias. Acesse "Lixeira" no menu lateral para recuperar ou excluir permanentemente.',
            Icons.delete_outline,
          ),

          const SizedBox(height: 24),

          // Estatísticas
          _buildSection(
            context,
            'Estatísticas',
            'Visualize estatísticas sobre seu uso do diário: número de histórias, palavras escritas, grupos mais usados, etc.',
            Icons.analytics,
          ),

          const SizedBox(height: 24),

          // Dicas de Uso
          _buildSection(
            context,
            'Dicas de Uso',
            '',
            Icons.lightbulb,
            children: [
              _buildHelpItem(
                'Organização',
                'Use grupos para categorizar suas histórias por temas, sentimentos ou períodos da vida.',
              ),
              _buildHelpItem(
                'Pesquisa',
                'Use a função de pesquisa para encontrar histórias antigas rapidamente.',
              ),
              _buildHelpItem(
                'Backup Regular',
                'Faça backup regularmente, especialmente antes de atualizações ou mudanças no dispositivo.',
              ),
              _buildHelpItem(
                'Privacidade',
                'Suas histórias são armazenadas localmente e criptografadas. Configure PIN para proteção adicional.',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Suporte
          _buildSection(
            context,
            'Suporte',
            'Para dúvidas ou problemas, entre em contato conosco através do email de suporte ou verifique as atualizações do app.',
            Icons.support,
          ),

          const SizedBox(height: 32),
        ],
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

  Widget _buildHelpItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
