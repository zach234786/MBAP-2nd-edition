# TP Mentorship — Part 2 Presentation Prep Guide

> **Purpose:** Everything you need to ace Part 2 — Program Code (30%) + Presentation (10%, split into Live Demo 5% and Q&A 5%). Read this top to bottom, then re-read the Q&A section (at the end) until you can answer without thinking. The rubric rewards you for **explaining reasoning behind implementation choices** — so this guide focuses on the *why*, not just the *what*.

---

## 0. The 30-Second Elevator Pitch

> "TP Mentorship is a Flutter app that connects Temasek Poly students with mentors. For Part 2 I built the full UI, navigation, and a complete Firebase authentication system. It uses **Riverpod** for state management, has **5+ screens** with a bottom navigation bar, **form validation** on every auth screen, and goes beyond the basics with **three account-management features** (change password, email verification, delete account) and **two extra sign-in methods** (Google and GitHub). All the Firebase logic lives in one service class so the UI stays clean."

Memorize this. It hits every rubric keyword: Riverpod, screens, navigation, form validation, Firebase auth, account management, extra auth methods, separation of concerns.

---

## 1. What the Rubric Actually Grades (straight from the spec)

Part 2 is worth **40%** total: Program Code (30%) + Presentation (10%). Here's the exact breakdown and where your app hits each criterion:

| Criterion | Weight | What "Excellent" requires | Your evidence |
|---|---|---|---|
| **Implemented screens** | 5% | 5 proposed screens implemented; each worth 2 marks (1 for matching Part 1 design, 1 for whitespace/graphics/alignment) | Home, Search, Messages, Profile, Mentor Profile (+ 4 auth screens) |
| **Navigation** | 2.5% | Appropriate structures taught in class (e.g. BottomNavigationBar); logical, smooth, bug-free flow | `BottomNavigationBar` + `IndexedStack` in `MainNavigator`; `Navigator.push` for Change Password |
| **Widgets** | 2.5% | ALL of: Form, TextFormField, ElevatedButton, Row, Column, ListView/GridView — used consistently | Forms on all 4 auth screens; ListView (Home, Messages), GridView (Search); Row/Column everywhere |
| **Form validation** | 2.5% | Input validations on ALL input fields + **appropriate keyboard types** on all fields | Validators on every field; `keyboardType: TextInputType.emailAddress` on email fields |
| **Feedback** | 2.5% | Clear, consistent feedback: SnackBars, error messages, success states | `friendlyError()` + SnackBars everywhere; success SnackBar on register/password change |
| **Program Code** | 2.5% | Well-structured folders (screens, providers, services), consistent naming, comments, Riverpod used correctly with clear UI/logic separation | Your `lib/` structure is literally the rubric's example |
| **User Authentication** | **12.5%** | Basic auth (register, login, logout, forgot password) with customised settings, no bugs + **≥2 extra account-management features** + **≥2 extra auth methods** not taught in class | Basic 4 ✔ + change password, email verification, delete account (3 features) + Google, GitHub (2 methods) |
| **Live Demo** | 5% | Smooth, complete, all key features, logical well-paced flow, no major issues | Follow the demo script in Section 7 |
| **Q&A** | 5% | Answers all technical questions confidently **including reasoning behind implementation choices**; within time limit | Section 10 of this guide |

**Notice:** Authentication alone is 12.5% — over a third of the code marks (30%). Your 3+2 extras put you squarely in the "Excellent" column (it only asks for 2+2). Spend the most demo/Q&A energy there.

### Spec warnings you must respect

- **AI-use policy:** AI tools are allowed for debugging/consultation/learning, but external resources including AI-generated content **must be declared and you must be able to explain the code**. "Students who are unable to explain their code… may receive significant mark deductions, regardless of whether the application is functional." → This guide exists so you can explain *every* line. Don't skip the Q&A section.
- **Submission (Week 12 — Mon 6 Jul, 9 AM):**
  - `Part2_YourName_StudentID_YourClass.zip` (entire project folder)
  - `Part2_YourName_StudentID_YourClass.docx` — Word doc with **hi-fi design screenshots from Part 1 + screenshots of the implemented app**
  - Late = −10 absolute marks within 1 day, −20 up to 2 days, 0 after that. Keep a backup copy.
