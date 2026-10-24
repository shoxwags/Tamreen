import 'package:flutter/material.dart';

/// A piece of text in English and Arabic.
class L {
  final String en;
  final String ar;
  const L(this.en, this.ar);

  String get(String lang) => lang == 'ar' ? ar : en;
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
  final L text;
  const Review(this.author, this.stars, this.text);
}

class Trainer {
  final String id;
  final L name;
  final String categoryId;
  final L area;
  final double rating;
  final int reviewCount;
  final double distanceKm;
  final int pricePerSession; // EGP
  final int yearsExperience;
  final L ages;
  final L about;
  final List<Slot> slots;
  final List<L> areas;
  final List<Review> reviews;
  final Color color;

  const Trainer({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.area,
    required this.rating,
    required this.reviewCount,
    required this.distanceKm,
    required this.pricePerSession,
    required this.yearsExperience,
    required this.ages,
    required this.about,
    required this.slots,
    required this.areas,
    required this.reviews,
    required this.color,
  });
}

/// The same statuses the operator dashboard and the future trainer app use.
enum BookingStatus { newRequest, contacting, alternativeOffered, confirmed, declined, cancelled }

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
  L? alternativeTime;
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

  bool get isPending =>
      status == BookingStatus.newRequest || status == BookingStatus.contacting;
}
