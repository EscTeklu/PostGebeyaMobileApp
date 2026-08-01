import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nopcommerce_mobile/constants/app_constants.dart';
import 'package:nopcommerce_mobile/constants/global_variables.dart';
import 'package:nopcommerce_mobile/features/authentication/presentation/auth_providers.dart';
enum ProgressIndicatorType { circular, linear }
class PostInfo extends ConsumerStatefulWidget {
  const PostInfo({super.key, this.urlWeb});

  final String? urlWeb;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PostInfoState();
}

class _PostInfoState extends ConsumerState<PostInfo> {

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
    //print(widget.urlWeb);

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
                    final url = mUrl.toString();
                    if (url.contains("/about-us") ||
                        url.contains("/privacy-notice") ||
                        url.contains("/disclaimers") ||
                        url.contains("/shipping-returns") ||
                        url.contains("/faq")) {
                      //showInSnackBar(context, 'EthioPost Info',color: Colors.redAccent);
                    } else  {
                      //Navigator.of(context).pop();
                      Navigator.of(context, rootNavigator: true).maybePop(context);
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

