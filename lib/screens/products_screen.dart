import 'package:flutter/material.dart';
import 'package:paymob_integration/models/product-model.dart';
import 'package:paymob_integration/screens/product_screen.dart';

import 'package:paymob_integration/shared/components/components.dart';
import 'package:paymob_integration/shared/components/constants.dart';
import 'package:paymob_integration/shared/dio_helper.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<Product>? productsList;
  void getData() async {
    await DioHelper.getData(url: 'Products/GetProducts', query: {})
        .then((value) {
      if (value!.data["status"] == false) {
        showToast(text: value.data["message"], state: ToastStates.ERROR);
        return;
      }
      setState(() {
        productsList = (value.data["data"] as List)
            .map((item) => Product.fromJson(item))
            .toList();
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // leading: const Icon(Icons.arrow_back),
        title: const Center(child: Text("جميع المنتجات")),
      ),
      body: productsList == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 201,
                      childAspectRatio: .75,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5),
                  itemCount: productsList!.length,
                  itemBuilder: (context, index) {
                    var item = productsList![index];
                    return InkWell(
                      onTap: () {
                        // ignore: prefer_const_constructors
                        navigateTo(
                            context,
                            ProductScreen(
                              productId: item.id!,
                              productName: item.productName!,
                              description: item.description!,
                              price: item.price,
                              photoUrl: item.photoUrl!,
                            ));
                      },
                      child: Card(
                        elevation: 0,
                        // margin: EdgeInsets.only(horizontal: 10, vertical: 10),
                        color: const Color.fromARGB(255, 250, 250, 250),
                        child: Container(
                          width: 250,
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 5),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.purple.shade800),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                    child: SizedBox(
                                  width: double.infinity,
                                  child: Image.network(
                                    '$webUrl/images/Products/${item.photoUrl}',
                                    fit: BoxFit.cover,
                                  ),
                                )),
                                Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.productName!,
                                          style: const TextStyle(
                                              fontSize: 20,
                                              color: Colors.black87),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Text(
                                          '${item.price.toStringAsFixed(0)} ج.م')
                                    ],
                                  ),
                                )
                              ]),
                        ),
                      ),
                    );
                  }),
            ),
    );
  }
}
