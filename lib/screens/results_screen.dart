import 'package:flutter/material.dart';

import '../app_state.dart';
import '../data/sample_data.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';

class ResultsScreen extends StatefulWidget {
  final String? initialCategoryId;
  final String query;
  const ResultsScreen({super.key, this.initialCategoryId, this.query = ''});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  String? _categoryId;
  late String _query;
  bool _topRated = false;
  bool _minRating = false;

  @override
  void initState() {
    super.initState();
    _categoryId = widget.initialCategoryId;
    _query = widget.query;
  }

  List<Trainer> _filtered() {
    final q = _query.toLowerCase();
    final list = kTrainers.where((t) {
      if (_categoryId != null && t.categoryId != _categoryId) return false;
      if (_minRating && t.rating < 4.5) return false;
      if (q.isEmpty) return true;
      final c = categoryById(t.categoryId);
      return [t.name.en, t.name.ar, t.area.en, t.area.ar, c.name.en, c.name.ar]
          .any((v) => v.toLowerCase().contains(q));
    }).toList();
    list.sort((a, b) => _topRated ? b.rating.compareTo(a.rating) : a.distanceKm.compareTo(b.distanceKm));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final results = _filtered();
    final String title;
    if (_categoryId != null) {
      final name = app.text(categoryById(_categoryId!).name);
      title = app.isArabic ? 'مدرّبو $name' : '$name ${app.t('trainersOf')}';
    } else if (_query.isNotEmpty) {
      title = '${app.t('resultsFor')} “$_query”';
    } else {
      title = app.t('allTrainers');
    }

    Widget chip(String label, bool selected, VoidCallback onTap) => Padding(
          padding: const EdgeInsetsDirectional.only(end: 8),
          child: ChoiceChip(
            label: Text(label),
            selected: selected,
            onSelected: (_) => onTap(),
            selectedColor: AppColors.navy,
            labelStyle: TextStyle(color: selected ? Colors.white : AppColors.navy, fontWeight: FontWeight.w500),
            showCheckmark: false,
            backgroundColor: Colors.white,
            side: const BorderSide(color: AppColors.border),
            shape: const StadiumBorder(),
          ),
        );

    return Scaffold(
      appBar: AppBar(title: Text(title), actions: const [LanguageButton()]),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text('${results.length} ${app.t('trainersOf')} ${app.t('available')}',
                style: const TextStyle(color: AppColors.muted, fontSize: 13)),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                chip(app.t('all'), _categoryId == null, () => setState(() => _categoryId = null)),
                for (final c in kCategories)
                  chip(app.text(c.name), _categoryId == c.id, () => setState(() => _categoryId = c.id)),
              ],
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                chip(app.t('nearest'), !_topRated, () => setState(() => _topRated = false)),
                chip(app.t('topRated'), _topRated, () => setState(() => _topRated = true)),
                chip(app.t('rating45'), _minRating, () => setState(() => _minRating = !_minRating)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(app.t('noResults'), style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(minimumSize: const Size(160, 44)),
                        onPressed: () => setState(() {
                          _categoryId = null;
                          _query = '';
                          _minRating = false;
                        }),
                        child: Text(app.t('clearFilters')),
                      ),
                    ]),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    children: [for (final t in results) TrainerCard(trainer: t)],
                  ),
          ),
        ],
      ),
    );
  }
}
