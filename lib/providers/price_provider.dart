import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/price_model.dart';
import 'auth_provider.dart';

class PriceProvider with ChangeNotifier {
  final AuthProvider authProvider;

  PriceProvider(this.authProvider);

  List<PriceModel> _prices = [];

  List<PriceModel> get prices => _prices;

  final String baseUrl = 'https://your-backend-api.com/api/prices';

  Future<void> fetchPrices() async {
    final token = authProvider.token;
    if (token == null) return;

    final url = Uri.parse(baseUrl);
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      _prices = data.map((e) => PriceModel.fromJson(e)).toList();
      notifyListeners();
    } else {
      throw Exception('Failed to fetch prices: ${response.body}');
    }
  }

  Future<void> addPrice(PriceModel price) async {
    final token = authProvider.token;
    if (token == null) return;

    final url = Uri.parse(baseUrl);
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: json.encode(price.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      _prices.add(price);
      notifyListeners();
    } else {
      throw Exception('Failed to add price: ${response.body}');
    }
  }
}
