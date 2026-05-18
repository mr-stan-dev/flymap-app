class DownloadCompletedArgs {
  const DownloadCompletedArgs({
    required this.flightId,
    this.isProSubscriber = false,
    this.usedSingleFlightUnlock = false,
  });

  final String flightId;
  final bool isProSubscriber;
  final bool usedSingleFlightUnlock;
}
