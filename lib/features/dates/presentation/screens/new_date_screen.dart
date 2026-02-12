import 'package:date_journal_app/core/constants/app_colors.dart';
import 'package:date_journal_app/core/constants/app_strings.dart';

import 'package:date_journal_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:date_journal_app/features/dates/models/date_entry.dart';
import 'package:date_journal_app/features/dates/presentation/providers/dates_provider.dart';
import 'package:date_journal_app/features/persons/models/person.dart';
import 'package:date_journal_app/features/persons/presentation/widgets/person_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class NewDateScreen extends ConsumerStatefulWidget {
  const NewDateScreen({super.key});

  @override
  ConsumerState<NewDateScreen> createState() => _NewDateScreenState();
}

class _NewDateScreenState extends ConsumerState<NewDateScreen> {
  final _formKey = GlobalKey<FormState>();

  // Person
  Person? _selectedPerson;

  // Basic Info
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final _locationController = TextEditingController();
  final _activityController = TextEditingController();
  final _styleController = TextEditingController();
  String _dateType = 'first';

  // Ratings
  int _chemistry = 5;
  int _conversation = 5;
  int _punctuality = 5;
  int _appearance = 5;
  double _overall = 0.0; // 0-5 stars

  // Text Fields
  final _notesController = TextEditingController(); // Ce qu'on a fait
  final _behaviorController = TextEditingController(); // Son comportement
  final _awkwardMomentsController = TextEditingController();
  final _greenFlagsController = TextEditingController();
  final _redFlagsController = TextEditingController();
  final _impressionController =
      TextEditingController(); // Comment ça s'est passé
  final _highlightsController = TextEditingController(); // À retenir

  // Mood
  String _mood = '😊';
  final List<String> _moods = ['😊', '😍', '🥰', '😐', '😔', '🤩', '😌', '💕'];

  final List<Map<String, String>> _dateTypes = [
    {'value': 'first', 'label': 'Premier RDV'},
    {'value': 'second', 'label': 'Deuxième RDV'},
    {'value': 'ongoing', 'label': 'Relation suivie'},
    {'value': 'casual', 'label': 'Rendez-vous décontracté'},
  ];

