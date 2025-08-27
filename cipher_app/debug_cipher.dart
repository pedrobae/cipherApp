import 'package:cipher_app/helpers/database_helper.dart';
import 'package:cipher_app/repositories/cipher_repository.dart';

void main() async {
  // Initialize database
  final dbHelper = DatabaseHelper();
  await dbHelper.resetDatabase(); // This will recreate and seed the database
  
  final repository = CipherRepository();
  
  // Get all ciphers
  final ciphers = await repository.getAllCiphers();
  
  print('Total ciphers loaded: ${ciphers.length}');
  
  for (final cipher in ciphers) {
    print('\n--- Cipher: ${cipher.title} ---');
    print('ID: ${cipher.id}');
    print('Maps count: ${cipher.maps.length}');
    
    for (final map in cipher.maps) {
      print('  Map ID: ${map.id}');
      print('  Version Name: ${map.versionName}');
      print('  Song Structure: ${map.songStructure}');
      print('  Content count: ${map.content.length}');
      print('  Content keys: ${map.content.keys.join(', ')}');
    }
  }
  
  // Specifically check "How Great Thou Art"
  final howGreat = ciphers.where((c) => c.title == 'How Great Thou Art').firstOrNull;
  if (howGreat != null) {
    print('\n=== HOW GREAT THOU ART DETAILS ===');
    print('ID: ${howGreat.id}');
    print('Title: ${howGreat.title}');
    print('Maps: ${howGreat.maps.length}');
    if (howGreat.maps.isNotEmpty) {
      final map = howGreat.maps.first;
      print('First map version name: ${map.versionName}');
      print('First map song structure: ${map.songStructure}');
      print('First map content: ${map.content}');
    } else {
      print('NO MAPS FOUND!');
    }
  } else {
    print('\nHOW GREAT THOU ART NOT FOUND!');
  }
  
  await dbHelper.close();
}
