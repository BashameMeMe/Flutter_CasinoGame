import 'package:dio/dio.dart';
import 'package:flutter_application_1/BaiTap/BaiTap7/product.dart'; 

class API{
  Future<List<Product>> getAllProduct() async {
    var dio = Dio();
    var response = await dio.get('https://fakestoreapi.com/products');
    List<Product> listProduct=[];
    if (response.statusCode == 200){
      print(response.data);
      List data = response.data;
      listProduct  =data.map((x)=> Product.fromJson(x)).toList();
    }
    
    else {
      print('Failed to load products');
    }
  return listProduct;
  }
}

var testAPI = API();