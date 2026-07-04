# Explaining.md — Every Key Term, Explained Like You're Five

> **What this file is:** PRESENTATION_PREP.md tells you how your app works. THIS file explains every technical word that guide uses, assuming you know NOTHING about programming. Every term gets: a simple definition, an everyday comparison, and an example from YOUR app.
>
> **How to use it:** When you're reading the prep guide and hit a word that makes your brain go "huh?", look it up here. Read it once top to bottom first — the sections build on each other.

---

## 1. The Absolute Basics

### Code / Programming
**What it is:** Writing instructions for a computer to follow. That's it. A computer is very fast but very dumb — it does EXACTLY what you tell it, step by step, and nothing more.
**Like:** Writing a super-detailed recipe for a chef who has never seen food before. You can't say "make it tasty" — you have to say "add exactly 1 spoon of salt, then stir 10 times."
**In your app:** Every `.dart` file is a page of instructions telling the phone what to draw and what to do when someone taps things.

### Programming language / Dart
**What it is:** A language humans write instructions in, with strict spelling and grammar rules, that can be turned into something a computer understands. **Dart** is the specific language your app is written in.
**Like:** English, Chinese, and Malay are all languages for talking to people. Dart, Python, and Java are languages for talking to computers. You picked Dart.
**In your app:** Everything inside `lib/` is written in Dart.

### Flutter
**What it is:** A big box of ready-made tools (made by Google) that takes your Dart code and turns it into a real app with buttons, colours, and screens — on Android, iPhone, AND web browsers, from ONE set of code.
**Like:** Dart is the language you write the recipe in; Flutter is the fully-equipped kitchen that actually cooks it. Without the kitchen, your recipe is just words on paper.
**In your app:** Flutter is why writing `ElevatedButton(...)` in Dart makes an actual clickable red button appear on a phone.

### App / Application
**What it is:** A finished program a person can open and use — like WhatsApp, YouTube, or your TP Mentorship app.

### Build / Compile
**What it is:** The process of translating your human-readable Dart code into the machine language the phone actually runs. "Compiling" is the translation; the "build" is the finished translated result.
**Like:** You wrote a book in English (your code); compiling is hiring a translator to produce the Japanese version (what the phone reads). The `build/` folder is the pile of translated pages — you can throw it away and translate again anytime.
**In your app:** When you run `flutter run`, Flutter compiles your code and puts all the machinery inside the `build/` folder.

### Platform / Web vs Mobile
**What it is:** The kind of device your app runs on — an Android phone, an iPhone, or a web browser are different "platforms." Some code needs to behave differently on each.
**In your app:** Google Sign-In works differently on the web than on a phone, so your code checks which platform it's on (see `kIsWeb` later) and picks the right method.

### Bug
**What it is:** A mistake in code that makes the app do the wrong thing. Not always a crash — sometimes just wrong behaviour (like showing a green dot for someone who is offline).
**Like:** A typo in the recipe that says "40 spoons of salt" instead of "4."
**In your app:** You found and fixed real bugs — e.g. the mentor profile used to show the same mentor no matter who you tapped.

### Refactor
**What it is:** Rewriting code to be cleaner and tidier WITHOUT changing what it does. The app behaves the same; the code is just better organised.
**Like:** Reorganising your messy wardrobe. Same clothes, but now everything is easy to find.
**In your app:** You refactored the repeated Firebase-bug handling into one shared helper in `AuthService`.

