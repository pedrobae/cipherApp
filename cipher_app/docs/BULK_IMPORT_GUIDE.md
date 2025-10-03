# Guia de Importação em Lote - Cifras App

## 🎯 **Como Funciona o Sistema**

### **Workflow Completo:**
1. **Você me envia** documentos de cifras (texto, Word, ChordPro, etc.)
2. **Eu converto** para JSON no formato exato do seu app
3. **Você cola** o JSON na interface admin
4. **Sistema importa** automaticamente para SQLite + Firestore

---

## 📋 **Template JSON - Estrutura Completa**

```json
{
  "ciphers": [
    {
      "title": "Nome da Cifra",
      "author": "Nome do Autor", 
      "tempo": "Moderado",
      "music_key": "C",
      "language": "pt-BR",
      "tags": ["hino", "adoração", "clássico"],
      "versions": [
        {
          "version_name": "Original",
          "transposed_key": "C",
          "song_structure": ["I", "V1", "C", "V2", "C", "B", "C", "F"],
          "sections": {
            "I": {
              "content_type": "intro",
              "content_code": "I", 
              "content_text": "[C]Introdução musical...",
              "content_color": "#9C27B0"
            },
            "V1": {
              "content_type": "verse",
              "content_code": "V1",
              "content_text": "[C]Graça maravilhosa [F]como doce é\n[G]Que salvou um pecador [C]como eu",
              "content_color": "#2196F3"
            },
            "C": {
              "content_type": "chorus", 
              "content_code": "C",
              "content_text": "[F]Aleluia, [C]aleluia\n[G]Cristo vive em [C]mim",
              "content_color": "#F44336"
            },
            "V2": {
              "content_type": "verse",
              "content_code": "V2", 
              "content_text": "[C]Segunda estrofe da música...",
              "content_color": "#2196F3"
            },
            "B": {
              "content_type": "bridge",
              "content_code": "B",
              "content_text": "[Am]Ponte musical [F]conectando partes...",
              "content_color": "#4CAF50"
            },
            "F": {
              "content_type": "final",
              "content_code": "F",
              "content_text": "[C]Final instrumental...",
              "content_color": "#FF9800"
            }
          }
        }
      ]
    }
  ]
}
```

---

## 🎨 **Cores Padrão por Tipo de Seção**

| Tipo | Código | Cor Hex | Descrição |
|------|--------|---------|-----------|
| **Intro** | I | `#9C27B0` | Roxo - Introdução |
| **Verso** | V1, V2, V3... | `#2196F3` | Azul - Estrofes |
| **Refrão** | C | `#F44336` | Vermelho - Chorus |
| **Ponte** | B | `#4CAF50` | Verde - Bridge |
| **Final** | F | `#FF9800` | Laranja - Finalização |
| **Pré-Refrão** | PC | `#E91E63` | Rosa - Pre-Chorus |
| **Solo** | S | `#673AB7` | Roxo Escuro - Solo |

---

## 📖 **Exemplo de Conversão**

### **Documento Original:**
```
Graça Maravilhosa
John Newton
Tom: G

Intro: G - C - G - D

Verso 1:
G                    C
Graça maravilhosa, como doce é
G               D       G
Que salvou um pecador como eu

Refrão:
C           G
Aleluia, aleluia
D           G
Cristo vive em mim

Verso 2:
G                 C
Foi a graça que me ensinou
G              D        G
A temer e me consolou
```

