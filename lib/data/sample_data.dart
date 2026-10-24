import 'package:flutter/material.dart';

import '../models.dart';

/// Fixed lists the app uses for icons and form options.
/// Trainers, bookings and reviews come from the Supabase database.
/// Category ids must match the `categories` table.

final List<Category> kCategories = [
  const Category(id: 'football', name: L('Football', 'كرة القدم'), icon: Icons.sports_soccer, color: Color(0xFF166534), tint: Color(0xFFDCFCE7)),
  const Category(id: 'swimming', name: L('Swimming', 'سباحة'), icon: Icons.pool, color: Color(0xFF1E40AF), tint: Color(0xFFDBEAFE)),
  const Category(id: 'drawing', name: L('Drawing', 'رسم'), icon: Icons.palette, color: Color(0xFF9A3412), tint: Color(0xFFFFEDD5)),
  const Category(id: 'piano', name: L('Piano', 'بيانو'), icon: Icons.piano, color: Color(0xFF5B21B6), tint: Color(0xFFEDE9FE)),
  const Category(id: 'chess', name: L('Chess', 'شطرنج'), icon: Icons.grid_on, color: Color(0xFF1F2937), tint: Color(0xFFE5E7EB)),
  const Category(id: 'karate', name: L('Karate', 'كاراتيه'), icon: Icons.sports_martial_arts, color: Color(0xFF991B1B), tint: Color(0xFFFEE2E2)),
  const Category(id: 'tennis', name: L('Tennis', 'تنس'), icon: Icons.sports_tennis, color: Color(0xFF854D0E), tint: Color(0xFFFEF9C3)),
  const Category(id: 'ballet', name: L('Ballet', 'باليه'), icon: Icons.accessibility_new, color: Color(0xFF9D174D), tint: Color(0xFFFCE7F3)),
];

const kDays = <String, L>{
  'sat': L('Sat', 'السبت'),
  'sun': L('Sun', 'الأحد'),
  'mon': L('Mon', 'الاثنين'),
  'tue': L('Tue', 'الثلاثاء'),
  'wed': L('Wed', 'الأربعاء'),
  'thu': L('Thu', 'الخميس'),
  'fri': L('Fri', 'الجمعة'),
};

const kTimes = <String, L>{
  'morning': L('Morning', 'صباحاً'),
  'afternoon': L('Afternoon', 'بعد الظهر'),
  'evening': L('Evening', 'مساءً'),
};

const kPlaces = <String, L>{
  'home': L('At home', 'في المنزل'),
  'venue': L("Trainer's venue", 'مكان المدرب'),
  'club': L('Sports club', 'نادٍ رياضي'),
};

Category categoryById(String id) {
  for (final c in kCategories) {
    if (c.id == id) return c;
  }
  return const Category(
      id: 'other', name: L('Other', 'أخرى'), icon: Icons.star_outline, color: Color(0xFF1E2A44), tint: Color(0xFFE5E7EB));
}
