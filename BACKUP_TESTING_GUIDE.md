# 🧪 Guia de Testes - Sistema de Backup Completo

## 📋 Objetivo dos Testes

Validar que o sistema de backup completo funciona corretamente em todos os cenários:
- ✅ Backup inclui todos os dados (banco + vídeos)
- ✅ Restauração recupera 100% dos dados
- ✅ Interface é intuitiva e funcional
- ✅ Tratamento de erros é adequado

---

## 🔧 Preparação do Ambiente de Teste

### 1. Instalar Dependências
```bash
cd dayapp
flutter pub get
```

### 2. Executar o App
```bash
# Android
flutter run -d android

# Windows
flutter run -d windows
```

### 3. Criar Dados de Teste

Antes de testar, crie algumas histórias variadas:
- [ ] 5 histórias com apenas texto
- [ ] 3 histórias com texto + 2-3 fotos cada
- [ ] 2 histórias com texto + 1 áudio cada
- [ ] 3 histórias com texto + 1 vídeo cada (vídeos curtos, 10-30 segundos)
- [ ] 1 história com tudo: texto + fotos + áudio + vídeo

**Total esperado**: ~14 histórias, ~6-10 fotos, ~2 áudios, ~4 vídeos

---

## 🧪 Testes Funcionais

### Teste 1: Backup Completo na Nuvem ☁️

#### Passos:
1. Abrir o app
2. Menu → Configurações → "Gerenciar Backup Completo"
3. No card "Backup na Nuvem" (azul), clicar em "Fazer Backup Completo"
4. Aguardar conclusão do processo
5. Anotar o código de recuperação mostrado

#### Validações:
- [ ] Processo inicia sem erros
- [ ] Mensagens de progresso são exibidas
- [ ] Barra de progresso funciona corretamente
- [ ] Código de recuperação é exibido ao final
- [ ] Botão de copiar código funciona
- [ ] Mensagem de sucesso é clara

#### Tempo Esperado:
- Pequeno backup (<50 MB): 10-30 segundos
- Médio backup (50-200 MB): 30-90 segundos
- Grande backup (>200 MB): 1-3 minutos

#### O que observar:
- Tamanho total do backup
- Tempo de upload
- Uso da rede (verificar em configurações do SO)

---

### Teste 2: Restaurar da Nuvem ☁️

#### Passos:
1. Com o código do Teste 1 anotado
2. Desinstalar o app **OU** limpar dados do app
3. Reinstalar/abrir o app
4. Fazer login (se necessário)
5. Menu → Configurações → "Gerenciar Backup Completo"
6. No card "Backup na Nuvem", clicar em "Restaurar da Nuvem"
7. Digitar o código de recuperação
8. Confirmar restauração
9. Aguardar conclusão
10. **Reiniciar o app** quando solicitado

#### Validações:
- [ ] Campo de código aceita texto corretamente
- [ ] Erro amigável se código inválido
- [ ] Confirmação antes de restaurar é exibida
- [ ] Processo de download funciona
- [ ] Mensagens de progresso são claras
- [ ] Banco de dados é restaurado
- [ ] **TODOS os vídeos são restaurados**
- [ ] Fotos são exibidas corretamente
- [ ] Áudios funcionam
- [ ] Contagem de histórias está correta

#### Checklist Detalhado:
- [ ] Número de histórias correto
- [ ] Textos íntegros
- [ ] Fotos carregam e são exibidas
- [ ] Áudios tocam normalmente
- [ ] Vídeos carregam e tocam normalmente
- [ ] Datas das histórias estão corretas
- [ ] Emoticons das histórias estão corretos
- [ ] Grupos (se houver) foram restaurados

---

### Teste 3: Backup em Arquivo ZIP 📁

#### Passos:
1. Com os mesmos dados de teste
2. Menu → Configurações → "Gerenciar Backup Completo"
3. No card "Backup em Arquivo" (verde), clicar em "Criar e Compartilhar Backup"
4. Aguardar criação do ZIP
5. No menu de compartilhamento:
   - **Android**: Salvar no "Arquivos" ou Google Drive
   - **Windows**: Salvar em uma pasta conhecida (ex: Downloads)

#### Validações:
- [ ] Processo de criação funciona
- [ ] Mensagens de progresso são claras
- [ ] Menu de compartilhamento aparece
- [ ] Arquivo ZIP é criado com sucesso
- [ ] Nome do arquivo é descritivo (ex: `dayapp_backup_1696291200000.zip`)
- [ ] Arquivo pode ser localizado após salvar

