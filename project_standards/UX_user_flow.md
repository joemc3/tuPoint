## 🚶 User Flow: Sign-Up & First Drop

The flow prioritizes getting the user authenticated and their required profile data (`username`) set up, followed immediately by the core action of the MVP: dropping a Point.

-----

### 1\. 🔑 Sign-Up / Log-In

The goal here is to authenticate the user and create their `profile` record if they are new.

**Authentication supports two methods:**
1. **Email/Password** - Direct sign-up/sign-in (MVP implementation)
2. **OAuth Providers** - Google and Apple Sign In (configured separately)

**Screen 1: Authentication Gate**

| Action | API Interaction |
| :--- | :--- |
| **Email/Password Sign Up** | Flutter sends **POST** to `auth.signup` with email/password. Creates `auth.users` record only (no profile yet). |
| **Email/Password Sign In** | Flutter sends **POST** to `auth.token` with email/password. Returns **JWT** and `auth.uid()`. |
| **OAuth Provider Clicked** | Flutter initiates **Supabase Auth** OAuth flow (e.g., Google or Apple). |
| **Success (All Methods)** | Supabase returns a **JWT** and the user's `auth.uid()`. |

```
┌───────────────────────────┐
│          tuPoint          │
│                           │
│   what's your point?      │
│                           │
│                           │
│ ┌─────────────────────┐   │
│ │  Create Account     │   │
│ │                     │   │
│ │ Email: _________    │   │
│ │ Password: ______    │   │
│ │                     │   │
│ │ After signing up,   │   │
│ │ you'll choose your  │   │
│ │ username            │   │
│ │                     │   │
│ │   [ Sign Up ]       │   │
│ │                     │   │
│ │ Already have an     │   │
│ │ account? Sign In    │   │
│ └─────────────────────┘   │
│                           │
│         OR                │
│                           │
│ [ Sign In with Google ]   │
│   (Not Configured)        │
│ [ Sign In with Apple ]    │
│   (Not Configured)        │
│                           │
└───────────────────────────┘
```

**Flow Routing After Authentication:**
- **New User** (no profile): → Profile Creation Screen
- **Returning User** (has profile): → Main Feed Screen

**Screen 2: Profile Creation (Conditional)**

This screen is shown **after authentication** to users whose `auth.uid()` does not yet have a corresponding record in the `profile` table.

**When Profile Creation is Shown:**
- **Email/Password Sign Up**: Always shown after account creation (account created without profile)
- **OAuth Sign In** (Google/Apple): Shown if user has no profile yet (first-time OAuth user)
- **Email/Password Sign In**: NOT shown (profile already exists from previous sign-up)

| Action | API Interaction |
| :--- | :--- |
| **User Enters Username & Clicks Done** | Flutter sends an authenticated **POST** to the `profile` endpoint with `id: auth.uid()` and the chosen `username`. |
| **Success** | HTTP 201 Created. The user now has a complete identity. Routes to Main Feed. |
| **Failure (Duplicate Username)** | HTTP 409 Conflict. Display error snackbar, user must try a different username. |
| **Failure (Invalid Format)** | HTTP 400 Bad Request. Display validation error, user corrects input. |

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
