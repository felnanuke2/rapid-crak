import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../generated_l10n/app_localizations.dart';
import '../features/password_cracker/presentation/state/password_cracker_provider.dart';
import 'router.dart';

/// Classe principal do app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PasswordCrackerProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Quebra de Senha - Brute Force',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale.fromSubtags(languageCode: 'pt', countryCode: 'BR'),
        ],
        locale: const Locale('pt', 'BR'),
        home: Consumer<PasswordCrackerProvider>(
          builder: (context, provider, _) {
            return AppRouter(
              currentState: provider.state,
              hasLoadedFile: provider.hasLoadedFile,
              isAttackRunning: provider.isAttackRunning,
            );
          },
        ),
      ),
    );
  }
}
