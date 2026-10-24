# Tamreen

Mobile app (Android and iPhone) that helps parents in Egypt find and book private trainers for their kids: sports, art, music, chess and more.

Built with **Flutter** (one codebase for both platforms). English by default, with an Arabic switch that flips the layout right-to-left.

## Phase 1 — what's in this version

- Home: search, activity tiles, trainers near you
- Results: filter by activity, sort by nearest or top rated, rating 4.5+ filter
- Trainer profile: rating, price, ages, experience, availability, areas, parent reviews (no contact details shown)
- Booking request form: child, preferred days/time, where, area, notes
- My bookings: every status (new, contacting, new time offered, confirmed, unavailable, cancelled), cancel, accept/decline a new time, rate after a confirmed booking
- Account: language switch

All trainers and bookings are **sample data** in `lib/data/sample_data.dart`. The next step connects the app to Supabase (real trainers, parent sign-in by phone number, bookings saved to the database for the operator dashboard).

## Run it on Windows

One-time setup: Git, VS Code with the Flutter extension, the Flutter SDK and Android Studio (`flutter doctor` should show green ticks for Flutter and Android toolchain).

```bat
cd C:\dev
git clone https://github.com/shoxwags/tamreen.git
cd tamreen
flutter create . --platforms=android,ios --org com.tamreen
flutter pub get
flutter run
```

`flutter create .` only adds the Android and iOS project folders; it does not overwrite the app code.
Connect an Android phone with USB debugging on (or start an emulator in Android Studio) before `flutter run`.

To get new versions later:

```bat
cd C:\dev\tamreen
git pull
flutter run
```

## Project structure

```
lib/
  main.dart                 app entry, language + right-to-left switching
  app_state.dart            language, current tab, bookings
  strings.dart              all interface text in English and Arabic
  models.dart               Trainer, Category, Booking, statuses
  theme.dart                colors and styles
  data/sample_data.dart     sample trainers and bookings (to be replaced by Supabase)
  widgets/common.dart       shared pieces: trainer card, avatar, status badge…
  screens/                  one file per screen
```
