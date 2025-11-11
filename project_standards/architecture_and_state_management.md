## 🏗️ Flutter Architecture and State Management

Given your goal of native iOS/Android/Web support and your experienced background, adopting a modern, scalable Flutter architecture is crucial for **tuPoint** (tP.2). We will structure the application using the **Clean Architecture** principles, separating presentation logic from data access, and utilize the **Riverpod** package for robust state management.

### 1. Application Structure (Clean Architecture)

We'll divide the app into three main layers to keep the code organized, testable, and maintainable:

| Layer | Purpose | Key Components |
| :--- | :--- | :--- |
| **Presentation** | Handles the UI, user interaction, and state changes. | Widgets, Views/Pages, Riverpod Providers (`Notifier`s). |
| **Domain** | Contains core business logic, models, and interfaces. Should be technology-agnostic. | **Models** (e.g., `Point`, `Profile`), **Use Cases** (e.g., `DropPointUseCase`), **Repositories** (Interfaces). |
| **Data** | Implements the interfaces defined in the Domain layer, handling external data sources. | **Repositories** (Implementation), **Data Sources** (e.g., `SupabaseClient`), **DTOs** (Data Transfer Objects). |

### 2. State Management: Riverpod

**Riverpod** is the recommended state management solution for complex Flutter apps as it addresses many limitations of Provider and is highly testable.

| Riverpod Component | Purpose in tuPoint (tP.2) | Example State |
| :--- | :--- | :--- |
| **`Provider`** | For read-only, immutable values (e.g., instances of Repositories). | `final pointsRepositoryProvider = Provider(...)` |
| **`StateNotifier` & `StateNotifierProvider`** | **Primary choice for business logic.** Handles complex, mutable state and logic (e.g., fetching data, filtering). | `PointsNotifier` |
| **`FutureProvider`** | For handling asynchronous operations and providing loading/error states directly to the UI. | `nearbyPointsFutureProvider` |

---

### 3. Key Data Flows and Providers

#### A. Authentication and Profile Flow

This handles the conditional profile creation logic.

* **`authProvider` (StateNotifier):** Manages the user's login state (Logged In, Logged Out, Loading) and handles the Supabase sign-in/out calls.
* **`profileProvider` (FutureProvider):** Fetches the user's `profile` data immediately after successful authentication. If the result is `null`, the UI knows to navigate to the **Profile Creation Screen**.

#### B. Point Drop Flow

1.  **UI:** User enters text.
2.  **UI:** Gets precise location ($\text{lat}/\text{lon}$) and calculates the **Maidenhead** code.
3.  **UI:** Calls method on `PointDropNotifier`.
4.  **`PointDropNotifier` (StateNotifier):** Calls the `PointsRepository.createPoint()` method.
5.  **`PointsRepository`:** Uses `SupabaseClient` to execute the **PostgREST POST** to the `/points` endpoint.

#### C. Feed View and Client-Side Filtering Flow

This is the most complex part of the MVP and uses a chain of Riverpod providers.

1.  **`allActivePointsFutureProvider` (FutureProvider):**
    * Calls `PointsRepository.fetchAllActive()`.
    * Performs the authenticated **PostgREST GET** to `/points?is_active=eq.true`.
    * Provides the raw list of all points (with loading/error states).

2.  **`currentLocationProvider` (StreamProvider/Notifier):**
    * Monitors the user's current geographic location in real-time (using the Flutter `geolocator` package).
    * Provides the latest $\text{lat}/\text{lon}$ data.

3.  **`nearbyPointsProvider` (Provider):**
    * **Watches** (`ref.watch`) the output of both `allActivePointsFutureProvider` and `currentLocationProvider`.
    * When either source updates, it triggers the **client-side filter logic**:
        * Iterates through the list of all active points.
        * Calculates the distance (using the Haversine formula on the $\text{geom}$ data).
        * Returns a filtered list of points within the $5\text{ km}$ radius.

This setup ensures the feed updates automatically whenever the user moves or a new point is created (if combined with Supabase Realtime in the future).
