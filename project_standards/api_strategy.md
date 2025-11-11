## 🌐 API Strategy: PostgREST Interaction

The API strategy for tuPoint (tP.2) will rely on **Supabase's PostgREST**, which automatically turns your database tables into a RESTful API. This approach is highly efficient for an MVP, as it requires minimal custom backend code.

### 1\. **Authentication**

All API calls must include a **JWT** in the `Authorization` header, obtained after the user logs in via the Supabase client. The **Row Level Security (RLS)** policies defined in the schema document will automatically enforce access control based on this token.

-----

### 2\. **Create a Point** (The `INSERT` Operation)

This is a simple, authenticated **HTTP POST** request from the Flutter client to the `points` table endpoint.

  * **Endpoint:** `[Supabase URL]/rest/v1/points`
  * **Method:** `POST`
  * **Headers:**
      * `Authorization: Bearer [JWT]`
      * `Content-Type: application/json`
      * `Prefer: return=minimal` (Optional: Tells the API not to return the inserted record, speeding up the response).
  * **Body (JSON Payload):**
    The client sends the required data. The `user_id` must match the authenticated user's ID for the RLS policy to pass.

<!-- end list -->

```json
{
  "user_id": "[Authenticated User ID]",
  "content": "Just dropped a point!",
  "maidenhead_6char": "FN20sa",
  "geom": "SRID=4326;POINT(-79.866 32.855)"
}
```

  * **Success Response:** HTTP Status **201 Created**.

-----

### 3\. **View Nearby Points** (The `SELECT` Operation)

The client performs a simple `SELECT` to fetch **all active points**, as the geographical filtering is handled client-side.

  * **Endpoint:** `[Supabase URL]/rest/v1/points`
  * **Method:** `GET`
  * **Headers:**
      * `Authorization: Bearer [JWT]`
  * **Query Parameters (Filtering):**
    We can add a basic server-side filter to only return active records, ensuring the RLS policy passes.

<!-- end list -->

```
?select=*&is_active=eq.true
```

  * **Flutter Client Logic:**
    1.  Receive the entire payload of active points (an array of JSON objects).
    2.  Use the user's current precise location and the **PostGIS `geom`** data from each returned point to calculate the distance (Haversine formula).
    3.  Filter and display only those points within the $5\text{ km}$ threshold.

-----

### 4\. **Like a Point** (The `INSERT` Operation)

This operation adds a record to the `likes` table.

  * **Endpoint:** `[Supabase URL]/rest/v1/likes`
  * **Method:** `POST`
  * **Headers:** Standard authenticated headers.
  * **Body (JSON Payload):**

<!-- end list -->

```json
{
  "user_id": "[Authenticated User ID]",
  "point_id": "[ID of the point being liked]"
}
```

-----

### 5\. **Un-Like a Point** (The `DELETE` Operation)

This operation removes a record from the `likes` table.

  * **Endpoint:** `[Supabase URL]/rest/v1/likes`
  * **Method:** `DELETE`
  * **Headers:** Standard authenticated headers.
  * **Query Parameters (Filtering):**
    We must use filters to ensure only the single, correct like record is deleted, and the RLS policy will ensure the authenticated user is the owner of that record.

<!-- end list -->

```
?point_id=eq.[ID of the point]&user_id=eq.[Authenticated User ID]
```
