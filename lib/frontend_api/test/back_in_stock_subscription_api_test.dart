import 'package:test/test.dart';
import 'package:frontend_api/frontend_api.dart';


/// tests for BackInStockSubscriptionApi
void main() {
  final instance = FrontendApi().getBackInStockSubscriptionApi();

  group(BackInStockSubscriptionApi, () {
    // My account / Back in stock subscriptions
    //
    //Future<CustomerBackInStockSubscriptionsModelDto> apiFrontendBackInStockSubscriptionCustomerSubscriptionsGet({ int pageNumber }) async
    test('test apiFrontendBackInStockSubscriptionCustomerSubscriptionsGet', () async {
      // TODO
    });

    //Future<CustomerBackInStockSubscriptionsModelDto> apiFrontendBackInStockSubscriptionCustomerSubscriptionsPost({ BuiltMap<String, String> requestBody }) async
    test('test apiFrontendBackInStockSubscriptionCustomerSubscriptionsPost', () async {
      // TODO
    });

    // Product details page > back in stock subscribe
    //
    //Future<BackInStockSubscribeModelDto> apiFrontendBackInStockSubscriptionSubscribePopupProductIdGet(int productId) async
    test('test apiFrontendBackInStockSubscriptionSubscribePopupProductIdGet', () async {
      // TODO
    });

    // Back in stock subscribe
    //
    //Future<String> apiFrontendBackInStockSubscriptionSubscribeProductIdPost(int productId) async
    test('test apiFrontendBackInStockSubscriptionSubscribeProductIdPost', () async {
      // TODO
    });

  });
}
