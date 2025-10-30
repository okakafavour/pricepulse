import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/price_provider.dart';
import 'screens/login_screen.dart';
// import 'services/google_auth_service.dart';

void main() {
  runApp(const PricePulseApp());
}

class PricePulseApp extends StatelessWidget {
  const PricePulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, PriceProvider>(
          create: (_) => PriceProvider(AuthProvider()),
          update: (_, auth, __) => PriceProvider(auth),
        ),
      ],
      child: MaterialApp(
        title: 'PricePulse',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF1565C0),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1565C0),
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
