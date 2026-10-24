import 'package:flutter_test/flutter_test.dart';

import 'package:tamreen/models.dart';
import 'package:tamreen/strings.dart';

void main() {
  test('Text exists in both languages', () {
    expect(tr('en', 'homeTitle'), 'Find a trainer for your child');
    expect(tr('ar', 'homeTitle'), 'ابحث عن مدرّب لطفلك');
  });

  test('Trainer reads a database row', () {
    final t = Trainer.fromMap({
      'id': 'sample-1',
      'name_en': 'Karim Adel',
      'name_ar': 'كريم عادل',
      'category_id': 'football',
      'rating': 4.9,
      'review_count': 3,
      'price_egp': 300,
      'slots': [
        {'day_en': 'Saturday', 'day_ar': 'السبت', 'hours_en': '4 – 8 pm', 'hours_ar': '4 – 8 م'}
      ],
      'areas': [
        {'en': 'Nasr City', 'ar': 'مدينة نصر'}
      ],
      'color': '#166534',
    });
    expect(t.name.get('ar'), 'كريم عادل');
    expect(t.slots.single.day.get('en'), 'Saturday');
    expect(t.pricePerSession, 300);
  });
}
