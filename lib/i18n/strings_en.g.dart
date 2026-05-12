///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations

	/// en: 'Flymap'
	String get appName => 'Flymap';

	late final TranslationsCommonEn common = TranslationsCommonEn.internal(_root);
	late final TranslationsHomeEn home = TranslationsHomeEn.internal(_root);
	late final TranslationsLearnEn learn = TranslationsLearnEn.internal(_root);
	late final TranslationsSettingsEn settings = TranslationsSettingsEn.internal(_root);
	late final TranslationsSubscriptionEn subscription = TranslationsSubscriptionEn.internal(_root);
	late final TranslationsCreateFlightEn createFlight = TranslationsCreateFlightEn.internal(_root);
	late final TranslationsPreviewEn preview = TranslationsPreviewEn.internal(_root);
	late final TranslationsFlightEn flight = TranslationsFlightEn.internal(_root);
	late final TranslationsShareFlightEn shareFlight = TranslationsShareFlightEn.internal(_root);
	late final TranslationsAboutEn about = TranslationsAboutEn.internal(_root);
	late final TranslationsOnboardingEn onboarding = TranslationsOnboardingEn.internal(_root);
}

// Path: common
class TranslationsCommonEn {
	TranslationsCommonEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Continue'
	String get kContinue => 'Continue';

	/// en: 'Back'
	String get back => 'Back';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'OK'
	String get ok => 'OK';

	/// en: 'Retry'
	String get retry => 'Retry';

	/// en: 'Manage'
	String get manage => 'Manage';

	/// en: 'Edit'
	String get edit => 'Edit';

	/// en: 'Upgrade'
	String get upgrade => 'Upgrade';

	/// en: 'Loading...'
	String get loading => 'Loading...';

	/// en: 'Read more'
	String get readMore => 'Read more';

	/// en: 'PRO'
	String get pro => 'PRO';

	/// en: 'Search'
	String get search => 'Search';
}

// Path: home
class TranslationsHomeEn {
	TranslationsHomeEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Home'
	String get title => 'Home';

	/// en: 'About'
	String get aboutTooltip => 'About';

	/// en: 'Settings'
	String get settingsTooltip => 'Settings';

	/// en: 'Flights'
	String get tabFlights => 'Flights';

	/// en: 'Learn'
	String get tabLearn => 'Learn';

	/// en: 'Loading flights...'
	String get loadingFlights => 'Loading flights...';

	/// en: 'Failed to load flights'
	String get failedToLoadFlights => 'Failed to load flights';

	/// en: 'New flight'
	String get newFlight => 'New flight';

	/// en: 'Add first flight'
	String get addFirstFlight => 'Add first flight';

	/// en: 'Add next flight'
	String get addNextFlight => 'Add next flight';

	/// en: 'Welcome to Flymap'
	String get welcomeTitle => 'Welcome to Flymap';

	/// en: 'Welcome to Flymap Pro'
	String get welcomeTitlePro => 'Welcome to Flymap Pro';

	/// en: 'Offline maps for flights'
	String get welcomeSubtitle => 'Offline maps for flights';

	/// en: 'Ready for the next flight?'
	String get greetingOnline => 'Ready for the next flight?';

	/// en: 'Hi $name, ready for the next flight?'
	String greetingOnlineWithName({required Object name}) => 'Hi ${name}, ready for the next flight?';

	/// en: 'Ready to explore your flight?'
	String get greetingOffline => 'Ready to explore your flight?';

	/// en: 'Hi $name, ready to explore your flight?'
	String greetingOfflineWithName({required Object name}) => 'Hi ${name}, ready to explore your flight?';

	/// en: 'Your flight is in progress'
	String get greetingInProgress => 'Your flight is in progress';

	/// en: 'Hi $name, your flight is in progress'
	String greetingInProgressWithName({required Object name}) => 'Hi ${name}, your flight is in progress';

	/// en: 'Total flights'
	String get totalFlights => 'Total flights';

	/// en: 'Storage used'
	String get storageUsed => 'Storage used';

	/// en: 'Total distance'
	String get totalDistance => 'Total distance';

	/// en: 'Upcoming flights ($count)'
	String upcomingFlightsCount({required Object count}) => 'Upcoming flights (${count})';

	/// en: 'Flight in progress'
	String get flightInProgressTitle => 'Flight in progress';

	/// en: 'Ready to explore the world from above?'
	String get noFlightsTitle => 'Ready to explore the world from above?';

	/// en: 'Add your first flight and start discovering your next journey.'
	String get noFlightsSubtitle => 'Add your first flight and start discovering your next journey.';

	/// en: 'Ready for your next trip?'
	String get noFlightsTitleNext => 'Ready for your next trip?';

	/// en: 'Your completed flights are in History. Add your next flight to keep going.'
	String get noFlightsSubtitleNext => 'Your completed flights are in History. Add your next flight to keep going.';

	/// en: 'Flight actions'
	String get flightActions => 'Flight actions';

	/// en: 'View all'
	String get viewAll => 'View all';

	/// en: 'Open'
	String get open => 'Open';

	/// en: 'Share route'
	String get shareRoute => 'Share route';

	/// en: 'Archive flight'
	String get completeFlight => 'Archive flight';

	/// en: 'Delete flight'
	String get deleteFlight => 'Delete flight';

	/// en: 'Failed to delete flight'
	String get failedDeleteFlight => 'Failed to delete flight';

	/// en: 'No offline map'
	String get noOfflineMap => 'No offline map';

	/// en: '$count places'
	String placesCount({required Object count}) => '${count} places';

	/// en: '$count articles'
	String offlineArticlesCount({required Object count}) => '${count} articles';

	/// en: 'Saved $time'
	String savedTime({required Object time}) => 'Saved ${time}';

	/// en: 'Just now'
	String get justNow => 'Just now';

	/// en: '$days d ago'
	String daysAgo({required Object days}) => '${days} d ago';

	/// en: '$hours h ago'
	String hoursAgo({required Object hours}) => '${hours} h ago';

	/// en: '$minutes m ago'
	String minutesAgo({required Object minutes}) => '${minutes} m ago';

	late final TranslationsHomeSortEn sort = TranslationsHomeSortEn.internal(_root);
}

// Path: learn
class TranslationsLearnEn {
	TranslationsLearnEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Loading learning categories...'
	String get loadingCategories => 'Loading learning categories...';

	/// en: 'Failed to load categories'
	String get failedToLoadCategories => 'Failed to load categories';

	/// en: 'No categories yet'
	String get emptyCategoriesTitle => 'No categories yet';

	/// en: 'Learning categories will appear here soon.'
	String get emptyCategoriesSubtitle => 'Learning categories will appear here soon.';

	/// en: '$count articles'
	String articlesCount({required Object count}) => '${count} articles';

	/// en: 'Loading articles...'
	String get loadingArticles => 'Loading articles...';

	/// en: 'Failed to load articles'
	String get failedToLoadArticles => 'Failed to load articles';

	/// en: 'No articles yet'
	String get emptyArticlesTitle => 'No articles yet';

	/// en: 'Articles for this category will appear soon.'
	String get emptyArticlesSubtitle => 'Articles for this category will appear soon.';

	/// en: 'Premium content is available with Pro. Connect to the internet to upgrade.'
	String get upgradeRequiresInternet => 'Premium content is available with Pro. Connect to the internet to upgrade.';

	/// en: 'You can browse these article titles now. Unlock reading with Flymap Pro.'
	String get proListPreviewHint => 'You can browse these article titles now. Unlock reading with Flymap Pro.';

	/// en: 'Could not open this article right now.'
	String get failedToLoadArticle => 'Could not open this article right now.';
}

// Path: settings
class TranslationsSettingsEn {
	TranslationsSettingsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Settings'
	String get title => 'Settings';

	/// en: 'Loading settings...'
	String get loading => 'Loading settings...';

	/// en: 'Profile'
	String get profile => 'Profile';

	/// en: 'Name, flying habits, home airport, and interests'
	String get profileSubtitle => 'Name, flying habits, home airport, and interests';

	/// en: '$name · $code'
	String profileSummaryNameHome({required Object name, required Object code}) => '${name} · ${code}';

	/// en: 'Home airport: $code'
	String profileSummaryHome({required Object code}) => 'Home airport: ${code}';

	/// en: 'Tap any item to edit your profile details.'
	String get profileEditHint => 'Tap any item to edit your profile details.';

	/// en: 'Not set'
	String get profileNotSet => 'Not set';

	/// en: '$count selected'
	String profileInterestsSelected({required Object count}) => '${count} selected';

	/// en: 'History'
	String get historyTitle => 'History';

	/// en: 'All flights and stats'
	String get historySubtitle => 'All flights and stats';

	/// en: 'Loading history...'
	String get historyLoading => 'Loading history...';

	/// en: 'Failed to load flight history.'
	String get historyLoadError => 'Failed to load flight history.';

	/// en: 'Total flights'
	String get historyFlightsLabel => 'Total flights';

	/// en: 'Total distance'
	String get historyDistanceLabel => 'Total distance';

	/// en: 'All flights'
	String get historyAllFlights => 'All flights';

	/// en: 'Upcoming'
	String get historyStatusUpcoming => 'Upcoming';

	/// en: 'In progress'
	String get historyStatusInProgress => 'In progress';

	/// en: 'Completed'
	String get historyStatusCompleted => 'Completed';

	/// en: 'Map $size'
	String historyMapChip({required Object size}) => 'Map ${size}';

	/// en: 'No map'
	String get historyNoMapChip => 'No map';

	/// en: 'Name'
	String get historySortName => 'Name';

	/// en: 'Distance'
	String get historySortDistance => 'Distance';

	/// en: 'Date'
	String get historySortDate => 'Date';

	/// en: 'No flights yet.'
	String get historyEmpty => 'No flights yet.';

	/// en: 'Search by airport or city'
	String get historySearchHint => 'Search by airport or city';

	/// en: 'No matching flights found.'
	String get historyNoResults => 'No matching flights found.';

	/// en: 'Delete map only'
	String get historyDeleteOfflineData => 'Delete map only';

	/// en: 'Appearance'
	String get appearance => 'Appearance';

	/// en: 'Theme'
	String get theme => 'Theme';

	/// en: 'System'
	String get system => 'System';

	/// en: 'Dark'
	String get dark => 'Dark';

	/// en: 'Light'
	String get light => 'Light';

	/// en: 'Units'
	String get units => 'Units';

	/// en: 'Storage'
	String get storage => 'Storage';

	/// en: 'Storage'
	String get storageTitle => 'Storage';

	/// en: 'Downloaded maps and disk usage'
	String get storageSubtitle => 'Downloaded maps and disk usage';

	/// en: 'Loading storage...'
	String get storageLoading => 'Loading storage...';

	/// en: 'Failed to load storage data.'
	String get storageLoadError => 'Failed to load storage data.';

	/// en: 'Downloaded maps'
	String get storageMapsLabel => 'Downloaded maps';

	/// en: 'Total size'
	String get storageTotalSizeLabel => 'Total size';

	/// en: 'Downloaded maps'
	String get storageDownloadedMaps => 'Downloaded maps';

	/// en: 'Name'
	String get storageSortName => 'Name';

	/// en: 'Size'
	String get storageSortSize => 'Size';

	/// en: 'Size: $size'
	String storageMapSize({required Object size}) => 'Size: ${size}';

	/// en: 'No downloaded maps yet.'
	String get storageEmpty => 'No downloaded maps yet.';

	/// en: 'Altitude'
	String get altitude => 'Altitude';

	/// en: 'Altitude unit'
	String get altitudeUnit => 'Altitude unit';

	/// en: 'Speed'
	String get speed => 'Speed';

	/// en: 'Speed unit'
	String get speedUnit => 'Speed unit';

	/// en: 'Time format'
	String get timeFormat => 'Time format';

	/// en: 'Distance unit'
	String get distanceUnit => 'Distance unit';

	/// en: 'Date format'
	String get dateFormat => 'Date format';

	/// en: 'Support'
	String get support => 'Support';

	/// en: 'About'
	String get about => 'About';

	/// en: 'Learn more about the app'
	String get aboutSubtitle => 'Learn more about the app';

	/// en: 'Privacy Policy'
	String get privacyPolicy => 'Privacy Policy';

	/// en: 'Read our privacy policy'
	String get privacyPolicySubtitle => 'Read our privacy policy';

	/// en: 'Terms of Service'
	String get termsOfService => 'Terms of Service';

	/// en: 'Read our terms of service'
	String get termsOfServiceSubtitle => 'Read our terms of service';

	/// en: 'Flymap Pro activated.'
	String get flymapProActivated => 'Flymap Pro activated.';

	/// en: 'Upgrade cancelled.'
	String get upgradeCancelled => 'Upgrade cancelled.';

	/// en: 'No paywall available right now.'
	String get noPaywall => 'No paywall available right now.';

	/// en: 'Failed to open paywall.'
	String get failedOpenPaywall => 'Failed to open paywall.';

	/// en: 'Could not open $url'
	String couldNotOpenUrl({required Object url}) => 'Could not open ${url}';

	/// en: 'Rate us'
	String get rateUs => 'Rate us';

	/// en: 'Leave a review on the store'
	String get rateUsSubtitle => 'Leave a review on the store';

	/// en: 'Leave a Feedback'
	String get leaveFeedback => 'Leave a Feedback';

	/// en: 'Share your thoughts to help us improve'
	String get leaveFeedbackSubtitle => 'Share your thoughts to help us improve';

	/// en: 'Could not open store page'
	String get couldNotOpenStorePage => 'Could not open store page';

