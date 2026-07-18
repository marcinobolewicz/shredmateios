# Mentor Slots — rezerwacje, płatności, cykl życia

> Base URL: `https://api.shredmate.eu/api/v1` · Auth: `Authorization: Bearer <accessToken>`
> Źródło prawdy dla backendu: `shredmatebe/docs/stripe.md` (płatności) i `src/mentor-slots/` (okna czasowe).
> Integracja Stripe w iOS: `Packages/Payment/STRIPE.md`.
>
> ⚠️ Ten dokument zastępuje starą wersję: endpoint `POST /mentor-slots/:id/book` **nie istnieje** —
> rezerwacja odbywa się wyłącznie przez płatność (`payment-intent` → Stripe → `confirm-payment`).

---

## 1. Cykl życia slotu

```
AVAILABLE ──(payment-intent)──▶ RESERVATION_PENDING ──(płatność OK)──▶ BOOKED
   ▲                                   │                                 │
   └────────(15 min TTL minęło)────────┘                                 │
                                                                         │
        ┌────────────────────────────────────────────────────────────────┤
        │ uczeń cancel ≥ 2 h przed startem   → CANCELLED + pełny REFUND
        │ uczeń reject ≤ koniec + 30 min     → REJECTED  + pełny REFUND
        │ uczeń complete (po starcie)        → COMPLETED → transfer do mentora
        │ nikt nic przez 48 h po końcu       → COMPLETED → transfer do mentora
        └───────────────────────────────────────────────────────────────
```

- `CANCELLED`/`REJECTED` są **terminalne** — slot nie wraca do sprzedaży (zachowuje rekord
  płatności/zwrotu). Mentor może wygenerować nowy slot w tym samym terminie — generator
  ignoruje sloty CANCELLED przy sprawdzaniu konfliktów.
- Jeżeli zwrot następuje po wypłacie mentorowi (np. reject tuż przed auto-complete),
  backend najpierw cofa transfer (reversal), potem zwraca środki uczniowi — klient nic
  nie musi robić.

### Okna czasowe (wymuszane serwerowo; klientowe checki to tylko UX)

| Okno | Wartość | Endpoint |
|---|---|---|
| Rezerwacja najpóźniej | 30 min przed startem | `POST /:id/payment-intent` → 400 |
| Blokada slotu na płatność | 15 min | cron zwalnia po TTL |
| Anulowanie ucznia (pełny zwrot) | ≥ 2 h przed startem | `POST /:id/cancel` → 400 po terminie |
| Zgłoszenie nieobecności mentora (pełny zwrot) | od startu do 30 min po końcu | `POST /:id/reject` → 400 poza oknem |
| Potwierdzenie sesji | po starcie, bez górnego limitu | `POST /:id/complete` |
| Auto-potwierdzenie (wypłata mentorowi) | 48 h po końcu | cron |

---

## 2. Endpointy

| Metoda | Ścieżka | Kto | Opis |
|---|---|---|---|
| `POST` | `/mentor-slots/generate` | mentor | generuje sloty wg tygodniowego harmonogramu |
| `GET` | `/mentor-slots` | wszyscy | lista z filtrami (`mentorRiderId`, `sportId`, `placeId`, `status`, `from`, `to`, paginacja) |
| `GET` | `/mentor-slots/my` | mentor | moje sloty (jako mentor) |
| `GET` | `/mentor-slots/booked-by-me` | uczeń | moje rezerwacje (jako uczeń) |
| `POST` | `/mentor-slots/:id/payment-intent` | uczeń | rezerwuje slot na 15 min + zwraca `clientSecret` Stripe |
| `POST` | `/mentor-slots/:id/confirm-payment` | uczeń | finalizuje po płatności (idempotentne; webhook to backup) |
| `POST` | `/mentor-slots/:id/cancel` | uczeń | anuluje ≥2 h przed startem → CANCELLED + refund |
| `POST` | `/mentor-slots/:id/reject` | uczeń | mentor się nie pojawił → REJECTED + refund |
| `POST` | `/mentor-slots/:id/complete` | uczeń | potwierdza sesję + opcjonalna rekomendacja → transfer do mentora |
| `DELETE` | `/mentor-slots/:id` | mentor | usuwa **niezarezerwowany** slot (409 gdy booked) |

### Typ `MentorSlot` (odpowiedź API)