### **JSON Convertido:**
```json
{
  "ciphers": [
    {
      "cipherId": "cifra###", // Id to be created by firebase
      "title": "Graça Maravilhosa",
      "author": "John Newton",
      "tempo": "Moderado", 
      "music_key": "G",
      "language": "pt-BR",
      "tags": ["hino", "clássico", "adoração"],
      "versions": [
        {
          "version_name": "Original",
          "transposed_key": "G",
          "song_structure": ["I", "V1", "C", "V2", "C"],
          "sections": {
            "I": {
              "content_type": "intro",
              "content_code": "I",
              "content_text": "[G] - [C] - [G] - [D]",
              "content_color": "#9C27B0"
            },
            "V1": {
              "content_type": "verse",
              "content_code": "V1", 
              "content_text": "[G]Graça maravilhosa, [C]como doce é\n[G]Que salvou um pe[D]cador como [G]eu",
              "content_color": "#2196F3"
            },
            "C": {
              "content_type": "chorus",
              "content_code": "C",
              "content_text": "[C]Aleluia, [G]aleluia\n[D]Cristo vive em [G]mim", 
              "content_color": "#F44336"
            },
            "V2": {
              "content_type": "verse",
              "content_code": "V2",
              "content_text": "[G]Foi a graça que me en[C]sinou\n[G]A temer e me conso[D]lou[G]",
              "content_color": "#2196F3"
            }
          }
        }
      ]
    }
  ]
}
```

---

## 🔧 **Como Usar a Interface Admin**

### **Passo 1: Acesso**
```
/admin/bulk-import
```
- Requer autenticação como admin
- Interface em português

### **Passo 2: Preparação**
1. Clique em **"Ver Exemplo"** para referência
2. Cole seu JSON na caixa de texto
3. Sistema detecta automaticamente quantas cifras

### **Passo 3: Validação**
1. Clique **"Validar JSON"**
2. Sistema verifica:
   - Estrutura correta
   - Campos obrigatórios
   - Formato das seções
   - Consistência dos dados

### **Passo 4: Importação**
1. Escolha se quer enviar para Firebase
2. Clique **"Importar Cifras"**
3. Acompanhe progresso em tempo real
4. Veja relatório detalhado

---

## ⚙️ **Opções de Importação**

### **Local + Nuvem (Recomendado)**
- ✅ Salva no SQLite local
- ✅ Upload para Firestore
- ✅ Disponível offline + online

### **Apenas Local**
- ✅ Salva no SQLite local
- ⏸️ Não envia para Firestore
- ✅ Funciona offline

---

## 🚨 **Validações Automáticas**

### **Campos Obrigatórios:**
- `title` - Título da cifra
- `author` - Autor/compositor

### **Validações de Estrutura:**
- JSON bem formado
- Array "ciphers" presente
- Estrutura de versões válida
- Seções com códigos únicos
- Cores em formato hexadecimal

### **Validações de Negócio:**
- Códigos de seção únicos por versão
- Song structure referencia seções existentes
- Tags são array de strings
- Campos de data válidos

---

## 📊 **Relatório de Importação**

### **Sucesso:**
```
=== RESULTADO DA IMPORTAÇÃO ===
Local: 5 sucessos, 0 falhas
Nuvem: 5 sucessos, 0 falhas

✅ Todas as cifras importadas com sucesso!
```

### **Com Falhas:**
```
=== RESULTADO DA IMPORTAÇÃO ===
Local: 3 sucessos, 2 falhas
Nuvem: 3 sucessos, 0 falhas

--- FALHAS LOCAIS ---
Amazing Grace: Campo 'title' é obrigatório
Hino Sem Autor: Campo 'author' é obrigatório
```

---

## 🎵 **Próximos Passos**

### **Para Usar:**
1. **Me envie** documentos de cifras que quer importar
2. **Receba** JSON formatado pronto para usar
3. **Cole** na interface admin
4. **Importe** automaticamente

### **Exemplos de Documentos que Aceito:**
- **Texto simples** com cifras
- **Arquivos ChordPro** (.cho, .crd)
- **Documentos Word** com letras e acordes
- **PDFs** de partituras simples
- **Listas** de músicas para buscar

Está pronto para começar! 🚀

curl -X POST https://us-central-cipherapp-8c2ee.cloudfunctions.net/grantFirstAdmin -H "Content-Type: application/json" -d '{"email": "pedrobettiolabe@gmail.com", "secret": "YOUR_SECRET_KEY_HERE"}'