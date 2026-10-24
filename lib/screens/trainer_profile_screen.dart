import 'package:flutter/material.dart';

import '../app_state.dart';
import '../data/sample_data.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'booking_screen.dart';

class TrainerProfileScreen extends StatelessWidget {
  final Trainer trainer;
  const TrainerProfileScreen({super.key, required this.trainer});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final category = categoryById(trainer.categoryId);

    Widget stat(String label, String value) => Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: panelDecoration(),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ]),
          ),
        );

    return Scaffold(
      appBar: AppBar(title: Text(app.t('trainerProfile')), actions: const [LanguageButton()]),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Row(children: [
            TrainerAvatar(trainer: trainer, size: 76),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(app.text(trainer.name), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('${app.text(category.name)} · ${app.text(trainer.area)}',
                    style: const TextStyle(color: AppColors.muted)),
                const SizedBox(height: 4),
                Row(children: [
                  RatingLine(trainer: trainer),
                  const SizedBox(width: 4),
                  Text(app.t('reviews'), style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                ]),
              ]),
            ),
          ]),
          const SizedBox(height: 14),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(999)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.verified_user_outlined, size: 16, color: Color(0xFF166534)),
                const SizedBox(width: 6),
                Text(app.t('approved'),
                    style: const TextStyle(color: Color(0xFF166534), fontSize: 12, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
          const SizedBox(height: 14),
          Row(children: [
            stat(app.t('price'), app.price(trainer.pricePerSession)),
            const SizedBox(width: 8),
            stat(app.t('ages'), app.text(trainer.ages)),
            const SizedBox(width: 8),
            stat(app.t('experience'), '${trainer.yearsExperience} ${app.t('years')}'),
          ]),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: panelDecoration(),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SectionTitle(app.t('about')),
              const SizedBox(height: 6),
              Text(app.text(trainer.about), style: const TextStyle(fontSize: 14, height: 1.6)),
            ]),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: panelDecoration(),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SectionTitle(app.t('availability')),
              const SizedBox(height: 6),
              for (final s in trainer.slots)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(app.text(s.day), style: const TextStyle(fontWeight: FontWeight.w500)),
                    Text(app.text(s.hours), style: const TextStyle(color: AppColors.muted)),
                  ]),
                ),
            ]),
          ),
          const SizedBox(height: 14),
          SectionTitle(app.t('areas')),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final a in trainer.areas)
              Chip(
                avatar: const Icon(Icons.place_outlined, size: 16, color: AppColors.accent),
                label: Text(app.text(a)),
                backgroundColor: Colors.white,
                side: const BorderSide(color: AppColors.border),
                shape: const StadiumBorder(),
              ),
          ]),
          const SizedBox(height: 14),
          InfoNote(icon: Icons.lock_outline, text: app.t('privacy')),
          const SizedBox(height: 18),
          SectionTitle(app.t('parentsSay')),
          const SizedBox(height: 8),
          _ReviewsSection(trainerId: trainer.id),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFECE9E2))),
          ),
          child: Row(children: [
            Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(app.price(trainer.pricePerSession),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              Text(app.t('perSession'), style: const TextStyle(fontSize: 12, color: AppColors.muted)),
            ]),
            const SizedBox(width: 14),
            Expanded(
              child: FilledButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => BookingScreen(trainer: trainer)),
                ),
                child: Text(app.t('requestBooking')),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _ReviewsSection extends StatefulWidget {
  final String trainerId;
  const _ReviewsSection({required this.trainerId});

  @override
  State<_ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<_ReviewsSection> {
  Future<List<Review>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= AppScope.of(context).repo.fetchReviews(widget.trainerId);
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return FutureBuilder<List<Review>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
        }
        final reviews = snap.data ?? const <Review>[];
        if (reviews.isEmpty) {
          return Text(app.t('noReviews'), style: const TextStyle(color: AppColors.muted));
        }
        return Column(children: [
          for (final r in reviews)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: panelDecoration(),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Expanded(child: Text(app.text(r.author), style: const TextStyle(fontWeight: FontWeight.w600))),
                  Row(children: [
                    for (var i = 1; i <= 5; i++)
                      Icon(i <= r.stars ? Icons.star_rounded : Icons.star_outline_rounded,
                          size: 16, color: AppColors.star),
                  ]),
                ]),
                if (r.text.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(r.text, style: const TextStyle(height: 1.5)),
                ],
                if (r.verified) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration:
                        BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(999)),
                    child: Text(app.t('verifiedBooking'),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF166534))),
                  ),
                ],
              ]),
            ),
        ]);
      },
    );
  }
}
