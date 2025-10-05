# PIN de Segurança - DayApp

## Funcionalidade Implementada

O DayApp agora possui um sistema de PIN de segurança que permite proteger o acesso ao aplicativo com um código numérico de 4 a 8 dígitos.

### Características:

- **PIN de 4 a 8 dígitos**: O usuário pode escolher um PIN entre 4 e 8 dígitos numéricos
- **Criptografia**: O PIN é armazenado com hash SHA-256 para segurança
- **Efeito Blur**: Quando ativo, a tela fica com efeito blur até o PIN ser inserido
- **Proteção em Background**: Sempre que o usuário sair do app e voltar, o PIN será solicitado novamente
- **Interface Intuitiva**: Teclado numérico personalizado para inserção do PIN

### Como Configurar:

1. Abra o aplicativo DayApp
2. Vá em **Configurações** 
3. Na seção **Segurança**, encontre a opção **PIN de Desbloqueio**
4. Ative o switch ao lado
5. Digite um PIN de 4 a 8 dígitos
6. Confirme o PIN
7. Pronto! O PIN está configurado

### Como Usar:

- **Primeira vez**: Após configurar, o PIN será solicitado imediatamente
- **Acesso posterior**: Sempre que abrir o app ou voltar de outro aplicativo, o PIN será solicitado
- **Tela protegida**: A tela ficará com efeito blur até que o PIN correto seja inserido

### Gerenciamento:

- **Alterar PIN**: Nas configurações, com o PIN ativo, aparece a opção "Alterar PIN"
- **Desabilitar PIN**: Desligue o switch na seção de segurança e confirme com o PIN atual

### Arquivos Criados/Modificados:

#### Novos Arquivos:
- `lib/services/pin_service.dart` - Serviço para gerenciar PIN
- `lib/providers/pin_provider.dart` - Provider para estado do PIN
- `lib/screens/setup_pin_screen.dart` - Tela para configurar/alterar PIN
- `lib/screens/pin_input_screen.dart` - Tela para inserir PIN (desbloqueio)
- `lib/widgets/pin_protected_wrapper.dart` - Widget wrapper que aplica proteção

#### Arquivos Modificados:
- `lib/main.dart` - Adicionado PinProvider e wrapper nas rotas
- `lib/screens/settings_screen.dart` - Adicionada opção de PIN
- `pubspec.yaml` - Adicionada dependência crypto

### Segurança:

- O PIN é armazenado usando hash SHA-256
- Não há possibilidade de recuperar o PIN original
- O PIN é validado comparando hashes
- Proteção contra saída e volta ao aplicativo

### Experiência do Usuário:

- Interface moderna com teclado numérico
- Feedback visual com círculos preenchidos
- Animação de erro quando PIN incorreto
- Feedback háptico nos toques
- Efeito blur suave para proteção visual