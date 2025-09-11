import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewYouTube extends StatefulWidget {
  final String embedUrl;
  const WebViewYouTube({ super.key, required this.embedUrl });

  @override
  State<WebViewYouTube> createState() => _WebViewYouTubeState();
}

class _WebViewYouTubeState extends State<WebViewYouTube> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => debugPrint('Loading…'),
          onPageFinished: (_) => debugPrint('Loaded'),
          onWebResourceError: (err) => debugPrint('Error: ${err.description}'),
        ),
      )
      ..loadRequest(Uri.parse(widget.embedUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: const Text('Product Video')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
