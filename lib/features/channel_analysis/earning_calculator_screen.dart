import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EarningCalculatorScreen extends StatefulWidget {
  const EarningCalculatorScreen({super.key});

  @override
  State<EarningCalculatorScreen> createState() =>
      _EarningCalculatorScreenState();
}

class _EarningCalculatorScreenState extends State<EarningCalculatorScreen> {
  // State variables
  double _dailyViews = 0;
  double _cpm = 2.0;
  double _adEngagementRate = 60;
  final double _youtubeSharePercentage = 45;
  bool _isAdvancedExpanded = false;

  final TextEditingController _viewsController = TextEditingController();

  // Color Palette
  static const Color _bgBlack = Color(0xFF000000);
  static const Color _cardDark = Color(0xFF1A1A1A);
  static const Color _cardDarker = Color(0xFF262626);
  static const Color _textPrimary = Colors.white;
  static const Color _textSecondary = Color(0xFF9CA3AF);
  static const Color _accentGreen = Color(0xFF10B981);
  static const Color _accentRed = Color(0xFFEF4444);
  static const Color _accentBlue = Color(0xFF3B82F6);
  static const Color _dividerColor = Color(0xFF1F1F1F);

  @override
  void initState() {
    super.initState();
    _viewsController.text = '0';
  }

  @override
  void dispose() {
    _viewsController.dispose();
    super.dispose();
  }

