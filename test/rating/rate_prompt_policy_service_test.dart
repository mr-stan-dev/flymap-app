import 'package:flutter_test/flutter_test.dart';
import 'package:flymap/rating/rate_prompt_policy_service.dart';
import 'package:flymap/rating/rate_prompt_repository.dart';
import 'package:flymap/rating/rate_prompt_trigger.dart';

void main() {
  group('DefaultRatePromptPolicyService', () {
    test(
      'does not show until download count and first-seen age are satisfied',
      () async {
        final repository = _InMemoryRatePromptRepository();
        final service = DefaultRatePromptPolicyService(
          repository: repository,
          nowProvider: () => DateTime.utc(2026, 4, 9),
        );

        await service.registerTrigger(
          RatePromptTrigger.flightMapDownloadSuccess,
        );
        expect(await service.shouldShowPromptNow(), isFalse);

        await service.registerTrigger(
          RatePromptTrigger.flightMapDownloadSuccess,
        );
        expect(await service.shouldShowPromptNow(), isFalse);

        repository.firstSeenAt = DateTime.utc(2026, 4, 1);
        expect(await service.shouldShowPromptNow(), isTrue);
      },
    );

    test('decline snoozes prompts for 30 days', () async {
      var now = DateTime.utc(2026, 4, 9);
      final repository = _InMemoryRatePromptRepository();
      final service = DefaultRatePromptPolicyService(
        repository: repository,
        nowProvider: () => now,
        firstSeenMinAge: Duration.zero,
      );

      expect(await service.shouldShowPromptNow(), isFalse);
      for (var i = 0; i < 2; i++) {
        await service.registerTrigger(
          RatePromptTrigger.flightMapDownloadSuccess,
        );
      }
      expect(await service.shouldShowPromptNow(), isTrue);
      await service.recordDeclined();

      final whileSnoozed = await service.shouldShowPromptNow();
      expect(whileSnoozed, isFalse);

      now = now.add(const Duration(days: 31));
      final afterSnooze = await service.shouldShowPromptNow();
      expect(afterSnooze, isTrue);
    });

    test('accepted users are snoozed for 180 days', () async {
      var now = DateTime.utc(2026, 4, 9);
      final repository = _InMemoryRatePromptRepository();
      final service = DefaultRatePromptPolicyService(
        repository: repository,
        nowProvider: () => now,
        firstSeenMinAge: Duration.zero,
      );

      expect(await service.shouldShowPromptNow(), isFalse);
      for (var i = 0; i < 2; i++) {
        await service.registerTrigger(
          RatePromptTrigger.flightMapDownloadSuccess,
        );
      }
      expect(await service.shouldShowPromptNow(), isTrue);
      await service.recordAccepted();

      await service.registerTrigger(RatePromptTrigger.flightMapDownloadSuccess);
      expect(await service.shouldShowPromptNow(), isFalse);

      now = now.add(const Duration(days: 181));
      expect(await service.shouldShowPromptNow(), isTrue);
    });

    test('legacy completed users are migrated to a 180-day snooze', () async {
      var now = DateTime.utc(2026, 4, 9);
      final repository = _InMemoryRatePromptRepository()
        .._completed = true
        ..firstSeenAt = DateTime.utc(2026, 4, 1);
      repository._counts[RatePromptTrigger.flightMapDownloadSuccess] = 2;
      final service = DefaultRatePromptPolicyService(
        repository: repository,
        nowProvider: () => now,
      );

      expect(await service.shouldShowPromptNow(), isFalse);
      expect(repository._completed, isFalse);
      expect(await service.shouldShowPromptNow(), isFalse);

      now = now.add(const Duration(days: 181));
      expect(await service.shouldShowPromptNow(), isTrue);
    });
  });
}

class _InMemoryRatePromptRepository implements RatePromptRepository {
  bool _completed = false;
  DateTime? _snoozedUntil;
  DateTime? firstSeenAt;
  final Map<RatePromptTrigger, int> _counts = {};

  @override
  Future<int> getTriggerCount(RatePromptTrigger trigger) async {
    return _counts[trigger] ?? 0;
  }

  @override
  Future<void> setTriggerCount(RatePromptTrigger trigger, int count) async {
    _counts[trigger] = count;
  }

  @override
  Future<bool> isCompleted() async => _completed;

  @override
  Future<void> setCompleted(bool completed) async {
    _completed = completed;
  }

  @override
  Future<DateTime?> getSnoozedUntil() async => _snoozedUntil;

  @override
  Future<void> setSnoozedUntil(DateTime? value) async {
    _snoozedUntil = value;
  }

  @override
  Future<DateTime?> getFirstSeenAt() async => firstSeenAt;

  @override
  Future<void> setFirstSeenAt(DateTime value) async {
    firstSeenAt = value;
  }
}