#### Verificar o Arquivo:
1. Extrair o ZIP manualmente
2. Verificar conteúdo:
   - [ ] `dayapp.db` presente
   - [ ] Pasta `videos/` presente
   - [ ] Vídeos dentro da pasta (quantidade correta)
   - [ ] `backup_info.txt` presente e legível

---

### Teste 4: Restaurar de Arquivo ZIP 📁

#### Passos:
1. Com o arquivo ZIP do Teste 3 salvo
2. Desinstalar o app **OU** limpar dados
3. Reinstalar/abrir o app
4. Fazer login (se necessário)
5. Menu → Configurações → "Gerenciar Backup Completo"
6. No card "Backup em Arquivo", clicar em "Restaurar de Arquivo"
7. Navegar até o arquivo ZIP
8. Selecionar o arquivo
9. Confirmar restauração
10. Aguardar conclusão
11. **Reiniciar o app** quando solicitado

#### Validações:
- [ ] Seletor de arquivo funciona
- [ ] Filtro .zip funciona (só mostra arquivos ZIP)
- [ ] Confirmação antes de restaurar é exibida
- [ ] Processo de extração funciona
- [ ] Mensagens de progresso são claras
- [ ] Banco de dados é restaurado
- [ ] **TODOS os vídeos são restaurados**
- [ ] Todos os dados conferem com o backup original

#### Checklist Detalhado (igual ao Teste 2):
- [ ] Número de histórias correto
- [ ] Textos íntegros
- [ ] Fotos carregam e são exibidas
- [ ] Áudios tocam normalmente
- [ ] Vídeos carregam e tocam normalmente
- [ ] Datas, emoticons e grupos corretos

---

## 🚨 Testes de Erro

### Teste 5: Código Inválido

#### Passos:
1. Tentar restaurar da nuvem
2. Digite um código inválido (ex: "abcd-1234")
3. Confirmar

#### Validação:
- [ ] Erro claro e amigável é exibido
- [ ] Não trava o app
- [ ] Permite tentar novamente

---

### Teste 6: Arquivo Corrompido

#### Passos:
1. Pegar um arquivo ZIP qualquer (não backup)
2. Renomear para `dayapp_backup_teste.zip`
3. Tentar restaurar este arquivo

#### Validação:
- [ ] Erro claro é exibido
- [ ] Não trava o app
- [ ] Dados atuais não são corrompidos

---

### Teste 7: Sem Internet (Backup Nuvem)

#### Passos:
1. Desativar Wi-Fi e dados móveis
2. Tentar fazer backup na nuvem

#### Validação:
- [ ] Erro claro sobre conexão é exibido
- [ ] Não trava o app
- [ ] Sugere verificar conexão

---

### Teste 8: Sem Espaço no Dispositivo

#### Preparação:
- Simular dispositivo com pouco espaço (difícil de testar)

#### Validação:
- [ ] Erro sobre espaço insuficiente é exibido
- [ ] App não trava

---

## 📊 Testes de Performance

### Teste 9: Backup Grande

#### Preparação:
- Criar ~20 histórias com vídeos de 1-2 minutos cada
- Total esperado: >500 MB

#### Validações:
- [ ] Processo completa sem travar
- [ ] Mensagens de progresso permanecem atualizadas
- [ ] Tempo é aceitável (até 5-10 minutos)
- [ ] Memória do app não cresce descontroladamente

---

### Teste 10: Múltiplos Backups Sequenciais

#### Passos:
1. Fazer backup na nuvem
2. Imediatamente fazer outro backup
3. Repetir 3 vezes

#### Validações:
- [ ] Cada backup gera código único
- [ ] Nenhum conflito entre backups
- [ ] Todos os códigos funcionam para restaurar

---

## 🔄 Testes de Compatibilidade

### Teste 11: Backup Antigo (Sem Vídeos)

#### Preparação:
- Se tiver um backup antigo (antes desta implementação)

#### Passos:
1. Restaurar backup antigo
2. Verificar funcionamento

#### Validações:
- [ ] Backup antigo ainda funciona
- [ ] Banco de dados é restaurado corretamente
- [ ] Aviso claro se não houver vídeos no backup

---

### Teste 12: Migração

#### Passos:
1. Restaurar backup antigo (sem vídeos)
2. Adicionar novos vídeos
3. Fazer novo backup completo
4. Restaurar novo backup

