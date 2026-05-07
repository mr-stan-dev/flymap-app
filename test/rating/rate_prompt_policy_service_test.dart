import 'package:flutter_test/flutter_test.dart';
import 'package:flymap/rating/rate_prompt_policy_service.dart';
import 'package:flymap/rating/rate_prompt_repository.dart';
import 'package:flymap/rating/rate_prompt_trigger.dart';

void main() {
  group('DefaultRatePromptPolicyService', () {
    test(
      'does not show before fifth trigger and shows on fifth trigger',
      () async {
        final repository = _InMemoryRatePromptRepository();
        final service = DefaultRatePromptPolicyService(
          repository: repository,
          nowProvider: () => DateTime.utc(2026, 4, 9),
        );

        final results = <bool>[];
        for (var i = 0; i < 5; i++) {
          results.add(
            await service.registerTriggerAndShouldShow(
              RatePromptTrigger.flightMapDownloadSuccess,
            ),
          );
        }

        expect(results.sublist(0, 4), everyElement(isFalse));
        expect(results.last, isTrue);
      },
    );

    test('decline snoozes prompts for 30 days', () async {
      var now = DateTime.utc(2026, 4, 9);
      final repository = _InMemoryRatePromptRepository();
      final service = DefaultRatePromptPolicyService(
        repository: repository,
        nowProvider: () => now,
      );

      for (var i = 0; i < 5; i++) {
        await service.registerTriggerAndShouldShow(
          RatePromptTrigger.flightMapDownloadSuccess,
        );
      }
      await service.recordDeclined();

      final whileSnoozed = await service.registerTriggerAndShouldShow(
        RatePromptTrigger.flightMapDownloadSuccess,
      );
      expect(whileSnoozed, isFalse);

      now = now.add(const Duration(days: 31));
      final afterSnooze = await service.registerTriggerAndShouldShow(
        RatePromptTrigger.flightMapDownloadSuccess,
      );
      expect(afterSnooze, isTrue);
    });

    test('accepted users are never prompted again', () async {
      final repository = _InMemoryRatePromptRepository();
      final service = DefaultRatePromptPolicyService(
        repository: repository,
        nowProvider: () => DateTime.utc(2026, 4, 9),
      );

      for (var i = 0; i < 5; i++) {
        await service.registerTriggerAndShouldShow(
          RatePromptTrigger.flightMapDownloadSuccess,
        );
      }
      await service.recordAccepted();

      final third = await service.registerTriggerAndShouldShow(
        RatePromptTrigger.flightMapDownloadSuccess,
      );
      final fourth = await service.registerTriggerAndShouldShow(
        RatePromptTrigger.flightMapDownloadSuccess,
      );

      expect(third, isFalse);
      expect(fourth, isFalse);
    });
  });
}

class _InMemoryRatePromptRepository implements RatePromptRepository {
  bool _completed = false;
  DateTime? _snoozedUntil;
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
}
