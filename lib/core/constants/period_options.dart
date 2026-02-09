/// Mood options for period log: value (stored in DB), label (display).
const List<({String value, String label})> periodMoodOptions = [
  (value: 'good', label: 'Bien'),
  (value: 'tired', label: 'Fatigué(e)'),
  (value: 'anxious', label: 'Anxieux(se)'),
  (value: 'irritable', label: 'Irrité(e)'),
];

/// Symptom options: value (stored in DB), label (display).
const List<({String value, String label})> periodSymptomOptions = [
  (value: 'cramps', label: 'Crampes'),
  (value: 'headache', label: 'Maux de tête'),
  (value: 'acne', label: 'Acné'),
  (value: 'pain', label: 'Douleurs'),
  (value: 'bloating', label: 'Ballonnements'),
];

/// Returns the display label for a mood value, or the raw value if unknown.
String periodMoodLabel(String? value) {
  if (value == null || value.isEmpty) return '';
  for (final o in periodMoodOptions) {
    if (o.value == value) return o.label;
  }
  return value;
}

/// Returns the display label for a symptom value, or the raw value if unknown.
String periodSymptomLabel(String value) {
  for (final o in periodSymptomOptions) {
    if (o.value == value) return o.label;
  }
  return value;
}
