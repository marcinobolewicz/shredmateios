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
