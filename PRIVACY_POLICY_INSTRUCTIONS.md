# 📝 Política de Privacidade - Guia de Uso

## ✅ Arquivos Criados

1. **`privacy_policy.md`** - Versão em Markdown (texto simples formatado)
2. **`privacy_policy.html`** - Versão HTML estilizada para web

---

## 🌐 Como Hospedar a Política de Privacidade

Para publicar no Google Play, você precisa hospedar a política de privacidade em uma URL pública.

### Opção 1: GitHub Pages (Grátis e Recomendado)

1. **Criar repositório no GitHub:**
   - Acesse https://github.com
   - Crie um novo repositório público (ex: `dayapp-privacy`)
   
2. **Fazer upload do arquivo HTML:**
   - Renomeie `privacy_policy.html` para `index.html`
   - Faça upload para o repositório
   
3. **Ativar GitHub Pages:**
   - Vá em Settings > Pages
   - Em "Source", selecione "main" branch
   - Clique em "Save"
   
4. **Sua URL será:**
   ```
   https://[seu-usuario].github.io/dayapp-privacy/
   ```

### Opção 2: Google Sites (Grátis)

1. Acesse https://sites.google.com
2. Crie um novo site
3. Copie o conteúdo do arquivo HTML (sem as tags HTML, apenas o conteúdo)
4. Cole no editor
5. Publique o site
6. Copie a URL gerada

### Opção 3: Netlify/Vercel (Grátis)

1. Crie conta em https://netlify.com ou https://vercel.com
2. Faça deploy do arquivo HTML
3. Use a URL gerada

### Opção 4: Seu Próprio Site

Se você já tem um site/domínio, coloque o arquivo lá:
```
https://seusite.com/dayapp/privacy-policy.html
```

---

## ✏️ Personalizações Necessárias

Antes de publicar, **EDITE** os seguintes itens nos arquivos:

### Em AMBOS os arquivos (.md e .html):

1. **E-mail de contato:**
   ```
   Busque por: [Seu e-mail de contato]
   Substitua por: seu.email@exemplo.com
   ```

2. **URL da política (no arquivo .md):**
   ```
   Busque por: [insira URL onde esta política está hospedada]
   Substitua por: https://[sua-url-aqui]
   ```

3. **E-mail no HTML:**
   ```html
   Busque por: <a href="mailto:seuemail@exemplo.com">[insira seu e-mail de contato]</a>
   Substitua por: <a href="mailto:seu.email@exemplo.com">seu.email@exemplo.com</a>
   ```

---

## 📱 No Google Play Console

Quando estiver preenchendo o formulário de publicação:

1. **Campo "Privacy Policy":**
   - Cole a URL onde hospedou a política
   - Exemplo: `https://seuusuario.github.io/dayapp-privacy/`

2. **Data Safety Section (Dados de Segurança):**
   - Use as informações da política para preencher
   - Marque que NÃO coleta dados compartilhados com terceiros
   - Marque que dados são armazenados localmente

---

## 📋 Checklist de Verificação

Antes de publicar, verifique:

- [ ] Substituiu o e-mail de contato
- [ ] Substituiu a URL da política hospedada
- [ ] Testou a URL no navegador (funciona?)
- [ ] A URL é HTTPS (não HTTP)
- [ ] O conteúdo está legível e formatado
- [ ] Todas as informações estão corretas

---

## 🔒 O que NÃO precisa mudar

Os seguintes itens já estão corretos:

- ✅ Nome do desenvolvedor: Israel Inacio Junior
- ✅ Application ID: br.com.israelijr.dayapp
- ✅ Localização: Belo Horizonte - MG
- ✅ Data: 05/10/2025
- ✅ Todas as permissões e funcionalidades
- ✅ Conformidade com LGPD e GDPR

---

## 📊 Informações para o Google Play

### Dados que o app coleta (para formulário Data Safety):

**Informações Pessoais:**
- ✅ Nome e endereço de e-mail
- ✅ Fotos e vídeos
- ✅ Arquivos de áudio

**Como os dados são usados:**
- ✅ Funcionalidade do app
- ❌ NÃO para Analytics
- ❌ NÃO para Publicidade
- ❌ NÃO compartilhado com terceiros

**Armazenamento:**
- ✅ Todos os dados armazenados localmente
- ❌ NÃO enviado para servidores

**Segurança:**
- ✅ Dados criptografados em trânsito (N/A - não há transmissão)
- ✅ Dados criptografados no dispositivo (Android padrão)
- ✅ Possibilidade de solicitar exclusão (desinstalar app)

---

## 🎯 Próximos Passos

Após hospedar a política:

1. ✅ Salve a URL da política de privacidade
2. ✅ Teste a URL no navegador
3. ✅ Anote para usar no Google Play Console
4. ✅ Continue com os próximos itens de publicação:
   - Screenshots
   - Ícone da loja
   - Descrição do app
   - Vídeo promocional (opcional)

---

## 💡 Dicas Importantes

### Para GitHub Pages:
```bash
# Comandos para criar e publicar rapidamente
git init
git add index.html
git commit -m "Add privacy policy"
git branch -M main
git remote add origin https://github.com/[usuario]/dayapp-privacy.git
git push -u origin main
```

### Testar localmente:
Abra o arquivo `privacy_policy.html` diretamente no navegador para ver como ficará.

### Manter atualizado:
Se atualizar a política no futuro:
1. Altere a data no topo
2. Faça upload da nova versão
3. Notifique usuários no app

---

## ❓ FAQ

**P: Preciso de um advogado para revisar?**
R: Recomendável, mas a política está bem completa e em conformidade com LGPD/GDPR.

**P: Posso usar um domínio personalizado?**
R: Sim! O Google aceita qualquer URL HTTPS válida.

**P: E se eu mudar algo no app?**
R: Atualize a política, mude a data, e publique novamente.

**P: Preciso traduzir para outros idiomas?**
R: Não é obrigatório para Brasil, mas ajuda se for global.

---

**Boa sorte com a publicação! 🚀**
