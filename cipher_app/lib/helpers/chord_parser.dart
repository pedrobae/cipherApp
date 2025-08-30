Song parseChordPro(String chordProText) {
  List<Line> lines = [];
  Map<String, String> metadata = {};

  final linesRaw = chordProText.split('\n');
  for (var line in linesRaw) {
    line = line.trim();
    if (line.startsWith('{') && line.endsWith('}')) {
      // Metadata line
      final content = line.substring(1, line.length - 1);
      final parts = content.split(':');
      if (parts.length >= 2) {
        final key = parts[0].trim().toLowerCase();
        final value = parts.sublist(1).join(':').trim();
        metadata[key] = value;
      }
    } else if (line.isNotEmpty) {
      // Regular line
      final chordPattern = RegExp(r'\[([^\]]+)\]');
      final hasChords = chordPattern.hasMatch(line);
      lines.add(Line(text: line, isChordLine: hasChords));
    }
  }

  return Song(lines: lines, metadata: metadata);
}


class Song {
  List<Line> lines;
  Map<String, String> metadata;

  Song({
    required this.lines,
    required this.metadata,
  });
}

class Line {
  String text;
  bool isChordLine;

  Line({
    required this.text,
    required this.isChordLine,
  });
}