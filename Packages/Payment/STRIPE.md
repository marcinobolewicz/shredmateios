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
│  Profile (mentor)          │  Booking (rider)                    │
│                            │                                     │
│  StripeOnboardingView      │  (future) BookingPaymentView        │
│         │                  │         │                           │
│  StripeOnboardingViewModel │  (future) BookingPaymentViewModel   │
│         │                  │         │                           │
├──────────────────────────────────────────────────────────────────┤
│  Networking                │  Payment                            │
│                            │                                     │
│  StripeService             │  StripePaymentService               │
│  (REST: account, status,   │  (Stripe SDK: PaymentSheet,         │
│   onboarding-link)         │   publishable key init)             │
│         │                  │         │                           │
│  StripeAPI (endpoints)     │  PaymentSheetPresenter (SwiftUI)    │
│  StripeModels (DTOs)       │  PaymentResult (app enum)           │
│         │                  │                                     │
│  AuthenticatingHTTPClient  │  StripePaymentSheet (Stripe SDK)    │
└──────────────────────────────────────────────────────────────────┘
```

### Package Responsibilities

| Package | Role |
|---------|------|
| `Networking` | REST calls to ShredMate backend (`StripeService`, `StripeAPI`, `StripeModels`) |
| `Payment` | Stripe iOS SDK wrapper (`StripePaymentService`, `PaymentSheetPresenter`, `PaymentResult`) |
| `Profile` | Mentor onboarding UI (`StripeOnboardingView`, `StripeOnboardingViewModel`) |
| `App` | SDK initialization (`StripeSetup`), DI wiring in `AppSetup` |

---

## Flow 1: Mentor Stripe Onboarding

### Entry Point

Profile menu shows "Payment Setup" link when the mentor has at least one sport with `isMentor: true` (`hasMentorSports` condition).

### Steps

```
User taps "Set Up Payments"
        │
        ▼
POST /mentors/me/stripe/account
  → creates Stripe Connected Account on backend
  → returns { accountId }
        │
        ▼
POST /mentors/me/stripe/onboarding-link
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
GET /mentors/me/stripe/status
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

> **Status: SDK integrated, flow not yet connected to booking.**

### Components Ready

- `StripePaymentService.makePaymentSheet(clientSecret:)` — builds a configured `PaymentSheet`
- `PaymentSheetPresenter` — `.stripePaymentSheet(isPresented:paymentSheet:onResult:)` SwiftUI modifier
- `PaymentResult` — app-level enum (`.completed` / `.canceled` / `.failed(String)`)

### Future Flow (not yet implemented)

```
Rider taps "Book & Pay" on a mentor slot
        │
        ▼
POST /bookings/:slotId/payment-intent   (backend creates PaymentIntent)
  → returns { clientSecret, customerId?, ephemeralKeySecret? }
        │
        ▼
StripePaymentService.makePaymentSheet(clientSecret:)
  → returns configured PaymentSheet
        │
        ▼
.stripePaymentSheet(isPresented:paymentSheet:onResult:)
  → Stripe SDK presents native payment UI
        │
        ├── .completed → confirm booking on backend
        ├── .canceled  → dismiss, no action
        └── .failed    → show error alert
```

---

## Configuration

### Publishable Key

The Stripe publishable key is injected via build configuration:

```
Configurations/Dev.xcconfig   →  STRIPE_PUBLISHABLE_KEY = pk_test_...
Configurations/Prod.xcconfig  →  STRIPE_PUBLISHABLE_KEY = pk_live_...
```

Read at runtime from `Info.plist` → `STRIPE_PUBLISHABLE_KEY`.

### SDK Initialization

`StripeSetup.configure()` is called during `AppSetup.configure()`:

```swift
// StripeSetup.swift
static func configure() -> StripePaymentService {
    let key = Bundle.main.infoDictionary?["STRIPE_PUBLISHABLE_KEY"] as? String ?? ""
    return StripePaymentService(publishableKey: key)
}
```

This sets `STPAPIClient.shared.publishableKey` once at app startup.

---

## API Endpoints

### Mentor Onboarding

| Method | Path | Auth | Request | Response |
|--------|------|------|---------|----------|
| `POST` | `/mentors/me/stripe/account` | Bearer | — | `{ accountId: String }` |
| `POST` | `/mentors/me/stripe/onboarding-link` | Bearer | — | `{ url: String }` |
| `GET` | `/mentors/me/stripe/status` | Bearer | — | `{ onboardingCompleted: Bool, payoutsEnabled: Bool }` |

### Payment (future)

| Method | Path | Auth | Request | Response |
|--------|------|------|---------|----------|
| `POST` | `/bookings/:slotId/payment-intent` | Bearer | — | `{ clientSecret, customerId?, ephemeralKeySecret? }` |

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
| `Models/StripeModels.swift` | `StripeAccount`, `StripeOnboardingLink`, `StripeStatus` DTOs |
| `Services/StripeService.swift` | `StripeServiceProtocol` + implementation (REST calls) |

### Payment Package

| File | Contents |
|------|----------|
| `StripePaymentService.swift` | SDK init, `makePaymentSheet()`, `mapResult()` |
| `PaymentSheetPresenter.swift` | `.stripePaymentSheet()` SwiftUI view modifier |
| `PaymentResult.swift` | `.completed` / `.canceled` / `.failed(String)` enum |
| `Strings/PaymentStrings.swift` | Localized string keys |
| `Resources/en.lproj/Localizable.strings` | English translations |
| `Resources/pl.lproj/Localizable.strings` | Polish translations |

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
