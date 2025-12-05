import 'package:flutter/material.dart';

import 'package:yttool_flutter/shared/widgets/input_field.dart';

class EarningCalculatorScreen extends StatefulWidget {
  const EarningCalculatorScreen({super.key});

  @override
  State<EarningCalculatorScreen> createState() =>
      _EarningCalculatorScreenState();
}

class _EarningCalculatorScreenState extends State<EarningCalculatorScreen> {
  final TextEditingController _viewsController = TextEditingController();
  double _cpm = 2.0;
  double _dailyEarnings = 0;
  double _monthlyEarnings = 0;
  double _yearlyEarnings = 0;

  void _calculateEarnings() {
    final viewsText = _viewsController.text.trim();
    if (viewsText.isEmpty) return;

    final views = int.tryParse(viewsText) ?? 0;

    setState(() {
      _dailyEarnings = (views / 1000) * _cpm;
      _monthlyEarnings = _dailyEarnings * 30;
      _yearlyEarnings = _dailyEarnings * 365;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Earning Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Estimated Monthly Earnings',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${_monthlyEarnings.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            InputField(
              controller: _viewsController,
              hintText: 'Daily Views',
              keyboardType: TextInputType.number,
              suffixIcon: const Icon(Icons.visibility),
              onChanged: (_) => _calculateEarnings(),
            ),
            const SizedBox(height: 24),
            Text(
              'CPM (Cost Per Mille): \$${_cpm.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Slider(
              value: _cpm,
              min: 0.5,
              max: 20.0,
              divisions: 39,
              label: _cpm.toStringAsFixed(2),
              onChanged: (value) {
                setState(() {
                  _cpm = value;
                });
                _calculateEarnings();
              },
            ),
            const Text(
              'CPM varies by niche and location. Average is around \$2-\$5.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildStatRow('Daily Earnings', _dailyEarnings),
            const Divider(),
            _buildStatRow('Yearly Earnings', _yearlyEarnings),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
