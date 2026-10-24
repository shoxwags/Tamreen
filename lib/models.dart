import 'package:flutter/material.dart';

/// A piece of text in English and Arabic (falls back to the other language if one is empty).
class L {
  final String en;
  final String ar;
  const L(this.en, this.ar);

  String get(String lang) {
    if (lang == 'ar') return ar.isNotEmpty ? ar : en;
    return en.isNotEmpty ? en : ar;
  }
}

String _s(dynamic v) => v == null ? '' : v.toString();
int? _i(dynamic v) => v == null ? null : num.tryParse(v.toString())?.toInt();
double _d(dynamic v) => v == null ? 0 : (num.tryParse(v.toString())?.toDouble() ?? 0);
L _l(Map<String, dynamic> m, String key) => L(_s(m['${key}_en']), _s(m['${key}_ar']));

Color _color(dynamic hex) {
  final h = _s(hex).replaceAll('#', '');
  final v = int.tryParse(h.length == 6 ? 'FF$h' : h, radix: 16);
  return v == null ? const Color(0xFF1E2A44) : Color(v);
}

class Category {
  final String id;
  final L name;
  final IconData icon;
  final Color color;
  final Color tint;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.tint,
  });
}

class Slot {
  final L day;
  final L hours;
  const Slot(this.day, this.hours);
}

class Review {
  final L author;
  final int stars;
  final String text;
  final bool verified;
  const Review(this.author, this.stars, this.text, this.verified);

  factory Review.fromMap(Map<String, dynamic> m) => Review(
        _l(m, 'author_label'),
        _i(m['stars']) ?? 0,
        _s(m['comment']),
        m['booking_id'] != null,
      );
}

class Trainer {
  final String id;
  final L name;
  final String categoryId;
  final L area;
  final double rating;
  final int reviewCount;
  final int pricePerSession; // EGP
  final int yearsExperience;
  final L ages;
  final L about;
  final List<Slot> slots;
  final List<L> areas;
  final Color color;

  const Trainer({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.area,
    required this.rating,
    required this.reviewCount,
    required this.pricePerSession,
    required this.yearsExperience,
    required this.ages,
    required this.about,
    required this.slots,
    required this.areas,
    required this.color,
  });

  factory Trainer.fromMap(Map<String, dynamic> m) {
    final slots = <Slot>[];
    for (final e in (m['slots'] as List? ?? const [])) {
      final s = Map<String, dynamic>.from(e as Map);
      slots.add(Slot(L(_s(s['day_en']), _s(s['day_ar'])), L(_s(s['hours_en']), _s(s['hours_ar']))));
    }
    final areas = <L>[];
    for (final e in (m['areas'] as List? ?? const [])) {
      final a = Map<String, dynamic>.from(e as Map);
      areas.add(L(_s(a['en']), _s(a['ar'])));
    }
    return Trainer(
      id: _s(m['id']),
      name: _l(m, 'name'),
      categoryId: _s(m['category_id']),
      area: _l(m, 'area'),
      rating: _d(m['rating']),
      reviewCount: _i(m['review_count']) ?? 0,
      pricePerSession: _i(m['price_egp']) ?? 0,
      yearsExperience: _i(m['years_experience']) ?? 0,
      ages: _l(m, 'ages'),
      about: _l(m, 'about'),
      slots: slots,
      areas: areas,
      color: _color(m['color']),
    );
  }
}

/// The same statuses the operator dashboard and the future trainer mode use.
enum BookingStatus { newRequest, contacting, alternativeOffered, confirmed, declined, cancelled }

const _statusFromDb = {
  'new': BookingStatus.newRequest,
  'contacting': BookingStatus.contacting,
  'alternative_offered': BookingStatus.alternativeOffered,
  'confirmed': BookingStatus.confirmed,
  'declined': BookingStatus.declined,
  'cancelled': BookingStatus.cancelled,
};

class Booking {
  final String id;
  final String trainerId;
  final String childName;
  final int? childAge;
  final List<String> days; // keys from kDays
  final String timeOfDay; // key from kTimes
  final String place; // key from kPlaces
  final String area;
  final String notes;
  final DateTime createdAt;
  BookingStatus status;
  String? alternativeTime;
  bool rated;

  Booking({
    required this.id,
    required this.trainerId,
    required this.childName,
    required this.childAge,
    required this.days,
    required this.timeOfDay,
    required this.place,
    required this.area,
    required this.notes,
    required this.createdAt,
    this.status = BookingStatus.newRequest,
    this.alternativeTime,
    this.rated = false,
  });

  bool get isPending => status == BookingStatus.newRequest || status == BookingStatus.contacting;

  factory Booking.fromMap(Map<String, dynamic> m) {
    final review = m['reviews'];
    final alt = _s(m['alternative_time']);
    return Booking(
      id: _s(m['id']),
      trainerId: _s(m['trainer_id']),
      childName: _s(m['child_name']),
      childAge: _i(m['child_age']),
      days: (m['days'] as List? ?? const []).map((e) => e.toString()).toList(),
      timeOfDay: m['time_of_day'] == null ? 'evening' : _s(m['time_of_day']),
      place: m['place'] == null ? 'home' : _s(m['place']),
      area: _s(m['area']),
      notes: _s(m['notes']),
      createdAt: DateTime.tryParse(_s(m['created_at'])) ?? DateTime.now(),
      status: _statusFromDb[_s(m['status'])] ?? BookingStatus.newRequest,
      alternativeTime: alt.isEmpty ? null : alt,
      rated: review is List ? review.isNotEmpty : review != null,
    );
  }

  /// Fields a parent sends when creating a request.
  Map<String, dynamic> toInsertMap() => {
        'trainer_id': trainerId,
        'child_name': childName,
        'child_age': childAge,
        'days': days,
        'time_of_day': timeOfDay,
        'place': place,
        'area': area,
        'notes': notes,
      };
}
