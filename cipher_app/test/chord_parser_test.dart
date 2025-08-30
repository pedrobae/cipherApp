import 'package:flutter_test/flutter_test.dart';
import 'package:cipher_app/helpers/chords/chord_song.dart';
import 'package:cipher_app/helpers/chords/chord_parser.dart';

void main() {
  group('parseChordPro', () {
    test('parses ChordPro text into Song object', () {
      // Arrange
      const chordProText = '[C]Amazing grace, how [G]sweet the sound\nThat [Am]saved a wretch like [F]me';

      // Act
      final song = parseChordPro(chordProText);

      // Assert
      expect(song.linesMap, {
        0: 'Amazing grace, how sweet the sound',
        1: 'That saved a wretch like me',
      });

      expect(song.chordsMap, {
        0: [
          isA<Chord>().having((c) => c.name, 'name', 'C').having((c) => c.lyricsBefore, 'lyricsBefore', ''),
          isA<Chord>().having((c) => c.name, 'name', 'G').having((c) => c.lyricsBefore, 'lyricsBefore', 'Amazing grace, how'),
        ],
        1: [
          isA<Chord>().having((c) => c.name, 'name', 'Am').having((c) => c.lyricsBefore, 'lyricsBefore', 'That'),
          isA<Chord>().having((c) => c.name, 'name', 'F').having((c) => c.lyricsBefore, 'lyricsBefore', 'saved a wretch like'),
        ],
      });
    });

    test('handles empty ChordPro text', () {
      // Arrange
      const chordProText = '';

      // Act
      final song = parseChordPro(chordProText);

      // Assert
      expect(song.linesMap, isEmpty);
      expect(song.chordsMap, isEmpty);
    });

    test('handles lines without chords', () {
      // Arrange
      const chordProText = 'Amazing grace, how sweet the sound\nThat saved a wretch like me';

      // Act
      final song = parseChordPro(chordProText);

      // Assert
      expect(song.linesMap, {
        0: 'Amazing grace, how sweet the sound',
        1: 'That saved a wretch like me',
      });

      expect(song.chordsMap, isEmpty);
    });
  });
}