	/// en: 'Do you like the app?'
	String get rateDialogTitle => 'Do you like the app?';

	/// en: 'We work hard to make every flight more enjoyable, and your feedback really helps us improve.'
	String get rateDialogBody => 'We work hard to make every flight more enjoyable, and your feedback really helps us improve.';

	/// en: 'Yes'
	String get rateDialogYes => 'Yes';

	/// en: 'No'
	String get rateDialogNo => 'No';

	/// en: 'Leave a Feedback'
	String get feedbackTitle => 'Leave a Feedback';

	/// en: 'Help us to make Flymap better'
	String get feedbackBody => 'Help us to make Flymap better';

	/// en: 'Feedback type'
	String get feedbackCategoryTitle => 'Feedback type';

	/// en: 'General'
	String get feedbackCategoryGeneral => 'General';

	/// en: 'Feature request'
	String get feedbackCategoryFeatureRequest => 'Feature request';

	/// en: 'Bug report'
	String get feedbackCategoryBugReport => 'Bug report';

	/// en: 'Share your feedback...'
	String get feedbackHint => 'Share your feedback...';

	/// en: 'Email (optional)'
	String get feedbackEmailHint => 'Email (optional)';

	/// en: 'Please enter a valid email or leave it empty.'
	String get feedbackEmailInvalid => 'Please enter a valid email or leave it empty.';

	/// en: 'Send'
	String get feedbackSend => 'Send';

	/// en: 'Thanks for sharing your feedback!'
	String get feedbackThanks => 'Thanks for sharing your feedback!';

	/// en: 'Couldn't send feedback. Please try again.'
	String get feedbackSendFailed => 'Couldn\'t send feedback. Please try again.';

	/// en: 'Flymap Pro'
	String get proBannerTitle => 'Flymap Pro';

	/// en: 'Flymap Pro Active'
	String get proBannerTitleActive => 'Flymap Pro Active';

	/// en: 'Detailed map mode and full offline article bundles unlocked.'
	String get proBannerSubtitleActive => 'Detailed map mode and full offline article bundles unlocked.';

	/// en: 'Unlock detailed maps and full offline article bundles'
	String get proBannerSubtitleFree => 'Unlock detailed maps and full offline article bundles';

	/// en: 'PRO ACTIVE'
	String get proBannerBadgeActive => 'PRO ACTIVE';
}

// Path: subscription
class TranslationsSubscriptionEn {
	TranslationsSubscriptionEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Subscription'
	String get screenTitle => 'Subscription';

	/// en: 'Pull down to refresh your subscription status.'
	String get pullToRefresh => 'Pull down to refresh your subscription status.';

	/// en: 'Need help?'
	String get needHelp => 'Need help?';

	/// en: 'Contact support'
	String get contactSupport => 'Contact support';

	/// en: 'Flymap Pro'
	String get cardTitle => 'Flymap Pro';

	/// en: 'What Flymap Pro unlocks'
	String get proFeaturesTitle => 'What Flymap Pro unlocks';

	/// en: 'Detailed offline maps'
	String get proFeatureMapsTitle => 'Detailed offline maps';

	/// en: 'Get higher-detail offline maps for your saved routes.'
	String get proFeatureMapsText => 'Get higher-detail offline maps for your saved routes.';

	/// en: 'More route discoveries'
	String get proFeaturePoiTitle => 'More route discoveries';

	/// en: 'See more interesting places along your route.'
	String get proFeaturePoiText => 'See more interesting places along your route.';

	/// en: 'Unlimited offline articles'
	String get proFeatureArticlesTitle => 'Unlimited offline articles';

	/// en: 'Read offline articles without the Free plan limit.'
	String get proFeatureArticlesText => 'Read offline articles without the Free plan limit.';

	/// en: 'Checking your subscription status...'
	String get checkingStatus => 'Checking your subscription status...';

	/// en: 'Flymap Pro is active.'
	String get proActive => 'Flymap Pro is active.';

	/// en: 'You are on Free plan.'
	String get freePlan => 'You are on Free plan.';

	/// en: 'Status'
	String get status => 'Status';

	/// en: 'Active'
	String get active => 'Active';

	/// en: 'Not active'
	String get notActive => 'Not active';

	/// en: 'Entitlement'
	String get entitlement => 'Entitlement';

	/// en: 'Expires'
	String get expires => 'Expires';

	/// en: 'No expiration'
	String get noExpiration => 'No expiration';

	/// en: 'Last update'
	String get lastUpdate => 'Last update';

	/// en: 'Unknown'
	String get unknown => 'Unknown';

	/// en: 'Manage subscription'
	String get manageSubscription => 'Manage subscription';

	/// en: 'Upgrade to Pro'
	String get upgradeToPro => 'Upgrade to Pro';

	/// en: 'You can cancel or change billing in your App Store or Google Play subscription settings.'
	String get proManageHint => 'You can cancel or change billing in your App Store or Google Play subscription settings.';

	/// en: 'Upgrade to Pro for detailed offline maps, more route discoveries, and unlimited offline articles.'
	String get freeUpgradeHint => 'Upgrade to Pro for detailed offline maps, more route discoveries, and unlimited offline articles.';

	/// en: 'Flymap subscription support'
	String get supportEmailSubject => 'Flymap subscription support';

	/// en: 'Could not open email app'
	String get couldNotOpenEmailApp => 'Could not open email app';

	/// en: 'Could not open subscription settings'
	String get couldNotOpenSubscriptionSettings => 'Could not open subscription settings';

	/// en: 'Flymap Pro restored.'
	String get proRestored => 'Flymap Pro restored.';

	/// en: 'Failed to open paywall.'
	String get failedOpenPaywall => 'Failed to open paywall.';

	/// en: 'Subscription service is temporarily unavailable.'
	String get serviceUnavailable => 'Subscription service is temporarily unavailable.';
}

// Path: createFlight
class TranslationsCreateFlightEn {
	TranslationsCreateFlightEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsCreateFlightStepsEn steps = TranslationsCreateFlightStepsEn.internal(_root);
	late final TranslationsCreateFlightRouteTypeSelectorEn routeTypeSelector = TranslationsCreateFlightRouteTypeSelectorEn.internal(_root);
	late final TranslationsCreateFlightFlightNumberSearchEn flightNumberSearch = TranslationsCreateFlightFlightNumberSearchEn.internal(_root);
	late final TranslationsCreateFlightSearchEn search = TranslationsCreateFlightSearchEn.internal(_root);
	late final TranslationsCreateFlightMapPreviewEn mapPreview = TranslationsCreateFlightMapPreviewEn.internal(_root);
	late final TranslationsCreateFlightOverviewEn overview = TranslationsCreateFlightOverviewEn.internal(_root);
	late final TranslationsCreateFlightWikipediaEn wikipedia = TranslationsCreateFlightWikipediaEn.internal(_root);
	late final TranslationsCreateFlightDownloadingEn downloading = TranslationsCreateFlightDownloadingEn.internal(_root);
	late final TranslationsCreateFlightErrorsEn errors = TranslationsCreateFlightErrorsEn.internal(_root);
	late final TranslationsCreateFlightPaywallEn paywall = TranslationsCreateFlightPaywallEn.internal(_root);
}

// Path: preview
class TranslationsPreviewEn {
	TranslationsPreviewEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Calculating flight route...'
	String get calculatingRoute => 'Calculating flight route...';

	/// en: 'Error'
	String get errorTitle => 'Error';

	/// en: 'Something went wrong'
	String get errorSomethingWrong => 'Something went wrong';

	/// en: 'Try Again'
	String get tryAgain => 'Try Again';

	/// en: 'Download Complete!'
	String get downloadComplete => 'Download Complete!';

	/// en: 'Flight has been saved'
	String get flightSaved => 'Flight has been saved';

	/// en: 'Navigating to home...'
	String get navigatingHome => 'Navigating to home...';

	/// en: 'Downloading Flight Map'
	String get downloadingMapTitle => 'Downloading Flight Map';

	/// en: 'Cancel download'
	String get cancelDownload => 'Cancel download';

	/// en: 'Download'
	String get download => 'Download';

	/// en: 'Flight route (~ $distance)'
	String flightRoute({required Object distance}) => 'Flight route (~ ${distance})';
}

// Path: flight
class TranslationsFlightEn {
	TranslationsFlightEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Map'
	String get tabMap => 'Map';

	/// en: 'Dashboard'
	String get tabDashboard => 'Dashboard';

	/// en: 'Route'
	String get tabRoute => 'Route';

	/// en: 'Info'
	String get tabInfo => 'Info';

	/// en: 'Complete flight?'
	String get completeDialogTitle => 'Complete flight?';

	/// en: 'This marks your flight as completed.'
	String get completeDialogBody => 'This marks your flight as completed.';

	/// en: 'Delete map and offline articles'
	String get completeDialogDeleteOffline => 'Delete map and offline articles';

	/// en: 'Complete'
	String get completeDialogConfirm => 'Complete';

	/// en: 'Are you sure?'
	String get deleteDialogTitle => 'Are you sure?';

	/// en: 'This permanently deletes this flight, including offline map and saved offline articles. Space to be regained: $size.'
	String deleteDialogMessage({required Object size}) => 'This permanently deletes this flight, including offline map and saved offline articles.\n\nSpace to be regained: ${size}.';

	/// en: 'Yes'
	String get yes => 'Yes';

	/// en: 'Share route'
	String get shareRoute => 'Share route';

	/// en: 'Copy route'
	String get copyRoute => 'Copy route';

	/// en: 'Delete flight'
	String get deleteFlight => 'Delete flight';

	/// en: 'Route summary copied'
	String get routeSummaryCopied => 'Route summary copied';

	/// en: 'Flight deleted'
	String get deleted => 'Flight deleted';

	/// en: 'Error deleting flight: $error'
	String deleteError({required Object error}) => 'Error deleting flight: ${error}';

	late final TranslationsFlightMapEn map = TranslationsFlightMapEn.internal(_root);
	late final TranslationsFlightDashboardEn dashboard = TranslationsFlightDashboardEn.internal(_root);
	late final TranslationsFlightUpcomingEn upcoming = TranslationsFlightUpcomingEn.internal(_root);
	late final TranslationsFlightInfoEn info = TranslationsFlightInfoEn.internal(_root);
	late final TranslationsFlightRouteEn route = TranslationsFlightRouteEn.internal(_root);
}

// Path: shareFlight
class TranslationsShareFlightEn {
	TranslationsShareFlightEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Share flight'
	String get title => 'Share flight';

	/// en: 'Preparing share preview map...'
	String get preparingMap => 'Preparing share preview map...';

	/// en: 'Preparing screenshot...'
	String get preparingScreenshot => 'Preparing screenshot...';

	/// en: 'Share'
	String get share => 'Share';

	/// en: 'Offline map missing. Using online style.'
	String get offlineMapMissing => 'Offline map missing. Using online style.';

	/// en: 'Failed to load offline style. Using online style.'
	String get offlineStyleFailed => 'Failed to load offline style. Using online style.';

	/// en: 'Could not capture route screenshot'
	String get captureFailed => 'Could not capture route screenshot';

	/// en: 'Failed to share route screenshot'
	String get shareFailed => 'Failed to share route screenshot';

	/// en: 'Flight route $from-$to'
	String shareText({required Object from, required Object to}) => 'Flight route ${from}-${to}';

	/// en: 'Flymap'
	String get watermark => 'Flymap';

	/// en: 'Flight distance'
	String get flightDistance => 'Flight distance';

	/// en: '$distance km'
	String distanceKm({required Object distance}) => '${distance} km';
}

// Path: about
class TranslationsAboutEn {
	TranslationsAboutEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'About Flymap'
	String get title => 'About Flymap';

	/// en: 'Welcome to Flymap'
	String get welcome => 'Welcome to Flymap';

	/// en: 'Flymap keeps your route visible in the air. Plan the trip, download your map on the ground, and track your flight offline with confidence.'
	String get intro => 'Flymap keeps your route visible in the air. Plan the trip, download your map on the ground, and track your flight offline with confidence.';

	/// en: 'Offline map'
	String get chipOffline => 'Offline map';

	/// en: 'Live dashboard'
	String get chipDashboard => 'Live dashboard';

	/// en: 'Route sharing'
	String get chipSharing => 'Route sharing';

	/// en: 'Before takeoff, download your route map. In flight mode, internet access may be limited or unavailable.'
	String get infoBanner => 'Before takeoff, download your route map. In flight mode, internet access may be limited or unavailable.';

	/// en: 'What You Can Do'
	String get whatYouCanDo => 'What You Can Do';

	/// en: 'Plan your route'
	String get featurePlanTitle => 'Plan your route';

	/// en: 'Choose departure and arrival airports, then preview the path before downloading.'
	String get featurePlanText => 'Choose departure and arrival airports, then preview the path before downloading.';

	/// en: 'Track flight data'
	String get featureTrackTitle => 'Track flight data';

	/// en: 'Use Dashboard to monitor heading, speed, altitude, and route progress.'
	String get featureTrackText => 'Use Dashboard to monitor heading, speed, altitude, and route progress.';

	/// en: 'Check route details'
	String get featureDetailsTitle => 'Check route details';

	/// en: 'Open the Info tab for airport details and a clean route overview.'
	String get featureDetailsText => 'Open the Info tab for airport details and a clean route overview.';

	/// en: 'Share your journey'
	String get featureShareTitle => 'Share your journey';

	/// en: 'Generate and share a flight map screenshot with route highlights.'
	String get featureShareText => 'Generate and share a flight map screenshot with route highlights.';

