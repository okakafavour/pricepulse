// lib/providers/auth_provider.dart
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html; // web-only helpers (window.localStorage, onMessage)
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://localhost:8080'; // adjust if needed

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _email;

  String? get token => _token;
  String? get email => _email;
  bool get isAuthenticated => _token != null;

  /// Email/password login -> returns true on success
  Future<bool> login(String email, String password) async {
    try {
      final url = Uri.parse('$baseUrl/login');
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _token = data['token'];
        _email = data['email'] ?? email;

        // Save to browser localStorage (web) and session fallback for mobile
        if (kIsWeb) {
          html.window.localStorage['token'] = _token!;
          html.window.localStorage['email'] = _email!;
        }

        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      // log if needed
      return false;
    }
  }

  /// Register -> returns true on success
  Future<bool> register(String email, String password) async {
    try {
      final url = Uri.parse('$baseUrl/register');
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        // Optionally read token response if backend returns token on register.
        try {
          final data = jsonDecode(res.body);
          if (data['token'] != null) {
            _token = data['token'];
            _email = data['email'] ?? email;
            if (kIsWeb) {
              html.window.localStorage['token'] = _token!;
              html.window.localStorage['email'] = _email!;
            }
            notifyListeners();
          }
        } catch (_) {}
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// This method waits for the index.html -> window.postMessage({type: 'google_login_success'})
  /// After receiving that event it reads token/email from localStorage, sets provider state and returns true.
  Future<bool> loginWithGoogle({Duration timeout = const Duration(seconds: 30)}) async {
    if (!kIsWeb) {
      // You would implement mobile GoogleSignIn flow here.
      throw Exception('Google login on non-web not implemented in this provider.');
    }

    final completer = Completer<bool>();
    void listener(html.Event event) {
      try {
        // event is a MessageEvent
        final messageEvent = event as html.MessageEvent;
        final data = messageEvent.data;

        // We expect either a JS object or JSON string; normalize:
        dynamic payload;
        if (data is String) {
          try {
            payload = jsonDecode(data);
          } catch (_) {
            payload = null;
          }
        } else {
          payload = data;
        }

        if (payload is Map && payload['type'] == 'google_login_success') {
          // index.html should have already saved token/email to localStorage after backend verification
          final token = html.window.localStorage['token'];
          final email = html.window.localStorage['email'];
          if (token != null && email != null) {
            _token = token;
            _email = email;
            notifyListeners();
            completer.complete(true);
          } else {
            completer.complete(false);
          }
        }
      } catch (e) {
        // ignore parse errors
      }
    }

    // Attach listener
    html.window.addEventListener('message', listener);

    // Wait for the message or timeout
    return completer.future.timeout(timeout, onTimeout: () {
      // remove listener on timeout and return false
      html.window.removeEventListener('message', listener);
      return false;
    }).whenComplete(() {
      // Always remove listener once done
      html.window.removeEventListener('message', listener);
    });
  }

  /// Attempt to auto-login (reads localStorage on web)
  Future<void> tryAutoLogin() async {
    if (kIsWeb) {
      final token = html.window.localStorage['token'];
      final email = html.window.localStorage['email'];
      if (token != null && email != null) {
        _token = token;
        _email = email;
        notifyListeners();
      }
    }
    // For mobile you may load from secure storage here.
  }

  Future<void> logout() async {
    _token = null;
    _email = null;
    if (kIsWeb) {
      html.window.localStorage.remove('token');
      html.window.localStorage.remove('email');
    }
    notifyListeners();
  }
}
