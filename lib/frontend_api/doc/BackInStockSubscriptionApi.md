# frontend_api.api.BackInStockSubscriptionApi

## Load the API package
```dart
import 'package:frontend_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiFrontendBackInStockSubscriptionCustomerSubscriptionsGet**](BackInStockSubscriptionApi.md#apifrontendbackinstocksubscriptioncustomersubscriptionsget) | **GET** /api-frontend/BackInStockSubscription/CustomerSubscriptions | My account / Back in stock subscriptions
[**apiFrontendBackInStockSubscriptionCustomerSubscriptionsPost**](BackInStockSubscriptionApi.md#apifrontendbackinstocksubscriptioncustomersubscriptionspost) | **POST** /api-frontend/BackInStockSubscription/CustomerSubscriptions | 
[**apiFrontendBackInStockSubscriptionSubscribePopupProductIdGet**](BackInStockSubscriptionApi.md#apifrontendbackinstocksubscriptionsubscribepopupproductidget) | **GET** /api-frontend/BackInStockSubscription/SubscribePopup/{productId} | Product details page &gt; back in stock subscribe
[**apiFrontendBackInStockSubscriptionSubscribeProductIdPost**](BackInStockSubscriptionApi.md#apifrontendbackinstocksubscriptionsubscribeproductidpost) | **POST** /api-frontend/BackInStockSubscription/Subscribe/{productId} | Back in stock subscribe


# **apiFrontendBackInStockSubscriptionCustomerSubscriptionsGet**
> CustomerBackInStockSubscriptionsModelDto apiFrontendBackInStockSubscriptionCustomerSubscriptionsGet(pageNumber)

My account / Back in stock subscriptions

### Example
```dart
import 'package:frontend_api/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = FrontendApi().getBackInStockSubscriptionApi();
final int pageNumber = 56; // int | Page number

try {
    final response = api.apiFrontendBackInStockSubscriptionCustomerSubscriptionsGet(pageNumber);
    print(response);
} catch on DioException (e) {
    print('Exception when calling BackInStockSubscriptionApi->apiFrontendBackInStockSubscriptionCustomerSubscriptionsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **pageNumber** | **int**| Page number | [optional] 

### Return type

[**CustomerBackInStockSubscriptionsModelDto**](CustomerBackInStockSubscriptionsModelDto.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiFrontendBackInStockSubscriptionCustomerSubscriptionsPost**
> CustomerBackInStockSubscriptionsModelDto apiFrontendBackInStockSubscriptionCustomerSubscriptionsPost(requestBody)



### Example
```dart
import 'package:frontend_api/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = FrontendApi().getBackInStockSubscriptionApi();
final BuiltMap<String, String> requestBody = ; // BuiltMap<String, String> | 

try {
    final response = api.apiFrontendBackInStockSubscriptionCustomerSubscriptionsPost(requestBody);
    print(response);
} catch on DioException (e) {
    print('Exception when calling BackInStockSubscriptionApi->apiFrontendBackInStockSubscriptionCustomerSubscriptionsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **requestBody** | [**BuiltMap&lt;String, String&gt;**](String.md)|  | [optional] 

### Return type

[**CustomerBackInStockSubscriptionsModelDto**](CustomerBackInStockSubscriptionsModelDto.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: application/json-patch+json, application/json, text/json, application/*+json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiFrontendBackInStockSubscriptionSubscribePopupProductIdGet**
> BackInStockSubscribeModelDto apiFrontendBackInStockSubscriptionSubscribePopupProductIdGet(productId)

Product details page > back in stock subscribe

### Example
```dart
import 'package:frontend_api/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = FrontendApi().getBackInStockSubscriptionApi();
final int productId = 56; // int | The product identifier

try {
    final response = api.apiFrontendBackInStockSubscriptionSubscribePopupProductIdGet(productId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling BackInStockSubscriptionApi->apiFrontendBackInStockSubscriptionSubscribePopupProductIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **productId** | **int**| The product identifier | 

### Return type

[**BackInStockSubscribeModelDto**](BackInStockSubscribeModelDto.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiFrontendBackInStockSubscriptionSubscribeProductIdPost**
> String apiFrontendBackInStockSubscriptionSubscribeProductIdPost(productId)

Back in stock subscribe

### Example
```dart
import 'package:frontend_api/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = FrontendApi().getBackInStockSubscriptionApi();
final int productId = 56; // int | Product id

try {
    final response = api.apiFrontendBackInStockSubscriptionSubscribeProductIdPost(productId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling BackInStockSubscriptionApi->apiFrontendBackInStockSubscriptionSubscribeProductIdPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **productId** | **int**| Product id | 

### Return type

**String**

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

