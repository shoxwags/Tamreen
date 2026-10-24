import 'package:flutter/material.dart';

import '../app_state.dart';
import '../data/sample_data.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';

class BookingScreen extends StatefulWidget {
  final Trainer trainer;
  const BookingScreen({super.key, required this.trainer});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _childName = TextEditingController();
  final _childAge = TextEditingController();
  final _area = TextEditingController();
  final _notes = TextEditingController();
  final Set<String> _days = {};
  String _time = 'evening';
  String _place = 'home';
  bool _showError = false;

  @override
  void dispose() {
    _childName.dispose();
    _childAge.dispose();
    _area.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _submit() {
    if (_childName.text.trim().isEmpty || _days.isEmpty) {
      setState(() => _showError = true);
      return;
    }
    final app = AppScope.of(context);
    app.addBooking(Booking(
      id: 'b${DateTime.now().millisecondsSinceEpoch}',
      trainerId: widget.trainer.id,
      childName: _childName.text.trim(),
      childAge: int.tryParse(_childAge.text.trim()),
      // Keep the days in week order, not tap order.
      days: kDays.keys.where(_days.contains).toList(),
      timeOfDay: _time,
      place: _place,
      area: _area.text.trim(),
      notes: _notes.text.trim(),
      createdAt: DateTime.now(),
    ));
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const RequestSentScreen()));
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      );

  Widget _chip(String label, bool selected, VoidCallback onTap) => ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.navy,
        labelStyle: TextStyle(color: selected ? Colors.white : AppColors.navy, fontWeight: FontWeight.w500),
        showCheckmark: false,
        backgroundColor: Colors.white,
        side: const BorderSide(color: AppColors.border),
        shape: const StadiumBorder(),
      );

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = widget.trainer;

    return Scaffold(
      appBar: AppBar(title: Text(app.t('bookingRequest')), actions: const [LanguageButton()]),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: panelDecoration(),
            child: Row(children: [
              TrainerAvatar(trainer: t),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(app.text(t.name), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  Text(
                      '${app.text(categoryById(t.categoryId).name)} · ${app.price(t.pricePerSession)} ${app.t('perSession')}',
                      style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 20),
          _label(app.t('childName')),
          TextField(
            controller: _childName,
            textCapitalization: TextCapitalization.words,
            onChanged: (_) => setState(() => _showError = false),
            decoration: InputDecoration(hintText: app.t('childNameHint')),
          ),
          const SizedBox(height: 16),
          _label(app.t('childAge')),
          TextField(
            controller: _childAge,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: app.t('childAgeHint')),
          ),
          const SizedBox(height: 16),
          _label(app.t('prefDays')),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final e in kDays.entries)
              _chip(app.text(e.value), _days.contains(e.key), () {
                setState(() {
                  _showError = false;
                  _days.contains(e.key) ? _days.remove(e.key) : _days.add(e.key);
                });
              }),
          ]),
          const SizedBox(height: 16),
          _label(app.t('prefTime')),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final e in kTimes.entries)
              _chip(app.text(e.value), _time == e.key, () => setState(() => _time = e.key)),
          ]),
          const SizedBox(height: 16),
          _label(app.t('where')),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final e in kPlaces.entries)
              _chip(app.text(e.value), _place == e.key, () => setState(() => _place = e.key)),
          ]),
          const SizedBox(height: 16),
          _label(app.t('area')),
          TextField(controller: _area, decoration: InputDecoration(hintText: app.t('areaHint'))),
          const SizedBox(height: 16),
          _label(app.t('notes')),
          TextField(
            controller: _notes,
            minLines: 3,
            maxLines: 5,
            decoration: InputDecoration(hintText: app.t('notesHint')),
          ),
          if (_showError) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(12)),
              child: Text(app.t('formError'),
                  style: const TextStyle(color: Color(0xFF991B1B), fontWeight: FontWeight.w500)),
            ),
          ],
          const SizedBox(height: 16),
          InfoNote(icon: Icons.schedule, text: app.t('noPayment')),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: FilledButton(onPressed: _submit, child: Text(app.t('send'))),
        ),
      ),
    );
  }
}

class RequestSentScreen extends StatelessWidget {
  const RequestSentScreen({super.key});

  void _goTab(BuildContext context, int tab) {
    AppScope.of(context).setTab(tab);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: const BoxDecoration(color: Color(0xFFDCFCE7), shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, size: 44, color: Color(0xFF166534)),
              ),
              const SizedBox(height: 20),
              Text(app.t('sentTitle'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Text(app.t('sentBody'),
                  textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, height: 1.6)),
              const SizedBox(height: 28),
              FilledButton(onPressed: () => _goTab(context, 1), child: Text(app.t('viewBookings'))),
              const SizedBox(height: 10),
              OutlinedButton(onPressed: () => _goTab(context, 0), child: Text(app.t('backHome'))),
            ],
          ),
        ),
      ),
    );
  }
}
