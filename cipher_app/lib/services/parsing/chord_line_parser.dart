import 'package:cipher_app/models/domain/cipher/section.dart';
import 'package:cipher_app/models/domain/parsing_cipher.dart';
import 'package:cipher_app/models/dtos/pdf_dto.dart';
import 'package:cipher_app/utils/section_constants.dart';
import 'package:flutter/material.dart';

class ChordLineParser {
  /// Parses sections from the given [ImportVariant] and creates the parsed objects.
  void parseBySimpleText(ImportVariant variant, ParsingStrategy strategy) {
    // Iterates through each section of the cipher creating Section objects
    Map<String, Section> parsedSections =
        variant.parsingResults[strategy]!.parsedSections;
    List<String> songStructure =
        variant.parsingResults[strategy]!.songStructure;
    int incrementalDefaultCode = 0;

    List<Map<String, dynamic>> rawSections =
        variant.parsingResults[strategy]!.rawSections;

    for (var rawSection in rawSections) {
      if (rawSection['suggestedTitle'] == 'Metadata') continue;

      String? code = getCodeFromLabel(rawSection['suggestedTitle']);
      if (code == null) {
        // Assign a default code if none is found
        code = incrementalDefaultCode.toString();
        incrementalDefaultCode++;
      }

      // If the section is marked as duplicate, skip creating a new Section object
      if (rawSection['duplicatedSectionIndex'] != null) {
        // Add the code of the original section to the song structure
        songStructure.add(
          rawSections[rawSection['duplicatedSectionIndex']]['code'],
        );
        // Skip to the next section
        continue;
      }

      // Keep track of song structure
      songStructure.add(code);
      rawSection['code'] = code;

      // Build the Section object
      Section parsedSection = Section(
        versionId: -1 /* ID will be set on database insertion */,
        contentCode: code,
        contentColor: defaultSectionColors[code] ?? Colors.grey,
        contentType: rawSection['suggestedTitle'] as String,
        contentText: _buildContentFromSimpleText(
          variant.lines,
          variant.variation,
        ),
      );

      parsedSections[code] = parsedSection;
    }
  }

  void parseByPdfFormatting(ImportVariant variant, ParsingStrategy strategy) {
    // Iterates through each section of the variant creating Section objects
    Map<String, Section> parsedSections =
        variant.parsingResults[strategy]!.parsedSections;
    List<String> songStructure =
        variant.parsingResults[strategy]!.songStructure;
    int incrementalDefaultCode = 0;

    List<Map<String, dynamic>> rawSections =
        variant.parsingResults[strategy]!.rawSections;
    for (var rawSection in rawSections) {
      if (rawSection['suggestedTitle'] == 'Metadata') continue;

      String? code = getCodeFromLabel(rawSection['officialLabel']);
      if (code == null) {
        // Assign a default code if none is found
        code = incrementalDefaultCode.toString();
        incrementalDefaultCode++;
      }
      // Append number from suggested title if present to ensure uniqueness
      final matches = RegExp(r'[0-9]').allMatches(rawSection['suggestedTitle']);
      if (matches.isNotEmpty) {
        code = '$code${matches.first.group(0)}';
      }

      // If the section is marked as duplicate, skip creating a new Section object
      if (rawSection['duplicatedSectionIndex'] != null) {
        // Add the code of the original section to the song structure
        songStructure.add(
          rawSections[rawSection['duplicatedSectionIndex']]['code'],
        );
        // Skip to the next section
        continue;
      }

      // Keep track of song structure
      songStructure.add(code);
      rawSection['code'] = code;

      // Build the Section object
      Section parsedSection = Section(
        versionId: -1 /* ID will be set on database insertion */,
        contentCode: code,
        contentColor: defaultSectionColors[code] ?? Colors.grey,
        contentType: rawSection['suggestedTitle'] as String,
        contentText: _buildContentFromSimpleText(
          rawSection['linesData'],
          variant.variation,
        ), // Using SimpleText builder for now TODO - check chord formatting
      );

      parsedSections[code] = parsedSection;
    }
  }

