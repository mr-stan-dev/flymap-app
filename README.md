# flymap

Offline maps for flights

## Flutter SDK

This project should be run with `fvm` so the Flutter SDK version stays pinned per repo.

Install `fvm`:

```bash
brew install fvm
```

Initial project setup:

```bash
fvm use <flutter-version>
fvm flutter pub get
```

After `.fvmrc` is committed, a fresh clone can be set up with:

```bash
fvm install
fvm flutter pub get
```

Use `fvm`-prefixed commands for day-to-day work:

```bash
fvm flutter run
fvm flutter analyze
fvm flutter test
```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## UI Style Guard

Run the style guard before opening a PR:

```bash
bash tool/check_ui_style_guard.sh
```

Rules for `lib/ui` (outside approved exclusions):

- disallow `Colors.*`
- disallow `Color(0x...)`
- disallow `TextStyle(...)`

Use `ThemeData` (`colorScheme`, `textTheme`) and `lib/ui/design_system` widgets/tokens.

Detailed migration and usage guide:
- `docs/ui_design_system.md`
