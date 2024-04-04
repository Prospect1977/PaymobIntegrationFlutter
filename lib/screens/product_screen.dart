import 'package:flutter/material.dart';
import 'package:paymob_integration/models/new-order-model.dart';
import 'package:paymob_integration/screens/select_payment_method_screen.dart';

import 'package:paymob_integration/shared/cache_helper.dart';
import 'package:paymob_integration/shared/components/components.dart';
import 'package:paymob_integration/shared/components/constants.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen(
      {required this.productId,
      required this.productName,
      required this.description,
      required this.price,
      required this.photoUrl,
      super.key});
  final int productId;
  final String productName;
  final String description;
  final dynamic price;
  final String photoUrl;
  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  var formKey = GlobalKey<FormState>();
  bool showPurchaseForm = false;
  dynamic totalPrice = 0;
  int quantity = 1;
  TextEditingController fullNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  bool isNumeric(String s) {
    // ignore: unnecessary_null_comparison
    if (s == null) {
      return false;
    }
    return int.tryParse(s) != null;
  }

  NewOrder? newOrder;
  void _saveNewOrder() {
    totalPrice = int.parse(quantityController.text) * widget.price;
    newOrder = NewOrder(
        email: CacheHelper.getData(key: 'email'),
        productId: widget.productId,
        unitPrice: widget.price,
        fullName: fullNameController.text,
        phoneNumber: phoneNumberController.text,
        address: addressController.text,
        quantity: int.parse(quantityController.text),
        totalPrice: totalPrice);
    CacheHelper.saveData(key: 'newOrder', value: newOrder);
    //  navigateTo(context, SelectPaymentMethodScreen());
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    quantityController.text = "1";
    if (CacheHelper.getData(key: 'phoneNumber') != null) {
      phoneNumberController.text = CacheHelper.getData(key: 'phoneNumber');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: InkWell(
          child: const Icon(Icons.arrow_back),
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
        title: Center(child: Text(widget.productName)),
        actions: appBarActions,
      ),
      body: showPurchaseForm == false
          ? Padding(
              padding: const EdgeInsets.all(8),
              child: Column(children: [
                Image.network(
                  '$webUrl/images/products/${widget.photoUrl}',
                  width: double.infinity,
                  height: 400,
                  fit: BoxFit.cover,
                ),
                Container(
                  width: double.infinity,
                  height: 35,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: Colors.black38),
                  child: Text(
                    '${widget.price.toStringAsFixed(2)} ج.م',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    textDirection: TextDirection.rtl,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  widget.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontStyle: FontStyle.italic),
                ),
                const SizedBox(
                  height: 8,
                ),
                defaultButton(
                  function: () {
                    setState(() {
                      showPurchaseForm = true;
                    });
                  },
                  text: "شراء",
                  background: Colors.green.shade600,
                )
              ]))
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(children: [
                      defaultFormField(
                        controller: fullNameController,
                        type: TextInputType.name,
                        validate: (value) {
                          if (value.isEmpty || value.split(" ").length < 2) {
                            return "من فضلك ادخل الأسم الثنائي!";
                          }
                          return null;
                        },
                        label: "الأسم الثنائي",
                        prefix: Icons.account_circle,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: defaultFormField(
                          controller: phoneNumberController,
                          type: TextInputType.text,
                          validate: (value) {
                            if (value.isEmpty) {
                              return "من فضلك ادخل رقم الهاتف!";
                            }
                            return null;
                          },
                          label: "رقم الهاتف",
                          prefix: Icons.phone,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      defaultFormField(
                        controller: addressController,
                        type: TextInputType.multiline,
                        maximumLines: 2,
                        validate: (value) {
                          if (value.isEmpty) {
                            return "من فضلك ادخل العنوان!";
                          }
                          return null;
                        },
                        label: "العنوان",
                        prefix: Icons.home,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      defaultFormField(
                        controller: quantityController,
                        type: TextInputType.number,
                        onChange: (value) {
                          if (isNumeric(value)) {
                            if (int.parse(value) > 0) {
                              setState(() {
                                quantity = int.parse(value);
                              });
                            }
                          }
                        },
                        validate: (value) {
                          if (value.isEmpty) {
                            return "من فضلك ادخل الكمية المطلوبة!";
                          }
                          return null;
                        },
                        label: "الكمية المطلوبة",
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      defaultButton(
                        function: () {
                          if (formKey.currentState!.validate()) {
                            _saveNewOrder();
                            navigateTo(
                                context, const SelectPaymentMethodScreen());
                          }
                        },
                        borderRadius: 5,
                        background: Theme.of(context).colorScheme.primary,
                        text:
                            '${(widget.price * quantity).toStringAsFixed(2)} ج.م',
                        isUpperCase: false,
                      ),
                    ]),
                  ),
                ),
              ),
            ),
    );
  }
}
