class Product {
  int? id;
  String? productName;
  String? description;
  dynamic price;
  String? photoUrl;

  Product({
    this.id,
    this.productName,
    this.description,
    this.price,
    this.photoUrl,
  });

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productName = json['productName'];
    description = json['description'];
    price = json['price'];
    photoUrl = json['photoUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['productName'] = this.productName;
    data['description'] = this.description;
    data['price'] = this.price;
    data['photoUrl'] = this.photoUrl;

    return data;
  }
}