- CRUD-related screens do **not** need to be functional in Part 2 (that's Part 3) — say this confidently when asked about stubbed buttons.

---

## 2. Foundations — the concepts behind everything

If you're shaky on basics, this is your mental model. Everything else in the guide builds on these five ideas.

### Flutter and Dart
- **Dart** is the *programming language* (the `.dart` files). It's the words.
- **Flutter** is the *toolkit* that turns Dart code into an actual app with buttons and screens. You write Dart → Flutter draws it.

### "Everything is a Widget"
Every single thing on screen is a widget: a piece of text, a button, spacing, the whole screen. Widgets nest inside other widgets like Russian dolls. That nested pile is the **widget tree**, and it *is* your UI. Every widget has a **`build()`** function that returns "here's what I look like." When something changes (you type, you tap), the relevant part re-runs `build()` and redraws. That's the whole loop.

### The five concepts behind your code
1. **Stateless vs Stateful widget** — *Stateless* shows what it's given, never changes on its own (`MentorCard`). *Stateful* can change over time (`LoginScreen` reacts to typing and taps). Memory hook: *"if it must remember or change something, it's Stateful."*
2. **`setState()`** — in a stateful widget, this means "something changed, redraw me." Without it, a changed value won't show up on screen.
3. **State management (Riverpod)** — `setState` only updates one widget. But "am I logged in?" must be known by the *whole* app. Riverpod stores that in a shared box called a *provider* that any screen can read.
4. **async / await / Future** — talking to Firebase is slow (it uses the internet). `Future` = "an answer that arrives later." `await` = "wait here for it." `async` = "this function is allowed to wait." That's why login is `Future<void> _login() async`.
5. **Models vs Data** — a *model* describes the *shape* of a thing (a Mentor has a name, rating, subjects…). The *data* is the actual filled-in examples (the sample mentors).

---

## 3. Project Architecture (the "big picture" answer)

### The traffic-light system

Your project has 40+ files but you only wrote a handful. Mark every file mentally:

- 🟢 **GREEN — YOUR app.** You wrote it; it controls what's on screen. Everything in `lib/` (except `firebase_options.dart`) + `test/`.
- 🟡 **YELLOW — Settings/config.** Occasionally edited: `pubspec.yaml`, `android/app/build.gradle.kts`, `AndroidManifest.xml`, `google-services.json`, `.gitignore`, `analysis_options.yaml`.
- ⚪ **WHITE — Auto-generated plumbing.** Tools create and manage these: `build/`, `.dart_tool/`, `.idea/`, `pubspec.lock`, `.metadata`, `.iml` files. (Full map in Section 6.)

**Short version:** almost everything you see on screen comes from the 🟢 files in `lib/`. The rest makes the app *build and run* but doesn't decide what screens look like. If someone deleted `build/`, `.dart_tool/`, and `.idea/`, the app would rebuild them and run identically.

### The `lib/` structure

If the lecturer asks **"Walk me through how your app is structured,"** say this:

```
lib/
├── main.dart              → App entry point + navigation shell + AuthGate
├── firebase_options.dart  → Auto-generated Firebase config (per platform)
├── providers/
│   └── auth_provider.dart  → Riverpod providers (the "wiring")
├── services/
│   └── auth_service.dart   → ALL Firebase Auth logic (the "brain")
├── screens/                → Full-page UI (9 screens)
├── widgets/                → Reusable UI pieces (cards, tiles)
├── models/                 → Plain data classes (Mentor, Message, Session)
├── data/
│   └── sample_data.dart    → Hardcoded demo data (no backend yet in Part 2)
├── utils/
│   ├── validators.dart     → Shared form validators (email, password)
│   └── snackbar_helper.dart→ Shared SnackBar feedback helper
└── theme/
    └── app_theme.dart      → Centralised colours + styling
```

**The one-sentence architecture principle to repeat:**
> "I separated **UI** (screens/widgets), **logic** (services), and **state wiring** (providers). The UI never calls Firebase directly — it always goes through `AuthService` via a Riverpod provider. This is the separation of concerns the rubric asks for."

This layering is your single strongest talking point. Bring it up early.

**Screens vs widgets:** Screens = whole pages. Widgets = pieces reused *inside* pages (`MentorCard` is used on both Home and Search). That's the difference.

---

## 4. The Data Flow (memorize both traces)

### Trace 1 — What happens when you tap the app icon

1. Android reads **AndroidManifest.xml**, shows the **launcher icon**, and starts **MainActivity.kt**.
2. MainActivity says "run Flutter," which executes **`main()`** in `lib/main.dart`.
3. `main()` connects to Firebase (using `firebase_options.dart` + `google-services.json`) and starts the app with Riverpod turned on (`ProviderScope`).
4. **`AuthGate`** asks the **`authStateProvider`**: "is anyone logged in?"
5. That provider listens to **`AuthService`**, which listens to Firebase.
6. Logged out → **login flow**. Logged in → **`MainNavigator`** (the 5 tabs).
7. Each screen builds its UI from **widgets**, styled by **`app_theme.dart`**, filled with **`sample_data.dart`** content.

> **One sentence:** "Android launches MainActivity → that starts `main.dart` → Firebase + Riverpod initialise → `AuthGate` checks login and shows either login or the tabbed app → screens draw themselves from widgets, the theme, and sample data."

### Trace 2 — What happens when the user taps "Login"

Being able to trace this is what separates an A from a B:

```
LoginScreen (_login method)
    │  reads the provider
    ▼
ref.read(authServiceProvider)          ← Riverpod hands us the AuthService
    │  calls
    ▼
AuthService.login(email, password)     ← wraps FirebaseAuth.signInWithEmailAndPassword
    │  Firebase updates its auth state
    ▼
authStateChanges stream fires          ← a Stream<User?> from Firebase
    │  Riverpod's authStateProvider is watching it
    ▼
AuthGate rebuilds (ref.watch)          ← sees user != null
    │  swaps the screen
    ▼
MainNavigator shows (the 5-tab app)
```

**Key insight to state out loud:** "I never manually navigate to the home screen after login. Firebase's `authStateChanges` stream fires automatically, `AuthGate` is listening, and it swaps screens for me. This is *reactive* — the UI reflects the true auth state at all times, even if the session expires."

---

## 5. File-by-File Deep Dive

### 5.1 `main.dart` — the entry point and navigation brain

**`_navigatorKey` (line 24):** A `GlobalKey<NavigatorState>` given to `MaterialApp`. **Why?** When the user signs out, `AuthGate` swaps the home widget — but any screen pushed with `Navigator.push` (like Change Password) would stay on top of it. `AuthGate` uses this key to pop back to the first route on sign-out, so a logged-out user can never be left stranded on an authed screen.

**`main()` function (lines 26–34):**
```dart
WidgetsFlutterBinding.ensureInitialized();   // Flutter must be ready before native calls
await Firebase.initializeApp(...);            // connect to Firebase project
runApp(const ProviderScope(child: MyApp()));  // ProviderScope = turn on Riverpod
```
- **Why `ensureInitialized()`?** Because `Firebase.initializeApp` talks to native platform code (method channels). You must confirm the Flutter engine binding is ready first, or it crashes.
- **Why `await`?** The app cannot function until Firebase is connected, so we block until it's done.
- **What is `ProviderScope`?** It's the Riverpod root. Every provider lives inside it. Without it, `ref.watch`/`ref.read` would throw. It must wrap the *entire* app, so it's at the very top.

**`MyApp` (lines 36–52):** A `StatelessWidget` returning `MaterialApp`. Points to:
- `theme: AppTheme.darkTheme` — our centralized theme.
- `home: const AuthGate()` — the first thing shown.
- `debugShowCheckedModeBanner: false` — hides the "debug" ribbon for a clean demo.

**`NoStretchScrollBehavior` (lines 55–73):** Custom scroll behavior that removes the bouncy overscroll glow. *Cosmetic polish.* If asked: "I overrode the default `MaterialScrollBehavior` to use `ClampingScrollPhysics` so scrolling stops firmly at the edges instead of stretching — it looks cleaner on web."

**`AuthGate` (lines 78–118) — THE most important widget in the app:**
```dart
final authState = ref.watch(authStateProvider);
return authState.when(
  data: (user) => user != null ? MainNavigator() : AuthFlow(),
  loading: () => CircularProgressIndicator(...),
  error: (err, stack) => Text('Something went wrong: $err'),
);
```
- It's a `ConsumerWidget` (Riverpod's version of StatelessWidget that can read providers).
- `ref.watch(authStateProvider)` returns an `AsyncValue<User?>` — because the auth state comes from a *stream*, it has three states: `data`, `loading`, `error`.
- `.when(...)` forces me to handle all three. **This is good practice** — I show a spinner while Firebase checks the cached session, an error screen if something breaks, and the right screen once I know the login state.
- **Why a gate?** So there is ONE single source of truth for "is the user logged in?" No screen has to check auth itself.
- **`ref.listen` (lines 86–90):** Besides *watching* the auth state to pick a screen, `AuthGate` also *listens* for the moment the user becomes null and pops any pushed routes via `_navigatorKey`. **`watch` rebuilds UI from state; `listen` runs a side effect when state changes** — a nice Riverpod distinction to mention.

