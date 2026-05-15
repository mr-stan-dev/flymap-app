import 'package:flymap/rating/rate_prompt_repository.dart';
import 'package:flymap/rating/rate_prompt_trigger.dart';

abstract interface class RatePromptPolicyService {
  Future<void> registerTrigger(RatePromptTrigger trigger);

  Future<bool> shouldShowPromptNow();

  Future<void> recordAccepted();

  Future<void> recordDeclined();

  Future<void> recordDismissed();
}

class DefaultRatePromptPolicyService implements RatePromptPolicyService {
  DefaultRatePromptPolicyService({
    required RatePromptRepository repository,
    DateTime Function()? nowProvider,
    Duration firstSeenMinAge = const Duration(days: 7),
    Duration dismissSnooze = const Duration(days: 14),
    Duration declineSnooze = const Duration(days: 30),
  }) : _repository = repository,
       _nowProvider = nowProvider ?? DateTime.now,
       _firstSeenMinAge = firstSeenMinAge,
       _dismissSnooze = dismissSnooze,
       _declineSnooze = declineSnooze;

  static const _minDownloadSuccessCountToPrompt = 3;
  static const _minShareCountToPrompt = 1;

  final RatePromptRepository _repository;
  final DateTime Function() _nowProvider;
  final Duration _firstSeenMinAge;
  final Duration _dismissSnooze;
  final Duration _declineSnooze;

  @override
  Future<void> registerTrigger(RatePromptTrigger trigger) async {
    await _incrementTriggerCount(trigger);
  }

  @override
  Future<bool> shouldShowPromptNow() async {
    if (await _repository.isCompleted()) {
      return false;
    }

    final now = _nowProvider().toUtc();
    var firstSeenAt = await _repository.getFirstSeenAt();
    if (firstSeenAt == null) {
      firstSeenAt = now;
      await _repository.setFirstSeenAt(now);
      return false;
    }
    if (now.isBefore(firstSeenAt.toUtc().add(_firstSeenMinAge))) {
      return false;
    }

    final downloadCount = await _repository.getTriggerCount(
      RatePromptTrigger.flightMapDownloadSuccess,
    );
    if (downloadCount < _minDownloadSuccessCountToPrompt) {
      return false;
    }

    final shareCount = await _repository.getTriggerCount(
      RatePromptTrigger.shareCardShared,
    );
    if (shareCount < _minShareCountToPrompt) {
      return false;
    }

    final snoozedUntil = await _repository.getSnoozedUntil();
    if (snoozedUntil == null) {
      return true;
    }

    return !now.isBefore(snoozedUntil.toUtc());
  }

  @override
  Future<void> recordAccepted() async {
    await _repository.setCompleted(true);
    await _repository.setSnoozedUntil(null);
  }

  @override
  Future<void> recordDeclined() async {
    final now = _nowProvider().toUtc();
    await _repository.setSnoozedUntil(now.add(_declineSnooze));
  }

  @override
  Future<void> recordDismissed() async {
    final now = _nowProvider().toUtc();
    await _repository.setSnoozedUntil(now.add(_dismissSnooze));
  }

  Future<int> _incrementTriggerCount(RatePromptTrigger trigger) async {
    final current = await _repository.getTriggerCount(trigger);
    final next = current + 1;
    await _repository.setTriggerCount(trigger, next);
    return next;
  }
}
