import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../data/repositories/booking_repository.dart';

// ─────────────────────────────────────────────
// Static experience data — keyed by id
// ─────────────────────────────────────────────
const _kExpData = <String, Map<String, dynamic>>{
  'exp1': {
    'title': 'Gorilla Trekking Experience',
    'priceRWF': 95000.0,
    'location': 'Volcanoes National Park',
    'duration': '6–8 hours',
    'color': 0xFF1B5E20,
    'description':
        'Trek through lush rainforests to encounter endangered mountain gorillas in their natural habitat.',
        'providerId': 'provider_gorilla_01',
  },
  'exp2': {
    'title': 'Traditional Intore Dance Workshop',
    'priceRWF': 15000.0,
    'location': 'Kigali Cultural Center',
    'duration': '2 hours',
    'color': 0xFF4A148C,
    'description':
        'Learn the powerful Intore dance — a UNESCO-recognised cultural heritage of Rwanda.',
        'providerId': 'provider_intore_01',
  },
  'exp3': {
    'title': 'Coffee Farm Tour & Tasting',
    'priceRWF': 20000.0,
    'location': 'Huye District',
    'duration': '3 hours',
    'color': 0xFF4E342E,
    'description':
        'Visit a local coffee cooperative and learn about Rwanda\'s famous single-origin coffee.',
        'providerId': 'provider_coffee_01',
  },
  'exp4': {
    'title': 'Nyungwe Forest Canopy Walk',
    'priceRWF': 25000.0,
    'location': 'Nyungwe National Park',
    'duration': '4 hours',
    'color': 0xFF2E7D32,
    'description':
        'Walk 70 m above the ground on a suspension bridge through one of Africa\'s oldest rainforests.',
        'providerId': 'provider_nyungwe_01',
  },
  'exp5': {
    'title': 'Lake Kivu Sunset Cruise',
    'priceRWF': 18000.0,
    'location': 'Gisenyi, Lake Kivu',
    'duration': '2 hours',
    'color': 0xFF01579B,
    'description':
        'Sail on beautiful Lake Kivu while watching the sunset over the Congo Nile Trail mountains.',
        'providerId': 'provider_kivu_01',
  },
  'exp6': {
    'title': 'Kigali City Heritage Tour',
    'priceRWF': 12000.0,
    'location': 'Kigali City',
    'duration': '3 hours',
    'color': 0xFFE65100,
    'description':
        'Explore Kigali\'s transformation from the Genocide Memorial to bustling Kimironko Market.',
        'providerId': 'provider_kigali_01',
  },
};

// ─────────────────────────────────────────────
// BookingScreen
// ─────────────────────────────────────────────
class BookingScreen extends StatefulWidget {
  final String? experienceId;
  const BookingScreen({super.key, this.experienceId});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _selectedDate;
  int _groupSize = 1;
  bool _isProcessing = false;
  String _selectedPayment = 'mtn';

  final _bookingRepo = BookingRepository();

  Map<String, dynamic> get _exp {
    final id = widget.experienceId ?? '';
    return Map<String, dynamic>.from(
      _kExpData[id] ?? _kExpData['exp1']!,
    );
  }

  double get _basePrice => _exp['priceRWF'] as double;
  double get _total => _basePrice * _groupSize;
  double get _platformFee => _total * 0.08;
  double get _providerEarnings => _total * 0.92;

