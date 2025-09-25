bool isTransition(String sectionCode) {
  final transitionCodes = ['I', 'B', 'B1', 'B2', 'PC', 'S', 'O', 'F'];
  return (transitionCodes.contains(sectionCode));
}

bool isAnnotation(String sectionCode) {
  return (sectionCode == 'N');
}
