import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nopcommerce_mobile/constants/app_constants.dart';
import 'package:nopcommerce_mobile/constants/global_variables.dart';
import 'package:nopcommerce_mobile/features/app/scaffold_messenger_extansion.dart';
import 'package:nopcommerce_mobile/features/authentication/presentation/auth_providers.dart';
import 'package:nopcommerce_mobile/router/route_utils.dart';
enum ProgressIndicatorType { circular, linear }
class WebInfo extends ConsumerStatefulWidget {
  const WebInfo({super.key, this.urlWeb});

  final String? urlWeb;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _WebInfoState();
}

class _WebInfoState extends ConsumerState<WebInfo> {

  @override
  void dispose() {
    super.dispose();
  }
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
    //String paymentInfoUrl = "${url}paymentinfowebview/paymentinfo";
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
                  onProgressChanged: (controller, progress) {
                    setState(() {
                      this.progress = progress / 100;
                    });
                  },
                  onLoadStop: (controller, mUrl) async {
                    final url = mUrl.toString();
                    if (url.contains("/nexstep/")) {
                      var nextStep = url[url.length - 1];
                      if (nextStep == '0') {
                        context.goNamed(Routes.cart.name);
                      } else {
                        Navigator.of(context, rootNavigator: true).maybePop(context);
                        //widget.onStepContinue();
                      }
                    } else if (url.contains('/status=payment_declined/') ||
                        url.contains('/error/')) {
                      showInSnackBar(context, 'Declined',color: Colors.redAccent);
                    } else if (url.contains('/finish/')) {
                      showInSnackBar(context, 'SUCCESS',color: Colors.green);
                      context.pushNamed(Routes.home.name);
                    }else if (url.contains('/orderdetails/') ||
                        url.contains('/completed/')) {
                      int orderId = -1;

                      try {
                        orderId = int.parse(url.split('/').last);
                      } catch (e) {
                        orderId = -1;
                      }

                      if (orderId > 0) {
                        context.pushNamed(
                          Routes.orderDetails.name,
                          pathParameters: {'id': orderId.toString()},
                        );
                      } else {
                        context.pushNamed(Routes.home.name);
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
class WindowPopup extends StatefulWidget {
  final CreateWindowAction createWindowAction;

  const WindowPopup({Key? key, required this.createWindowAction})
      : super(key: key);

  @override
  State<WindowPopup> createState() => _WindowPopupState();
}

class _WindowPopupState extends State<WindowPopup> {
  String title = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(mainAxisSize: MainAxisSize.max, children: [
              Expanded(
                child:
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close))
            ]),
            Expanded(
              child: InAppWebView(
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                  Factory<OneSequenceGestureRecognizer>(
                        () => EagerGestureRecognizer(),
                  ),
                },
                windowId: widget.createWindowAction.windowId,
                onTitleChanged: (controller, title) {
                  setState(() {
                    this.title = title ?? '';
                  });
                },
                onCloseWindow: (controller) {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/
