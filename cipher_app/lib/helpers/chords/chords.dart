class ChordHelper {
  List<String> notesFlat = [
    'C',
    'Db',
    'D',
    'Eb',
    'E',
    'F',
    'Gb',
    'G',
    'Ab',
    'A',
    'Bb',
    'B',
  ];

  List<String> notesSharp = [
    'C',
    'C#',
    'D',
    'D#',
    'E',
    'F',
    'F#',
    'G',
    'G#',
    'A',
    'A#',
    'B',
  ];

  /// Generate chords for the current key
  List<String> getChordsForKey(String key) {
    final Map<String, List<String>> keyChords = {
      'C': ['C', 'Dm', 'Em', 'F', 'G', 'Am', 'Bdim'],
      'D': ['D', 'Em', 'F#m', 'G', 'A', 'Bm', 'C#dim'],
      'E': ['E', 'F#m', 'G#m', 'A', 'B', 'C#m', 'D#dim'],
      'F': ['F', 'Gm', 'Am', 'Bb', 'C', 'Dm', 'Edim'],
      'G': ['G', 'Am', 'Bm', 'C', 'D', 'Em', 'F#dim'],
      'A': ['A', 'Bm', 'C#m', 'D', 'E', 'F#m', 'G#dim'],
      'B': ['B', 'C#m', 'D#m', 'E', 'F#', 'G#m', 'A#dim'],
      // flat keys
      'Bb': ['Bb', 'Cm', 'Dm', 'Eb', 'F', 'Gm', 'Adim'],
      'Eb': ['Eb', 'Fm', 'Gm', 'Ab', 'Bb', 'Cm', 'Ddim'],
      'Ab': ['Ab', 'Bbm', 'Cm', 'Db', 'Eb', 'Fm', 'Gdim'],
      'Db': ['Db', 'Ebm', 'Fm', 'Gb', 'Ab', 'Bbm', 'Cdim'],
      'Gb': ['Gb', 'Abm', 'Bbm', 'Cb', 'Db', 'Ebm', 'Fdim'],
    };

    // Return chords for key, or default C major if not found
    return keyChords[key] ?? keyChords['C']!;
  }

  List<String> getVariationsForChord(String chord, int index) {
    switch (index) {
      case 0:
        return [
          '$chord/${getShifted(chord, 4) ?? 'error'}',
          '$chord/${getShifted(chord, 7) ?? 'error'}',
          '${chord}maj7',
          '${chord}9',
        ];
      case 1:
      case 2:
      case 5:
        return ['${chord}7', minorToMajor(chord), '${minorToMajor(chord)}7'];
      case 3:
        return [
          '$chord/${getShifted(chord, 4) ?? 'error'}',
          '$chord/${getShifted(chord, 7) ?? 'error'}',
          '${chord}maj7',
          '$chord/${getShifted(chord, 2) ?? 'error'}',
          '${chord}9',
          '${chord}m',
        ];
      case 4:
        return [
          '${chord}7',
          '$chord/${getShifted(chord, 4) ?? 'error'}',
          '$chord/${getShifted(chord, 7) ?? 'error'}',
          '${chord}9',
          '${chord}m',
        ];
      case 6:
        return [
          '${dimToMajor(chord)}ø',
          '${dimToMajor(chord)}m',
          dimToMajor(chord),
          '${dimToMajor(chord)}m/${getShifted(dimToMajor(chord), 3)}',
        ];
      default:
        return [];
    }
  }

  String? getShifted(String chord, int semitoneShift) {
    List<String> notes = notesFlat;
    if (chord.contains('#')) {
      notes = notesSharp;
    }

    final index = notes.indexOf(chord);

    if (index != -1) {
      final newIndex = (index + semitoneShift) % notes.length;
      return notes[newIndex];
    }
    return null;
  }

  String minorToMajor(String chord) {
    if (chord.endsWith('m')) {
      return chord.substring(0, chord.length - 1);
    }
    return chord;
  }

  String dimToMajor(String chord) {
    if (chord.endsWith('dim')) {
      return chord.substring(0, chord.length - 3);
    }
    return chord;
  }
}
