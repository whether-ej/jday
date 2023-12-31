import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:jday/page_root.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await dotenv.load(fileName: '.env');
  } catch (e) {}

  final runnableApp = _buildRunnableApp(
    isWeb: kIsWeb,
    webAppWidth: 480.0,
    app: const MyApp(),
  );

  initializeDateFormatting('ko_KR', null).then((_) => runApp(runnableApp));
}

Widget _buildRunnableApp({
  required bool isWeb,
  required double webAppWidth,
  required Widget app,
}) {
  if (!isWeb) {
    return app;
  }

  return Center(
    child: ClipRect(
      child: SizedBox(
        width: webAppWidth,
        child: app,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'j day',
      theme: ThemeData(
        useMaterial3: false,
        fontFamily: 'SUIT',
        colorScheme: const ColorScheme.light().copyWith(
          brightness: Brightness.light,
          background: Colors.white,
          surface: Colors.white,
          primary: const Color(0xFF93CD93),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const PageRoot(),
    );
  }
}