```ts
interface MentorSlot {
  id: string;
  startTime: string;        // ISO 8601
  endTime: string;
  duration: number;         // minuty (30 | 60)
  price: number;            // grosze — wyświetlaj price / 100
  currency: string;         // "PLN"
  status: 'AVAILABLE' | 'RESERVATION_PENDING' | 'BOOKED' | 'COMPLETED' | 'CANCELLED' | 'REJECTED';
  paymentStatus: 'PENDING' | 'PAID' | 'REFUNDED' | null;
  recommendationStatus: 'PENDING' | 'RECOMMENDED' | 'DISMISSED' | null;
  rejectionMessage: string | null;
  createdAt: string;
  mentorRider: { id: string; displayName: string; avatarUrl: string | null;
                 recommendationCount: number; sessionCount: number };
  studentRider: { id: string; displayName: string; avatarUrl: string | null } | null;
  sport: { id: string; name: string; slug: string };
  place: { id: string; name: string; avatarUrl: string | null } | null;
}
```

---

## 3. Generowanie slotów (mentor)

`POST /mentor-slots/generate` — wymaga `isMentor: true` dla danego sportu (403 w przeciwnym razie).

```jsonc
{
  "sportId": "…",
  "placeId": "…",            // opcjonalne
  "weekdays": [1, 2, 3],      // 0=Nd … 6=Sb
  "timeFrom": "14:00",
  "timeTo": "18:00",
  "duration": 60,             // 30 | 60
  "price": 15000,             // grosze! (150 PLN)
  "startDate": "2026-08-01",  // opcjonalne; max 31 dni od dziś
  "endDate": "2026-08-14"     // opcjonalne; domyślnie startDate + 7 dni
}
```

Odpowiedź: `{ generated, skipped, skippedSlots[] }` — `skipped` to kolizje z istniejącymi
slotami (sloty CANCELLED nie blokują — można ponownie wystawić anulowany termin).

Warunek przyjmowania rezerwacji: ukończony onboarding Stripe
(`stripeChargesEnabled`) **oraz** zaakceptowany aktualny regulamin mentora
(`403 MENTOR_TERMS_ACCEPTANCE_REQUIRED` przy onboardingu — patrz `shredmatebe/docs/legal.md`).

---

## 4. Rezerwacja i płatność (uczeń)

```
1. POST /mentor-slots/:id/payment-intent
   ← { paymentIntentId, clientSecret, amount, currency, publishableKey }
   Slot: AVAILABLE → RESERVATION_PENDING (15 min)
   Błędy: 400 własny slot / <30 min do startu / mentor bez onboardingu; 409 slot zajęty

2. Stripe PaymentSheet (clientSecret)   ← iOS: StripePaymentService

3. POST /mentor-slots/:id/confirm-payment { paymentIntentId }
   ← 200 potwierdzone (slot BOOKED)
   ← 402 płatność jeszcze nie przeszła (retry po stronie klienta)
   ← 400 płatność padła (slot wraca do AVAILABLE)
   Webhook payment_intent.succeeded robi to samo niezależnie — kto pierwszy, ten wygrywa.
```

Cena zawsze z serwera (`slot.price`) — klient **nigdy** nie wysyła kwoty.
W UI rezerwacji pokazujemy sprzedawcę: „Kupujesz sesję od: {mentor}. Operator platformy: ShredMate".

---

## 5. Moje rezerwacje (uczeń) — akcje wg stanu

| Stan slotu | Czas | Akcja |
|---|---|---|
| `BOOKED` | > 2 h do startu | „Anuluj rezerwację" (dialog informuje o pełnym zwrocie) |
| `BOOKED` | < 2 h do startu | przycisk wyszarzony — za późno |
| `BOOKED` | po starcie | „Potwierdź sesję" (+ 👍 rekomendacja) oraz — do 30 min po końcu — „Mentor nie dotarł" |
| `COMPLETED` | — | status rekomendacji |
| `CANCELLED` / `REJECTED` | — | wpis historyczny (zwrot środków) |

- `POST /:id/cancel` → 400 po terminie, 409 przy wyścigu statusów („odśwież i spróbuj ponownie").
- `POST /:id/reject` body: `{ "message": "…" }` (opcjonalne).
- `POST /:id/complete` body: `{ "recommend": true | false }` → 409 jeśli już potwierdzona.
- Zwroty idą na kartę użytą do płatności (księgowanie 5–10 dni roboczych).

iOS: logika okien w `Packages/Profile/Sources/MyBookingsViewModel.swift` (musi być zgodna
z tabelą z sekcji 1 — przy zmianie stałych na BE aktualizować oba miejsca + regulamin §6).

---

## 6. Rekomendacje i statystyki mentora

- Rekomendacja jest **binarna** (👍 albo nic) i możliwa wyłącznie przy `complete` opłaconej sesji.
- `GET /riders/:riderId` zwraca `recommendationCount` i `sessionCount`.
- Kolejność mentorów na listach: `recommendationCount` malejąco, potem alfabetycznie —
  ta reguła jest publikowana w regulaminie (P2B); nie zmieniać bez aktualizacji regulaminu.
