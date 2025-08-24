import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nopcommerce_mobile/features/app/home/noon_layout/models/product.dart';
//import 'package:http/http.dart' as http;

class HomeServices {
  var dio = Dio();
  Future<List<Product>> fetchCategoryProducts(
      {required BuildContext context, required String category}) async {
    List<Product> productList = [];
    var uri = '';
    try {
      var headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': 'userProvider.user.token',
      };
      var response = await dio.request(
        '$uri/api/products?category=$category',
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );
      if (context.mounted) {
        /* httpErrorHandle(
            response: res,
            context: context,
            onSuccess: () {
              for (int i = 0; i < jsonDecode(res.body).length; i++) {
                productList.add(
                  Product.fromJson(
                    jsonEncode(
                      jsonDecode(res.body)[i],
                    ),
                  ),
                );
              }
            }); */
      }
    } catch (e) {
      if (context.mounted) {
        // showSnackBar(context, e.toString());
      }
    }

    return productList;
  }

  Future<Product> fetchDealOfTheDay({required BuildContext context}) async {
    //final userProvider = Provider.of<UserProvider>(context, listen: false);
    var uri = '';
    Product product = Product(
        name: '',
        description: '',
        quantity: 0,
        images: [],
        category: '',
        price: 0);

    try {
      var headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': 'userProvider.user.token',
      };
      var response = await dio.request(
        '$uri/api/deal-of-the-day',
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );
      if (context.mounted) {
        /* httpErrorHandle(
            response: res,
            context: context,
            onSuccess: () {
              product = Product.fromJson(res.body);
            }); */
      }
    } catch (e) {
      if (context.mounted) {
        //showSnackBar(context, e.toString());
      }
    }

    return product;
  }
}
