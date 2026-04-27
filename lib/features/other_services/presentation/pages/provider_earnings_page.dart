import 'package:flutter/material.dart';
import 'package:kz_servicos_prestador/core/constants/app_colors.dart';
import 'package:kz_servicos_prestador/core/widgets/service_provider_bottom_nav.dart';
import 'package:kz_servicos_prestador/core/services/trip_service.dart' show MonthlyEarning;
import 'package:kz_servicos_prestador/features/earnings/data/models/mock_earnings.dart';
import 'package:kz_servicos_prestador/features/earnings/presentation/widgets/earnings_chart_card.dart';
import 'package:kz_servicos_prestador/features/profile/data/models/mock_provider.dart';

class ProviderEarningsPage extends StatefulWidget {
  final ValueChanged<int> onNavTap;

  const ProviderEarningsPage({super.key, required this.onNavTap});

  @override
  State<ProviderEarningsPage> createState() =>
      _ProviderEarningsPageState();
}

class _ProviderEarningsPageState extends State<ProviderEarningsPage> {
  String _selectedPeriod = 'Diário';

  MockPeriodEarning _periodEarning(MockEarnings e) =>
      switch (_selectedPeriod) {
        'Semanal' => e.weeklyEarning,
        'Mensal' => e.monthlyEarning,
        'Anual' => e.yearlyEarning,
        _ => e.dailyEarning,
      };

  @override
  Widget build(BuildContext context) {
    final earnings = MockEarnings.sample;
    final provider = MockProvider.providerSample;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final period = _periodEarning(earnings);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding:
                  EdgeInsets.fromLTRB(24, 24, 24, bottomPad + 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Carteira',
                    style: TextStyle(
                      fontFamily: 'OutfitBlack',
                      fontSize: 24,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _BalanceCard(earnings: earnings),
                  const SizedBox(height: 16),
                  _PeriodCard(
                    selectedPeriod: _selectedPeriod,
                    onPeriodChanged: (p) =>
                        setState(() => _selectedPeriod = p),
                    earning: period,
                  ),
                  const SizedBox(height: 16),
                  EarningsChartCard(
                    monthlyHistory: earnings.monthlyHistory
                        .map((m) => MonthlyEarning(
                              month: m.month,
                              year: m.year,
                              total: m.total,
                              trips: m.trips,
                            ))
                        .toList(),
                    monthOverMonthDiff: earnings.currentMonthTotal -
                        earnings.previousMonthTotal,
                  ),
                  const SizedBox(height: 16),
                  _BankInfoCard(provider: provider),
                  const SizedBox(height: 20),
                  _StatementSection(entries: earnings.recentEntries),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: bottomPad + 12,
            left: 24,
            right: 24,
            child: ServiceProviderBottomNav(
              selectedIndex: 1,
              onItemSelected: widget.onNavTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final MockEarnings earnings;

  const _BalanceCard({required this.earnings});

  @override
  Widget build(BuildContext context) {
    final lastTx = earnings.lastTransaction;
    final isPositive = lastTx.type != EarningType.withdrawal;
    final txColor =
        isPositive ? const Color(0xFF2ECC71) : Colors.red.shade300;
    final txSign = isPositive ? '+' : '-';
    final txAmount = lastTx.amount.abs();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2261FE), Color(0xFF1A4BC9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Saldo disponível',
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'R\$ ${earnings.availableBalance.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontFamily: 'OutfitBlack',
                  fontSize: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: txColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$txSign R\$ ${txAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontFamily: 'OutfitBlack',
                      fontSize: 13,
                      color: txColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Solicitar saque',
                style:
                    TextStyle(fontFamily: 'OutfitBlack', fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodCard extends StatelessWidget {
  final String selectedPeriod;
  final ValueChanged<String> onPeriodChanged;
  final MockPeriodEarning earning;

  const _PeriodCard({
    required this.selectedPeriod,
    required this.onPeriodChanged,
    required this.earning,
  });

  static const _periods = ['Diário', 'Semanal', 'Mensal', 'Anual'];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: _periods.map((p) {
              final isActive = p == selectedPeriod;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => onPeriodChanged(p),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.highlight
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: isActive
                          ? null
                          : Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      p,
                      style: TextStyle(
                        fontFamily: 'QuasimodoSemiBold',
                        fontSize: 12,
                        color: isActive
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Text(
            'R\$ ${earning.total.toStringAsFixed(2)}',
            style: const TextStyle(
              fontFamily: 'OutfitBlack',
              fontSize: 28,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${earning.trips} serviços',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _BankInfoCard extends StatelessWidget {
  final MockProvider provider;

  const _BankInfoCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance,
                  color: AppColors.textSecondary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Dados bancários',
                style: TextStyle(
                  fontFamily: 'OutfitBlack',
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Editar',
                  style: TextStyle(
                      color: AppColors.secondary, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${provider.bankName} · Ag ${provider.bankAgency} · Cc ${provider.bankAccount}',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'PIX: ${provider.pixKey}',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatementSection extends StatelessWidget {
  final List<MockEarningEntry> entries;

  const _StatementSection({required this.entries});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Extrato',
          style: TextStyle(
            fontFamily: 'OutfitBlack',
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...entries.map((e) => _EntryTile(entry: e)),
      ],
    );
  }
}

class _EntryTile extends StatelessWidget {
  final MockEarningEntry entry;

  const _EntryTile({required this.entry});

  IconData get _icon => switch (entry.type) {
        EarningType.trip => Icons.handyman_rounded,
        EarningType.bonus => Icons.star,
        EarningType.withdrawal => Icons.arrow_downward,
      };

  Color get _color => switch (entry.type) {
        EarningType.trip => const Color(0xFF2ECC71),
        EarningType.bonus => AppColors.highlight,
        EarningType.withdrawal => Colors.red.shade400,
      };

  @override
  Widget build(BuildContext context) {
    final isNeg = entry.type == EarningType.withdrawal;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_icon, color: _color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.description,
                  style: const TextStyle(
                    fontFamily: 'QuasimodoSemiBold',
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.date.day.toString().padLeft(2, '0')}/'
                  '${entry.date.month.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isNeg ? '-' : '+'}R\$ ${entry.amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontFamily: 'OutfitBlack',
              fontSize: 15,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}
