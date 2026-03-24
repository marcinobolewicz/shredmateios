@@ -0,0 +1,435 @@
# Mentor Slots — Frontend Web Guide

> Base URL: `https://api.shredmate.eu/api/v1`
> Auth: `Authorization: Bearer <accessToken>` (wszystkie endpointy)

---

## 1. Dodawanie slotów przez mentora

### UI — button "Dodaj sloty" na profilu mentora

Przycisk **"Dodaj sloty"** pokazuj tylko gdy `currentRider.id === profileRider.id` i rider ma `isMentor: true` dla co najmniej jednego sportu (sprawdź z `GET /riders/me/sports`).

Po kliknięciu otwiera się panel/modal z formularzem generatora.

---

### UI — formularz generatora slotów

```
┌──────────────────────────────────────────────────────┐
│  Dodaj sloty                                         │
│                                                      │
│  Sport:  [ Wakeboard ▾ ]   Spot:  [ Wake Trip ▾ ]   │
│                                                      │
│  Dni tygodnia:                                       │
│  [ Pn ] [ Wt ] [ Śr ] [ Cz ] [ Pt ] [ Sb ] [ Nd ]  │
│  [ Dni robocze ]           [ Cały tydzień ]          │
│                                                      │
│  Godziny:  [ 14 : 00 ]  —  [ 18 : 00 ]              │
│                                                      │
│  Czas trwania:  ( 30 min )  ( 60 min )               │
│                                                      │
│  Cena:  [ 150 ] PLN za sesję                         │
│                                                      │
│              [ Wygeneruj sloty ]                     │
└──────────────────────────────────────────────────────┘
```

**Stan formularza (React przykład):**
```ts
const [form, setForm] = useState({
  sportId: '',
  placeId: '',
  weekdays: [] as number[],   // 0=Nd 1=Pn 2=Wt 3=Śr 4=Cz 5=Pt 6=Sb
  timeFrom: '14:00',
  timeTo:   '18:00',
  duration: 60 as 30 | 60,
  price: 150,                 // wyświetlasz PLN, wysyłasz grosze (×100)
});
```

**Przyciski dni tygodnia:**
```ts
const DAYS = ['Nd', 'Pn', 'Wt', 'Śr', 'Cz', 'Pt', 'Sb'];

// toggle pojedynczego dnia
const toggleDay = (day: number) =>
  setForm(f => ({
    ...f,
    weekdays: f.weekdays.includes(day)
      ? f.weekdays.filter(d => d !== day)
      : [...f.weekdays, day],
  }));

// presety
const setWeekdays  = () => setForm(f => ({ ...f, weekdays: [1, 2, 3, 4, 5] }));
const setEveryDay  = () => setForm(f => ({ ...f, weekdays: [0, 1, 2, 3, 4, 5, 6] }));
```

---

### Request — generowanie slotów

`POST /mentor-slots/generate`

```ts
async function generateSlots(form: typeof initialForm, token: string) {
  const res = await fetch(`${BASE_URL}/mentor-slots/generate`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify({
      sportId:  form.sportId,
      placeId:  form.placeId || undefined,   // pomiń jeśli puste
      weekdays: form.weekdays,
      timeFrom: form.timeFrom,               // "14:00"
      timeTo:   form.timeTo,                 // "18:00"
      duration: form.duration,               // 30 | 60
      price:    form.price * 100,            // PLN → grosze
    }),
  });

  if (!res.ok) {
    const err = await res.json();
    throw new Error(err.message ?? 'Błąd generowania slotów');
  }

  return res.json() as Promise<GenerateSlotsResponse>;
}
```

### Response

```ts
interface GenerateSlotsResponse {
  generated: number;
  skipped: number;
  skippedSlots: Array<{ startTime: string; endTime: string }>;
}
```

**Obsługa response:**
```ts
const result = await generateSlots(form, token);

if (result.generated === 0 && result.skipped > 0) {
  showToast('Wszystkie sloty już istnieją w tym przedziale', 'warning');
} else if (result.skipped > 0) {
  showToast(
    `Wygenerowano ${result.generated} slotów. Pominięto ${result.skipped} (konflikt z istniejącymi).`,
    'info'
  );
} else {
  showToast(`Wygenerowano ${result.generated} slotów`, 'success');
}

closeModal();
refetchSlots();   // odśwież listę slotów mentora
```

**Walidacja po stronie frontu (przed wysłaniem):**
```ts
if (form.weekdays.length === 0) return showError('Wybierz co najmniej jeden dzień');
if (!form.sportId)              return showError('Wybierz sport');
if (form.timeFrom >= form.timeTo) return showError('Godzina końca musi być po godzinie startu');
if (form.price <= 0)            return showError('Cena musi być większa niż 0');
```

