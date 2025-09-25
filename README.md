# 📱 DayApp - Diário Digital

Um aplicativo de diário pessoal desenvolvido em Flutter que permite aos usuários registrar suas histórias, memórias e experiências diárias com fotos, localização e muito mais.

## ✨ Funcionalidades

### 📝 Registro de Histórias
- **Criação de histórias**: Adicione título, descrição e data/hora personalizada
- **Fotos**: Anexe múltiplas fotos às suas histórias usando a câmera ou galeria
- **Capitalização automática**: Títulos e descrições são automaticamente formatados com primeira letra maiúscula
- **Emoticons**: Suporte completo a emoticons no campo de descrição

### 🎨 Interface Personalizável
- **Dois modos de visualização**:
  - **Modo Blocos**: Cards detalhados com todas as informações
  - **Modo Ícones**: Visualização compacta com ícones pequenos
- **Transições suaves**: Animações fluidas entre os modos de exibição
- **Tema roxo elegante**: Interface moderna e intuitiva

### 🔐 Sistema de Autenticação
- **Login seguro**: Sistema de autenticação com e-mail e senha
- **Registro de conta**: Criação de novas contas de usuário
- **Persistência de sessão**: Mantenha-se logado entre sessões

### 💾 Armazenamento Local
- **Banco de dados SQLite**: Dados armazenados localmente no dispositivo
- **Fotos otimizadas**: Imagens comprimidas e armazenadas eficientemente

## 🚀 Tecnologias Utilizadas

- **Flutter**: Framework principal para desenvolvimento multiplataforma
- **Dart**: Linguagem de programação
- **SQLite**: Banco de dados local
- **Provider**: Gerenciamento de estado
- **Image Picker**: Captura e seleção de imagens
- **Intl**: Formatação de datas e internacionalização
- **Material Design 3**: Componentes de interface moderna

## 📦 Dependências Principais

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.5
  sqflite: ^2.3.0
  path: ^1.8.3
  image_picker: ^1.0.4
  intl: ^0.19.0
  m3_carousel: ^1.0.2
  shared_preferences: ^2.2.2
  path_provider: ^2.1.1
```

## 🛠️ Instalação e Execução

### Pré-requisitos
- Flutter SDK (versão 3.0 ou superior)
- Android Studio ou VS Code
- Dispositivo Android ou emulador

### Passos para execução

1. **Clone o repositório**:
   ```bash
   git clone https://github.com/SEU_USERNAME/dayapp.git
   cd dayapp
   ```

2. **Instale as dependências**:
   ```bash
   flutter pub get
   ```

3. **Execute o aplicativo**:
   ```bash
   flutter run
   ```

4. **Para build de produção**:
   ```bash
   flutter build apk --release
   ```

## 📱 Estrutura do Projeto

```
lib/
├── main.dart                 # Ponto de entrada da aplicação
├── db/                       # Camada de dados
│   ├── database_helper.dart  # Configuração do SQLite
│   └── historia_foto_helper.dart # Gerenciamento de fotos
├── models/                   # Modelos de dados
│   ├── historia.dart         # Modelo de história
│   ├── historia_foto.dart    # Modelo de foto
│   └── user.dart             # Modelo de usuário
├── providers/                # Gerenciamento de estado
│   └── auth_provider.dart    # Provedor de autenticação
├── screens/                  # Telas da aplicação
│   ├── login_screen.dart     # Tela de login
│   ├── home_screen.dart      # Tela principal com histórias
│   ├── create_historia_screen.dart # Criação de histórias
│   └── edit_historia_screen.dart   # Edição de histórias
├── widgets/                  # Componentes reutilizáveis
│   └── custom_text_field.dart # Campo de texto personalizado
└── assets/                   # Recursos estáticos
    ├── icon/                 # Ícones do app
    └── image/                # Imagens da interface
```

## 🎯 Funcionalidades em Destaque

### Modos de Visualização
O aplicativo oferece dois modos distintos de visualização das histórias:

- **Modo Blocos**: Visualização completa com cards grandes contendo título, descrição, fotos e data
- **Modo Ícones**: Visualização compacta com ícones pequenos, ideal para navegação rápida

### Capitalização Automática
Os campos de título e descrição são automaticamente formatados com a primeira letra de cada palavra em maiúsculo, garantindo consistência visual.

### Suporte a Emoticons
O campo de descrição suporta completamente emoticons e emojis, permitindo expressões mais ricas e pessoais nas histórias.

## 🤝 Contribuição

Contribuições são bem-vindas! Para contribuir:

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

## 📞 Contato

Para dúvidas ou sugestões, entre em contato através das issues do GitHub.

---

**Desenvolvido com ❤️ usando Flutter**
