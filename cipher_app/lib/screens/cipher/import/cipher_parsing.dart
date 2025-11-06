import 'package:cipher_app/providers/import_provider.dart';
import 'package:cipher_app/providers/parsing_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CipherParsing extends StatefulWidget {
  final ImportType source;

  const CipherParsing({super.key, required this.source});

  @override
  State<CipherParsing> createState() => _CipherParsingState();
}

class _CipherParsingState extends State<CipherParsing> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cipher Parser')),
      body: Consumer2<ImportProvider, ParsingProvider>(
        builder: (context, importProvider, parserProvider, child) {
          return Center(child: Text('Parsing from source: ${widget.source}'));
        },
      ),
    );
  }
}
