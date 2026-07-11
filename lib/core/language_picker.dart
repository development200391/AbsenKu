import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'locale_controller.dart';

/// Shows a dialog letting the user pick the app's language, independent of
/// the device's system language. Language names are shown in their own
/// language (not translated), matching how language pickers usually read.
Future<void> showLanguagePicker(BuildContext context, LocaleController localeController) {
  final l10n = AppLocalizations.of(context)!;

  return showDialog<void>(
    context: context,
    builder: (context) {
      return SimpleDialog(
        title: Text(l10n.chooseLanguageTitle),
        children: [
          _LanguageOption(
            label: l10n.systemDefaultLanguage,
            selected: localeController.locale == null,
            onTap: () {
              localeController.setLocale(null);
              Navigator.of(context).pop();
            },
          ),
          _LanguageOption(
            label: 'Bahasa Indonesia',
            selected: localeController.locale?.languageCode == 'id',
            onTap: () {
              localeController.setLocale(const Locale('id'));
              Navigator.of(context).pop();
            },
          ),
          _LanguageOption(
            label: 'English',
            selected: localeController.locale?.languageCode == 'en',
            onTap: () {
              localeController.setLocale(const Locale('en'));
              Navigator.of(context).pop();
            },
          ),
          _LanguageOption(
            label: '日本語',
            selected: localeController.locale?.languageCode == 'ja',
            onTap: () {
              localeController.setLocale(const Locale('ja'));
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SimpleDialogOption(
      onPressed: onTap,
      child: Row(
        children: [
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
            color: selected ? Theme.of(context).colorScheme.primary : null,
          ),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }
}
