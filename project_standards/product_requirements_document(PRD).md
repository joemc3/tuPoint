## 📝 Product Requirements Document (PRD)

### 1. Goal & Vision (The "Why")

| Field | Description |
| :--- | :--- |
| **Product Name** | tuPoint (**tP.2** internally)|
| **Product Goal** | To create a mobile social media platform centered around dropping location-specific content ("Points") to share and discover experiences tied to physical places. |
| **Target User** | Early adopters interested in location-aware sharing and localized communities. |

### 2. MVP Scope (The "What")

The MVP will focus on the core loop: **Authenticate -> Drop a Point -> View Nearby Points.**

| Feature Area | Priority | Description |
| :--- | :--- | :--- |
| **User Authentication** | **Must Have** | Users can sign up/log in using external providers (Google, Apple). |
| **Drop a Point** | **Must Have** | Users can post a simple text-based message ("Point") at their current location. They must confirm the exact location. |
| **Location Handling** | **Must Have** | Capture precise lat/lon. Calculate and store a **6-character Maidenhead locator** for generalized search/display. |
| **View Feed** | **Must Have** | Display a feed of Points based on the user's current location. Default feed is "All Points within $5\text{ km}$." |
| **Basic Profile** | Should Have | User can see their own list of dropped Points. |
| **Social Interaction** | Nice to Have | Users can "Like" a Point. No commenting/following in MVP. |
| **Real-time Chat** | **Out of Scope** | *Future Feature* |
| **Moderation System** | **Out of Scope** | *Future Feature* (Manual moderation, if any, will be done outside the app.) |

### 3. Technical Requirements (The "How")

| Area | Requirement | Rationale |
| :--- | :--- | :--- |
| **Frontend** | Build using **Flutter/Dart**. Must support iOS and Android. | Cross-platform development speed and unified codebase. |
| **Backend** | **Supabase** (Postgres, Auth, Edge Functions) running via Docker locally. | Leverage existing knowledge and local development capability. |
| **API Layer** | Direct access via **PostgREST** (Supabase), secured by **Row Level Security (RLS)**. Minimal initial custom logic in **Edge Functions**. | Focus development on RLS and data schema first. Avoid building complex API services prematurely. |
| **Data Storage** | Use **PostGIS** for efficient spatial queries. | Essential for scalable "nearby points" functionality. |
| **Security** | All client-to-server interaction must use **JWT validation** and be governed by **RLS policies**. | Mandatory for any social application MVP. |
| **Scalability** | Initial schema must support a growth path towards complex graph queries and real-time features (via Supabase Realtime). | Ensure the core data model (e.g., PostGIS, normalized tables) supports future needs. |

