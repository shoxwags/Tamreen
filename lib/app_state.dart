import 'package:flutter/material.dart';

import 'data/repository.dart';
import 'models.dart';
import 'strings.dart';

/// App-wide state: language, current tab, trainers and the parent's bookings.
class AppState extends ChangeNotifier {
  final Repository repo = Repository();

  String lang = 'en';
  int tabIndex = 0;
  List<Trainer> trainers = [];
  List<Booking> bookings = [];
  bool loading = true;
  String? loadError;

  bool get isArabic => lang == 'ar';
  String t(String key) => tr(lang, key);
  String text(L value) => value.get(lang);

  String price(int egp) => isArabic ? '$egp ${t('currency')}' : '${t('currency')} $egp';

  Trainer? trainerById(String id) {
    for (final tr in trainers) {
      if (tr.id == id) return tr;
    }
    return null;
  }

  /// Loads everything from the database. Called at start-up and on "Try again".
  Future<void> load() async {
    loading = true;
    loadError = null;
    notifyListeners();
    try {
      trainers = await repo.fetchTrainers();
      try {
        await repo.ensureSignedIn();
        bookings = await repo.fetchMyBookings();
      } catch (e) {
        // Browsing still works if sign-in fails; booking will show the error.
        debugPrint('Sign-in or bookings failed: $e');
      }
    } catch (e) {
      loadError = e.toString();
    }
    loading = false;
    notifyListeners();
  }

  Future<void> refreshBookings() async {
    await repo.ensureSignedIn();
    bookings = await repo.fetchMyBookings();
    notifyListeners();
  }

  void toggleLanguage() {
    lang = isArabic ? 'en' : 'ar';
    notifyListeners();
  }

  void setTab(int index) {
    tabIndex = index;
    notifyListeners();
  }

  Future<void> addBooking(Booking draft) async {
    await repo.ensureSignedIn();
    final saved = await repo.createBooking(draft);
    bookings.insert(0, saved);
    notifyListeners();
  }

  Future<void> cancel(String id) async {
    await repo.cancelBooking(id);
    await refreshBookings();
  }

  Future<void> respondToAlternative(String id, bool accept) async {
    await repo.respondToAlternative(id, accept);
    await refreshBookings();
  }

  Future<void> submitReview(Booking booking, int stars, String comment) async {
    await repo.addReview(booking: booking, stars: stars, comment: comment);
    booking.rated = true;
    trainers = await repo.fetchTrainers();
    notifyListeners();
  }
}

/// Makes [AppState] available to every screen: `AppScope.of(context)`.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
