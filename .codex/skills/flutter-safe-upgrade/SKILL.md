---
name: flutter-safe-upgrade
description: Safely upgrade a Flutter project to a newer stable SDK and compatible package set. Use when the user explicitly wants the upgrade performed, not just audited, and expects a conservative sequence with validation after each step.
---

# Flutter Safe Upgrade

## Goal

Perform a conservative Flutter SDK and dependency upgrade with validation. Prefer the smallest safe forward move that satisfies the user's goal. If blockers are high risk, stop and report instead of forcing the migration through.

## Preconditions

- The user has explicitly asked to perform the upgrade.
- Start from the Flutter app root.
- Read the environment first; do not upgrade blind.
- Treat current version data as time-sensitive and verify it from local tooling.

If the project is not ready for upgrade, stop and provide an audit report instead.

## Step 1 - Read Current State

Run:

```bash
flutter --version
dart --version
flutter pub outdated --no-dev-dependencies
```

Read the same files as the audit skill:

```text
pubspec.yaml
pubspec.lock
melos.yaml
.fvmrc
fvm_config.json
android/build.gradle*
android/gradle.properties
android/gradle/wrapper/gradle-wrapper.properties
ios/Podfile
analysis_options.yaml
```

Identify:

- Flutter/Dart baseline
- native Android/iOS tooling baseline
- packages likely to break

## Step 2 - Choose the Upgrade Target

Prefer one of these:

- latest stable Flutter if compatibility is straightforward
- otherwise the highest stable Flutter that avoids known blockers

Do not jump multiple toolchain layers at once unless necessary.

If the project uses FVM, follow the repo's FVM workflow instead of changing the global SDK.

## Step 3 - Upgrade in Safe Order

Typical order:

1. Flutter SDK / FVM version
2. AGP / Gradle / Kotlin if required by target Flutter
3. `pubspec.yaml` package constraints
4. `flutter pub upgrade --major-versions`
5. iOS pods if applicable

After changing package constraints, run:

```bash
flutter clean
flutter pub get
dart fix --apply
```

If iOS exists and pods are used:

```bash
cd ios && pod install
```

## Step 4 - Fix Breakages

Fix only what is necessary to restore compatibility:

- deprecated Flutter APIs
- removed plugin APIs
- AGP / Gradle / Kotlin mismatches
- namespace issues
- Android embedding issues
- obvious iOS Pod / deployment target issues

Do not:

- remove features to make the upgrade pass
- downgrade Flutter unless the blocker is real and documented
- leave analysis failures behind

## Step 5 - Validate

Run:

```bash
flutter analyze
flutter test
```

If the repo has relevant project-specific validation commands, run them too.

For Android/iOS native upgrades, prefer at least one platform-specific sanity check when feasible.

## Step 6 - Report

Include:

- old -> new Flutter version
- old -> new Dart version
- upgraded packages
- native tooling changes
- code changes made to restore compatibility
- remaining blockers or manual follow-up steps
- high-risk areas needing manual QA

## Output Shape

Use this structure:

```text
Upgrade result
- Flutter: old -> new
- Dart: old -> new

Packages upgraded
- ...

Native tooling changes
- ...

Code fixes applied
- ...

Validation
- flutter analyze: pass/fail
- flutter test: pass/fail
- other checks: ...

Follow-up
- ...
```

## Rules

- Be conservative. A smaller successful upgrade is better than a broad risky one.
- Validate after meaningful changes, not only at the end.
- If a package blocks the target SDK, say so and stop rather than forcing broken dependency overrides.
- Prefer project conventions over generic migration advice.
