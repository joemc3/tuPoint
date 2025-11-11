A strong **Testing Strategy** is vital for tuPoint (tP.2), especially given the security (RLS) and location requirements. We will use the standard **Testing Pyramid** approach combined with specialized techniques for database and geolocation logic.

## 🧪 Testing Strategy

The strategy will be tiered: Unit $\to$ Widget $\to$ Integration $\to$ Database.

### 1. 🎯 Unit Tests (Focus: Business Logic)

These are fast, isolated tests that ensure individual functions and methods work correctly.

* **Target:** **Domain** and **Data** layer logic (e.g., Use Cases, Repositories).
* **Key Coverage Areas:**
    * **Maidenhead Calculation:** Test your custom function with diverse latitude/longitude inputs (coastal, landlocked, various hemispheres) to ensure the 6-character code is always accurate.
    * **Distance/Filtering Logic:** Test the Dart function that calculates distance (Haversine) and filters points. This is critical for the "View Nearby Points" feature. Use **mock data** for both user location and points list.
    * **Model Parsing:** Verify that JSON payloads from PostgREST map correctly to your immutable Dart **Models** (`Point`, `Profile`, `Like`).

### 2. 🧩 Widget Tests (Focus: UI Components)

These verify that individual Flutter widgets look and behave as expected in isolation.

* **Target:** `PointCard` widget, `DropButton`, `ProfileCreationForm`.
* **Key Coverage Areas:**
    * **UI Rendering:** Test that a `PointCard` correctly displays the `content`, `username`, and `like` count based on the data provided by a mock provider.
    * **User Interaction:** Verify that tapping the **Like button** triggers the correct event (e.g., calls a mock `LikesNotifier` method once).
    * **Conditional Display:** Ensure the **Profile Creation Screen** is shown when the `profileProvider` returns `null` (simulating a new user).

### 3. 📱 Integration Tests (Focus: End-to-End Flow)

These test large parts of the app, simulating full user flows on a device or emulator.

* **Target:** The full stack, including the live local Supabase instance.
* **Key Coverage Areas:**
    * **Sign-Up Flow:** Simulate sign-in, detect missing profile, input username, submit, and verify the `profile` is created in the database.
    * **Drop-a-Point Flow:** Log in $\to$ Navigate to drop screen $\to$ Input text $\to$ **Mock the GPS location** $\to$ Submit $\to$ Verify the point appears in the main feed.
    * **Like/Unlike Flow:** Log in $\to$ View a point $\to$ Click Like $\to$ Verify the like count increments in the feed and a record exists in the `likes` table.

### 4. 🗄️ Database & Security Testing (Supabase/Postgres)

This is the most specialized and critical layer for tuPoint's security model.

* **Method:** Use the **Supabase CLI's database testing feature** which leverages **pgTAP** (a PostgreSQL unit testing framework).
* **Key Coverage Areas:**
    * **RLS (Row Level Security) Enforcement:**
        * Test **`points` INSERT**: Attempt to insert a point with a `user_id` that does **not** match the simulated authenticated user's ID (`auth.uid()`). **Expected result: Failure/Denial.**
        * Test **`likes` DELETE**: Authenticate as User A. Try to delete a `like` record created by User B. **Expected result: Failure/Denial.**
        * Test **`profile` UPDATE**: Authenticate as User A. Try to change User B's `username`. **Expected result: Failure/Denial.**
    * **PostGIS & Indexes:** Verify that PostGIS is active and that your `geom` and `maidenhead_6char` columns have indexes to ensure query performance.

### 5. 🗺️ Geolocation Testing

Since the core feature relies on location, you need techniques to simulate movement.

* **Mocking:** Use **mock location libraries** (e.g., on Android/iOS emulators or device developer options) and **GPX/KML files** to simulate routes and fixed locations.
* **Scenarios:** Test the feed view by setting the mock location:
    * **Inside the $5\text{ km}$ boundary:** Verify points are displayed.
    * **Outside the $5\text{ km}$ boundary:** Verify points are correctly filtered and **not** displayed.
    * **At the $5\text{ km}$ exact edge:** Test inclusion/exclusion boundaries.

This video provides a crash course on the criticality of Row-Level Security when using Supabase, which is central to your application's security strategy. [A Crash Course In Row-Level Security (RLS) For FlutterFlow Users](https://www.youtube.com/watch?v=Fqre21bcxlo)
http://googleusercontent.com/youtube_content/10