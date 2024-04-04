class NewOrder {
  int? productId;
  int? quantity;
  dynamic unitPrice;
  dynamic totalPrice;
  String? email;
  String? phoneNumber;
  String? fullName;
  String? address;

  NewOrder(
      {this.productId,
      this.quantity,
      this.unitPrice,
      this.phoneNumber,
      this.totalPrice,
      this.email,
      this.fullName,
      this.address});

  NewOrder.fromJson(Map<String, dynamic> json) {
    productId = json['productId'];
    quantity = json['quantity'];
    unitPrice = json['unitPrice'];
    totalPrice = json['totalPrice'];
    phoneNumber = json['phoneNumber'];
    email = json['email'];
    fullName = json['fullName'];
    address = json['address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['productId'] = productId;
    data['quantity'] = quantity;
    data['unitPrice'] = unitPrice;
    data['totalPrice'] = totalPrice;
    data['phoneNumber'] = phoneNumber;
    data['email'] = email;
    data['fullName'] = fullName;
    data['address'] = address;

    return data;
  }
}
