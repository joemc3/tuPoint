# Flutter Hybrid Application: UI/UX Standards & Best Practices

## 1. Introduction

This document provides a comprehensive set of UI/UX standards and best practices for designing and developing hybrid applications with Flutter. The goal is to ensure a consistent, intuitive, accessible, and high-performance user experience across Android, iOS, and Web platforms, adapting gracefully to phones, tablets, and desktops.

---

## 2. Core Principles

These fundamental principles should guide all design and development decisions.

* **Platform Adaptability:** Strive for a consistent brand identity while respecting platform-specific conventions (Material Design for Android/Web, Cupertino for iOS). The UI should feel native, not like a web page in a container.
* **Responsive & Adaptive Design:** The user interface must fluidly adapt to a wide range of screen sizes, orientations, and input methods (touch, mouse, keyboard).
* **Performance First:** UI interactions, animations, and transitions must be smooth and jank-free. Prioritize performance to ensure a responsive feel, especially on lower-end devices.
* **Accessibility (A11y):** Design for everyone. Applications must be usable by people with disabilities, adhering to WCAG (Web Content Accessibility Guidelines).
* **Consistency:** A consistent design language (colors, typography, spacing, components) across the application reinforces the brand and improves usability by making the UI predictable.

---

## 3. Layout & Responsive Design

A robust responsive strategy is critical for a multi-platform application.

### 3.1. Breakpoints

Define layouts based on available screen width. Use these standard breakpoints to adapt the UI.

* **Small (Phone):** `< 600dp`
* **Medium (Tablet):** `600dp - 840dp`
* **Large (Desktop):** `> 840dp`

**Implementation:** Use `LayoutBuilder` and `MediaQuery.of(context).size.width` to determine the current breakpoint and render the appropriate layout.

### 3.2. Responsive Patterns by Device

#### **Phone (Portrait & Landscape)**
* **Layout:** Primarily single-column.
* **Navigation:** Use a `BottomNavigationBar` for primary, top-level destinations. For secondary screens, use the `AppBar` with a back button.
* **Landscape:** Avoid forcing portrait mode. Ensure layouts remain usable, often by making the single column scrollable. For data-heavy screens, consider a two-column view if content permits.

#### **Tablet (Portrait & Landscape)**
* **Layout:** Master-detail views, two or three-column grids, and dashboards.
* **Navigation:** A `NavigationRail` on the left side is ideal for saving vertical space and providing ergonomic navigation. A permanently visible `Drawer` can also be effective.
* **Content:** Use the extra space to reduce navigation depth, show more information at once (e.g., a list and a detail view side-by-side), and provide a richer user experience.

#### **Desktop (Web)**
* **Layout:** Multi-pane, complex grid layouts. Content should be centered with comfortable margins on very wide screens.
* **Navigation:** A persistent `NavigationRail` or `Drawer` on the left is standard. A top `AppBar` can be used for global actions, branding, and user profile management.
* **Interactions:** Support mouse and keyboard input.
    * Use `InkWell` or similar widgets to provide hover effects.
    * Implement keyboard shortcuts for common actions.
    * Manage focus with `FocusNode` for accessibility and intuitive keyboard navigation.
    * Always wrap scrollable content with the `Scrollbar` widget.

---

## 4. UI Components & Theming

Standardize all visual elements using Flutter's theming capabilities.

### 4.1. Theming

Define all styles within a `ThemeData` object to ensure app-wide consistency.

```dart
ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
  textTheme: //... your text theme,
  useMaterial3: true,
  // ... other theme properties
)
```

### 4.2. Spacing & Sizing

Use a base unit of **8dp** for all spacing, padding, and component dimensions. This creates a consistent visual rhythm.

  * **Padding/Margins:** Use multiples of 8 (e.g., 8, 16, 24, 32).
  * **Touch Targets:** Ensure all interactive elements have a minimum size of **48x48dp** on touch devices. Use `SizedBox` or `Padding` to enforce this.

