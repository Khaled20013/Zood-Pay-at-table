# Zood Pay-At-Table

Guest-facing app of the **ZoodPOS** ecosystem. A guest scans the QR code on
their table, browses the branch menu, customises items with modifiers, and
pays by card from their seat. No account, no waiting for the bill.

One Flutter codebase, one design, three targets: **Android**, **iOS** and
**Web**, responsive from small phones to desktop, in **Arabic (RTL)** and
**English**.

```
https://control.zood.ai/pay-at-table/{qr_id}/menu
                                     └── table QR id
```

The same link opens the installed app (App Links / Universal Links) or, if the
app is not installed, the web version.

---

## Contents

- [Guest flow](#guest-flow)
- [Getting started](#getting-started)
- [Configuration](#configuration)
- [API contract](#api-contract)
- [Demo data](#demo-data)
- [Architecture](#architecture)
- [Localization](#localization)
- [Deep links](#deep-links)
- [Web & deployment](#web--deployment)
- [Quality checks](#quality-checks)

---

## Guest flow

```
Scan QR ─▶ QR check ─▶ Menu ─▶ Product sheet ─▶ Cart ─▶ Checkout (card) ─▶ Order placed
           3.1         3.2–3.4  modifier rules           3.5
```

| Step | What happens |
| --- | --- |
| **QR check** | Resolves the QR to a branch, table and `business_reference`. `404` shows *QR code not found*, `410` or an inactive QR shows *Ordering is unavailable at this table*. |
| **Menu** | Categories sorted by `index`; products with an unknown or empty category are grouped under *Other items* at the end. Search and category filter. |
| **Product sheet** | Modifiers with their rules: required / optional, single choice (radio), unique options (checkbox) or quantities (stepper), defaults, excluded options, free units. **Add** stays blocked until every required modifier is satisfied. |
| **Cart** | Lines merge only when product, options and notes are identical. Subtotal, estimated VAT (15%) on top, total. |
| **Checkout** | Card form (number, expiry, CVC, name), optional order note. One request charges the card and creates the order. |
| **Success** | Order `#number`, table, reference, and the totals returned by the server. |

---

## Getting started

Requirements: Flutter **3.41+** (Dart **3.11+**), plus Android Studio and/or
Xcode for mobile.

```sh
flutter pub get
flutter run                 # pick a device: emulator, simulator, phone
flutter run -d chrome       # web
```

Open the demo table directly:

```sh
# Android emulator
adb shell am start -a android.intent.action.VIEW \
  -d "zoodpay://pay-at-table/40de86d3987ef0a98768ad61/menu"

# iOS Simulator
xcrun simctl openurl booted "zoodpay://pay-at-table/40de86d3987ef0a98768ad61/menu"

# Web
flutter run -d chrome \
  --dart-define=INITIAL_LOCATION=/pay-at-table/40de86d3987ef0a98768ad61/menu
```

Or launch the app and tap **Open demo table**.

---

## Configuration

Compile-time flags (`--dart-define`), defined in
[`lib/Helper/Configs/AppConfig.dart`](lib/Helper/Configs/AppConfig.dart):

| Key | Default | Purpose |
| --- | --- | --- |
| `USE_DUMMY_DATA` | `false` | Serve bundled demo data instead of calling the API |
| `API_BASE_URL` | `https://dev.api.zood.ai/api/v1/` | Pay at Table API |
| `ENABLE_NETWORK_LOGS` | `true` | Request / response logs in debug builds (card data is masked) |
| `INITIAL_LOCATION` | empty | Route to open on launch instead of splash → landing |

Run against the real API:

```sh
flutter run --dart-define=USE_DUMMY_DATA=false
```

With `USE_DUMMY_DATA=false`, debug builds fall back to demo data when the API is
unreachable, **except for placing an order**, which never fakes a success.

---

## API contract

All endpoints are **public**: no `Authorization` header, no logged-in client.
Every request sends `Accept: application/json` and `Accept-Language: ar|en`.
Localized fields show `*_localized` in Arabic when not empty, otherwise the
default value.

| # | Endpoint | Used for |
| --- | --- | --- |
| 3.1 | `GET  /public/pay-at-table/qr/{qr_id}` | Branch, table, `business_reference` |
| 3.2 | `GET  /public/pay-at-table/categories?business_reference=` | Categories (sorted by `index`) |
| 3.3 | `GET  /public/pay-at-table/products?business_reference=` | Products + per-product modifier rules |
| 3.4 | `GET  /public/pay-at-table/modifiers?business_reference=` | Modifier names and options |
| 3.5 | `POST /public/pay-at-table/orders` | Charge the card and create the order |

### Placing an order (3.5)

- **No prices are sent.** The server prices and charges the order.
- Option `quantity` is per **one** product unit.
- `client_order_id` (UUID v4) is **reused** when retrying after a network error
  or `5xx` (the server never charges twice), and **renewed** after a `402` or
  when the order changes.
- Card fields live only in the checkout form: never stored, never logged.
- **Pay** is disabled while the request runs.

| Status | Shown to the guest | Then |
| --- | --- | --- |
| `201` / `200` | Order placed: `#number`, table, total | Cart is cleared |
| `402` | *Your card was declined.* + server message | Retry with a new `client_order_id` |
| `422` | Server message | Menu reloads; unavailable items leave the cart |
| `404` / `410` | *Ordering is unavailable at this table* | |
| `429` | *Too many attempts, please wait and try again* | |
| other / network | *Something went wrong, please try again* | Same `client_order_id` on retry |

> **VAT:** menu prices are treated as excluding VAT (per the contract example:
> `610 + 91.5 = 701.5`). The cart shows 15% VAT on top as an estimate; the
> success screen shows the server's `subtotal_price`, `total_taxes` and
> `total_price`.

### Kitchen fan-out (Cashier Pusher)

Same cycle as Self Order: this app builds a Multipeer kitchen string
(`pat_kds_message`) and sends it on `POST /public/pay-at-table/orders`. The
**backend** broadcasts it to the branch Cashier on the Pay-at-Table channel;
Cashier maps the payload into OrderHistory, shows a **Pay at Table** alert,
and fans the wire out to KDS.

| | Value |
| --- | --- |
| Channel | `pay-at-table-orders.{deviceCode}` |
| Event | `pay-at-table-order` |
| `deviceCode` | Cashier `DeviceIdDeviceId` for that branch |
| Kitchen wire | `record.pat_kds_message` (fallback: `kiosk_kds_message`) |

The Flutter client does **not** subscribe to this channel — reception is
Cashier-only. See `lib/Helper/Configs/CashierPusherContract.dart`.

---

## Demo data

While `USE_DUMMY_DATA=true` (the default), the `*Api` classes return bundled JSON
in the **exact API shape**, parsed by the same models as real responses. It
covers every modifier rule.

| Input | Result |
| --- | --- |
| Any valid QR id | Demo table: branch *Olaya*, table *T5* |
| QR id `not-found` | `404`: QR code not found |
| QR id `inactive` | `410`: ordering unavailable |
| Card `4111 1111 1111 1111` | Order placed |
| Card `4000 0000 0000 0002` | `402`: card declined |

---

## Architecture

Layered structure from the team architecture rules (see `.cursor/rules/`):
`flutter_bloc` for app-wide state only, plain controllers per screen,
`go_router` for navigation and static `*Api` classes over `package:http`.

```
lib/
├── main.dart            # MyApp, MultiBlocProvider, global routerMain
├── Constants.dart       # current language, app version
├── AppRoutes/           # GoRouterApp + one <Feature>Routes.dart per feature, DeepLinkService
├── Bloc/                # AppCubit (session, menu, cart) · LanguageCubit · states.dart
├── Screens/<Feature>/<Screen>/
│   ├── Controller/      # plain class, refresh() → setState
│   └── View/            # widget with routeName / path
├── Models/<Feature>/    # immutable *Model classes, *Api (Future<KApiResponse>), dummy data
├── Helper/
│   ├── ApiServices/     # ApiBase, ApiRequest, KApiResponse, ApiEndpoints, DemoDataPolicy
│   ├── connection/      # HttpClientHelper (http), local cache
│   ├── Configs/         # AppConfig (dart-defines), kcore Config (base url)
│   ├── Errors/          # AppException hierarchy (QrNotFound, CardDeclined, …)
│   └── L10n.dart        # S + error / category text helpers
├── Styles/              # AppColors (Teams blue #004FEE), AppTheme (Cairo font)
├── Widgets/             # shared buttons, steppers, status views
├── generated/           # S (flutter gen-l10n output)
└── l10n/                # app_en.arb · app_ar.arb
```

Key points:

- `AppCubit` is app-scoped, so the cart survives navigation. Resolving a
  table binds the cart to it (a different table starts a fresh cart) and
  warms the menu. Views rebuild on `TableSessionAppStates`, `MenuAppStates`
  or `CartAppStates`.
- Views never call `context.go` with raw strings; they use
  `<Feature>Routes.open<Screen>Screen(...)`.
- `TableSessionGate` resolves the QR on any nested route, so links straight to
  `/menu` or `/cart` work.
- `DemoDataPolicy` decides between API and demo data and maps HTTP statuses to
  typed `AppException`s per endpoint (`KApiResponse.error`).
- `ModifierSelection` is an immutable model that enforces min / max / unique /
  free / default rules and prices one product unit.
- `CartSummaryController` keeps the same `client_order_id` across retries of
  an unchanged order, so the server never charges twice.

Generated localizations (`lib/generated/`) are committed, so a fresh checkout
builds without code generation.

---

## Localization

Arabic and English, switchable in-app; the choice is persisted. Arabic is fully
RTL with the **Cairo** font. Menu content comes localized from the API and is
re-fetched when the language changes.

```sh
flutter gen-l10n      # after editing lib/l10n/*.arb
```

---

## Deep links

| Platform | Config |
| --- | --- |
| Android | `AndroidManifest.xml`: `autoVerify` intent filter for `https://control.zood.ai/pay-at-table/*` and the `zoodpay://` scheme |
| iOS | `Runner.entitlements`: `applinks:control.zood.ai`. `Info.plist`: `zoodpay` URL scheme |
| Web | Path URLs (no `#`), so the QR link is a normal web route |

Verified links need these files on `control.zood.ai`:

```
/.well-known/assetlinks.json
/.well-known/apple-app-site-association
```

---

## Web & deployment

The web build is published to a separate static repo served by Vercel:
[Zood-Pay-at-table-web](https://github.com/Khaled20013/Zood-Pay-at-table-web).

```sh
tool/deploy_web.sh "commit message"
```

The script runs `flutter build web --release`, syncs `build/web` into
`../zood_pay_at_table_web`, commits and pushes. `web/vercel.json` rewrites all
routes to `index.html` and serves `/.well-known/*` as JSON.

> The API must allow **CORS** from the web domain for the web build to reach it.

---

## Quality checks

```sh
flutter analyze
flutter test
```

Tests mirror `lib/` and cover the modifier rules, cart pricing, QR / menu /
order status mapping against a mock `http` client, the `client_order_id` retry rules, card validation,
and layout of the main screens on small phones in both languages.
