import 'package:date_journal_app/core/constants/app_colors.dart';
import 'package:date_journal_app/core/constants/app_strings.dart';
import 'package:date_journal_app/core/theme/text_styles.dart';

import 'package:date_journal_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:date_journal_app/features/dates/models/date_entry.dart';
import 'package:date_journal_app/features/dates/presentation/providers/dates_provider.dart';
import 'package:date_journal_app/features/persons/presentation/providers/persons_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:uuid/uuid.dart';

class NewDateScreen extends ConsumerStatefulWidget {
  final String? dateId;
  const NewDateScreen({super.key, this.dateId});

  @override
  ConsumerState<NewDateScreen> createState() => _NewDateScreenState();
}

class _NewDateScreenState extends ConsumerState<NewDateScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _initialized = false;

  // Person
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _howKnownController = TextEditingController();

  // Basic Info
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final _locationController = TextEditingController();
  final _activityController =
      TextEditingController(); // Activité (General type)
  final _styleController = TextEditingController(); // Style d'homme

  // Ratings
  int _chemistry = 5;
  int _conversation = 5;
  int _punctuality = 5;
  int _appearance = 5;
  double _overall = 0.0;

  // Text Fields (Detailed)
  final _whatWeDidController = TextEditingController(); // Ce qu'on a fait
  final _behaviorController =
      TextEditingController(); // Comment s'est-il comporté
  final _awkwardMomentsController =
      TextEditingController(); // Moments gênants/drôles
  final _greenFlagsController = TextEditingController();
  final _redFlagsController = TextEditingController();
  final _impressionController =
      TextEditingController(); // Comment ça s'est passé
  final _highlightsController = TextEditingController(); // À retenir

  // Mood
  String _mood = '😊';
  final List<String> _moods = ['😊', '😍', '🥰', '😐', '😔', '🤩', '😌', '💕'];

  // CreatedAt preservation for edit mode
  DateTime? _originalCreatedAt;
  String?
      _personId; // For linking if person already exists (not used in simple flow yet)

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _howKnownController.dispose();
    _locationController.dispose();
    _activityController.dispose();
    _styleController.dispose();
    _whatWeDidController.dispose();
    _behaviorController.dispose();
    _awkwardMomentsController.dispose();
    _greenFlagsController.dispose();
    _redFlagsController.dispose();
    _impressionController.dispose();
    _highlightsController.dispose();
    super.dispose();
  }

  void _initialize(DateEntry date) {
    if (_initialized) return;

    _nameController.text = date.person?.name ?? '';
    _ageController.text = date.person?.age?.toString() ?? '';
    _howKnownController.text = date.person?.howKnown ?? '';
    _selectedDate = date.dateTime;
    _selectedTime = TimeOfDay.fromDateTime(date.dateTime);
    _locationController.text = date.location;
    // Activity manually mapped if needed or removed
    _styleController.text = date.manStyle ?? '';
    _chemistry = date.ratingChemistry;
    _conversation = date.ratingConversation;
    _punctuality = date.ratingPunctuality;
    _appearance = date.ratingAppearance;
    _overall = date.ratingOverall;
    _whatWeDidController.text = date.whatWeDid ?? '';
    _behaviorController.text = date.hisBehavior ?? '';
    _awkwardMomentsController.text = date.awkwardMoments ?? '';
    _greenFlagsController.text = date.greenFlags ?? '';
    _redFlagsController.text = date.redFlags ?? '';
    _impressionController.text = date.myNotes ?? '';
    _highlightsController.text = date.highlights ?? '';
    _mood = date.mood ?? '😊';
    _originalCreatedAt = date.createdAt;
    _personId = date.personId;
    _initialized = true;
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
            colorScheme: const ColorScheme.light(
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
            colorScheme: const ColorScheme.light(
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
      final name = _nameController.text.trim();
      final ageText = _ageController.text.trim();
      final howKnown = _howKnownController.text.trim();

      final int? age = ageText.isNotEmpty ? int.tryParse(ageText) : null;

      if (name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez entrer un prénom')),
        );
        return;
      }

      // 1. Create or Find Person
      // For now, simpler flow: always create/update logic.
      // If we are editing (_personId != null), we update the person?
      // Or we just create a NEW person for this date?
      // Since "persons" works as a profile, we should try to update if ID exists,
      // or create new.

      String? currentPersonId = _personId;

      if (currentPersonId == null || currentPersonId.isEmpty) {
        // Create new person
        final newPerson = await ref.read(personsProvider.notifier).addPerson(
              name: name,
              age: age,
              howKnown: howKnown.isEmpty ? null : howKnown,
            );

        if (newPerson != null) {
          currentPersonId = newPerson.id;
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content:
                      Text('Erreur lors de la création du profil (Personne)')),
            );
          }
          return;
        }
      } else {
        // Update existing person?
        // Let's assume for now we don't update person info from here to keep it simple,
        // unless user explicitly wants to. "remets le code pour implémenter persons"
        // implies we capture this info.
        // Ideally we should update the person record if we have an ID.
        // But the provider currently only has `addPerson`.
        // Let's stick to using the ID we have or created.
      }

      final fullDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final user = await ref.read(authRepositoryProvider).getCurrentUser();

      // If editing, use existing ID. If new, generate ID.
      final String id = widget.dateId ?? const Uuid().v4();

      final dateEntry = DateEntry(
        id: id,
        userId: user?.id ?? '',
        personId: currentPersonId,
        dateTime: fullDateTime,
        location: _locationController.text.trim(),
        manStyle: _styleController.text.trim(),
        ratingChemistry: _chemistry,
        ratingConversation: _conversation,
        ratingPunctuality: _punctuality,
        ratingAppearance: _appearance,
        ratingOverall: _overall,
        whatWeDid: _whatWeDidController.text.trim(),
        hisBehavior: _behaviorController.text.trim(),
        awkwardMoments: _awkwardMomentsController.text.trim(),
        funnyMoments: null, // Merged
        greenFlags: _greenFlagsController.text.trim(),
        redFlags: _redFlagsController.text.trim(),
        myNotes: _impressionController.text.trim(),
        highlights: _highlightsController.text.trim(),
        mood: _mood,
        dateType: 'casual', // Set default or add selector if needed.
        spentNightTogether: false, // Default or add field if needed
        createdAt:
            _originalCreatedAt ?? DateTime.now(), // Preserve creation time
      );

      try {
        if (widget.dateId != null) {
          await ref.read(datesProvider.notifier).updateDate(dateEntry);
          // Invalidate detail provider to refresh details screen
          ref.invalidate(dateDetailProvider(widget.dateId!));
        } else {
          await ref.read(datesProvider.notifier).createDate(dateEntry);
        }
        if (mounted) context.pop();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e')),
          );
        }
      }
    }
  }

  // Custom Input Decoration matching the design
  InputDecoration _buildInputDecoration(String hint, {IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      prefixIcon: icon != null ? Icon(icon, color: Colors.grey[400]) : null,
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18), // Rounded corners
        borderSide: const BorderSide(color: AppColors.secondary, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.primary, width: 0.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.error, width: 0.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.error, width: 0.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If in edit mode, fetch data
    final AsyncValue<DateEntry?>? dateAsync = widget.dateId != null
        ? ref.watch(dateDetailProvider(widget.dateId!))
        : null;

    // Handle loading/error for edit mode
    if (dateAsync != null) {
      if (dateAsync.isLoading) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }
      if (dateAsync.hasError) {
        return Scaffold(
          body: Center(child: Text('Erreur: ${dateAsync.error}')),
        );
      }
      if (dateAsync.value != null && !_initialized) {
        _initialize(dateAsync.value!);
      }
    }

    // Ensure persons are loaded for duplication check
    // ref.watch(personsProvider); // No longer needed

    final isEditing = widget.dateId != null;

    return Scaffold(
      extendBodyBehindAppBar:
          true, // Allow body to scroll behind app bar if needed, but here we just want gradient header
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Modifier la Date' : 'Nouvelle Date',
          style: AppTextStyles.h1.copyWith(color: Colors.white, fontSize: 24),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFF6B9D), // Light pink
                Color(0xFFFF8FA3), // Darker pink
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Photos
                Text('Photos', style: AppTextStyles.h3.copyWith(fontSize: 18)),
                const SizedBox(height: 12),
                CustomPaint(
                  painter: _DashedBorderPainter(
                      color: AppColors.secondary, strokeWidth: 1.5, gap: 5.0),
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      // Border removed here, handled by painter
                    ),
                    child: const Center(
                      child: Icon(Icons.camera_alt_outlined,
                          color: AppColors.secondary, size: 32),
                    ),
                  ),
                ),
                // Dashed border effect simulation could be added here if critical
                const SizedBox(height: 24),

                // Prénom / Nom
                Text('Nom et Prénom',
                    style: AppTextStyles.h3.copyWith(fontSize: 16)),
                const SizedBox(height: 8),
                _buildShadowWrapper(
                  TextFormField(
                    controller: _nameController,
                    decoration: _buildInputDecoration('Prénom de la personne',
                        icon: Icons.person_outline),
                    validator: (val) => val == null || val.isEmpty
                        ? AppStrings.requiredField
                        : null,
                  ),
                ),
                const SizedBox(height: 20),

                // Age
                Text('Âge', style: AppTextStyles.h3.copyWith(fontSize: 16)),
                const SizedBox(height: 8),
                _buildShadowWrapper(
                  TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: _buildInputDecoration('Âge (optionnel)',
                        icon: Icons.cake_outlined),
                  ),
                ),
                const SizedBox(height: 20),

                // Comment je l'ai connu
                Text('Comment je l\'ai connu',
                    style: AppTextStyles.h3.copyWith(fontSize: 16)),
                const SizedBox(height: 8),
                _buildShadowWrapper(
                  TextFormField(
                    controller: _howKnownController,
                    decoration: _buildInputDecoration('Tinder, Bar, Amis...',
                        icon: Icons.question_answer_outlined),
                  ),
                ),
                const SizedBox(height: 20),

                // Lieu
                Text('Lieu', style: AppTextStyles.h3.copyWith(fontSize: 16)),
                const SizedBox(height: 8),
                _buildShadowWrapper(
                  TextFormField(
                    controller: _locationController,
                    decoration: _buildInputDecoration('Où étiez-vous ?',
                        icon: Icons.location_on_outlined),
                    validator: (val) => val == null || val.isEmpty
                        ? AppStrings.requiredField
                        : null,
                  ),
                ),
                const SizedBox(height: 20),

                // Activité
                Text('Activité',
                    style: AppTextStyles.h3.copyWith(fontSize: 16)),
                const SizedBox(height: 8),
                _buildShadowWrapper(
                  TextFormField(
                    controller: _activityController,
                    decoration: _buildInputDecoration('Qu\'avez-vous fait ?'),
                  ),
                ),
                const SizedBox(height: 20),

                // Date & Heure
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date',
                              style: AppTextStyles.h3.copyWith(fontSize: 16)),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _pickDate,
                            child: AbsorbPointer(
                              child: _buildShadowWrapper(
                                TextFormField(
                                  controller: TextEditingController(
                                      text: DateFormat('dd/MM/yyyy')
                                          .format(_selectedDate)),
                                  decoration: _buildInputDecoration('',
                                      icon: Icons.calendar_today_outlined),
                                ),
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
                          Text('Heure',
                              style: AppTextStyles.h3.copyWith(fontSize: 16)),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _pickTime,
                            child: AbsorbPointer(
                              child: _buildShadowWrapper(
                                TextFormField(
                                  controller: TextEditingController(
                                      text: _selectedTime.format(context)),
                                  decoration: _buildInputDecoration('')
                                      .copyWith(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 20,
                                                  vertical: 16)),
                                  // Removed icon to match design
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Style d'homme
                Text('Style d\'homme',
                    style: AppTextStyles.h3.copyWith(fontSize: 16)),
                const SizedBox(height: 8),
                _buildShadowWrapper(
                  TextFormField(
                    controller: _styleController,
                    decoration:
                        _buildInputDecoration('Timide, Romantique, ...'),
                  ),
                ),
                const SizedBox(height: 32),

                // ... rating slider and moods ...
                // Keep lines 451-509 unchanged, jumping to buildTextArea usage?
                // Actually I can't jump too much with replace_file_content if I want to be safe.
                // I'll stick to replacing lines 356 to 449 for the main block.
                // And separately update _buildTextArea and add the helper which is at the end.

                const SizedBox(height: 32),

                // Évaluation
                Text('Évaluation', style: AppTextStyles.h3),
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

                // Humeur
                Text('Humeur', style: AppTextStyles.h3.copyWith(fontSize: 16)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _moods.map((mood) {
                    final isSelected = _mood == mood;
                    return GestureDetector(
                      onTap: () => setState(() => _mood = mood),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.secondary,
                            width: 1,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                          ],
                        ),
                        // If selected, we might want to fill it, but emojis have their own color.
                        // Better to use a border/background indicator.
                        // Let's use the design: Pink background if selected.
                        child: Center(
                          child: Text(
                            mood,
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),

                // Text Areas
                _buildTextArea('Ce qu\'on a fait',
                    'Partagez vos impressions...', _whatWeDidController),
                _buildTextArea('Comment s\'est-il comporté',
                    'Partagez vos impressions...', _behaviorController),
                _buildTextArea('Moments gênants / drôles',
                    'Partagez vos impressions...', _awkwardMomentsController),
                _buildTextArea('Green flag', 'Partagez vos impressions...',
                    _greenFlagsController),
                _buildTextArea('Red flag', 'Partagez vos impressions...',
                    _redFlagsController),

                const SizedBox(height: 16),

                // Note Globale
                Text('Note globale',
                    style: AppTextStyles.h3.copyWith(fontSize: 16)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _overall = (index + 1).toDouble()),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(
                          index < _overall ? Icons.star : Icons.star_border,
                          color: index < _overall
                              ? const Color(0xFFFFD93D)
                              : Colors.grey[300], // Yellow star
                          size: 40,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),

                _buildTextArea('Comment ça s\'est passé ?',
                    'Partagez vos impressions...', _impressionController),
                _buildTextArea('À retenir', 'Détails importants, anecdotes...',
                    _highlightsController),

                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: AppColors.primary.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Enregistrer',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
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
                style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w500)),
            Text(
              '$value/10',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary, // #FF6B9D
            inactiveTrackColor: AppColors.secondary, // #F8C4D8
            thumbColor: AppColors.primary,
            trackHeight: 6.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
            overlayColor: AppColors.primary.withOpacity(0.2),
          ),
          child: Slider(
            value: value.toDouble(),
            min: 1,
            max: 10,
            onChanged: (val) => onChanged(val.toInt()),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTextArea(
      String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.h3.copyWith(fontSize: 16)),
        const SizedBox(height: 12),
        _buildShadowWrapper(
          TextFormField(
            controller: controller,
            maxLines: 4,
            decoration: _buildInputDecoration(hint).copyWith(
              alignLabelWithHint: true,
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildShadowWrapper(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
            spreadRadius: 2,
          ),
        ],
      ),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  _DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final double width = size.width;
    final double height = size.height;
    final double dashWidth = gap;
    final double dashSpace = gap;

    final Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, width, height), const Radius.circular(20)));

    final Path dashPath = Path();
    final ui.PathMetrics metrics = path.computeMetrics();

    for (final ui.PathMetric metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.gap != gap;
  }
}
