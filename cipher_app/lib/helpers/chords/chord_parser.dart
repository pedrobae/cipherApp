import 'chord_song.dart';


Song parseChordPro(String chordProText) {
  final linesRaw = chordProText.split('\n');
  Map<int, String> linesMap = {};
  Map<int, List<Chord>> chordsMap = {};

  for (int i = 0; i < linesRaw.length; i++) {
    String line = linesRaw[i].trim();

    if (line.isNotEmpty) {
      // Extract chords and lyrics
      final chordPattern = RegExp(r'\[([^\]]+)\]');
      final matches = chordPattern.allMatches(line);

      // Adds the plain lyric to the linesMap
      linesMap[i] = line.replaceAll(chordPattern, '').trim();

      List<Chord> chords = [];
      int lastMatchEnd = 0;
      for (final match in matches) {
        String chordName = match.group(1)!; //Actual Chord 
        String lyricsBefore = line.substring(lastMatchEnd, match.start).trim(); // Lyrics before
        
        chords.add(Chord(chordName, lyricsBefore));
        lastMatchEnd = match.end;
      }

      // Add the list of chords to the map
      if (chords.isNotEmpty) {
        chordsMap[i] = chords;
      }
    }
  }

  return Song(linesMap, chordsMap);
}