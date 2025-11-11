## 🚶 User Flow: Sign-Up & First Drop

The flow prioritizes getting the user authenticated and their required profile data (`username`) set up, followed immediately by the core action of the MVP: dropping a Point.

-----

### 1\. 🔑 Sign-Up / Log-In

The goal here is to authenticate the user via a third party and create their `profile` record if they are new.

**Screen 1: Authentication Gate**

| Action | API Interaction |
| :--- | :--- |
| **New/Returning User Clicks Provider** | Flutter initiates **Supabase Auth** flow (e.g., Google or Apple OAuth). |
| **Success** | Supabase returns a **JWT** and the user's `auth.uid()`. |

```
┌───────────────────────────┐
│          tuPoint          │
│                           │
│     (App Logo Here)       │
│                           │
│                           │
│ [ Sign In with Google ]   │
│ [ Sign In with Apple ]    │
│                           │
└───────────────────────────┘
```

**Screen 2: Profile Creation (Conditional)**

This screen is only shown **once** to new users whose `auth.uid()` does not yet have a corresponding record in the `profile` table.

| Action | API Interaction |
| :--- | :--- |
| **User Enters Username & Clicks Done** | Flutter sends an authenticated **POST** to the `profile` endpoint with `id: auth.uid()` and the chosen `username`. |
| **Success** | HTTP 201 Created. The user now has a complete identity. |
| **Failure (Duplicate Username)** | HTTP 409 Conflict. Display error, user must try again. |

```
┌───────────────────────────┐
│  Welcome to tuPoint!      │
│                           │
│ Pick a Username:          │
│ ───────────────────────── │
│ | @CoolMapMaker_99      | │
│ ───────────────────────── │
│                           │
│ Bio (Optional):           │
│ ───────────────────────── │
│ | ...                   | │
│ ───────────────────────── │
│                           │
│     [ Done ]              │
└───────────────────────────┘
```

-----

### 2\. 📍 Drop a New Point

This is the core creation flow.

**Screen 3: Main Feed & Drop Button**

| Action | API Interaction |
| :--- | :--- |
| **App Loads** | Flutter performs authenticated **GET** request for all `points` (active) and starts client-side filtering. |
| **User Clicks Drop Button** | Triggers location check and navigates to the creation screen. |

```
┌───────────────────────────┐
│ 📍 Near Me                │
│ ───────────────────────── │
│ Point: "Awesome coffee!"  │
│ User: @latte_lover        │
│ Likes: 12                 │
│ ───────────────────────── │
│ Point: "Busy park today." │
│ User: @local_explorer     │
│ Likes: 5                  │
│ ───────────────────────── │
│                           │
│        [ + ]              │
└───────────────────────────┘
```

**Screen 4: Point Creation**

| Action | API Interaction |
| :--- | :--- |
| **User Taps Post** | Flutter calculates the **Maidenhead** code and sends an authenticated **POST** to the `points` endpoint. |

```
┌───────────────────────────┐
│ 🗺️ Drop a Point           │
│                           │
│ Your Message:             │
│ ───────────────────────── │
│ | This app is gonna be  | │
│ | huge!                 | │
│ ───────────────────────── │
│                           │
│ Location:                 │
│ (Captured Lat/Lon)        │
│ (Maidenhead: FN20sa)      │
│                           │
│ [ Cancel ]  [ Post ]      │
└───────────────────────────┘
```
