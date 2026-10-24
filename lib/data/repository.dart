import 'package:supabase_flutter/supabase_flutter.dart';

import '../models.dart';

/// Everything the app reads from and writes to the Supabase database.
class Repository {
  SupabaseClient get _db => Supabase.instance.client;

  /// Until phone-number sign-in is added, each phone gets an anonymous account
  /// so its bookings stay private to it.
  Future<void> ensureSignedIn() async {
    if (_db.auth.currentSession == null) {
      await _db.auth.signInAnonymously();
    }
  }

  Future<List<Trainer>> fetchTrainers() async {
    final rows = await _db.from('trainer_cards').select().order('rating', ascending: false);
    return rows.map((r) => Trainer.fromMap(r)).toList();
  }

  Future<List<Review>> fetchReviews(String trainerId) async {
    final rows = await _db
        .from('reviews')
        .select()
        .eq('trainer_id', trainerId)
        .order('created_at', ascending: false)
        .limit(20);
    return rows.map((r) => Review.fromMap(r)).toList();
  }

  Future<List<Booking>> fetchMyBookings() async {
    if (_db.auth.currentSession == null) return [];
    final rows = await _db.from('bookings').select('*, reviews(id)').order('created_at', ascending: false);
    return rows.map((r) => Booking.fromMap(r)).toList();
  }

  Future<Booking> createBooking(Booking draft) async {
    final row = await _db.from('bookings').insert(draft.toInsertMap()).select('*, reviews(id)').single();
    return Booking.fromMap(row);
  }

  Future<void> cancelBooking(String bookingId) async {
    await _db.rpc('cancel_booking', params: {'p_booking_id': bookingId});
  }

  Future<void> respondToAlternative(String bookingId, bool accept) async {
    await _db.rpc('respond_to_alternative', params: {'p_booking_id': bookingId, 'p_accept': accept});
  }

  Future<void> addReview({
    required Booking booking,
    required int stars,
    required String comment,
  }) async {
    await _db.from('reviews').insert({
      'trainer_id': booking.trainerId,
      'booking_id': booking.id,
      'author_id': _db.auth.currentUser?.id,
      'author_label_en': "${booking.childName}'s parent",
      'author_label_ar': 'ولي أمر ${booking.childName}',
      'stars': stars,
      'comment': comment,
    });
  }
}