**`AuthFlow` (lines 121–151):** A `StatefulWidget` holding a `String _screen` variable ('login' / 'register' / 'forgot_password'). It swaps between the three auth screens using `setState`. The screens call callbacks like `onGoToRegister` to flip the string.
- **Why not use `Navigator.push` here?** Because these three screens are a self-contained flow *before* login. Using a simple state variable keeps them grouped without polluting the navigation stack. (Be ready to defend this — see Q&A Q7.)

**`MainNavigator` (lines 154–413):** The logged-in shell.
- It's a `ConsumerStatefulWidget` because it needs both **state** (`_selectedIndex` for the current tab, `_selectedMentor` for the tapped mentor) AND **provider access** (to call logout/delete).
- **`IndexedStack` (line 365):** Holds all 5 screens at once, showing only the selected index.
  - **CRITICAL to know:** *Why `IndexedStack` instead of just swapping widgets?* Because `IndexedStack` keeps all screens **alive** in memory. If you scroll down on Home, switch to Search, and come back, Home is still scrolled where you left it. If I used a plain conditional, each screen would be rebuilt from scratch and lose its state. (See Q&A Q2 — this is a favourite.)
- **`BottomNavigationBar` (line 400):** 5 tabs (Home, Search, Messages, Profile, Mentor Profile). `currentIndex` is bound to `_selectedIndex`, `onTap` calls `_onNavItemTapped` which does `setState`.
- **Callbacks passed to screens (lines 367–397):** Each screen gets functions like `onNavigateToSearch: () => setState(() => _selectedIndex = 1)`. This is how a button on the Home screen can switch tabs. **Why callbacks?** So screens don't need to know about the navigation bar — they just say "a mentor was tapped" and `MainNavigator` decides what to do. This keeps screens reusable and decoupled.
- **`_openMentorProfile()` (lines 175–181):** Mentor taps pass the actual `Mentor` object (`ValueChanged<Mentor>` callbacks, not plain `VoidCallback`). This method remembers **which mentor** was tapped (`_selectedMentor`) and **which tab the user came from** (`_mentorProfileReturnIndex`), then switches to tab 4. So the Mentor Profile shows the mentor you actually tapped, and its back button returns to Home or Search — whichever you came from. *(Mention this as a fix you made after reviewing your own code — graders love that.)*

**`_openSettings()` (lines 238–358):** Opens a `showModalBottomSheet` with the 3 account-management options.
- Uses `StatefulBuilder` so the sheet can rebuild itself independently (to refresh the "Email Verified" row).
- **The clever bit (lines 253–260):** It shows the sheet *immediately*, then calls `authService.reloadUser()` in the background. When fresh data arrives, `setSheetState(() {})` rebuilds just the sheet. **Why?** `emailVerified` is cached locally by Firebase. If the user verified on another device, the app wouldn't know until it reloads. I reload in the background so there's no blocking "dead tap" — the sheet opens instantly and updates a moment later.
- Gates each feature on `authService.isEmailPasswordAccount` — a Google/GitHub user has no password, so "Change Password" would fail. Instead we show a friendly SnackBar.
- When Change Password pushes `ForgotPasswordScreen`, it passes `backLabel: 'Back'` — because in that context tapping the link returns to Change Password, not to the login screen, so the default 'Back to Login' label would lie.

**`_deleteAccount()` (lines 198–234):** Shows a confirmation `AlertDialog` (destructive action → always confirm), then calls `deleteAccount()`. On success, Firebase signs the user out → `authStateChanges` fires → `AuthGate` returns to login automatically. No manual navigation needed.

**`_logout()` (lines 190–194):** Calls `authService.logout()`. Uses `.catchError` to show a SnackBar if it fails.

**`_showSnackBar()` (lines 183–188):** Guards with `if (!mounted) return;` (some callers await first — the State could be disposed by the time the call returns), then delegates to the shared `showAppSnackBar` helper in `lib/utils/snackbar_helper.dart` so feedback looks identical on every screen.

---

### 5.2 `services/auth_service.dart` — the brain (EXPECT THE MOST QUESTIONS HERE)

This class wraps every Firebase Auth call. The UI only ever calls these methods.

**`authStateChanges` getter (line 13):** `Stream<User?>` — the reactive backbone. Emits a `User` on login, `null` on logout. Riverpod watches this.

**`currentUser` getter (line 16):** The synchronous "who's logged in right now" — returns `User?`.

**`_ignoreKnownBugIf()` (lines 24–36) + `_isKnownBugError()` (lines 38–39) — the centralised Pigeon-bug handling:**
```dart
Future<void> _ignoreKnownBugIf({
  required Future<void> Function() action,
  required bool Function() succeeded,
}) async {
  try { await action(); } catch (e) { if (!succeeded()) rethrow; }
}
```
- There's a known `firebase_auth` bug where the native bridge ("Pigeon") throws a type-cast error **even when the operation succeeded**. Instead of copy-pasting a try/catch into every method, ONE helper runs the operation and swallows the error only when a `succeeded` check confirms it actually worked (e.g. "am I signed in now?"). Login, delete, Google and GitHub sign-in all call it with their own success check.
- `_isKnownBugError()` recognises the bug by its error *shape* — used by `changePassword`, whose success can't be confirmed by checking `currentUser`.
- **Why a helper?** If Firebase fixes the bug, I update one place instead of six. *(This was a refactor after reviewing my own code — a great "good programming practices" talking point.)*

**`register()` (lines 47–72) — the trickiest method, KNOW IT COLD:**
```dart
final tempApp = await Firebase.initializeApp(name: 'registrationTemp_...', options: ...);
final tempAuth = FirebaseAuth.instanceFor(app: tempApp);
await tempAuth.createUserWithEmailAndPassword(...);
await credential.user?.sendEmailVerification();
// ... finally: await tempApp.delete();
```
- **THE key question: "Why create a whole separate Firebase app just to register?"**
  - Answer: `createUserWithEmailAndPassword` **automatically signs the new user in** on the default Firebase instance. That would drop them straight into the app. I want them to register, then go *back to the login screen* and log in manually (which is the expected UX and also confirms they know their password). By creating the account on a **temporary secondary Firebase app**, the main app's auth state is never touched. Then I delete the temp app in a `finally` block so it's always cleaned up.
- **Why `sendEmailVerification()` right after?** So the verification email goes out the moment they register.
- **The try/catch around create (lines 60–68):** The known Pigeon bug can throw even when the account WAS created. This one is handled inline (not with `_ignoreKnownBugIf`) because the recovery path also has to re-send the verification email that the try block never reached. If `tempAuth.currentUser == null`, it's a real failure (rethrow). (See Q&A Q9.)

**`login()` (lines 78–90):** Wraps `signInWithEmailAndPassword` in `_ignoreKnownBugIf` with `succeeded: () => _auth.currentUser != null` — if it throws but we ARE signed in, it worked.

