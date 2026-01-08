# Firebase Security Rules Setup Guide

Este guia explica como configurar e implantar as regras de segurança do Firebase para o Cipher App.

## 📋 Visão Geral das Regras

### Firestore Security Rules (`firestore.rules`)
Controla o acesso aos dados persistentes:
- **Users**: Usuários podem acessar apenas seus próprios dados
- **PublicCiphers**: Leitura para usuários autenticados, escrita apenas para admins
- **Playlists**: Acesso baseado em propriedade e colaboração
- **Stats**: Apenas leitura para usuários, escrita apenas para Cloud Functions
- **InfoContent**: Leitura para todos, escrita apenas para admins

### Realtime Database Rules (`database.rules.json`)
Controla dados de sessão em tempo real:
- **Sessions**: Para sincronização de apresentações ao vivo
- **Temp**: Dados temporários com limpeza automática (24h)

## 🔐 Níveis de Acesso

### Funções de Usuário
1. **Usuário Comum (Autenticado)**
   - Lê cifras públicas e metadados
   - Cria/edita suas próprias playlists
   - Participa de sessões de apresentação

2. **Colaborador de Playlist**
   - Todas as permissões de usuário comum
   - Edita itens da playlist onde é colaborador
   - Apresenta playlists compartilhadas

3. **Administrador** (`admin: true` em claims)
   - Todas as permissões anteriores
   - Cria/edita/exclui cifras públicas
   - Gerencia conteúdo informativo
   - Exclui qualquer recurso

### Estruturas de Dados Protegidas

#### Cipher Security
```javascript
// Apenas admins podem publicar/editar cifras
allow create, update, delete: if isAdmin();

// Validação de estrutura obrigatória
request.resource.data.keys().hasAll(['title', 'author', 'musicKey'])
```

#### Playlist Security
```javascript
// Acesso baseado em proprietário/colaborador
allow read: if isOwner(resource.data.owner) || 
              isCollaborator(playlistId) ||
              resource.data.public == true;
```

## 🚀 Implantação das Regras

### 1. Verificar Configuração
```powershell
# Verificar se firebase.json está configurado corretamente
firebase projects:list

# Confirmar projeto ativo
firebase use cipherapp-8c2ee
```

### 2. Validar Regras Localmente
```powershell
# Testar regras do Firestore
firebase emulators:start --only firestore

# Testar regras do Realtime Database
firebase emulators:start --only database

# Ou testar ambos
firebase emulators:start
```

### 3. Implantar Regras
```powershell
# Implantar apenas regras do Firestore
firebase deploy --only firestore:rules

# Implantar apenas regras do Realtime Database
firebase deploy --only database

# Implantar tudo (regras + índices + functions)
firebase deploy
```

### 4. Verificar Implantação
```powershell
# Ver logs de implantação
firebase functions:log

# Verificar status das regras no console
# https://console.firebase.google.com/project/cipherapp-8c2ee
```

## 🧪 Testes de Segurança

### Comandos de Teste Local
```powershell
# Executar emulators para teste
firebase emulators:start --only firestore,database,auth

# Em outro terminal, executar testes
cd cipher_app
flutter test test/security_test.dart
```

### Cenários de Teste Importantes

1. **Teste de Autenticação**
   - Usuário não autenticado tentando acessar dados
   - Usuário comum tentando acessar dados de outro usuário

2. **Teste de Autorização Admin**
   - Usuário comum tentando criar cifra pública
   - Admin criando/editando cifras

3. **Teste de Playlist**
   - Proprietário acessando playlist privada
   - Colaborador editando itens de playlist
   - Usuário não autorizado tentando acessar playlist privada

## ⚠️ Considerações de Segurança

### Tokens de Admin
- Admin claims são definidos via Cloud Functions
- Use `grantFirstAdmin` function apenas uma vez para bootstrap
- Não exponha `grantAdminRole` em production sem validação adicional

### Validação de Dados
- Todas as escritas validam estrutura obrigatória
- Timestamps são validados contra server time
- Strings têm validação de tamanho mínimo

### Rate Limiting
- Firebase automaticamente aplica rate limiting
- Para proteção adicional, considere Cloud Functions com validação customizada

### Auditoria
- Todas as operações importantes são logadas via Firebase Analytics
- Use logs para monitorar padrões suspeitos de acesso

## 🔧 Manutenção

### Atualizações Regulares
1. Revisar regras mensalmente
2. Monitorar logs de segurança
3. Atualizar índices conforme queries evoluem
4. Testar regras após mudanças na estrutura de dados

### Backup das Regras
```powershell
# Fazer backup das regras atuais
firebase firestore:rules > backup_firestore_rules.txt
```

### Rollback de Regras
```powershell
# Em caso de emergência, usar regras de backup
firebase deploy --only firestore:rules --force
```

## 📚 Recursos Adicionais

- [Firebase Security Rules Documentation](https://firebase.google.com/docs/rules)
- [Firestore Security Rules Reference](https://firebase.google.com/docs/firestore/security/rules-conditions)
- [Realtime Database Security Rules](https://firebase.google.com/docs/database/security)
- [Security Rules Testing](https://firebase.google.com/docs/rules/unit-tests)