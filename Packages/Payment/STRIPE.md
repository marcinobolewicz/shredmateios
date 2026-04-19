# Stripe Integration — ShredMate iOS

This document describes the Stripe integration for mentor payouts and rider payments in the ShredMate iOS app.

## Overview

ShredMate uses Stripe Connect to enable mentors to receive payments for mentoring sessions. The integration has two sides:

1. **Mentor onboarding** — creating a Stripe Connected Account and completing identity verification via Stripe-hosted onboarding.
2. **Rider payments** — presenting Stripe PaymentSheet so riders can pay for booked sessions.

---

## Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│  Profile (mentor)          │  Places (rider booking)             │
│                            │                                     │
│  StripeOnboardingView      │  MentorSlotsSection                 │
│         │                  │         │                           │
│  StripeOnboardingViewModel │  MentorSlotsViewModel               │
│         │                  │    (payment flow + PaymentSheet)     │
├──────────────────────────────────────────────────────────────────┤
│  Networking                │  Payment                            │
│                            │                                     │
│  StripeService             │  StripePaymentService (@Observable) │
│  (REST: account, status,   │  (Stripe SDK: PaymentSheet,         │
│   onboarding-link)         │   publishable key init)             │
│                            │                                     │
│  MentorSlotsService        │  PaymentSheetPresenter (SwiftUI)    │
│  (REST: payment-intent,    │  PaymentResult (app enum)           │
│   confirm-payment)         │                                     │
│         │                  │                                     │
│  AuthenticatingHTTPClient  │  StripePaymentSheet (Stripe SDK)    │
└──────────────────────────────────────────────────────────────────┘
```

### Package Responsibilities

| Package | Role |
|---------|------|
| `Networking` | REST calls to ShredMate backend (`StripeService`, `MentorSlotsService` — payment-intent, confirm-payment) |
| `Payment` | Stripe iOS SDK wrapper (`StripePaymentService`, `PaymentSheetPresenter`, `PaymentResult`) |
| `Places` | Slot booking UI with payment flow (`MentorSlotsViewModel`, `MentorSlotsSection`) |
| `Profile` | Mentor onboarding UI (`StripeOnboardingView`, `StripeOnboardingViewModel`) |
| `App` | SDK initialization (`StripeSetup`), DI wiring in `AppSetup`, Environment injection |

---

## Flow 1: Mentor Stripe Onboarding

### Entry Point

Profile menu shows "Payment Setup" link when the mentor has at least one sport with `isMentor: true` (`hasMentorSports` condition).

### Steps

```
User taps "Set Up Payments"
        │
        ▼
POST /riders/me/stripe/account
  → creates Stripe Connected Account on backend
  → returns { accountId }
        │
        ▼
POST /riders/me/stripe/onboarding-link
  → backend generates Stripe Account Link (type: account_onboarding)
  → returns { url }
        │
        ▼
Open URL in Safari (UIApplication.shared.open)
  → user completes Stripe-hosted onboarding
  → identity verification, bank account, etc.
        │
        ▼
User returns to app (detected via scenePhase → .active)
        │
        ▼
GET /riders/me/stripe/status
  → returns { onboardingCompleted, payoutsEnabled }
        │
        ▼
UI updates status card:
  ✓ Onboarding completed / ○ Onboarding not completed
  ✓ Payouts enabled      / ○ Payouts not yet enabled
```

### State Machine

```
idle ──▶ creatingAccount ──▶ creatingLink ──▶ awaitingReturn ──▶ refreshingStatus ──▶ idle
  │            │                   │                                      │
  ◀────────── error ◀───────── error                                  error ──▶ idle
```

### Error Handling

Each API step has its own localized error message. On failure the flow stops at the failed step and returns to `idle` — the user can retry.

### Return Detection

When `scenePhase` transitions to `.active` while `step == .awaitingReturn`, the view automatically calls `refreshAfterReturn()` to fetch the latest status.

---

## Flow 2: Rider Payment (PaymentSheet)

### Steps

```
Student taps a mentor slot card
        │
        ▼
