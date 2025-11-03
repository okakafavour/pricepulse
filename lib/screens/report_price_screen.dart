import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/price_provider.dart';

class ReportPriceScreen extends StatefulWidget {
  const ReportPriceScreen({super.key});

  @override
  State<ReportPriceScreen> createState() => _ReportPriceScreenState();
}

class _ReportPriceScreenState extends State<ReportPriceScreen> {
  final _formKey = GlobalKey<FormState>();
  final productController = TextEditingController();
  final categoryController = TextEditingController();
  final areaController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();

  Uint8List? webImage;
  File? imageFile;

  bool _isSubmitting = false;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    if (kIsWeb) {
      final bytes = await picked.readAsBytes();
      setState(() {
        webImage = bytes;
        imageFile = null;
      });
    } else {
      setState(() {
        imageFile = File(picked.path);
        webImage = null;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final provider = Provider.of<PriceProvider>(context, listen: false);

      await provider.addPrice(
        productName: productController.text.trim(),
        price: double.parse(priceController.text.trim()),
        area: areaController.text.trim(),
        description: descriptionController.text.trim(),
        category: categoryController.text.trim(),
        imageFile: imageFile,
        webImage: webImage,
        context: context,
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting product: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    productController.dispose();
    categoryController.dispose();
    areaController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Product Price')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: productController,
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (v) => v == null || v.isEmpty ? 'Enter product name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (v) => v == null || v.isEmpty ? 'Enter category' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: areaController,
                decoration: const InputDecoration(labelText: 'Area / Location'),
                validator: (v) => v == null || v.isEmpty ? 'Enter area' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price (₦)'),
                validator: (v) => v == null || v.isEmpty ? 'Enter price' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (v) => v == null || v.isEmpty ? 'Enter description' : null,
              ),
              const SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Pick Image'),
              ),
              const SizedBox(height: 10),
              if (kIsWeb && webImage != null) Image.memory(webImage!, height: 150),
              if (!kIsWeb && imageFile != null) Image.file(imageFile!, height: 150),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
