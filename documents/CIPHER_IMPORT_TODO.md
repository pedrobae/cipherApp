# Cipher Import Feature - TODO List
**Objetivo**: Melhorar significativamente a inserção de cifras através de importação inteligente

---

## 📋 FASE 1: ARQUITETURA & ESTRUTURA BASE

### 1.2 Criar Estrutura de Parsing
- [ ] **Criar** `lib/models/dtos/import_result.dart`
  - DTO para resultado de importação
  - Campos: `rawText`, `source` (pdf/image/text), `metadata`
- [ ] **Criar** `lib/models/dtos/parsed_section.dart`
  - DTO para seção parseada
  - Campos: `suggestedCode`, `suggestedType`, `chordProContent`, `suggestedColor`

---

## 📱 FASE 2: UI DE IMPORTAÇÃO
### 2.2 Criar Dialog de Importação de Texto
- [ ] **Criar** `lib/widgets/dialogs/import_text_dialog.dart`
  - `TextFormField` grande (maxLines: 20) para colar texto
  - Botão "Processar e Importar"
  - Executa parsing → popula provider → fecha dialog
  - Usuário volta para `EditCipher` com seções já carregadas

### 2.3 Refatorar EditCipher para Suportar Modo "Pós-Importação"
- [ ] **Modificar** `lib/screens/cipher/cipher_editor.dart`
  - Adicionar botão "Importar" no AppBar quando `_isNewVersion || _isNewCipher`
  - Botão abre `ImportMethodDialog`
  - **ESTRATÉGIA**: Não criar tela de preview separada, usar editor existente
- [ ] **Modificar** `lib/providers/version_provider.dart`
  - Adicionar método `loadImportedSections(List<ParsedSection> sections)`
  - Popula `currentVersion.sections` e `songStructure`
  - Mantém flag `_isImported` para indicar origem dos dados
  - Chama `notifyListeners()` para atualizar UI
- [ ] **Adicionar** banner informativo no VersionForm (opcional mas recomendado)
  - Se `_isImported == true`, mostrar `MaterialBanner` no topo:
  - "✨ Cifra importada! Revise as seções e edite conforme necessário."
  - Botão "Entendi" remove banner (seta flag para false)
  - Cor diferenciada para destacar

### 2.4 Fluxo de Importação Simplificado
**Fluxo Completo**:
```
EditCipher (new cipher/version)
      ↓
[AppBar: Botão "Importar"]
      ↓
ImportMethodDialog (BottomSheet)
  • Importar de Texto
  • Importar de PDF  
  • Importar de Imagem
      ↓
[Seleciona: Texto] → ImportTextDialog
      ↓
Usuario cola texto → [Processar]
      ↓
ChordProConverter.parse(rawText)
      ↓
SectionDetector.detectSections(chordProText)
      ↓
versionProvider.loadImportedSections(parsedSections)
      ↓
Dialog fecha automaticamente
      ↓
EditCipher recarrega (seções já populadas no VersionForm)
      ↓
Usuario revisa/edita seções no editor normal
      ↓
[Botão Salvar] → Persiste no DB (confirmação implícita)
```

**Benefícios desta Abordagem**:
- ✅ Reutiliza 100% da UI de edição existente
- ✅ Usuário pode editar imediatamente após importação
- ✅ Botão "Salvar" serve como confirmação natural
- ✅ Não precisa de tela de preview separada (menos código)
- ✅ Menos navegação entre telas = UX mais fluida
- ✅ Aproveita validação e features do editor existente
- ✅ Consistência: mesma experiência para criar manualmente ou importar

---

## 🎯 FASE 3: PARSING INTELIGENTE

### 3.1 Implementar ChordLineParser
- [ ] **Implementar** `ChordLineParser.isChordLine(String line)`
  - Heurística baseada em regex para acordes comuns
  - Padrões: `C`, `Am`, `G7`, `Dm/F`, `C#m`, `Bb`, etc.
  - Proporção de palavras que são acordes > 50%
  - Considerar espaçamento (acordes têm mais espaços)
- [ ] **Implementar** `ChordLineParser.extractChordPositions(String line)`
  - Retorna lista de `(chord, position)` tuples
- [ ] **Adicionar** suporte para notação portuguesa e inglesa
  - Dó, Ré, Mi = C, D, E
  - Menor (m), Maior (M), etc.

