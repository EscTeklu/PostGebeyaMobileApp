import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nopcommerce_mobile/constants/app_constants.dart';
import 'package:nopcommerce_mobile/constants/global_variables.dart';
import 'package:nopcommerce_mobile/customize/services/payment_service.dart';
import 'package:nopcommerce_mobile/features/app/scaffold_messenger_extansion.dart';
import 'package:nopcommerce_mobile/features/authentication/presentation/auth_providers.dart';
enum ProgressIndicatorType { circular, linear }

class CybersourcePayment extends ConsumerStatefulWidget {
  const CybersourcePayment({super.key, this.urlWeb, required this.orderId, required this.paymentService});

  final String? urlWeb;
  //
  final String orderId;
  final PaymentService paymentService;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CybersourcePaymentState();
}

class _CybersourcePaymentState extends ConsumerState<CybersourcePayment> {

  @override
  void dispose() {
    super.dispose();
  }
  bool loading = true;
  double progress = 0;
  ProgressIndicatorType type = ProgressIndicatorType.linear;
  Map<String, String> getRequestHeader() {
    final authRepository = ref.watch(authRepositoryProvider);
    String? authToken = authRepository.currentCustomer?.token;

    var map = {
      'Content-Type': 'application/json',
      'User-Agent': 'nopcommerce.flutter/v1',
      'Authorization': 'Bearer $authToken',
    };

    return map;
  }

  @override
  Widget build(BuildContext context) {
    InAppWebViewSettings settings = InAppWebViewSettings(
      useShouldOverrideUrlLoading: true,
      mediaPlaybackRequiresUserGesture: false,
      javaScriptCanOpenWindowsAutomatically: true,
      userAgent: "nopCommerce-mobile-app",
      allowsInlineMediaPlayback: true,
      sharedCookiesEnabled: true,
    );

    var url = AppConstants.storeUrl;

    if (url.substring(url.length - 1) != '/') {
      url += '/';
    }
    String payUrl = widget.urlWeb.toString();
    print(widget.urlWeb);

    return Scaffold(
        backgroundColor: GlobalVariables.backgroundColor,
        appBar: AppBar(
          backgroundColor: GlobalVariables.accentColor,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Column(children: <Widget>[
          Expanded(
              child: Stack(children: [
                InAppWebView(
                  initialUrlRequest: URLRequest(
                    url: WebUri(payUrl),
                    headers: getRequestHeader(),
                  ),
                  initialSettings: settings,
                  shouldOverrideUrlLoading: (controller, action) async {
                    return NavigationActionPolicy.ALLOW;
                  },
                  onWebViewCreated: (controller) async {
                    await controller.setSettings(settings: settings);
                  },
                  onReceivedServerTrustAuthRequest: (controller, challenge) async {

                    // Decide whether to proceed or cancel
                    return ServerTrustAuthResponse(
                      action: ServerTrustAuthResponseAction.PROCEED, // or PROCEED for dev
                    );
                  },
                  onProgressChanged: (controller, progress) {
                    setState(() {
                      this.progress = progress / 100;
                    });
                  },
                  onLoadStop: (controller, mUrl) async {
                    final uri = mUrl.toString();// Uri.parse(request.url);
                    // Check if the path ends with 'finish.html'
                    if (uri.contains('/finish.html?')) {
                      debugPrint('Navigated to finish.html');
                      final status = mUrl?.queryParameters['status'];

                      if (status != null) {
                        showInSnackBar(context,'Payment Status : $status');
                        if (status == 'payment_declined') {
                          debugPrint('Payment was declined!');
                          // Verify with backend
                          /*try {
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
                          }*/
                          //return NavigationDecision.prevent;

                        } else if (status == 'payment_deposited') {
                          debugPrint('Payment was successful!');
                          // Verify with backend
                          /*try {
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
                          }*/
                          if (mounted) {
                            Navigator.pop(context, true);
                          }
                          //return NavigationDecision.prevent;
                        }else if (url.contains('/orderdetails/') ||
                            url.contains('/completed/')) {
                          /*int orderId = -1;

                          try {
                            orderId = int.parse(url.split('/').last);
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
                          }*/
                        }
                      }
                    }

                  },
                ),
                progress < 1.0 ? getProgressIndicator(type) : Container(),
              ])),
        ])

    );
  }
  Widget getProgressIndicator(ProgressIndicatorType type) {
    switch (type) {
      case ProgressIndicatorType.circular:
        return Center(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Colors.white.withAlpha(70),
            ),
            child: const CircularProgressIndicator(),
          ),
        );
      case ProgressIndicatorType.linear:
      default:
        return LinearProgressIndicator(
          value: progress,
        );
    }
  }
}


/*
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
ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Payment Status : $status'))
                );

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

                } else if (status == 'payment_deposited') {
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
                    //Navigator.pop(context, true);
                  }
                  //return NavigationDecision.prevent;
                }else if (request.url.contains('/orderdetails/') ||
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
              }
            }
            // Detect deep link return
if (request.url.startsWith("myapp://payment-success")) {

            }

            return NavigationDecision.navigate;
          },
          onPageStarted: (_) => setState(() => loading = true),
          onPageFinished: (String url) async {
            setState(() => loading = false);
final uri = Uri.parse(url);
            if (uri.path.endsWith('finish.html')) {
              debugPrint('Page finished loading: ${uri.path}');
              final status = uri.queryParameters['status'];
              final orderId = uri.queryParameters['orderId'];

              if (status != null) {
                //_handleRedirect(status, orderId);

ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Payment FINISHED : '+ status))
                );
              }
            }

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
*/