Alert: "Book session?" with price
        │
        ▼
POST /mentor-slots/:id/payment-intent
  → backend validates slot (AVAILABLE, not own, ≥30 min before start, mentor onboarded)
  → creates Stripe PaymentIntent with platform fee (10%)
  → reserves slot for 15 minutes
  → returns { paymentIntentId, clientSecret, amount, currency, publishableKey }
        │
        ▼
StripePaymentService.makePaymentSheet(clientSecret:)
  → builds configured PaymentSheet
        │
        ▼
.stripePaymentSheet(isPresented:paymentSheet:onResult:)
  → Stripe SDK presents native payment UI
        │
        ├── .completed ──▶ POST /mentor-slots/:id/confirm-payment { paymentIntentId }
        │                    → backend verifies PaymentIntent status in Stripe
        │                    → sets paymentStatus: PAID_ON_PLATFORM, slot.status: BOOKED
        │                    → returns updated MentorSlot
        │                    → UI shows "Booking confirmed" alert
        │
        ├── .canceled  ──▶ dismiss, no action (slot reservation expires after 15 min)
        │
        └── .failed    ──▶ show error alert
```

### Backend Safety Nets

- **15-minute reservation TTL**: cron job releases expired reservations every minute
- **Webhook**: `payment_intent.succeeded` confirms payment server-side (same logic as confirm-payment)
- **402 retry**: if PaymentIntent not yet `succeeded` when confirm-payment is called, backend returns 402
- **iOS does not retry 402** today — on failure we surface an error. The webhook is the safety net: if the user loses connectivity after paying, the next `GET /mentor-slots` will show the slot as `BOOKED` because the webhook flipped `paymentStatus` to `PAID` server-side.

---

## Timing & Lifecycle

All time windows the payment flow depends on. Keep these in sync with backend and the ToS.

| Window | Value | Enforced by | Where |
|---|---|---|---|
| Book cutoff before start | ≥ 30 min | iOS + backend | [MentorSlotsViewModel.slotTapped](../Places/Sources/Views/MentorSlots/MentorSlotsViewModel.swift#L88) |
| PaymentIntent / reservation TTL | 15 min | backend (cron/minute) | [MentorSlotsViewModel.confirmBook](../Places/Sources/Views/MentorSlots/MentorSlotsViewModel.swift#L117) |
| Student cancel cutoff before start | ≥ 2 h | iOS (client-side only — backend must also enforce) | [MyBookingsViewModel.action](../Profile/Sources/MyBookingsViewModel.swift#L65) |
| Reject (mentor no-show) window | `startTime … endTime + 30 min` | iOS (client-side only — backend must also enforce) | [MyBookingsViewModel.canReject](../Profile/Sources/MyBookingsViewModel.swift#L84) |
| Complete (student confirm) window | any time after `startTime` | iOS client (no upper bound today) | [MyBookingsViewModel.completeTapped](../Profile/Sources/MyBookingsViewModel.swift#L93) |
| Auto-complete after end | **not implemented** — sessions sit in "to confirm" forever unless user acts | — | — |
| Refund on cancel / reject | **no explicit iOS call** — backend must refund on `cancel` / `reject` | backend | en.lproj Localizable.strings ("Rejecting will cancel the booking and refund the payment") |
| Mentor payout timing | **not defined in client** — governed by Stripe Connect payout schedule on the Connected Account | Stripe | — |

### State transitions tied to money

```
AVAILABLE ─▶ RESERVATION_PENDING ─(paid / webhook)─▶ BOOKED ─▶ COMPLETED
                    │                                   │
                    ▼ (15-min TTL)                      ├─(student cancel ≥2h)──▶ CANCELLED  + refund
              AVAILABLE                                 └─(student reject ≤end+30m)▶ REJECTED + refund
