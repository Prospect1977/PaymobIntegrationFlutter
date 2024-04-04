import 'package:flutter/material.dart';

import 'package:paymob_integration/screens/paymob_creditcard_screen.dart';
import 'package:paymob_integration/screens/paymob_kiosk_screen.dart';

import '../shared/components/components.dart';

class SelectPaymentMethodScreen extends StatefulWidget {
  const SelectPaymentMethodScreen({super.key});

  @override
  State<SelectPaymentMethodScreen> createState() =>
      _SelectPaymentMethodScreenState();
}

class _SelectPaymentMethodScreenState extends State<SelectPaymentMethodScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              option(
                widget: widget,
                title: "الدفع ببطاقة البنك",
                image: "assets/images/credit_cards.png",
                on_Tap: () {
                  Navigator.of(context).pop();
                  navigateTo(context, PaymobCreditCardScreen());
                },
              ),
              const SizedBox(
                height: 20,
              ),
              option(
                widget: widget,
                title: "الدفع في المتاجر",
                image: "assets/images/Store.png",
                on_Tap: () {
                  Navigator.of(context).pop();
                  navigateTo(context, const PaymobKioskScreen());
                },
              ),
            ]),
      ),
    );
  }
}

class option extends StatelessWidget {
  const option(
      {Key? key,
      required this.widget,
      required this.title,
      required this.image,
      required this.on_Tap()})
      : super(key: key);

  final SelectPaymentMethodScreen widget;
  final String title;
  final String image;

  final Function on_Tap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          on_Tap();
        },
        child: Container(
          alignment: Alignment.center,
          width: double.infinity,
          height: 100,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.circular(5)),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(image, height: 75),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 22, color: Colors.black.withOpacity(0.60)),
                ),
              ],
            ),
          ),
        ));
  }
}