---

## 2. Wyświetlanie slotów mentora

### Pobieranie slotów

**Sloty konkretnego mentora** (widok profilu innego ridera):
```ts
async function fetchMentorSlots(mentorRiderId: string, token: string) {
  const from = new Date().toISOString();
  const to   = new Date(Date.now() + 14 * 24 * 60 * 60 * 1000).toISOString();

  const params = new URLSearchParams({
    mentorRiderId,
    status: 'AVAILABLE',
    from,
    to,
    limit: '100',
  });

  const res = await fetch(`${BASE_URL}/mentor-slots?${params}`, {
    headers: { Authorization: `Bearer ${token}` },
  });

  return res.json() as Promise<{ items: MentorSlot[]; total: number }>;
}
```

**Własne sloty mentora** (widok "moje sloty"):
```ts
const res = await fetch(`${BASE_URL}/mentor-slots/my?limit=100`, {
  headers: { Authorization: `Bearer ${token}` },
});
```

---

### Typy

```ts
interface MentorSlot {
  id: string;
  startTime: string;       // ISO 8601
  endTime: string;         // ISO 8601
  duration: number;        // minuty
  price: number;           // grosze — wyświetl jako price / 100
  currency: string;        // "PLN"
  status: 'AVAILABLE' | 'BOOKED' | 'COMPLETED' | 'CANCELLED';
  paymentStatus: 'PENDING' | 'PAID' | 'REFUNDED' | null;
  recommendationStatus: 'PENDING' | 'RECOMMENDED' | 'DISMISSED' | null;
  mentorRider: { id: string; displayName: string; avatarUrl: string | null; recommendationCount: number; sessionCount: number };
  studentRider: { id: string; displayName: string; avatarUrl: string | null } | null;
  sport: { id: string; name: string; slug: string };
  place: { id: string; name: string; avatarUrl: string | null } | null;
}
```

---

### UI — lista slotów zgrupowana po dniach

```
┌──────────────────────────────────────────────────┐
│  Dostępne terminy                                │
│                                                  │
│  Wtorek, 25 marca                                │
│  ┌──────────────┐  ┌──────────────┐             │
│  │  14:00–15:00 │  │  15:00–16:00 │             │
│  │   60 min     │  │   60 min     │             │
│  │   150,00 PLN │  │   150,00 PLN │             │
│  └──────────────┘  └──────────────┘             │
│                                                  │
│  Środa, 26 marca                                 │
│  ┌──────────────┐                               │
│  │  14:00–15:00 │                               │
│  │   60 min     │                               │
│  │   150,00 PLN │                               │
│  └──────────────┘                               │
└──────────────────────────────────────────────────┘
```

**Grupowanie po dniach:**
```ts
function groupByDay(slots: MentorSlot[]) {
  return slots.reduce<Record<string, MentorSlot[]>>((acc, slot) => {
    const day = slot.startTime.slice(0, 10); // "2026-03-25"
    if (!acc[day]) acc[day] = [];
    acc[day].push(slot);
    return acc;
  }, {});
}

function formatDayHeader(dateStr: string) {
  return new Date(dateStr).toLocaleDateString('pl-PL', {
    weekday: 'long',
    day: 'numeric',
    month: 'long',
  }); // "wtorek, 25 marca"
}

function formatTimeRange(slot: MentorSlot) {
  const fmt = (iso: string) =>
    new Date(iso).toLocaleTimeString('pl-PL', { hour: '2-digit', minute: '2-digit' });
  return `${fmt(slot.startTime)}–${fmt(slot.endTime)}`; // "14:00–15:00"
}

function formatPrice(grosz: number) {
  return (grosz / 100).toFixed(2).replace('.', ',') + ' PLN'; // "150,00 PLN"
}
```

---

### Kliknięcie w slot — popup

Wyświetl popup zależnie od tego czy `currentRider.id === slot.mentorRider.id`:

**Widok ucznia** (`currentRider.id !== slot.mentorRider.id`):

```
┌──────────────────────────────────┐
│  Zarezerwować sesję?             │
│                                  │
│  Wtorek, 25 marca                │
│  14:00–15:00 · 60 min            │
│  150,00 PLN                      │
│  Mentor: Jan Kowalski            │
│  Spot: Wake Trip Wołów           │
│                                  │
│  [ Anuluj ]   [ Zarezerwuj ]     │
└──────────────────────────────────┘
```

**Widok mentora** (własny slot, status `AVAILABLE`):

