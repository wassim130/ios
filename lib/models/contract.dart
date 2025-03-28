import 'package:get/get.dart';

class Contract {
  final int id;
  final String title,client;
  final bool status;
  final double amount,progress;
  final DateTime date;
  Contract({required this.id ,required this.title, required this.client, required this.status, required this.amount,required this.progress, required this.date});
  
  static Future<List<Contract>> fetchAll() async{
    return await Future.delayed(Duration(seconds: 0),() => [
      Contract(id:1,title: 'Contract 1'.tr, client: 'John Doe'.tr, status: true, amount: 1000.0,progress:0.1, date: DateTime.now()),
      Contract(id:2,title: 'Contract 2'.tr, client: 'Jane Smith'.tr, status: false, amount: 2000.0,progress:0.4, date: DateTime.now().subtract(Duration(days: 30))),
      Contract(id:3,title: 'Contract 3'.tr, client: 'Bob Johnson'.tr, status: true, amount: 3000.0,progress:0.8, date: DateTime.now().subtract(Duration(days: 60))),
      Contract(id:4,title: 'Contract 3'.tr, client: 'Bob Johnson'.tr, status: true, amount: 3000.0,progress:0.4, date: DateTime.now().subtract(Duration(days: 35))),
      Contract(id:5,title: 'Contract 3'.tr, client: 'Bob Johnson'.tr, status: true, amount: 3000.0,progress:0.4, date: DateTime.now().subtract(Duration(days: 20))),
      Contract(id:6,title: 'Contract 3'.tr, client: 'Bob Johnson'.tr, status: true, amount: 3000.0,progress:0.4, date: DateTime.now().subtract(Duration(days: 15))),
      Contract(id:7,title: 'Contract 3'.tr, client: 'Bob Johnson'.tr, status: true, amount: 3000.0,progress:0.4, date: DateTime.now().subtract(Duration(days: 7))),
      Contract(id:8,title: 'Contract 3'.tr, client: 'Bob Johnson'.tr, status: true, amount: 3000.0,progress:0.4, date: DateTime.now().subtract(Duration(days: 460))),
    ]);
  }


  @override
  String toString() {
    return 'Contract{title: $title, client: $client, status: $status, amount: $amount, date: $date}';
  }
  
  factory Contract.fromMap(Map<String,dynamic> map){
    return Contract(
      id: map['id'],
      title: map['title'],
      client: map['client'],
      status: map['status'] == 'active'.tr,
      progress: map['progress'],
      amount: map['amount'],
      date: DateTime.parse(map['date'])
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'client': client,
     'status': status? 'active' : 'inactive'.tr,
      'amount': amount,
      'progress': progress,
      'date': date.toIso8601String()
    };
  }
}