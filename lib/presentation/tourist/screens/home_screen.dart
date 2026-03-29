import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afrivoyage/presentation/tourist/blocs/experience/experience_bloc.dart';
import 'package:afrivoyage/presentation/tourist/widgets/experience_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ExperienceBloc>().add(LoadExperiences());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AfriVoyage'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Navigate to profile (optional)
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search experiences...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  context.read<ExperienceBloc>().add(SearchExperiences(value));
                } else {
                  context.read<ExperienceBloc>().add(LoadExperiences());
                }
              },
            ),
          ),
        ),
      ),
      body: BlocBuilder<ExperienceBloc, ExperienceState>(
        builder: (context, state) {
          if (state is ExperienceLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ExperienceLoaded) {
            if (state.experiences.isEmpty) {
              return const Center(child: Text('No experiences found.'));
            }
            return ListView.builder(
              itemCount: state.experiences.length,
              itemBuilder: (context, index) {
                final experience = state.experiences[index];
                return ExperienceCard(
                  experience: experience,
                  onTap: () {
                    // Navigate to detail screen
                    context.go('/experience/${experience.id}');
                  },
                );
              },
            );
          } else if (state is ExperienceError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const SizedBox();
        },
      ),
    );
  }
}