import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/price_model.dart';
import 'auth_provider.dart';

class PriceProvider with ChangeNotifier {
  final AuthProvider authProvider;

  PriceProvider(this.authProvider);

  List<PriceModel> _prices = [];
  List<PriceModel> get prices => _prices;

  final String baseUrl = 'http://10.54.2.240:8080/products';

  // Fetch all products
  Future<void> fetchPrices() async {
    final token = authProvider.token;
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List<dynamic> data = decoded is List ? decoded : decoded['products'] ?? [];
        _prices = data.map((e) => PriceModel.fromJson(e)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to fetch prices');
      }
    } catch (e) {
      debugPrint('Error fetching prices: $e');
      rethrow;
    }
  }

  // Add product (web + mobile)
  Future<void> addPrice({
    required String productName,
    required double price,
    required String area,
    required String description,
    required String category,
    File? imageFile,      // mobile
    Uint8List? webImage,  // web
    required BuildContext context,
  }) async {
    final token = authProvider.token;

    if (productName.isEmpty || price <= 0 || area.isEmpty || category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    if (!kIsWeb && imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    if (kIsWeb && webImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      return;
    }

    try {
      final request = http.MultipartRequest('POST', Uri.parse(baseUrl));
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['name'] = productName;
      request.fields['price'] = price.toString();
      request.fields['area'] = area;
      request.fields['description'] = description;
      request.fields['category'] = category;

      if (kIsWeb && webImage != null) {
        request.files.add(
          http.MultipartFile.fromBytes('image', webImage, filename: '$productName.png'),
        );
      } else if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully')),
        );
        await fetchPrices();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add product: $responseBody')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
