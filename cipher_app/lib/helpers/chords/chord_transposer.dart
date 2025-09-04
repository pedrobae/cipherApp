class ChordTransposer {
  static const List<String> sharps = [
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
  static const List<String> flats = [
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
  static const List<String> flatKeys = [
    'F',
    'Bb',
    'Eb',
    'Ab',
    'Db',
    'Gb',
    'Cb',
  ];

  // Pre-sorted list of all chord roots (longest first for proper parsing)
  static const List<String> allChordRoots = [
    'C#',
    'Db',
    'D#',
    'Eb',
    'F#',
    'Gb',
    'G#',
    'Ab',
    'A#',
    'Bb', // 2-char roots first
    'C', 'D', 'E', 'F', 'G', 'A', 'B', // 1-char roots second
  ];

  final String originalKey;
  final int transposeValue;

  ChordTransposer({required this.originalKey, required this.transposeValue});

  // Calculate the transposed key first, then determine if we should use flats
  String get transposedKey {
    String tempKey = _transposeRoot(originalKey, transposeValue, true);
    String key = '';
    tempKey == 'Gb' ? key = 'F#' : key = tempKey;
    return key;
  }

  bool get useFlats => flatKeys.contains(transposedKey);

  String transpose(String chord) {
    // Parse chord root first
    String? root;
    String remainingSuffix = '';

    // Find the longest matching root (handles both C# and C correctly)
    for (final r in allChordRoots) {
      if (chord.startsWith(r)) {
        root = r;
        remainingSuffix = chord.substring(r.length);
        break;
      }
    }
    if (root == null) return chord;

    // Parse slash chord if present
    String? bass;
    String chordSuffix = remainingSuffix;

    if (remainingSuffix.contains('/')) {
      final slashIndex = remainingSuffix.indexOf('/');
      chordSuffix = remainingSuffix.substring(0, slashIndex);
      final bassPart = remainingSuffix.substring(slashIndex + 1);

      // Find bass note (should match exactly or be at the start)
      for (final r in allChordRoots) {
        if (bassPart == r || bassPart.startsWith(r)) {
          bass = r;
          break;
        }
      }
    }

    // Transpose root and bass
    String transposedRoot = _transposeRoot(root, transposeValue, useFlats);
    String result = transposedRoot + chordSuffix;

    if (bass != null) {
      String transposedBass = _transposeRoot(bass, transposeValue, useFlats);
      result += '/$transposedBass';
    }

    return result;
  }

  // Helper to transpose a single root
  String _transposeRoot(String root, int value, bool useFlats) {
    final chromatic = useFlats ? flats : sharps;
    int rootIndex = chromatic.indexOf(root);
    if (rootIndex == -1) {
      // Try alternate chromatic
      rootIndex = (useFlats ? sharps : flats).indexOf(root);
    }
    if (rootIndex == -1) return root;
    int newIndex = (rootIndex + value) % chromatic.length;
    if (newIndex < 0) newIndex += chromatic.length;
    return chromatic[newIndex];
  }
}
