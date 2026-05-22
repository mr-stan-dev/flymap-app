import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flymap/i18n/app_localization.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/repository/settings_repository.dart';
import 'package:flymap/ui/screens/settings/viewmodel/settings_cubit.dart';
import 'package:flymap/ui/screens/settings/viewmodel/settings_state.dart';

import 'setting_item.dart';
import 'settings_bottom_sheet.dart';

class LanguageSettingItem extends StatelessWidget {
  const LanguageSettingItem({required this.state, super.key});

  final SettingsState state;

  @override
  Widget build(BuildContext context) {
    return SettingItem(
      title: context.t.settings.language,
      subtitle: _languageLabel(context, state.localeSetting),
      leading: const Icon(Icons.language_rounded),
      onTap: () =>
          showLanguageSheet(context, initialSetting: state.localeSetting),
    );
  }
}

Future<void> showLanguageSheet(
  BuildContext context, {
  required LocaleSetting initialSetting,
}) async {
  final cubit = context.read<SettingsCubit>();
  final deviceLocaleSetting = AppLocalization.deviceSupportedLocaleSetting;
  final options = _buildLanguageOptions(context, deviceLocaleSetting);
  final initialLanguageSetting = _effectiveLanguageSetting(
    setting: initialSetting,
    deviceLocaleSetting: deviceLocaleSetting,
  );
  var selectedLanguageSetting = initialLanguageSetting;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return SettingsBottomSheet(
            title: context.t.settings.language,
            onConfirm: () async {
              final resolvedSetting = _resolveLocaleSettingForSelection(
                initialSetting: initialSetting,
                initialLanguageSetting: initialLanguageSetting,
                selectedLanguageSetting: selectedLanguageSetting,
                deviceLocaleSetting: deviceLocaleSetting,
              );
              if (resolvedSetting != initialSetting) {
                await cubit.setLocaleSetting(resolvedSetting);
              }
              if (ctx.mounted) {
                Navigator.of(ctx).pop();
              }
            },
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((option) {
                final isSelected =
                    option.localeSetting == selectedLanguageSetting;
                final theme = Theme.of(context);
                final colorScheme = theme.colorScheme;
                return ChoiceChip(
                  label: Text(
                    option.label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  avatar: Opacity(
                    opacity: 0.82,
                    child: CountryFlag.fromCountryCode(
                      option.flagCountryCode,
                      width: 18,
                      height: 18,
                      shape: const Circle(),
                    ),
                  ),
                  selected: isSelected,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  selectedColor: colorScheme.primary,
                  side: BorderSide(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.outline.withValues(alpha: 0.24),
                  ),
                  showCheckmark: false,
                  onSelected: (_) {
                    setModalState(() {
                      selectedLanguageSetting = option.localeSetting;
                    });
                  },
                );
              }).toList(),
            ),
          );
        },
      );
    },
  );
}

String _languageLabel(BuildContext context, LocaleSetting setting) {
  if (setting == LocaleSetting.system) {
    return _systemLanguageLabel(
      context,
      AppLocalization.deviceSupportedLocaleSetting,
    );
  }
  return switch (setting) {
    LocaleSetting.english => context.t.settings.languageEnglish,
    LocaleSetting.spanish => context.t.settings.languageSpanish,
    LocaleSetting.french => context.t.settings.languageFrench,
    LocaleSetting.german => context.t.settings.languageGerman,
    LocaleSetting.system => _systemLanguageLabel(
      context,
      AppLocalization.deviceSupportedLocaleSetting,
    ),
  };
}

List<_LanguageChoiceOption> _buildLanguageOptions(
  BuildContext context,
  LocaleSetting deviceLocaleSetting,
) {
  return [
    _LanguageChoiceOption(
      localeSetting: LocaleSetting.english,
      label: deviceLocaleSetting == LocaleSetting.english
          ? _systemLanguageLabel(context, LocaleSetting.english)
          : context.t.settings.languageEnglish,
      flagCountryCode: 'GB',
    ),
    _LanguageChoiceOption(
      localeSetting: LocaleSetting.spanish,
      label: deviceLocaleSetting == LocaleSetting.spanish
          ? _systemLanguageLabel(context, LocaleSetting.spanish)
          : context.t.settings.languageSpanish,
      flagCountryCode: 'ES',
    ),
    _LanguageChoiceOption(
      localeSetting: LocaleSetting.french,
      label: deviceLocaleSetting == LocaleSetting.french
          ? _systemLanguageLabel(context, LocaleSetting.french)
          : context.t.settings.languageFrench,
      flagCountryCode: 'FR',
    ),
    _LanguageChoiceOption(
      localeSetting: LocaleSetting.german,
      label: deviceLocaleSetting == LocaleSetting.german
          ? _systemLanguageLabel(context, LocaleSetting.german)
          : context.t.settings.languageGerman,
      flagCountryCode: 'DE',
    ),
  ];
}

LocaleSetting _resolveLocaleSettingForSelection({
  required LocaleSetting initialSetting,
  required LocaleSetting initialLanguageSetting,
  required LocaleSetting selectedLanguageSetting,
  required LocaleSetting deviceLocaleSetting,
}) {
  if (selectedLanguageSetting == initialLanguageSetting) {
    return initialSetting;
  }
  if (selectedLanguageSetting == deviceLocaleSetting) {
    return LocaleSetting.system;
  }
  return selectedLanguageSetting;
}

LocaleSetting _effectiveLanguageSetting({
  required LocaleSetting setting,
  required LocaleSetting deviceLocaleSetting,
}) {
  return switch (setting) {
    LocaleSetting.system => deviceLocaleSetting,
    LocaleSetting.english => LocaleSetting.english,
    LocaleSetting.spanish => LocaleSetting.spanish,
    LocaleSetting.french => LocaleSetting.french,
    LocaleSetting.german => LocaleSetting.german,
  };
}

String _systemLanguageLabel(BuildContext context, LocaleSetting localeSetting) {
  final languageLabel = switch (localeSetting) {
    LocaleSetting.spanish => context.t.settings.languageSpanish,
    LocaleSetting.french => context.t.settings.languageFrench,
    LocaleSetting.german => context.t.settings.languageGerman,
    _ => context.t.settings.languageEnglish,
  };
  return context.t.settings.languageSystemFormat(language: languageLabel);
}

class _LanguageChoiceOption {
  const _LanguageChoiceOption({
    required this.localeSetting,
    required this.label,
    required this.flagCountryCode,
  });

  final LocaleSetting localeSetting;
  final String label;
  final String flagCountryCode;
}
