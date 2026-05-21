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
  required String initialSetting,
}) async {
  final cubit = context.read<SettingsCubit>();
  final deviceLanguageCode = AppLocalization.deviceSupportedLanguageCode;
  final options = _buildLanguageOptions(context, deviceLanguageCode);
  final initialLanguageCode = _effectiveLanguageCode(
    setting: initialSetting,
    deviceLanguageCode: deviceLanguageCode,
  );
  var selectedLanguageCode = initialLanguageCode;

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
                initialLanguageCode: initialLanguageCode,
                selectedLanguageCode: selectedLanguageCode,
                deviceLanguageCode: deviceLanguageCode,
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
                final isSelected = option.languageCode == selectedLanguageCode;
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
                      selectedLanguageCode = option.languageCode;
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

String _languageLabel(BuildContext context, String setting) {
  if (setting == SettingsRepository.localeSystem) {
    return _systemLanguageLabel(
      context,
      AppLocalization.deviceSupportedLanguageCode,
    );
  }
  return switch (setting) {
    SettingsRepository.localeEnglish => context.t.settings.languageEnglish,
    SettingsRepository.localeSpanish => context.t.settings.languageSpanish,
    _ => _systemLanguageLabel(
      context,
      AppLocalization.deviceSupportedLanguageCode,
    ),
  };
}

List<_LanguageChoiceOption> _buildLanguageOptions(
  BuildContext context,
  String deviceLanguageCode,
) {
  return [
    _LanguageChoiceOption(
      languageCode: SettingsRepository.localeEnglish,
      label: deviceLanguageCode == SettingsRepository.localeEnglish
          ? _systemLanguageLabel(context, SettingsRepository.localeEnglish)
          : context.t.settings.languageEnglish,
      flagCountryCode: 'GB',
    ),
    _LanguageChoiceOption(
      languageCode: SettingsRepository.localeSpanish,
      label: deviceLanguageCode == SettingsRepository.localeSpanish
          ? _systemLanguageLabel(context, SettingsRepository.localeSpanish)
          : context.t.settings.languageSpanish,
      flagCountryCode: 'ES',
    ),
  ];
}

String _resolveLocaleSettingForSelection({
  required String initialSetting,
  required String initialLanguageCode,
  required String selectedLanguageCode,
  required String deviceLanguageCode,
}) {
  if (selectedLanguageCode == initialLanguageCode) {
    return initialSetting;
  }
  if (selectedLanguageCode == deviceLanguageCode) {
    return SettingsRepository.localeSystem;
  }
  return selectedLanguageCode;
}

String _effectiveLanguageCode({
  required String setting,
  required String deviceLanguageCode,
}) {
  return switch (setting) {
    SettingsRepository.localeSpanish => SettingsRepository.localeSpanish,
    SettingsRepository.localeEnglish => SettingsRepository.localeEnglish,
    _ => deviceLanguageCode,
  };
}

String _systemLanguageLabel(BuildContext context, String languageCode) {
  final languageLabel = switch (languageCode) {
    SettingsRepository.localeSpanish => context.t.settings.languageSpanish,
    _ => context.t.settings.languageEnglish,
  };
  return context.t.settings.languageSystemFormat(language: languageLabel);
}

class _LanguageChoiceOption {
  const _LanguageChoiceOption({
    required this.languageCode,
    required this.label,
    required this.flagCountryCode,
  });

  final String languageCode;
  final String label;
  final String flagCountryCode;
}
