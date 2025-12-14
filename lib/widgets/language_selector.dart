import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bodyecho/l10n/app_localizations.dart';
import '../services/locale_provider.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final l10n = AppLocalizations.of(context)!;

    return PopupMenuButton<Locale>(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.language, size: 20),
          const SizedBox(width: 4),
          Text(
            localeProvider.locale.languageCode.toUpperCase(),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
      onSelected: (Locale locale) {
        localeProvider.setLocale(locale);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
        PopupMenuItem<Locale>(
          value: const Locale('tr'),
          child: Row(
            children: [
              if (localeProvider.locale.languageCode == 'tr')
                const Icon(Icons.check, size: 20),
              if (localeProvider.locale.languageCode == 'tr')
                const SizedBox(width: 8),
              Text(l10n.turkish),
            ],
          ),
        ),
        PopupMenuItem<Locale>(
          value: const Locale('en'),
          child: Row(
            children: [
              if (localeProvider.locale.languageCode == 'en')
                const Icon(Icons.check, size: 20),
              if (localeProvider.locale.languageCode == 'en')
                const SizedBox(width: 8),
              Text(l10n.english),
            ],
          ),
        ),
      ],
    );
  }
}