### 4.3. Colors

Define a strict color palette in `ThemeData.colorScheme`.

  * **`primary`**: The primary brand color.
  * **`secondary`**: The secondary brand or accent color.
  * **`surface`**: Background color for components like `Card`, `BottomSheet`.
  * **`background`**: The app's main background color.
  * **`error`**: For indicating errors in input fields, etc.
  * **`onPrimary`, `onSecondary`, etc.**: Colors for text and icons placed on top of their corresponding color key.

### 4.4. Typography

Define a clear typographic scale in `ThemeData.textTheme`.

  * **Font:** Use a cross-platform friendly font or a specific brand font.
  * **Scale:** Define styles for headlines, subtitles, body text, buttons, and captions (e.g., `headlineLarge`, `bodyMedium`).
  * **Implementation:** Always use `Theme.of(context).textTheme.bodyLarge` instead of hard-coding `TextStyle`. This ensures consistency and supports dynamic type scaling.

### 4.5. Iconography

  * **Library:** Use a single, consistent icon library (e.g., Flutter's built-in `Icons`, `CupertinoIcons`, or a third-party pack like FontAwesome).
  * **Style:** Icons should share a consistent style (e.g., all outlined or all filled).
  * **Semantics:** Every `IconButton` must have a `tooltip` that acts as its semantic label for accessibility.

### 4.6. Common Widgets

  * **Buttons:** Use `ElevatedButton` for primary actions, `TextButton` for secondary actions, and `OutlinedButton` for tertiary actions. Ensure they have clear hover, pressed, and disabled states.
  * **Cards:** Use the `Card` widget to group related content. Standardize its elevation, border radius (`shape`), and margins.
  * **Input Fields:** Use `TextFormField` with a `InputDecoration` theme. Always provide clear labels, helper text, and validation error messages.

-----

## 5\. Platform-Specific Considerations

### 5.1. Scrolling Physics

Use platform-appropriate scroll physics to feel native.

  * **iOS:** `BouncingScrollPhysics()`
  * **Android/Web:** `ClampingScrollPhysics()`

You can set this app-wide in your `MaterialApp` theme:

```dart
MaterialApp(
  theme: ThemeData(
    platform: TargetPlatform.iOS, // This will default physics and more
  ),
)
```

### 5.2. Safe Area

Always wrap screen-level layouts with the `SafeArea` widget. This prevents your UI from being obscured by system elements like notches, status bars, or navigation gestures.

### 5.3. Dialogs and Alerts

Use platform-adaptive dialogs where appropriate.

  * `showDialog` for Material-style alerts.
  * `showCupertinoDialog` for iOS-style alerts.
  * Consider creating a helper function that shows the correct dialog based on `Theme.of(context).platform`.

-----

## 6\. Accessibility (A11y)

  * **Semantic Labels:** Provide descriptive labels for all non-text widgets using the `Semantics` widget or the `tooltip` property on widgets like `IconButton`.
  * **Color Contrast:** Ensure text and interactive elements meet a minimum contrast ratio of 4.5:1 against their background (WCAG AA).
  * **Dynamic Type:** Test your app with larger font sizes to ensure layouts do not break. Use `Text.textScaler` to respect system font size settings.
  * **Focus Management:** Ensure a logical focus order for keyboard and screen reader navigation, especially in complex forms and layouts.

-----

## 7\. UI State Management

The UI must always reflect the current application state.

  * **Loading State:** When data is being fetched, display a loading indicator like `CircularProgressIndicator` or a shimmer effect. Avoid blank screens.
  * **Empty State:** When a list or content area is empty, display a helpful message, an icon, and optionally a call-to-action (e.g., "You have no messages. Start a new conversation\!").
  * **Error State:** If an error occurs (e.g., network failure), display a user-friendly error message with an option to retry the action. Avoid showing raw error codes or exceptions.