### 3.2 Implementar ChordProConverter
- [ ] **Implementar** `ChordProConverter.convert(String rawText)`
  - Itera linha por linha
  - Identifica pares chord-line + lyric-line
  - Mapeia posições dos acordes nas letras
  - Insere acordes como `[chord]` nas posições corretas
- [ ] **Implementar** algoritmo de alinhamento de posição
  - Calcula offset de cada acorde baseado em posição na linha de acordes
  - Insere acorde antes da sílaba/palavra correspondente na letra
- [ ] **Lidar com edge cases**:
  - Linhas de acordes sem letra correspondente
  - Letras sem acordes
  - Acordes no meio de palavras
  - Múltiplos acordes em sequência

### 3.3 Implementar SectionDetector
- [ ] **Implementar** `SectionDetector.detectSections(String chordProText)`
  - Divide texto por linhas vazias (separadores de seção)
  - Retorna `List<ParsedSection>`
- [ ] **Implementar** reconhecimento de labels de seção
  - Regex para padrões comuns:
    - `Verso 1`, `V1`, `Verse 1` → V1
    - `Refrão`, `Chorus`, `C` → C
    - `Ponte`, `Bridge`, `B` → B
    - `Intro`, `I` → I
    - `Final`, `Outro`, `O` → O
  - Detecta labels no início do bloco
- [ ] **Implementar** geração de código padrão
  - Se não detectar label: gera V1, V2, V3 sequencialmente
  - Usuário pode editar no preview
- [ ] **Implementar** sugestão de cores
  - Usa `defaultSectionColors` de `section_constants.dart`
  - Fallback para cores aleatórias de `availableColors`

### 3.4 Testes Unitários de Parsing
- [ ] **Criar** `test/services/parsing/chord_line_parser_test.dart`
  - Testa detecção de linhas de acordes
  - Casos: acordes simples, complexos, linhas ambíguas
- [ ] **Criar** `test/services/parsing/chordpro_converter_test.dart`
  - Testa conversão completa
  - Input: texto bruto com acordes e letras
  - Output: texto ChordPro formatado
- [ ] **Criar** `test/services/parsing/section_detector_test.dart`
  - Testa detecção de seções
  - Casos: com labels, sem labels, múltiplas seções

---

## 📄 FASE 4: IMPORTAÇÃO DE PDF

### 4.1 Implementar PDFImportService
- [ ] **Implementar** `PDFImportService.importFromPDF()`
  - Usa `file_picker` para seleção de arquivo
  - Usa `syncfusion_flutter_pdf` para extração de texto:
    ```dart
    import 'package:syncfusion_flutter_pdf/pdf.dart';
    
    Future<String> extractTextFromPDF(String filePath) async {
      final PdfDocument document = PdfDocument(inputBytes: File(filePath).readAsBytesSync());
      final String text = PdfTextExtractor(document).extractText();
      document.dispose();
      return text;
    }
    ```
  - Retorna `ImportResult` com texto extraído
- [ ] **Criar** dialog ou método inline para seleção de PDF
  - Integra com `ImportMethodDialog`
  - Extrai texto e passa para parser

### 4.2 Lidar com Formatação de PDF
- [ ] **Implementar** limpeza de texto de PDF
  - Remove headers/footers comuns
  - Lida com quebras de linha estranhas
  - Normaliza espaçamento
- [ ] **Testar** com PDFs reais de cifras
  - Ultimate Guitar exports
  - Cifra Club exports
  - PDFs escaneados (texto, não imagem)

---

## 📸 FASE 5: IMPORTAÇÃO POR IMAGEM (OCR)

### 5.1 Implementar ImageImportService
- [ ] **Implementar** `ImageImportService.importFromImage()`
  - Usa `image_picker` para seleção/captura
  - Usa `google_mlkit_text_recognition` para OCR
  - Retorna `ImportResult` com texto extraído
- [ ] **Criar** `lib/screens/cipher/import_image_screen.dart`
  - Opções: Galeria ou Câmera
  - Preview da imagem selecionada
  - Botão "Processar Imagem" → OCR → parser → preview

### 5.2 Melhorias de OCR
- [ ] **Implementar** pré-processamento de imagem
  - Ajuste de contraste
  - Binarização
  - Rotação automática
- [ ] **Implementar** heurística adicional para OCR
  - Acordes geralmente em fonte diferente/menor
  - Uso de análise de layout do ML Kit
  - Detecção de blocos de texto para seções