  String _buildContentFromSimpleText(
    List<dynamic> lines,
    ImportVariation variation,
  ) {
    String content = '';
    // Iterate through lines in the section, creating the content
    for (int index = 0; index < lines.length - 1; index++) {
      String lineText;
      int wordCount;
      double avgWordLength;

      String nextLineText;
      int nextWordCount;
      double nextAvgWordLength;

      switch (variation) {
        case ImportVariation.imageOcr:
        case ImportVariation.textDirect:
          lineText = lines[index]['text'];
          wordCount = lines[index]['wordCount'];
          avgWordLength = lines[index]['avgWordLength'];

          nextLineText = lines[index + 1]['text'];
          nextWordCount = lines[index + 1]['wordCount'];
          nextAvgWordLength = lines[index + 1]['avgWordLength'];
          break;
        case ImportVariation.pdfNoColumns:
        case ImportVariation.pdfWithColumns:
          final lineData = lines[index] as LineData;
          lineText = lineData.text;
          wordCount = lineData.wordCount;
          avgWordLength = _calculateAvgWordLength(lineData);

          final nextLineData = lines[index + 1] as LineData;
          nextLineText = nextLineData.text;
          nextWordCount = nextLineData.wordCount;
          nextAvgWordLength = _calculateAvgWordLength(nextLineData);
          break;
      }

      if (_isChordLine(lineText, wordCount, avgWordLength)) {
        if (!_isChordLine(nextLineText, nextWordCount, nextAvgWordLength)) {
          // This line is a chord line followed by a lyric line
          // Merge chords with the next line, associating chord positions
          String chordProLine = _mergeLines(lineText, nextLineText);
          content = '$content$chordProLine\n';
        } else if (_isChordLine(
          nextLineText,
          nextWordCount,
          nextAvgWordLength,
        )) {
          // This line is a chord line followed by another chord line
          // Format as chord-only line
          content = '$content${_formatChordOnlyLine(lineText)}\n';
        }
      } else if (!_isChordLine(lineText, wordCount, avgWordLength)) {
        // This line is a lyric line
        // Lyric lines are handled by previous line (except if it is the first line)
        if (!_isChordLine(nextLineText, nextWordCount, nextAvgWordLength)) {
          // This line is a lyric line followed by another lyric line
          // If it's the first line, add it as-is
          if (index == 0) {
            content = '$content$lineText\n';
          }
          // Add the next line as-is
          content = '$content$nextLineText\n';
        }
      }
    }
    // Check if the last line is a chord line and add it
    String lastLineText;
    int lastWordCount;
    double lastAvgWordLength;

    switch (variation) {
      case ImportVariation.imageOcr:
      case ImportVariation.textDirect:
        lastLineText = lines[lines.length - 1]['text'];
        lastWordCount = lines[lines.length - 1]['wordCount'];
        lastAvgWordLength = lines[lines.length - 1]['avgWordLength'];
        break;
      case ImportVariation.pdfNoColumns:
      case ImportVariation.pdfWithColumns:
        final lastLineData = lines[lines.length - 1] as LineData;
        lastLineText = lastLineData.text;
        lastWordCount = lastLineData.wordCount;
        lastAvgWordLength = _calculateAvgWordLength(lastLineData);
        break;
    }

    if (_isChordLine(lastLineText, lastWordCount, lastAvgWordLength)) {
      content = '$content$lastLineText';
    }

    return content;
  }

  String _mergeLines(String chordLine, String lyricLine) {
    // Merges chord line and lyric line into a single chord pro formatted line
    StringBuffer mergedLine = StringBuffer();
    int lyricIndex = 0;

    for (int i = 0; i < chordLine.length; i++) {
      if (chordLine[i] != ' ') {
        // Found a chord character, insert chord brackets
        mergedLine.write('[');
        while (i < chordLine.length && chordLine[i] != ' ') {
          mergedLine.write(chordLine[i]);
          i++;
        }
        mergedLine.write(']');
      }
      // Add corresponding lyric character if available
      if (lyricIndex < lyricLine.length) {
        while (lyricIndex <= i && lyricIndex < lyricLine.length) {
          mergedLine.write(lyricLine[lyricIndex]);
          lyricIndex++;
        }
      }
    }
    // Append any remaining lyrics
    if (lyricIndex < lyricLine.length) {
      mergedLine.write(lyricLine.substring(lyricIndex));
    }

    return mergedLine.toString();
  }

  String _formatChordOnlyLine(String chordLine) {
    // Formats a line that contains only chords into ChordPro format
    StringBuffer formattedLine = StringBuffer();
    int i = 0;

    while (i < chordLine.length) {
      if (chordLine[i] != ' ') {
        // Found a chord character, insert chord brackets
        formattedLine.write('[');
        while (i < chordLine.length && chordLine[i] != ' ') {
          formattedLine.write(chordLine[i]);
          i++;
        }
        formattedLine.write(']');
      } else {
        // Just a space, move to the next character
        i++;
      }
    }

    return formattedLine.toString();
  }

  bool _isChordLine(String text, int wordCount, double avgWordLength) {
    // Simple regex to identify chord patterns (e.g., C, G7, Am, F#m)
    RegExp chordRegex = RegExp(
      r'([CDEFGAB][#b]?)(m|maj|min|sus|aug|dim)?([7|maj7|m7|min7|sus2|sus4])?(\/[A-G][#b]?)?',
    );
    List<RegExpMatch> matches = chordRegex.allMatches(text).toList();

    // Check if the matches are part of a word
    List<RegExpMatch> matchesCopy = List.from(matches);
    for (var match in matchesCopy) {
      int start = match.start;
      int end = match.end;

      // Check character before the match
      if (start != 0) {
        String charBefore = text[start - 1];
        // Check if the character before the match is alphanumeric
        if (RegExp(r'[a-zA-Z0-9]').hasMatch(charBefore)) {
          // Match is part of a word
          matches.remove(match);
          continue;
        }
      }

      // Check character after the match
      if (end != text.length) {
        String charAfter = text[end];
        // Check if the character after the match is alphanumeric
        if (RegExp(r'[a-zA-Z0-9]').hasMatch(charAfter)) {
          // Match is part of a word
          matches.remove(match);
          continue;
        }
      }
    }

    // Heuristic: compare word count and match count
    if (matches.length >= (wordCount / 2)) {
      return true;
    }

    // Additional heuristic: low average word length and few words
    if (avgWordLength < 2.0 && wordCount > 0 && wordCount <= 6) {
      return true;
    } else {
      return false;
    }
  }

  double _calculateAvgWordLength(LineData lineData) {
    double totalLength = 0;
    for (var word in lineData.wordList) {
      totalLength += word.text.length;
    }
    return lineData.wordList.isEmpty
        ? 0.0
        : totalLength / lineData.wordList.length;
  }
}
