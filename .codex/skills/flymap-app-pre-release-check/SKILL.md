---
name: flymap-app-pre-release-check
description: Review the Flymap Flutter app before release by comparing the current worktree or HEAD to the most recent reachable git tag, then report major concerns, mobile release blockers, security exposures, Flymap-specific regressions, privacy/config issues, and missing validation. Use when the user asks for a Flymap app pre-release check, Flutter/mobile ship review for this repo, app-store readiness review, or a focused review of flymap-app changes since the last tag.
---

# Flymap App Pre Release Check

## Overview

Review `flymap-app` with a code-review stance tuned for this repository. Focus on regressions in flight lookup, map/offline behavior, share/export flows, subscriptions, analytics/privacy, and Android/iOS release configuration. Produce a brief report, not a patch, unless the user explicitly asks for fixes.

## Scope

- Work from the `flymap-app` repository root.
- Compare against the most recent reachable git tag.
- If no tag exists, fall back to the root commit and say that explicitly.
- Run `bash .codex/skills/flymap-app-pre-release-check/scripts/release_scope.sh` first.

## High-Risk Areas In This Repo

- `lib/data/api`, `lib/repository`, `lib/domain/usecase`
  - flight lookup, route preview, backend contract, cache semantics
- `lib/data/local`, `lib/data/cache`, `lib/data/tiles_downloader`
  - offline storage, Sembast/MBTiles consistency, long-running downloads
- `lib/ui/map`, `lib/ui/screens`, `lib/ui/widgets`
  - map rendering, controller lifecycle, route/region presentation, crash-prone UI state
- `lib/subscription`, `lib/rating`, `lib/analytics`, `lib/crashlytics`, `lib/feedback`
  - privacy, purchase gating, prompt timing, telemetry regressions
- `android/`, `ios/`
  - permissions, plist/manifest, entitlements, build config, URL schemes, SDK wiring
- `pubspec.yaml`, `assets/`, `lib/i18n`
  - asset drift, generated files, localization/build issues

## Flymap-Specific Review Workflow

1. Establish release scope.
   - Run the scope script.
   - Read `pubspec.yaml` and the changed file list first.
   - Group changes by risk: backend contract/API, offline maps, share/export, subscription/paywall, analytics/privacy, permissions/platform config, and user-visible map flows.

2. Review the highest-risk files first.
   - Any change under `lib/data/api`, `lib/repository`, `lib/domain/usecase`
   - Any change under `lib/data/local`, `lib/data/cache`, `lib/data/tiles_downloader`
   - Any change under `android/` or `ios/`
   - Any config or asset declaration changes in `pubspec.yaml`

3. Prioritize findings in this order.
   - Security and privacy:
     - tracked secrets, keys, tokens, service credentials
     - logging of identifiers, routes, or other sensitive data
     - analytics/crash reporting changes without clear gating
     - permissive webview/deep-link handling
   - Release blockers:
     - startup crashes, navigation dead ends, broken map initialization
     - offline map or cached flight corruption/regression
     - backend contract mismatch with current call sites
     - share/export failures, missing assets, broken font/resource loading
     - purchase/subscription flow regressions
     - missing Android/iOS permission or privacy string updates for changed behavior
   - Important improvements:
     - missing tests around risky use cases, mappers, or cubit flows
     - missing `flutter analyze`, `flutter test`, or build verification
     - weak error handling around downloads, map setup, purchases, or network retries

4. Cross-check against repo conventions.
   - Use `.cursor/rules/rules.mdc` as the repo-specific architecture baseline.
   - Flag new business logic in widgets, repositories doing too much, raw map/JSON leakage beyond mappers, or DI violations when they materially increase release risk.

5. Validate with targeted evidence.
   - Prefer changed code, tests, manifests, plist files, entitlements, and config readers over broad speculation.
   - For platform concerns, verify both Dart and native config.
   - If a concern depends on runtime behavior, say that explicitly.

## Flymap-Specific Checklist

- Verify flight lookup / route preview changes do not break cached or historical flows.
- Verify map/offline changes preserve download integrity and do not weaken failure handling.
- Check share/export paths for missing assets, font assumptions, and file-write failure handling.
- Review changes touching subscriptions, rating prompts, analytics, or crashlytics for privacy and UX regressions.
- Check map/location permissions, background modes, and privacy copy for consistency with behavior.
- Check that new assets are declared in `pubspec.yaml` and that removed assets are no longer referenced.

## Commands

Run the scope script first:

```bash
bash .codex/skills/flymap-app-pre-release-check/scripts/release_scope.sh
```

Then use targeted commands as needed:

```bash
git diff --stat <base>..HEAD
git diff --name-only <base>..HEAD
git diff <base>..HEAD -- pubspec.yaml
git diff <base>..HEAD -- lib/path.dart
git diff <base>..HEAD -- android/app/src/main/AndroidManifest.xml
git diff <base>..HEAD -- ios/Runner/Info.plist
rg -n "apiKey|token|secret|analytics|crashlytics|purchase|permission|entitlement|webview|share" lib android ios
flutter analyze
flutter test
```

## Review Rules

- Default to review-only. Do not make code changes unless the user asks for fixes.
- Do not flood the user with style nits. Report only materially important issues.
- Treat tracked secrets, broken map/offline flows, startup/build regressions, and purchase/privacy regressions as top severity.
- If the repo is dirty, note whether uncommitted changes make the release scope ambiguous.
- If you cannot run a validation command, say that explicitly rather than implying coverage.

## Output Shape

Use this structure:

```text
Findings
- [severity] Title — file:line
  Why it matters.
  Suggested fix.

Open questions / assumptions
- ...

Release assessment
- Recommendation: ship | ship with follow-up | do not ship
- Residual risk: ...
```
