import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:notes_app/screens/note_list.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeProvider = ThemeProvider();
  await themeProvider.initialize();

  // Khởi tạo sqflite_ffi cho nền tảng desktop
  if (Platform.isLinux || Platform.isWindows) {
    // Khởi tạo SQLite trên Linux/Windows
    sqfliteFfiInit();
    // Thay đổi factory mặc định
    databaseFactory = databaseFactoryFfi;
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => themeProvider,
      child: const MyApp(),
    ),
  );
}

class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;

  Future<void> initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool('isDark') ?? false;
  }

  Future<void> toggleTheme() async {
    _isDark = !_isDark;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', _isDark);
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Lấy trạng thái theme hiện tại
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Định nghĩa TextTheme chung cho cả sáng và tối
    final TextTheme textTheme = TextTheme(
      headlineSmall: TextStyle(
        fontFamily: 'Sans',
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Sans',
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Sans',
        fontWeight: FontWeight.normal,
        fontSize: 18,
      ),
      titleSmall: TextStyle(
        fontFamily: 'Sans',
        fontWeight: FontWeight.normal,
        fontSize: 14,
      ),
    );

    // Định nghĩa theme sáng
    final lightTheme = ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: Colors.blue.shade600,
        onPrimary: Colors.white,
        secondary: Colors.blue.shade700,
        surface: Colors.white,
        background: Colors.grey.shade100,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue.shade600,
        elevation: 0,
      ),
      textTheme: textTheme.apply(
        bodyColor: Colors.black,
        displayColor: Colors.black,
      ),
      useMaterial3: true,
    );

    // Định nghĩa theme tối
    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: Colors.blue.shade300,
        onPrimary: Colors.black,
        secondary: Colors.blue.shade400,
        surface: Colors.grey.shade900,
        background: Colors.black,
        onSurface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF202020),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      textTheme: textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      useMaterial3: true,
    );

    return MaterialApp(
      title: 'Flutter Notes',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: const NoteList(),
    );
  }
}
