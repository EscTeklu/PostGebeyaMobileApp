import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nopcommerce_mobile/constants/global_variables.dart';
import 'package:nopcommerce_mobile/features/app/scaffold_messenger_extansion.dart';
import 'package:nopcommerce_mobile/router/route_utils.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:nopcommerce_mobile/customize/services/transaction_history_service.dart';
import 'package:nopcommerce_mobile/customize/services/payment_service.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String url;
  final String orderId;
  final PaymentService paymentService;

  const PaymentWebViewScreen({super.key, required this.url, required this.orderId, required this.paymentService});

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
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
            if (request.url.contains('/finish.html?')) {
              debugPrint('Navigated to finish.html');
              final status = uri.queryParameters['status'];

              if (status != null) {
                //_handleRedirect(status, orderId);
                /*ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Payment Status : $status'))
                );*/
                showInSnackBar(context,'Payment Status : $status');
                if (status == 'payment_declined') {
                  debugPrint('Payment was declined!');
                  // Verify with backend
                  try {
                    setState(() => loading = true);
                    final verify = await widget.paymentService.verifyPayment(widget.orderId);
                    final status = verify['status'] ?? 'Unknown';
                    await TransactionHistoryService().saveTransaction({
                      'orderId': widget.orderId,
                      'status': status,
                      'timestamp': DateTime.now().toIso8601String(),
                      'amount': verify['amount'] ?? ''
                    });
                    setState(() => loading = false);
                  } catch (e) {
                    await TransactionHistoryService().saveTransaction({
                      'orderId': widget.orderId,
                      'status': 'verification_failed',
                      'timestamp': DateTime.now().toIso8601String(),
                      'amount': ''
                    });
                    setState(() => loading = false);
                  }
                  if (mounted) {
                    Navigator.pop(context, false);
                  }
                  return NavigationDecision.prevent;

                } else if (status == 'payment_successful') {
                  debugPrint('Payment was successful!');
                  // Verify with backend
                  try {
                    setState(() => loading = true);
                    final verify = await widget.paymentService.verifyPayment(widget.orderId);
                    final status = verify['status'] ?? 'Unknown';

                    await TransactionHistoryService().saveTransaction({
                      'orderId': widget.orderId,
                      'status': status,
                      'timestamp': DateTime.now().toIso8601String(),
                      'amount': verify['amount'] ?? ''
                    });
                    setState(() => loading = false);
                  } catch (e) {
                    await TransactionHistoryService().saveTransaction({
                      'orderId': widget.orderId,
                      'status': 'verification_failed',
                      'timestamp': DateTime.now().toIso8601String(),
                      'amount': ''
                    });
                    setState(() => loading = false);
                  }
                  if (mounted) {
                    Navigator.pop(context, true);
                  }
                  return NavigationDecision.prevent;
                }
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
            await _controller.runJavaScript("document.body.style.zoom = '70%';");
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
