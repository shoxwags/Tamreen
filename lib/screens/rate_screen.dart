import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// Only reachable from a confirmed booking, so every rating is from a real customer.
class RateScreen extends StatefulWidget {
  final Booking booking;
  const RateScreen({super.key, required this.booking});

  @override
  State<RateScreen> createState() => _RateScreenState();
}

class _RateScreenState extends State<RateScreen> {
  int _stars = 0;
  bool _showError = false;
  bool _sending = false;
  final _comment = TextEditingController();

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_sending) return;
    if (_stars == 0) {
      setState(() => _showError = true);
      return;
    }
    final app = AppScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _sending = true);
    try {
      await app.submitReview(widget.booking, _stars, _comment.text.trim());
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(app.t('reviewPublished'))));
    } catch (e) {
      debugPrint('Review failed: $e');
      messenger.showSnackBar(SnackBar(content: Text(app.t('saveError'))));
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final trainer = app.trainerById(widget.booking.trainerId);
    if (trainer == null) return const Scaffold();

    return Scaffold(
      appBar: AppBar(title: Text(app.t('rateTitle')), actions: const [LanguageButton()]),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Center(child: TrainerAvatar(trainer: trainer, size: 76)),
          const SizedBox(height: 16),
          Text('${app.t('howWas')} ${app.text(trainer.name)}?',
              textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 1; i <= 5; i++)
                IconButton(
                  iconSize: 38,
                  tooltip: '$i',
                  onPressed: () => setState(() {
                    _stars = i;
                    _showError = false;
                  }),
                  icon: Icon(i <= _stars ? Icons.star_rounded : Icons.star_outline_rounded, color: AppColors.star),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(app.t('yourReview'), style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _comment,
            minLines: 3,
            maxLines: 5,
            decoration: InputDecoration(hintText: app.t('reviewHint')),
          ),
          if (_showError) ...[
            const SizedBox(height: 12),
            Text(app.t('rateError'), style: const TextStyle(color: Color(0xFF991B1B), fontWeight: FontWeight.w500)),
          ],
          const SizedBox(height: 12),
          Text(app.t('rateNote'),
              textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: FilledButton(onPressed: _sending ? null : _submit, child: Text(app.t('submitReview'))),
        ),
      ),
    );
  }
}
