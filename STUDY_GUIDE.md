# TP Mentorship — Complete Beginner's Study Guide

> Written for someone who has **never coded**. By the end you'll know what every file does,
> which files actually change what you see, and you'll be ready for the demo + Q&A.
>
> **How to read this:** Part 1–3 build your mental model. Part 4 is the file-by-file tour
> (the big one). Part 5 traces what happens when you tap the app icon. Part 6 is the Q&A
> bank. Part 7 is the live-demo script.

---

## The traffic-light system (the single most useful idea in this guide)

Your project has ~40+ files, but **you only ever wrote or care about a handful.** Everything
else is automatic plumbing. I mark every file with one of these:

- 🟢 **GREEN — This is YOUR app.** You wrote it. It directly controls what appears on screen. *Understand these deeply.*
- 🟡 **YELLOW — Settings/config.** You occasionally edit these (add a package, change the app name). *Understand what they're for.*
- ⚪ **WHITE — Auto-generated plumbing.** The tools create and manage these. You never touch them. *Just know what they are so you're not confused.*

**Short version of "what affects my output":** almost everything you see on screen comes from
the 🟢 files inside the `lib/` folder. That's it. The rest makes the app *build and run*, but
doesn't decide what the screens look like.

---

# PART 1 — What is this thing, really?

### Flutter and Dart
- **Dart** is the *programming language* you wrote in (the `.dart` files). It's the words.
- **Flutter** is the *toolkit* that turns Dart code into an actual phone app with buttons and screens. It's the machine that builds the app.
- You write Dart → Flutter draws it on the phone.

### "Everything is a Widget"
In Flutter, *every single thing on screen is a "widget"*: a piece of text is a widget, a button
is a widget, spacing is a widget, the whole screen is a widget. Widgets sit inside other widgets
like Russian nesting dolls. That nested pile is called the **widget tree**, and it *is* your UI.

### How the app decides what to show
Every widget has a **`build()`** function that returns "here's what I look like." When something
changes (you type, you tap), the relevant part re-runs `build()` and redraws. That's the whole loop.

---

# PART 2 — The five concepts behind your code

1. **Stateless vs Stateful widget**
   - *Stateless* = shows what it's given, never changes on its own. (e.g. `MentorCard` — just displays a mentor.)
   - *Stateful* = can change over time. (e.g. `LoginScreen` — reacts to typing and taps.)
   - Memory hook: *"if it must remember or change something, it's Stateful."*

2. **`setState()`** — in a stateful widget, this means "something changed, redraw me." Without it, a changed value won't show up on screen.

3. **State management (Riverpod)** — `setState` only updates one widget. But "am I logged in?" must be known by the *whole* app. **Riverpod** stores that in a shared box called a *provider* that any screen can read.

4. **async / await / Future** — talking to Firebase is slow (it uses the internet). `Future` = "an answer that arrives later." `await` = "wait here for it." `async` = "this function is allowed to wait." This is why login is written `Future<void> _login() async`.

5. **Models vs Data** — a *model* describes the *shape* of a thing (a Mentor has a name, rating, subjects…). The *data* is the actual filled-in examples (Damian Tan, 4.8 stars…).

---

# PART 3 — The folder map at a glance

```
tpmentorship/
│
├── lib/              🟢 YOUR ACTUAL APP — everything you see lives here
├── android/          🟡 Android-specific settings (app name, icon, Firebase key)
├── test/             🟢 Automated tests (you have one real test file)
│
├── pubspec.yaml      🟡 The "shopping list" of packages + app settings  ← important
├── pubspec.lock      ⚪ Exact versions locked (auto)
├── analysis_options.yaml 🟡 Code-style rules
│
├── .idea/            ⚪ Android Studio's personal settings for this project
├── .dart_tool/       ⚪ Tool cache (auto, huge, ignore)
├── build/            ⚪ The compiled app output (auto, regenerated every run)
│
├── .metadata         ⚪ Flutter's internal bookkeeping
├── .flutter-plugins-dependencies ⚪ Auto list of plugins
├── .gitignore        🟡 Tells Git which files to skip
├── tpmentorship.iml  ⚪ Android Studio module description
│
├── README.md         ⚪ Default project readme (harmless)
├── CLAUDE.md         ⚪ Notes file (not part of the app)
├── DEVELOPMENT_SUMMARY.md  ⚪ Your written summary (docs, not code)
└── STUDY_GUIDE.md    ⚪ This file
```

