// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:paymob_integration/models/new-order-model.dart';
import 'package:paymob_integration/screens/products_screen.dart';

import 'package:paymob_integration/shared/cache_helper.dart';
import 'package:paymob_integration/shared/components/components.dart';
import 'package:paymob_integration/shared/components/paymob.dart';
import 'package:paymob_integration/shared/dio_helper.dart';

class PaymobKioskScreen extends StatefulWidget {
  const PaymobKioskScreen({super.key});

  @override
  State<PaymobKioskScreen> createState() => _PaymobKioskScreenState();
}

class _PaymobKioskScreenState extends State<PaymobKioskScreen> {
  bool isResponseRecieved = false;
  int bill_reference = 0;
  late NewOrder orderDetails;
  late int TransactionId;
  var fullName = CacheHelper.getData(key: "fullName");
  String phoneNumber = CacheHelper.getData(key: "phoneNumber");
  var email = CacheHelper.getData(key: "email");
  bool isLoaded = false;
  var token = CacheHelper.getData(key: "token");
  int OrderId = 0;
  void postPurchase() {
    DioHelper.postData(
            url: 'Orders/NewOrder',
            data: {
              "userId": CacheHelper.getData(key: 'userId'),
              "productId": orderDetails.productId,
              "unitPrice": orderDetails.unitPrice,
              "quantity": orderDetails.quantity,
              "payment": orderDetails.totalPrice,
              "source": "kiosk",
              "orderId": OrderId,
              "transactionId": TransactionId
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
      "integration_id": kiosk_integration_id, // very important
      "lock_order_when_paid": "false",
      "items": []
    };
    print(data);
    DioHelper.postPaymobData(
            url: '$base_paymob_url/acceptance/payment_keys', data: data)
        .then((t) {
      token_second = t.data['token'];
      print('token_second: ${t.data['token']}');

      request4();
    });
  }

  Future<void> request4() async {
    DioHelper.postPaymobData(
        url: '$base_paymob_url/acceptance/payments/pay',
        data: {
          "source": {"identifier": "AGGREGATOR", "subtype": "AGGREGATOR"},
          "payment_token": token_second
        }).then((t) {
      print(t.data["data"]);
      print(t.data["data"]["bill_reference"]);
      setState(() {
        isLoaded = true;
        isResponseRecieved = true;
        bill_reference = t.data["data"]["bill_reference"];
      });
      TransactionId = t.data["data"]["bill_reference"];
      postPurchase();
    }).catchError((e) {
      print(e.toString());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoaded == false
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(children: [
              Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("كود الدفع",
                      style: TextStyle(fontSize: 26, color: Colors.black54)),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    bill_reference.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Image.asset('assets/images/AmanMasaryMomken.png'),
                  Container(
                    width: MediaQuery.of(context).size.width / 1.5,
                    child: const Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        "إذهب بالكود إلى المتجر واخبرهم بأنك ترغب في الدفع عن طريق: امان أو مصاري أو ممكن، وسوف يتم بدأ إجراءات الشحن بعدها مباشرة",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, color: Colors.black54),
                      ),
                    ),
                  )
                ],
              )),
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