	/// en: 'Quick Start'
	String get quickStart => 'Quick Start';

	/// en: 'Tap New flight on Home.'
	String get step1 => 'Tap New flight on Home.';

	/// en: 'Choose departure and arrival airports.'
	String get step2 => 'Choose departure and arrival airports.';

	/// en: 'Open Map preview and download the map before the flight.'
	String get step3 => 'Open Map preview and download the map before the flight.';

	/// en: 'Open your flight and use Map, Dashboard, and Info in the air.'
	String get step4 => 'Open your flight and use Map, Dashboard, and Info in the air.';

	/// en: 'Tips For Better GPS'
	String get tips => 'Tips For Better GPS';

	/// en: 'For stronger GPS signal, sit closer to a window.'
	String get tip1 => 'For stronger GPS signal, sit closer to a window.';

	/// en: 'Signal can drop in the middle of the aircraft. Flymap keeps the last known route view while searching.'
	String get tip2 => 'Signal can drop in the middle of the aircraft. Flymap keeps the last known route view while searching.';
}

// Path: onboarding
class TranslationsOnboardingEn {
	TranslationsOnboardingEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Skip'
	String get skip => 'Skip';

	/// en: 'Let's start'
	String get letsStart => 'Let\'s start';

	/// en: 'Discover what’s below'
	String get welcomeTitle => 'Discover what’s below';

	/// en: 'shows you offline maps and interesting places along your flight'
	String get welcomeSubtitle => 'shows you offline maps and interesting places along your flight';

	/// en: 'Pick a username'
	String get nameTitle => 'Pick a username';

	/// en: 'Make discovery personal. You can change it anytime.'
	String get nameSubtitle => 'Make discovery personal. You can change it anytime.';

	/// en: 'How often do you fly?'
	String get frequencyTitle => 'How often do you fly?';

	/// en: 'Flymap will personalize your experience and make suggestions more relevant'
	String get frequencySubtitle => 'Flymap will personalize your experience and make suggestions more relevant';

	/// en: 'This is my first flight'
	String get frequencyFirstFlight => 'This is my first flight';

	/// en: 'A few times a year'
	String get frequencyFewPerYear => 'A few times a year';

	/// en: 'About monthly'
	String get frequencyMonthly => 'About monthly';

	/// en: 'Very often'
	String get frequencyFrequent => 'Very often';

	/// en: 'Set your home airport'
	String get homeAirportTitle => 'Set your home airport';

	/// en: 'Get faster flight setup. You can change it anytime.'
	String get homeAirportSubtitle => 'Get faster flight setup. You can change it anytime.';

	/// en: 'Search home airport'
	String get homeAirportHint => 'Search home airport';

	/// en: 'Popular airports'
	String get popularAirports => 'Popular airports';

	/// en: 'Remove home airport'
	String get removeHomeAirport => 'Remove home airport';

	/// en: 'No airports found for that search.'
	String get noHomeAirportFound => 'No airports found for that search.';

	/// en: 'What places you want to see more on a map?'
	String get interestsTitle => 'What places you want to see more on a map?';

	/// en: 'Choose up to 3 topics to see more relevant places and stories along your flight.'
	String get interestsSubtitle => 'Choose up to 3 topics to see more relevant places and stories along your flight.';

	/// en: 'Pick up to 3 topics.'
	String get interestsHelper => 'Pick up to 3 topics.';

	/// en: '$count of $max selected'
	String interestsSelected({required Object count, required Object max}) => '${count} of ${max} selected';

	/// en: 'Mountains & ridges'
	String get interestMountains => 'Mountains & ridges';

	/// en: 'Volcanoes & geology'
	String get interestVolcanoes => 'Volcanoes & geology';

	/// en: 'Cities & regions'
	String get interestRegions => 'Cities & regions';

	/// en: 'Islands & coastlines'
	String get interestIslands => 'Islands & coastlines';

	/// en: 'National parks & reserves'
	String get interestNationalParks => 'National parks & reserves';

	/// en: 'Rivers & lakes'
	String get interestRivers => 'Rivers & lakes';

	/// en: 'Get more from every flight'
	String get proTitle => 'Get more from every flight';

	/// en: 'Unlock detailed maps, places and articles — even offline.'
	String get proStepSubtitle => 'Unlock detailed maps, places and articles — even offline.';

	/// en: 'Detailed maps for your flight'
	String get proFeatureMaps => 'Detailed maps for your flight';

	/// en: '10x more places along the route'
	String get proFeaturePlaces => '10x more places along the route';

	/// en: 'A detailed timeline of your entire flight'
	String get proFeatureTimeline => 'A detailed timeline of your entire flight';

	/// en: 'Complete pack of offline articles'
	String get proFeatureArticles => 'Complete pack of offline articles';

	/// en: 'Unlock Pro'
	String get unlockPro => 'Unlock Pro';

	/// en: 'Continue Free'
	String get continueFree => 'Continue Free';

	/// en: 'Congratulations!'
	String get proActiveTitle => 'Congratulations!';

	/// en: 'You now have full access to detailed maps, all places, and article packs.'
	String get proActiveSubtitle => 'You now have full access to detailed maps, all places, and article packs.';

	/// en: 'Start my first flight'
	String get planFirstFlight => 'Start my first flight';

	/// en: 'Plan my first detailed flight'
	String get planFirstFlightPro => 'Plan my first detailed flight';

	/// en: 'Failed to load your profile.'
	String get failedLoadProfile => 'Failed to load your profile.';
}

// Path: home.sort
class TranslationsHomeSortEn {
	TranslationsHomeSortEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Most recent'
	String get mostRecent => 'Most recent';

	/// en: 'Longest'
	String get longest => 'Longest';

	/// en: 'A-Z'
	String get alphabetical => 'A-Z';
}

// Path: createFlight.steps
class TranslationsCreateFlightStepsEn {
	TranslationsCreateFlightStepsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Choose departure airport'
	String get departureTitle => 'Choose departure airport';

	/// en: 'Choose arrival airport'
	String get arrivalTitle => 'Choose arrival airport';

	/// en: 'Route not supported'
	String get routeNotSupportedTitle => 'Route not supported';

	/// en: 'Map preview'
	String get mapPreviewTitle => 'Map preview';

	/// en: 'Route overview'
	String get overviewTitle => 'Route overview';

	/// en: 'Wikipedia articles'
	String get wikipediaTitle => 'Wikipedia articles';
}

// Path: createFlight.routeTypeSelector
class TranslationsCreateFlightRouteTypeSelectorEn {
	TranslationsCreateFlightRouteTypeSelectorEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'New flight'
	String get title => 'New flight';

	/// en: 'Approximate route'
	String get basicTitle => 'Approximate route';

	/// en: 'By airports'
	String get basicSubtitle => 'By airports';

	/// en: 'Works well for short and mid-haul flights.'
	String get basicDescription => 'Works well for short and mid-haul flights.';

	/// en: 'Real route'
	String get proTitle => 'Real route';

	/// en: 'By flight number'
	String get proSubtitle => 'By flight number';

	/// en: 'Based on recent historical flight data'
	String get proDescription => 'Based on recent historical flight data';

	/// en: 'Most accurate'
	String get mostAccurate => 'Most accurate';
}

// Path: createFlight.flightNumberSearch
class TranslationsCreateFlightFlightNumberSearchEn {
	TranslationsCreateFlightFlightNumberSearchEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Flight number'
	String get title => 'Flight number';

	/// en: 'Enter a flight number (for example BA117).'
	String get subtitle => 'Enter a flight number (for example BA117).';

	/// en: 'e.g. BA117'
	String get hint => 'e.g. BA117';

	/// en: 'Searching your flight'
	String get loading => 'Searching your flight';

	/// en: 'We couldn't find your flight. Edit number or find by airports'
	String get error => 'We couldn\'t find your flight. Edit number or find by airports';

	/// en: 'Find by Airports'
	String get findByAirports => 'Find by Airports';

	/// en: 'Confirm flight'
	String get confirmTitle => 'Confirm flight';

	/// en: 'We found your flight'
	String get foundTitle => 'We found your flight';
}

// Path: createFlight.search
class TranslationsCreateFlightSearchEn {
	TranslationsCreateFlightSearchEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Search departure airport'
	String get departureHint => 'Search departure airport';

	/// en: 'Search arrival airport'
	String get arrivalHint => 'Search arrival airport';

	/// en: 'Remove favorite'
	String get removeFavorite => 'Remove favorite';

	/// en: 'Add to favorite'
	String get addFavorite => 'Add to favorite';

	/// en: 'Remove selected airport'
	String get removeSelectedAirport => 'Remove selected airport';

	/// en: 'Favorites'
	String get favorites => 'Favorites';

	/// en: 'Recent airports'
	String get recentAirports => 'Recent airports';

	/// en: 'Popular airports'
	String get popularAirports => 'Popular airports';

	/// en: 'Remove from favorites'
	String get removeFromFavorites => 'Remove from favorites';

	/// en: 'No departure airports found.'
	String get noDepartureFound => 'No departure airports found.';

	/// en: 'No arrival airports found.'
	String get noArrivalFound => 'No arrival airports found.';

	/// en: '$code · $city'
	String airportCodeCity({required Object code, required Object city}) => '${code} · ${city}';

	/// en: '$name ($code)'
	String airportNameCode({required Object name, required Object code}) => '${name} (${code})';
}

// Path: createFlight.mapPreview
class TranslationsCreateFlightMapPreviewEn {
	TranslationsCreateFlightMapPreviewEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Sorry, antimeridian flights are not supported yet.'
	String get routeNotSupportedMsg => 'Sorry, antimeridian flights are not supported yet.';

	/// en: 'Basic'
	String get basic => 'Basic';

	/// en: 'Pro'
	String get pro => 'Pro';

	/// en: 'Route note'
	String get mapDetailInfoTooltip => 'Route note';

	/// en: 'Legend'
	String get legendButton => 'Legend';

	/// en: 'POI legend'
	String get legendTitle => 'POI legend';

	/// en: 'Estimated map size: $size'
	String estimatedMapSize({required Object size}) => 'Estimated map size: ${size}';

	/// en: 'Upgrade to Pro'
	String get upgradeToPro => 'Upgrade to Pro';

	/// en: 'Basic map detail with limited places'
	String get basicHint => 'Basic map detail with limited places';

	/// en: 'Upgrade for a detailed map with all places'
	String get proGateHint => 'Upgrade for a detailed map with all places';

	/// en: 'Detailed offline map with $count places'
	String proHint({required Object count}) => 'Detailed offline map with ${count} places';

	/// en: 'Approximate route'
	String get optionsTitle => 'Approximate route';

	/// en: 'Route is approximate — actual path may vary, especially on long-haul flights.'
	String get optionsBody => 'Route is approximate — actual path may vary, especially on long-haul flights.';
}

// Path: createFlight.overview
class TranslationsCreateFlightOverviewEn {
	TranslationsCreateFlightOverviewEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Route is not ready yet.'
	String get routeNotReady => 'Route is not ready yet.';

	/// en: 'Free plan includes basic map and limited places'
	String get proPoiUpsell => 'Free plan includes basic map and limited places';

	/// en: 'Route note'
	String get routeNoteTooltip => 'Route note';

	/// en: 'Approximate route'
	String get routeNoteTitle => 'Approximate route';

	/// en: 'Route is approximate — actual path may vary, especially on long-haul flights.'
	String get routeNoteBody => 'Route is approximate — actual path may vary, especially on long-haul flights.';

	/// en: 'Real route'
	String get realRouteNoteTitle => 'Real route';

	/// en: 'Route is based on recent historical data of the same flight.'
	String get realRouteNoteBody => 'Route is based on recent historical data of the same flight.';

	/// en: 'Approximate route may be inaccurate'
	String get approximateRouteLongHaulWarningTitle => 'Approximate route may be inaccurate';

	/// en: 'Approximate routes can be inaccurate for long-haul flights. Use a real route with a flight number instead.'
	String get approximateRouteLongHaulWarningBody => 'Approximate routes can be inaccurate for long-haul flights. Use a real route with a flight number instead.';

	/// en: 'Approximate routes are not supported for ultra long-haul flights. Use a real route with a flight number instead.'
	String get approximateRouteUltraLongHaulUnsupportedBody => 'Approximate routes are not supported for ultra long-haul flights. Use a real route with a flight number instead.';

	/// en: 'Start review'
	String get startReview => 'Start review';

	/// en: 'Skip review'
	String get skipReview => 'Skip review';

	/// en: 'Unlock full route overview'
	String get premiumGateTitle => 'Unlock full route overview';

	/// en: 'Free plan includes a limited route preview. Upgrade to Pro to view every region on this route.'
	String get premiumGateBody => 'Free plan includes a limited route preview. Upgrade to Pro to view every region on this route.';

	/// en: 'Unlock all $count regions on this route with Pro.'
	String premiumGateBodyWithCount({required Object count}) => 'Unlock all ${count} regions on this route with Pro.';

	/// en: 'Upgrade to Pro'
	String get premiumGateCta => 'Upgrade to Pro';

	/// en: 'Route reviewed'
	String get routeReviewedTitle => 'Route reviewed';

	/// en: 'You will fly over $regions from $departure to $arrival.'
	String routeReviewedSubtitle({required Object regions, required Object departure, required Object arrival}) => 'You will fly over ${regions} from ${departure} to ${arrival}.';

	/// en: 'Full summary'
	String get fullSummary => 'Full summary';

	/// en: 'Route Summary'
	String get routeSummaryTitle => 'Route Summary';

