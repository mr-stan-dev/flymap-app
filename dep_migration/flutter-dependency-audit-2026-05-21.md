# Flutter Dependency Audit

Date: 2026-05-21
Project: `flymap-app`

Current state
- Plain Flutter setup, not FVM-managed: no `.fvmrc` or `fvm_config.json`.
- Project SDK constraint in `pubspec.yaml` is `sdk: ^3.8.1`, which already allows Dart 3.12.
- Installed locally: Flutter `3.38.9` / Dart `3.10.8`.
- Latest stable as of 2026-05-21: Flutter `3.44.0` / Dart `3.12.0` (released 2026-05-18).
- Android baseline is already modern: AGP `8.9.1`, Kotlin `2.1.0`, Gradle `8.12`, `compileSdk 36`, `targetSdk 36`, Java 11.
- `minSdk` is inherited from `flutter.minSdkVersion` rather than pinned in the app module.
- iOS baseline is modern: Podfile platform `15.6`, Runner target `15.6`, Swift `5.0`.
- This audit did not include full Android or iOS builds.

Safe upgrades
- Firebase family within current majors: `firebase_core 4.0.0 -> 4.9.0`, `firebase_analytics 12.0.0 -> 12.4.1`, `firebase_crashlytics 5.0.0 -> 5.2.2`, `cloud_functions 6.0.0 -> 6.3.1`.
- Low-risk direct updates: `equatable 2.0.7 -> 2.0.8`, `flutter_svg 2.2.4 -> 2.3.0`, `http 1.5.0 -> 1.6.0`, `in_app_review 2.0.11 -> 2.0.12`, `shared_preferences 2.5.3 -> 2.5.5`, `sqflite 2.4.2 -> 2.4.2+1`, `uuid 4.5.1 -> 4.5.3`.
- RevenueCat short-term safe step: `purchases_flutter 9.15.1 -> 9.16.1` and `purchases_ui_flutter 9.15.1 -> 9.16.1`.
- Already effectively current or close enough: `webview_flutter 4.13.1`, `path_provider 2.1.5`, `url_launcher 6.3.2`.
- Dev-only safe update: `build 4.0.5 -> 4.0.6`.

Breaking upgrades
- `maplibre_gl 0.25.0 -> 0.26.1`: highest-risk app dependency; broad usage across map screens and controllers.
- `go_router 14.8.1 -> 17.2.3`: central router migration surface.
- `flutter_bloc 8.1.6 -> 9.1.1`: large app-wide usage footprint.
- `get_it 7.7.0 -> 9.2.1`: likely mechanical but DI changes can ripple.
- `geolocator 10.1.1 -> 14.0.1`: affects live GPS flows.
- `purchases_flutter / purchases_ui_flutter 9.15.1 -> 10.1.1`: wrapped well locally, but still a major-version migration.
- `share_plus 10.1.4 -> 13.1.0`: limited usage surface, still a major bump.
- `package_info_plus 8.3.1 -> 10.1.0`: small local surface, but a major bump.
- `country_flags 3.3.0 -> 4.1.2`, `csv 5.1.1 -> 8.0.0`, `latlong2 0.9.1 -> 0.10.1`: smaller-surface semver-risky jumps.
- Dev breaking: `flutter_lints 5.0.0 -> 6.0.0`.

Blockers
- No hard blocker to moving from Flutter `3.38.9` to `3.44.0`.
- Android baseline already clears Flutter 3.44’s Kotlin requirement of `>= 2.0.0`.
- Dart constraint already admits `3.12.0`.
- Main practical blocker is dependency migration scope if everything is upgraded together.
- `minSdk` is inherited from Flutter instead of pinned, so a Flutter SDK move can change the effective Android floor.
- Solver gaps are minor: `geolocator` resolves to `14.0.1` while `14.0.2` exists, and `sembast` resolves to `3.8.6` while `3.8.7` exists.

Recommended target
- Flutter: `3.44.0`
- Dart: `3.12.0`

Upgrade plan
1. Upgrade Flutter only to `3.44.0`, keep native tooling as-is, regenerate packages, and verify `flutter analyze`, Android debug build, and an iOS simulator build.
2. Pin Android `minSdk` explicitly if device-floor stability matters.
3. Apply the safe dependency set first: Firebase family, `cloud_functions`, `flutter_svg`, `http`, `shared_preferences`, `sqflite`, `uuid`, `equatable`, `in_app_review`.
4. Take RevenueCat only to `9.16.1` first; leave `10.x` for a separate pass.
5. Upgrade `package_info_plus` and `share_plus` next.
6. Tackle `go_router`, `get_it`, `flutter_bloc`, and `geolocator` one at a time with validation after each.
7. Leave `maplibre_gl 0.26.x` for its own branch and validate Android map rendering early.
8. Do dev-only upgrades such as `flutter_lints` and `flutter_launcher_icons` last.

Risk assessment
- medium
- The Flutter SDK move itself looks straightforward. The primary risk is the number of major dependency jumps, especially `maplibre_gl`, `go_router`, `flutter_bloc`, `get_it`, and RevenueCat.

Sources
- Flutter SDK archive: <https://docs.flutter.dev/install/archive?tab=android>
- Flutter 3.44 release notes: <https://docs.flutter.dev/release/release-notes/release-notes-3.44.0>
- Flutter 3.44 Kotlin requirement note: <https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-plugin-authors>
- pub.dev package metadata:
  - <https://pub.dev/packages/maplibre_gl/versions>
  - <https://pub.dev/packages/purchases_flutter/versions>
  - <https://pub.dev/packages/share_plus/versions>
  - <https://pub.dev/packages/package_info_plus/versions>
  - <https://pub.dev/packages/geolocator/versions>
  - <https://pub.dev/packages/webview_flutter/versions>
