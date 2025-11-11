## 📄 tuPoint (tP.2) Data Schema Document

This document compiles the **Data Model, Relationships, and RLS Policies** for the Minimum Viable Product of tuPoint.

### 1. **Core Tables and Relationships**



| Table Name | Purpose | Key Relationships |
| :--- | :--- | :--- |
| **`auth.users`** | Supabase managed authentication records (external to public schema). | 1:1 with `profile`, 1:N with `points`, M:N with `points` via `likes`. |
| **`profile`** | User metadata (username, bio). | 1:1 Foreign Key (`id`) to `auth.users.id`. |
| **`points`** | Location-specific posts/content. | N:1 Foreign Key (`user_id`) to `auth.users.id`. |
| **`likes`** | Records social interactions (who liked what). | N:1 Foreign Key (`user_id`) to `auth.users.id`. N:1 Foreign Key (`point_id`) to `points.id`. |

### 2. **Detailed Table Specifications**

#### A. `profile` Table

| Field Name | Data Type | Constraints / Description |
| :--- | :--- | :--- |
| **`id`** | `uuid` | **Primary Key** & **Foreign Key** to `auth.users.id`. **NOT NULL** |
| **`username`** | `text` | **NOT NULL**. **Unique**. |
| **`bio`** | `text` | **NULLABLE**. |
| **`created_at`** | `timestamptz` | **NOT NULL** (Default: `now()`). |
| **`updated_at`** | `timestamptz` | **NULLABLE**. |

#### B. `points` Table

| Field Name | Data Type | Constraints / Description |
| :--- | :--- | :--- |
| **`id`** | `uuid` | **Primary Key** |
| **`user_id`** | `uuid` | **Foreign Key** to `auth.users.id`. **NOT NULL** |
| **`content`** | `text` | **NOT NULL** (Max 280 characters). |
| **`created_at`** | `timestamptz` | **NOT NULL** (Default: `now()`). |
| **`geom`** | `geometry(Point, 4326)` | **NOT NULL**. PostGIS index required. |
| **`maidenhead_6char`**| `text` | **NOT NULL**. Index required. |
| **`is_active`** | `boolean` | Default: `TRUE` (Soft-delete flag). |

#### C. `likes` Table

| Field Name | Data Type | Constraints / Description |
| :--- | :--- | :--- |
| **`point_id`** | `uuid` | **Foreign Key** to `points.id`. **NOT NULL** |
| **`user_id`** | `uuid` | **Foreign Key** to `auth.users.id`. **NOT NULL** |
| **`created_at`** | `timestamptz` | **NOT NULL** (Default: `now()`). |
| **Unique Constraint** | (N/A) | Composite key on (`point_id`, `user_id`). |

### 3. **Row Level Security (RLS) Policies**

| Table | Action | Target Role | Condition (`USING`/`WITH CHECK`) | Effect / Rationale |
| :--- | :--- | :--- | :--- | :--- |
| **`profile`** | `INSERT` | `authenticated` | `auth.uid() = id` | Allows a user to create their initial profile upon sign-up. |
| **`profile`** | `SELECT` | `authenticated` | `TRUE` | Allows viewing of all public profiles (usernames, bios). |
| **`profile`** | `UPDATE` | `authenticated` | `auth.uid() = id` | Allows a user to update only their own profile. |
| **`points`** | `INSERT` | `authenticated` | `auth.uid() = user_id` | User can only create points associated with their ID. |
| **`points`** | `SELECT` | `authenticated` | `is_active = TRUE` | Allows viewing of all active points (client handles geo-filtering). |
| **`points`** | `UPDATE/DELETE` | `authenticated` | `auth.uid() = user_id` | Users can only modify/soft-delete their own points. |
| **`likes`** | `INSERT` | `authenticated` | `auth.uid() = user_id` | Allows a user to record their own "Like" action. |
| **`likes`** | `SELECT` | `authenticated` | `TRUE` | Allows users to read all likes (for counting and self-check). |
| **`likes`** | `DELETE` | `authenticated` | `auth.uid() = user_id` | Allows a user to remove (un-like) their own recorded action. |