	/// en: 'Distance'
	String get routeSummaryDistanceLabel => 'Distance';

	/// en: 'Duration'
	String get routeSummaryDurationLabel => 'Duration';

	/// en: 'Regions'
	String get routeSummaryRegionsLabel => 'Regions';

	/// en: 'Places'
	String get routeSummaryPlacesLabel => 'Places';

	/// en: 'Timeline'
	String get routeSummaryTimelineTitle => 'Timeline';

	/// en: 'Places along the route'
	String get routeSummaryPlacesTitle => 'Places along the route';

	/// en: 'Search places'
	String get routeSummaryPoiSearchHint => 'Search places';

	/// en: 'No places match your search.'
	String get routeSummaryPoiNoMatches => 'No places match your search.';

	late final TranslationsCreateFlightOverviewAirportCardEn airportCard = TranslationsCreateFlightOverviewAirportCardEn.internal(_root);
	late final TranslationsCreateFlightOverviewRegionInfoEn regionInfo = TranslationsCreateFlightOverviewRegionInfoEn.internal(_root);
	late final TranslationsCreateFlightOverviewTimelineEn timeline = TranslationsCreateFlightOverviewTimelineEn.internal(_root);
}

// Path: createFlight.wikipedia
class TranslationsCreateFlightWikipediaEn {
	TranslationsCreateFlightWikipediaEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Download articles and read while you’re in the air'
	String get title => 'Download articles and read while you’re in the air';

	/// en: 'Finding route-related articles...'
	String get loadingIntro => 'Finding route-related articles...';

	/// en: 'Based on your route we found $count relevant articles'
	String foundIntro({required Object count}) => 'Based on your route we found ${count} relevant articles';

	/// en: 'No route-related Wikipedia articles found. You can continue with map download only.'
	String get emptyIntro => 'No route-related Wikipedia articles found. You can continue with map download only.';

	/// en: '$count selected'
	String selectedCount({required Object count}) => '${count} selected';

	/// en: 'Unselect all'
	String get unselectAll => 'Unselect all';

	/// en: 'Select all'
	String get selectAll => 'Select all';

	/// en: 'Offline articles selected: $count'
	String basicHint({required Object count}) => 'Offline articles selected: ${count}';

	/// en: 'Full offline article pack'
	String get proHint => 'Full offline article pack';

	/// en: 'Upgrade for the full offline article pack'
	String get proGateHint => 'Upgrade for the full offline article pack';

	/// en: 'Pro active'
	String get proActiveTitle => 'Pro active';

	/// en: 'Full articles pack unlocked.'
	String get proActiveMessage => 'Full articles pack unlocked.';

	/// en: 'Free plan includes up to 3 offline articles'
	String get freeLimitHint => 'Free plan includes up to 3 offline articles';

	/// en: 'Estimated download size: $size'
	String estimatedDownloadSize({required Object size}) => 'Estimated download size: ${size}';

	/// en: 'Upgrade to Pro'
	String get upgrade => 'Upgrade to Pro';

	/// en: 'Loading article suggestions...'
	String get loadingSuggestions => 'Loading article suggestions...';

	/// en: 'Download map'
	String get downloadMapOnly => 'Download map';

	/// en: 'Download map + 1 article'
	String get downloadMapPlusOne => 'Download map + 1 article';

	/// en: 'Download map + $count articles'
	String downloadMapPlusMany({required Object count}) => 'Download map + ${count} articles';

	/// en: 'Could not open link'
	String get couldNotOpenLink => 'Could not open link';
}

// Path: createFlight.downloading
class TranslationsCreateFlightDownloadingEn {
	TranslationsCreateFlightDownloadingEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Downloading selected articles...'
	String get articlesTitle => 'Downloading selected articles...';

	/// en: 'Downloading offline map...'
	String get mapTitle => 'Downloading offline map...';

	/// en: 'Map'
	String get mapSectionTitle => 'Map';

	/// en: 'Places'
	String get poiSectionTitle => 'Places';

	/// en: 'Articles'
	String get articlesSectionTitle => 'Articles';

	/// en: 'Cancel download'
	String get cancelDownload => 'Cancel download';

	/// en: 'Do not close this screen until download completes'
	String get doNotClose => 'Do not close this screen until download completes';

	/// en: 'Current'
	String get currentStep => 'Current';

	/// en: 'Pending'
	String get pending => 'Pending';

	/// en: 'In progress'
	String get inProgress => 'In progress';

	/// en: 'Completed'
	String get completed => 'Completed';

	/// en: 'Completed with issues'
	String get completedWithIssues => 'Completed with issues';

	/// en: 'Failed'
	String get failed => 'Failed';

	/// en: 'Skipped'
	String get skipped => 'Skipped';

	/// en: 'Waiting for map download...'
	String get waitingForMap => 'Waiting for map download...';

	/// en: 'Map download failed.'
	String get mapFailed => 'Map download failed.';

	/// en: 'No place summaries selected.'
	String get noPoiSelected => 'No place summaries selected.';

	/// en: 'Preparing place summaries...'
	String get preparingPoi => 'Preparing place summaries...';

	/// en: 'Places: $completed/$total'
	String poiProgress({required Object completed, required Object total}) => 'Places: ${completed}/${total}';

	/// en: 'Places: $completed/$total ($failed failed)'
	String poiProgressWithFailed({required Object completed, required Object total, required Object failed}) => 'Places: ${completed}/${total} (${failed} failed)';

	/// en: 'No articles selected.'
	String get noArticlesSelected => 'No articles selected.';

	/// en: 'Preparing article downloads...'
	String get preparingArticles => 'Preparing article downloads...';

	/// en: 'Articles: $completed/$total'
	String articlesProgress({required Object completed, required Object total}) => 'Articles: ${completed}/${total}';

	/// en: 'Articles: $completed/$total ($failed failed)'
	String articlesProgressWithFailed({required Object completed, required Object total, required Object failed}) => 'Articles: ${completed}/${total} (${failed} failed)';

	/// en: 'Preparing map download...'
	String get preparingMap => 'Preparing map download...';

	/// en: 'Computing map tiles...'
	String get computingTiles => 'Computing map tiles...';

	/// en: 'Computing map tiles ($count)...'
	String computingTilesWithCount({required Object count}) => 'Computing map tiles (${count})...';

	/// en: 'Preparing for download...'
	String get preparingForDownload => 'Preparing for download...';

	/// en: 'Downloaded: $size'
	String downloaded({required Object size}) => 'Downloaded: ${size}';

	/// en: 'Finalizing map package...'
	String get finalizing => 'Finalizing map package...';

	/// en: 'Verifying map package...'
	String get verifying => 'Verifying map package...';
}

// Path: createFlight.errors
class TranslationsCreateFlightErrorsEn {
	TranslationsCreateFlightErrorsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Failed to load airports. Please try again.'
	String get failedLoadAirports => 'Failed to load airports. Please try again.';

	/// en: 'Airport search failed. Try another query.'
	String get airportSearchFailed => 'Airport search failed. Try another query.';

	/// en: 'Some articles failed. Continuing with map download.'
	String get someArticlesFailed => 'Some articles failed. Continuing with map download.';

	/// en: 'Map downloaded. Some optional content could not be downloaded.'
	String get someOptionalDownloadsFailed => 'Map downloaded. Some optional content could not be downloaded.';

	/// en: 'Failed to build route preview. Please try again.'
	String get failedBuildPreview => 'Failed to build route preview. Please try again.';

	/// en: 'Could not load route overview. You can still continue.'
	String get overviewUnavailableContinue => 'Could not load route overview. You can still continue.';

	/// en: 'No internet connection. Please check your connection and try again.'
	String get noInternet => 'No internet connection. Please check your connection and try again.';

	/// en: 'Failed to start download: $error'
	String failedStartDownload({required Object error}) => 'Failed to start download: ${error}';
}

// Path: createFlight.paywall
class TranslationsCreateFlightPaywallEn {
	TranslationsCreateFlightPaywallEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Upgrade cancelled.'
	String get upgradeCancelled => 'Upgrade cancelled.';

	/// en: 'No paywall available right now.'
	String get noPaywall => 'No paywall available right now.';

	/// en: 'Failed to open paywall.'
	String get failedOpenPaywall => 'Failed to open paywall.';
}

// Path: flight.map
class TranslationsFlightMapEn {
	TranslationsFlightMapEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Loading map'
	String get initializing => 'Loading map';

	/// en: 'Loading map'
	String get loadingStyle => 'Loading map';

	/// en: 'Offline map is not available for this flight.'
	String get offlineNotAvailable => 'Offline map is not available for this flight.';

	/// en: 'Offline map file is missing. Please re-download this route.'
	String get offlineMissing => 'Offline map file is missing. Please re-download this route.';

	/// en: 'Offline map validation failed. Please re-download this route.'
	String get validationFailed => 'Offline map validation failed. Please re-download this route.';

	/// en: 'Could not load offline map style.'
	String get loadStyleFailed => 'Could not load offline map style.';

	/// en: 'Switch to 2D'
	String get switchTo2D => 'Switch to 2D';

	/// en: 'Switch to 3D'
	String get switchTo3D => 'Switch to 3D';

	/// en: 'Uncenter map'
	String get uncenterMap => 'Uncenter map';

	/// en: 'Center on me'
	String get centerOnMe => 'Center on me';
}

// Path: flight.dashboard
class TranslationsFlightDashboardEn {
	TranslationsFlightDashboardEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Location services are off'
	String get gpsOffTitle => 'Location services are off';

	/// en: 'Turn on location services in system settings to resume live flight tracking and map following.'
	String get gpsOffSubtitle => 'Turn on location services in system settings to resume live flight tracking and map following.';

	/// en: 'Open location settings'
	String get openLocationSettings => 'Open location settings';

	/// en: 'Location permission required'
	String get permissionTitle => 'Location permission required';

	/// en: 'Allow location access so the dashboard can show live heading, speed, and altitude.'
	String get permissionSubtitle => 'Allow location access so the dashboard can show live heading, speed, and altitude.';

	/// en: 'Grant permissions'
	String get grantPermissions => 'Grant permissions';

	/// en: 'GPS Accuracy: $label (±$accuracy m)'
	String gpsAccuracy({required Object label, required Object accuracy}) => 'GPS Accuracy: ${label} (±${accuracy} m)';

	/// en: 'Excellent'
	String get accuracyExcellent => 'Excellent';

	/// en: 'Good'
	String get accuracyGood => 'Good';

	/// en: 'Poor'
	String get accuracyPoor => 'Poor';

	/// en: 'GPS off'
	String get gpsOff => 'GPS off';

	/// en: 'Enable location services to start tracking.'
	String get gpsOffHint => 'Enable location services to start tracking.';

	/// en: 'Location permission required'
	String get gpsPermissionRequired => 'Location permission required';

	/// en: 'Grant permission to access live flight telemetry.'
	String get gpsPermissionHint => 'Grant permission to access live flight telemetry.';

	/// en: 'Searching for GPS'
	String get gpsSearching => 'Searching for GPS';

	/// en: 'Looking for a reliable signal'
	String get gpsSearchingHint => 'Looking for a reliable signal';

	/// en: 'Weak GPS signal'
	String get gpsWeak => 'Weak GPS signal';

	/// en: 'Signal is unstable. Keep device in open sky.'
	String get gpsWeakHint => 'Signal is unstable. Keep device in open sky.';

	/// en: 'Signal unstable. Last fix $age.'
	String gpsWeakHintWithAge({required Object age}) => 'Signal unstable. Last fix ${age}.';

	/// en: 'GPS active'
	String get gpsActive => 'GPS active';

	/// en: 'Receiving live telemetry.'
	String get gpsActiveHint => 'Receiving live telemetry.';

	/// en: 'Last GPS update $age.'
	String gpsActiveHintWithAge({required Object age}) => 'Last GPS update ${age}.';

	/// en: 'just now'
	String get ageJustNow => 'just now';

	/// en: '$seconds s ago'
	String ageSeconds({required Object seconds}) => '${seconds} s ago';

	/// en: '$minutes m ago'
	String ageMinutes({required Object minutes}) => '${minutes} m ago';

	/// en: 'Good'
	String get signalGood => 'Good';

	/// en: 'Poor'
	String get signalPoor => 'Poor';

	/// en: 'Bad'
	String get signalBad => 'Bad';

	/// en: 'Searching'
	String get signalSearching => 'Searching';

	/// en: 'GPS $quality'
	String gpsQuality({required Object quality}) => 'GPS ${quality}';

	/// en: 'GPS searching'
	String get gpsSearchingLabel => 'GPS searching';

	/// en: 'GPS permission needed'
	String get gpsPermissionNeededLabel => 'GPS permission needed';

	/// en: 'GPS off'
	String get gpsOffLabel => 'GPS off';

	/// en: 'Aircraft heading'
	String get aircraftHeading => 'Aircraft heading';

	/// en: 'HDG $heading°'
	String headingShort({required Object heading}) => 'HDG ${heading}°';

	/// en: 'Live instruments'
	String get liveInstruments => 'Live instruments';

	/// en: 'Acquiring GPS signal'
	String get acquiringGpsSignal => 'Acquiring GPS signal';

	/// en: 'Keep the device steady and in open sky for a reliable fix.'
	String get acquiringGpsHint => 'Keep the device steady and in open sky for a reliable fix.';

	/// en: 'Weak GPS signal. Values may drift until accuracy improves.'
	String get weakSignalBanner => 'Weak GPS signal. Values may drift until accuracy improves.';

