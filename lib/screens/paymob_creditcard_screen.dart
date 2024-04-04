import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:paymob_integration/screens/products_screen.dart';
import 'package:paymob_integration/shared/cache_helper.dart';
import 'package:paymob_integration/shared/components/components.dart';
import 'package:paymob_integration/shared/components/paymob.dart';
import 'package:paymob_integration/shared/dio_helper.dart';
import 'package:paymob_integration/models/new-order-model.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymobCreditCardScreen extends StatefulWidget {
  PaymobCreditCardScreen({super.key});

  @override
  State<PaymobCreditCardScreen> createState() => _PaymobCreditCardScreenState();
}

class _PaymobCreditCardScreenState extends State<PaymobCreditCardScreen> {
  bool isResponseRecieved = false;
  late NewOrder orderDetails;
  int? userOrderId;
  bool isLoaded = false;
  var token = CacheHelper.getData(key: "token");
  int OrderId = 0;

  Future<void> request1() async {
    DioHelper.postPaymobData(
        url: '$base_paymob_url/auth/tokens',
        data: {"api_key": api_key}).then((value) {
      print('token_first:' + value.data['token']);

      token_first = value.data['token'];
      request2();
    });
  }

  Future<void> request2() async {
    print('assure token_first:' + token_first);
    DioHelper.postPaymobData(url: '$base_paymob_url/ecommerce/orders', data: {
      "auth_token": token_first,
      "delivery_needed": "false",
      "amount_cents": orderDetails.totalPrice * 100,
      "currency": "EGP",
      "items": []
    }).then((value) {
      if (value.data["status"] != null) {}
      print('order id: ${value.data['id']}');
      print('response2: ${value.data}');
      setState(() {
        OrderId = value.data['id'];
      });

      request3();
    });
  }

  Future<void> request3() async {
    var data = {
      "auth_token": token_first,
      "amount_cents": orderDetails.totalPrice * 100,
      "expiration": 3600,
      "order_id": OrderId, //From Request2
      "billing_data": {
        "apartment": "NA",
        "email": orderDetails.email,
        "floor": "NA",
        "first_name": orderDetails.fullName!.split(' ')[0],
        "street": "NA",
        "building": "NA",
        "phone_number": orderDetails.phoneNumber,
        "shipping_method": "NA",
        "postal_code": "NA",
        "city": "NA",
        "country": "Egypt",
        "last_name": orderDetails.fullName!.split(' ')[1],
        "state": "NA"
      },
      "currency": "EGP",
      "integration_id": integration_id, // very important
      "lock_order_when_paid": "false",
      "items": []
    };

    DioHelper.postPaymobData(
            url: '$base_paymob_url/acceptance/payment_keys', data: data)
        .then((t) {
      token_second = t.data['token'];
      print('token_second: ${t.data['token']}');

      postPurchase();
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              // Update loading bar.
            },
            onPageStarted: (String url) {
              if (url.contains('post_pay?id=')) {
                setState(() {
                  isResponseRecieved = true;
                });
              }
            },
            onPageFinished: (String url) {},
            onWebResourceError: (WebResourceError error) {},
            onNavigationRequest: (NavigationRequest request) {
              if (request.url.startsWith('https://www.youtube.com/')) {
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse(
            'https://accept.paymob.com/api/acceptance/iframes/760844?payment_token=$token_second'));
      setState(() {
        isLoaded = true;
      });
    });
  }

  void postPurchase() {
    DioHelper.postData(
            url: 'Orders/NewOrder',
            data: {
              "userId": CacheHelper.getData(key: 'userId'),
              "productId": orderDetails.productId,
              "unitPrice": orderDetails.unitPrice,
              "quantity": orderDetails.quantity,
              "payment": orderDetails.totalPrice,
              "source": "iframe",
              "orderId": OrderId
            },
            query: {},
            token: token)
        .then((value) {
      print(value.data["data"]);
      if (value.data["status"] == false) {
        print(value.data["message"]);
      }
    }).catchError((error) {
      print(error.toString());
      //emit(ErrorState(error.toString()));
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    orderDetails =
        NewOrder.fromJson(jsonDecode(CacheHelper.getData(key: 'newOrder')));
    request1();
  }

  late WebViewController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoaded == false
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(children: [
              WebViewWidget(
                controller: controller,
              ),
              isResponseRecieved
                  ? Align(
                      alignment: AlignmentDirectional.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: defaultButton(
                            function: () {
                              Navigator.of(context).pop();
                              navigateTo(context, const ProductsScreen());
                            },
                            text: "متابعة التسوق",
                            background: Colors.green,
                            foregroundColor: Colors.white),
                      ),
                    )
                  : Container(),
            ]),
    );
  }
}
