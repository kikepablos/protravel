class PaymentModel {
  DateTime? created;
  DateTime? date;
  String? id;
  String? desc;
  num? payment;
  String? paymentMethod;
  String? reciver;
  String? reciverUID;
  String? reservationCode;
  PaymentModel(
      {this.created,
      this.date,
      this.id,
      this.desc,
      this.payment,
      this.paymentMethod,
      this.reciver,
      this.reciverUID,
      this.reservationCode});

  PaymentModel.fromMap(Map<String, dynamic> data, id)
      : this(
          created: data['created'].toDate(),
          date: data['date'].toDate(),
          desc: data['desc'] ?? '',
          id: id.toString(),
          payment: data['payment'],
          paymentMethod: data['paymentMethod'].toString(),
          reciver: data['reciver'].toString(),
          reciverUID: data['reciverUID'].toString(),
          reservationCode: data['reservationCode'].toString(),
        );

  Map<String, dynamic> toJson() {
    return {
      'desc': desc,
      'created': created,
      'date': date,
      'id': id,
      'payment': payment,
      'paymentMethod': paymentMethod,
      'reciver': reciver,
      'reciverUID': reciverUID,
      'reservationCode': reservationCode,
    };
  }
}
