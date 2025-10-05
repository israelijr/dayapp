# ⚠️ AÇÃO NECESSÁRIA - Configure suas senhas!

## 🔐 Passo Final: Editar key.properties

Você precisa **editar manualmente** o arquivo `key.properties` e substituir os placeholders pelas suas senhas REAIS.

### 📍 Localização do arquivo:
```
c:\DEV\dayapp\android\key.properties
```

### ✏️ O que editar:

Abra o arquivo `key.properties` e substitua:

```properties
storePassword=<SUA_SENHA_DO_KEYSTORE>  ← SUBSTITUA AQUI
keyPassword=<SUA_SENHA_DA_CHAVE>       ← SUBSTITUA AQUI
keyAlias=upload
storeFile=upload-keystore.jks
```

### 🔑 Quais senhas usar?

Durante a criação da keystore, você informou:

1. **storePassword** = A primeira senha que você digitou (senha da área de armazenamento)
2. **keyPassword** = A segunda senha (ou a mesma da primeira, se você apertou RETURN)

### ✅ Exemplo de arquivo preenchido:

```properties
storePassword=MinhaSenh@Segur@123
keyPassword=MinhaSenh@Segur@123
keyAlias=upload
storeFile=upload-keystore.jks
```

---

## 🚀 Após configurar, você pode:

### 1️⃣ Testar a configuração:
```bash
flutter build apk --release
```

### 2️⃣ Gerar App Bundle para Google Play:
```bash
flutter build appbundle --release
```

---

## ⚠️ LEMBRE-SE:

- ✅ **FAÇA BACKUP** do arquivo `upload-keystore.jks` EM LOCAL SEGURO
- ✅ **SALVE AS SENHAS** em um gerenciador de senhas
- ❌ **NUNCA commite** o arquivo `key.properties` com senhas reais no Git
- ❌ **NUNCA compartilhe** a keystore publicamente

---

**Se perder a keystore, não será possível atualizar o app no Google Play!**
