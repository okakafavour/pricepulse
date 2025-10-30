import 'dart:html' as html;
import 'dart:convert';
import 'package:http/http.dart' as http;

class GoogleAuthWebService {
  final String baseUrl = "http://localhost:8080/api/auth"; // your backend base URL

  GoogleAuthWebService() {
    // Listen for the "google-login" event from google_signin.js
    html.window.addEventListener("google-login", (event) async {
      final customEvent = event as html.CustomEvent;
      final idToken = customEvent.detail;

      print("✅ Got ID Token from Google: $idToken");

      // Send the ID token to your backend
      final response = await http.post(
        Uri.parse("$baseUrl/google/callback"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"idToken": idToken}),
      );

      print("🔁 Backend response: ${response.body}");
    });
  }
}
