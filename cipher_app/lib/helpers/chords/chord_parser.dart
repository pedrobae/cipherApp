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
      String plainLyrics = line.replaceAll(chordPattern, '').trim();
      linesMap[i] = plainLyrics;

      List<Chord> chords = [];
      int plainIndex = 0; // Tracks the position in plainLyrics

      for (final match in matches) {
        String chordName = match.group(1)!; // Actual Chord

        // Extract the lyrics before the chord in plain text
        String lyricsUpToMatch = line.substring(0, match.start).replaceAll(chordPattern, '');
        plainIndex = lyricsUpToMatch.length;

        String lyricsBefore = plainLyrics.substring(0, plainIndex);

        // Add the chord to the list
        chords.add(Chord(chordName, lyricsBefore));
      }

      // Add the list of chords to the map
      if (chords.isNotEmpty) {
        chordsMap[i] = chords;
      }
    }
  }

  return Song(linesMap, chordsMap);
}