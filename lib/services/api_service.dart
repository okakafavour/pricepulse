import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/price_model.dart';

class ApiService {
  // 👇 Use correct backend URL and route
  static const String baseUrl = "http://10.0.2.2:8080";

  Future<List<PriceModel>> fetchPrices() async {
    final response = await http.get(Uri.parse("$baseUrl/products"));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // your backend returns: { "message": "...", "products": [...] }
      final List products = data["products"];

      return products.map((e) => PriceModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load products: ${response.body}");
    }
  }
}
