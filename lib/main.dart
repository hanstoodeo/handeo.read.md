import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('dark_mode') ?? false;
  runApp(HandeoReadMD(isDark: isDark));
}

class HandeoReadMD extends StatefulWidget {
  final bool isDark;
  const HandeoReadMD({super.key, required this.isDark});

  @override
  State<HandeoReadMD> createState() => _HandeoReadMDState();
}

class _HandeoReadMDState extends State<HandeoReadMD> {
  late bool _isDark;

  @override
  void initState() {
    super.initState();
    _isDark = widget.isDark;
  }

  void _toggleTheme(bool value) async {
    setState(() => _isDark = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hanstoodeo Read MD',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: HomeScreen(isDark: _isDark, onThemeToggle: _toggleTheme),
    );
  }
}
