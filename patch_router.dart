import 'dart:io';

void main() {
  final file = File('lib/routes/app_router.dart');
  var content = file.readAsStringSync();
  
  // Replace the first PopScope for Customer App
  content = content.replaceFirst(RegExp(r'return PopScope\([\s\S]*?child: Scaffold\('), 'return Scaffold(');
  
  // Replace the second PopScope for Retailer App
  content = content.replaceFirst(RegExp(r'return PopScope\([\s\S]*?child: Scaffold\('), 'return Scaffold(');
  
  file.writeAsStringSync(content);
  print('Removed PopScopes');
}
