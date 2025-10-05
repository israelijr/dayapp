# 📊 Respostas para Data Safety - Google Play Console

Este documento contém as respostas corretas para preencher o formulário "Data Safety" (Segurança de Dados) no Google Play Console.

---

## 📋 Seção 1: Coleta e Compartilhamento de Dados

### Pergunta: Seu app coleta ou compartilha algum dos tipos de dados de usuários necessários?

**Resposta:** ✅ **SIM**

**Explicação:** O app coleta dados pessoais como nome, email, fotos, vídeos e áudios.

---

## 📋 Seção 2: Tipos de Dados Coletados

### Categoria: INFORMAÇÕES PESSOAIS

#### Nome
- **Coletado?** ✅ SIM
- **Compartilhado com terceiros?** ❌ NÃO
- **Opcional ou obrigatório?** ✅ Obrigatório
- **Propósito:** Funcionalidade do app (personalização)
- **Criptografado em trânsito?** N/A (não transmitido)
- **Usuário pode solicitar exclusão?** ✅ SIM

#### Endereço de e-mail
- **Coletado?** ✅ SIM
- **Compartilhado com terceiros?** ❌ NÃO
- **Opcional ou obrigatório?** ✅ Obrigatório
- **Propósito:** Funcionalidade do app (identificação de conta)
- **Criptografado em trânsito?** N/A (não transmitido)
- **Usuário pode solicitar exclusão?** ✅ SIM

#### Data de nascimento
- **Coletado?** ✅ SIM
- **Compartilhado com terceiros?** ❌ NÃO
- **Opcional ou obrigatório?** ⚠️ Opcional
- **Propósito:** Funcionalidade do app (perfil)
- **Criptografado em trânsito?** N/A (não transmitido)
- **Usuário pode solicitar exclusão?** ✅ SIM

---

### Categoria: FOTOS E VÍDEOS

#### Fotos
- **Coletado?** ✅ SIM
- **Compartilhado com terceiros?** ❌ NÃO
- **Opcional ou obrigatório?** ⚠️ Opcional
- **Propósito:** Funcionalidade do app (conteúdo gerado pelo usuário)
- **Criptografado em trânsito?** N/A (não transmitido)
- **Usuário pode solicitar exclusão?** ✅ SIM

#### Vídeos
- **Coletado?** ✅ SIM
- **Compartilhado com terceiros?** ❌ NÃO
- **Opcional ou obrigatório?** ⚠️ Opcional
- **Propósito:** Funcionalidade do app (conteúdo gerado pelo usuário)
- **Criptografado em trânsito?** N/A (não transmitido)
- **Usuário pode solicitar exclusão?** ✅ SIM

---

### Categoria: ARQUIVOS DE ÁUDIO

#### Gravações de voz ou som
- **Coletado?** ✅ SIM
- **Compartilhado com terceiros?** ❌ NÃO
- **Opcional ou obrigatório?** ⚠️ Opcional
- **Propósito:** Funcionalidade do app (conteúdo gerado pelo usuário)
- **Criptografado em trânsito?** N/A (não transmitido)
- **Usuário pode solicitar exclusão?** ✅ SIM

---

### Categoria: OUTROS CONTEÚDOS GERADOS PELO USUÁRIO

#### Outros conteúdos gerados pelo usuário
- **Coletado?** ✅ SIM
- **Compartilhado com terceiros?** ❌ NÃO
- **Opcional ou obrigatório?** ✅ Obrigatório
- **Propósito:** Funcionalidade do app (histórias do diário)
- **Criptografado em trânsito?** N/A (não transmitido)
- **Usuário pode solicitar exclusão?** ✅ SIM

---

### Categoria: INFORMAÇÕES DO DISPOSITIVO OU DE OUTROS IDS

#### ID do dispositivo
- **Coletado?** ❌ NÃO

---

## 📋 Seção 3: Práticas de Segurança

### Os dados são criptografados em trânsito?
**Resposta:** ⚠️ **N/A (Não Aplicável)**

**Explicação:** O app não transmite dados para servidores. Todos os dados são armazenados localmente no dispositivo.

