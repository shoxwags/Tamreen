import 'package:flutter/material.dart';

import '../app_state.dart';
import '../data/sample_data.dart';
import '../models.dart';
import '../screens/trainer_profile_screen.dart';
import '../theme.dart';

String initials(String name) => name
    .split(' ')
    .where((p) => p.isNotEmpty)
    .take(2)
    .map((p) => p.characters.first)
    .join();

class TrainerAvatar extends StatelessWidget {
  final Trainer trainer;
  final double size;
  const TrainerAvatar({super.key, required this.trainer, this.size = 48});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: trainer.color,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Text(
        initials(app.text(trainer.name)),
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: size * 0.33),
      ),
    );
  }
}

class RatingLine extends StatelessWidget {
  final Trainer trainer;
  final bool showDistance;
  const RatingLine({super.key, required this.trainer, this.showDistance = true});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 16, color: AppColors.star),
        const SizedBox(width: 2),
        Text(trainer.rating.toStringAsFixed(1),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.navy)),
        const SizedBox(width: 4),
        Text('(${trainer.reviewCount})', style: const TextStyle(fontSize: 12, color: AppColors.muted)),
        if (showDistance) ...[
          const SizedBox(width: 8),
          Text('${trainer.distanceKm.toStringAsFixed(1)} ${app.t('km')}',
              style: const TextStyle(fontSize: 12, color: AppColors.muted)),
        ],
      ],
    );
  }
}

class TrainerCard extends StatelessWidget {
  final Trainer trainer;
  const TrainerCard({super.key, required this.trainer});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final category = categoryById(trainer.categoryId);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => TrainerProfileScreen(trainer: trainer)),
          ),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: panelDecoration().copyWith(color: Colors.transparent),
            child: Row(
              children: [
                TrainerAvatar(trainer: trainer),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(app.text(trainer.name),
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text('${app.text(category.name)} · ${app.text(trainer.area)}',
                          style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                      const SizedBox(height: 4),
                      RatingLine(trainer: trainer),
                    ],
                  ),
                ),
                Text(app.price(trainer.pricePerSession),
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) =>
      Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600));
}

/// Grey info panel with an icon (privacy notes, "no payment now", etc).
class InfoNote extends StatelessWidget {
  final IconData icon;
  final String text;
  const InfoNote({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.softPanel, borderRadius: BorderRadius.circular(14)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.navy),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, height: 1.5))),
        ],
      ),
    );
  }
}

class LanguageButton extends StatelessWidget {
  const LanguageButton({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: OutlinedButton(
        onPressed: app.toggleLanguage,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 40),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: const StadiumBorder(),
          backgroundColor: Colors.white,
        ),
        child: Tooltip(message: app.t('langTooltip'), child: Text(app.t('langButton'))),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final BookingStatus status;
  const StatusBadge(this.status, {super.key});

  static const _colors = <BookingStatus, (Color, Color)>{
    BookingStatus.newRequest: (Color(0xFFFEF3C7), Color(0xFF92400E)),
    BookingStatus.contacting: (Color(0xFFDBEAFE), Color(0xFF1E40AF)),
    BookingStatus.alternativeOffered: (Color(0xFFFFEDD5), Color(0xFF9A3412)),
    BookingStatus.confirmed: (Color(0xFFDCFCE7), Color(0xFF166534)),
    BookingStatus.declined: (Color(0xFFFEE2E2), Color(0xFF991B1B)),
    BookingStatus.cancelled: (Color(0xFFE5E7EB), Color(0xFF374151)),
  };

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final (bg, fg) = _colors[status]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(app.t('st_${status.name}'),
          style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
