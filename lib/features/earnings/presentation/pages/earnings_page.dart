import 'package:flutter/material.dart';
import 'package:kz_servicos_prestador/core/constants/app_colors.dart';
import 'package:kz_servicos_prestador/core/models/driver_profile_data.dart';
import 'package:kz_servicos_prestador/core/services/auth_state.dart';
import 'package:kz_servicos_prestador/core/services/driver_service.dart';
import 'package:kz_servicos_prestador/core/services/trip_service.dart';
import 'package:kz_servicos_prestador/core/widgets/provider_bottom_nav.dart';
import 'package:kz_servicos_prestador/features/earnings/presentation/widgets/earnings_chart_card.dart';

class EarningsPage extends StatefulWidget {
  final ValueChanged<int> onNavTap;

  const EarningsPage({super.key, required this.onNavTap});

  @override
  State<EarningsPage> createState() => _EarningsPageState();
}

class _EarningsPageState extends State<EarningsPage> {
  final _tripService = TripService();
  final _driverService = DriverService();

  EarningsData? _earnings;
  DriverProfileData? _profile;
  bool _loading = true;
  String _selectedPeriod = 'Diário';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profileId = AuthState.providerProfileId ?? '';
    final userId = AuthState.userId ?? '';
    final results = await Future.wait([
      _tripService.getDriverEarnings(profileId),
      _driverService.getDriverProfile(userId),
    ]);
    if (mounted) {
      setState(() {
        _earnings = results[0] as EarningsData;
        _profile = results[1] as DriverProfileData?;
        _loading = false;
      });
    }
  }

  PeriodEarning _periodEarning(EarningsData e) => switch (_selectedPeriod) {
        'Semanal' => e.weeklyEarning,
        'Mensal' => e.monthlyEarning,
        'Anual' => e.yearlyEarning,
        _ => e.dailyEarning,
      };

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _load,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding:
                          EdgeInsets.fromLTRB(24, 24, 24, bottomPadding + 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ganhos',
                            style: TextStyle(
                              fontFamily: 'OutfitBlack',
                              fontSize: 24,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _BalanceCard(earnings: _earnings!),
                          const SizedBox(height: 16),
                          _PeriodEarningsCard(
                            selectedPeriod: _selectedPeriod,
                            onPeriodChanged: (p) =>
                                setState(() => _selectedPeriod = p),
                            earning: _periodEarning(_earnings!),
                          ),
                          const SizedBox(height: 16),
                          EarningsChartCard(
                            monthlyHistory: _earnings!.monthlyHistory,
                            monthOverMonthDiff: _earnings!.currentMonthTotal -
                                _earnings!.previousMonthTotal,
                          ),
                          if (_profile != null) ...[
                            const SizedBox(height: 16),
                            _BankInfoCard(profile: _profile!),
                          ],
                          const SizedBox(height: 20),
                          _StatementSection(entries: _earnings!.recentEntries),
                        ],
                      ),
                    ),
                  ),
          ),
          Positioned(
            bottom: bottomPadding + 12,
            left: 24,
            right: 24,
            child: ProviderBottomNav(
              selectedIndex: 2,
              onItemSelected: widget.onNavTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final EarningsData earnings;

  const _BalanceCard({required this.earnings});

  @override
  Widget build(BuildContext context) {
    final lastTx = earnings.lastTransaction;
    final isPositive = lastTx.type != EarningType.withdrawal;
    final txColor = isPositive ? const Color(0xFF2ECC71) : Colors.red.shade300;
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
              if (lastTx.amount > 0) ...[
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
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
                style: TextStyle(fontFamily: 'OutfitBlack', fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodEarningsCard extends StatelessWidget {
  final String selectedPeriod;
  final ValueChanged<String> onPeriodChanged;
  final PeriodEarning earning;

  const _PeriodEarningsCard({
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
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.highlight : Colors.transparent,
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
                        color: isActive ? Colors.white : AppColors.textSecondary,
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
            '${earning.trips} corridas',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _BankInfoCard extends StatelessWidget {
  final DriverProfileData profile;

  const _BankInfoCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final bank = profile.bankName ?? '-';
    final agency = profile.bankAgency ?? '-';
    final account = profile.bankAccount ?? '-';
    final pix = profile.pixKey ?? '-';

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
                  style: TextStyle(color: AppColors.secondary, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$bank · Ag $agency · Cc $account',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            'PIX: $pix',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _StatementSection extends StatelessWidget {
  final List<EarningEntry> entries;

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
        if (entries.isEmpty)
          const Center(
            child: Text(
              'Nenhuma transação encontrada',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          )
        else
          ...entries.map((e) => _EntryTile(entry: e)),
      ],
    );
  }
}

class _EntryTile extends StatelessWidget {
  final EarningEntry entry;

  const _EntryTile({required this.entry});

  IconData get _icon => switch (entry.type) {
        EarningType.trip => Icons.directions_car,
        EarningType.bonus => Icons.star,
        EarningType.withdrawal => Icons.arrow_downward,
      };

  Color get _color => switch (entry.type) {
        EarningType.trip => const Color(0xFF2ECC71),
        EarningType.bonus => AppColors.highlight,
        EarningType.withdrawal => Colors.red,
      };

  @override
  Widget build(BuildContext context) {
    final isNegative = entry.type == EarningType.withdrawal;

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
                  '${entry.date.day.toString().padLeft(2, '0')}/${entry.date.month.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isNegative ? '-' : '+'}R\$ ${entry.amount.toStringAsFixed(2)}',
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
