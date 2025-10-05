# 🔐 Configuração da Keystore - DayApp

## ⚠️ IMPORTANTE - SEGURANÇA

Este diretório contém arquivos sensíveis que **NUNCA** devem ser commitados no Git:

- `upload-keystore.jks` - Arquivo da keystore
- `key.properties` - Senhas e configurações da keystore

Estes arquivos já estão no `.gitignore` do projeto.

## 📝 Configuração Atual

### Arquivo: `key.properties`

Você precisa **substituir os placeholders** no arquivo `key.properties` com suas senhas reais:

```properties
storePassword=<SUBSTITUA_PELA_SENHA_DO_KEYSTORE>
keyPassword=<SUBSTITUA_PELA_SENHA_DA_CHAVE>
keyAlias=upload
storeFile=upload-keystore.jks
```

**Senhas que você definiu durante a criação da keystore:**
- `storePassword`: A senha da área de armazenamento (primeira senha informada)
- `keyPassword`: A senha da chave (pode ser a mesma da área de armazenamento se você apertou RETURN)

### Informações da Keystore

- **Arquivo**: `upload-keystore.jks`
- **Alias**: `upload`
- **Algoritmo**: RSA 2048 bits
- **Validade**: 10.000 dias (~27 anos)
- **Tipo**: JKS (Java KeyStore)

**Dados do Certificado:**
```
CN=Israel Inacio Junior
OU=israelijr
O=israelijr
L=Belo Horizonte
ST=Minas Gerais
C=BR
```

## 🔒 Backup da Keystore

### ⚠️ CRÍTICO - FAÇA BACKUP AGORA!

**Se você perder a keystore, NUNCA mais poderá atualizar seu app no Google Play!**

1. **Copie imediatamente** o arquivo `upload-keystore.jks` para um local seguro:
   - Serviço de nuvem criptografado (OneDrive, Google Drive com criptografia)
   - Pendrive em local físico seguro
   - Gerenciador de senhas (1Password, Bitwarden, etc)

2. **Salve as senhas** em um gerenciador de senhas seguro

3. **Documentação recomendada:**
   - Anote a data de criação: 05/10/2025
   - Anote quando a keystore expira (aproximadamente 2052)
   - Mantenha uma cópia das informações do certificado

## 🚀 Como Usar

### Gerar APK de Release Assinado

```bash
flutter build apk --release
```

### Gerar App Bundle (Recomendado para Google Play)

```bash
flutter build appbundle --release
```

O arquivo gerado estará em:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- Bundle: `build/app/outputs/bundle/release/app-release.aab`

## 📱 Publicação no Google Play

1. Acesse [Google Play Console](https://play.google.com/console)
2. Crie um novo aplicativo
3. Faça upload do arquivo `.aab` (App Bundle)
4. O Google Play gerenciará automaticamente a assinatura do app (App Signing by Google Play)

## 🔄 App Signing by Google Play (Recomendado)

Quando você faz o primeiro upload, o Google Play oferece gerenciar a assinatura do app.
**Recomendo aceitar** porque:

- ✅ Google gerencia a chave de produção
- ✅ Você mantém a upload key (mais seguro)
- ✅ Possível recuperar acesso se perder a upload key
- ✅ Suporte a múltiplas variantes de APK

Sua `upload-keystore.jks` será usada apenas para fazer upload. O Google assina o APK final com a chave de produção.

## 📞 Suporte

Se tiver problemas:
1. Verifique se as senhas em `key.properties` estão corretas
2. Verifique se o arquivo `upload-keystore.jks` existe
3. Execute `flutter clean` e tente novamente
4. Consulte: https://docs.flutter.dev/deployment/android

---

**Data de Criação**: 05/10/2025  
**Desenvolvedor**: Israel Inacio Junior (israelijr)  
**Application ID**: br.com.israelijr.dayapp
