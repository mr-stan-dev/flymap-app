# Analytics Event Routing

The app-facing API is `AppAnalytics`.

Firebase Analytics is the detailed product analytics sink and receives every
custom `AppAnalytics` event.

PostHog is the paid funnel and LTV analytics sink. It is wrapped in
`FilteringAppAnalytics` with `PostHogFunnelEventFilter`, so it receives only the
explicit allowlist below.

PostHog and Firebase anonymous identity are enabled only for release builds.
Debug/profile builds skip Firebase anonymous auth and PostHog capture by
default.

## Identity

Release builds use the Firebase anonymous Auth UID as the canonical user ID:

- PostHog `distinct_id`
- Firebase Analytics user ID
- RevenueCat app user ID

RevenueCat also receives these customer attributes for joining and debugging:

- `firebase_uid`
- `posthog_distinct_id`
- `app_version`
- `platform`

## Global Event Properties

Every custom PostHog event includes:

- `app_version`
- `build_number`
- `platform`
- `app_env`

Boolean values are sent to PostHog as booleans when the event class uses a
boolean. Firebase Analytics converts booleans to `0` or `1`.

## Person Properties

On identify:

- `app_version`
- `build_number`
- `platform`
- `app_env`
- `is_pro` when known
- `subscription_status` when known: `free`, `pro`

Set once:

- `first_app_version`
- `first_platform`

When subscription state changes:

- `is_pro`
- `subscription_status`

## Automatic PostHog Capture

Automatic PostHog screen capture is disabled:

- `PosthogObserver` is not registered in `GoRouter`.
- SDK application lifecycle capture is disabled.
- Feature flag preload/call events are disabled.
- Session replay is disabled.

RevenueCat subscription and purchase events should enter PostHog through the
RevenueCat integration/webhook, not through duplicate client-side purchase
logging.

## PostHog Custom Event Allowlist

### Onboarding

| Event | Properties |
| --- | --- |
| `onboarding_started` | `flow_version`, `entry_source` |
| `onboarding_completed` | `flow_version`, `steps_total`, `steps_skipped_count`, `duration_sec` |

### Route Creation

| Event | Properties |
| --- | --- |
| `route_type_selected` | `route_type`, `is_pro_user`, `has_pending_flight_unlock` |
| `search_route_prepared` | `route_length_km`, `route_length_bucket`, `map_detail`, `route_source` |
| `search_route_not_supported` | `reason`, `route_length_km` |
| `flight_opened` | `route_source`, `route_length_bucket`, `access_tier` |

Known values:

- `route_type`: `airports`, `flight_number`, `real_route`
- `route_length_bucket`: `short`, `mid`, `long`, `super_long`
- `map_detail`: `basic`, `pro`
- `route_source`: `great_circle`, `fr24_historical`
- `flight_opened.access_tier`: `free`, `pro`, `flight_unlock`

### Downloads

| Event | Properties |
| --- | --- |
| `download_started` | `route_length_km`, `map_detail`, `articles_selected_count`, `is_pro_user`, `access_mode`, `route_source` |
| `download_completed` | `route_length_km`, `articles_downloaded_count`, `map_size_mb`, `access_mode`, `route_source` |
| `download_failed` | `stage`, `error_type`, `error_message`, `route_length_km`, `route_source` |

Notes:

- `download_failed.error_message` is compacted and capped at 200 characters.
- `download_completed.map_size_mb` is rounded to one decimal place.

### Monetization

| Event | Properties |
| --- | --- |
| `paywall_presented` | `source`, `is_pro_user`, `has_products` |
| `paywall_result` | `source`, `result` |
| `subscription_status_changed` | `from_status`, `to_status`, `source` |
| `restore_purchases_result` | `result` |

Known values:

- `source`: `wiki_and_map_pro`, `wiki_limit`, `map_pro`, `poi_section`,
  `settings_banner`, `subscription_management`, `learn_locked_content`,
  `onboarding`, `route_overview_gate`, `route_timeline_gate`,
  `geo_awareness_gate`, `real_route_gate`
- `paywall_result.result`: `purchased`, `restored`, `cancelled`, `error`,
  `notPresented`
- `restore_purchases_result.result`: `pro_restored`, `no_subscription`, `error`
- `subscription_status_changed.source`: currently app-defined strings such as
  `purchase`, `restore`, `refresh`, or `customer_info_stream`

## Firebase-Only Custom Events

These still go to Firebase Analytics through `AppAnalytics`, but are filtered
out before PostHog:

- `onboarding_step_viewed`
- `onboarding_step_completed`
- `onboarding_step_skipped`
- `flight_number_lookup_result`
- `route_overview_completed`
- `learn_category_opened`
- `learn_article_opened`
- `flight_unlock_sheet_opened`
- `flight_unlock_action`
- `flight_unlock_purchase_result`
- `poi_marker_tapped`
- `share_card_generated`
- `share_card_shared`
- `rate_prompt_action`

## Privacy Boundaries

PostHog v1 should not receive:

- exact flight number
- exact origin or destination airport
- GPS location
- email
- IDFA
- advertising ID
- full route geometry
