class SellsModel {
  String? id;
  String? reservationCode;
  DateTime? date;
  DateTime? travelDate;
  String? clientName;
  String? clientEmail;
  String? address;
  String? phone;
  String? description;
  List? payments;
  String? sellType;
  String? package;
  String? destiny;
  num? travelers;
  String? sellerName;
  String? season;
  String? sellerUID;
  num? totalPrice;
  String? status;
  num? pago;

  SellsModel(
      {this.address,
      this.clientName,
      this.package,
      this.date,
      this.season,
      this.description,
      this.destiny,
      this.pago,
      this.payments,
      this.id,
      this.phone,
      this.clientEmail,
      this.reservationCode,
      this.sellType,
      this.sellerName,
      this.sellerUID,
      this.totalPrice,
      this.status,
      this.travelDate,
      this.travelers});

  SellsModel.fromMap(Map<String, dynamic> data, id)
      : this(
          id: id,
          reservationCode: data['reservationCode'].toString(),
          package: data['package'] ?? '',
          date: data['date'] == null ? null : data['date'].toDate(),
          status: data['status'],
          payments: data['payments'] ?? [],
          travelDate:
              data['travelDate'] == null ? null : data['travelDate'].toDate(),
          clientName: data['clientName'],
          address: data['address'],
          season: data['season'] ?? '',
          pago: data['pago'] ?? 0,
          clientEmail: data['clientEmail'],
          phone: data['phone'],
          description: data['description'],
          sellType: data['sellType'],
          destiny: data['destiny'],
          travelers: data['travelers'],
          sellerName: data['sellerName'],
          sellerUID: data['sellerUID'],
          totalPrice: data['totalPrice'],
        );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reservationCode': reservationCode,
      'date': date,
      'travelDate': travelDate,
      'clientName': clientName,
      'address': address,
      'package': package,
      'pago': pago,
      'clientEmail': clientEmail,
      'phone': phone,
      'description': description,
      'season': season,
      'sellType': sellType,
      'status': status,
      'destiny': destiny,
      'travelers': travelers,
      'sellerName': sellerName,
      'sellerUID': sellerUID,
      'totalPrice': totalPrice
    };
  }
}