---

### Os dados são criptografados em repouso (no dispositivo)?
**Resposta:** ✅ **SIM**

**Explicação:** Os dados são protegidos pela criptografia padrão do sistema operacional Android.

---

### Os usuários podem solicitar a exclusão de dados?
**Resposta:** ✅ **SIM**

**Explicação:** Usuários podem:
1. Excluir histórias individualmente no app
2. Limpar todos os dados nas configurações do app
3. Desinstalar o aplicativo

---

## 📋 Seção 4: Coleta de Dados

### O app coleta dados?
**Resposta:** ✅ **SIM**

---

### Todos os dados coletados são opcionais?
**Resposta:** ❌ **NÃO**

**Dados obrigatórios:**
- Nome
- E-mail
- Conteúdo do diário (histórias)

**Dados opcionais:**
- Data de nascimento
- Avatar (foto de perfil)
- Fotos anexadas às histórias
- Vídeos anexados às histórias
- Áudios anexados às histórias

---

## 📋 Seção 5: Compartilhamento de Dados

### O app compartilha dados com terceiros?
**Resposta:** ❌ **NÃO**

**Explicação:** Nenhum dado é compartilhado com terceiros. Todos os dados permanecem localmente no dispositivo do usuário.

---

## 📋 Seção 6: Propósito do Uso de Dados

### Para que os dados coletados são usados?

Selecione: **Funcionalidade do app**

**NÃO selecione:**
- ❌ Analytics
- ❌ Publicidade ou marketing
- ❌ Personalização de anúncios
- ❌ Prevenção de fraude
- ❌ Comunicação com desenvolvedores

---

## 📋 Seção 7: Informações Adicionais

### Seu app permite que os usuários criem contas?
**Resposta:** ✅ **SIM**

**Tipo de conta:** Local (não sincronizada com servidores)

---

### Seu app permite que usuários entrem com autenticação de terceiros?
**Resposta:** ❌ **NÃO**

---

### Seu app implementa autenticação biométrica?
**Resposta:** ✅ **SIM**

**Explicação:** O app permite proteção por impressão digital ou Face ID.

---

## 🎯 Resumo das Respostas-Chave

```
✅ Coleta dados: SIM
✅ Dados obrigatórios: Nome, Email, Conteúdo
⚠️ Dados opcionais: Fotos, Vídeos, Áudios, Data de nascimento
❌ Compartilha com terceiros: NÃO
❌ Transmite dados: NÃO
✅ Armazenamento local: SIM
✅ Criptografia no dispositivo: SIM (padrão Android)
✅ Usuário pode excluir: SIM
✅ Propósito: Funcionalidade do app
❌ Analytics: NÃO
❌ Publicidade: NÃO
✅ Autenticação biométrica: SIM
```

---

## 💡 Dicas para Preencher

1. **Seja honesto e preciso** - O Google verifica as declarações
2. **Leia cada pergunta com atenção** - Algumas são similares
3. **Use a política de privacidade** como referência
4. **Salve rascunhos** durante o preenchimento
5. **Revise antes de enviar** - Mudanças posteriores precisam nova revisão

---

## ⚠️ Avisos Importantes

### O Google pode verificar:
- Análise do código do app
- Testes automatizados
- Revisão manual

### Se houver inconsistências:
- App pode ser rejeitado
- Pode precisar de nova revisão
- Política de privacidade deve corresponder às declarações

---

## 🔄 Atualizações Futuras

Se você adicionar novos recursos que coletam dados diferentes:

1. ✅ Atualize a política de privacidade
2. ✅ Atualize o formulário Data Safety
3. ✅ Submeta nova versão do app
4. ✅ Aguarde nova revisão

---

## 📞 Suporte

Se tiver dúvidas ao preencher:
- Consulte: https://support.google.com/googleplay/android-developer/answer/10787469
- Centro de ajuda do Google Play Console
- Fóruns de desenvolvedores

---

**Boa sorte com a publicação! 🚀**

*Documento atualizado em 05/10/2025*
