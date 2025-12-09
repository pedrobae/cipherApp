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
  final Map<String, List<LineData>> _documentData = {};
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

      // Extract text from all pages
      final textExtractor = PdfTextExtractor(document);
      List<TextGlyph> glyphs = [];
      for (int i = 0; i < document.pages.count; i++) {
        final lines = textExtractor.extractTextLines(
          startPageIndex: i,
          endPageIndex: i,
        );

        for (var line in lines) {
          for (var word in line.wordCollection) {
            glyphs.addAll(word.glyphs);
          }
        }
      }

      // Sort glyphs by their vertical position (top)
      glyphs.sort((a, b) {
        return a.bounds.top.compareTo(b.bounds.top);
      });

      final DocumentData documentData = DocumentData.fromGlyphArray(glyphs);

      if (mounted) {
        setState(() {
          _documents.add(document);
          _documentNames.add(name);
          _documentData[name] = documentData.lines;
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

  Widget _buildAnalysisView(List<LineData> data, ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary stats
        _buildSummaryCard(data, theme),
        const SizedBox(height: 16),

        // Font size distribution chart
        _buildChartCard(
          'Distribuição de Tamanho de Fonte',
          _buildFontSizeDistributionChart(data, theme),
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

        // Font Size chart
        _buildChartCard(
          'Tamanho da Fonte das Linha',
          _buildFontSizeChart(data, theme),
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

        // Detailed line list
        _buildDetailedLineList(data, theme),
      ],
    );
  }

  Widget _buildSummaryCard(List<LineData> data, ThemeData theme) {
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
    final totalWords = data.fold<int>(0, (sum, line) => sum + line.wordCount);
    final avgWordsPerLine = totalLines > 0 ? totalWords / totalLines : 0.0;
    final fontSizes = data.map((l) => l.fontSize).toSet().toList()..sort();
    final avgFontSize = totalLines > 0
        ? data.fold<double>(0, (sum, line) => sum + (line.fontSize)) /
              totalLines
        : 0.0;
    final emptyLines = data.where((l) => l.text.trim().isEmpty).length;

    // Calculate average word length
    final totalChars = data.fold<int>(
      0,
      (sum, line) =>
          sum +
          line.wordList.fold<int>(0, (wSum, word) => wSum + word.text.length),
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

  Widget _buildFontSizeDistributionChart(List<LineData> data, ThemeData theme) {
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

  Widget _buildWordCountChart(List<LineData> data, ThemeData theme) {
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
            isCurved: false,
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

  Widget _buildFontSizeChart(List<LineData> data, ThemeData theme) {
    if (data.isEmpty) {
      return const Center(child: Text('Dados insuficientes'));
    }

    final spots = data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.fontSize.toDouble()))
        .toList();

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
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

  Widget _buildLineHeightChart(List<LineData> data, ThemeData theme) {
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
            isCurved: false,
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

  Widget _buildYPositionChart(List<LineData> data, ThemeData theme) {
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

  Widget _buildLineSpacingChart(List<LineData> data, ThemeData theme) {
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

  Widget _buildFontStylePerLineChart(List<LineData> data, ThemeData theme) {
    if (data.isEmpty) {
      return const Center(child: Text('Dados insuficientes'));
    }

    // Map font styles to numeric values for visualization
    final styleToValue = {
      PdfFontStyle.regular: 1.0,
      PdfFontStyle.bold: 2.0,
      PdfFontStyle.italic: 3.0,
      PdfFontStyle.strikethrough: 4.0,
      PdfFontStyle.underline: 5.0,
    };

    final spots = data.asMap().entries.map((entry) {
      final styleName = entry.value.fontStyle;
      final value = styleToValue[styleName.lastOrNull] ?? 0.5;
      return FlSpot(entry.key.toDouble() + 1, value);
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
                // Use spot.x as the data index (safer than using index parameter)
                final dataIndex = spot.x.toInt() - 1;
                if (dataIndex < 0 || dataIndex >= data.length) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: Colors.grey,
                    strokeWidth: 1,
                    strokeColor: Colors.white,
                  );
                }
                final style = data[dataIndex].fontStyle.lastOrNull;
                Color dotColor = Colors.grey;
                if (style == PdfFontStyle.bold) {
                  dotColor = Colors.red;
                } else if (style == PdfFontStyle.italic) {
                  dotColor = Colors.blue;
                } else if (style == PdfFontStyle.strikethrough) {
                  dotColor = Colors.purple;
                } else if (style == PdfFontStyle.underline) {
                  dotColor = Colors.orange;
                } else if (style == PdfFontStyle.regular) {
                  dotColor = Colors.green;
                } else {
                  dotColor = Colors.grey;
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
                      'Strikethrough',
                      style: TextStyle(fontSize: 9),
                    );
                  case 5:
                    return const Text(
                      'Underline',
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
        maxY: 5,
        borderData: FlBorderData(show: true),
        gridData: const FlGridData(show: true),
      ),
    );
  }

  Widget _buildDetailedLineList(List<LineData> data, ThemeData theme) {
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

  Widget _buildLineDetail(LineData line, ThemeData theme) {
    return ExpansionTile(
      title: Text(
        'Linha ${line.lineIndex + 1}',
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
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 16,
                  dataRowMinHeight: 28,
                  dataRowMaxHeight: 36,
                  headingRowHeight: 32,
                  columns: const [
                    DataColumn(
                      label: Text(
                        'Texto',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Tamanho',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      numeric: true,
                    ),
                    DataColumn(
                      label: Text(
                        'Largura',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      numeric: true,
                    ),
                    DataColumn(
                      label: Text(
                        'Altura',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      numeric: true,
                    ),
                    DataColumn(
                      label: Text(
                        'X',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      numeric: true,
                    ),
                    DataColumn(
                      label: Text(
                        'Y',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      numeric: true,
                    ),
                    DataColumn(
                      label: Text(
                        'Estilo',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  rows: line.wordList
                      .map(
                        (word) => DataRow(
                          cells: [
                            DataCell(
                              Text(
                                word.text,
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                            DataCell(
                              Text(
                                word.fontSize.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                            DataCell(
                              Text(
                                word.bounds.width.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                            DataCell(
                              Text(
                                word.bounds.height.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                            DataCell(
                              Text(
                                word.bounds.left.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                            DataCell(
                              Text(
                                word.bounds.top.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                            DataCell(
                              Text(
                                word.fontStyle.toString().split('.').last,
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DocumentData {
  final List<LineData> lines;

  DocumentData({required this.lines});

  factory DocumentData.fromGlyphArray(List<TextGlyph> glyphs) {
    int currentLineIndex = -1;
    double lastY = -1.0;
    double tolerance = 2.0; // Tolerance for y-position differences
    Map<int, List<TextGlyph>> lineGlyphMap = {};
    for (var glyph in glyphs) {
      // Check if glyph starts a new line
      if ((lastY - glyph.bounds.top).abs() > tolerance || lastY == -1.0) {
        currentLineIndex++;
        lastY = glyph.bounds.top;
      }

      // Add glyph to the current line, on the correct position (x-axis)
      if (lineGlyphMap[currentLineIndex] == null) {
        lineGlyphMap[currentLineIndex] = [glyph];
      } else {
        final lineGlyph = lineGlyphMap[currentLineIndex]!;
        bool inserted = false;
        for (int i = 0; i < lineGlyph.length; i++) {
          if (glyph.bounds.left < lineGlyph[i].bounds.left) {
            inserted = true;
            lineGlyph.insert(i, glyph);
            break;
          }
        }
        if (!inserted) {
          lineGlyph.add(glyph);
        }
      }
    }

    List<LineData> lines = [];
    for (var entry in lineGlyphMap.entries) {
      lines.add(LineData.fromGlyphArray(entry.key, entry.value));
    }

    return DocumentData(lines: lines);
  }
}

class LineData {
  final String text;
  final double? _fontSize;
  final Rect bounds;
  final List<PdfFontStyle>? _fontStyle;
  final int lineIndex;
  final List<WordData> wordList;

  LineData({
    required this.text,
    double? fontSize,
    required this.bounds,
    List<PdfFontStyle>? fontStyle,
    required this.lineIndex,
    required this.wordList,
  }) : _fontStyle = fontStyle,
       _fontSize = fontSize;

  double get fontSize => _fontSize ?? _getFontSizeFromWords();
  List<PdfFontStyle> get fontStyle => _fontStyle ?? _getFontStyleFromWords();
  int get wordCount => wordList.length;

  factory LineData.fromGlyphArray(int lineIndex, List<TextGlyph> glyphs) {
    Map<int, List<TextGlyph>> wordGlyphMap = {};
    int currentWordIndex = -1;
    double lastRightBound = 0.0;
    double spaceThreshold = 2.0; // Threshold to detect spaces between words
    for (var glyph in glyphs) {
      // Check if glyph is a space
      if (glyph.text.trim().isEmpty) {
        lastRightBound = glyph.bounds.right;
        continue; // Trim spaces
      }
      if (glyph.bounds.left - lastRightBound > spaceThreshold ||
          currentWordIndex == -1) {
        currentWordIndex++;
      }
      // Add glyph to the current word
      if (wordGlyphMap[currentWordIndex] == null) {
        wordGlyphMap[currentWordIndex] = [glyph];
      } else {
        wordGlyphMap[currentWordIndex]!.add(glyph);
      }
      lastRightBound = glyph.bounds.right;
    }

    // Create WordData list
    List<WordData> words = [];
    for (var entry in wordGlyphMap.entries) {
      words.add(WordData.fromGlyphArray(entry.key, entry.value));
    }

    return LineData(
      lineIndex: lineIndex,
      text: glyphs.map((g) => g.text).join(),
      bounds: _calculateBounds(glyphs),
      wordList: words,
    );
  }

  double _getFontSizeFromWords() {
    if (wordList.isEmpty) return 0.0;
    double totalSize = 0.0;
    for (var word in wordList) {
      totalSize += word.fontSize;
    }
    return totalSize / wordList.length;
  }

  List<PdfFontStyle> _getFontStyleFromWords() {
    final styles = <PdfFontStyle>{};
    for (var word in wordList) {
      styles.addAll(word.fontStyle);
    }
    return styles.toList();
  }
}

class WordData {
  final String text;
  final double? _fontSize;
  final Rect bounds;
  final List<PdfFontStyle>? _fontStyle;
  final int wordIndex;
  final List<GlyphData> glyphList;

  WordData({
    required this.text,
    double? fontSize,
    required this.bounds,
    List<PdfFontStyle>? fontStyle,
    required this.glyphList,
    required this.wordIndex,
  }) : _fontStyle = fontStyle,
       _fontSize = fontSize;

  double get fontSize => _fontSize ?? _getFontSizeFromGlyphs();

  List<PdfFontStyle> get fontStyle => _fontStyle ?? _getFontStyleFromGlyphs();

  factory WordData.fromGlyphArray(int wordIndex, List<TextGlyph> glyphs) {
    return WordData(
      wordIndex: wordIndex,
      text: glyphs.map((g) => g.text).join(),
      bounds: _calculateBounds(glyphs),
      glyphList: glyphs
          .asMap()
          .entries
          .map((e) => GlyphData.fromGlyph(e.key, e.value))
          .toList(),
    );
  }

  double _getFontSizeFromGlyphs() {
    if (glyphList.isEmpty) return 0.0;
    double totalSize = 0.0;
    for (var glyph in glyphList) {
      totalSize += glyph.fontSize;
    }
    return totalSize / glyphList.length;
  }

  List<PdfFontStyle> _getFontStyleFromGlyphs() {
    final styles = <PdfFontStyle>{};
    for (var glyph in glyphList) {
      styles.addAll(glyph.fontStyle);
    }
    return styles.toList();
  }
}

class GlyphData {
  final String text;
  final double fontSize;
  final Rect bounds;
  final List<PdfFontStyle> fontStyle;
  final int glyphIndex;

  GlyphData({
    required this.text,
    required this.fontSize,
    required this.bounds,
    required this.fontStyle,
    required this.glyphIndex,
  });

  factory GlyphData.fromGlyph(int glyphIndex, TextGlyph glyph) {
    return GlyphData(
      glyphIndex: glyphIndex,
      text: glyph.text,
      fontSize: glyph.fontSize,
      bounds: glyph.bounds,
      fontStyle: glyph.fontStyle,
    );
  }
}

Rect _calculateBounds(List<TextGlyph> glyphs) {
  if (glyphs.isEmpty) {
    return Rect.zero;
  }
  double left = glyphs.first.bounds.left;
  double top = glyphs.first.bounds.top;
  double right = glyphs.first.bounds.right;
  double bottom = glyphs.first.bounds.bottom;

  for (var glyph in glyphs) {
    if (glyph.bounds.left < left) {
      left = glyph.bounds.left;
    }
    if (glyph.bounds.top < top) {
      top = glyph.bounds.top;
    }
    if (glyph.bounds.right > right) {
      right = glyph.bounds.right;
    }
    if (glyph.bounds.bottom > bottom) {
      bottom = glyph.bounds.bottom;
    }
  }

  return Rect.fromLTRB(left, top, right, bottom);
}
