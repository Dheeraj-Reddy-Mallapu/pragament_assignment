import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:mass_qr/models/scans.dart';
import 'package:mass_qr/models/settings.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mass_qr/firebase_options.dart';
import 'package:mass_qr/pages/login.dart';


Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  ByteData data = await PlatformAssetBundle().load('assets/ca/lets-encrypt-r3.pem');
  SecurityContext.defaultContext.setTrustedCertificatesBytes(data.buffer.asUint8List());

  runApp(MyApp());
}
const MaterialColor kPrimaryColor = const MaterialColor(
  0xFF0E7AC7,
  const <int, Color>{
    50: const Color(0xFF0E7AC7),
    100: const Color(0xFF0E7AC7),
    200: const Color(0xFF0E7AC7),
    300: const Color(0xFF0E7AC7),
    400: const Color(0xFF0E7AC7),
    500: const Color(0xFF0E7AC7),
    600: const Color(0xFF0E7AC7),
    700: const Color(0xFF0E7AC7),
    800: const Color(0xFF0E7AC7),
    900: const Color(0xFF0E7AC7),
  },
);
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ScansModel()),
          ChangeNotifierProvider(create: (context) => SettingsModel()),
        ],
    child: MaterialApp(
        title: 'MassQR',
        theme: ThemeData(
            primarySwatch: kPrimaryColor ,
            primaryColor: kPrimaryColor,
            brightness: Brightness.light),
        darkTheme: ThemeData(
            primarySwatch: kPrimaryColor,
            primaryColor: kPrimaryColor,
            brightness: Brightness.dark),
        themeMode: ThemeMode.system,
        home: LoginPage()
      ),
    );
  }
}