- [ ] **Lidar com qualidade de imagem**
  - Mostrar aviso se confiança do OCR for baixa
  - Permitir retry com outra imagem
  - Sugerir edição manual

### 5.3 Testes com Imagens Reais
- [ ] **Testar** com:
  - Fotos de livros de cifras
  - Screenshots de sites de cifras
  - Cifras escritas à mão (difícil, baixa prioridade)

---

## ✨ FASE 6: MELHORIAS DE EDIÇÃO

### 6.1 Drag-and-Drop de Acordes
- [ ] **Criar** `lib/widgets/cipher/editor/chord_palette.dart`
  - Painel lateral ou bottom sheet com acordes comuns
  - Acordes organizados por tonalidade
  - Drag source para cada acorde
- [ ] **Modificar** campo de texto de seção em `version_form.dart`
  - Tornar campo um `DragTarget<String>`
  - Ao soltar acorde, insere `[chord]` na posição do cursor
- [ ] **Implementar** `lib/widgets/cipher/editor/draggable_chord_chip.dart`
  - Widget `Draggable` para cada acorde no palette
  - Visual feedback durante drag

### 6.2 Paleta de Acordes Comuns
- [ ] **Criar** `lib/utils/chord_constants.dart`
  - Mapas de acordes por tonalidade:
    ```dart
    const Map<String, List<String>> chordsByKey = {
      'C': ['C', 'Dm', 'Em', 'F', 'G', 'Am', 'Bdim'],
      'G': ['G', 'Am', 'Bm', 'C', 'D', 'Em', 'F#dim'],
      // ... todas as tonalidades
    };
    ```
  - Lista de acordes mais usados em PT-BR
- [ ] **Implementar** seleção de tonalidade no palette
  - Dropdown para selecionar tonalidade base
  - Atualiza acordes mostrados dinamicamente
- [ ] **Adicionar** acordes avançados
  - Sus, 7, 9, diminished, augmented, etc.
  - Toggle "Mostrar Acordes Avançados"

### 6.3 Reposicionamento de Acordes por Drag (OPCIONAL - v2.0)
- [ ] **Criar** `lib/widgets/cipher/editor/chord_editor_field.dart`
  - Campo de texto customizado para edição de seções
  - Renderiza acordes `[chord]` como chips draggable dentro do texto
  - Permite arrastar chips para reposicionar acordes
- [ ] **Implementar** lógica de reposicionamento
  - Detecta posição de drop
  - Atualiza texto ChordPro com nova posição
  - Mantém sincronização com `TextEditingController`
- **NOTA**: Esta feature é complexa e pode esperar. O usuário pode editar texto diretamente.

### 6.4 Melhorias na Edição de Seções (Prioridade Baixa)
- [ ] **Adicionar** ação de "Dividir Seção"
  - Divide seção no cursor em duas seções
  - Usuário seleciona ponto de divisão
- [ ] **Adicionar** ação de "Mesclar Seções"
  - Mescla seção atual com próxima
  - Botão no card da seção
- [ ] **Adicionar** preview inline do ChordPro
  - Toggle "Modo Preview" para ver como ficará renderizado
  - Usa widget `ChordProView` existente
- **NOTA**: Usuário já tem controle total via `VersionForm`, estas são melhorias incrementais

---

## 🎨 FASE 7: POLISH & UX

### 7.1 Feedback Visual
- [ ] **Adicionar** loading indicators durante parsing
  - Skeleton screens para preview
  - Progress indicator para OCR
- [ ] **Adicionar** animações de transição
  - Entre telas de importação
  - Ao adicionar/remover seções
- [ ] **Adicionar** snackbars de sucesso/erro
  - "Texto processado com sucesso!"
  - "X seções detectadas"
  - Erros de parsing com sugestão de edição manual

### 7.2 Onboarding & Ajuda
- [ ] **Criar** `lib/widgets/cipher/import/import_help_dialog.dart`
  - Explica formato esperado de texto
  - Mostra exemplo de cifra bem formatada
  - Dicas para melhor resultado de OCR
- [ ] **Adicionar** tooltips nos botões de importação
  - Explicações breves de cada método
- [ ] **Criar** tutorial first-time
  - Mostrar na primeira vez que usuário acessa importação
  - Walkthrough básico

