import 'package:cordis/models/domain/cipher/section.dart';
import 'package:cordis/models/domain/parsing_cipher.dart';
import 'package:cordis/models/dtos/pdf_dto.dart';
import 'package:cordis/utils/section_constants.dart';
import 'package:flutter/material.dart';

class ChordLineParser {
  /// Parses sections from the given [ImportVariant] and creates the parsed objects.
  void parseBySimpleText(ParsingResult result) {
    // Iterates through each section of the cipher creating Section objects
    Map<String, Section> parsedSections = result.parsedSections;
    List<String> songStructure = result.songStructure;
    int incrementalDefaultCode = 0;

    List<Map<String, dynamic>> rawSections = result.rawSections;

    for (var rawSection in rawSections) {
      if (rawSection['suggestedTitle'] == 'Metadata') continue;

      String? code =
          commonSectionLabels[rawSection['officialLabel'].toLowerCase()]?.code;
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
        contentColor:
            commonSectionLabels[rawSection['officialLabel'].toLowerCase()]
                ?.color ??
            Colors.grey,
        contentType: rawSection['suggestedTitle'] as String,
        contentText: _buildContentFromSimpleText(
          rawSection['content'] as String,
        ),
      );

      parsedSections[code] = parsedSection;
    }
  }

  void parseByPdfFormatting(ImportVariant variant, ParsingResult result) {
    // Iterates through each section of the variant creating Section objects
    Map<String, Section> parsedSections = result.parsedSections;
    List<Map<String, dynamic>> rawSections = result.rawSections;
    List<String> songStructure = result.songStructure;
    int incrementalDefaultCode = 0;

    for (var rawSection in rawSections) {
      if (rawSection['suggestedTitle'] == 'Metadata') continue;

      String? code =
          commonSectionLabels[rawSection['officialLabel'].toLowerCase()]?.code;
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
        contentColor:
            commonSectionLabels[rawSection['officialLabel'].toLowerCase()]
                ?.color ??
            Colors.grey,
        contentType: rawSection['suggestedTitle'] as String,
        contentText: _buildContentFromLinesData(
          rawSection['linesData'] as List<LineData>,
        ),
      );

      parsedSections[code] = parsedSection;
    }
  }

  String _buildContentFromLinesData(List<LineData> lines) {
    /// Use bouds from each word to position chords over lyrics in ChordPro format
    String content = '';
    for (int index = 0; index < lines.length - 1; index++) {
      LineData lineData = lines[index];
      String lineText = lineData.text;

      LineData? nextLineData = lines[index + 1];
      String nextLineText = nextLineData.text;

      if (_isChordLine(lineText)) {
        if (!_isChordLine(nextLineText)) {
          // This line is a chord line followed by a lyric line
          // Merge chords with the next line, associating chord positions
          String chordProLine = _mergeByPdfFormatting(lineData, nextLineData);
          content = '$content$chordProLine\n';
        } else if (_isChordLine(nextLineText)) {
          // This line is a chord line followed by another chord line
          // Format as chord-only line
          content = '$content${_formatChordOnlyLine(lineText)}\n';
        }
      } else if (!_isChordLine(lineText)) {
        // This line is a lyric line
        // Lyric lines are handled by previous line (except if it is the first line)
        if (!_isChordLine(nextLineText)) {
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
    // Handle last line if chord line
    LineData lastLineData = lines[lines.length - 1];
    String lastLineText = lastLineData.text;
    if (_isChordLine(lastLineText)) {
      content = '$content${_formatChordOnlyLine(lastLineText)}';
    }

    return content;
  }

  String _buildContentFromSimpleText(String rawContent) {
    List<String> lines = rawContent.split('\n');

    String content = '';
    // Iterate through lines in the section, creating the content
    for (int index = 0; index < lines.length - 1; index++) {
      final String lineText = lines[index];

      final String nextLineText = lines[index + 1];

      if (_isChordLine(lineText)) {
        if (!_isChordLine(nextLineText)) {
          // This line is a chord line followed by a lyric line
          // Merge chords with the next line, associating chord positions
          String chordProLine = _mergeLines(lineText, nextLineText);
          content = '$content$chordProLine\n';
        } else if (_isChordLine(nextLineText)) {
          // This line is a chord line followed by another chord line
          // Format as chord-only line
          content = '$content${_formatChordOnlyLine(lineText)}\n';
        }
      } else if (!_isChordLine(lineText)) {
        // This line is a lyric line
        // Lyric lines are handled by previous line (except if it is the first line)
        if (!_isChordLine(nextLineText)) {
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
    final String lastLineText = lines[lines.length - 1];

    if (_isChordLine(lastLineText)) {
      content = '$content${_formatChordOnlyLine(lastLineText)}';
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

  String _mergeByPdfFormatting(LineData chordLineData, LineData lyricLineData) {
    // Merges chord line and lyric line into a single chord pro formatted line
    // Using glyph bounds to insert chords into lyrics
    List<WordData> chordGlyphs = chordLineData.wordList;

    List<GlyphData> lyricGlyphs = lyricLineData.wordList
        .expand(
          (word) =>
              word.glyphList +
              [
                GlyphData(
                  bounds: Rect.zero,
                  text: ' ',
                  fontSize: 0.0,
                  fontStyle: [],
                  glyphIndex: 0,
                ),
              ],
        )
        .toList();

    String mergedLine = '';

    WordData? chordGlyph;
    GlyphData? lyricGlyph;
    while (chordGlyphs.isNotEmpty || lyricGlyphs.isNotEmpty) {
      try {
        chordGlyph ??= chordGlyphs.removeAt(0);
      } catch (e) {
        //  No more chord glyphs
        //  Append remaining lyric glyphs
        while (lyricGlyphs.isNotEmpty) {
          if (lyricGlyph != null) {
            mergedLine += lyricGlyph.text;
            lyricGlyph = null;
          }
          mergedLine += lyricGlyphs.removeAt(0).text;
        }
        break;
      }

      try {
        lyricGlyph ??= lyricGlyphs.removeAt(0);
      } catch (e) {
        //  No more lyric glyphs
        //  Append remaining chord glyphs
        while (chordGlyphs.isNotEmpty) {
          if (chordGlyph != null) {
            mergedLine += '[${chordGlyph.text}]';
            chordGlyph = null;
          }
          mergedLine += '[${chordGlyphs.removeAt(0).text}]';
        }
        break;
      }

      if (chordGlyph.bounds.left <= lyricGlyph.bounds.left) {
        // Next chord glyph is before the next lyric glyph
        mergedLine += '[';
        mergedLine += chordGlyph.text;
        mergedLine += ']';
        chordGlyph = null;
      } else {
        // Next lyric glyph is before the next chord glyph
        mergedLine += lyricGlyph.text;
        lyricGlyph = null;
      }
    }

    return mergedLine;
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

  bool _isChordLine(String text) {
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

    // Heuristic: at least half of the words should match chord patterns
    if (matches.length < (text.split(RegExp(r'\s+')).length / 2)) {
      return false;
    }

    return true;
  }
}
