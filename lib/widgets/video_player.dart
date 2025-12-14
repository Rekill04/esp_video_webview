import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VideoPlayer extends StatelessWidget {
  const VideoPlayer({
    super.key,
    required bool showWebView,
    required WebViewController? controller,
  })  : _showWebView = showWebView,
        _controller = controller;

  final bool _showWebView;
  final WebViewController? _controller;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: DecoratedBox(
          decoration: const BoxDecoration(color: Colors.black),
          child: _showWebView
              ? (_controller == null)
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : WebViewWidget(controller: _controller)
              : const Center(
                  child: Text(
                    'Нажми “Открыть”, чтобы посмотреть поток.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
        ),
      ),
    );
  }
}