  String _fmt(double v) {
    if (v >= 1000) {
      final k = v / 1000;
      return '${k % 1 == 0 ? k.toInt() : k.toStringAsFixed(1)}K';
    }
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // No id? Show "browse first" message
    if (widget.experienceId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.bookExperience)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.explore_outlined,
                  size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(l10n.noExperienceSelected,
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text(l10n.browseExperiencesFromHome,
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: Text(l10n.browseExperiences),
              ),
            ],
          ),
        ),
      );
    }

    final exp = _exp;
    final bg = Color(exp['color'] as int);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bookExperience)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero header ──────────────────────────────
            Container(
              width: double.infinity,
              height: 155,
              color: bg,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    exp['title'] as String,
                    style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 13, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(exp['location'] as String,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12)),
                      const SizedBox(width: 14),
                      const Icon(Icons.timer_outlined,
                          size: 13, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(exp['duration'] as String,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Description ──────────────────────
                  Text(
                    exp['description'] as String,
                    style: TextStyle(
                        color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 24),

                  // ── Date selection ───────────────────
                  _sectionTitle(l10n.selectDate),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedDate != null
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade400,
                          width: _selectedDate != null ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_month,
                              color: _selectedDate != null
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primary
                                  : Colors.grey),
                          const SizedBox(width: 12),
                          Text(
                            _selectedDate != null
                                ? _formatDate(_selectedDate!)
                                : l10n.tapToChooseDate,
                            style: TextStyle(
                                color: _selectedDate != null
                                    ? null
                                    : Colors.grey[500]),
                          ),
                          const Spacer(),
                          if (_selectedDate == null)
                            Text(l10n.required,
                                style: TextStyle(
                                    color: Colors.red[400],
                                    fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Group size ───────────────────────
                  _sectionTitle(l10n.groupSize),
                  const SizedBox(height: 10),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(l10n.numberOfPeople,
                              style: const TextStyle(fontSize: 14)),
                          Row(
                            children: [
                              IconButton(
                                onPressed: _groupSize > 1
                                    ? () => setState(
                                        () => _groupSize--)
                                    : null,
                                icon: const Icon(
                                    Icons.remove_circle_outline),
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary,
                              ),
                              SizedBox(
                                width: 36,
                                child: Text('$_groupSize',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight:
                                            FontWeight.bold)),
                              ),
                              IconButton(
                                onPressed: _groupSize < 15
                                    ? () => setState(
                                        () => _groupSize++)
                                    : null,
                                icon: const Icon(
                                    Icons.add_circle_outline),
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Payment method ───────────────────
                  _sectionTitle(l10n.paymentMethod),
                  const SizedBox(height: 10),
                  _paymentTile(
                      'mtn',
                      l10n.mtnMobileMoney,
                      l10n.payWithMtn,
                      const Color(0xFFFFC400)),
                  const SizedBox(height: 8),
                  _paymentTile(
                      'airtel',
                      l10n.airtelMoney,
                      l10n.payWithAirtel,
                      const Color(0xFFD50000)),
                  const SizedBox(height: 24),

                  // ── Price breakdown ──────────────────
                  _sectionTitle(l10n.priceBreakdown),
                  const SizedBox(height: 10),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _priceRow(
                            l10n.experienceFee,
                            'RWF ${_fmt(_basePrice)} × $_groupSize',
                          ),
                          const SizedBox(height: 6),
                          _priceRow(
                            l10n.subtotal,
                            'RWF ${_fmt(_total)}',
                          ),
                          _priceRow(
                            l10n.platformFee,
                            '− RWF ${_fmt(_platformFee)}',
                            isGrey: true,
                          ),
                          const Divider(height: 20),
                          _priceRow(
                            l10n.total,
                            'RWF ${_fmt(_total)}',
                            isBold: true,
                            isGreen: true,
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.green
                                  .withValues(alpha: 0.1),
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.favorite,
                                    size: 14,
                                    color: Colors.green),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'RWF ${_fmt(_providerEarnings)} goes directly to the local provider (92 %)',
                                    style: const TextStyle(
                                        color: Colors.green,
                                        fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Confirm button ───────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_isProcessing ||
                              _selectedDate == null)
                          ? null
                          : _processBooking,
                      child: _isProcessing
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(l10n.confirmAndPay),
                    ),
                  ),
                  if (_selectedDate == null) ...[
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        l10n.selectDateToContinue,
                        style: const TextStyle(
                            color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      l10n.freeCancellation,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.grey[500], fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────

  Widget _sectionTitle(String title) => Text(
        title,
        style: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.bold),
      );

  Widget _paymentTile(
      String id, String title, String subtitle, Color color) {
    final selected = _selectedPayment == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: selected ? 0.12 : 0.06),
          border: Border.all(
            color: selected ? color : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color,
              child: Text(
                id == 'mtn' ? 'M' : 'A',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold)),
                  Text(subtitle,
                      style: TextStyle(
                          color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: selected ? color : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(
    String label,
    String value, {
    bool isBold = false,
    bool isGrey = false,
    bool isGreen = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight:
                      isBold ? FontWeight.bold : FontWeight.normal,
                  color: isGrey ? Colors.grey[500] : null)),
          Text(value,
              style: TextStyle(
                  fontWeight:
                      isBold ? FontWeight.bold : FontWeight.normal,
                  color: isGreen
                      ? Colors.green
                      : (isGrey ? Colors.grey[500] : null),
                  fontSize: isBold ? 16 : 14)),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${_dayName(d.weekday)}, ${d.day} ${_monthName(d.month)} ${d.year}';

  String _dayName(int w) =>
      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][w - 1];

  String _monthName(int m) => [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ][m - 1];

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _processBooking() async {
  if (_selectedDate == null) return;
  setState(() => _isProcessing = true);

  try {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You need to be logged in to make a booking.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      setState(() => _isProcessing = false);
      return;
    }

    final bookingId = await _bookingRepo.createBooking(
      touristId: currentUser.uid,
      experienceId: widget.experienceId!,
      providerId: _exp['providerId'] as String,
      experienceDate: _selectedDate!,
      groupSize: _groupSize,
      totalPrice: _total,
      paymentMethod: _selectedPayment,
    );

    if (mounted) {
      setState(() => _isProcessing = false);
      _showConfirmation(bookingId);
    }
  } catch (e) {
    if (mounted) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking failed: ${e.toString().replaceFirst('Exception: ', '')}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

  void _showConfirmation(String bookingId) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.check_circle,
            color: Colors.green, size: 56),
        title: Text(l10n.bookingConfirmedTitle,
            textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _exp['title'] as String,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${_formatDate(_selectedDate!)} · $_groupSize ${_groupSize == 1 ? l10n.person : l10n.people}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 6),
            Text(
              '${l10n.total}: RWF ${_fmt(_total)}',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),

            const SizedBox(height: 6),
            Text(
              'Booking ID: ${bookingId.substring(0, 8).toUpperCase()}',
              style: TextStyle(color: Colors.grey[500], fontSize: 11),
            ),

            const SizedBox(height: 12),
            Text(
              l10n.smsConfirmation,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.pop();
              },
              child: Text(l10n.done),
            ),
          ),
        ],
      ),
    );
  }
}