**If you remember one thing:** the `lib/` folder is your app. Everything else supports it.

---

# PART 4 — Every file explained

## 4.1 — `lib/` — 🟢 THE APP ITSELF (this is what matters)

### `lib/main.dart` 🟢 — the front door
The very first code that runs. It does four jobs:
1. `main()` — starts Firebase, then launches the app wrapped in `ProviderScope` (turns on Riverpod).
2. `MyApp` — sets the app title, applies your dark theme, and says "start at `AuthGate`."
3. `AuthGate` — the **traffic cop**: checks if you're logged in → shows the main app; if not → shows login.
4. `MainNavigator` — the 5-tab shell (Home, Search, Messages, Profile, Mentor Profile) with the bottom bar. It also holds the Settings pop-up (change password / verify email).

> This one file controls the *entire navigation* of your app.

### `lib/firebase_options.dart` ⚪→🟢 — Firebase address book
Auto-generated when Firebase was set up. It holds the keys/IDs that tell your app *which* Firebase
project to talk to. **You didn't hand-write it and shouldn't edit it**, but it's essential — without
it, login can't work. (So: auto-generated, but it does affect output because login depends on it.)

### `lib/theme/app_theme.dart` 🟢 — the paint palette
Defines every colour (TP red `#E11D2B`, dark background, card colour…) and the default look of
buttons, text fields, the app bar, and bottom nav. Every screen pulls colours from here, so the
whole app stays consistent. **Change a colour here → it changes everywhere.**

### `lib/models/` 🟢 — the *shapes* of your data
Plain descriptions of what each kind of thing contains. No visuals — just structure.
- `mentor.dart` — a Mentor has: name, specialization, rating, reviewCount, subjects, bio, availability, isOnline, sessionCount.
- `session.dart` — a Session has: title, mentorName, date, time, status, description.
- `message.dart` — a Message has: senderName, content, timestamp, isRead, unreadCount, isOnline.
- `user.dart` — a User has: uid, email, displayName, bio, course, etc.

Think of a model as a **blank form**. The data folder fills the form in.

### `lib/data/sample_data.dart` 🟢 — the fake content
The actual hardcoded mentors (Damian Tan…), sessions (Web Development Basics…), messages (Marcus
Lim…), and reviews. This is *prototype* data — it's not from a database. The screens read from
here to fill the cards.

> **Important honesty point for Q&A:** mentor/session/message content is sample data; only
> *authentication* (login) is connected to a real backend.

### `lib/services/auth_service.dart` 🟢 — all the login brains
The single place that talks to Firebase for login. Register, login, logout, password reset,
Google sign-in, guest sign-in, change password, resend verification, and the friendly-error
translator all live here. The screens never call Firebase directly — they call this file.
*(This is the most "impressive" file for the Q&A — see Part 6.)*

### `lib/providers/auth_provider.dart` 🟢 — the sharing glue (Riverpod)
Two small "providers" (shared boxes):
- `authServiceProvider` — hands the one `AuthService` to any screen that needs it.
- `authStateProvider` — a live feed of "are we logged in?" that `AuthGate` watches to switch screens automatically.

### `lib/screens/` 🟢 — the full pages
Each file is one complete page you can see:
- `login_screen.dart` — the login page (logo, Student ID + password, Google, guest).
- `register_screen.dart` — create-account page.
- `forgot_password_screen.dart` — send password-reset email page.
- `home_screen.dart` — the dashboard (welcome, recommended mentors, quick actions, sessions, messages).
- `search_screen.dart` — popular searches, subjects, mentor ratings.
- `messages_screen.dart` — chat list with mentor avatars on top.
- `profile_screen.dart` — your profile, sessions, premium, NETS card.
- `mentor_profile_screen.dart` — a mentor's detailed page (specialisations, availability, reviews).

