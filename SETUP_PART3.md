# Part 3 Setup - What YOU still need to do

All the code is written. These are the backend / console steps only you can do.

## 1. Enable Cloud Firestore (required - CRUD won't work without it)

1. Go to https://console.firebase.google.com and open your project (`mbap-6e9d4`)
2. Left menu → **Build → Firestore Database** → **Create database**
3. Pick the **asia-southeast1 (Singapore)** region
4. Start in **test mode** (fine for the project; you can tighten rules later)

That's it - no composite indexes are needed. The queries were deliberately
designed so Firestore's automatic single-field indexes cover all of them.

The first time anyone logs in, the app automatically fills the `mentors`
collection with 10 seed mentors and creates the logged-in user's profile
document. Sessions appear in the `appointments` collection as you book them.

### Recommended security rules (after testing)

Firestore Database → Rules tab:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /mentors/{doc} {
      allow read: if request.auth != null;
      allow write: if request.auth != null; // needed for the auto-seed
    }
    match /users/{uid} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
    match /appointments/{doc} {
      allow create: if request.auth != null
                    && request.resource.data.studentId == request.auth.uid;
      allow read, update, delete: if request.auth != null
                    && resource.data.studentId == request.auth.uid;
    }
  }
}
```

## 2. Gemini API key (optional but recommended for the AI feature)

Without a key the AI mentor matching still works - it falls back to the
local scoring algorithm. With a key, Gemini ranks the mentors and writes
the "why this mentor" explanations.

1. Go to https://aistudio.google.com/apikey (free, no credit card)
2. Create an API key
3. Paste it into `lib/services/ai_matching_service.dart`:
   ```dart
   static const String geminiApiKey = 'YOUR_KEY_HERE';
   ```

Note: the key is free-tier and the endpoint used is `gemini-2.0-flash`.

## 3. Try it

```
flutter run -d chrome        # web (notifications are silently disabled)
flutter run                  # android emulator (everything works)
```

Demo flow to test everything:
1. Log in → home shows AI-recommended mentors (seeded on first login)
2. Profile → Edit Profile → set your subjects (feeds the AI matching)
3. Tap a mentor → Book a Session (INSERT + scheduled notification)
4. Home → Upcoming Sessions "View all" → filter chips (advanced queries)
5. Tap a session → Reschedule (UPDATE) / Mark Completed (UPDATE) /
   Cancel (DELETE with confirm dialog)
6. Profile → "X completed" badge (COUNT aggregation)
7. Search → popular search chips / subject cards / rating rows
   (filter, multi-filter same field, sort queries)
8. Profile → Upgrade → NETS QR → "I've paid" (premium unlocks live)
9. Settings → App Theme → switch palettes (personalisation)
10. Settings → Test Notification (emulator only)
11. Turn off wifi → orange offline banner slides in

## 4. Known behaviour notes (for your Q&A prep)

- **Notifications on web**: every NotificationService method starts with
  `if (kIsWeb) return;` - the feature is mobile-only by design, web still
  runs cleanly without it.
- **google_sign_in stays at v6** - do NOT `pub upgrade --major-versions`
  (v7 removed the API that `signInWithGoogle()` uses).
- **Theme switching**: AppTheme's colours are mutable statics; picking a
  palette reassigns them and the MaterialApp key change forces a full
  rebuild. Saved with shared_preferences.
- The seed data lives in `lib/services/mentor_service.dart` - edit the
  `_seedMentors` list if you want different mentors (delete the mentors
  collection in the console to re-trigger seeding).
