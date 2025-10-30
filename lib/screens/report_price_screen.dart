import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/price_model.dart';
import '../providers/price_provider.dart';

class ReportPriceScreen extends StatefulWidget {
  const ReportPriceScreen({super.key});

  @override
  State<ReportPriceScreen> createState() => _ReportPriceScreenState();
}

class _ReportPriceScreenState extends State<ReportPriceScreen> {
  final _formKey = GlobalKey<FormState>();
  final productController = TextEditingController();
  final marketController = TextEditingController();
  final locationController = TextEditingController();
  final priceController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    productController.dispose();
    marketController.dispose();
    locationController.dispose();
    priceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final price = PriceModel(
        id: '',
        productName: productController.text.trim(),
        market: marketController.text.trim(),
        location: locationController.text.trim(),
        price: double.parse(priceController.text),
        isVerified: false,
      );

      final provider = Provider.of<PriceProvider>(context, listen: false);
      await provider.addPrice(price);

      // After successful submission, refresh list and go back
      await provider.fetchPrices();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Price reported successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Price'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: productController,
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter product name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: marketController,
                decoration: const InputDecoration(labelText: 'Market'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter market name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter market location' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price (₦)'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter product price' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit Price'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
