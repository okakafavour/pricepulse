import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

GoogleSignIn getGoogleSignIn() {
  if (kIsWeb) {
    // Web client ID for Flutter Web
    return GoogleSignIn(
      clientId: '208804397507-gk0vubpjuj28b0mntiqkbagh5bje1e5d.apps.googleusercontent.com',
      scopes: ['email', 'profile'],
    );
  } else if (Platform.isAndroid || Platform.isIOS) {
    // Mobile apps use default config
    return GoogleSignIn(scopes: ['email', 'profile']);
  } else {
    // fallback
    return GoogleSignIn(scopes: ['email', 'profile']);
  }
}
