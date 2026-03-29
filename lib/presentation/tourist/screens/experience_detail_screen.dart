import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afrivoyage/domain/entities/experience.dart';
import 'package:afrivoyage/presentation/tourist/blocs/booking/booking_bloc.dart';
import 'package:afrivoyage/presentation/tourist/blocs/experience/experience_bloc.dart';
import 'package:afrivoyage/presentation/tourist/screens/booking_confirmation_screen.dart';
import 'package:afrivoyage/presentation/shared/widgets/custom_button.dart';

class ExperienceDetailScreen extends StatefulWidget {
  final String experienceId;

  const ExperienceDetailScreen({super.key, required this.experienceId});

  @override
  State<ExperienceDetailScreen> createState() => _ExperienceDetailScreenState();
}

class _ExperienceDetailScreenState extends State<ExperienceDetailScreen> {
  Experience? _experience;
  DateTime _selectedDate = DateTime.now();
  int _participants = 1;
  String _paymentMethod = 'mtn';

  @override
  void initState() {
    super.initState();
    _loadExperience();
  }

  Future<void> _loadExperience() async {
    final state = context.read<ExperienceBloc>().state;
    if (state is ExperienceLoaded) {
      setState(() {
        _experience = state.experiences.firstWhere(
          (exp) => exp.id == widget.experienceId,
          orElse: () => throw Exception('Experience not found'),
        );
      });
    } else {
      // Fetch single experience (you may need a repository method for that)
      // For simplicity, assume we have it loaded in the bloc; otherwise implement a separate fetch.
      // In a real scenario, you'd have a method like `getExperienceById`.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_experience == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(_experience!.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                _experience!.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _experience!.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: 4),
                Text(_experience!.location),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text('${_experience!.rating} (${_experience!.reviewCount} reviews)'),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _experience!.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Text('Select Date', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                itemBuilder: (context, index) {
                  final date = DateTime.now().add(Duration(days: index));
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedDate = date),
                      child: Container(
                        width: 80,
                        decoration: BoxDecoration(
                          color: _selectedDate == date ? Colors.green : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${date.day}/${date.month}',
                              style: TextStyle(
                                color: _selectedDate == date ? Colors.white : Colors.black,
                              ),
                            ),
                            Text(
                              _getWeekday(date),
                              style: TextStyle(
                                color: _selectedDate == date ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text('Participants', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: _participants > 1
                      ? () => setState(() => _participants--)
                      : null,
                ),
                Text('$_participants'),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => setState(() => _participants++),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Radio(
                  value: 'mtn',
                  groupValue: _paymentMethod,
                  onChanged: (value) => setState(() => _paymentMethod = value as String),
                ),
                const Text('MTN Mobile Money'),
                const SizedBox(width: 16),
                Radio(
                  value: 'airtel',
                  groupValue: _paymentMethod,
                  onChanged: (value) => setState(() => _paymentMethod = value as String),
                ),
                const Text('Airtel Money'),
              ],
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Book Now - RWF ${_experience!.price * _participants}',
              onPressed: () {
                context.read<BookingBloc>().add(
                  CreateBooking(
                    experienceId: _experience!.id,
                    date: _selectedDate,
                    participants: _participants,
                    paymentMethod: _paymentMethod,
                  ),
                );
              },
            ),
            BlocListener<BookingBloc, BookingState>(
              listener: (context, state) {
                if (state is BookingSuccess) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingConfirmationScreen(booking: state.booking),
                    ),
                  );
                } else if (state is BookingError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
              child: const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  String _getWeekday(DateTime date) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[date.weekday - 1];
  }
}