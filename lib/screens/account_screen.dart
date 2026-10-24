import 'package:flutter/material.dart';

import '../app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);

    Widget panel(Widget child) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: panelDecoration(),
          child: child,
        );

    return Scaffold(
      appBar: AppBar(title: Text(app.t('account')), actions: const [LanguageButton()]),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          panel(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(app.t('parentName'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 4),
            const Text('+20 1X XXXX XXXX',
                textDirection: TextDirection.ltr, style: TextStyle(color: AppColors.muted)),
          ])),
          panel(Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            SectionTitle(app.t('myChildren')),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: Text(app.t('addChild')),
            ),
          ])),
          panel(Row(children: [
            Expanded(child: Text(app.t('language'), style: const TextStyle(fontWeight: FontWeight.w500))),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'en', label: Text('English')),
                ButtonSegment(value: 'ar', label: Text('العربية')),
              ],
              selected: {app.lang},
              showSelectedIcon: false,
              onSelectionChanged: (s) {
                if (s.first != app.lang) app.toggleLanguage();
              },
            ),
          ])),
          panel(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(app.t('help'), style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(app.t('helpBody'), style: const TextStyle(color: AppColors.muted, fontSize: 13)),
          ])),
        ],
      ),
    );
  }
}
