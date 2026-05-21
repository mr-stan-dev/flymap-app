import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flymap/data/local/airports_database.dart';
import 'package:flymap/domain/entity/user_profile.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/domain/entity/units.dart';
import 'package:flymap/repository/metric_units_repository.dart';
import 'package:flymap/repository/onboarding_repository.dart';
import 'package:flymap/repository/settings_repository.dart';
import 'package:flymap/utils/unit_format_utils.dart';

import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _settingsRepo;
  final MetricUnitsRepository _unitsRepo;
  final OnboardingRepository _onboardingRepository;
  final AirportsDatabase _airportsDb;
  SettingsCubit({
    required SettingsRepository repository,
    required MetricUnitsRepository unitsRepository,
    required OnboardingRepository onboardingRepository,
    required AirportsDatabase airportsDatabase,
  }) : _settingsRepo = repository,
       _unitsRepo = unitsRepository,
       _onboardingRepository = onboardingRepository,
       _airportsDb = airportsDatabase,
       super(const SettingsState());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    final theme = await _settingsRepo.getThemeMode();
    final altitude = await _unitsRepo.getAltitudeUnit();
    final speed = await _unitsRepo.getSpeedUnit();
    final time = await _unitsRepo.getTimeFormat();
    final distance = await _unitsRepo.getDistanceUnit();
    final dateDisplay = await _unitsRepo.getDateDisplayFormat();
    final temperature = await _unitsRepo.getTemperatureUnit();
    final localeSetting = await _settingsRepo.getLocaleSetting();
    final profile = await _onboardingRepository.getProfile();
    await _airportsDb.initialize();
    final homeAirportDisplayCode = _resolveHomeAirportDisplayCode(profile);

    emit(
      SettingsState(
        themeMode: theme,
        altitudeUnit: _formatAltitude(altitude),
        speedUnit: _formatSpeed(speed),
        timeFormat: _formatTime(time),
        distanceUnit: _formatDistance(distance),
        dateDisplayFormat: _formatDateDisplay(dateDisplay),
        temperatureUnit: _formatTemperature(temperature),
        localeSetting: localeSetting,
        profile: profile,
        homeAirportDisplayCode: homeAirportDisplayCode,
        isLoading: false,
      ),
    );
  }

  Future<void> setTheme(ThemeMode mode) async {
    emit(state.copyWith(themeMode: mode));
    await _settingsRepo.setThemeMode(mode);
  }

  Future<void> setAltitudeUnit(String unit) async {
    final enumUnit = unit == 'm' || unit == 'meter'
        ? AltitudeUnit.meter
        : AltitudeUnit.foot;
    emit(state.copyWith(altitudeUnit: unit));
    await _unitsRepo.setAltitudeUnit(enumUnit);
  }

  Future<void> setSpeedUnit(String unit) async {
    final enumUnit = unit == 'mph' ? SpeedUnit.mph : SpeedUnit.kmh;
    emit(state.copyWith(speedUnit: unit));
    await _unitsRepo.setSpeedUnit(enumUnit);
  }

  Future<void> setTimeFormat(String format) async {
    final enumFmt = format == '12h'
        ? TimeFormat.format12h
        : TimeFormat.format24h;
    emit(state.copyWith(timeFormat: format));
    await _unitsRepo.setTimeFormat(enumFmt);
  }

  Future<void> setDistanceUnit(String unit) async {
    final enumUnit = unit == 'mi' ? DistanceUnit.mile : DistanceUnit.km;
    emit(state.copyWith(distanceUnit: unit));
    await _unitsRepo.setDistanceUnit(enumUnit);
  }

  Future<void> setDateDisplayFormat(String format) async {
    final enumFormat = format == 'DD/MM/YYYY'
        ? DateDisplayFormat.international
        : DateDisplayFormat.us;
    emit(state.copyWith(dateDisplayFormat: format));
    await _unitsRepo.setDateDisplayFormat(enumFormat);
  }

  Future<void> setTemperatureUnit(String unit) async {
    final enumUnit = unit == '°F' || unit == 'F'
        ? TemperatureUnit.fahrenheit
        : TemperatureUnit.celsius;
    emit(state.copyWith(temperatureUnit: unit));
    await _unitsRepo.setTemperatureUnit(enumUnit);
  }

  Future<void> setLocaleSetting(String setting) async {
    emit(state.copyWith(localeSetting: setting));
    await _settingsRepo.setLocaleSetting(setting);
    if (setting == SettingsRepository.localeSystem) {
      await LocaleSettings.useDeviceLocale();
      return;
    }
    await LocaleSettings.setLocaleRaw(setting);
  }

  String _formatAltitude(AltitudeUnit u) => UnitFormatUtils.formatAltitude(u);
  String _formatSpeed(SpeedUnit u) => UnitFormatUtils.formatSpeed(u);
  String _formatTime(TimeFormat t) => UnitFormatUtils.formatTime(t);
  String _formatDistance(DistanceUnit u) =>
      UnitFormatUtils.formatDistanceUnit(u);
  String _formatDateDisplay(DateDisplayFormat f) =>
      UnitFormatUtils.formatDateDisplay(f);
  String _formatTemperature(TemperatureUnit u) =>
      UnitFormatUtils.formatTemperature(u);

  String? _resolveHomeAirportDisplayCode(UserProfile profile) {
    final code = profile.homeAirportCode;
    if (code == null || code.isEmpty) return null;
    final airport = _airportsDb.findByCode(code);
    return airport?.displayCode ?? code;
  }
}
