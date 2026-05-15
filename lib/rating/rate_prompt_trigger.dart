enum RatePromptTrigger { flightMapDownloadSuccess, shareCardShared }

extension RatePromptTriggerStorageKey on RatePromptTrigger {
  String get storageKey {
    return switch (this) {
      RatePromptTrigger.flightMapDownloadSuccess =>
        'flight_map_download_success',
      RatePromptTrigger.shareCardShared => 'share_card_shared',
    };
  }
}
