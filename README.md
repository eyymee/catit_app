# catit — Catit down. Get it done.

Your household isn't going to manage itself. catit is a focused Flutter app for people who have groceries to buy, routines to keep, and upcoming tasks quietly piling up in the back of their mind. Warm, minimal, and ruthlessly practical.

---

## Download

Grab the latest release APK from the [Releases](../../releases) page — no account, no store, no waiting.

**Install on Android (sideload):**
1. Download `app-release.apk`
2. On your phone go to **Settings → Apps → Special app access → Install unknown apps** and allow your browser or file manager
3. Open the downloaded file and tap Install
4. Done — find catit in your app drawer

> Android 8.0+ required.

---

## What it does

### Home
The big picture at a glance. A circular progress ring shows how far through today's routines you are, a groceries summary tells you what's left to grab, and your next upcoming reminders sit right there waiting to be ignored — or actually handled.

### Groceries
Type it in, check it off. The list persists between sessions so you won't forget you still need oat milk. Tap *Complete list* when you're done and start fresh.

### Routines
Daily habits you actually track. Add a name, optional time, optional note — then tick things off as the day moves. A progress bar keeps it honest. Reset whenever life derails you (no judgement).

### Upcoming
Tasks with a real date attached. Set the date, time, location, and priority. catit sorts them automatically into Today / This week / This month / Future so you can panic in the right order. Completed tasks drop to the bottom of the page and clear out every Sunday at 11:59 PM.

---

## Tech stack

| Layer | Library |
|---|---|
| Framework | Flutter 3.x (Dart ^3.5) |
| State management | Riverpod 2.x (`StateNotifier`, `Provider`) |
| Navigation | GoRouter 14.x |
| Local storage | Hive Flutter |
| Fonts | Plus Jakarta Sans (headings), Inter (body) via Google Fonts |
| IDs | uuid 4.x |
| Date formatting | intl |

---

## Project structure

```
lib/
├── core/
│   ├── router/         # GoRouter setup
│   └── theme/          # Colors, spacing, text styles, Material theme
├── features/
│   ├── home/           # Dashboard screen
│   ├── groceries/      # Grocery list screen
│   ├── routine/        # Daily routines screen
│   └── upcoming/       # Upcoming tasks screen
├── models/             # GroceryItem, RoutineTask, UpcomingTask
├── providers/          # Riverpod providers for each feature
└── shared/
    └── widgets/        # AppTopBar, ResponsiveLayout, TimePickerSheet
```

---

## Getting started

**You'll need:**
- Flutter SDK ≥ 3.5
- Dart SDK ≥ 3.5
- Android SDK (for Android builds)

```bash
flutter pub get
flutter run
```

```bash
# Release build
flutter build apk --release
```

---

## Design

The palette leans warm on purpose — cream background, terracotta primary, sage green accents. It's a household app, not a dashboard for a hedge fund.

| Token | Value |
|---|---|
| Background | `#FFF9E7` warm cream |
| Primary | `#944A00` / `#E67E22` terracotta |
| Secondary | `#286B33` sage green |
| Headings | Plus Jakarta Sans |
| Body & labels | Inter |
| Max content width | 720px |
| Padding | 20px mobile → 32px tablet → 48px desktop |

---

## Package ID

`com.catit.catit_app`
