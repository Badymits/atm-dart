import 'dart:convert';
import 'dart:io';

List<Map<String, dynamic>> readUserData() {
  try {
    final file = File('data.json');

    final jsonString = file.readAsStringSync();

    final List<dynamic> jsonData = jsonDecode(jsonString);

    final List<Map<String, dynamic>> userData =
        jsonData.cast<Map<String, dynamic>>();

    return userData;
  } on FileSystemException catch (e) {
    print('Error reading file: ${e.message}');
    return [];
  } on FormatException catch (e) {
    print('Error parsing JSON: ${e.message}');
    return [];
  }
}

Map<String, dynamic>? findUserByPin(
  String pin,
  List<Map<String, dynamic>> userData,
) {
  try {
    return userData.firstWhere((user) => user['pin'].toString() == pin);
  } catch (e) {
    return null;
  }
}

Map<String, dynamic>? findUserByAccountNumber(
  String accountNumber,
  List<Map<String, dynamic>> userData,
) {
  try {
    return userData.firstWhere((user) => user['accountNumber'].toString() == accountNumber);
  } catch (e) {
    return null;
  }
}

bool writeUserData(List<Map<String, dynamic>> userData) {
  try {
    final file = File('data.json');
    final jsonString = jsonEncode(userData);
    file.writeAsStringSync(jsonString);
    return true;
  } catch (e) {
    print('Error writing file: $e');
    return false;
  }
}
