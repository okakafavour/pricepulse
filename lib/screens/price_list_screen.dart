import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/price_provider.dart';
import '../widget/price_card.dart';
import 'report_price_screen.dart';

class PriceListScreen extends StatelessWidget {
  const PriceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PriceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Prices'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: RefreshIndicator(
        onRefresh: provider.fetchPrices,
        child: provider.prices.isEmpty
            ? const Center(
                child: Text(
                  'No prices available',
                  style: TextStyle(fontSize: 16),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: provider.prices.length,
                itemBuilder: (context, index) {
                  final price = provider.prices[index];
                  return PriceCard(price: price);
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 5,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReportPriceScreen()),
          );
          await provider.fetchPrices(); // Refresh list when coming back
        },
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}