```

---

## Safety Nets & Threat Model

### What the client must NEVER trust

- **Price**: iOS only displays `slot.price`; the PaymentIntent amount is set server-side from the stored slot. Never send price from client.
- **Slot availability**: booking eligibility (AVAILABLE, not own slot, ≥30 min, mentor onboarded) is re-checked by `POST /payment-intent`. The 30-min client check is UX sugar only.
- **Cancel / reject windows**: client enforces them for UX; backend must reject out-of-window requests with 400.
- **Payment status**: `paymentStatus: PAID` is only trustworthy after the webhook or confirm-payment has run server-side. Never mark a slot paid from a Stripe SDK `.completed` callback alone — that signal means "user tapped Pay", not "Stripe captured funds".

### Known risks & mitigations

| Risk | Mitigation | Status |
|---|---|---|
| Double payment on double-tap ("Zarezerwuj") | `isProcessingPayment` flag + alert dismissal. Backend should also key PaymentIntents by `(slotId, studentId, status≠succeeded)` to dedupe. | Client OK; backend dedupe should be verified. |
| Network drop between PaymentSheet `.completed` and `confirm-payment` | Stripe webhook (`payment_intent.succeeded`) promotes slot to BOOKED server-side. Next fetch shows correct state. | Present. |
| Race: slot reserved by A, A pays late (>15 min), B already re-booked | Backend must reject late confirm-payment with 409 and auto-refund the late capture. | **Needs backend verification.** |
| Chargeback after mentor payout | Stripe Connect payout schedule should delay payouts until refund window closes. | **Needs Dashboard configuration review.** |
| Stolen card fraud | Stripe Radar + PaymentSheet with 3DS handle this at the SDK layer. No extra client work. | Covered by Stripe. |
| Collusion (fake sessions to move money) | Rate-limit sessions per student↔mentor pair; monitor in Stripe Dashboard. | Out of scope for client. |
| Price drift mid-booking (mentor edits slot) | Slots are deleted/re-created, not edited; `AVAILABLE` slots can be deleted only when unbooked. | Covered. |
| Apple App Store review: IAP requirement | Mentoring is a real-world service (physical / person-to-person), exempt from IAP per App Store Review Guidelines §3.1.3(e). Must be clear from product description. | Keep marketing copy focused on in-person sessions. |

### Publishable key hygiene

`pk_*` keys are safe to ship in the binary. However:

> ⚠️ **Current config ships the same `pk_test_...` key in both [Dev.xcconfig](../../Configurations/Dev.xcconfig) and [Prod.xcconfig](../../Configurations/Prod.xcconfig).** Production builds are therefore in Stripe **test mode** and will not capture real funds. Before first real payment, replace the Prod value with a `pk_live_...` key and flip the Stripe Connect application to live mode.

Secret keys (`sk_*`, webhook signing secrets) must live only on the backend and never appear in the repo, Info.plist, or logs.

### Reliability gaps worth fixing

- No explicit 402 retry on `confirm-payment`. Consider: on 402, wait 1 s and retry up to 3×, then fall back to "we'll confirm shortly" state and rely on webhook + pull-to-refresh.
- No surfaced user feedback on `.canceled` — fine as UX, but log it for analytics.
- No auto-complete cron: a booking that the student never confirms stays in `BOOKED` forever. Mentor is not paid out until completion (if that's the payout trigger — verify). Add backend auto-complete `endTime + 48 h` or similar.
- Stripe onboarding opens in Safari via `UIApplication.open`. Consider `ASWebAuthenticationSession` for tighter return handling and no browser-history leakage.

### Error Cases

| HTTP Status | Meaning |
|-------------|---------|
| `400` | Own slot / too late to book (< 30 min) / mentor not onboarded |
| `404` | Slot not found |
| `409` | Slot not available / payment already exists |
| `402` | PaymentIntent not yet succeeded (retry) |

### ViewModel State

`MentorSlotsViewModel` manages the payment flow with these properties:

| Property | Type | Purpose |
|----------|------|---------|
| `isProcessingPayment` | `Bool` | Shows loading overlay during API calls |
| `showPaymentSheet` | `Bool` | Triggers PaymentSheet presentation |
| `paymentSheet` | `PaymentSheet?` | Configured sheet from `StripePaymentService` |
| `showPaymentSuccess` | `Bool` | Shows success alert after confirmed booking |
| `showPaymentError` | `Bool` | Shows error alert on payment failure |
| `currentPaymentIntentId` | `String?` | Stored for confirm-payment call |

---

## Configuration

### Publishable Key

The Stripe publishable key is injected via build configuration:

```
Configurations/Dev.xcconfig   →  STRIPE_PUBLISHABLE_KEY = pk_test_...
Configurations/Prod.xcconfig  →  STRIPE_PUBLISHABLE_KEY = pk_live_...
```

Read at runtime from `Info.plist` → `STRIPE_PUBLISHABLE_KEY`.

### Apple Pay

Apple Pay appears in the PaymentSheet **only** when all three are set up:

1. `STRIPE_APPLE_MERCHANT_ID` and `STRIPE_APPLE_MERCHANT_COUNTRY` in the xcconfig
   (exposed through `Info.plist`). Missing / empty ID → Apple Pay tile is hidden.
2. **Apple Pay capability** on the `ShredMate` target (both dev and prod), with
   the same merchant ID in the entitlement (`com.apple.developer.in-app-payments`).
3. The Apple Merchant ID registered on [Stripe Dashboard → Apple Pay].

The merchant ID is passed to `StripePaymentService` at init; the service sets
`PaymentSheet.Configuration.applePay` when the ID is non-empty.

### Xcode setup for Apple Pay

**One-time, in Apple Developer portal:**

- Certificates, Identifiers & Profiles → Identifiers → **Merchant IDs** → register
  e.g. `merchant.pl.shredmate.app`.
- Both App IDs (`pl.shredmate.app`, `pl.shredmate.app.dev`) must have the
  **Apple Pay Payment Processing** capability enabled, with the merchant ID
  associated to each.

**In Xcode, for both `ShredMate` and `ShredMate Dev` targets:**

- Signing & Capabilities → **+ Capability** → **Apple Pay**.
- Tick the merchant ID you registered.
  This writes `com.apple.developer.in-app-payments` into the respective
  `.entitlements` file.

**In Stripe Dashboard:**

- Settings → Payment methods → **Apple Pay** → add a new Apple Merchant ID →
  paste the same ID (Stripe will walk you through the CSR/certificate step).

**Testing:**

- Apple Pay does **not** work in the iOS Simulator with real cards — use a
  device with a test card set up in Wallet. For the simulator, Stripe renders
  the Apple Pay button in test mode but you cannot complete a real authorization.

### SDK Initialization

`StripeSetup.configure()` is called during `AppSetup.configure()`:

```swift
// StripeSetup.swift
static func configure() -> StripePaymentService {
    let info = Bundle.main.infoDictionary
    let key = info?["STRIPE_PUBLISHABLE_KEY"] as? String ?? ""
    let merchantId = info?["STRIPE_APPLE_MERCHANT_ID"] as? String
    let merchantCountry = info?["STRIPE_APPLE_MERCHANT_COUNTRY"] as? String ?? "PL"
    return StripePaymentService(
        publishableKey: key,
        applePayMerchantId: merchantId,
        applePayMerchantCountryCode: merchantCountry
    )
}
```

This sets `STPAPIClient.shared.publishableKey` once at app startup and stores
the Apple Pay merchant info used by `makePaymentSheet()`.

### Environment Injection

`StripePaymentService` is `@Observable` and injected into the SwiftUI environment at `ShredMateApp`:

```swift
.environment(dependencies.stripePaymentService)
```

Views in Places and Feed packages access it via `@Environment(StripePaymentService.self)` in their navigation destination modifiers, which pass it down to `MentorSlotsViewModel`.

---

## API Endpoints

### Mentor Onboarding

| Method | Path | Auth | Request | Response |
|--------|------|------|---------|----------|
| `POST` | `/riders/me/stripe/account` | Bearer | — | `{ accountId: String }` |
| `POST` | `/riders/me/stripe/onboarding-link` | Bearer | — | `{ url: String }` |
| `GET` | `/riders/me/stripe/status` | Bearer | — | `{ onboardingCompleted: Bool, payoutsEnabled: Bool }` |

### Slot Payment

| Method | Path | Auth | Request | Response |
|--------|------|------|---------|----------|
| `POST` | `/mentor-slots/:id/payment-intent` | Bearer | — | `{ paymentIntentId, clientSecret, amount, currency, publishableKey }` |
| `POST` | `/mentor-slots/:id/confirm-payment` | Bearer | `{ paymentIntentId }` | `MentorSlot` |

---

## Dependencies

| Dependency | Product Used | Purpose |
|------------|-------------|---------|
| `stripe-ios` (v24+) | `StripePaymentSheet` | PaymentSheet UI, STPAPIClient |

---

## File Index

### Networking Package

| File | Contents |
|------|----------|
| `API/StripeAPI.swift` | Endpoint definitions (account, onboarding-link, status) |
| `API/MentorSlotsAPI.swift` | Endpoint definitions (payment-intent, confirm-payment, book, cancel, complete) |
| `Models/StripeModels.swift` | `StripeAccount`, `StripeOnboardingLink`, `StripeStatus` DTOs |
| `Models/MentorSlot.swift` | `MentorSlot`, `PaymentIntentResponse`, `ConfirmPaymentBody`, status enums |
| `Services/StripeService.swift` | `StripeServiceProtocol` + implementation (onboarding REST calls) |
| `Services/MentorSlotsService.swift` | `MentorSlotsServiceProtocol` + implementation (slot + payment REST calls) |

### Payment Package

| File | Contents |
|------|----------|
| `StripePaymentService.swift` | `@Observable`, SDK init, `makePaymentSheet()`, `mapResult()` |
| `PaymentSheetPresenter.swift` | `.stripePaymentSheet()` SwiftUI view modifier |
| `PaymentResult.swift` | `.completed` / `.canceled` / `.failed(String)` enum |
| `Strings/PaymentStrings.swift` | Localized string keys |
| `Resources/en.lproj/Localizable.strings` | English translations |
| `Resources/pl.lproj/Localizable.strings` | Polish translations |

### Places Package (Slot Booking + Payment)

| File | Contents |
|------|----------|
| `Views/MentorSlots/MentorSlotsSection.swift` | Slot cards UI, `.stripePaymentSheet()` modifier, payment alerts |
| `Views/MentorSlots/MentorSlotsViewModel.swift` | Payment flow orchestration (create intent → sheet → confirm) |
| `Views/MentorSlots/MentorSlotCard.swift` | Individual slot card display |

### Profile Package (Stripe Onboarding)

| File | Contents |
|------|----------|
| `StripeOnboardingView.swift` | Onboarding UI (description, status card, action buttons) |
| `StripeOnboardingViewModel.swift` | State machine, API orchestration, URL opening |
| `Strings/StripeStrings.swift` | Localized string keys for onboarding |

### App Package

| File | Contents |
|------|----------|
| `StripeSetup.swift` | Reads publishable key, creates `StripePaymentService` |
| `AppSetup.swift` | Wires `stripeService` + `stripePaymentService` into `AppDependencies` |
| `ShredMateApp.swift` | `.environment(dependencies.stripePaymentService)` injection |
