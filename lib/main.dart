import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_state.dart';
import 'screens/shell.dart';
import 'theme.dart';

void main() => runApp(const TamreenApp());

class TamreenApp extends StatefulWidget {
  const TamreenApp({super.key});

  @override
  State<TamreenApp> createState() => _TamreenAppState();
}

class _TamreenAppState extends State<TamreenApp> {
  final AppState _state = AppState();

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: _state,
      child: Builder(builder: (context) {
        final app = AppScope.of(context);
        return MaterialApp(
          title: 'Tamreen',
          debugShowCheckedModeBanner: false,
          theme: buildTheme(),
          // Switching to Arabic also flips the whole layout right-to-left.
          locale: Locale(app.lang),
          supportedLocales: const [Locale('en'), Locale('ar')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: const Shell(),
        );
      }),
    );
  }
}