  @override
  void dispose() {
    _locationController.dispose();
    _activityController.dispose();
    _styleController.dispose();
    _notesController.dispose();
    _behaviorController.dispose();
    _awkwardMomentsController.dispose();
    _greenFlagsController.dispose();
    _redFlagsController.dispose();
    _impressionController.dispose();
    _highlightsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.text,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.text,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedPerson == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez sélectionner une personne')),
        );
        return;
      }

      final fullDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final user = await ref.read(authRepositoryProvider).getCurrentUser();
      final String id = const Uuid().v4();

      final newDate = DateEntry(
        id: id,
        userId: user?.id ?? '',
        personId: _selectedPerson!.id,
        dateTime: fullDateTime,
        location: _locationController.text.trim(),
        manStyle: _styleController.text.trim(),
        ratingChemistry: _chemistry,
        ratingConversation: _conversation,
        ratingPunctuality: _punctuality,
        ratingAppearance: _appearance,
        ratingOverall: _overall,
        whatWeDid: _activityController.text.trim(), // Mapped to activity input
        hisBehavior: _behaviorController.text.trim(),
        awkwardMoments: _awkwardMomentsController.text.trim(),
        funnyMoments:
            null, // Merged concept in UI or separate? usage notes map to 'Ce qu'on a fait'
        greenFlags: _greenFlagsController.text.trim(),
        redFlags: _redFlagsController.text.trim(),
        myNotes: _impressionController.text.trim(),
        highlights: _highlightsController.text.trim(),
        mood: _mood,
        dateType: _dateType,
        spentNightTogether: false, // Not in new UI
        createdAt: DateTime.now(),
      );

      ref.read(datesProvider.notifier).createDate(newDate);

      if (mounted) context.pop();
    }
  }

  // Custom Input Decoration
  InputDecoration _buildInputDecoration(String hint, {IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, color: Colors.grey[400]) : null,
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.secondary, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          Container(
            padding:
                const EdgeInsets.only(top: 50, left: 24, right: 24, bottom: 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.secondary],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(
                    0), // React design shows full width header/shadow
                bottomRight: Radius.circular(0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.close, color: Colors.white, size: 24),
                  ),
                ),
                const Text(
                  'Nouvelle Date',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 40), // Balance the close button
              ],
            ),
          ),

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Photos
                    const Text('Photos',
                        style: TextStyle(color: AppColors.text, fontSize: 14)),
                    const SizedBox(height: 8),
                    Container(
                      height: 96,
                      width: 96,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppColors.secondary,
                            width:
                                2), // Should be dashed but standard border is okay for MVP
                      ),
                      child: const Center(
                        child: Icon(Icons.camera_alt,
                            color: AppColors.secondary, size: 32),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Person Name (Using Selector for logic, but styling to match)
                    const Text('Prénom',
                        style: TextStyle(color: AppColors.text, fontSize: 14)),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: AppColors.secondary, width: 2),
                        color: Colors.white,
                      ),
                      child: PersonSelector(
                        selectedPerson: _selectedPerson,
                        onPersonSelected: (person) =>
                            setState(() => _selectedPerson = person),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Location
                    const Text('Lieu',
                        style: TextStyle(color: AppColors.text, fontSize: 14)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _locationController,
                      decoration: _buildInputDecoration('Où étiez-vous ?',
                          icon: Icons.location_on_outlined),
                      validator: (val) => val == null || val.isEmpty
                          ? AppStrings.requiredField
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Activity
                    const Text('Activité',
                        style: TextStyle(color: AppColors.text, fontSize: 14)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _activityController,
                      decoration: _buildInputDecoration(
                          'Qu\'avez-vous fait ?'), // Initial code had bug where location updated location variable for activity input
                    ),
                    const SizedBox(height: 16),

                    // Date & Time
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Date',
                                  style: TextStyle(
                                      color: AppColors.text, fontSize: 14)),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: _pickDate,
                                child: AbsorbPointer(
                                  child: TextFormField(
                                    decoration: _buildInputDecoration('',
                                        icon: Icons.calendar_today_outlined),
                                    controller: TextEditingController(
                                        text: DateFormat('dd/MM/yyyy')
                                            .format(_selectedDate)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Heure',
                                  style: TextStyle(
                                      color: AppColors.text, fontSize: 14)),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: _pickTime,
                                child: AbsorbPointer(
                                  child: TextFormField(
                                    decoration: _buildInputDecoration(
                                        ''), // No icon in React code for time
                                    controller: TextEditingController(
                                        text: _selectedTime.format(context)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Date Type
                    const Text('Type de RDV',
                        style: TextStyle(color: AppColors.text, fontSize: 14)),
                    const SizedBox(height: 8),
                    Container(
                      height: 50,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _dateTypes.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final type = _dateTypes[index];
                          final isSelected = _dateType == type['value'];
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _dateType = type['value']!),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.secondary,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                type['label']!,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.text,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Style
                    const Text('Style d\'homme',
                        style: TextStyle(color: AppColors.text, fontSize: 14)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _styleController,
                      decoration:
                          _buildInputDecoration('Timide, Romantique, ...'),
                    ),
                    const SizedBox(height: 24),

                    // Ratings
                    const Text('Évaluation',
                        style: TextStyle(
                            color: AppColors.text,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildRatingSlider('Chemistry', _chemistry,
                        (v) => setState(() => _chemistry = v)),
                    _buildRatingSlider('Conversation', _conversation,
                        (v) => setState(() => _conversation = v)),
                    _buildRatingSlider('Punctuality', _punctuality,
                        (v) => setState(() => _punctuality = v)),
                    _buildRatingSlider('Appearance', _appearance,
                        (v) => setState(() => _appearance = v)),
                    const SizedBox(height: 24),

                    // Mood
                    const Text('Humeur',
                        style: TextStyle(color: AppColors.text, fontSize: 14)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _moods.map((mood) {
                        final isSelected = _mood == mood;
                        return GestureDetector(
                          onTap: () => setState(() => _mood = mood),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color:
                                  isSelected ? AppColors.primary : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.secondary,
                                  width: 2),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color:
                                            AppColors.primary.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      )
                                    ]
                                  : [],
                            ),
                            child: Center(
                              child: Text(mood,
                                  style: const TextStyle(fontSize: 24)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Text Zones
                    _buildTextArea('Ce qu\'on a fait',
                        'Partagez vos impressions...', _notesController),
                    _buildTextArea('Comment s\'est-il comporté',
                        'Partagez vos impressions...', _behaviorController),
                    _buildTextArea(
                        'Moments gênants / drôles',
                        'Partagez vos impressions...',
                        _awkwardMomentsController),
                    _buildTextArea('Green flag', 'Partagez vos impressions...',
                        _greenFlagsController),
                    _buildTextArea('Red flag', 'Partagez vos impressions...',
                        _redFlagsController),

                    // Overall Rating
                    const Text('Note globale',
                        style: TextStyle(color: AppColors.text, fontSize: 14)),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(5, (index) {
                        final starValue = index + 1;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _overall = starValue.toDouble()),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Icon(
                              Icons.star,
                              color: starValue <= _overall
                                  ? AppColors.primary
                                  : Colors.grey[300],
                              size: 40,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),

                    _buildTextArea('Comment ça s\'est passé ?',
                        'Partagez vos impressions...', _impressionController),
                    _buildTextArea(
                        'À retenir',
                        'Détails importants, anecdotes...',
                        _highlightsController,
                        maxLines: 3),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Text('Enregistrer',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSlider(String label, int value, Function(int) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 14)),
            Text('$value/10',
                style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.secondary,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withOpacity(0.2),
            trackHeight: 8,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
          ),
          child: Slider(
            value: value.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: (val) => onChanged(val.toInt()),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildTextArea(
      String label, String placeholder, TextEditingController controller,
      {int maxLines = 4}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: AppColors.text, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: _buildInputDecoration(placeholder).copyWith(
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