```
┌──────────────────────────────────┐
│  Usunąć slot?                    │
│                                  │
│  Wtorek, 25 marca                │
│  14:00–15:00 · 60 min            │
│                                  │
│  [ Anuluj ]    [ Usuń slot ]     │
└──────────────────────────────────┘
```

---

### Request — rezerwacja

`POST /mentor-slots/:id/book`

```ts
async function bookSlot(slotId: string, token: string) {
  const res = await fetch(`${BASE_URL}/mentor-slots/${slotId}/book`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${token}` },
  });

  if (res.status === 409) throw new Error('Slot został właśnie zarezerwowany przez kogoś innego');
  if (res.status === 400) {
    const err = await res.json();
    throw new Error(err.message); // "Slots can only be booked at least 30 minutes before start"
  }
  if (!res.ok) throw new Error('Błąd rezerwacji');

  return res.json() as Promise<MentorSlot>;
}
```

---

### Request — usunięcie slotu (mentor)

`DELETE /mentor-slots/:id`

```ts
async function deleteSlot(slotId: string, token: string) {
  const res = await fetch(`${BASE_URL}/mentor-slots/${slotId}`, {
    method: 'DELETE',
    headers: { Authorization: `Bearer ${token}` },
  });

  if (res.status === 409) throw new Error('Nie można usunąć zarezerwowanego slotu');
  if (!res.ok) throw new Error('Błąd usuwania slotu');
  // 204 No Content — brak body
}
```

---

### Blokada przycisku "Zarezerwuj"

Ukryj lub zablokuj przycisk gdy zostało mniej niż 30 minut do startu:

```ts
function canBook(slot: MentorSlot): boolean {
  const minutesLeft = (new Date(slot.startTime).getTime() - Date.now()) / 60_000;
  return minutesLeft >= 30 && slot.studentRiderId === null;
}
```

---

## 3. Widok "Moje rezerwacje" (uczeń)

Sloty zarezerwowane przez zalogowanego ucznia — lista z opcją anulowania i potwierdzenia po sesji.

```ts
const res = await fetch(`${BASE_URL}/mentor-slots/booked-by-me`, {
  headers: { Authorization: `Bearer ${token}` },
});
```

**Logika przycisków akcji:**

| Status | startTime | Akcja dla ucznia |
|--------|-----------|-----------------|
| `BOOKED` | w przyszłości (≥2h) | Przycisk **"Anuluj rezerwację"** |
| `BOOKED` | w przyszłości (<2h) | Przycisk wyszarzony "Zbyt późno na anulowanie" |
| `BOOKED` | w przeszłości | Przycisk **"Potwierdź sesję"** |
| `COMPLETED` | — | Wyświetl status rekomendacji |

### Request — anulowanie

`POST /mentor-slots/:id/cancel`

```ts
async function cancelBooking(slotId: string, token: string) {
  const res = await fetch(`${BASE_URL}/mentor-slots/${slotId}/cancel`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${token}` },
  });

  if (res.status === 400) throw new Error('Zbyt późno na anulowanie (mniej niż 2h przed startem)');
  if (!res.ok) throw new Error('Błąd anulowania');

  return res.json() as Promise<MentorSlot>;
}
```

### Request — potwierdzenie sesji + rekomendacja

`POST /mentor-slots/:id/complete`

Popup po kliknięciu "Potwierdź sesję":
```
┌──────────────────────────────────────┐
│  Jak minęła sesja z Jan Kowalski?    │
│                                      │
│  [ Polecam mentora  👍 ]             │
│  [ Bez rekomendacji ]               │
└──────────────────────────────────────┘
```

```ts
async function completeSession(slotId: string, recommend: boolean, token: string) {
  const res = await fetch(`${BASE_URL}/mentor-slots/${slotId}/complete`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify({ recommend }),
  });

  if (res.status === 409) throw new Error('Sesja już potwierdzona');
  if (!res.ok) throw new Error('Błąd potwierdzenia sesji');

  return res.json() as Promise<MentorSlot>;
}
```

---

## 4. Profil mentora — statystyki

Przy `GET /riders/:riderId` zwracane są `recommendationCount` i `sessionCount`.

```
┌────────────────────────────────────────────┐
│  Jan Kowalski                              │
│  Wakeboard · Mentor                        │
│                                            │
│  ⭐ 20 rekomendacji   📋 34 sesje          │
│                                            │
│              [ Dodaj sloty ]               │  ← tylko gdy to mój profil
└────────────────────────────────────────────┘
```

```ts
const { recommendationCount, sessionCount } = rider;
// "⭐ 20 rekomendacji · 34 sesje"
```
