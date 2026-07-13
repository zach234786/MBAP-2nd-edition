# In-App Messaging — Design

**Date:** 2026-07-13
**Status:** Approved

## Goal

Replace the fake Messages tab and the email-based "Reach Out" flow with real,
live, two-way chat between registered users, backed by Firestore.

- Students can message mentors (a **Message** button on the mentor profile).
- Mentors can message students (the existing **Reach Out** button in the
  student directory, repurposed from email to chat).
- The Messages tab lists the logged-in user's real conversations, live.

## Key constraint

Messaging only truly works between **real registered accounts**. Seed students
and seed mentors are demo data with no account behind them, so a message to one
lands nowhere. This must never crash — a conversation with a seed entry is
simply one no real account will ever receive. Real accounts (whose directory /
mentor doc id is their auth uid) are the ones that work end to end.

## Data model (Firestore)

### `conversations/{conversationId}`
- `participants`: array of the two user uids
- `participantNames`: map of uid → display name (denormalised so the other
  person's name shows without an extra lookup)
- `lastMessage`: string (preview text for the Messages list)
- `lastMessageAt`: timestamp
- `lastSenderId`: uid of who sent the last message

`conversationId` is **deterministic**: the two uids sorted alphabetically and
joined with `_` (e.g. `abc_xyz`). Opening a chat with the same person always
resolves to the same document, so no duplicate threads are created.

### `conversations/{conversationId}/messages/{messageId}`
- `senderId`: uid of the sender
- `text`: the message body
- `createdAt`: timestamp

## Components

### New files
- `lib/models/conversation.dart` — `Conversation` model + `fromMap`/`toMap`,
  plus a helper to resolve the other participant's uid/name given "my" uid.
- `lib/models/chat_message.dart` — `ChatMessage` model + `fromMap`/`toMap`.
- `lib/services/chat_service.dart`:
  - `conversationIdFor(a, b)` — deterministic id helper.
  - `streamConversations(myUid)` — `where('participants', arrayContains: myUid)`,
    sorted by `lastMessageAt` **in Dart** (no composite index needed, matching
    the pattern in the existing services).
  - `streamMessages(conversationId)` — the thread, oldest→newest.
  - `sendMessage(...)` — writes the message doc and `set`s (merge) the parent
    conversation doc with `participants`, `participantNames`, `lastMessage`,
    `lastMessageAt`, `lastSenderId`. The merge-set means the first message also
    creates the conversation, so there is no separate "create conversation" step.
- `lib/providers/chat_provider.dart`:
  - `chatServiceProvider`
  - `conversationsProvider` — StreamProvider of the current user's conversations.
  - `messagesProvider` — StreamProvider.family keyed by conversationId.
- `lib/screens/chat_screen.dart` — the thread UI: a scrolling list of message
  bubbles (mine right-aligned, theirs left-aligned) and a text input + send
  button at the bottom.

### Modified files
- `lib/screens/messages_screen.dart` — becomes a `ConsumerStatefulWidget`.
  Replaces `SampleData.getMessages()` with `conversationsProvider`. Removes the
  fake mentor-circle row. The search box filters the real conversation list by
  the other participant's name. Tapping a conversation opens `ChatScreen`.
- `lib/screens/student_list_screen.dart` — "Reach Out" opens `ChatScreen` with
  the student (via their uid + name) instead of composing an email.
- `lib/screens/mentor_detail_screen.dart` — adds a **Message** button
  (hidden when viewing your own profile, alongside the existing self checks).
- `firestore.rules` — add rules for `conversations` and its `messages`
  subcollection.

### Removed / retired
- `ShareService.contactStudentByEmail` is no longer used (Reach Out now chats).
  Left in place or removed during implementation; the mentor-share-by-email
  feature is untouched.

## Firestore rules

```
match /conversations/{conversationId} {
  allow read: if request.auth != null
              && request.auth.uid in resource.data.participants;
  allow create: if request.auth != null
              && request.auth.uid in request.resource.data.participants;
  allow update: if request.auth != null
              && request.auth.uid in resource.data.participants;

  match /messages/{messageId} {
    allow read: if request.auth != null
        && request.auth.uid in
           get(/databases/$(database)/documents/conversations/$(conversationId)).data.participants;
    allow create: if request.auth != null
        && request.resource.data.senderId == request.auth.uid;
  }
}
```

The conversations-list query filters by `arrayContains: myUid`, which matches
the read rule's condition, so the aggregate/list query is allowed (unlike a
query whose filter can't satisfy the rule).

## Data flow

1. User taps **Reach Out** (student) or **Message** (mentor).
2. App computes `conversationIdFor(myUid, otherUid)` and pushes
   `ChatScreen(conversationId, otherUid, otherName)`.
3. `ChatScreen` watches `messagesProvider(conversationId)` — empty on a brand
   new thread.
4. On send, `sendMessage` merge-creates the conversation doc and appends the
   message. The stream updates both screens live.
5. The Messages tab's `conversationsProvider` picks up the new/updated
   conversation automatically.

## Error handling
- No participant email or account (seed data): the write still succeeds; the
  message just isn't delivered to a real inbox. No crash.
- Offline / permission errors: the existing snackbar + async error states in
  the screens surface a friendly message; the send button re-enables.

## Out of scope (YAGNI)
- Read receipts / unread counts / typing indicators.
- Group chats (conversations are strictly 1:1).
- Push notifications for new messages.
- Editing or deleting sent messages.