### `lib/widgets/` 🟢 — reusable building blocks
Small parts used *inside* the screens, so you don't rewrite them:
- `mentor_card.dart` — the little mentor box (avatar, name, rating) used on Home & Search.
- `session_card.dart` — the session row (icon, title, date, "Pending" badge).
- `message_tile.dart` — one row in the messages list (avatar, name, preview, time, unread badge).

> **Screens = whole pages. Widgets = pieces reused inside pages.** That's the difference.

---

## 4.2 — `android/` — 🟡 the Android wrapper

Your Flutter code needs an Android "shell" to run on an Android phone. These files are that shell.
Most are auto-created; a few you (or the setup) edited.

### Files that matter here:
- `android/app/build.gradle.kts` 🟡 — Android build settings. Sets your **app ID**
  (`com.tpmentorship.tpmentorship`), Java version 17, and **enables the Firebase plugin**
  (`com.google.gms.google-services`). You'd edit this only for app-level changes.
- `android/app/google-services.json` 🟡 — your **Firebase configuration key for Android**.
  Downloaded from the Firebase console. Login won't work without it. *(Don't share it publicly.)*
- `android/app/src/main/AndroidManifest.xml` 🟡 — the app's "ID card" for Android: the **app
  name shown under the icon** (`tpmentorship`), the launcher icon, and that this app can be opened
  from the home screen. Change the display name here.
- `android/app/src/main/kotlin/.../MainActivity.kt` ⚪ — five lines that say "start Flutter."
  You almost never touch it. It's the bridge from Android into your Flutter code.
- `android/app/src/main/res/mipmap-*/ic_launcher.png` ⚪ — the **app icon images** in various sizes.
- `android/app/src/main/res/.../styles.xml` & `launch_background.xml` ⚪ — the splash/loading
  background shown for a split second while the app starts.

### Files you completely ignore here:
- `android/.gradle/`, `android/build/` ⚪ — build caches (auto, regenerated).
- `android/gradlew`, `gradlew.bat`, `gradle/wrapper/*` ⚪ — the build tool itself.
- `android/local.properties` ⚪ — paths to the SDK on *your* computer (auto).
- `android/*.gradle.kts` (root, settings) ⚪ — top-level build wiring (auto).
- `GeneratedPluginRegistrant.java` ⚪ — auto-generated list that hooks plugins into Android.
- `android/tpmentorship_android.iml` ⚪ — Android Studio module file (see .iml note below).

> **Q&A-safe summary:** "The `android/` folder is the Android wrapper around my Flutter app. The
> parts I care about are the app name in the manifest, the app ID and Firebase plugin in
> build.gradle, and the google-services.json that connects Firebase. The rest is auto-generated."

---

## 4.3 — `test/` — 🟢 automated tests

- `test/widget_test.dart` 🟢 — **you actually have a real, working test here.** It checks that
  `AuthService.friendlyError()` correctly turns Firebase error codes (like `wrong-password`) into
  friendly messages (like "Incorrect email or password."). Running `flutter test` runs it.

> Great Q&A flex: "I wrote unit tests for my error-handling function — it's a pure function so
> it's fast and reliable to test without needing Firebase or the UI."

---

## 4.4 — The root config files

### `pubspec.yaml` 🟡 — THE most important config file (know this one)
This is your app's **shopping list and settings sheet**. It lists every external package your app
uses. Yours are:
- `flutter_riverpod` — state management (sharing login status).
- `firebase_core` — base Firebase connection.
- `firebase_auth` — the login system.
- `google_sign_in` — the "Sign in with Google" button.
- `cupertino_icons` — extra icons.
- (dev) `flutter_test`, `flutter_lints` — testing + code-quality rules.

It also sets the app `name`, `version` (`1.0.0+1`), and `uses-material-design: true` (so Material
icons work). **When you "add a package," you add a line here**, then run `flutter pub get`.

### `pubspec.lock` ⚪ — exact versions, frozen
After `pubspec.yaml` says "I want firebase_auth ^4.10.1," this file records the *exact* version
that got installed (e.g. 4.10.1) plus every sub-package. Auto-managed. Don't edit. It exists so the
app builds identically on any machine.