#### Validações:
- [ ] Migração funciona suavemente
- [ ] Dados antigos + novos são preservados
- [ ] Novos vídeos são incluídos no backup

---

## 🎨 Testes de Interface

### Teste 13: Usabilidade

#### Checklist:
- [ ] Todos os botões são clicáveis
- [ ] Textos são legíveis
- [ ] Ícones são intuitivos
- [ ] Cores distinguem bem as seções
- [ ] Indicadores de progresso são visíveis
- [ ] Mensagens de erro são claras
- [ ] Código é fácil de copiar

---

### Teste 14: Responsividade

#### Testar em:
- [ ] Celular pequeno (5")
- [ ] Celular médio (6")
- [ ] Celular grande (6.5"+)
- [ ] Tablet (se disponível)
- [ ] Windows desktop

#### Validações:
- [ ] Layout se adapta bem
- [ ] Textos não são cortados
- [ ] Botões são acessíveis
- [ ] Scroll funciona onde necessário

---

## 📝 Checklist Final de Aceitação

### Funcionalidade Core:
- [ ] Backup na nuvem inclui vídeos
- [ ] Backup em arquivo inclui vídeos
- [ ] Restauração recupera 100% dos dados
- [ ] Interface é intuitiva e clara

### Qualidade:
- [ ] Sem crashes em uso normal
- [ ] Erros são tratados adequadamente
- [ ] Performance é aceitável
- [ ] Memória é gerenciada adequadamente

### Documentação:
- [ ] Código está documentado
- [ ] Guia do usuário está completo
- [ ] Documentação técnica está clara

### Compatibilidade:
- [ ] Funciona no Android
- [ ] Funciona no Windows
- [ ] Backups antigos ainda funcionam
- [ ] Migração é suave

---

## 🐛 Relatório de Bugs

Use este template para reportar problemas encontrados:

```
### Bug #[número]

**Descrição**: [O que aconteceu]

**Passos para Reproduzir**:
1. [Passo 1]
2. [Passo 2]
3. ...

**Resultado Esperado**: [O que deveria acontecer]

**Resultado Atual**: [O que realmente aconteceu]

**Ambiente**:
- Dispositivo: [modelo]
- SO: [Android/Windows + versão]
- Versão do App: [1.0.0]

**Screenshots/Logs**: [Se disponível]

**Severidade**: [Crítico/Alto/Médio/Baixo]
```

---

## ✅ Critérios de Aprovação

O sistema será considerado **aprovado** se:

1. ✅ **Todos os testes funcionais** passarem sem erros críticos
2. ✅ **Restauração recuperar 100%** dos dados (incluindo vídeos)
3. ✅ **Interface ser intuitiva** (feedback de 3+ usuários)
4. ✅ **Performance ser aceitável** (backup <5 min para dados normais)
5. ✅ **Erros serem tratados** adequadamente (sem crashes)
6. ✅ **Documentação estar completa** e clara

---

## 📅 Cronograma Sugerido

### Fase 1: Testes Básicos (1-2 horas)
- Testes 1-4: Funcionalidade core

### Fase 2: Testes de Erro (30 min)
- Testes 5-8: Tratamento de erros

### Fase 3: Testes de Performance (1 hora)
- Testes 9-10: Performance e stress

### Fase 4: Testes de Compatibilidade (30 min)
- Testes 11-12: Retrocompatibilidade

### Fase 5: Testes de Interface (30 min)
- Testes 13-14: UX/UI

### Total Estimado: 3-4 horas

---

## 📊 Relatório Final

Após completar todos os testes, preencher:

```
### Relatório de Testes - Sistema de Backup Completo

**Data**: [data]
**Testador**: [nome]
**Ambiente**: [Android/Windows + versão]

**Resumo**:
- Testes Executados: [X/14]
- Testes Passados: [X]
- Testes Falhados: [X]
- Bugs Encontrados: [X]
- Severidade Média: [Baixa/Média/Alta]

**Funcionalidades Testadas**:
- [x] Backup na nuvem
- [x] Restauração da nuvem
- [x] Backup em arquivo
- [x] Restauração de arquivo
- [x] Tratamento de erros
- [x] Performance
- [x] Interface

**Recomendação**:
[ ] Aprovado para produção
[ ] Aprovado com ressalvas
[ ] Necessita correções

**Observações**:
[Comentários gerais sobre os testes]
```

---

**Boa sorte com os testes!** 🚀

Se encontrar problemas, documente-os detalhadamente para facilitar a correção.