	/// en: 'Preparing dashboard...'
	String get preparingDashboard => 'Preparing dashboard...';

	/// en: 'Navigation'
	String get navigation => 'Navigation';

	/// en: 'Heading $heading'
	String heading({required Object heading}) => 'Heading ${heading}';

	/// en: 'Route progress'
	String get routeProgress => 'Route progress';

	/// en: 'Covered'
	String get covered => 'Covered';

	/// en: 'Remaining'
	String get remaining => 'Remaining';

	/// en: 'Total'
	String get total => 'Total';
}

// Path: flight.upcoming
class TranslationsFlightUpcomingEn {
	TranslationsFlightUpcomingEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Begin your flight journey'
	String get mapTitle => 'Begin your flight journey';

	/// en: 'Start live tracking once your flight begins'
	String get mapSubtitle => 'Start live tracking once your flight begins';

	/// en: 'Begin your flight journey'
	String get dashboardTitle => 'Begin your flight journey';

	/// en: 'Start to see your live dashboard'
	String get dashboardSubtitle => 'Start to see your live dashboard';

	/// en: 'Start'
	String get checkInButton => 'Start';

	/// en: 'Could not start now. Please try again'
	String get checkInError => 'Could not start now. Please try again';
}

// Path: flight.info
class TranslationsFlightInfoEn {
	TranslationsFlightInfoEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Overview'
	String get overviewTitle => 'Overview';

	/// en: 'Building route overview...'
	String get overviewLoading => 'Building route overview...';

	/// en: 'Overview is not available yet for this route.'
	String get overviewEmpty => 'Overview is not available yet for this route.';

	/// en: 'Loading route information...'
	String get loadingRouteInformation => 'Loading route information...';

	/// en: 'Highlights of your route'
	String get flyOverTitle => 'Highlights of your route';

	/// en: 'Airports'
	String get airportsTitle => 'Airports';

	/// en: 'Departure'
	String get departure => 'Departure';

	/// en: 'Arrival'
	String get arrival => 'Arrival';

	/// en: 'Show all'
	String get showAll => 'Show all';

	/// en: 'Show all $count'
	String showAllCount({required Object count}) => 'Show all ${count}';

	/// en: 'Show less'
	String get showLess => 'Show less';

	/// en: 'By rank'
	String get sortByRank => 'By rank';

	/// en: 'By route'
	String get sortByRouteProgress => 'By route';

	/// en: 'By type'
	String get sortByType => 'By type';

	/// en: 'Route timeline'
	String get routeTimelineTitle => 'Route timeline';

	/// en: '$count planned waypoints'
	String plannedWaypoints({required Object count}) => '${count} planned waypoints';

	/// en: 'Points of Interest'
	String get pointsOfInterestTitle => 'Points of Interest';

	/// en: 'No POIs available yet.'
	String get noPoi => 'No POIs available yet.';

	/// en: 'Type: $type'
	String poiType({required Object type}) => 'Type: ${type}';

	/// en: 'Fly-over: $view'
	String poiFlyOver({required Object view}) => 'Fly-over: ${view}';

	/// en: 'Offline Articles'
	String get offlineArticlesTitle => 'Offline Articles';

	/// en: 'Region articles'
	String get regionArticlesTitle => 'Region articles';

	/// en: 'Other articles'
	String get otherArticlesTitle => 'Other articles';

	/// en: 'No offline articles downloaded.'
	String get noOfflineArticles => 'No offline articles downloaded.';

	/// en: 'Open Source'
	String get openSource => 'Open Source';

	/// en: 'Open source page'
	String get openSourcePageTooltip => 'Open source page';

	/// en: '$distance km'
	String distanceKm({required Object distance}) => '${distance} km';

	/// en: 'Speed'
	String get speed => 'Speed';

	/// en: 'Altitude'
	String get altitude => 'Altitude';

	/// en: 'Flymap Route'
	String get copyRouteTitle => 'Flymap Route';

	/// en: 'Route code: $routeCode'
	String copyRouteCode({required Object routeCode}) => 'Route code: ${routeCode}';

	/// en: 'Distance: $distance km'
	String copyDistance({required Object distance}) => 'Distance: ${distance} km';

	/// en: 'From'
	String get copyFrom => 'From';

	/// en: 'To'
	String get copyTo => 'To';

	/// en: 'City: $city, $countryCode'
	String copyCity({required Object city, required Object countryCode}) => 'City: ${city}, ${countryCode}';

	/// en: 'Airport: $airport'
	String copyAirport({required Object airport}) => 'Airport: ${airport}';

	/// en: 'Codes: IATA $iata | ICAO $icao'
	String copyCodes({required Object iata, required Object icao}) => 'Codes: IATA ${iata} | ICAO ${icao}';
}

// Path: flight.route
class TranslationsFlightRouteEn {
	TranslationsFlightRouteEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Loading route timeline...'
	String get loadingRouteTimeline => 'Loading route timeline...';

	/// en: 'No saved offline regions for this flight.'
	String get noSavedOfflineRegions => 'No saved offline regions for this flight.';

	/// en: 'Current progress: $percentage% (around $minute from takeoff)'
	String currentProgress({required Object percentage, required Object minute}) => 'Current progress: ${percentage}% (around ${minute} from takeoff)';

	/// en: 'Now'
	String get nowLabel => 'Now';

	/// en: 'Current'
	String get currentRegionLabel => 'Current';

	/// en: 'Next'
	String get nextRegionLabel => 'Next';

	/// en: 'ETA: $time'
	String etaLabel({required Object time}) => 'ETA: ${time}';

	/// en: 'You are flying over:'
	String get flyingOverLabel => 'You are flying over:';

	/// en: 'Unlock'
	String get premiumLockedChipLabel => 'Unlock';

	/// en: 'Unlock full route timeline'
	String get premiumGateTitle => 'Unlock full route timeline';

	/// en: 'Upgrade to Pro to see all regions along your route and timeline details.'
	String get premiumGateBody => 'Upgrade to Pro to see all regions along your route and timeline details.';

	/// en: 'Unlock all $count regions on this route with Premium.'
	String premiumGateBodyWithCount({required Object count}) => 'Unlock all ${count} regions on this route with Premium.';

	/// en: 'Subscribe to Premium'
	String get premiumGateCta => 'Subscribe to Premium';

	/// en: 'Internet needed to upgrade'
	String get premiumOfflineTitle => 'Internet needed to upgrade';

	/// en: 'You are offline right now. Connect to the internet to upgrade and unlock the full route view.'
	String get premiumOfflineBody => 'You are offline right now. Connect to the internet to upgrade and unlock the full route view.';

	/// en: 'Next: $region ($eta)'
	String nextHintLabel({required Object region, required Object eta}) => 'Next: ${region} (${eta})';

	/// en: 'estimating...'
	String get etaUnknownLabel => 'estimating...';
}

// Path: createFlight.overview.airportCard
class TranslationsCreateFlightOverviewAirportCardEn {
	TranslationsCreateFlightOverviewAirportCardEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'You'll start your journey from $airport.'
	String departureDescription({required Object airport}) => 'You\'ll start your journey from ${airport}.';

	/// en: 'You'll arrive at $airport.'
	String arrivalDescription({required Object airport}) => 'You\'ll arrive at ${airport}.';
}

// Path: createFlight.overview.regionInfo
class TranslationsCreateFlightOverviewRegionInfoEn {
	TranslationsCreateFlightOverviewRegionInfoEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Description is not available yet.'
	String get descriptionUnavailable => 'Description is not available yet.';

	/// en: 'Wikipedia'
	String get wikipediaSectionTitle => 'Wikipedia';

	/// en: 'Wikipedia article is not available right now.'
	String get wikipediaUnavailable => 'Wikipedia article is not available right now.';

	/// en: 'Open Wikipedia'
	String get openWikipedia => 'Open Wikipedia';
}

// Path: createFlight.overview.timeline
class TranslationsCreateFlightOverviewTimelineEn {
	TranslationsCreateFlightOverviewTimelineEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Take off'
	String get takeOffTimeline => 'Take\noff';

	/// en: 'Land'
	String get land => 'Land';

	/// en: 'Also around same time:'
	String get alsoAroundThisTime => 'Also around same time:';

	/// en: 'min'
	String get minuteUnit => 'min';

	/// en: 'h'
	String get hourCompactUnit => 'h';

	/// en: 'm'
	String get minuteCompactUnit => 'm';

	late final TranslationsCreateFlightOverviewTimelineRegionTypeEn regionType = TranslationsCreateFlightOverviewTimelineRegionTypeEn.internal(_root);
}

// Path: createFlight.overview.timeline.regionType
class TranslationsCreateFlightOverviewTimelineRegionTypeEn {
	TranslationsCreateFlightOverviewTimelineRegionTypeEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Country'
	String get country => 'Country';

	/// en: 'Region'
	String get region => 'Region';

	/// en: 'State'
	String get state => 'State';

	/// en: 'Province'
	String get province => 'Province';

	/// en: 'Sea'
	String get sea => 'Sea';

	/// en: 'Ocean'
	String get ocean => 'Ocean';

	/// en: 'Strait'
	String get strait => 'Strait';

	/// en: 'Channel'
	String get channel => 'Channel';

	/// en: 'Gulf'
	String get gulf => 'Gulf';

	/// en: 'Bay'
	String get bay => 'Bay';

	/// en: 'Lake'
	String get lake => 'Lake';

	/// en: 'Alkaline lake'
	String get alkalineLake => 'Alkaline lake';

	/// en: 'Island'
	String get island => 'Island';

	/// en: 'Archipelago'
	String get archipelago => 'Archipelago';

	/// en: 'Peninsula'
	String get peninsula => 'Peninsula';

	/// en: 'Coast'
	String get coast => 'Coast';

	/// en: 'Mountain range'
	String get mountainRange => 'Mountain range';

	/// en: 'Valley'
	String get valley => 'Valley';

	/// en: 'Plateau'
	String get plateau => 'Plateau';

	/// en: 'Plain'
	String get plain => 'Plain';

	/// en: 'Basin'
	String get basin => 'Basin';

	/// en: 'Lowland'
	String get lowland => 'Lowland';

	/// en: 'Tundra'
	String get tundra => 'Tundra';

	/// en: 'Wetlands'
	String get wetlands => 'Wetlands';

	/// en: 'Desert'
	String get desert => 'Desert';

	/// en: 'Delta'
	String get delta => 'Delta';

	/// en: 'Reservoir'
	String get reservoir => 'Reservoir';

	/// en: 'Continent'
	String get continent => 'Continent';

	/// en: 'Geographic area'
	String get geoarea => 'Geographic area';

	/// en: 'Isthmus'
	String get isthmus => 'Isthmus';

