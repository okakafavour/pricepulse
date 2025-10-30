import 'dart:async';
import 'dart:js_interop';

@JS('google.accounts.id')
external GoogleAccountsId get googleAccountsId;

@JS()
@staticInterop
class GoogleAccountsId {}

extension GoogleAccountsIdExt on GoogleAccountsId {
  external void initialize(JSObject options);
  external void prompt();
}

@JS()
@staticInterop
class CredentialResponse {}

extension CredentialResponseExt on CredentialResponse {
  external String get credential;
}

/// ✅ Listens for messages from index.html (the Google token)
Future<String?> getGoogleIdToken() async {
  final completer = Completer<String?>();

  // Define the handler
  void messageHandler(JSAny? event) {
    if (event == null) return;
    final dynamic e = event.dartify(); // Convert JS object to Dart map

    if (e is Map && e['type'] == 'google_id_token') {
      completer.complete(e['token']);
      _removeListener('message', messageHandler.toJS);
    }
  }

  // Attach listener for 'message' events
  _addListener('message', messageHandler.toJS);

  // Timeout safety (avoid waiting forever)
  return completer.future.timeout(
    const Duration(seconds: 90),
    onTimeout: () {
      _removeListener('message', messageHandler.toJS);
      return null;
    },
  );
}

/// ✅ Correct JS interop signatures
@JS('window.addEventListener')
external void _addListener(String type, JSFunction callback);

@JS('window.removeEventListener')
external void _removeListener(String type, JSFunction callback);
