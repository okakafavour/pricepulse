import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId: "208804397507-0bu3dp1neogk2a5nl75s85cvtthvcc81.apps.googleusercontent.com",
);

Future<Map<String, dynamic>?> signInWithGoogle() async {
  try {
    // Attempt silent sign-in first
    final GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();

    // If user not signed in, show the popup
    final GoogleSignInAccount? user = googleUser ?? await _googleSignIn.signIn();

    if (user == null) {
      print("User cancelled login");
      return null;
    }

    final GoogleSignInAuthentication auth = await user.authentication;
    final idToken = auth.idToken;

    if (idToken == null) {
      print("❌ No ID token received");
      return null;
    }

    // Send ID token to backend
    final res = await http.post(
      Uri.parse("http://localhost:8080/auth/google/web"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"idToken": idToken}),
    );

    if (res.statusCode != 200) {
      print("Backend returned error: ${res.body}");
      return null;
    }

    // Return decoded backend response (token, email, etc.)
    return jsonDecode(res.body);
  } catch (e) {
    print("Google sign in failed: $e");
    return null;
  }
}
