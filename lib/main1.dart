/*import 'package:flutter/material.dart';
import 'package:musicapp/model/playlistprovider.dart';
import 'package:musicapp/pages/homepage.dart';
import 'package:musicapp/pages/splash_screen.dart';
import 'package:musicapp/theme/lightmode.dart';
import 'package:musicapp/theme/darmode.dart';
import 'package:musicapp/theme/themeprovider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Themeprovider()),
        ChangeNotifierProvider(create: (context) => Playlistprovider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      theme: Provider.of<Themeprovider>(context).themeData,
    );
  }
}*/