### 7.3 Acessibilidade
- [ ] **Garantir** labels semânticos em todos os botões
- [ ] **Adicionar** suporte para screen readers
- [ ] **Testar** navegação por teclado
- [ ] **Verificar** contraste de cores em todos os widgets

### 7.4 Internacionalização (Opcional)
- [ ] **Extrair** strings hardcoded para arquivo de localização
  - Manter português como padrão
  - Preparar para suporte futuro a inglês
- [ ] **Usar** strings localizadas em todos os widgets de importação

---

## 🧪 FASE 8: TESTES & VALIDAÇÃO

### 8.1 Testes de Integração
- [ ] **Criar** `test/integration/import_flow_test.dart`
  - Testa fluxo completo: importar → preview → confirmar
  - Mock de serviços de importação
- [ ] **Criar** `test/widgets/import_preview_screen_test.dart`
  - Testa edição de seções no preview
  - Testa confirmação e navegação

### 8.2 Testes com Dados Reais
- [ ] **Criar** `test/fixtures/` directory com cifras de teste
  - `sample_cipher_raw.txt` - texto bruto
  - `sample_cipher_chordpro.txt` - esperado após parsing
  - `sample_cipher.pdf` - PDF de teste
  - `sample_cipher.jpg` - imagem de teste
- [ ] **Executar** testes end-to-end com cada fixture
- [ ] **Documentar** edge cases descobertos

### 8.3 Testes de Usabilidade
- [ ] **Recrutar** 3-5 usuários para teste beta
- [ ] **Observar** uso da feature de importação
- [ ] **Coletar** feedback sobre:
  - Facilidade de uso
  - Qualidade do parsing
  - Necessidade de edição manual
  - Features faltando
- [ ] **Iterar** baseado no feedback

---

## 📚 FASE 9: DOCUMENTAÇÃO

### 9.1 Documentação Técnica
- [ ] **Criar** `docs/IMPORT_FEATURE.md`
  - Arquitetura da feature
  - Como adicionar novos métodos de importação
  - Algoritmos de parsing explicados
- [ ] **Adicionar** comments nos métodos complexos
  - Especialmente em `chordpro_converter.dart`
  - Explicar lógica de alinhamento de acordes

### 9.2 Documentação de Usuário
- [ ] **Criar** guia de importação no app
  - Acessível via "?" button nas telas de importação
  - Formato markdown ou HTML simples
- [ ] **Criar** vídeo tutorial (opcional)
  - Screencast de 2-3 minutos
  - Mostrar cada método de importação

---

## 🚀 FASE 10: DEPLOY & MONITORAMENTO (Contínuo)

### 10.1 Preparação para Lançamento
- [ ] **Atualizar** changelog com nova feature
- [ ] **Incrementar** versão no `pubspec.yaml`
- [ ] **Executar** `flutter analyze` e corrigir warnings
- [ ] **Executar** `flutter test` e garantir 100% pass
- [ ] **Build** de release para Windows/Android

### 10.2 Monitoramento Pós-Lançamento
- [ ] **Adicionar** analytics para rastrear uso
  - Quantos imports por método
  - Taxa de sucesso de parsing
  - Tempo médio de edição pós-import
- [ ] **Criar** formulário de feedback in-app
  - Específico para feature de importação
- [ ] **Monitorar** crash reports relacionados a import

---

## 📊 MÉTRICAS DE SUCESSO

### Objetivos Quantitativos
- [ ] **80%+** de cifras importadas requerem < 5 minutos de edição
- [ ] **90%+** de acordes detectados corretamente
- [ ] **70%+** de seções detectadas corretamente (code + type)
- [ ] **95%+** taxa de sucesso em conversão ChordPro

### Objetivos Qualitativos
- [ ] Usuários preferem importar vs. digitar do zero
- [ ] Feedback positivo sobre facilidade de uso
- [ ] Redução no tempo médio de criação de cifra em 60%+

---

## 🔧 MELHORIAS FUTURAS (Backlog)

### Curto Prazo
- [ ] Importação via URL (scraping de sites de cifras)
- [ ] Suporte para tablatura (tabs de guitarra)
- [ ] Transposição automática durante importação
- [ ] Template de seções (salvar estruturas comuns)

### Médio Prazo
- [ ] IA generativa para correção de parsing
  - Usar LLM para melhorar detecção de seções
  - Sugerir correções de acordes errados
