import 'package:flutter/material.dart';

import '../app_state.dart';
import '../data/sample_data.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'results_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _openResults({String? categoryId, String query = ''}) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ResultsScreen(initialCategoryId: categoryId, query: query),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final top = app.trainers.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.star_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 10),
          Text(app.t('app'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
        ]),
        actions: const [LanguageButton()],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text(app.t('hello'), style: const TextStyle(color: AppColors.muted, fontSize: 14)),
          const SizedBox(height: 4),
          Text(app.t('homeTitle'), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, height: 1.3)),
          const SizedBox(height: 18),
          TextField(
            controller: _search,
            textInputAction: TextInputAction.search,
            onSubmitted: (q) => _openResults(query: q.trim()),
            decoration: InputDecoration(
              hintText: app.t('searchHint'),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () => _openResults(query: _search.text.trim()),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SectionTitle(app.t('activities')),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.85,
            children: [
              for (final c in kCategories)
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => _openResults(categoryId: c.id),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(color: c.tint, borderRadius: BorderRadius.circular(12)),
                          child: Icon(c.icon, color: c.color),
                        ),
                        const SizedBox(height: 8),
                        Text(app.text(c.name),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SectionTitle(app.t('topTrainers')),
              TextButton(onPressed: () => _openResults(), child: Text(app.t('seeAll'))),
            ],
          ),
          const SizedBox(height: 6),
          if (app.loading)
            const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()))
          else if (app.loadError != null)
            Column(children: [
              Text(app.t('loadError'), textAlign: TextAlign.center),
              const SizedBox(height: 10),
              OutlinedButton(onPressed: app.load, child: Text(app.t('retry'))),
            ])
          else if (top.isEmpty)
            Text(app.t('noTrainers'), style: const TextStyle(color: AppColors.muted))
          else
            for (final t in top) TrainerCard(trainer: t),
        ],
      ),
    );
  }
}