**`logout()` (lines 92–104):**
```dart
if (!kIsWeb) { try { await GoogleSignIn().signOut(); } catch (_) {} }
await _auth.signOut();
```
- **Why the `kIsWeb` check?** The `google_sign_in` package is only wired up for mobile. On web, calling `GoogleSignIn().signOut()` throws (no web client configured), which would *block* the Firebase sign-out below it. So on web I skip it entirely and just sign out of Firebase.
- **Why the `try/catch`?** Even on mobile, if the user never used Google sign-in, this is best-effort — I never want it to stop the actual Firebase logout.

**`sendPasswordResetEmail()` (lines 107–109):** One-liner wrapping Firebase's built-in. Firebase sends the reset email; we don't build the reset UI ourselves.

**`sendEmailVerification()` (lines 112–116) — Account Management Feature #1:** Resends the verification email to the current user.

**`isEmailVerified` getter (line 119):** `_auth.currentUser?.emailVerified ?? false`. Note: this is **cached** — hence `reloadUser()` exists.

**`reloadUser()` (lines 124–126):** `await _auth.currentUser?.reload()` — pulls fresh user data from Firebase servers so `emailVerified` reflects reality.

**`isEmailPasswordAccount` getter (lines 133–136):**
```dart
_auth.currentUser?.providerData.any((info) => info.providerId == 'password') ?? false;
```
- **Why does this exist?** Change-password and resend-verification only make sense for email/password accounts. A Google or GitHub user has no password to reauthenticate with. I check the user's `providerData` list for the `'password'` provider ID. This is more robust than checking `email != null` — because Google users *have* an email too, but still can't change a Firebase password. (This was a code-review fix — mention it as evidence of careful thinking.)

