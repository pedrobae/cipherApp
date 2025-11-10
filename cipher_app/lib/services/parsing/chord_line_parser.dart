import 'package:cipher_app/models/domain/cipher/section.dart';
import 'package:cipher_app/models/domain/parsing_cipher.dart';
import 'package:cipher_app/utils/section_constants.dart';
import 'package:flutter/material.dart';

class ChordLineParser {
  Future<void> parseChords(ParsingCipher cipher) async {
    // Identifies chords from text lines and associates them with lyrics,

    // Iterates through each section of the cipher creating Section objects
    List<Section> parsedSections = [];
    List<String> songStructure = [];
    for (var section in cipher.sections) {
      String code = getCodeFromLabel(section['label'] as String) ?? '';

      // Keep track of song structure
      songStructure.add(code);

      // If the section is marked as duplicate, skip creating a new Section object
      if (section['isDuplicate'] == true) continue;

      // Build the Section object
      Section parsedSection = Section(
        versionId: -1 /* ID will be set on database insertion */,
        contentCode: code,
        contentColor: defaultSectionColors[code] ?? Colors.grey,
        contentType: section['label'] as String,
        contentText: _buildContent(section),
      );

      parsedSections.add(parsedSection);
    }

    cipher.parsedSections = parsedSections;
    cipher.songStructure = songStructure;
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
        mergedLine.write(lyricLine[lyricIndex]);
        lyricIndex++;
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

  bool? _isChordLine(Map<String, dynamic>? line) {
    if (line == null) return null;
    // Simple regex to identify chord patterns (e.g., C, G7, Am, F#m)
    RegExp chordRegex = RegExp(
      r'([CDEFGAB][#b]?)(m|maj|min|sus|aug|dim)?([7|maj7|m7|min7|sus2|sus4])?(\/[A-G][#b]?)?',
    );
    List<RegExpMatch> matches = chordRegex.allMatches(line['text']).toList();

    // Heuristic: compare word count and match count
    if (matches.length >= line['wordCount'] / 2) {
      return true;
    }

    // Additional heuristic: low average word length and few words
    if (line['avgWordLength'] < 3.0 &&
        line['wordCount'] > 0 &&
        line['wordCount'] <= 6) {
      return true;
    } else {
      return false;
    }
  }

  String _buildContent(Map<String, dynamic> section) {
    String content = '';
    // Iterate through lines in the section, creating the content
    for (int index = 0; index < section['lines'].length; index++) {
      var line = section['lines'][index];
      var nextLine = (index + 1 < section['lines'].length)
          ? section['lines'][index + 1]
          : null;

      if (_isChordLine(line) == true) {
        if (_isChordLine(nextLine) == false) {
          // This line is a chord line followed by a lyric line
          // Merge chords with the next line, associating chord positions
          String chordProLine = _mergeLines(line['text'], nextLine!['text']);
          content = '$content$chordProLine\n';
        } else {
          // This line is a chord line not followed by a lyric line
          // Format as chord-only line
          content = '$content${_formatChordOnlyLine(line['text'])}\n';
        }
      } else if (_isChordLine(line) == false) {
        // This line is a lyric line
        // Lyric lines are handled by previous line (except if it is the first line)
        if (_isChordLine(nextLine) == false) {
          // This line is a lyric line followed by another lyric line
          // If it's the first line, add it as-is
          if (index == 0) {
            content = '$content${line['text']}\n';
          }
          // Add the next line as-is
          content = '$content${nextLine!['text']}\n';
        }
      }
    }
    return content;
  }
}
