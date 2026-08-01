import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nopcommerce_mobile/constants/global_variables.dart';
import 'package:nopcommerce_mobile/router/route_utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentTelebirrScreen extends StatefulWidget {
  final String url;
  final String orderId;

  const PaymentTelebirrScreen({super.key, required this.url, required this.orderId});

  @override
  State<PaymentTelebirrScreen> createState() => _PaymentTelebirrScreenState();
}

class _PaymentTelebirrScreenState extends State<PaymentTelebirrScreen> {
  late final WebViewController _controller;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(false)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) async {
            final uri = Uri.parse(request.url);
            // Check if the path ends with 'finish.html'
            if (request.url.contains('/orderdetails/') ||
                request.url.contains('/completed/')) {
              int orderId = -1;

              try {
                orderId = int.parse(request.url.split('/').last);
              } catch (e) {
                orderId = -1;
              }

              if (orderId > 0) {
                print("================== Current Order to be Paid ==================: $orderId");
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Pay for Order : $orderId'))
                );
                context.pushNamed(
                  Routes.orderDetails.name,
                  pathParameters: {'id': orderId.toString()},
                );
              } else {
                context.pushNamed(Routes.home.name);
              }
            }
            // Detect deep link return
            /*if (request.url.startsWith("myapp://payment-success")) {

            }*/
            return NavigationDecision.navigate;
          },
          onPageStarted: (_) => setState(() => loading = true),
          onPageFinished: (String url) async {
            setState(() => loading = false);
            /*final uri = Uri.parse(url);
            if (uri.path.endsWith('finish.html')) {
              debugPrint('Page finished loading: ${uri.path}');
              final status = uri.queryParameters['status'];
              final orderId = uri.queryParameters['orderId'];

              if (status != null) {
                //_handleRedirect(status, orderId);
                *//*ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Payment FINISHED : '+ status))
                );*//*
              }
            }*/
            // apply fixed 120% zoom via JS
            await _controller.runJavaScript("document.body.style.zoom = '80%';");
          },

        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalVariables.backgroundColor,
      appBar: AppBar(
        backgroundColor: GlobalVariables.accentColor,
        title: const Text(''),
        leading: IconButton(
          icon: const Icon(
            Icons.cancel,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (loading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
