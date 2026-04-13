import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:musicapp/pages/splash_screen.dart';
import 'package:provider/provider.dart';
import 'model/playlistprovider.dart';
import 'theme/themeprovider.dart'; 
import 'pages/homepage.dart';

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();

  
  await Firebase.initializeApp();

  runApp(
    // 3. MULTIPROVIDER: The "Power Strip" for your app
    MultiProvider(
      providers: [
        // Music & ML Logic
        ChangeNotifierProvider(create: (context) => PlaylistProvider()),

        // Dark Mode / Light Mode Logic
        ChangeNotifierProvider(create: (context) => Themeprovider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 4. LISTEN TO THEME CHANGES
    // This part ensures that when you toggle the switch in Settings, the app actually changes color
    return Consumer<Themeprovider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Euphony',

          // Use the theme data from your provider
          theme: themeProvider.themeData,

          home: const SplashScreen(),
        );
      },
    );
  }
}
