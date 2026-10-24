import 'package:flutter/material.dart';

import '../app_state.dart';
import '../data/sample_data.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'rate_screen.dart';
import 'results_screen.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final cards = [
      for (final b in app.bookings)
        if (app.trainerById(b.trainerId) != null) _BookingCard(booking: b),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(app.t('myBookings')),
        actions: [
          IconButton(
            tooltip: app.t('pullToRefresh'),
            icon: const Icon(Icons.refresh),
            onPressed: () => _refresh(context),
          ),
          const LanguageButton(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refresh(context),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: cards.isEmpty
              ? [
                  Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Text(app.t('noBookings'), textAlign: TextAlign.center),
                  ),
                ]
              : cards,
        ),
      ),
    );
  }

  Future<void> _refresh(BuildContext context) async {
    final app = AppScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await app.refreshBookings();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(app.t('loadError'))));
    }
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;
  const _BookingCard({required this.booking});

  Future<void> _run(BuildContext context, Future<void> Function() action) async {
    final app = AppScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
    } catch (e) {
      debugPrint('Booking action failed: $e');
      messenger.showSnackBar(SnackBar(content: Text(app.t('saveError'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final b = booking;
    final trainer = app.trainerById(b.trainerId)!;
    final category = categoryById(trainer.categoryId);
    final separator = app.isArabic ? '، ' : ', ';
    final dayNames = b.days.where(kDays.containsKey).map((d) => app.text(kDays[d]!)).join(separator);
    final timeName = kTimes[b.timeOfDay] == null ? '' : app.text(kTimes[b.timeOfDay]!);
    final when = [dayNames, timeName].where((x) => x.isNotEmpty).join(' · ');
    final age = b.childAge == null ? '' : ' (${b.childAge} ${app.t('years')})';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: panelDecoration(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          TrainerAvatar(trainer: trainer, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(app.text(trainer.name), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              Text('${app.text(category.name)} · ${app.t('for')} ${b.childName}$age',
                  style: const TextStyle(fontSize: 13, color: AppColors.muted)),
            ]),
          ),
          StatusBadge(b.status),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.muted),
          const SizedBox(width: 6),
          Expanded(child: Text(when, style: const TextStyle(fontSize: 13))),
        ]),
        if (b.isPending) ...[
          const SizedBox(height: 10),
          Text(app.t('pendingNote'), style: const TextStyle(fontSize: 12, color: AppColors.muted)),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => _run(context, () => app.cancel(b.id)),
            child: Text(app.t('cancel')),
          ),
        ],
        if (b.status == BookingStatus.alternativeOffered) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              border: Border.all(color: const Color(0xFFFED7AA)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text('${app.t('proposedTime')}: ${b.alternativeTime ?? ''}', style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(44)),
                    onPressed: () => _run(context, () => app.respondToAlternative(b.id, true)),
                    child: Text(app.t('accept')),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _run(context, () => app.respondToAlternative(b.id, false)),
                    child: Text(app.t('decline')),
                  ),
                ),
              ]),
            ]),
          ),
        ],
        if (b.status == BookingStatus.confirmed && !b.rated) ...[
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => RateScreen(booking: b)),
            ),
            icon: const Icon(Icons.star_rounded, color: AppColors.star),
            label: Text(app.t('rateTrainer')),
          ),
        ],
        if (b.rated) ...[
          const SizedBox(height: 10),
          Text(app.t('rated'), style: const TextStyle(color: Color(0xFF166534), fontWeight: FontWeight.w500)),
        ],
        if (b.status == BookingStatus.declined) ...[
          const SizedBox(height: 10),
          Text(app.t('declinedNote'), style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ResultsScreen(initialCategoryId: trainer.categoryId)),
            ),
            child: Text(app.t('similar')),
          ),
        ],
      ]),
    );
  }
}
