// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const PdfAnalysisApp());
}

class PdfAnalysisApp extends StatelessWidget {
  const PdfAnalysisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Analysis Preview',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const PdfAnalysisScreen(),
    );
  }
}

class PdfAnalysisScreen extends StatefulWidget {
  const PdfAnalysisScreen({super.key});

  @override
  State<PdfAnalysisScreen> createState() => _PdfAnalysisScreenState();
}

class _PdfAnalysisScreenState extends State<PdfAnalysisScreen> {
  final List<PdfDocument> _documents = [];
  final List<String> _documentNames = [];
  final Map<String, List<TextLineData>> _documentData = {};
  int _selectedDocIndex = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    for (var doc in _documents) {
      doc.dispose();
    }
    super.dispose();
  }

  Future<void> _pickPdfFiles() async {
    try {
      setState(() => _isLoading = true);

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        for (var file in result.files) {
          if (file.path != null) {
            await _loadPdfDocument(file.path!, file.name);
          }
        }
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao carregar PDF: $e')));
      }
    }
  }

  Future<void> _loadPdfDocument(String path, String name) async {
    try {
      final bytes = await File(path).readAsBytes();
      final document = PdfDocument(inputBytes: bytes);

      final List<TextLineData> allLines = [];

      // Extract text from all pages
      final textExtractor = PdfTextExtractor(document);
      for (int i = 0; i < document.pages.count; i++) {
        final textLines = textExtractor.extractTextLines(
          startPageIndex: i,
          endPageIndex: i,
        );

        int lineNumber = 0;
        for (var line in textLines) {
          allLines.add(
            TextLineData(
              pageNumber: i + 1,
              lineNumber: lineNumber++,
              text: line.text,
              fontSize: line.fontSize,
              fontStyle: line.fontStyle.isNotEmpty
                  ? line.fontStyle.first
                  : PdfFontStyle.regular,
              bounds: line.bounds,
              wordCount: line.wordCollection.length,
              words: line.wordCollection
                  .map(
                    (w) => WordData(
                      text: w.text,
                      fontSize: w.fontSize,
                      fontStyle: w.fontStyle.isNotEmpty
                          ? w.fontStyle.first
                          : PdfFontStyle.regular,
                      bounds: w.bounds,
                    ),
                  )
                  .toList(),
            ),
          );
        }
      }

      if (mounted) {
        setState(() {
          _documents.add(document);
          _documentNames.add(name);
          _documentData[name] = allLines;
          _selectedDocIndex = _documents.length - 1;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao processar $name: $e')));
      }
    }
  }

  void _clearAll() {
    setState(() {
      for (var doc in _documents) {
        doc.dispose();
      }
      _documents.clear();
      _documentNames.clear();
      _documentData.clear();
      _selectedDocIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDocuments = _documents.isNotEmpty;
    final currentDocName = hasDocuments
        ? _documentNames[_selectedDocIndex]
        : null;
    final currentData = currentDocName != null
        ? _documentData[currentDocName]
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Analysis Preview'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          if (hasDocuments)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearAll,
              tooltip: 'Limpar todos',
            ),
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: _pickPdfFiles,
            tooltip: 'Importar PDFs',
          ),
        ],
      ),
      body: !hasDocuments
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.picture_as_pdf,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum PDF carregado',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _pickPdfFiles,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Importar PDFs'),
                  ),
                ],
              ),
            )
          : Row(
              children: [
                // Document list sidebar
                Container(
                  width: 200,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: ListView.builder(
                    itemCount: _documentNames.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          _documentNames[index],
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: _selectedDocIndex == index
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        selected: _selectedDocIndex == index,
                        selectedTileColor: theme.colorScheme.primaryContainer,
                        onTap: () {
                          setState(() {
                            _selectedDocIndex = index;
                          });
                        },
                      );
                    },
                  ),
                ),
                // Main content
                Expanded(
                  child: Stack(
                    children: [
                      if (currentData != null)
                        _buildAnalysisView(currentData, theme)
                      else
                        const Center(child: CircularProgressIndicator()),
                      if (_isLoading)
                        Container(
                          color: Colors.black54,
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text(
                                  'Processando PDF...',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAnalysisView(List<TextLineData> data, ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary stats
        _buildSummaryCard(data, theme),
        const SizedBox(height: 16),

        // Font size distribution chart
        _buildChartCard(
          'Distribuição de Tamanho de Fonte',
          _buildFontSizeChart(data, theme),
          theme,
        ),
        const SizedBox(height: 16),

        // Word count per line chart
        _buildChartCard(
          'Palavras por Linha',
          _buildWordCountChart(data, theme),
          theme,
        ),
        const SizedBox(height: 16),

        // Line height chart
        _buildChartCard(
          'Altura das Linhas',
          _buildLineHeightChart(data, theme),
          theme,
        ),
        const SizedBox(height: 16),

        // Y-position chart
        _buildChartCard(
          'Posição Vertical (Y)',
          _buildYPositionChart(data, theme),
          theme,
        ),
        const SizedBox(height: 16),

        // Line spacing chart
        _buildChartCard(
          'Espaçamento Entre Linhas',
          _buildLineSpacingChart(data, theme),
          theme,
        ),
        const SizedBox(height: 16),

        // Font style per line chart
        _buildChartCard(
          'Estilo de Fonte por Linha',
          _buildFontStylePerLineChart(data, theme),
          theme,
        ),
        const SizedBox(height: 16),

        // Font style distribution
        _buildFontStyleCard(data, theme),
        const SizedBox(height: 16),

        // Detailed line list
        _buildDetailedLineList(data, theme),
      ],
    );
  }

  Widget _buildSummaryCard(List<TextLineData> data, ThemeData theme) {
    if (data.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Resumo', style: theme.textTheme.titleLarge),
              const Divider(),
              const Text('Nenhum dado disponível'),
            ],
          ),
        ),
      );
    }

    final totalLines = data.length;
    final totalPages = data.last.pageNumber;
    final totalWords = data.fold<int>(0, (sum, line) => sum + line.wordCount);
    final avgWordsPerLine = totalLines > 0 ? totalWords / totalLines : 0.0;
    final fontSizes = data.map((l) => l.fontSize).toSet().toList()..sort();
    final avgFontSize = totalLines > 0
        ? data.fold<double>(0, (sum, line) => sum + line.fontSize) / totalLines
        : 0.0;
    final emptyLines = data.where((l) => l.text.trim().isEmpty).length;

    // Calculate average word length
    final totalChars = data.fold<int>(
      0,
      (sum, line) =>
          sum +
          line.words.fold<int>(0, (wSum, word) => wSum + word.text.length),
    );
    final avgWordLength = totalWords > 0 ? totalChars / totalWords : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resumo', style: theme.textTheme.titleLarge),
            const Divider(),
            _statRow('Total de Páginas:', totalPages.toString()),
            _statRow('Total de Linhas:', totalLines.toString()),
            _statRow('Linhas Vazias:', emptyLines.toString()),
            _statRow('Total de Palavras:', totalWords.toString()),
            _statRow(
              'Média de Palavras/Linha:',
              avgWordsPerLine.toStringAsFixed(2),
            ),
            _statRow(
              'Comprimento Médio de Palavra:',
              avgWordLength.toStringAsFixed(2),
            ),
            _statRow('Tamanho de Fonte Médio:', avgFontSize.toStringAsFixed(2)),
            _statRow(
              'Tamanhos de Fonte:',
              fontSizes.map((f) => f.toStringAsFixed(1)).join(', '),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            SizedBox(height: 200, child: chart),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSizeChart(List<TextLineData> data, ThemeData theme) {
    if (data.isEmpty) {
      return const Center(child: Text('Dados insuficientes'));
    }

    final fontSizeFrequency = <double, int>{};
    for (var line in data) {
      fontSizeFrequency[line.fontSize] =
          (fontSizeFrequency[line.fontSize] ?? 0) + 1;
    }

    final sortedEntries = fontSizeFrequency.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    if (sortedEntries.isEmpty) {
      return const Center(child: Text('Dados insuficientes'));
    }

    // Find max value safely
    int maxValue = 0;
    for (var entry in sortedEntries) {
      if (entry.value > maxValue) {
        maxValue = entry.value;
      }
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue.toDouble() * 1.2,
        barGroups: sortedEntries.asMap().entries.map((mapEntry) {
          final fontSizeEntry = mapEntry.value;
          return BarChartGroupData(
            x: mapEntry.key,
            barRods: [
              BarChartRodData(
                toY: fontSizeEntry.value.toDouble(),
                color: theme.colorScheme.primary,
                width: 20,
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 &&
                    value.toInt() < sortedEntries.length) {
                  return Text(
                    sortedEntries[value.toInt()].key.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: true),
      ),
    );
  }

  Widget _buildWordCountChart(List<TextLineData> data, ThemeData theme) {
    if (data.isEmpty) {
      return const Center(child: Text('Dados insuficientes'));
    }

    final spots = data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.wordCount.toDouble()))
        .toList();

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: theme.colorScheme.secondary,
            barWidth: 2,
            dotData: const FlDotData(show: false),
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          bottomTitles: AxisTitles(
            axisNameWidget: const Text('Número da Linha'),
            sideTitles: SideTitles(showTitles: true, reservedSize: 30),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: true),
        gridData: const FlGridData(show: true),
      ),
    );
  }

  Widget _buildLineHeightChart(List<TextLineData> data, ThemeData theme) {
    if (data.isEmpty) {
      return const Center(child: Text('Dados insuficientes'));
    }

    final spots = data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.bounds.height))
        .toList();

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: theme.colorScheme.tertiary,
            barWidth: 2,
            dotData: const FlDotData(show: false),
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          bottomTitles: AxisTitles(
            axisNameWidget: const Text('Número da Linha'),
            sideTitles: SideTitles(showTitles: true, reservedSize: 30),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: true),
        gridData: const FlGridData(show: true),
      ),
    );
  }

  Widget _buildYPositionChart(List<TextLineData> data, ThemeData theme) {
    if (data.isEmpty) {
      return const Center(child: Text('Dados insuficientes'));
    }

    final spots = data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.bounds.top))
        .toList();

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            color: Colors.orange,
            barWidth: 2,
            dotData: const FlDotData(show: false),
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          bottomTitles: AxisTitles(
            axisNameWidget: const Text('Número da Linha'),
            sideTitles: SideTitles(showTitles: true, reservedSize: 30),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: true),
        gridData: const FlGridData(show: true),
      ),
    );
  }

  Widget _buildLineSpacingChart(List<TextLineData> data, ThemeData theme) {
    if (data.length < 2) {
      return const Center(child: Text('Dados insuficientes'));
    }

    final spacings = <FlSpot>[];
    for (int i = 1; i < data.length; i++) {
      // Calculate gap between end of previous line and start of current line
      final prevBottom = data[i - 1].bounds.top + data[i - 1].bounds.height;
      final currentTop = data[i].bounds.top;
      final gap = currentTop - prevBottom;
      spacings.add(FlSpot(i.toDouble(), gap));
    }

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spacings,
            isCurved: false,
            color: Colors.purple,
            barWidth: 2,
            dotData: const FlDotData(show: false),
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          bottomTitles: AxisTitles(
            axisNameWidget: const Text('Número da Linha'),
            sideTitles: SideTitles(showTitles: true, reservedSize: 30),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: true),
        gridData: const FlGridData(show: true),
      ),
    );
  }

  Widget _buildFontStylePerLineChart(List<TextLineData> data, ThemeData theme) {
    if (data.isEmpty) {
      return const Center(child: Text('Dados insuficientes'));
    }

    // Map font styles to numeric values for visualization
    final styleToValue = {
      'regular': 1.0,
      'bold': 2.0,
      'italic': 3.0,
      'boldItalic': 4.0,
    };

    final spots = data.asMap().entries.map((entry) {
      final styleName = entry.value.fontStyle.toString().split('.').last;
      final value = styleToValue[styleName] ?? 0.0;
      return FlSpot(entry.key.toDouble(), value);
    }).toList();

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            color: Colors.teal,
            barWidth: 2,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                final style = data[index].fontStyle.toString().split('.').last;
                Color dotColor = Colors.grey;
                if (style == 'bold') {
                  dotColor = Colors.red;
                } else if (style == 'italic') {
                  dotColor = Colors.blue;
                } else if (style == 'boldItalic') {
                  dotColor = Colors.purple;
                } else {
                  dotColor = Colors.green;
                }
                return FlDotCirclePainter(
                  radius: 3,
                  color: dotColor,
                  strokeWidth: 1,
                  strokeColor: Colors.white,
                );
              },
            ),
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (value, meta) {
                switch (value.toInt()) {
                  case 1:
                    return const Text('Regular', style: TextStyle(fontSize: 9));
                  case 2:
                    return const Text('Bold', style: TextStyle(fontSize: 9));
                  case 3:
                    return const Text('Italic', style: TextStyle(fontSize: 9));
                  case 4:
                    return const Text(
                      'BoldItalic',
                      style: TextStyle(fontSize: 9),
                    );
                  default:
                    return const Text('');
                }
              },
            ),
          ),
          bottomTitles: AxisTitles(
            axisNameWidget: const Text('Número da Linha'),
            sideTitles: SideTitles(showTitles: true, reservedSize: 30),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        minY: 0.5,
        maxY: 4.5,
        borderData: FlBorderData(show: true),
        gridData: const FlGridData(show: true),
      ),
    );
  }

  Widget _buildFontStyleCard(List<TextLineData> data, ThemeData theme) {
    if (data.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Dados insuficientes',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    final fontStyleFrequency = <String, int>{};
    for (var line in data) {
      final style = line.fontStyle.toString().split('.').last;
      fontStyleFrequency[style] = (fontStyleFrequency[style] ?? 0) + 1;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Distribuição de Estilos de Fonte',
              style: theme.textTheme.titleMedium,
            ),
            const Divider(),
            ...fontStyleFrequency.entries.map((entry) {
              final percentage = (entry.value / data.length * 100)
                  .toStringAsFixed(1);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(child: Text(entry.key)),
                    Text('${entry.value} ($percentage%)'),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedLineList(List<TextLineData> data, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Detalhes das Linhas', style: theme.textTheme.titleMedium),
            const Divider(),
            ...data.take(50).map((line) => _buildLineDetail(line, theme)),
            if (data.length > 50)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  '... e mais ${data.length - 50} linhas',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineDetail(TextLineData line, ThemeData theme) {
    return ExpansionTile(
      title: Text(
        'Linha ${line.lineNumber} (Pág ${line.pageNumber})',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        line.text.length > 50 ? '${line.text.substring(0, 50)}...' : line.text,
        style: const TextStyle(fontSize: 11),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Texto: ${line.text}', style: const TextStyle(fontSize: 11)),
              Text('Tamanho Fonte: ${line.fontSize.toStringAsFixed(2)}'),
              Text('Estilo: ${line.fontStyle.toString().split('.').last}'),
              Text('Palavras: ${line.wordCount}'),
              Text(
                'Bounds: x=${line.bounds.left.toStringAsFixed(1)}, '
                'y=${line.bounds.top.toStringAsFixed(1)}, '
                'w=${line.bounds.width.toStringAsFixed(1)}, '
                'h=${line.bounds.height.toStringAsFixed(1)}',
              ),
              const Divider(),
              Text(
                'Palavras:',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ...line.words.map(
                (word) => Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Text(
                    '• "${word.text}" (size: ${word.fontSize.toStringAsFixed(1)}, '
                    'w: ${word.bounds.width.toStringAsFixed(1)})',
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TextLineData {
  final int pageNumber;
  final int lineNumber;
  final String text;
  final double fontSize;
  final PdfFontStyle fontStyle;
  final Rect bounds;
  final int wordCount;
  final List<WordData> words;

  TextLineData({
    required this.pageNumber,
    required this.lineNumber,
    required this.text,
    required this.fontSize,
    required this.fontStyle,
    required this.bounds,
    required this.wordCount,
    required this.words,
  });
}

class WordData {
  final String text;
  final double fontSize;
  final PdfFontStyle fontStyle;
  final Rect bounds;

  WordData({
    required this.text,
    required this.fontSize,
    required this.fontStyle,
    required this.bounds,
  });
}
