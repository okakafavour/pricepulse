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
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPrices();
  }

  /// ✅ Fetch prices from backend with error handling
  Future<void> _fetchPrices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Provider.of<PriceProvider>(context, listen: false).fetchPrices();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load prices: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final priceProvider = Provider.of<PriceProvider>(context);
    final prices = priceProvider.prices;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F5FF),
      appBar: AppBar(
        title: const Text('PricePulse'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _fetchPrices,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton.icon(
                          onPressed: _fetchPrices,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              : prices.isEmpty
                  ? const Center(
                      child: Text(
                        'No prices available yet.\nTap + to add a new report!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchPrices,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: prices.length,
                        itemBuilder: (ctx, i) => PriceCard(price: prices[i]),
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReportPriceScreen()),
          );
        },
        backgroundColor: const Color(0xFF1565C0),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