	/// en: 'Unknown region type'
	String get unknown => 'Unknown region type';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'appName' => 'Flymap',
			'common.kContinue' => 'Continue',
			'common.back' => 'Back',
			'common.cancel' => 'Cancel',
			'common.ok' => 'OK',
			'common.retry' => 'Retry',
			'common.manage' => 'Manage',
			'common.edit' => 'Edit',
			'common.upgrade' => 'Upgrade',
			'common.loading' => 'Loading...',
			'common.readMore' => 'Read more',
			'common.pro' => 'PRO',
			'common.search' => 'Search',
			'home.title' => 'Home',
			'home.aboutTooltip' => 'About',
			'home.settingsTooltip' => 'Settings',
			'home.tabFlights' => 'Flights',
			'home.tabLearn' => 'Learn',
			'home.loadingFlights' => 'Loading flights...',
			'home.failedToLoadFlights' => 'Failed to load flights',
			'home.newFlight' => 'New flight',
			'home.addFirstFlight' => 'Add first flight',
			'home.addNextFlight' => 'Add next flight',
			'home.welcomeTitle' => 'Welcome to Flymap',
			'home.welcomeTitlePro' => 'Welcome to Flymap Pro',
			'home.welcomeSubtitle' => 'Offline maps for flights',
			'home.greetingOnline' => 'Ready for the next flight?',
			'home.greetingOnlineWithName' => ({required Object name}) => 'Hi ${name}, ready for the next flight?',
			'home.greetingOffline' => 'Ready to explore your flight?',
			'home.greetingOfflineWithName' => ({required Object name}) => 'Hi ${name}, ready to explore your flight?',
			'home.greetingInProgress' => 'Your flight is in progress',
			'home.greetingInProgressWithName' => ({required Object name}) => 'Hi ${name}, your flight is in progress',
			'home.totalFlights' => 'Total flights',
			'home.storageUsed' => 'Storage used',
			'home.totalDistance' => 'Total distance',
			'home.upcomingFlightsCount' => ({required Object count}) => 'Upcoming flights (${count})',
			'home.flightInProgressTitle' => 'Flight in progress',
			'home.noFlightsTitle' => 'Ready to explore the world from above?',
			'home.noFlightsSubtitle' => 'Add your first flight and start discovering your next journey.',
			'home.noFlightsTitleNext' => 'Ready for your next trip?',
			'home.noFlightsSubtitleNext' => 'Your completed flights are in History. Add your next flight to keep going.',
			'home.flightActions' => 'Flight actions',
			'home.viewAll' => 'View all',
			'home.open' => 'Open',
			'home.shareRoute' => 'Share route',
			'home.completeFlight' => 'Archive flight',
			'home.deleteFlight' => 'Delete flight',
			'home.failedDeleteFlight' => 'Failed to delete flight',
			'home.noOfflineMap' => 'No offline map',
			'home.placesCount' => ({required Object count}) => '${count} places',
			'home.offlineArticlesCount' => ({required Object count}) => '${count} articles',
			'home.savedTime' => ({required Object time}) => 'Saved ${time}',
			'home.justNow' => 'Just now',
			'home.daysAgo' => ({required Object days}) => '${days} d ago',
			'home.hoursAgo' => ({required Object hours}) => '${hours} h ago',
			'home.minutesAgo' => ({required Object minutes}) => '${minutes} m ago',
			'home.sort.mostRecent' => 'Most recent',
			'home.sort.longest' => 'Longest',
			'home.sort.alphabetical' => 'A-Z',
			'learn.loadingCategories' => 'Loading learning categories...',
			'learn.failedToLoadCategories' => 'Failed to load categories',
			'learn.emptyCategoriesTitle' => 'No categories yet',
			'learn.emptyCategoriesSubtitle' => 'Learning categories will appear here soon.',
			'learn.articlesCount' => ({required Object count}) => '${count} articles',
			'learn.loadingArticles' => 'Loading articles...',
			'learn.failedToLoadArticles' => 'Failed to load articles',
			'learn.emptyArticlesTitle' => 'No articles yet',
			'learn.emptyArticlesSubtitle' => 'Articles for this category will appear soon.',
			'learn.upgradeRequiresInternet' => 'Premium content is available with Pro. Connect to the internet to upgrade.',
			'learn.proListPreviewHint' => 'You can browse these article titles now. Unlock reading with Flymap Pro.',
			'learn.failedToLoadArticle' => 'Could not open this article right now.',
			'settings.title' => 'Settings',
			'settings.loading' => 'Loading settings...',
			'settings.profile' => 'Profile',
			'settings.profileSubtitle' => 'Name, flying habits, home airport, and interests',
			'settings.profileSummaryNameHome' => ({required Object name, required Object code}) => '${name} · ${code}',
			'settings.profileSummaryHome' => ({required Object code}) => 'Home airport: ${code}',
			'settings.profileEditHint' => 'Tap any item to edit your profile details.',
			'settings.profileNotSet' => 'Not set',
			'settings.profileInterestsSelected' => ({required Object count}) => '${count} selected',
			'settings.historyTitle' => 'History',
			'settings.historySubtitle' => 'All flights and stats',
			'settings.historyLoading' => 'Loading history...',
			'settings.historyLoadError' => 'Failed to load flight history.',
			'settings.historyFlightsLabel' => 'Total flights',
			'settings.historyDistanceLabel' => 'Total distance',
			'settings.historyAllFlights' => 'All flights',
			'settings.historyStatusUpcoming' => 'Upcoming',
			'settings.historyStatusInProgress' => 'In progress',
			'settings.historyStatusCompleted' => 'Completed',
			'settings.historyMapChip' => ({required Object size}) => 'Map ${size}',
			'settings.historyNoMapChip' => 'No map',
			'settings.historySortName' => 'Name',
			'settings.historySortDistance' => 'Distance',
			'settings.historySortDate' => 'Date',
			'settings.historyEmpty' => 'No flights yet.',
			'settings.historySearchHint' => 'Search by airport or city',
			'settings.historyNoResults' => 'No matching flights found.',
			'settings.historyDeleteOfflineData' => 'Delete map only',
			'settings.appearance' => 'Appearance',
			'settings.theme' => 'Theme',
			'settings.system' => 'System',
			'settings.dark' => 'Dark',
			'settings.light' => 'Light',
			'settings.units' => 'Units',
			'settings.storage' => 'Storage',
			'settings.storageTitle' => 'Storage',
			'settings.storageSubtitle' => 'Downloaded maps and disk usage',
			'settings.storageLoading' => 'Loading storage...',
			'settings.storageLoadError' => 'Failed to load storage data.',
			'settings.storageMapsLabel' => 'Downloaded maps',
			'settings.storageTotalSizeLabel' => 'Total size',
			'settings.storageDownloadedMaps' => 'Downloaded maps',
			'settings.storageSortName' => 'Name',
			'settings.storageSortSize' => 'Size',
			'settings.storageMapSize' => ({required Object size}) => 'Size: ${size}',
			'settings.storageEmpty' => 'No downloaded maps yet.',
			'settings.altitude' => 'Altitude',
			'settings.altitudeUnit' => 'Altitude unit',
			'settings.speed' => 'Speed',
			'settings.speedUnit' => 'Speed unit',
			'settings.timeFormat' => 'Time format',
			'settings.distanceUnit' => 'Distance unit',
			'settings.dateFormat' => 'Date format',
			'settings.support' => 'Support',
			'settings.about' => 'About',
			'settings.aboutSubtitle' => 'Learn more about the app',
			'settings.privacyPolicy' => 'Privacy Policy',
			'settings.privacyPolicySubtitle' => 'Read our privacy policy',
			'settings.termsOfService' => 'Terms of Service',
			'settings.termsOfServiceSubtitle' => 'Read our terms of service',
			'settings.flymapProActivated' => 'Flymap Pro activated.',
			'settings.upgradeCancelled' => 'Upgrade cancelled.',
			'settings.noPaywall' => 'No paywall available right now.',
			'settings.failedOpenPaywall' => 'Failed to open paywall.',
			'settings.couldNotOpenUrl' => ({required Object url}) => 'Could not open ${url}',
			'settings.rateUs' => 'Rate us',
			'settings.rateUsSubtitle' => 'Leave a review on the store',
			'settings.leaveFeedback' => 'Leave a Feedback',
			'settings.leaveFeedbackSubtitle' => 'Share your thoughts to help us improve',
			'settings.couldNotOpenStorePage' => 'Could not open store page',
			'settings.rateDialogTitle' => 'Do you like the app?',
			'settings.rateDialogBody' => 'We work hard to make every flight more enjoyable, and your feedback really helps us improve.',
			'settings.rateDialogYes' => 'Yes',
			'settings.rateDialogNo' => 'No',
			'settings.feedbackTitle' => 'Leave a Feedback',
			'settings.feedbackBody' => 'Help us to make Flymap better',
			'settings.feedbackCategoryTitle' => 'Feedback type',
			'settings.feedbackCategoryGeneral' => 'General',
			'settings.feedbackCategoryFeatureRequest' => 'Feature request',
			'settings.feedbackCategoryBugReport' => 'Bug report',
			'settings.feedbackHint' => 'Share your feedback...',
			'settings.feedbackEmailHint' => 'Email (optional)',
			'settings.feedbackEmailInvalid' => 'Please enter a valid email or leave it empty.',
			'settings.feedbackSend' => 'Send',
			'settings.feedbackThanks' => 'Thanks for sharing your feedback!',
			'settings.feedbackSendFailed' => 'Couldn\'t send feedback. Please try again.',
			'settings.proBannerTitle' => 'Flymap Pro',
			'settings.proBannerTitleActive' => 'Flymap Pro Active',
			'settings.proBannerSubtitleActive' => 'Detailed map mode and full offline article bundles unlocked.',
			'settings.proBannerSubtitleFree' => 'Unlock detailed maps and full offline article bundles',
			'settings.proBannerBadgeActive' => 'PRO ACTIVE',
			'subscription.screenTitle' => 'Subscription',
			'subscription.pullToRefresh' => 'Pull down to refresh your subscription status.',
			'subscription.needHelp' => 'Need help?',
			'subscription.contactSupport' => 'Contact support',
			'subscription.cardTitle' => 'Flymap Pro',
			'subscription.proFeaturesTitle' => 'What Flymap Pro unlocks',
			'subscription.proFeatureMapsTitle' => 'Detailed offline maps',
			'subscription.proFeatureMapsText' => 'Get higher-detail offline maps for your saved routes.',
			'subscription.proFeaturePoiTitle' => 'More route discoveries',
			'subscription.proFeaturePoiText' => 'See more interesting places along your route.',
			'subscription.proFeatureArticlesTitle' => 'Unlimited offline articles',
			'subscription.proFeatureArticlesText' => 'Read offline articles without the Free plan limit.',
			'subscription.checkingStatus' => 'Checking your subscription status...',
			'subscription.proActive' => 'Flymap Pro is active.',
			'subscription.freePlan' => 'You are on Free plan.',
			'subscription.status' => 'Status',
			'subscription.active' => 'Active',
			'subscription.notActive' => 'Not active',
			'subscription.entitlement' => 'Entitlement',
			'subscription.expires' => 'Expires',
			'subscription.noExpiration' => 'No expiration',
			'subscription.lastUpdate' => 'Last update',
			'subscription.unknown' => 'Unknown',
			'subscription.manageSubscription' => 'Manage subscription',
			'subscription.upgradeToPro' => 'Upgrade to Pro',
			'subscription.proManageHint' => 'You can cancel or change billing in your App Store or Google Play subscription settings.',
			'subscription.freeUpgradeHint' => 'Upgrade to Pro for detailed offline maps, more route discoveries, and unlimited offline articles.',
			'subscription.supportEmailSubject' => 'Flymap subscription support',
			'subscription.couldNotOpenEmailApp' => 'Could not open email app',
			'subscription.couldNotOpenSubscriptionSettings' => 'Could not open subscription settings',
			'subscription.proRestored' => 'Flymap Pro restored.',
			'subscription.failedOpenPaywall' => 'Failed to open paywall.',
			'subscription.serviceUnavailable' => 'Subscription service is temporarily unavailable.',
			'createFlight.steps.departureTitle' => 'Choose departure airport',
			'createFlight.steps.arrivalTitle' => 'Choose arrival airport',
			'createFlight.steps.routeNotSupportedTitle' => 'Route not supported',
			'createFlight.steps.mapPreviewTitle' => 'Map preview',
			'createFlight.steps.overviewTitle' => 'Route overview',
			'createFlight.steps.wikipediaTitle' => 'Wikipedia articles',
			'createFlight.routeTypeSelector.title' => 'New flight',
			'createFlight.routeTypeSelector.basicTitle' => 'Approximate route',
			'createFlight.routeTypeSelector.basicSubtitle' => 'By airports',
			'createFlight.routeTypeSelector.basicDescription' => 'Works well for short and mid-haul flights.',
			'createFlight.routeTypeSelector.proTitle' => 'Real route',
			'createFlight.routeTypeSelector.proSubtitle' => 'By flight number',
			'createFlight.routeTypeSelector.proDescription' => 'Based on recent historical flight data',
			'createFlight.routeTypeSelector.mostAccurate' => 'Most accurate',
			'createFlight.flightNumberSearch.title' => 'Flight number',
			'createFlight.flightNumberSearch.subtitle' => 'Enter a flight number (for example BA117).',
			'createFlight.flightNumberSearch.hint' => 'e.g. BA117',
			'createFlight.flightNumberSearch.loading' => 'Searching your flight',
			'createFlight.flightNumberSearch.error' => 'We couldn\'t find your flight. Edit number or find by airports',
			'createFlight.flightNumberSearch.findByAirports' => 'Find by Airports',
			'createFlight.flightNumberSearch.confirmTitle' => 'Confirm flight',
			'createFlight.flightNumberSearch.foundTitle' => 'We found your flight',
			'createFlight.search.departureHint' => 'Search departure airport',
			'createFlight.search.arrivalHint' => 'Search arrival airport',
			'createFlight.search.removeFavorite' => 'Remove favorite',
			'createFlight.search.addFavorite' => 'Add to favorite',
			'createFlight.search.removeSelectedAirport' => 'Remove selected airport',
			'createFlight.search.favorites' => 'Favorites',
			'createFlight.search.recentAirports' => 'Recent airports',
			'createFlight.search.popularAirports' => 'Popular airports',
			'createFlight.search.removeFromFavorites' => 'Remove from favorites',
			'createFlight.search.noDepartureFound' => 'No departure airports found.',
			'createFlight.search.noArrivalFound' => 'No arrival airports found.',
			'createFlight.search.airportCodeCity' => ({required Object code, required Object city}) => '${code} · ${city}',
			'createFlight.search.airportNameCode' => ({required Object name, required Object code}) => '${name} (${code})',
			'createFlight.mapPreview.routeNotSupportedMsg' => 'Sorry, antimeridian flights are not supported yet.',
			'createFlight.mapPreview.basic' => 'Basic',
			'createFlight.mapPreview.pro' => 'Pro',
			'createFlight.mapPreview.mapDetailInfoTooltip' => 'Route note',
			'createFlight.mapPreview.legendButton' => 'Legend',
			'createFlight.mapPreview.legendTitle' => 'POI legend',
			'createFlight.mapPreview.estimatedMapSize' => ({required Object size}) => 'Estimated map size: ${size}',
			'createFlight.mapPreview.upgradeToPro' => 'Upgrade to Pro',
			'createFlight.mapPreview.basicHint' => 'Basic map detail with limited places',
			'createFlight.mapPreview.proGateHint' => 'Upgrade for a detailed map with all places',
			'createFlight.mapPreview.proHint' => ({required Object count}) => 'Detailed offline map with ${count} places',
			'createFlight.mapPreview.optionsTitle' => 'Approximate route',
			'createFlight.mapPreview.optionsBody' => 'Route is approximate — actual path may vary, especially on long-haul flights.',
			'createFlight.overview.routeNotReady' => 'Route is not ready yet.',
			'createFlight.overview.proPoiUpsell' => 'Free plan includes basic map and limited places',
			'createFlight.overview.routeNoteTooltip' => 'Route note',
			'createFlight.overview.routeNoteTitle' => 'Approximate route',
			'createFlight.overview.routeNoteBody' => 'Route is approximate — actual path may vary, especially on long-haul flights.',
			'createFlight.overview.realRouteNoteTitle' => 'Real route',
			'createFlight.overview.realRouteNoteBody' => 'Route is based on recent historical data of the same flight.',
			'createFlight.overview.approximateRouteLongHaulWarningTitle' => 'Approximate route may be inaccurate',
			'createFlight.overview.approximateRouteLongHaulWarningBody' => 'Approximate routes can be inaccurate for long-haul flights. Use a real route with a flight number instead.',
			'createFlight.overview.approximateRouteUltraLongHaulUnsupportedBody' => 'Approximate routes are not supported for ultra long-haul flights. Use a real route with a flight number instead.',
			'createFlight.overview.startReview' => 'Start review',
			'createFlight.overview.skipReview' => 'Skip review',
			'createFlight.overview.premiumGateTitle' => 'Unlock full route overview',
			'createFlight.overview.premiumGateBody' => 'Free plan includes a limited route preview. Upgrade to Pro to view every region on this route.',
			'createFlight.overview.premiumGateBodyWithCount' => ({required Object count}) => 'Unlock all ${count} regions on this route with Pro.',
			'createFlight.overview.premiumGateCta' => 'Upgrade to Pro',
			'createFlight.overview.routeReviewedTitle' => 'Route reviewed',
			'createFlight.overview.routeReviewedSubtitle' => ({required Object regions, required Object departure, required Object arrival}) => 'You will fly over ${regions} from ${departure} to ${arrival}.',
			'createFlight.overview.fullSummary' => 'Full summary',
			'createFlight.overview.routeSummaryTitle' => 'Route Summary',
			'createFlight.overview.routeSummaryDistanceLabel' => 'Distance',
			'createFlight.overview.routeSummaryDurationLabel' => 'Duration',
			'createFlight.overview.routeSummaryRegionsLabel' => 'Regions',
			'createFlight.overview.routeSummaryPlacesLabel' => 'Places',
			'createFlight.overview.routeSummaryTimelineTitle' => 'Timeline',
			'createFlight.overview.routeSummaryPlacesTitle' => 'Places along the route',
			'createFlight.overview.routeSummaryPoiSearchHint' => 'Search places',
			'createFlight.overview.routeSummaryPoiNoMatches' => 'No places match your search.',
			'createFlight.overview.airportCard.departureDescription' => ({required Object airport}) => 'You\'ll start your journey from ${airport}.',
			'createFlight.overview.airportCard.arrivalDescription' => ({required Object airport}) => 'You\'ll arrive at ${airport}.',
			'createFlight.overview.regionInfo.descriptionUnavailable' => 'Description is not available yet.',
			'createFlight.overview.regionInfo.wikipediaSectionTitle' => 'Wikipedia',
			'createFlight.overview.regionInfo.wikipediaUnavailable' => 'Wikipedia article is not available right now.',
			'createFlight.overview.regionInfo.openWikipedia' => 'Open Wikipedia',
			'createFlight.overview.timeline.takeOffTimeline' => 'Take\noff',
			'createFlight.overview.timeline.land' => 'Land',
			'createFlight.overview.timeline.alsoAroundThisTime' => 'Also around same time:',
			'createFlight.overview.timeline.minuteUnit' => 'min',
			'createFlight.overview.timeline.hourCompactUnit' => 'h',
			'createFlight.overview.timeline.minuteCompactUnit' => 'm',
			'createFlight.overview.timeline.regionType.country' => 'Country',
			'createFlight.overview.timeline.regionType.region' => 'Region',
			'createFlight.overview.timeline.regionType.state' => 'State',
			'createFlight.overview.timeline.regionType.province' => 'Province',
			'createFlight.overview.timeline.regionType.sea' => 'Sea',
			'createFlight.overview.timeline.regionType.ocean' => 'Ocean',
			'createFlight.overview.timeline.regionType.strait' => 'Strait',
			'createFlight.overview.timeline.regionType.channel' => 'Channel',
			'createFlight.overview.timeline.regionType.gulf' => 'Gulf',
			'createFlight.overview.timeline.regionType.bay' => 'Bay',
			'createFlight.overview.timeline.regionType.lake' => 'Lake',
			'createFlight.overview.timeline.regionType.alkalineLake' => 'Alkaline lake',
			'createFlight.overview.timeline.regionType.island' => 'Island',
			'createFlight.overview.timeline.regionType.archipelago' => 'Archipelago',
			'createFlight.overview.timeline.regionType.peninsula' => 'Peninsula',
			'createFlight.overview.timeline.regionType.coast' => 'Coast',
			'createFlight.overview.timeline.regionType.mountainRange' => 'Mountain range',
			'createFlight.overview.timeline.regionType.valley' => 'Valley',
			'createFlight.overview.timeline.regionType.plateau' => 'Plateau',
			'createFlight.overview.timeline.regionType.plain' => 'Plain',
			'createFlight.overview.timeline.regionType.basin' => 'Basin',
			'createFlight.overview.timeline.regionType.lowland' => 'Lowland',
			'createFlight.overview.timeline.regionType.tundra' => 'Tundra',
			'createFlight.overview.timeline.regionType.wetlands' => 'Wetlands',
			'createFlight.overview.timeline.regionType.desert' => 'Desert',
			'createFlight.overview.timeline.regionType.delta' => 'Delta',
			'createFlight.overview.timeline.regionType.reservoir' => 'Reservoir',
			'createFlight.overview.timeline.regionType.continent' => 'Continent',
			'createFlight.overview.timeline.regionType.geoarea' => 'Geographic area',
			'createFlight.overview.timeline.regionType.isthmus' => 'Isthmus',
			'createFlight.overview.timeline.regionType.unknown' => 'Unknown region type',
			'createFlight.wikipedia.title' => 'Download articles and read while you’re in the air',
			'createFlight.wikipedia.loadingIntro' => 'Finding route-related articles...',
			'createFlight.wikipedia.foundIntro' => ({required Object count}) => 'Based on your route we found ${count} relevant articles',
			'createFlight.wikipedia.emptyIntro' => 'No route-related Wikipedia articles found. You can continue with map download only.',
			'createFlight.wikipedia.selectedCount' => ({required Object count}) => '${count} selected',
			'createFlight.wikipedia.unselectAll' => 'Unselect all',
			'createFlight.wikipedia.selectAll' => 'Select all',
			'createFlight.wikipedia.basicHint' => ({required Object count}) => 'Offline articles selected: ${count}',
			'createFlight.wikipedia.proHint' => 'Full offline article pack',
			'createFlight.wikipedia.proGateHint' => 'Upgrade for the full offline article pack',
			'createFlight.wikipedia.proActiveTitle' => 'Pro active',
			'createFlight.wikipedia.proActiveMessage' => 'Full articles pack unlocked.',
			'createFlight.wikipedia.freeLimitHint' => 'Free plan includes up to 3 offline articles',
			'createFlight.wikipedia.estimatedDownloadSize' => ({required Object size}) => 'Estimated download size: ${size}',
			'createFlight.wikipedia.upgrade' => 'Upgrade to Pro',
			'createFlight.wikipedia.loadingSuggestions' => 'Loading article suggestions...',
			'createFlight.wikipedia.downloadMapOnly' => 'Download map',
			'createFlight.wikipedia.downloadMapPlusOne' => 'Download map + 1 article',
			'createFlight.wikipedia.downloadMapPlusMany' => ({required Object count}) => 'Download map + ${count} articles',
			'createFlight.wikipedia.couldNotOpenLink' => 'Could not open link',
			'createFlight.downloading.articlesTitle' => 'Downloading selected articles...',
			'createFlight.downloading.mapTitle' => 'Downloading offline map...',
			'createFlight.downloading.mapSectionTitle' => 'Map',
			'createFlight.downloading.poiSectionTitle' => 'Places',
			'createFlight.downloading.articlesSectionTitle' => 'Articles',
			'createFlight.downloading.cancelDownload' => 'Cancel download',
			'createFlight.downloading.doNotClose' => 'Do not close this screen until download completes',
			'createFlight.downloading.currentStep' => 'Current',
			'createFlight.downloading.pending' => 'Pending',
			'createFlight.downloading.inProgress' => 'In progress',
			'createFlight.downloading.completed' => 'Completed',
			'createFlight.downloading.completedWithIssues' => 'Completed with issues',
			'createFlight.downloading.failed' => 'Failed',
			'createFlight.downloading.skipped' => 'Skipped',
			'createFlight.downloading.waitingForMap' => 'Waiting for map download...',
			'createFlight.downloading.mapFailed' => 'Map download failed.',
			'createFlight.downloading.noPoiSelected' => 'No place summaries selected.',
			'createFlight.downloading.preparingPoi' => 'Preparing place summaries...',
			'createFlight.downloading.poiProgress' => ({required Object completed, required Object total}) => 'Places: ${completed}/${total}',
			'createFlight.downloading.poiProgressWithFailed' => ({required Object completed, required Object total, required Object failed}) => 'Places: ${completed}/${total} (${failed} failed)',
			'createFlight.downloading.noArticlesSelected' => 'No articles selected.',
			'createFlight.downloading.preparingArticles' => 'Preparing article downloads...',
			'createFlight.downloading.articlesProgress' => ({required Object completed, required Object total}) => 'Articles: ${completed}/${total}',
			'createFlight.downloading.articlesProgressWithFailed' => ({required Object completed, required Object total, required Object failed}) => 'Articles: ${completed}/${total} (${failed} failed)',
			'createFlight.downloading.preparingMap' => 'Preparing map download...',
			'createFlight.downloading.computingTiles' => 'Computing map tiles...',
			'createFlight.downloading.computingTilesWithCount' => ({required Object count}) => 'Computing map tiles (${count})...',
			'createFlight.downloading.preparingForDownload' => 'Preparing for download...',
			'createFlight.downloading.downloaded' => ({required Object size}) => 'Downloaded: ${size}',
			'createFlight.downloading.finalizing' => 'Finalizing map package...',
			'createFlight.downloading.verifying' => 'Verifying map package...',
			'createFlight.errors.failedLoadAirports' => 'Failed to load airports. Please try again.',
			'createFlight.errors.airportSearchFailed' => 'Airport search failed. Try another query.',
			'createFlight.errors.someArticlesFailed' => 'Some articles failed. Continuing with map download.',
			'createFlight.errors.someOptionalDownloadsFailed' => 'Map downloaded. Some optional content could not be downloaded.',
			'createFlight.errors.failedBuildPreview' => 'Failed to build route preview. Please try again.',
			'createFlight.errors.overviewUnavailableContinue' => 'Could not load route overview. You can still continue.',
			'createFlight.errors.noInternet' => 'No internet connection. Please check your connection and try again.',
			'createFlight.errors.failedStartDownload' => ({required Object error}) => 'Failed to start download: ${error}',
			'createFlight.paywall.upgradeCancelled' => 'Upgrade cancelled.',
			'createFlight.paywall.noPaywall' => 'No paywall available right now.',
			'createFlight.paywall.failedOpenPaywall' => 'Failed to open paywall.',
			'preview.calculatingRoute' => 'Calculating flight route...',
			'preview.errorTitle' => 'Error',
			'preview.errorSomethingWrong' => 'Something went wrong',
			'preview.tryAgain' => 'Try Again',
			'preview.downloadComplete' => 'Download Complete!',
			'preview.flightSaved' => 'Flight has been saved',
			'preview.navigatingHome' => 'Navigating to home...',
			'preview.downloadingMapTitle' => 'Downloading Flight Map',
			'preview.cancelDownload' => 'Cancel download',
			'preview.download' => 'Download',
			'preview.flightRoute' => ({required Object distance}) => 'Flight route (~ ${distance})',
			'flight.tabMap' => 'Map',
			'flight.tabDashboard' => 'Dashboard',
			'flight.tabRoute' => 'Route',
			'flight.tabInfo' => 'Info',
			'flight.completeDialogTitle' => 'Complete flight?',
			'flight.completeDialogBody' => 'This marks your flight as completed.',
			'flight.completeDialogDeleteOffline' => 'Delete map and offline articles',
			'flight.completeDialogConfirm' => 'Complete',
			'flight.deleteDialogTitle' => 'Are you sure?',
			'flight.deleteDialogMessage' => ({required Object size}) => 'This permanently deletes this flight, including offline map and saved offline articles.\n\nSpace to be regained: ${size}.',
			'flight.yes' => 'Yes',
			'flight.shareRoute' => 'Share route',
			'flight.copyRoute' => 'Copy route',
			'flight.deleteFlight' => 'Delete flight',
			'flight.routeSummaryCopied' => 'Route summary copied',
			'flight.deleted' => 'Flight deleted',
			'flight.deleteError' => ({required Object error}) => 'Error deleting flight: ${error}',
			'flight.map.initializing' => 'Loading map',
			'flight.map.loadingStyle' => 'Loading map',
			'flight.map.offlineNotAvailable' => 'Offline map is not available for this flight.',
			'flight.map.offlineMissing' => 'Offline map file is missing. Please re-download this route.',
			'flight.map.validationFailed' => 'Offline map validation failed. Please re-download this route.',
			'flight.map.loadStyleFailed' => 'Could not load offline map style.',
			'flight.map.switchTo2D' => 'Switch to 2D',
			'flight.map.switchTo3D' => 'Switch to 3D',
			'flight.map.uncenterMap' => 'Uncenter map',
			'flight.map.centerOnMe' => 'Center on me',
			'flight.dashboard.gpsOffTitle' => 'Location services are off',
			'flight.dashboard.gpsOffSubtitle' => 'Turn on location services in system settings to resume live flight tracking and map following.',
			'flight.dashboard.openLocationSettings' => 'Open location settings',
			'flight.dashboard.permissionTitle' => 'Location permission required',
			'flight.dashboard.permissionSubtitle' => 'Allow location access so the dashboard can show live heading, speed, and altitude.',
			'flight.dashboard.grantPermissions' => 'Grant permissions',
			'flight.dashboard.gpsAccuracy' => ({required Object label, required Object accuracy}) => 'GPS Accuracy: ${label} (±${accuracy} m)',
			'flight.dashboard.accuracyExcellent' => 'Excellent',
			'flight.dashboard.accuracyGood' => 'Good',
			'flight.dashboard.accuracyPoor' => 'Poor',
			'flight.dashboard.gpsOff' => 'GPS off',
			'flight.dashboard.gpsOffHint' => 'Enable location services to start tracking.',
			'flight.dashboard.gpsPermissionRequired' => 'Location permission required',
			'flight.dashboard.gpsPermissionHint' => 'Grant permission to access live flight telemetry.',
			'flight.dashboard.gpsSearching' => 'Searching for GPS',
			'flight.dashboard.gpsSearchingHint' => 'Looking for a reliable signal',
			'flight.dashboard.gpsWeak' => 'Weak GPS signal',
			'flight.dashboard.gpsWeakHint' => 'Signal is unstable. Keep device in open sky.',
			'flight.dashboard.gpsWeakHintWithAge' => ({required Object age}) => 'Signal unstable. Last fix ${age}.',
			'flight.dashboard.gpsActive' => 'GPS active',
			'flight.dashboard.gpsActiveHint' => 'Receiving live telemetry.',
			'flight.dashboard.gpsActiveHintWithAge' => ({required Object age}) => 'Last GPS update ${age}.',
			'flight.dashboard.ageJustNow' => 'just now',
			'flight.dashboard.ageSeconds' => ({required Object seconds}) => '${seconds} s ago',
			'flight.dashboard.ageMinutes' => ({required Object minutes}) => '${minutes} m ago',
			'flight.dashboard.signalGood' => 'Good',
			'flight.dashboard.signalPoor' => 'Poor',
			'flight.dashboard.signalBad' => 'Bad',
			'flight.dashboard.signalSearching' => 'Searching',
			'flight.dashboard.gpsQuality' => ({required Object quality}) => 'GPS ${quality}',
			'flight.dashboard.gpsSearchingLabel' => 'GPS searching',
			'flight.dashboard.gpsPermissionNeededLabel' => 'GPS permission needed',
			'flight.dashboard.gpsOffLabel' => 'GPS off',
			'flight.dashboard.aircraftHeading' => 'Aircraft heading',
			'flight.dashboard.headingShort' => ({required Object heading}) => 'HDG ${heading}°',
			'flight.dashboard.liveInstruments' => 'Live instruments',
			'flight.dashboard.acquiringGpsSignal' => 'Acquiring GPS signal',
			'flight.dashboard.acquiringGpsHint' => 'Keep the device steady and in open sky for a reliable fix.',
			'flight.dashboard.weakSignalBanner' => 'Weak GPS signal. Values may drift until accuracy improves.',
			'flight.dashboard.preparingDashboard' => 'Preparing dashboard...',
			'flight.dashboard.navigation' => 'Navigation',
			'flight.dashboard.heading' => ({required Object heading}) => 'Heading ${heading}',
			'flight.dashboard.routeProgress' => 'Route progress',
			'flight.dashboard.covered' => 'Covered',
			'flight.dashboard.remaining' => 'Remaining',
			'flight.dashboard.total' => 'Total',
			'flight.upcoming.mapTitle' => 'Begin your flight journey',
			'flight.upcoming.mapSubtitle' => 'Start live tracking once your flight begins',
			'flight.upcoming.dashboardTitle' => 'Begin your flight journey',
			'flight.upcoming.dashboardSubtitle' => 'Start to see your live dashboard',
			'flight.upcoming.checkInButton' => 'Start',
			'flight.upcoming.checkInError' => 'Could not start now. Please try again',
			'flight.info.overviewTitle' => 'Overview',
			'flight.info.overviewLoading' => 'Building route overview...',
			'flight.info.overviewEmpty' => 'Overview is not available yet for this route.',
			'flight.info.loadingRouteInformation' => 'Loading route information...',
			'flight.info.flyOverTitle' => 'Highlights of your route',
			'flight.info.airportsTitle' => 'Airports',
			'flight.info.departure' => 'Departure',
			'flight.info.arrival' => 'Arrival',
			'flight.info.showAll' => 'Show all',
			'flight.info.showAllCount' => ({required Object count}) => 'Show all ${count}',
			'flight.info.showLess' => 'Show less',
			'flight.info.sortByRank' => 'By rank',
			'flight.info.sortByRouteProgress' => 'By route',
			'flight.info.sortByType' => 'By type',
			'flight.info.routeTimelineTitle' => 'Route timeline',
			'flight.info.plannedWaypoints' => ({required Object count}) => '${count} planned waypoints',
			'flight.info.pointsOfInterestTitle' => 'Points of Interest',
			'flight.info.noPoi' => 'No POIs available yet.',
			'flight.info.poiType' => ({required Object type}) => 'Type: ${type}',
			'flight.info.poiFlyOver' => ({required Object view}) => 'Fly-over: ${view}',
			'flight.info.offlineArticlesTitle' => 'Offline Articles',
			'flight.info.regionArticlesTitle' => 'Region articles',
			'flight.info.otherArticlesTitle' => 'Other articles',
			'flight.info.noOfflineArticles' => 'No offline articles downloaded.',
			'flight.info.openSource' => 'Open Source',
			'flight.info.openSourcePageTooltip' => 'Open source page',
			'flight.info.distanceKm' => ({required Object distance}) => '${distance} km',
			'flight.info.speed' => 'Speed',
			'flight.info.altitude' => 'Altitude',
			'flight.info.copyRouteTitle' => 'Flymap Route',
			'flight.info.copyRouteCode' => ({required Object routeCode}) => 'Route code: ${routeCode}',
			'flight.info.copyDistance' => ({required Object distance}) => 'Distance: ${distance} km',
			'flight.info.copyFrom' => 'From',
			'flight.info.copyTo' => 'To',
			'flight.info.copyCity' => ({required Object city, required Object countryCode}) => 'City: ${city}, ${countryCode}',
			'flight.info.copyAirport' => ({required Object airport}) => 'Airport: ${airport}',
			'flight.info.copyCodes' => ({required Object iata, required Object icao}) => 'Codes: IATA ${iata} | ICAO ${icao}',
			'flight.route.loadingRouteTimeline' => 'Loading route timeline...',
			'flight.route.noSavedOfflineRegions' => 'No saved offline regions for this flight.',
			'flight.route.currentProgress' => ({required Object percentage, required Object minute}) => 'Current progress: ${percentage}% (around ${minute} from takeoff)',
			'flight.route.nowLabel' => 'Now',
			'flight.route.currentRegionLabel' => 'Current',
			'flight.route.nextRegionLabel' => 'Next',
			'flight.route.etaLabel' => ({required Object time}) => 'ETA: ${time}',
			'flight.route.flyingOverLabel' => 'You are flying over:',
			'flight.route.premiumLockedChipLabel' => 'Unlock',
			_ => null,
		} ?? switch (path) {
			'flight.route.premiumGateTitle' => 'Unlock full route timeline',
			'flight.route.premiumGateBody' => 'Upgrade to Pro to see all regions along your route and timeline details.',
			'flight.route.premiumGateBodyWithCount' => ({required Object count}) => 'Unlock all ${count} regions on this route with Premium.',
			'flight.route.premiumGateCta' => 'Subscribe to Premium',
			'flight.route.premiumOfflineTitle' => 'Internet needed to upgrade',
			'flight.route.premiumOfflineBody' => 'You are offline right now. Connect to the internet to upgrade and unlock the full route view.',
			'flight.route.nextHintLabel' => ({required Object region, required Object eta}) => 'Next: ${region} (${eta})',
			'flight.route.etaUnknownLabel' => 'estimating...',
			'shareFlight.title' => 'Share flight',
			'shareFlight.preparingMap' => 'Preparing share preview map...',
			'shareFlight.preparingScreenshot' => 'Preparing screenshot...',
			'shareFlight.share' => 'Share',
			'shareFlight.offlineMapMissing' => 'Offline map missing. Using online style.',
			'shareFlight.offlineStyleFailed' => 'Failed to load offline style. Using online style.',
			'shareFlight.captureFailed' => 'Could not capture route screenshot',
			'shareFlight.shareFailed' => 'Failed to share route screenshot',
			'shareFlight.shareText' => ({required Object from, required Object to}) => 'Flight route ${from}-${to}',
			'shareFlight.watermark' => 'Flymap',
			'shareFlight.flightDistance' => 'Flight distance',
			'shareFlight.distanceKm' => ({required Object distance}) => '${distance} km',
			'about.title' => 'About Flymap',
			'about.welcome' => 'Welcome to Flymap',
			'about.intro' => 'Flymap keeps your route visible in the air. Plan the trip, download your map on the ground, and track your flight offline with confidence.',
			'about.chipOffline' => 'Offline map',
			'about.chipDashboard' => 'Live dashboard',
			'about.chipSharing' => 'Route sharing',
			'about.infoBanner' => 'Before takeoff, download your route map. In flight mode, internet access may be limited or unavailable.',
			'about.whatYouCanDo' => 'What You Can Do',
			'about.featurePlanTitle' => 'Plan your route',
			'about.featurePlanText' => 'Choose departure and arrival airports, then preview the path before downloading.',
			'about.featureTrackTitle' => 'Track flight data',
			'about.featureTrackText' => 'Use Dashboard to monitor heading, speed, altitude, and route progress.',
			'about.featureDetailsTitle' => 'Check route details',
			'about.featureDetailsText' => 'Open the Info tab for airport details and a clean route overview.',
			'about.featureShareTitle' => 'Share your journey',
			'about.featureShareText' => 'Generate and share a flight map screenshot with route highlights.',
			'about.quickStart' => 'Quick Start',
			'about.step1' => 'Tap New flight on Home.',
			'about.step2' => 'Choose departure and arrival airports.',
			'about.step3' => 'Open Map preview and download the map before the flight.',
			'about.step4' => 'Open your flight and use Map, Dashboard, and Info in the air.',
			'about.tips' => 'Tips For Better GPS',
			'about.tip1' => 'For stronger GPS signal, sit closer to a window.',
			'about.tip2' => 'Signal can drop in the middle of the aircraft. Flymap keeps the last known route view while searching.',
			'onboarding.skip' => 'Skip',
			'onboarding.letsStart' => 'Let\'s start',
			'onboarding.welcomeTitle' => 'Discover what’s below',
			'onboarding.welcomeSubtitle' => 'shows you offline maps and interesting places along your flight',
			'onboarding.nameTitle' => 'Pick a username',
			'onboarding.nameSubtitle' => 'Make discovery personal. You can change it anytime.',
			'onboarding.frequencyTitle' => 'How often do you fly?',
			'onboarding.frequencySubtitle' => 'Flymap will personalize your experience and make suggestions more relevant',
			'onboarding.frequencyFirstFlight' => 'This is my first flight',
			'onboarding.frequencyFewPerYear' => 'A few times a year',
			'onboarding.frequencyMonthly' => 'About monthly',
			'onboarding.frequencyFrequent' => 'Very often',
			'onboarding.homeAirportTitle' => 'Set your home airport',
			'onboarding.homeAirportSubtitle' => 'Get faster flight setup. You can change it anytime.',
			'onboarding.homeAirportHint' => 'Search home airport',
			'onboarding.popularAirports' => 'Popular airports',
			'onboarding.removeHomeAirport' => 'Remove home airport',
			'onboarding.noHomeAirportFound' => 'No airports found for that search.',
			'onboarding.interestsTitle' => 'What places you want to see more on a map?',
			'onboarding.interestsSubtitle' => 'Choose up to 3 topics to see more relevant places and stories along your flight.',
			'onboarding.interestsHelper' => 'Pick up to 3 topics.',
			'onboarding.interestsSelected' => ({required Object count, required Object max}) => '${count} of ${max} selected',
			'onboarding.interestMountains' => 'Mountains & ridges',
			'onboarding.interestVolcanoes' => 'Volcanoes & geology',
			'onboarding.interestRegions' => 'Cities & regions',
			'onboarding.interestIslands' => 'Islands & coastlines',
			'onboarding.interestNationalParks' => 'National parks & reserves',
			'onboarding.interestRivers' => 'Rivers & lakes',
			'onboarding.proTitle' => 'Get more from every flight',
			'onboarding.proStepSubtitle' => 'Unlock detailed maps, places and articles — even offline.',
			'onboarding.proFeatureMaps' => 'Detailed maps for your flight',
			'onboarding.proFeaturePlaces' => '10x more places along the route',
			'onboarding.proFeatureTimeline' => 'A detailed timeline of your entire flight',
			'onboarding.proFeatureArticles' => 'Complete pack of offline articles',
			'onboarding.unlockPro' => 'Unlock Pro',
			'onboarding.continueFree' => 'Continue Free',
			'onboarding.proActiveTitle' => 'Congratulations!',
			'onboarding.proActiveSubtitle' => 'You now have full access to detailed maps, all places, and article packs.',
			'onboarding.planFirstFlight' => 'Start my first flight',
			'onboarding.planFirstFlightPro' => 'Plan my first detailed flight',
			'onboarding.failedLoadProfile' => 'Failed to load your profile.',
			_ => null,
		};
	}
}
