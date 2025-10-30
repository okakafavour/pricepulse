import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/price_provider.dart';
import '../widget/price_card.dart';
import 'report_price_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPrices();
  }

  Future<void> _fetchPrices() async {
    setState(() {
      _isLoading = true;
    });
    await Provider.of<PriceProvider>(context, listen: false).fetchPrices();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final priceData = Provider.of<PriceProvider>(context);
    final prices = priceData.prices;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PricePulse'),
        actions: [
          IconButton(
            onPressed: _fetchPrices,
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : prices.isEmpty
              ? const Center(child: Text('No prices available.'))
              : ListView.builder(
                  itemCount: prices.length,
                  itemBuilder: (ctx, i) => PriceCard(price: prices[i]),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 👇 Navigation to ReportPriceScreen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ReportPriceScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