### `analysis_options.yaml` 🟡 — the grammar checker rules
Turns on a set of recommended "lints" — automatic warnings that nudge you toward clean code (e.g.
"this variable is unused"). It's why VS Code underlines things. Doesn't change what the app *does*.

### `.gitignore` 🟡 — what Git should skip
If you use Git/GitHub, this lists files NOT to upload (like the giant `build/` and `.dart_tool/`
caches). Keeps the repo clean. Doesn't affect the running app.

### `.metadata` ⚪ — Flutter's bookkeeping
Records which Flutter version created the project so the upgrade tool works. The file literally says
"should not be manually edited." Leave it.

### `.flutter-plugins-dependencies` ⚪ — auto plugin index
A machine-generated list of which plugins (firebase, google_sign_in…) are wired into which
platforms. Flutter rewrites it automatically every time you run `flutter pub get`. Never edit.

### `tpmentorship.iml` ⚪ — Android Studio module file
`.iml` = "IntelliJ/Android Studio Module." It tells the *editor* how your project is organised:
"`lib/` is source code, `test/` is test code, ignore `build/`, `.dart_tool/`, `.idea/`." It's purely
for the editor — it has **zero effect on your app's behaviour or output.** If you deleted it,
Android Studio would just regenerate it.

### `README.md`, `CLAUDE.md`, `DEVELOPMENT_SUMMARY.md`, `STUDY_GUIDE.md` ⚪
Plain text documentation. `README` is the default template. The others are notes/docs. **None are
part of the running app** — they're for humans.

---

## 4.5 — Folders you can mentally delete

- `.dart_tool/` ⚪ — a big cache Flutter uses to build faster. Auto. Regenerated on demand.
- `build/` ⚪ — the **compiled app output** (the actual APK lives in here after building).
  Wiped and rebuilt every time. Never edit by hand.
- `.idea/` ⚪ — Android Studio's *personal* settings for this project (window layout, run buttons).
  Yours contains run configs and editor prefs. Doesn't affect the app.

> If someone deleted `.dart_tool/`, `build/`, and `.idea/`, your app would rebuild them from scratch
> and run identically. That's how you know they're not "your app."

---

# PART 5 — What actually happens when you tap the app icon

This is the "trace" — being able to tell this story is worth a lot in the Q&A:

1. Android reads **AndroidManifest.xml**, shows the **launcher icon**, and starts **MainActivity.kt**.
2. MainActivity says "run Flutter," which executes **`main()`** in `lib/main.dart`.
3. `main()` connects to Firebase (using `firebase_options.dart` + `google-services.json`) and starts the app with Riverpod turned on.
4. **`AuthGate`** asks the **`authStateProvider`** (in `auth_provider.dart`): "is anyone logged in?"
5. That provider listens to **`AuthService`** (in `auth_service.dart`), which listens to Firebase.
6. If logged out → show **`LoginScreen`**. If logged in → show **`MainNavigator`** (the 5 tabs).
7. Each tab/screen builds its UI from **widgets**, styled by **`app_theme.dart`**, filled with
   **`sample_data.dart`** content.
8. When you log in, Firebase tells `AuthService`, which updates the provider, which makes `AuthGate`
   automatically swap to the main app — **no manual page-switching code needed.**

> **One sentence:** "Android launches MainActivity → that starts `main.dart` → Firebase + Riverpod
> initialise → `AuthGate` checks login and shows either login or the tabbed app → screens draw
> themselves from widgets, the theme, and sample data."

---

# PART 6 — Q&A bank (practice out loud)

### Easy
- **"What is this app / what tech?"** → "A Flutter app written in Dart. It uses Firebase for login and Riverpod for state. Five screens behind a login gate."
- **"What's a widget?"** → "A building block of the UI. In Flutter everything is a widget — text, layout, the whole screen — nested into a tree."
- **"Stateless vs Stateful?"** → "Stateless just displays what it's given (`MentorCard`). Stateful can change over time (`LoginScreen`)."
- **"Where does your data come from?"** → "Mentor/session/message data is sample data in `sample_data.dart`. Only login is connected to a real backend, Firebase."

