import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'features/auth/presentation/screens/reset_password_page.dart';
import 'main.dart';


class DeepLinkHandler {

  final AppLinks _appLinks = AppLinks();
  bool _isHandling = false;

  Future<void> init() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleUri(initialUri);
      }
      _appLinks.uriLinkStream.listen((uri) {
        _handleUri(uri);
      });
    } catch (e) {
      debugPrint('[DeepLinkHandler] Error: $e');
    }
  }

  void _handleUri(Uri uri) {
    if (_isHandling) return;
    _isHandling = true;

    final path = uri.host; // reset-password
    final token = uri.queryParameters['token']; // abc123

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigator = navigatorKey.currentState;
      if (navigator == null) {
        debugPrint('[DeepLinkHandler] navigatorKey is null');
        _isHandling = false;
        return;
      }

      switch (path) {
        case 'reset-password':
          if (token != null && token.isNotEmpty) {
            navigator.push(
              MaterialPageRoute(
                builder: (_) => ResetPasswordPage(token: token),
              ),
            );
          } else {
            debugPrint('[DeepLinkHandler] Missing token');
          }
          break;

        default:
          debugPrint('[DeepLinkHandler] Unknown path: $path');
      }

      _isHandling = false;
    });
  }
}