### Code review
**What it is:** Carefully reading through code (yours or someone else's) hunting for bugs and messy parts before it "ships."
**In your app:** You ran a review, found 10 issues, and fixed them — great thing to mention to graders.

---

## 2. Building Blocks of Code

### Variable
**What it is:** A named box that holds a piece of information. You can look inside the box or change what's in it.
**Like:** A labelled jar. The jar labelled `_selectedIndex` currently contains the number `0`.
**In your app:** `int _selectedIndex = 0;` — a box named `_selectedIndex` holding which tab is open (0 = Home, 1 = Search...).

### Value / Data
**What it is:** The actual stuff inside the boxes — a number, some text, a yes/no.

### Types: String, int, double, bool
**What they are:** Different KINDS of values. Dart is strict — every box is labelled with what kind of thing it may hold.
- **String** — text. `'Damian Tan'` is a String. (Always in quotes.)
- **int** — a whole number. `87` sessions.
- **double** — a number with decimals. `4.8` rating.
- **bool** — a yes/no answer: `true` or `false`. `isOnline: true`.
**Like:** A jar labelled "cookies only" can't hold soup. A `String` box can't hold a number.

### null
**What it is:** The special value that means "nothing in this box." Dart makes you say upfront whether a box is allowed to be empty — a question mark after the type (`User?`) means "a User, OR nothing."
**Like:** An empty jar. Before you drink from a jar, you'd better check it's not empty — or you get a nasty surprise (a crash).
**In your app:** `User?` means "maybe a logged-in user, maybe nobody." `AuthGate` checks: if it's null → show login; if not → show the app.

### List
**What it is:** A box holding many values in order, numbered starting from **0** (not 1 — computers count from zero).
**Like:** A row of numbered lockers. Locker 0, locker 1, locker 2...
**In your app:** `List<Mentor>` is a row of mentors. `mentors[0]` is the first mentor (Damian Tan).

### Function / Method
**What it is:** A named bundle of instructions you can run whenever you want by "calling" its name. A **method** is just a function that lives inside a class (see below).
**Like:** A recipe card named "make tea." Instead of rewriting the steps every time, you just say "make tea" and the steps run.
**In your app:** `_login()` is a function. When the Login button is tapped, the app "calls" `_login()` and its steps run: check the form, show the spinner, ask Firebase.

### Parameter / Argument
**What it is:** Information you hand INTO a function so it can do its job.
**Like:** "Make tea" is more useful as "make tea (how sweet, hot or iced)." The bits in brackets are parameters.
**In your app:** `login(email: ..., password: ...)` — the email and password are handed in as parameters.

### Return / Return value
**What it is:** What a function hands BACK when it finishes.
**Like:** You call "make tea" and get back... a cup of tea. That cup is the return value.
**In your app:** `friendlyError(e)` takes an ugly error and returns a nice sentence like "Incorrect email or password."

### Class
**What it is:** A blueprint that describes a kind of thing — what information it holds and what it can do.
**Like:** The blueprint for "a car": every car has wheels, a colour, and can drive. The blueprint isn't a car — it DESCRIBES cars.
**In your app:** `class Mentor` says every mentor has a name, specialization, rating, etc.

### Object / Instance
**What it is:** One real thing made FROM a blueprint.
**Like:** The blueprint is "car"; your neighbour's red Toyota is an object.
**In your app:** `Mentor(name: 'Damian Tan', rating: 4.8, ...)` creates one actual mentor object from the Mentor blueprint.

### Constructor
**What it is:** The special "factory entrance" of a class — the part that builds a new object and fills in its boxes.
**In your app:** `Mentor({required this.name, ...})` is the constructor. `required` means "you MUST provide this — no name, no mentor."

### Getter
**What it is:** A tiny method that looks like reading a variable but actually computes the answer when asked.
**Like:** Asking "is the fridge empty?" — nobody keeps a sticky note with the answer; someone opens the fridge and checks right then.
**In your app:** `isEmailVerified` is a getter — each time you ask, it checks Firebase's current user and answers true/false.

### static
**What it is:** Marks something as belonging to the CLASS itself, not to any one object. You can use it without creating an object first.
**Like:** A vending machine bolted to the school wall — anyone can use it directly; you don't need to build your own vending machine first.
**In your app:** `AuthService.friendlyError(e)` — you call it straight on the class name. Same with `Validators.email`.

### Private (the underscore `_`)
**What it is:** In Dart, a name starting with `_` means "only usable inside this file." It keeps internal machinery hidden.
**Like:** "Staff Only" doors in a restaurant. Customers use the dining room (public); the kitchen is private.
**In your app:** `_ignoreKnownBugIf` starts with `_` because only `AuthService` should ever use it — screens have no business touching it.

### Enum
**What it is:** A type with a fixed menu of allowed values, so you can't typo an invalid one.
**Like:** A traffic light can ONLY be red, amber, or green — never "purple."
**In your app:** You used a plain String (`'login'`, `'register'`) for the auth flow. An enum would be the stricter alternative — a fair "how would you improve this?" answer.

### Import / Package / Library
**What it is:** An **import** is a line at the top of a file saying "I want to use code from over there." A **package/library** is a shareable bundle of someone else's code you can pull into your project.
**Like:** Borrowing tools. Instead of building your own hammer, you borrow the neighbourhood's shared one. `import` is you saying "hand me the hammer."
**In your app:** `import 'package:firebase_auth/firebase_auth.dart';` borrows Google's ready-made login toolbox instead of writing it yourself.

### Comment
**What it is:** A note in the code (starting with `//`) that the computer completely ignores — it's for humans reading the code.
**In your app:** `// always clean up the temporary app` explains WHY a line exists. Graders like good comments.

---

## 3. How Flutter Draws Screens

### Widget
**What it is:** THE most important Flutter word. Every single thing on screen is a "widget": a piece of text is a widget, a button is a widget, empty spacing is a widget, a whole screen is a widget made of smaller widgets.
**Like:** LEGO bricks. A tiny 1x1 brick (text), a wheel (button), a whole LEGO castle (screen) — all "LEGO." Big pieces are built by snapping small pieces together.
**In your app:** `Text('Login')`, `ElevatedButton(...)`, and the entire `LoginScreen` are all widgets.

### Widget tree
**What it is:** The family tree of widgets nested inside each other. Screen contains a column, the column contains rows, rows contain text and icons...
**Like:** Russian nesting dolls, or a family tree: the Scaffold is the grandparent, the Column its child, the Texts its grandchildren.
**In your app:** Your Part 1 proposal contains the widget tree drawing of your home screen — that diagram IS this concept.

### `build()` method
**What it is:** Every widget has a `build()` function that answers one question: "what do you look like RIGHT NOW?" Flutter calls it whenever it needs to draw or redraw the widget.
**Like:** A mirror asking "show me your current outfit." Whenever something changes (you type, you tap), Flutter asks affected widgets to `build()` again and repaints the screen.
**In your app:** Every screen file has a `build()` returning the widgets to draw.

### const
**What it is:** Marks something as "frozen forever at compile time — this will NEVER change." Flutter can then skip rebuilding it, which is faster.
**Like:** A printed poster vs a whiteboard. The poster (`const`) never changes, so nobody wastes time repainting it.
**In your app:** `const Text('Login')` — that text never changes, so it's marked const.

### BuildContext
**What it is:** A widget's "you are here" marker — its position in the widget tree. Lots of Flutter features need it to find things above the widget (like the theme, or where to show a SnackBar).
**Like:** Your home address. To get pizza delivered (a SnackBar shown), the pizza place needs your address (context).
**In your app:** `ScaffoldMessenger.of(context)` means "starting from where I am, walk up the tree and find the thing that can show SnackBars."

### Common layout widgets
- **Row** — puts children side by side, left to right. *Like books on a shelf.*
- **Column** — stacks children top to bottom. *Like pancakes.*
- **Container** — a box you can give a colour, border, rounded corners, and padding. *Like a gift box you decorate.*
- **Expanded** — tells a child "stretch to fill the leftover space." *Like the last person on the sofa spreading out.*
- **Padding / SizedBox** — empty breathing room around or between things.
- **Stack / Positioned** — layers widgets ON TOP of each other. *In your app:* the little green online dot sits on top of the avatar circle using a Stack.
- **SafeArea** — keeps your content away from the phone's notch and system bars.
- **SingleChildScrollView** — makes a too-tall column scrollable instead of overflowing.
- **Wrap** — like a Row that moves to the next line when it runs out of room. *In your app:* the specialization tags ('C++', 'DAVA'...).

### ListView and GridView
**What they are:** Scrollable lists. **ListView** = one column (or row) of items you can scroll. **GridView** = items arranged in a grid, like a photo album.
**The `.builder` part:** `ListView.builder` is the smart version — it only builds the items currently visible on screen, creating more as you scroll. Efficient for long lists.
**Like:** A restaurant that only cooks meals when customers actually order, instead of cooking all 500 menu items upfront.
**In your app:** Home uses a horizontal `ListView.builder` for mentor cards; Messages uses a vertical one; Search uses a `GridView.builder` for subject cards. (The rubric requires these — know where they are!)

### Scaffold and MaterialApp
- **MaterialApp** — the outermost wrapper of the whole app: sets the title, theme, and the first screen. There's exactly one.
- **Scaffold** — the skeleton of ONE screen: background, body, bottom navigation bar slots.
**Like:** MaterialApp is the whole building; each Scaffold is one furnished room.

### GestureDetector / onTap
**What it is:** An invisible wrapper that makes anything tappable and lets you say what happens when it's tapped.
**In your app:** The mentor cards are wrapped in GestureDetector — tapping one calls the function that opens that mentor's profile.

### Callback (`VoidCallback`, `ValueChanged`)
**What it is:** A function you hand to someone else so THEY can call it later when something happens. `VoidCallback` = a callback carrying no information; `ValueChanged<Mentor>` = a callback that carries one value (here, a Mentor) when called.
**Like:** Leaving your phone number with the clinic: "call me when the results are in." You don't know when they'll call — you just gave them the button to press.
**In your app:** `MainNavigator` hands `HomeScreen` a callback `onMentorTap`. When a card is tapped, HomeScreen "calls the number," passing along WHICH mentor was tapped — and MainNavigator shows the popup "Opening \<that mentor\>'s profile." This is how screens talk to the navigator without knowing it exists.

### SnackBar
**What it is:** The little message strip that pops up at the bottom of the screen for a few seconds ("Password changed successfully!").
**Like:** A sticky note that appears, gets read, and vanishes by itself.
**In your app:** Every success and error message is a SnackBar — red for errors, green for success — all shown through one shared helper (`showAppSnackBar`) so they look identical everywhere.

### AlertDialog
**What it is:** A pop-up box in the middle of the screen that demands a decision before you can continue.
**In your app:** Two of them: "Delete Account — This cannot be undone. Cancel / Delete" (destructive actions ALWAYS get a confirmation dialog), and the first-login question for Google/GitHub users — "What should TPMentorship call you?"

### Bottom sheet (`showModalBottomSheet`)
**What it is:** A panel that slides up from the bottom of the screen, covering part of it.
**In your app:** Your Settings menu (Change Password / Email Verification / Delete Account) is a bottom sheet.

### Theme
**What it is:** One central place defining the app's look — colours, fonts, button styles — so every screen matches automatically.
**Like:** A school uniform policy written once, followed by everyone. Change the policy, everyone's outfit changes.
**In your app:** `app_theme.dart` holds TP red (`#E11D2B`) and dark colours. Change a colour there → the whole app updates.

### `kIsWeb`
**What it is:** A built-in yes/no answer that is `true` when the app is running in a web browser and `false` on a phone. Decided at compile time, so the app always knows where it lives.
**In your app:** `if (kIsWeb) { use popup sign-in } else { use phone sign-in }` — Google/GitHub login needs different methods per platform.

---

## 4. Widgets That Remember Things (State)

### State
**What it is:** Information that can CHANGE while the app runs, and that the screen needs to reflect. Which tab is open? Is the spinner spinning? Is the password hidden?
**Like:** The scoreboard at a game. The rules of the game never change (the code); the score changes constantly (the state) and everyone looks at it.

### StatelessWidget
**What it is:** A widget with NO memory. It's handed information, draws it, done. Show it the same information twice, it looks identical.
**Like:** A printed photo. It shows what it shows; it never changes on its own.
**In your app:** `MentorCard` — you give it a mentor, it displays that mentor. No memory needed.

### StatefulWidget
**What it is:** A widget WITH memory. It keeps variables and can redraw itself when they change.
**Like:** A whiteboard — you can erase and rewrite parts of it anytime.
**In your app:** `LoginScreen` remembers what you typed, whether the password is hidden, whether it's loading.

### `setState()`
**What it is:** How a StatefulWidget says "I changed something — redraw me!" You change the variable INSIDE setState so Flutter knows to repaint.
**Like:** Editing the whiteboard and then ringing a bell so everyone looks up and sees the change. Change it without the bell (without setState), and nobody notices — the screen won't update.
**In your app:** Tapping a bottom-nav tab runs `setState(() => _selectedIndex = index)` — the variable changes AND the screen redraws to show the new tab.

### Lifecycle / `dispose()`
**What it is:** Widgets are born, live, and die (get removed from screen). `dispose()` is the "last will" method that runs at death — where you clean up.
**Like:** Checking out of a hotel room: return the key, don't leave the taps running.
**In your app:** Every auth screen disposes its TextEditingControllers so they don't keep using memory after the screen is gone.

### Memory leak
**What it is:** When a program keeps holding onto memory it no longer needs, slowly hogging more and more.
**Like:** Never returning library books. One book, fine. A thousand books, the library runs out.
**In your app:** Forgetting to dispose controllers would slowly leak memory — which is exactly why `dispose()` exists.

### `mounted`
**What it is:** A yes/no flag telling a StatefulWidget "are you still actually on screen?" After waiting for something slow (like the internet), the user might have left the screen — touching a dead screen crashes.
**Like:** Calling out an answer to someone... after checking they haven't already left the room.
**In your app:** `if (!mounted) return;` before every SnackBar shown after an `await`. (Guaranteed Q&A question — Q6.)

### TextEditingController
**What it is:** The object connected to a text box that lets your code READ what the user typed (and change it).
**Like:** A microphone clipped to the text field — whatever gets typed, your code can hear through the controller.
**In your app:** `_emailController.text` is how `_login()` gets the email that was typed. Must be disposed (see above).

### GlobalKey
**What it is:** A name-tag you attach to one specific widget so you can find and talk to it directly from elsewhere.
**Like:** Giving one specific worker a walkie-talkie so you can reach exactly them, not just shout into the crowd.
**In your app:** Two uses: `GlobalKey<FormState>` to tell a Form "validate all your fields NOW," and the `_navigatorKey` used to clear leftover screens when someone signs out.

### StatefulBuilder
**What it is:** A trick to give one small area (like a bottom sheet) its own mini-setState, so just that area can redraw without redrawing the whole screen.
**In your app:** The Settings sheet uses it to refresh the "Email Verified" row after fresh data arrives.

---

## 5. Forms and Checking Input

### Form / TextFormField
**What they are:** **TextFormField** is a text box that knows how to check its own content. **Form** is the container that groups several of them so they can all be checked at once.
**Like:** A paper form with several blanks, and a clerk who checks every blank in one go when you hand it in.

### Validator / Validation
**What it is:** A small function attached to each field that answers: "is this input acceptable?" It returns `null` for "all good" or an error sentence to show under the field.
**Like:** The bouncer at each field's door. Empty email? "Please enter your email." Password too short? "Must be at least 6 characters."
**In your app:** Rules live in ONE shared place — `Validators.email` and `Validators.password` in `lib/utils/validators.dart` — used by every screen, so the rules can never disagree with each other. Cross-checks (like "confirm password must match") stay on the screen because they need to peek at another field.

### `validate()`
**What it is:** The command (via the form's GlobalKey) that runs EVERY field's validator at once. If any field complains, it returns false and the error messages appear.
**In your app:** Every submit button starts with `if (!_formKey.currentState!.validate()) return;` — "if the form isn't clean, stop right here."

### keyboardType
**What it is:** A hint telling the phone which on-screen keyboard to show for a field.
**Like:** Handing someone the right pen for the job — a calculator for numbers, a normal pen for words.
**In your app:** Email fields set `TextInputType.emailAddress`, so the keyboard shows `@` prominently. (The rubric grades this!)

### obscureText
**What it is:** Makes a text field show dots (••••) instead of the actual characters.
**In your app:** Password fields use it, with an eye icon to toggle peeking.

### Feedback
**What it is:** Anything the app does to tell the user "here's what just happened" — error messages, success messages, spinners.
**Like:** A good waiter: confirms your order, tells you if the kitchen is out of something, doesn't just stare silently.
**In your app:** Red/green SnackBars, error text under fields, loading spinners on buttons. (Graded criterion — 2.5%.)

---

## 6. Moving Between Screens (Navigation)

### Navigation
**What it is:** How the user moves from screen to screen.

### Navigator, push and pop
**What it is:** Flutter keeps screens in a **stack** — a pile. **push** = put a new screen ON TOP of the pile. **pop** = throw away the top screen, revealing the one underneath. The Navigator manages the pile.
**Like:** A stack of plates. Add a plate on top (push), remove the top plate (pop). You always see the top plate.
**In your app:** Settings → Change Password does a `push`. Its back button does a `pop`. And when you sign out, the app pops EVERYTHING back to the bottom plate so no logged-in screen is left lying on top of the login screen.

### Route
**What it is:** One screen in that pile. `MaterialPageRoute` is the standard "wrap this screen so it can be pushed."

### BottomNavigationBar
**What it is:** The row of tab buttons along the bottom of the screen (Home, Search, Messages, Profile, Mentor Profile).
**In your app:** Tapping a tab doesn't push anything — it just changes `_selectedIndex`, and the IndexedStack (next) shows a different child.

### IndexedStack
**What it is:** A widget holding several children at once but SHOWING only one, chosen by number. The hidden ones stay alive in memory.
**Like:** A TV with 5 channels. All 5 shows keep playing; you only watch one. Flip back to channel 1 — the show continued while you were away, exactly where it got to.
**In your app:** All 5 tab screens live in an IndexedStack. Scroll down on Home, visit Search, come back — Home is still scrolled where you left it, because it never died. That's the whole reason you chose it. (Q&A favourite — Q2.)

---

## 7. Waiting for Slow Things (Async)

### Synchronous vs Asynchronous
**What it is:** **Synchronous** = do steps one at a time, each waiting for the previous. **Asynchronous (async)** = start a slow job, and don't freeze everything while waiting for it.
**Like:** Sync: standing at the mailbox until a letter arrives, doing nothing else. Async: ordering a package and going about your day; you deal with it when it arrives.
**Why it matters:** Talking to Firebase goes over the internet — slow. If the app waited frozen, the screen would lock up.

### Future
**What it is:** Dart's "I owe you" — an object representing an answer that will arrive LATER.
**Like:** A bakery receipt: not the cake, but the promise of a cake you can collect when it's ready.
**In your app:** `Future<void> login(...)` — calling it doesn't finish immediately; it promises to complete once Firebase answers.

### async / await
**What it is:** `async` marks a function as "allowed to wait." `await` means "pause THIS function here until the answer comes back — but let the rest of the app keep running."
**Like:** At the bakery, you (`await`) sit by the counter till your cake is boxed — but the rest of the shop keeps serving other customers.
**In your app:** `await Firebase.initializeApp(...)` in `main()` — the app must not start until Firebase is connected.

### Stream
**What it is:** A Future gives ONE answer, once. A **Stream** keeps delivering answers over time, whenever something happens.
**Like:** Future = a letter. Stream = a magazine subscription — issues keep arriving.
**In your app:** `authStateChanges` is a Stream. Every time someone logs in or out, it delivers the news. `AuthGate` is subscribed and switches screens each time an issue arrives. This is the reactive backbone of your whole app.

### Exception / throw
**What it is:** When something goes wrong, code **throws** an exception — an error object that shoots up out of the function like an alarm, stopping normal flow until someone catches it.
**Like:** A fire alarm. Work stops, and the alarm travels up until someone qualified handles it.
**In your app:** Wrong password → Firebase throws a `FirebaseAuthException` with code `'wrong-password'`.

### try / catch / finally
**What it is:** `try { risky stuff } catch (e) { what to do if it explodes } finally { runs NO MATTER WHAT }`.
**Like:** Try: attempt the science experiment. Catch: if it explodes, grab the extinguisher. Finally: whether it exploded or not, clean the desk afterwards.
**In your app:** Registration tries to create the account, catches Firebase errors to show friendly messages, and the `finally` block ALWAYS deletes the temporary Firebase app — success or failure.

### rethrow
**What it is:** Inside a catch block: "actually, I can't handle this one — send the alarm further up."
**In your app:** In the known-bug helper: if the operation genuinely failed, `rethrow` passes the real error up so the screen can show it.

---

## 8. Sharing Information Across the App (Riverpod)

### State management
**What it is:** The strategy for handling information MANY screens care about. `setState` only redraws ONE widget — but "is the user logged in?" matters to the entire app. State management tools solve that.
**Like:** A family whiteboard in the kitchen vs sticky notes in each bedroom. Family-wide info goes on the kitchen board where everyone can see it.

### Riverpod
**What it is:** The state-management package your app uses. It keeps shared information in "providers" that any widget can read or watch.
**In your app:** Riverpod shares two things: the AuthService (the login toolbox) and the live login status.

### Provider
**What it is:** A labelled shared box that creates and holds ONE value for the whole app. Widgets ask the box for the value instead of making their own.
**Like:** The office's one shared printer. Nobody buys a personal printer; everyone sends jobs to THE printer.
**In your app:** `authServiceProvider` holds the single AuthService everybody uses.

### Singleton
**What it is:** The pattern of having exactly ONE instance of something, shared by all.
**Why it matters here:** One AuthService means one consistent view of who's logged in — no duplicates that could disagree.

### StreamProvider
**What it is:** A provider that wraps a Stream and hands widgets its latest value, along with "still loading" and "something broke" states.
**In your app:** `authStateProvider` wraps Firebase's `authStateChanges` stream. `AuthGate` watches it.

### ProviderScope
**What it is:** The root widget that switches Riverpod ON. All providers live inside it, so it must wrap the entire app.
**Like:** The electrical main switch of the house. No switch on, no power anywhere.
**In your app:** `runApp(const ProviderScope(child: MyApp()))` — the very first widget.

### ConsumerWidget / ConsumerStatefulWidget
**What it is:** Widgets that are ALLOWED to read providers (they get a `ref`, the handle for reaching the shared boxes). Consumer = stateless + ref; ConsumerStateful = stateful + ref.
**In your app:** `AuthGate` is a ConsumerWidget (needs the login status, no memory). `LoginScreen` is ConsumerStateful (needs the auth service AND its own memory).

### `ref.watch` vs `ref.read` vs `ref.listen`
**The guaranteed exam question.** All three reach into a provider, but differently:
- **watch** — "subscribe me: whenever this value changes, REDRAW me." Use in `build()`.
  *Like subscribing to a YouTube channel — you get every new video.*
- **read** — "give me the value RIGHT NOW, once, no subscription." Use inside button handlers.
  *Like watching a single video without subscribing.*
- **listen** — "don't redraw me, but RUN THIS ACTION whenever it changes." For side effects.
  *Like setting an alarm: when X happens, do Y.*
**In your app:** `AuthGate` **watches** the login status (must redraw when it changes), buttons **read** the auth service (just need to call a method once), and `AuthGate` also **listens** for "user became null" to clear pushed screens on sign-out.

### AsyncValue (data / loading / error)
**What it is:** The wrapper StreamProvider hands you. Because internet answers take time and can fail, the value is always one of three shapes: **loading** (still waiting), **data** (here's the answer), **error** (it broke). The `.when(...)` method forces you to handle all three.
**Like:** Tracking a delivery: "on the way" / "delivered" / "lost in transit." A good app plans for all three.
**In your app:** `AuthGate` shows a spinner while loading, the right screen on data, and an error message on error. Handling all three is good practice worth saying out loud.

---

## 9. Firebase and the Internet

### Server / Backend / Cloud
**What it is:** A **server** is a computer that lives somewhere else and answers requests over the internet. The **backend** is the behind-the-scenes half of an app (data, accounts) that lives on servers. "**The cloud**" = renting other people's servers (Google's, in your case).
**Like:** A restaurant: the dining room you sit in is the frontend (your app's screens); the kitchen you never see is the backend.
**In your app:** Your screens are the frontend. Firebase is your backend — it remembers accounts so users can log in from any device.

### Firebase
**What it is:** Google's ready-made backend-in-a-box. Instead of building and running your own account system on your own servers, you use theirs.
**Like:** Instead of building a bank vault in your bedroom, you keep valuables at an actual bank.
**In your app:** Part 2 uses Firebase **Authentication** (accounts/login). Part 3 will add **Firestore** (a cloud database for your mentors/sessions data).

### Authentication ("auth")
**What it is:** Proving you are who you say you are — the whole business of registering, logging in, logging out.
**Like:** Showing ID at a club door.
**In your app:** 12.5% of your grade. Register, login, logout, forgot password + change password, email verification, delete account + Google & GitHub sign-in.

### Account / User / Session / Credential
- **Account** — your saved identity on the server (email + secret).
- **User object** — the app's handle on the logged-in person (`User?` — null when nobody's in).
- **Session** — the period you stay logged in. Firebase remembers you between app launches; that's why the app opens straight to Home.
- **Credential** — the proof used to log in (email+password, or a token from Google).

### Display name (`displayName`)
**What it is:** A name Firebase stores ON the account, on its servers — separate from the email. Because it lives on the server, it follows the user to any device and survives reinstalls.
**Like:** The name tag stapled to your gym membership file — the gym greets you with it no matter which branch you walk into.
**In your app:** The register form's name is saved as the display name (`updateDisplayName`). Google/GitHub users without one get asked "What should TPMentorship call you?" on first login. The Home screen's "Hello \<name\>", the Profile card, and the My Mentor Profile tab all read it.

### `authStateChanges`
**What it is:** Firebase's Stream that announces "someone logged IN" / "someone logged OUT" the moment it happens.
**In your app:** The single most important wire: Firebase → this stream → StreamProvider → AuthGate → the screen switches. You never manually navigate after login; the news arrives and the app reacts.

### Email verification
**What it is:** Sending a click-this-link email to prove the address really belongs to the user.
**In your app:** Sent automatically on registration; can be re-sent from Settings; the sheet shows current verified status.

### Password reset ("forgot password")
**What it is:** Firebase emails a special link where the user sets a new password. You never see or store their password — Firebase handles all of it.

### Reauthentication
**What it is:** For sensitive actions, being logged in isn't enough — Firebase demands you re-enter your password to prove it's really YOU right now.
**Like:** The bank asks for ID again before a big withdrawal, even though you're already inside.
**In your app:** Change Password requires the current password first — that's reauthentication.

### `requires-recent-login`
**What it is:** Firebase's error meaning "this action is too sensitive for an old session — log in again first."
**In your app:** Can appear on Delete Account; your `friendlyError` turns it into "For security, please log out and log in again."

### OAuth / Federated sign-in ("Sign in with Google/GitHub")
**What it is:** Logging into one app using an account from another company, WITHOUT giving your password to the new app. Google/GitHub just tell your app "yes, we vouch for this person" via a **token** (a temporary proof-pass).
**Like:** A trusted friend vouching for you at the door instead of you showing ID: the bouncer trusts the friend.
**In your app:** Google and GitHub sign-in are your two "extra auth methods." A federated user has NO password in your app — which is exactly why change-password is disabled for them (`isEmailPasswordAccount`).

### Popup (`signInWithPopup`)
**What it is:** On the web, sign-in opens a small browser window where you log into Google/GitHub, then it closes and hands the result back.
**In your app:** Used when `kIsWeb` is true; phones use the native flow instead.

### Provider ID (`'password'`, `'google.com'`)
**What it is:** Firebase labels each way a user can sign in. Checking for the `'password'` label is how your app knows "this is a real email/password account."
**Careful:** this "provider" (sign-in method) is a DIFFERENT word from Riverpod's "provider" (shared box). Same word, two meanings — don't mix them up in the Q&A.

### The "Pigeon bug"
**What it is:** Pigeon is the messenger system between Flutter code and the phone's native code. The current firebase_auth version has a known glitch: sometimes the messenger garbles the reply and THROWS AN ERROR even though the operation SUCCEEDED.
**Like:** You mail a letter, it arrives safely — but the postal service still hands you a "delivery failed" slip by mistake.
**In your app:** Instead of trusting the false alarm, you CHECK REALITY: after "failed" login, is someone actually signed in now? After "failed" delete, is the account actually gone? One shared helper (`_ignoreKnownBugIf`) does this check everywhere. The whole thing lives inside AuthService so the screens never even know the bug exists.

### API key / Config files
**What it is:** An **API key** is an ID string that tells Google WHICH Firebase project your app belongs to (like a customer number — not a password). Config files (`firebase_options.dart`, `google-services.json`) hold these IDs and were generated by tools, not typed by hand.
**In your app:** `flutterfire configure` generated them. Without them, the app wouldn't know which Firebase project to call.

### Firestore (Part 3 preview)
**What it is:** Firebase's cloud database — where real mentor/session/message data will live instead of your hardcoded sample data.
**In your app:** Not used yet. Part 2's `SampleData` class is the stand-in; Part 3 swaps it for Firestore reads.

### CRUD
**What it is:** The four basic things you do with stored data: **C**reate, **R**ead, **U**pdate, **D**elete.
**Like:** A notebook: write a new entry, read it, correct it, tear the page out.
**In your app:** Part 3 scope. Part 2's spec explicitly says CRUD screens don't need to work yet — your "coming soon" buttons are intentional.

---

## 10. The Toolbox (Project Files & Commands)

### pubspec.yaml / Dependency
**What it is:** Your project's shopping list. Each **dependency** is a line saying "my app needs this package." Yours: firebase_core, firebase_auth, flutter_riverpod, google_sign_in.

### `flutter pub get` / pubspec.lock
**What it is:** The command that goes shopping — downloads everything on the list. **pubspec.lock** records the EXACT versions fetched, so the app builds identically on any computer.
**Like:** The list says "buy milk"; the lock file is the receipt showing "Meiji 1L, $3.20" — anyone can re-buy the exact same basket.

### flutter create / run / clean / analyze / test
- **create** — builds a new project skeleton (that's where `android/`, `web/`, etc. came from).
- **run** — compiles and launches your app on a phone/emulator/browser.
- **clean** — deletes the whole `build/` folder. Safe; it regenerates.
- **analyze** — spell-checks your code for mistakes and bad habits WITHOUT running it. Yours reports zero issues.
- **test** — runs your automated tests.

### Auto-generated code
**What it is:** Files created by tools, not typed by a human. You don't edit them; you re-run the tool.
**In your app:** `firebase_options.dart`, everything in `build/`, `pubspec.lock`. Section 6 of the prep guide maps out exactly which files are which — a likely grader question.

### Linter
**What it is:** The automatic nag that underlines sloppy code as you type ("this variable is never used").
**Like:** Spell-check for code.
**In your app:** Configured by `analysis_options.yaml`; it's why VS Code underlines things.

### Unit test / Pure function
**What it is:** A **unit test** is code that checks another piece of code automatically: "given THIS input, I expect THAT output." A **pure function** always gives the same output for the same input and touches nothing else — which makes it the easiest thing to test.
**Like:** A fire drill for code — a rehearsed check that the alarm works, run any time in seconds.
**In your app:** `test/widget_test.dart` checks `friendlyError` turns `'wrong-password'` into "Incorrect email or password." It's pure and static — no Firebase or UI needed. `flutter test`: all 4 pass.

### Emulator
**What it is:** A pretend phone running in a window on your computer, for testing without a real device.

### Git / Repository / .gitignore
**What it is:** **Git** saves snapshots (commits) of your project over time so you can see history and undo mistakes. The **repository** is the tracked project. **.gitignore** lists files NOT worth saving (like the throwaway `build/` folder).
**Like:** Autosave slots in a video game — you can always reload an older save.

### Hardcoded / Sample data / Placeholder
**What it is:** Values typed directly into the code instead of coming from a real source. **Sample data** = fake demo content; **placeholder** = a stand-in until the real thing exists.
**In your app:** The mentors in `sample_data.dart` are hardcoded on purpose — Part 2 needs UI + auth, not a live database. Own this answer confidently.

---

## 11. The Big Ideas (Architecture)

### Architecture
**What it is:** The deliberate plan for how the code is organised — what goes where and why.

### Separation of concerns
**What it is:** THE big idea of your project: each part of the code has ONE job and doesn't do anyone else's. Screens draw. Services talk to Firebase. Providers share. Models hold data.
**Like:** A restaurant: waiters take orders, chefs cook, cashiers handle money. Imagine the waiter also cooking and doing accounts — chaos when anything changes.
**In your app:** Screens NEVER call Firebase directly — they always ask `AuthService`. If you ever switched away from Firebase, you'd edit one file, not eleven. The rubric literally grades this.

### Service
**What it is:** A class whose only job is handling one outside thing (here: authentication). The "brain" the screens delegate to.
**In your app:** `AuthService` — every Firebase call in the whole app lives in this one file.

### Model vs Data
**What it is:** A **model** is the empty form (a Mentor HAS a name, a rating...). The **data** is a filled-in copy (Damian Tan, 4.8).
**Like:** The blank "student profile" sheet vs your actual completed one.
**In your app:** `lib/models/` holds the blank forms; `sample_data.dart` fills them in. Every field on your models is actually shown somewhere on screen — dead fields were removed after your code review.

### UI (User Interface) / UX (User Experience)
**What it is:** **UI** = everything the user sees and touches. **UX** = how it FEELS to use — smooth and obvious, or confusing.
**In your app:** A UX detail worth bragging about: the app greets you by YOUR name ("Hello Zach"), and tapping a mentor card gives instant feedback naming exactly who you tapped — small touches that make the app feel aware instead of generic.

### Reactive
**What it is:** The style where the screen automatically reflects the current data, instead of being manually pushed around. Data changes → screen reacts.
**Like:** A thermometer. Nobody "updates" it — the temperature changes and the reading follows, always.
**In your app:** Login is reactive: Firebase's stream fires, AuthGate reacts, the screen swaps. You never write "now go to the home screen."

### DRY — Don't Repeat Yourself
**What it is:** If the same code appears in five places, put it in ONE place and reuse it. Repeats drift apart and cause bugs (fix one copy, forget the others).
**Like:** One master house key instead of five slightly-different copies that each open only some doors.
**In your app:** You applied it three times: shared validators (`Validators`), one SnackBar helper (`showAppSnackBar`), one Pigeon-bug helper (`_ignoreKnownBugIf`).

### Defensive programming
**What it is:** Writing code that expects things to go wrong — checking `mounted`, handling all three AsyncValue states, confirming before deletes, verifying reality when a buggy library cries wolf.
**Like:** Wearing a seatbelt. Not because you plan to crash — because you might.

---

## The 60-second recap (read this at the door)

> My app is **code** written in **Dart**, drawn by **Flutter**, where everything on screen is a **widget** arranged in a **tree**. Widgets that remember things are **stateful** and redraw with **setState**; app-wide facts (like "who is logged in") live in **Riverpod providers**, which screens **watch** (redraw on change) or **read** (grab once). Logging in is **asynchronous** — the app **awaits** **Firebase**, my cloud **backend** — and the result flows through a **stream** into **AuthGate**, which **reactively** swaps between the login flow and the 5-tab app. Forms check input with **validators**, users get **feedback** through **SnackBars**, tabs preserve state with an **IndexedStack**, and every Firebase call lives in ONE **service** class — that's **separation of concerns**, and it's the backbone of my whole project.

If you can read that paragraph and explain every bolded word using this file — you understand your app better than most people who built theirs twice as fast.
