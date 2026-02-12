import 'package:date_journal_app/core/constants/app_colors.dart';
import 'package:date_journal_app/core/constants/app_strings.dart';
import 'package:date_journal_app/core/theme/text_styles.dart';
import 'package:date_journal_app/features/dates/models/date_entry.dart';
import 'package:date_journal_app/features/dates/presentation/providers/dates_provider.dart';
import 'package:date_journal_app/features/dates/presentation/widgets/man_style_selector.dart';
import 'package:date_journal_app/features/dates/presentation/widgets/rating_slider.dart';
import 'package:date_journal_app/features/persons/models/person.dart';
import 'package:date_journal_app/features/persons/presentation/widgets/person_selector.dart';
import 'package:date_journal_app/shared/widgets/loading_spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class EditDateScreen extends ConsumerStatefulWidget {
  final String dateId;
  const EditDateScreen({super.key, required this.dateId});

  @override
  ConsumerState<EditDateScreen> createState() => _EditDateScreenState();
}

class _EditDateScreenState extends ConsumerState<EditDateScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _initialized = false;
  
  // Person
  Person? _selectedPerson;
  
  // Basic Info
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final _locationController = TextEditingController();
  
  // Style
  String? _manStyle;
  
  // Ratings
  int _chemistry = 5;
  int _conversation = 5;
  int _punctuality = 5;
  int _appearance = 5;
  double _overall = 3.0;

  // Text Fields
  final _whatWeDidController = TextEditingController();
  final _hisBehaviorController = TextEditingController();
  final _awkwardMomentsController = TextEditingController();
  final _funnyMomentsController = TextEditingController();
  final _greenFlagsController = TextEditingController();
  final _redFlagsController = TextEditingController();
  final _myNotesController = TextEditingController();
  
  // Others
  bool _spentNight = false;
  
  // CreateAt preservation
  DateTime _originalCreatedAt = DateTime.now();

  @override
  void dispose() {
    _locationController.dispose();
    _whatWeDidController.dispose();
    _hisBehaviorController.dispose();
    _awkwardMomentsController.dispose();
    _funnyMomentsController.dispose();
    _greenFlagsController.dispose();
    _redFlagsController.dispose();
    _myNotesController.dispose();
    super.dispose();
  }

  void _initialize(DateEntry date) {
    if (_initialized) return;
    _selectedPerson = date.person;
    _selectedDate = date.dateTime;
    _selectedTime = TimeOfDay.fromDateTime(date.dateTime);
    _locationController.text = date.location;
    _manStyle = date.manStyle;
    _chemistry = date.ratingChemistry;
    _conversation = date.ratingConversation;
    _punctuality = date.ratingPunctuality;
    _appearance = date.ratingAppearance;
    _overall = date.ratingOverall;
    _whatWeDidController.text = date.whatWeDid ?? '';
    _hisBehaviorController.text = date.hisBehavior ?? '';
    _awkwardMomentsController.text = date.awkwardMoments ?? '';
    _funnyMomentsController.text = date.funnyMoments ?? '';
    _greenFlagsController.text = date.greenFlags ?? '';
    _redFlagsController.text = date.redFlags ?? '';
    _myNotesController.text = date.myNotes ?? '';
    _spentNight = date.spentNightTogether;
    _originalCreatedAt = date.createdAt;
    _initialized = true;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _submit(String userId) async {
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

      final updatedDate = DateEntry(
        id: widget.dateId,
        userId: userId,
        personId: _selectedPerson!.id,
        dateTime: fullDateTime,
        location: _locationController.text.trim(),
        manStyle: _manStyle,
        ratingChemistry: _chemistry,
        ratingConversation: _conversation,
        ratingPunctuality: _punctuality,
        ratingAppearance: _appearance,
        ratingOverall: _overall,
        whatWeDid: _whatWeDidController.text.trim(),
        hisBehavior: _hisBehaviorController.text.trim(),
        awkwardMoments: _awkwardMomentsController.text.trim(),
        funnyMoments: _funnyMomentsController.text.trim(),
        greenFlags: _greenFlagsController.text.trim(),
        redFlags: _redFlagsController.text.trim(),
        myNotes: _myNotesController.text.trim(),
        spentNightTogether: _spentNight,
        createdAt: _originalCreatedAt,
      );

      await ref.read(datesProvider.notifier).updateDate(updatedDate);
      
      // Also invalidate detail provider
      ref.invalidate(dateDetailProvider(widget.dateId));
      
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateAsync = ref.watch(dateDetailProvider(widget.dateId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier la Date'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: dateAsync.when(
        data: (date) {
            if (date == null) return const Center(child: Text('Date introuvable'));
            if (!_initialized) _initialize(date);

            return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
            key: _formKey,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                PersonSelector(
                    selectedPerson: _selectedPerson,
                    onPersonSelected: (person) {
                    setState(() => _selectedPerson = person);
                    },
                ),
                const SizedBox(height: 16),

                TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                    labelText: 'Lieu',
                    prefixIcon: Icon(Icons.place_outlined),
                    hintText: 'Où étiez-vous ?',
                    ),
                    validator: (val) => val == null || val.isEmpty ? AppStrings.requiredField : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                    controller: _whatWeDidController,
                    decoration: const InputDecoration(
                    labelText: 'Activité',
                    hintText: 'Qu\'avez-vous fait ?',
                    ),
                ),
                const SizedBox(height: 16),

                Row(
                    children: [
                    Expanded(
                        child: InkWell(
                        onTap: _pickDate,
                        child: InputDecorator(
                            decoration: const InputDecoration(
                            labelText: 'Date',
                            prefixIcon: Icon(Icons.calendar_today_outlined),
                            ),
                            child: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                        ),
                        ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                        child: InkWell(
                        onTap: _pickTime,
                        child: InputDecorator(
                            decoration: const InputDecoration(
                            labelText: 'Heure',
                            prefixIcon: Icon(Icons.access_time),
                            ),
                            child: Text(_selectedTime.format(context)),
                        ),
                        ),
                    ),
                    ],
                ),
                const SizedBox(height: 24),

                ManStyleSelector(
                    selectedStyle: _manStyle,
                    onSelected: (style) {
                    setState(() => _manStyle = style);
                    },
                ),
                const SizedBox(height: 24),

                Text('Évaluation', style: AppTextStyles.h3),
                const SizedBox(height: 8),
                
                // Star Rating for Overall
                Center(
                    child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                        return IconButton(
                        onPressed: () {
                            setState(() {
                            _overall = index + 1.0;
                            });
                        }, 
                        icon: Icon(
                            index < _overall ? Icons.star : Icons.star_border,
                            color: AppColors.accent,
                            size: 40,
                        ),
                        );
                    }),
                    ),
                ),
                const SizedBox(height: 16),

                RatingSlider(label: 'Alchimie', value: _chemistry, onChanged: (v) => setState(() => _chemistry = v)),
                const SizedBox(height: 8),
                RatingSlider(label: 'Conversation', value: _conversation, onChanged: (v) => setState(() => _conversation = v)),
                const SizedBox(height: 8),
                RatingSlider(label: 'Ponctualité', value: _punctuality, onChanged: (v) => setState(() => _punctuality = v)),
                const SizedBox(height: 8),
                RatingSlider(label: 'Apparence', value: _appearance, onChanged: (v) => setState(() => _appearance = v)),
                const SizedBox(height: 24),

                TextFormField(
                    controller: _hisBehaviorController,
                    decoration: const InputDecoration(
                    labelText: 'Son comportement',
                    prefixIcon: Icon(Icons.person_outline),
                    ),
                    maxLines: 2,
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                    controller: _greenFlagsController,
                    decoration: const InputDecoration(
                    labelText: 'Green Flags',
                    prefixIcon: Icon(Icons.check_circle_outline, color: AppColors.success),
                    ),
                    maxLines: 2,
                ),
                const SizedBox(height: 16),

                TextFormField(
                    controller: _redFlagsController,
                    decoration: const InputDecoration(
                    labelText: 'Red Flags',
                    prefixIcon: Icon(Icons.warning_amber_rounded, color: AppColors.error),
                    ),
                    maxLines: 2,
                ),
                const SizedBox(height: 24),

                SwitchListTile(
                    title: Text('Nuit ensemble ?', style: AppTextStyles.body),
                    value: _spentNight, 
                    onChanged: (val) => setState(() => _spentNight = val),
                    activeColor: AppColors.primary,
                ),
                const SizedBox(height: 32),

                SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                    onPressed: () => _submit(date.userId),
                    child: const Text('Mettre à jour'),
                    ),
                ),
                const SizedBox(height: 48),
                ],
            ),
            ),
            );
        }, 
        loading: () => const LoadingSpinner(),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
      ),
    );
  }
}
