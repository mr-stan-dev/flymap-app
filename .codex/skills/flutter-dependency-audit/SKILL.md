---
name: flutter-dependency-audit
description: Audit a Flutter project for dependency and SDK upgrade readiness. Use when the user wants to assess migration to the latest stable Flutter, review package blockers, inspect Android/iOS toolchain compatibility, or produce a safe upgrade plan without making changes yet.
---

# Flutter Dependency Audit

## Goal

Assess a Flutter project's readiness for upgrade and produce a concrete migration plan. Default to audit-only. Do not change SDKs, package versions, or native tooling unless the user explicitly asks for the upgrade to be performed.

## Scope

- Work from the Flutter app root.
- Read the current project config first.
- Treat version advice as time-sensitive: verify current package and SDK versions from local tooling and official package metadata when available.
- Prefer official Flutter docs, pub.dev package metadata, and primary package docs/issues for blockers.
- Save every audit as a new dated Markdown report under `dep_migration/` at the app root. Use a filename like `flutter-dependency-audit-YYYY-MM-DD.md`. If that filename already exists, append `-2`, `-3`, and so on instead of overwriting.

## Step 1 - Detect Current Environment

Run:

```bash
flutter --version
dart --version
```

Read, when present:

```text
pubspec.yaml
pubspec.lock
melos.yaml
.fvmrc
fvm_config.json
android/build.gradle
android/build.gradle.kts
android/app/build.gradle
android/app/build.gradle.kts
android/gradle.properties
android/gradle/wrapper/gradle-wrapper.properties
ios/Podfile
ios/Runner.xcodeproj/project.pbxproj
analysis_options.yaml
```

Determine:

- current Flutter version
- current Dart version
- Dart SDK constraints
- whether FVM is used
- Android Gradle Plugin version
- Gradle wrapper version
- Kotlin version
- Java source/target compatibility
- `compileSdk`, `targetSdk`, `minSdk`
- iOS deployment target
- Swift / Xcode-related constraints if obvious from project files

## Step 2 - Check Latest Stable Flutter

If the project uses plain Flutter:

```bash
flutter channel stable
flutter --version
```

If the project uses FVM:

```bash
fvm releases
```

Do not upgrade yet.

Determine:

- latest stable Flutter line
- corresponding Dart line
- whether the project can plausibly move there without native-tooling changes

## Step 3 - Audit Dependencies

Run:

```bash
flutter pub outdated --no-dev-dependencies
flutter pub outdated
```

Categorize packages into:

- safe upgrades
  - compatible with current or target Flutter
  - no obvious migration risk
- breaking upgrades
  - major version bump
  - migration likely required
- blockers
  - incompatible SDK constraints
  - abandoned/discontinued package
  - native Android/iOS incompatibility
  - transitive conflict that blocks target Flutter

Pay special attention to:

- `maplibre_*` / map SDKs
- `firebase_*`
- `purchases_flutter` / RevenueCat
- `webview_flutter`
- `shared_preferences`, `path_provider`, `url_launcher`
- code generation packages
- packages with Android/iOS native code

## Step 4 - Check Native Tooling Compatibility

Verify Android:

- `compileSdk`
- `targetSdk`
- AGP version
- Gradle version
- Kotlin version
- Java compatibility
- namespace migration status

Verify iOS:

- deployment target
- Podfile platform target
- obvious Pod conflicts
- Swift version assumptions if present

Flag mismatches between target Flutter and native tooling.

## Step 5 - Produce Upgrade Plan

Produce:

- current Flutter/Dart/tooling summary
- recommended target Flutter version
- recommended target Dart version
- package upgrade order
- native tooling updates required first
- expected migration hotspots
- blockers and suggested replacements or mitigations

If the risk is high, stop at the report and say so explicitly.

## Output Shape

Use this structure:

```text
Current state
- ...

Safe upgrades
- ...

Breaking upgrades
- ...

Blockers
- ...

Recommended target
- Flutter: ...
- Dart: ...

Upgrade plan
1. ...
2. ...

Risk assessment
- low | medium | high
- Why.
```

Also:

- Write the report to `dep_migration/flutter-dependency-audit-YYYY-MM-DD.md` before finishing.
- Return the same findings in chat, plus the saved report path.

## Rules

- Default to report-only.
- Do not hand-wave package compatibility. Cite the local version and the target version you are discussing.
- Prefer primary sources for unstable facts.
- Call out when a recommended Flutter upgrade also implies AGP/Gradle/Kotlin/iOS target work.
- If a package is the real blocker, say that plainly rather than proposing a risky broad upgrade.
- Do not overwrite a previous audit report for the same date; create a new suffixed file instead.
