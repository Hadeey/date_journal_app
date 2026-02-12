import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DateFormNotifier extends ChangeNotifier {
  // Form state logic
}

final dateFormProvider = ChangeNotifierProvider((ref) => DateFormNotifier());
