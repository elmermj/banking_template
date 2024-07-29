import 'package:get/get.dart';

class DummyDataService extends GetxService {  
  List<Map<String,dynamic>> cards = [
    {
      "cardNum": "5307 xxxx xxxx 5201",
      "cardProvider": "Mastercard",
      "cardExpDate": "12/25",
      "cardBalance": "200000000"
    },
    {
      "cardNum": "3565 xxxx xxxx 2517",
      "cardProvider": "JCB",
      "cardExpDate": "01/26",
      "cardBalance": "123452310"
    },
    {
      "cardNum": "5257 xxxx xxxx 2517",
      "cardProvider": "Mastercard",
      "cardExpDate": "01/27",
      "cardBalance": "989114687"
    },
    {
      "cardNum": "4556 xxxx xxxx 2001",
      "cardProvider": "Visa",
      "cardExpDate": "07/27",
      "cardBalance": "693247514"
    },
    {
      "cardNum": "4556 xxxx xxxx 5548",
      "cardProvider": "Visa",
      "cardExpDate": "07/27",
      "cardBalance": "293247514"
    }
  ];
}