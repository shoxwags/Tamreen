import 'package:flutter/material.dart';

import 'data/sample_data.dart';
import 'models.dart';
import 'strings.dart';

/// App-wide state: language, current tab and the parent's bookings.
/// Bookings are kept in memory for now; they move to Supabase in the next step.
class AppState extends ChangeNotifier {
  String lang = 'en';
  int tabIndex = 0;
  final List<Booking> bookings = sampleBookings();

  bool get isArabic => lang == 'ar';
  String t(String key) => tr(lang, key);
  String text(L value) => value.get(lang);

  String price(int egp) => isArabic ? '$egp ${t('currency')}' : '${t('currency')} $egp';

  void toggleLanguage() {
    lang = isArabic ? 'en' : 'ar';
    notifyListeners();
  }

  void setTab(int index) {
    tabIndex = index;
    notifyListeners();
  }

  void addBooking(Booking booking) {
    bookings.insert(0, booking);
    notifyListeners();
  }

  void _update(String id, void Function(Booking b) change) {
    final b = bookings.firstWhere((x) => x.id == id);
    change(b);
    notifyListeners();
  }

  void cancel(String id) => _update(id, (b) => b.status = BookingStatus.cancelled);

  void acceptAlternative(String id) => _update(id, (b) => b.status = BookingStatus.confirmed);

  void declineAlternative(String id) => _update(id, (b) => b.status = BookingStatus.cancelled);

  /// Demo only: what the operator's "Confirm" button will do from the dashboard.
  void simulateConfirm(String id) => _update(id, (b) => b.status = BookingStatus.confirmed);

  void markRated(String id) => _update(id, (b) => b.rated = true);
}

/// Makes [AppState] available to every screen: `AppScope.of(context)`.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
