import 'package:flutter_test/flutter_test.dart';
import 'package:cipher_app/helpers/chords/chord_transposer.dart';

void main() {
  group('ChordTransposer', () {
    group('Basic chord transposition', () {
      test('transpose C major up 2 semitones', () {
        final transposer = ChordTransposer(originalKey: 'C', transposeValue: 2);
        expect(transposer.transpose('C'), equals('D'));
      });

      test('transpose C major up 5 semitones (to F - should use flats)', () {
        final transposer = ChordTransposer(originalKey: 'C', transposeValue: 5);
        expect(transposer.transpose('C'), equals('F'));
        expect(transposer.transpose('G'), equals('C'));
      });

      test('transpose C major down 2 semitones', () {
        final transposer = ChordTransposer(
          originalKey: 'C',
          transposeValue: -2,
        );
        expect(transposer.transpose('C'), equals('Bb'));
        expect(transposer.transpose('F'), equals('Eb'));
      });

      test('transpose around the circle', () {
        final transposer = ChordTransposer(
          originalKey: 'C',
          transposeValue: 12,
        );
        expect(transposer.transpose('C'), equals('C'));
        expect(transposer.transpose('F#'), equals('F#'));
      });
    });

    group('Sharp and flat preferences', () {
      test('transpose to sharp keys (G, D, A, E, B, F#, C#)', () {
        final transposer = ChordTransposer(
          originalKey: 'C',
          transposeValue: 7,
        ); // C to G
        expect(transposer.transpose('C'), equals('G'));
        expect(
          transposer.transpose('F'),
          equals('C'),
        ); // Should use sharps for G major
      });

      test('transpose to flat keys (F, Bb, Eb, Ab, Db, Gb)', () {
        final transposer = ChordTransposer(
          originalKey: 'C',
          transposeValue: 5,
        ); // C to F
        expect(transposer.transpose('C'), equals('F'));
        expect(
          transposer.transpose('E'),
          equals('A'),
        ); // Should use flats for F major
      });

      test('transpose C# to flat key should convert to Db', () {
        final transposer = ChordTransposer(
          originalKey: 'C',
          transposeValue: 1,
        ); // C to Db (C#)
        expect(transposer.transpose('C#'), equals('D'));
      });
    });

    group('Complex chords', () {
      test('transpose major 7 chords', () {
        final transposer = ChordTransposer(originalKey: 'C', transposeValue: 2);
        expect(transposer.transpose('Cmaj7'), equals('Dmaj7'));
        expect(transposer.transpose('Fmaj7'), equals('Gmaj7'));
      });

      test('transpose minor chords', () {
        final transposer = ChordTransposer(originalKey: 'C', transposeValue: 3);
        expect(transposer.transpose('Am'), equals('Cm'));
        expect(transposer.transpose('Dm'), equals('Fm'));
      });

      test('transpose dominant 7 chords', () {
        final transposer = ChordTransposer(originalKey: 'C', transposeValue: 7);
        expect(transposer.transpose('G7'), equals('D7'));
        expect(transposer.transpose('C7'), equals('G7'));
      });

      test('transpose suspended chords', () {
        final transposer = ChordTransposer(originalKey: 'C', transposeValue: 4);
        expect(transposer.transpose('Csus4'), equals('Esus4'));
        expect(transposer.transpose('Fsus2'), equals('Asus2'));
      });

      test('transpose extended chords', () {
        final transposer = ChordTransposer(originalKey: 'C', transposeValue: 2);
        expect(transposer.transpose('Cmaj9'), equals('Dmaj9'));
        expect(transposer.transpose('F13'), equals('G13'));
      });
    });

    group('Slash chords', () {
      test('transpose basic slash chords', () {
        final transposer = ChordTransposer(originalKey: 'C', transposeValue: 2);
        expect(transposer.transpose('C/E'), equals('D/F#'));
        expect(transposer.transpose('F/A'), equals('G/B'));
      });

      test('transpose complex slash chords', () {
        final transposer = ChordTransposer(originalKey: 'C', transposeValue: 3);
        expect(transposer.transpose('Cmaj7/E'), equals('Ebmaj7/G'));
        expect(transposer.transpose('Am7/C'), equals('Cm7/Eb'));
      });

      test('transpose slash chords with flat keys', () {
        final transposer = ChordTransposer(
          originalKey: 'C',
          transposeValue: 5,
        ); // To F major
        expect(transposer.transpose('C/E'), equals('F/A'));
        expect(transposer.transpose('G/B'), equals('C/E'));
      });

      test('transpose slash chords with sharp bass notes', () {
        final transposer = ChordTransposer(originalKey: 'C', transposeValue: 1);
        expect(transposer.transpose('C/F#'), equals('Db/G'));
      });
    });

    group('Edge cases', () {
      test('transpose unrecognized chords returns original', () {
        final transposer = ChordTransposer(originalKey: 'C', transposeValue: 2);
        expect(transposer.transpose('X'), equals('X'));
        expect(transposer.transpose('123'), equals('123'));
        expect(transposer.transpose(''), equals(''));
      });

      test('transpose chords with accidentals', () {
        final transposer = ChordTransposer(originalKey: 'C', transposeValue: 1);
        expect(transposer.transpose('C#'), equals('D'));
        expect(transposer.transpose('Db'), equals('D'));
        expect(transposer.transpose('F#'), equals('G'));
        expect(transposer.transpose('Bb'), equals('B'));
      });

      test('transpose negative values wrap correctly', () {
        final transposer = ChordTransposer(
          originalKey: 'C',
          transposeValue: -1,
        );
        expect(transposer.transpose('C'), equals('B'));
        expect(transposer.transpose('F'), equals('E'));
      });

      test('large transpose values wrap correctly', () {
        final transposer = ChordTransposer(
          originalKey: 'C',
          transposeValue: 25,
        ); // 25 = 12 + 1
        expect(transposer.transpose('C'), equals('Db'));
      });
    });

    group('ChordPro format compatibility', () {
      test('transpose chords with brackets (ChordPro format)', () {
        final transposer = ChordTransposer(originalKey: 'C', transposeValue: 2);
        // Note: The transposer expects just the chord name, not the brackets
        expect(transposer.transpose('C'), equals('D'));
        expect(transposer.transpose('Am'), equals('Bm'));
      });

      test('transpose various chord qualities common in ChordPro', () {
        final transposer = ChordTransposer(originalKey: 'C', transposeValue: 4);
        expect(transposer.transpose('C'), equals('E'));
        expect(transposer.transpose('Cm'), equals('Em'));
        expect(transposer.transpose('C7'), equals('E7'));
        expect(transposer.transpose('Cmaj7'), equals('Emaj7'));
        expect(transposer.transpose('Cm7'), equals('Em7'));
        expect(transposer.transpose('Cdim'), equals('Edim'));
        expect(transposer.transpose('Caug'), equals('Eaug'));
        expect(transposer.transpose('C6'), equals('E6'));
        expect(transposer.transpose('C9'), equals('E9'));
      });
    });

    group('Key calculation', () {
      test('transposed key calculation', () {
        final transposer1 = ChordTransposer(
          originalKey: 'C',
          transposeValue: 5,
        );
        expect(transposer1.transposedKey, equals('F'));
        expect(transposer1.useFlats, isTrue);

        final transposer2 = ChordTransposer(
          originalKey: 'C',
          transposeValue: 7,
        );
        expect(transposer2.transposedKey, equals('G'));
        expect(transposer2.useFlats, isFalse);

        final transposer3 = ChordTransposer(
          originalKey: 'F',
          transposeValue: 2,
        );
        expect(transposer3.transposedKey, equals('G'));
        expect(transposer3.useFlats, isFalse);
      });
    });
  });
}