### Medium
- **"How do you manage state?"** → "Riverpod. `authStateProvider` streams the live login status, and `AuthGate` watches it to decide which screen to show. I use `watch` to rebuild on changes and `read` to call a function once."
- **"How does navigation work?"** → "The five tabs use an `IndexedStack`, which keeps all of them alive so their scroll position and state are preserved when I switch. The login/register/forgot screens swap using a simple state variable and callbacks."
- **"What does pubspec.yaml do?"** → "It's the list of external packages plus app settings like name and version. Adding a package means adding a line there and running `flutter pub get`."
- **"What's the difference between a screen and a widget?"** → "A screen is a full page; a widget is a reusable piece used inside pages, like my `MentorCard` and `SessionCard`."

### Hard (these impress)
- **"Why a temporary Firebase app when registering?"** (`auth_service.dart:27`) → "Creating an account normally signs you in automatically. I create it on a throwaway Firebase instance and delete it, so after registering the user is returned to the login screen to sign in deliberately."
- **"You catch an error but sometimes ignore it — why?"** (`auth_service.dart:60`) → "There's a known Firebase plugin bug that throws a type-cast error even when login succeeds. So I check whether `currentUser` is actually set — if it is, it worked and I ignore the false error; if not, it's a real failure and I rethrow it."
- **"`watch` vs `read` in Riverpod?"** → "`watch` rebuilds the widget when the value changes; I use it in `build`. `read` just grabs the value once to call a method; I use it in button handlers."
- **"What does `async`/`await` do?"** → "Firebase calls take time. `await` pauses that function until the result arrives, without freezing the whole app."
- **"How would you add a real database?"** → "Add Firestore, write a data service like my `AuthService`, and swap the `SampleData` calls for Firestore reads. My models already match, so the screens wouldn't change."
- **"Do you have any tests?"** → "Yes — a unit test for my `friendlyError` function in `test/widget_test.dart`."

### Curveballs — honest, calm answers
- **"Does the search bar filter?"** → "It's a styled UI scaffold in this prototype; live filtering is the next step."
- **"Why is some data hardcoded?"** → "It's a prototype focused on the auth system and UI; the data layer is structured to plug into a real database later."
- **"Explain this exact line."** → Read it slowly and describe it in plain English. You wrote it; you can narrate it.

---

# PART 7 — Live demo script (rehearse this exact path)

Narrate as you go — calm and clear beats fast.

1. **Open app** → lands on **Login**. *"The whole app is gated behind Firebase login."*
2. **Register** → tap "Register Here," make an account. *"Registration uses a temporary Firebase instance so it doesn't auto-log me in — it sends me back to log in manually and emails a verification link."*
3. **Log in.** *"Firebase confirms, the auth stream updates, and the app switches to the main screens automatically."*
4. **Home** → scroll through mentors, quick actions, sessions, messages. *"All five tabs stay alive via an IndexedStack, so state is preserved."*
5. **Visit each tab** → Search, Messages, Profile, Mentor Profile. Show a **back arrow** working.
6. **Profile → Settings** → show **Change Password** and **Resend Verification** (your account-management features).
7. **Logout** → *"This clears the Firebase session and the AuthGate drops me back to login."*
8. *(Optional)* show **Guest** and **Google** sign-in.

**Safety checklist before you present:**
- Have a **known working email + password** ready (don't type a fresh one live).
- Make sure the device/emulator has **internet** (Firebase needs it).
- Do **one full practice run** right before.
- If anything breaks: state what *should* happen and move on. Composure is graded; perfection isn't.

---

## The one paragraph to re-read at the door

> "TP Mentorship is a Flutter/Dart app. Everything I see lives in the `lib/` folder; the rest of
> the project is the Android wrapper and auto-generated build files. `main.dart` starts Firebase
> and Riverpod and hands control to `AuthGate`, which watches a Firebase login stream and shows
> either the login flow or the five-tab main app. All login logic is in `AuthService`, shared to
> screens through Riverpod providers. Screens are full pages built from reusable widgets, styled by
> one theme file, and filled with sample data. Only authentication is live. I used an IndexedStack
> to preserve tab state, a temporary Firebase app to control the post-registration flow, and a
> single error-mapping function for clean messages — which I also unit-tested."

If you can say that and then expand any sentence on request, you're ready.