- [ ] Importação de múltiplas cifras em batch
- [ ] OCR de cifras escritas à mão
- [ ] Integração com APIs de cifras (Cifra Club, etc.)

### Longo Prazo
- [ ] Reconhecimento de áudio → geração de cifra
- [ ] Colaboração em tempo real na edição de importação
- [ ] Marketplace de cifras importadas (compartilhamento)

---

## 📝 NOTAS DE IMPLEMENTAÇÃO

### Ordem de Implementação
1. **FASE 2** → UI de importação (dialogs + integração com EditCipher)
2. **FASE 3** → Parsing inteligente (depende dos dados reais de importação)
3. **FASE 4** → PDF import
4. **FASE 1** → Refatorar para arquitetura de serviços (opcional)
5. **FASE 7** → Polish básico (feedback, loading)
6. **FASE 8** → Testes
7. **FASE 6** → Melhorias de edição avançadas (opcional)
8. **FASE 5** → OCR (complexo, pode ser v2.0)

### Riscos & Mitigações
| Risco | Probabilidade | Impacto | Mitigação |
|-------|---------------|---------|-----------|
| Parsing de acordes impreciso | Alta | Alto | Testes extensivos com fixtures reais, permitir edição manual fácil |
| OCR de baixa qualidade | Média | Médio | Pré-processamento de imagem, feedback claro ao usuário |
| UX complexa demais | Baixa | Alto | Testes de usabilidade, iterar rapidamente |
| Performance em PDFs grandes | Baixa | Baixo | Processar em background, mostrar progress |

### Padrões de Código a Seguir
- Usar padrão StatefulWidget com `addPostFrameCallback` para pre-loading
- Todos os services em `lib/services/` devem ser singleton ou stateless
- **Parsing deve ser idempotente** (mesmo input = mesmo output)
- **UI strings sempre em português** (ver copilot-instructions.md)
- **Providers seguem padrão existente**: `_cache`, `isLoading`, `error`, `notifyListeners()`

---

## 📊 FLUXO VISUAL

```mermaid
flowchart TD
    A[EditCipher Screen<br/>Nova Cifra/Versão] --> B{Botão Importar}
    B --> C[ImportMethodDialog<br/>BottomSheet]
    
    C --> D1[Opção: Texto]
    C --> D2[Opção: PDF]
    C --> D3[Opção: Imagem]
    
    D1 --> E1[ImportTextDialog<br/>TextFormField grande]
    D2 --> E2[FilePicker<br/>Seleciona PDF]
    D3 --> E3[ImagePicker<br/>Galeria/Câmera]
    
    E1 --> F[Texto Bruto]
    E2 --> G[PDF → Extração] --> F
    E3 --> H[Imagem → OCR] --> F
    
    F --> I[ChordLineParser<br/>Detecta linhas de acordes vs letras]
    I --> J[ChordProConverter<br/>Gera [chord]lyric]
    J --> K[SectionDetector<br/>Identifica blocos e labels]
    
    K --> L[List&lt;ParsedSection&gt;<br/>code, type, content, color]
    
    L --> M[VersionProvider<br/>loadImportedSections]
    M --> N[Atualiza currentVersion<br/>sections + songStructure]
    N --> O[notifyListeners]
    
    O --> P[Dialog Fecha]
    P --> Q[EditCipher Recarrega<br/>Seções já populadas]
    
    Q --> R{MaterialBanner<br/>Cifra importada!}
    R --> S[Usuario Revisa/Edita<br/>VersionForm normal]
    
    S --> T[Botão Salvar]
    T --> U[Persiste no DB<br/>Confirmação Implícita]
    U --> V[Navegação de Volta<br/>Feature Completa]
    
    style F fill:#e1f5ff
    style L fill:#fff4e1
    style N fill:#e8f5e9
    style Q fill:#f3e5f5
    style U fill:#c8e6c9
```

---

## ✅ CHECKLIST DE READY FOR REVIEW

Antes de considerar a feature completa:
- [ ] Todos os testes passando
- [ ] Zero warnings no `flutter analyze`
- [ ] Documentação técnica completa
- [ ] Testado em Windows + Android
- [ ] Feedback de pelo menos 3 usuários beta
- [ ] Changelog atualizado
- [ ] Screenshots/GIFs para documentação
- [ ] Code review completo
- [ ] Acessibilidade verificada

---

**Última Atualização**: 3 de Novembro de 2025