**`changePassword()` (lines 140–174) — Account Management Feature #2:**
- Requires **reauthentication** first: Firebase makes you re-enter the old password before changing it (security — proves it's really you, not someone who grabbed an unlocked phone).
- `EmailAuthProvider.credential(email, oldPassword)` → `user.reauthenticateWithCredential(...)` → then `user.updatePassword(newPassword)`.
- Uses `_isKnownBugError` for the Pigeon bug (can't verify a password change via `currentUser`, so it matches the error shape instead). The UI layer does NOT know about the bug — the screen just calls the service and shows `friendlyError` on failure.

**`deleteAccount()` (lines 177–189) — Account Management Feature #3:**
- `user.delete()`. Firebase requires a **recent login**; if the session is old it throws `requires-recent-login`.
- Uses `_ignoreKnownBugIf` with `succeeded: () => _auth.currentUser == null` — if the account is actually gone, the delete worked; only rethrow if the user is still there (a real failure).

**`signInWithGoogle()` (lines 191–216) — Extra Auth Method #1:**
```dart
if (kIsWeb) {
  await _auth.signInWithPopup(GoogleAuthProvider());   // web path
} else {
  final googleUser = await GoogleSignIn().signIn();     // mobile path
  final googleAuth = await googleUser.authentication;
  final credential = GoogleAuthProvider.credential(accessToken:..., idToken:...);
  await _auth.signInWithCredential(credential);
}
```
- **Why two different paths?** On **web**, the `google_sign_in` package's `signIn()` method isn't supported the same way (it needs a rendered Google button and has no access token flow), so Firebase's own `signInWithPopup` handles it in the browser. On **mobile**, we use the native `google_sign_in` flow to get tokens and hand them to Firebase. Same end result, platform-appropriate method. `kIsWeb` is a compile-time constant Flutter provides.

**`signInWithGitHub()` (lines 218–229) — Extra Auth Method #2:**
```dart
if (kIsWeb) { await _auth.signInWithPopup(GithubAuthProvider()); }
else { await _auth.signInWithProvider(GithubAuthProvider()); }
```
- Web opens a popup; mobile/desktop opens a native OAuth web flow. GitHub is configured as an OAuth provider in the Firebase Console with a callback URL pointing at our Firebase auth handler.

**`friendlyError()` (lines 231–265) — static helper:**
- Takes any error, and if it's a `FirebaseAuthException`, maps the raw `error.code` (like `'wrong-password'`) to a human message ("Incorrect email or password."). Every screen calls this in its catch block.
- **Why `static`?** It doesn't need any instance state — it's a pure function. Making it static means screens can call `AuthService.friendlyError(e)` without needing the provider.
- **Why does this matter for the rubric?** "Feedback" is a graded criterion (2.5%). Turning cryptic Firebase codes into friendly messages is exactly the clear feedback they want.

---

### 5.3 `providers/auth_provider.dart` — the Riverpod wiring

Only two providers, but know them both:

```dart
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});
```

- **`authServiceProvider`** — a plain `Provider`. Creates ONE shared `AuthService` for the whole app (a singleton). Any widget does `ref.read(authServiceProvider)` to get it. **Why one shared instance?** So everyone talks to the same auth logic; no duplicated FirebaseAuth wrappers.
- **`authStateProvider`** — a `StreamProvider`. It watches `authServiceProvider`, then exposes the `authStateChanges` stream as an `AsyncValue<User?>`. `AuthGate` watches THIS one.
- **`ref.watch` vs `ref.read`** (guaranteed question — see Q1): `watch` subscribes and rebuilds on change; `read` grabs the value once without subscribing. I `watch` in `AuthGate` (I want rebuilds when auth changes) and `read` in button handlers (I just want to call a method once).

---

### 5.4 The Auth Screens (`login`, `register`, `forgot_password`, `change_password`)

All four follow the **same pattern** — learn it once:

1. **`ConsumerStatefulWidget`** — needs state (controllers, loading flag) + provider access.
2. **`GlobalKey<FormState> _formKey`** — the handle to the `Form`. Calling `_formKey.currentState!.validate()` runs every field's `validator` at once.
3. **`TextEditingController`s** — one per input, disposed in `dispose()` to prevent memory leaks (**know this — Q5**).
4. **`bool _isLoading`** — disables the button and shows a spinner during async calls, so the user can't double-submit.
5. **A `_showSnackBar` helper** — with `if (!mounted) return;` guard (**Q6**), delegating to the shared `showAppSnackBar` in `lib/utils/snackbar_helper.dart`.
6. **The submit method** — validate → set loading → try/await service call → catch → `friendlyError` → finally reset loading.

**Shared validators (`lib/utils/validators.dart`):** email and password rules are defined ONCE in a `Validators` class (`Validators.email`, `Validators.password`) and reused by every auth screen. **Why?** If the password rule ever changes (say min 6 → min 8), it changes in one place and every form stays consistent. Cross-field checks (confirm-password matches, new ≠ current) stay inline because they need the screen's other controller.

**Login-specific (`login_screen.dart`):**
- Two `TextFormField`s (email, password) with validators.
- Email validator (`Validators.email`): non-empty + contains `@` — with `field: 'Student ID'` to customise the message.
- Password validator (`Validators.password`): non-empty + length ≥ 6.
- `keyboardType: TextInputType.emailAddress` on the email field → shows the @ keyboard on mobile (graded under form validation — the rubric explicitly asks for appropriate keyboard types).
- `obscureText: _obscurePassword` with an eye-icon toggle to show/hide.
- Google + GitHub `OutlinedButton.icon` buttons calling the service.
- `_isLoading ? null : _login` on `onPressed` — passing `null` disables the button.

**Register-specific:** 4 fields (name, email, password, confirm). The confirm-password validator compares against `_passwordController.text` — cross-field validation. On success it does NOT log in (see the temp-app trick) — it shows a success SnackBar and calls `onGoToLogin()`.

**Forgot-password-specific:** 1 email field → `sendPasswordResetEmail`. Firebase emails the link.

**Change-password-specific:** 3 fields (current, new, confirm). Extra validators: new must be ≥6 AND different from current; confirm must match new. Also double-checks `isEmailPasswordAccount` before running. The screen knows nothing about the Firebase Pigeon bug — `AuthService` filters that out, so any error reaching the screen is real.

---

### 5.5 Non-auth screens (Home, Search, Messages, Profile, Mentor Profile)

These are **presentation screens** using hardcoded `SampleData` (Part 2 doesn't require a live backend — CRUD comes in Part 3). Know these facts:

- **`home_screen.dart`** — `StatelessWidget`. Uses a **horizontal `ListView.builder`** (line 153) for mentors, plus `_QuickActionCard` and `_sectionHeader` helper widgets. This is your **home screen** for the widget-tree question.
- **`search_screen.dart`** — `StatefulWidget`. Uses a **`GridView.builder`** (line 172) for the subject cards. Has a `TextField` search bar (not yet functional — honest about this). Uses Dart **records** like `('C++', 'COMT')` for the tag data.
- **`messages_screen.dart`** — `StatefulWidget`. **`ListView.builder`** of `MessageTile`s. Tapping shows a SnackBar.
- **`profile_screen.dart`** — `StatelessWidget`. Shows profile card, stats, 3 action buttons (Edit / Settings / Logout), sessions, a premium card, and the **NETS QR payment** placeholder (part of the proposal).
- **`mentor_profile_screen.dart`** — `StatelessWidget`. Takes a **required `Mentor` object** and shows THAT mentor's name, specialization, rating, review count, session count and online status. Mentor taps on Home/Search pass the tapped mentor up via `ValueChanged<Mentor>` callbacks, so tapping "Jovan Tan" shows Jovan Tan (not a hardcoded profile). Specialisations/about/availability/reviews below the card are still sample content (Part 3 binds them to Firestore).

**Honesty note:** The search bar and some buttons show "coming soon" SnackBars. If asked, say: "Part 2 is about UI, navigation, and auth. The CRUD-related interactions are intentionally stubbed — the spec explicitly says CRUD screens don't need to be functional yet; that's Part 3."

---

### 5.6 Widgets (`MentorCard`, `MessageTile`, `SessionCard`)

Reusable `StatelessWidget`s that each take a model + optional `onTap` callback.
- **`MentorCard`** — avatar with online dot, name, specialization, star rating.
- **`MessageTile`** — has a `_formatTimestamp` helper that shows "3:45 PM" for today, "Yesterday", weekday name, or date. Good example of real logic in a widget.
- **`SessionCard`** — has `_sessionIcon()` (picks an icon from the title keywords) and `_formattedDate()`. Another example of logic.

**Why separate widget files?** Reusability + readability. `MentorCard` is used on both Home and Search — defined once, used everywhere. This is the "well-structured project" the rubric rewards.

---

### 5.7 Models (`Mentor`, `Message`, `Session`)

Plain Dart classes with `final` fields and a constructor. Immutable data holders. No logic. **Every field is actually rendered somewhere** — unused fields (imageUrl, mentorImage, isRead) were removed after a code review; Part 3 re-adds fields as Firestore needs them.
- `mentor.dart` — id, name, specialization, rating, reviewCount, isOnline, sessionCount.
- `message.dart` — id, senderName, content, timestamp, unreadCount, isOnline.
- `session.dart` — id, title, mentorName, date, time, status.

Think of a model as a **blank form**; `sample_data.dart` fills the form in. In Part 3 these will get `fromFirestore`/`toMap` methods, but for Part 2 they just structure the sample data.

### 5.8 `theme/app_theme.dart`

All colours (TP red `#E11D2B`, dark backgrounds) and component themes (buttons, inputs, bottom nav) defined once as `static const`. **Why centralize?** Change the brand colour in one place and the whole app updates. Consistency + maintainability.

### 5.9 `data/sample_data.dart`

Static methods returning hardcoded `List<Mentor>`, `List<Message>`, etc. Stands in for a database in Part 2. **Honesty point for Q&A:** mentor/session/message content is sample data; only *authentication* is connected to a real backend.

### 5.10 `test/widget_test.dart` — your unit tests (a genuine flex)

You have **real, working unit tests**: they check that `AuthService.friendlyError()` correctly turns Firebase error codes (`wrong-password`, `email-already-in-use`, `weak-password`, unknown) into the friendly messages shown to users. Run with `flutter test`.

> **Q&A flex:** "I wrote unit tests for my error-handling function — it's a pure static function, so it's fast and reliable to test without needing Firebase or the UI."

### 5.11 The `android/` folder — the Android wrapper (know just this much)

Your Flutter code needs an Android "shell" to run on a phone. The parts that matter:

- `android/app/build.gradle.kts` 🟡 — Android build settings: your **app ID** (`com.tpmentorship.tpmentorship`) and **enables the Firebase plugin** (`com.google.gms.google-services`).
- `android/app/google-services.json` 🟡 — the **Firebase configuration key for Android**, downloaded from the Firebase console. Login won't work without it. *(Don't share it publicly.)*
- `android/app/src/main/AndroidManifest.xml` 🟡 — the app's "ID card": the app name shown under the icon, the launcher icon, launch permissions.
- `MainActivity.kt` ⚪ — five lines that say "start Flutter." The bridge from Android into your Flutter code.
- `mipmap-*/ic_launcher.png` ⚪ — app icon images. `styles.xml`/`launch_background.xml` ⚪ — the splash background shown while the app starts.

> **Q&A-safe summary:** "The `android/` folder is the Android wrapper around my Flutter app. The parts I care about are the app name in the manifest, the app ID and Firebase plugin in build.gradle, and the google-services.json that connects Firebase. The rest is auto-generated."

---

## 6. Which Files Did You Actually Write? (Auto-generated vs Hand-written)

If a grader points at a random file and asks "did you write this?", here's the honest map. Files are grouped by the **single command/tool that created them together**.

### Group A — `flutter create` (project scaffolding, auto-generated ONCE at project birth)

Run once when the project was created; Flutter generated all of these together:

| File | Notes |
|---|---|
| `.gitignore` | Standard Flutter ignore list |
| `.metadata` | Tracks the Flutter version/channel the project was created with — never edit |
| `README.md` | Default stub |
| `analysis_options.yaml` | Linter config (points at `flutter_lints`) |
| `pubspec.yaml` | Generated skeleton, **then hand-edited** (see Group F) |
| `android/` — everything | `build.gradle.kts`, `settings.gradle.kts`, `gradle.properties`, `gradle/wrapper/`, `gradlew`, `gradlew.bat`, `MainActivity.kt`, both `styles.xml`, `launch_background.xml`, `ic_launcher.png` (all densities), all three `AndroidManifest.xml` files |
| `web/index.html`, `web/manifest.json` | Generated when web support was added (`flutter create . --platforms=web`) |
| `lib/main.dart` | Generated as the counter demo, **then completely rewritten by me** |
| `test/widget_test.dart` | Generated as the counter demo test, **then completely rewritten by me** (see Group F) |

> **Fine print:** `android/app/build.gradle.kts` and `android/app/src/main/AndroidManifest.xml` started auto-generated but were **hand-edited** to wire up Firebase (google-services plugin) — worth mentioning if asked about the Android setup.

### Group B — `flutterfire configure` (Firebase CLI, one command)

| File | Notes |
|---|---|
| `lib/firebase_options.dart` | Per-platform Firebase keys/config. **Never hand-edit** — re-run the command instead |
| `firebase.json` | FlutterFire project config |
| `android/app/google-services.json` | Android's native Firebase config (downloaded from the Firebase project) |

**One-liner if asked:** "The FlutterFire CLI reads my Firebase project and generates the platform config so I never copy-paste API keys by hand."

### Group C — `flutter pub get` (dependency resolution, regenerated constantly)

| File | Notes |
|---|---|
| `pubspec.lock` | Exact resolved versions of every package — committed so builds are reproducible |
| `.dart_tool/` | Package resolution cache + build tooling (gitignored) |
| `.flutter-plugins-dependencies` | Plugin registry for the native builds (gitignored) |

### Group D — `flutter run` / `flutter build` (compiler output, fully disposable)

| File | Notes |
|---|---|
| `build/` — everything | APK pieces, compiled plugins, `flutter_assets`, C++ intermediates, Gradle caches. `flutter clean` deletes it all; the next run regenerates it. Gitignored — **never in version control** |

### Group E — Android Studio / IntelliJ (IDE metadata, not part of the app)

| File | Notes |
|---|---|
| `.idea/` | IDE workspace settings |
| `tpmentorship.iml`, `android/tpmentorship_android.iml` | IDE module files — purely for the editor, zero effect on the app; deleted → regenerated |
| `android/local.properties` | Machine-specific SDK paths (gitignored) |

### Group F — 100% HAND-WRITTEN (this is YOUR work — own it)

Everything in `lib/` except `firebase_options.dart`:

| Area | Files |
|---|---|
| Entry + navigation | `lib/main.dart` (rewritten from scratch) |
| State wiring | `lib/providers/auth_provider.dart` |
| Auth logic | `lib/services/auth_service.dart` |
| Screens (9) | `lib/screens/` — login, register, forgot_password, change_password, home, search, messages, profile, mentor_profile |
| Reusable widgets | `lib/widgets/` — mentor_card, message_tile, session_card |
| Models | `lib/models/` — mentor, message, session |
| Theme | `lib/theme/app_theme.dart` |
| Demo data | `lib/data/sample_data.dart` |
| Shared helpers | `lib/utils/validators.dart`, `lib/utils/snackbar_helper.dart` |
| Tests | `test/widget_test.dart` (unit tests for `friendlyError`) |
| Hand-edited configs | `pubspec.yaml` (added firebase_core, firebase_auth, flutter_riverpod, google_sign_in), `android/app/build.gradle.kts` + `AndroidManifest.xml` (Firebase/auth wiring) |
| Docs | `README.md` edits, `PRESENTATION_PREP.md` |

### The 15-second summary answer

> "Everything in `lib/` is hand-written except `firebase_options.dart`, which the FlutterFire CLI generates. The `android/` and `web/` folders are Flutter scaffolding from `flutter create` — I only touched the Gradle file and manifest to wire up Firebase. `build/`, `.dart_tool/`, and `pubspec.lock` are tool output: the first two are gitignored and disposable, and the lock file is committed so anyone cloning the repo resolves the exact same package versions."

### `pubspec.yaml` — THE most important config file (know this one)

Your app's **shopping list and settings sheet**. It lists every external package:
- `flutter_riverpod` — state management (sharing login status)
- `firebase_core` — base Firebase connection
- `firebase_auth` — the login system
- `google_sign_in` — the "Sign in with Google" button
- `cupertino_icons` — extra icons
- (dev) `flutter_test`, `flutter_lints` — testing + code-quality rules

It also sets the app `name`, `version` (`1.0.0+1`), and `uses-material-design: true`. **When you "add a package," you add a line here**, then run `flutter pub get` (which updates `pubspec.lock` with the exact versions).

---

## 7. Live Demo Script (rehearse this exact order)

The rubric wants a "logical, well-paced" demo covering navigation, authentication, and main screens — smooth and complete with no major issues. Narrate as you go — calm and clear beats fast. Follow this:

1. **Launch** → app opens on the Login screen. *"The whole app is gated behind Firebase login — `AuthGate` decided this because no one's logged in."*
2. **Show validation** → tap Login with empty fields → validators fire. Type a bad email → "valid email" error. *(Proves form validation — a graded criterion.)*
3. **Register** → go to Register, fill the form, show the confirm-password mismatch error, then fix it → success SnackBar → back to login. *"Registration uses a temporary Firebase instance so it doesn't auto-log me in — it sends me back to log in manually and emails a verification link."*
4. **Login** → enter the new credentials → app reactively swaps to Home. *"Firebase confirms, the auth stream updates, and `AuthGate` switches screens automatically."*
5. **Navigate all 5 tabs** → Home, Search, Messages, Profile, Mentor Profile. Point out `ListView` (Home/Messages) and `GridView` (Search) — required widgets.
   - **Tap two different mentor cards** (one from Home, one from Search) → the Mentor Profile shows the mentor you tapped each time, and its back button returns to the tab you came from. *"The tapped `Mentor` object is passed up through a callback, stored in the navigator's state, and passed into the profile screen."*
6. **Show state preservation** → scroll Home, switch tab, come back → still scrolled. *"All five tabs stay alive via an `IndexedStack`, so state is preserved."*
7. **Account management** → Profile → Settings → show Change Password, Email Verification, Delete Account.
8. **Change password** → do it live → success SnackBar.
9. **Google or GitHub sign-in** → log out, sign in with a provider → show it works.
10. **Logout** → Profile → Logout. *"This clears the Firebase session and `AuthGate` drops me back to login."*

**Safety checklist before you present:**
- Have a **known working email + password** ready (don't invent one live).
- Make sure the device/emulator has **internet** (Firebase needs it).
- Do **one full practice run** right before.
- If anything breaks: state what *should* happen and move on. Composure is graded; perfection isn't.

---

## 8. Known Weak Spots (defend these honestly — don't get caught out)

The graders may probe where you're weakest. Honesty + a plan scores better than bluffing.

- **Riverpod is only used for auth.** Search/Messages use `setState`. If pushed: "For Part 2, auth was the state that genuinely needed sharing across widgets. The other screens have only local UI state so far. In Part 3, when I add Firestore CRUD, I'll introduce more providers for the data layer." *(This is a legitimate, forward-looking answer.)*
- **Search bar isn't functional.** "It's UI-complete; wiring the filter logic is Part 3 scope where the data becomes live."
- **Sample data is hardcoded.** "Correct — Part 2 is UI + auth. The `SampleData` class will be replaced by Firestore queries in Part 3, and my models are already structured to accept that." (The spec itself says CRUD screens don't need to be functional in Part 2.)
- **The `_screen` string in `AuthFlow`.** Some might prefer an enum. "A string was simple and readable for three states; an enum would be marginally more type-safe and is an easy refactor."
- **"John Tay" / hardcoded profile name.** The profile shows placeholder data, not the logged-in user's real info. "In Part 2 the profile is a design mock-up; Part 3 binds it to the real user and Firestore."

---

## 9. Concepts You MUST Be Able To Define In One Sentence

| Term | Your one-liner |
|---|---|
| **Riverpod** | A state-management library that provides and reacts to shared app state. |
| **Provider** | An object that creates and exposes a value (like my `AuthService`) to widgets. |
| **StreamProvider** | A provider that exposes a stream as an `AsyncValue` with data/loading/error states. |
| **`ProviderScope`** | The root widget that enables Riverpod for the whole app. |
| **`ConsumerWidget`** | A stateless widget that can read providers via `ref`. |
| **Widget** | The basic building block of Flutter UI — everything is a widget. |
| **Widget tree** | The nested hierarchy of widgets that *is* your UI. |
| **StatelessWidget** | A widget with no changing internal state. |
| **StatefulWidget** | A widget that holds mutable state and rebuilds via `setState`. |
| **`setState()`** | "Something changed — redraw me." |
| **`Form` / `GlobalKey<FormState>`** | A container that validates all its fields together via a key handle. |
| **`TextEditingController`** | Reads and controls the text in a `TextFormField`; must be disposed. |
| **`Future` / `async`/`await`** | A `Future` is a value that arrives later; `await` pauses until it does. |
| **`Stream`** | A sequence of async events over time (like auth state changes). |
| **`FirebaseAuth`** | Firebase's authentication service that manages users and sessions. |
| **`authStateChanges`** | A stream that emits the current user (or null) on every login/logout. |
| **`IndexedStack`** | A widget that stacks children and shows one by index, keeping all alive. |
| **`kIsWeb`** | A compile-time constant that's true when running on web. |
| **Reauthentication** | Re-confirming the user's password before sensitive actions like changing it. |
| **Model** | A class describing the *shape* of a thing (Mentor, Message, Session) — the data fills it in. |

---

## 10. Q&A — The Question Bank (5% of your grade — practice OUT LOUD)

The rubric's "Excellent" for Q&A: *answers all technical questions confidently, **including reasoning behind implementation choices**, and explains key parts of the code accurately and in detail.* Work up from warm-ups to the tough ones.

### Warm-ups (don't fumble the easy ones)

- **"What is this app / what tech?"** → "A Flutter app written in Dart. Firebase for login, Riverpod for state. Five main screens behind a login gate."
- **"What's a widget?"** → "A building block of the UI. In Flutter everything is a widget — text, layout, the whole screen — nested into a tree."
- **"Stateless vs Stateful?"** → "Stateless just displays what it's given (`MentorCard`). Stateful can change over time (`LoginScreen`)."
- **"Where does your data come from?"** → "Mentor/session/message data is sample data in `sample_data.dart`. Only login is connected to a real backend, Firebase."
- **"What's the difference between a screen and a widget?"** → "A screen is a full page; a widget is a reusable piece used inside pages, like my `MentorCard` and `SessionCard`."
- **"What does pubspec.yaml do?"** → "It's the list of external packages plus app settings like name and version. Adding a package means adding a line there and running `flutter pub get`."
- **"What does `async`/`await` do?"** → "Firebase calls take time. `await` pauses that function until the result arrives, without freezing the whole app."
- **"Do you have any tests?"** → "Yes — unit tests for my `friendlyError` function in `test/widget_test.dart`. It's a pure function, so it tests fast without Firebase or UI."

### Rapid-fire tough questions (the ones most likely to throw you off)

**Q1. "What's the difference between `ref.watch` and `ref.read`?"**
> `watch` subscribes to a provider and rebuilds the widget whenever the value changes — I use it in `AuthGate` so the UI reacts to login/logout. `read` fetches the value once without subscribing — I use it inside button handlers where I just need to call a method one time and don't want rebuilds. Using `watch` inside a callback would be a mistake, and `read` in `build` would miss updates.

**Q2. "Why did you use `IndexedStack` for your navigation instead of just showing one screen?"**
> `IndexedStack` keeps all five screens mounted and only shows the selected one. That preserves each screen's state — scroll position, text in a search box — when you switch tabs and come back. If I'd used a conditional that returns only the active screen, Flutter would destroy and rebuild each screen on every tab switch, losing that state. The trade-off is slightly more memory, which is fine for five screens.

**Q3. "How does your app know whether to show login or the home screen?"**
> There's one gatekeeper widget, `AuthGate`, that watches Firebase's `authStateChanges` stream through a Riverpod `StreamProvider`. When the stream emits a non-null user, it shows `MainNavigator`; when null, it shows the login flow. I never manually navigate after login — it's fully reactive to the real auth state.

**Q4. "Why put all the Firebase code in a service class? Why not just call Firebase in the screens?"**
> Separation of concerns. If I called `FirebaseAuth` directly in every screen, the Firebase logic would be scattered and duplicated, and if I ever swapped auth providers I'd edit dozens of files. With `AuthService`, all auth logic is in one testable place, the screens stay focused on UI, and Riverpod injects the single shared instance. The rubric specifically rewards "clear separation between UI and logic."

**Q5. "Why do you have a `dispose()` method in your screens?"**
> `TextEditingController`s hold resources and listeners. If I don't dispose them when the screen is destroyed, they leak memory. `dispose()` is the StatefulWidget lifecycle hook where I clean them up. Flutter's linter actually warns if you forget.

**Q6. "What does `if (!mounted) return;` do and why is it there?"**
> After an `await`, the widget might have been removed from the tree (e.g., the user navigated away while the network call was in flight). `mounted` tells me if the widget is still alive. If I call `setState` or `ScaffoldMessenger.of(context)` on a dead widget, it throws. The guard prevents that crash.

**Q7. "Why does your login/register/forgot flow use a state variable instead of `Navigator`?"**
> Those three screens are a small self-contained flow shown *before* the user is authenticated. Swapping them with a simple state string in `AuthFlow` keeps them grouped and avoids pushing throwaway routes onto the navigation stack. Once logged in, the main app *does* use proper navigation (bottom nav + `Navigator.push` for Change Password). It's the right tool for each situation.

**Q8. "Walk me through what happens when registration succeeds."**
> I create the account on a temporary secondary Firebase app so it doesn't sign the user into the main app. I fire off a verification email. I delete the temp app in a `finally` block. Back in the UI, I show a success SnackBar and send the user to the login screen to log in manually with the credentials they just chose.

**Q9. "I saw some weird try/catch blocks checking for 'Pigeon' — explain those."**
> There's a known bug in the current `firebase_auth` version where the native bridge (called Pigeon) throws a type-cast error even when the operation *succeeded* — for login, register, delete, and change-password. So instead of blindly showing an error, I verify the real outcome: I centralised this in one helper, `_ignoreKnownBugIf`, which runs the operation and swallows the error only when a success check confirms it worked — e.g., after delete I check `currentUser` is now null. Change-password can't be verified that way, so a second helper recognises the bug by its error shape. All of this lives in `AuthService` — the UI never knows the bug exists, and if Firebase fixes it I update one place.

**Q10. "Why are Google and GitHub sign-in split by `kIsWeb`?"**
> The `google_sign_in` package's token flow works on mobile but not the same way on web, so on web I use Firebase's built-in `signInWithPopup`, and on mobile I use the native package flow. `kIsWeb` is a compile-time constant, so the right branch is chosen per platform. Same for GitHub: popup on web, native provider flow on mobile.

**Q11. "How does form validation actually work?"**
> Each screen has a `Form` with a `GlobalKey<FormState>`. Every `TextFormField` has a `validator` function that returns an error string or null. When the user submits, I call `_formKey.currentState!.validate()`, which runs all validators at once. If any returns a non-null string, that message shows under the field and `validate()` returns false, so I stop. Only when everything's valid do I call Firebase.

**Q12. "What state management are you using and why Riverpod over `setState`?"**
> Riverpod for app-wide state (auth), `setState` for local screen state (a loading spinner, a password-visibility toggle). Auth state needs to be shared across many widgets and react to an external stream — that's exactly what Riverpod's `StreamProvider` is for. Local UI toggles don't need to be global, so `setState` is simpler and appropriate there. Using the right tool at each level.

**Q13. "What happens if the user has no internet when they log in?"**
> Firebase throws a `FirebaseAuthException` with code `network-request-failed`. My `friendlyError` helper catches that specific code and shows "No internet connection. Please try again." instead of a raw error. I handle a whole set of these codes — wrong password, user not found, too many requests, and so on.

**Q14. "Can a Google user change their password in your app?"**
> No, and I handle that deliberately. Change-password and resend-verification are gated behind `isEmailPasswordAccount`, which checks the user's `providerData` for the `'password'` provider. A Google or GitHub user doesn't have one, so instead of letting the call fail, I show a friendly message that the feature is only for email/password accounts.

**Q15. "Why `ConsumerStatefulWidget` in some screens but `ConsumerWidget` / `StatelessWidget` in others?"**
> It depends on what the widget needs. `StatelessWidget` = no state, no providers (e.g., `MentorCard`). `ConsumerWidget` = needs providers but no local state (e.g., `AuthGate`). `ConsumerStatefulWidget` = needs BOTH local state and providers (e.g., `LoginScreen`, which has controllers/loading AND calls the auth service). I pick the lightest one that does the job.

**Q16. "How would you add a real database?"**
> Add Firestore, write a data service like my `AuthService`, and swap the `SampleData` calls for Firestore reads. My models already match, so the screens wouldn't change much. That's exactly the Part 3 plan.

### Curveballs — honest, calm answers

- **"Does the search bar filter?"** → "It's a styled UI scaffold in Part 2; live filtering comes in Part 3 when the data goes live. The spec says CRUD screens don't need to be functional yet."
- **"Why is some data hardcoded?"** → "Part 2 focuses on UI, navigation, and auth; the data layer is structured to plug into Firestore in Part 3."
- **"Did you use AI tools?"** → Declare honestly per the spec: AI is allowed for debugging, consultation, and learning support. What matters is that you understand and can explain every line — which is exactly what this guide prepares you for.
- **"Explain this exact line."** → Read it slowly and describe it in plain English. Don't rush. You know this codebase.

---

## 11. Final Confidence Checklist

Before you walk in, make sure you can:

- [ ] Give the 30-second pitch without notes.
- [ ] Trace the app-launch flow (Android → MainActivity → main() → AuthGate).
- [ ] Trace the login data flow (Screen → provider → service → stream → AuthGate).
- [ ] Explain `ref.watch` vs `ref.read`.
- [ ] Explain why `IndexedStack`.
- [ ] Explain the temp-app registration trick.
- [ ] Explain `kIsWeb` branching for Google/GitHub.
- [ ] Explain form validation with `GlobalKey<FormState>` + keyboard types.
- [ ] Point to a `ListView` AND a `GridView` in your app.
- [ ] Name your 3 account-management features + 2 extra auth methods (rubric only needs 2+2 for Excellent).
- [ ] Explain the AuthService separation-of-concerns benefit.
- [ ] Mention your unit tests if asked about testing.
- [ ] Run the full demo flow smoothly with a known test account (internet on, one practice run done).
- [ ] Word doc ready: Part 1 hi-fi screenshots + implemented app screenshots, named `Part2_YourName_StudentID_YourClass.docx`, zip named to match — submitted before **Mon 6 Jul, 9 AM**.

### The one paragraph to re-read at the door

> "TP Mentorship is a Flutter/Dart app. Everything I see lives in the `lib/` folder; the rest of the project is the Android wrapper and auto-generated build files. `main.dart` starts Firebase and Riverpod and hands control to `AuthGate`, which watches a Firebase login stream and shows either the login flow or the five-tab main app. All login logic is in `AuthService`, shared to screens through Riverpod providers. Screens are full pages built from reusable widgets, styled by one theme file, and filled with sample data. Only authentication is live. I used an `IndexedStack` to preserve tab state, a temporary Firebase app to control the post-registration flow, and a single error-mapping function for clean messages — which I also unit-tested."

**You built this. You understand it. Walk in and explain it like you own it — because you do.**