  void _updateViews(String value) {
    if (value.isEmpty) {
      setState(() {
        _dailyViews = 0;
      });
      return;
    }
    setState(() {
      _dailyViews = double.tryParse(value) ?? 0;
    });
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(2)}M';
    } else if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(2)}K';
    } else {
      return NumberFormat.simpleCurrency().format(amount);
    }
  }

  // Calculation Logic
  double get _monetizedViews => _dailyViews * (_adEngagementRate / 100);
  double get _grossRevenue => (_monetizedViews * _cpm) / 1000;
  double get _creatorShare => (100 - _youtubeSharePercentage) / 100;
  double get _dailyEarnings => _grossRevenue * _creatorShare;
  double get _monthlyEarnings => _dailyEarnings * 30;
  double get _yearlyEarnings => _dailyEarnings * 365;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: _bgBlack,
        colorScheme: const ColorScheme.dark(
          primary: _accentGreen,
          surface: _cardDark,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: _bgBlack,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Earning Calculator',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: _textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          // bottom: PreferredSize(
          //   preferredSize: const Size.fromHeight(1),
          //   child: Container(color: _dividerColor, height: 1),
          // ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildMonthlyEarningsCard(),
              const SizedBox(height: 24),
              _buildDailyViewsInput(),
              const SizedBox(height: 24),
              _buildCPMSlider(),
              const SizedBox(height: 24),
              _buildAdvancedSettingsToggle(),
              if (_isAdvancedExpanded) ...[
                const SizedBox(height: 16),
                _buildAdvancedSettingsPanel(),
              ],
              const SizedBox(height: 24),
              _buildEarningsBreakdown(),
              const SizedBox(height: 24),
              _buildInfoCard(),
              const SizedBox(height: 16),
              const Text(
                'These are estimates. Actual earnings depend on factors like viewer location, niche, season, video length, and YouTube\'s ad policies.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF4B5563), fontSize: 11),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyEarningsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A1A), Color(0xFF262626)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Estimated Monthly Earnings',
            style: TextStyle(color: _textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            _formatCurrency(_monthlyEarnings),
            style: const TextStyle(
              color: _accentGreen,
              fontSize: 56,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'After YouTube\'s 45% revenue share',
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyViewsInput() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.remove_red_eye_outlined, color: _textSecondary),
              SizedBox(width: 12),
              Text(
                'Daily Views',
                style: TextStyle(color: _textPrimary, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _viewsController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: _textPrimary, fontSize: 24),
            cursorColor: _accentGreen,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: '0',
              hintStyle: TextStyle(color: _textSecondary),
            ),
            onChanged: _updateViews,
          ),
        ],
      ),
    );
  }

  Widget _buildCPMSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'CPM (Cost Per Mille)',
              style: TextStyle(color: _textPrimary, fontSize: 16),
            ),
            Text(
              NumberFormat.simpleCurrency().format(_cpm),
              style: const TextStyle(
                color: _accentGreen,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: _accentRed,
            inactiveTrackColor: const Color(0xFF374151),
            thumbColor: _accentRed,
            overlayColor: _accentRed.withOpacity(0.2),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: _cpm,
            min: 0.5,
            max: 15.0,
            divisions: 145,
            onChanged: (value) {
              setState(() {
                _cpm = value;
              });
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$0.50',
                style: TextStyle(color: _textSecondary, fontSize: 12),
              ),
              Text(
                '\$15.00',
                style: TextStyle(color: _textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '💡 Finance/Business: \$8-15 | Tech: \$4-8 | Gaming/Vlogs: \$2-5',
          style: TextStyle(color: _textSecondary, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildAdvancedSettingsToggle() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isAdvancedExpanded = !_isAdvancedExpanded;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardDark,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.tune, color: _textPrimary),
                SizedBox(width: 12),
                Text(
                  'Advanced Settings',
                  style: TextStyle(color: _textPrimary, fontSize: 16),
                ),
              ],
            ),
            Transform.rotate(
              angle: _isAdvancedExpanded ? 3.14159 : 0,
              child: const Icon(Icons.expand_more, color: _textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedSettingsPanel() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ad Engagement Rate',
                style: TextStyle(color: _textPrimary, fontSize: 14),
              ),
              Text(
                '${_adEngagementRate.toInt()}%',
                style: const TextStyle(
                  color: _accentBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: _accentBlue,
              inactiveTrackColor: const Color(0xFF374151),
              thumbColor: _accentBlue,
              overlayColor: _accentBlue.withOpacity(0.2),
            ),
            child: Slider(
              value: _adEngagementRate,
              min: 30,
              max: 90,
              divisions: 12,
              onChanged: (value) {
                setState(() {
                  _adEngagementRate = value;
                });
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '30%',
                  style: TextStyle(color: _textSecondary, fontSize: 12),
                ),
                Text(
                  '90%',
                  style: TextStyle(color: _textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Percentage of views that actually see ads',
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 11),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _cardDarker,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Revenue Split',
                  style: TextStyle(color: _textSecondary, fontSize: 14),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('You receive:', style: TextStyle(color: _textPrimary)),
                    Text(
                      '55%',
                      style: TextStyle(
                        color: _accentGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'YouTube keeps:',
                      style: TextStyle(color: _textPrimary),
                    ),
                    Text(
                      '45%',
                      style: TextStyle(
                        color: _accentRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsBreakdown() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.monetization_on_outlined, color: _textPrimary),
              SizedBox(width: 12),
              Text(
                'Earnings Breakdown',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildBreakdownRow('Daily Earnings', _dailyEarnings),
          const Divider(color: _dividerColor, height: 32),
          _buildBreakdownRow('Monthly Earnings (30 days)', _monthlyEarnings),
          const Divider(color: _dividerColor, height: 32),
          _buildBreakdownRow('Yearly Earnings (365 days)', _yearlyEarnings),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: _textSecondary, fontSize: 14),
        ),
        Text(
          _formatCurrency(amount),
          style: const TextStyle(
            color: _accentGreen,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A8A).withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E40AF).withOpacity(0.3)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📊 How This Calculation Works:',
            style: TextStyle(
              color: Color(0xFF93C5FD),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '• Only X% of views show ads (monetized views)\n'
            '• CPM of \$X per 1,000 monetized views\n'
            '• YouTube takes 45%, you receive 55%\n'
            '• Results are estimates - actual earnings vary',
            style: TextStyle(color: _textSecondary, fontSize: 11, height: 1.5),
          ),
        ],
      ),
    );
  }
}
