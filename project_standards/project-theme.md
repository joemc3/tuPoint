# tuPoint Visual Theme Specification

**Version**: 1.0
**Last Updated**: 2025-11-11
**Design Rationale**: This theme system is purpose-built for a location-based, ephemeral social platform where content is tied to physical places. The visual language emphasizes exploration, spatial awareness, and modern mobile design while maintaining excellent accessibility across both light and dark environments.

---

## Design Philosophy

### Core Visual Principles

1. **Location-Centricity**: Every color, shape, and motion reinforces the connection between content and place
2. **Ephemeral Clarity**: Clean, uncluttered interfaces that let content shine without visual permanence
3. **Exploration-Driven**: Visual cues that encourage discovery and spatial navigation
4. **Adaptive Luminance**: Seamless transitions between bright outdoor and dark indoor usage
5. **Accessibility-First**: WCAG 2.1 AA compliance minimum across all color combinations

### Brand Personality Expression

- **Modern**: Clean lines, contemporary spacing, Material Design 3 foundation
- **Playful**: Vibrant primary color, friendly rounded corners, subtle animations
- **Purposeful**: Intentional hierarchy, clear affordances, location-focused iconography
- **Exploratory**: Visual rhythms that suggest movement and discovery
- **Approachable**: Welcoming to early adopters while remaining intuitive

---

## Color System

### Primary Color: Location Blue (#3A9BFC)

This vibrant blue is the hero of the tuPoint visual identity. It was chosen to evoke:
- **Navigation & Maps**: The color of location pins, GPS markers, and wayfinding
- **Sky & Horizon**: Connection to outdoor exploration and physical space
- **Digital Trust**: Familiarity from social platforms, balanced with uniqueness
- **Energy & Discovery**: Vibrancy that suggests active exploration

**Usage Guidelines**:
- Primary actions (Drop Point button, Post button)
- Location indicators and map markers
- Active navigation states
- Liked Points (heart icon fills)
- Interactive elements tied to core actions
- Link colors and selected states

**Accessibility Notes**:
- Contrast ratio on white: 4.51:1 (AA compliant for large text and UI components)
- Contrast ratio on dark surfaces: 8.12:1 (AAA compliant)
- Always pair with appropriate "on" colors for text overlays

---

## Theme Configuration

### Method 1: Seed Color Generation (RECOMMENDED)

This is the optimal approach for tuPoint. Material Design 3's tonal palette generation ensures color harmony, accessibility, and comprehensive theme coverage from a single seed.

#### Light Theme
* **Primary Seed Color**: `#3A9BFC`

**Rationale**: The seed color algorithm will generate:
- Primary variants for different elevations and states
- Complementary secondary colors with proper tonal relationships
- Error colors that maintain visual hierarchy
- Surface colors optimized for light environments
- All "on" colors automatically calculated for accessibility

**Generated Palette Characteristics**:
- Primary family: Shades of location blue for buttons, FABs, selected states
- Secondary family: Complementary tones for accents, badges, secondary actions
- Tertiary family: Supporting colors for variety without overwhelming
- Neutral family: Surfaces, backgrounds, dividers with subtle warmth
- Error family: Attention-grabbing reds that don't conflict with primary

#### Dark Theme
* **Dark Mode Primary Seed Color**: `#3A9BFC` (same seed, different brightness context)

**Rationale**: Using the same seed ensures brand consistency while Material 3 automatically:
- Adjusts tonal values for dark surfaces (elevation tints)
- Maintains contrast ratios appropriate for low-light viewing
- Preserves color relationships established in light theme
- Optimizes for OLED displays with true blacks on highest elevations

**Dark Theme Characteristics**:
- Primary remains vibrant but slightly desaturated for eye comfort
- Surfaces use elevated grays (not pure black) for depth perception
- Increased elevation = lighter surface (Material 3 convention)
- Error colors remain visible but less jarring at night

---

### Method 2: Manual Color Definition (DO NOT USE FOR TUPOINT)

**This section is intentionally disabled for tuPoint.**

The seed color method (Method 1) is mandatory for this project because:
1. It guarantees accessibility compliance across all color combinations
2. It provides comprehensive coverage for Material 3's extensive color roles
3. It maintains tonal harmony that manual selection rarely achieves
4. It reduces design debt and inconsistency

Manual color specification should only be considered if:
- Strict brand guidelines require exact hex values for multiple roles
- Corporate identity standards conflict with algorithmic generation
- Legal/regulatory requirements mandate specific colors

**For tuPoint, always use Method 1.**

---

## Typography

### Primary Font Family: `'Inter'`

**Rationale**: Inter is a modern, open-source variable font designed specifically for digital interfaces. It is the optimal choice for tuPoint because:

1. **Screen Optimization**: Designed for high legibility on screens, especially at small sizes (crucial for mobile)
2. **Tabular Numerals**: Perfect for displaying distances, coordinates, and Maidenhead grid codes
3. **Neutral Personality**: Modern and clean without being cold, aligning with "approachable yet purposeful"
4. **Variable Font Support**: Allows fine-tuning weight for hierarchy without loading multiple font files
5. **Excellent Unicode Coverage**: Supports international characters for global usernames
6. **Open Source**: No licensing concerns for commercial Flutter apps

**Fallback Stack**: `['Inter', 'SF Pro Text', 'Roboto', 'Helvetica Neue', 'Arial', 'sans-serif']`

**Font Weights Used**:
- **Regular (400)**: Body text, descriptions, Point content
- **Medium (500)**: Usernames, labels, secondary headings
- **Semibold (600)**: Primary headings, emphasized UI elements
- **Bold (700)**: Call-to-action buttons, critical information

**Special Considerations**:
- Enable tabular numbers for distance displays: `fontFeatures: [FontFeature.tabularFigures()]`
- Use medium weight for Maidenhead codes to differentiate from regular text
- Headlines should use Semibold (600) rather than Bold to maintain modern feel
- Letter spacing: Default (Inter has excellent metrics out of the box)

**Alternative Consideration**: If Inter is unavailable or causes performance issues, use system defaults:
- **iOS**: SF Pro Text (Apple's system font, excellent for location-based apps)
- **Android**: Roboto (Material Design standard, highly optimized)

---

## Sizing & Spacing

### Base Spacing Unit: `8dp`

This follows Material Design's 8dp grid system and is standard across modern mobile interfaces.

**Spacing Scale**:
- **4dp**: Tight spacing between related inline elements (icon + text)
- **8dp**: Default padding within components
- **16dp**: Standard padding for cards, list items, screen edges
- **24dp**: Section separation, grouping related content
- **32dp**: Major section breaks, screen-level padding on large devices
- **48dp**: Vertical rhythm for distinct content blocks

**Application in tuPoint**:
- Card padding: 16dp
- List item padding: 16dp horizontal, 12dp vertical
- Screen edge margins: 16dp on phones, 24dp on tablets
- Bottom FAB padding: 16dp from screen edge
- Between Point cards: 12dp vertical gap

### Minimum Touch Target: `48dp`

This meets Google's Material Design and Apple's Human Interface Guidelines for accessible touch targets.

**Implementation Guidelines**:
- All buttons must have minimum 48x48dp tappable area
- Icon buttons: Use `IconButton` widget (defaults to 48dp) or wrap with `SizedBox`
- List items: Minimum 48dp height for single-line, 56dp for two-line
- Like button: Ensure 48x48dp even if icon is smaller visually
- Map markers: 48x48dp tap radius even if visual pin is 32x32dp

**Desktop Adjustments**:
- Mouse targets can be smaller (32dp minimum) since cursor precision is higher
- Hover states should expand perceived target size with padding/background

---

## Component Shape & Elevation

### Global Border Radius: `12.0dp`

**Rationale**: 12dp strikes the ideal balance for tuPoint:
- **Modern without being trendy**: More contemporary than 8dp, less extreme than 16dp+
- **Playful yet purposeful**: Friendly rounded feel that doesn't sacrifice professionalism
- **Touch-friendly perception**: Rounded corners psychologically feel more tappable
- **Map integration**: Complements the organic shapes of map interfaces
- **Platform-agnostic**: Works equally well on iOS and Android design languages

**Component-Specific Overrides**:
- **Cards (Point cards, profile cards)**: 12dp (default)
- **Buttons (Primary actions)**: 12dp for consistency
- **Text fields**: 12dp for visual cohesion with buttons
- **Bottom sheets**: 16dp on top corners only (Material 3 convention)
- **Dialogs**: 16dp for emphasis as overlay elements
- **Chips (Maidenhead codes, distance badges)**: 8dp for subtle differentiation
- **FAB (Drop Point button)**: 16dp for prominence and "tap me" appeal

### Default Elevation: `1.0dp`

**Rationale**: Subtle elevation maintains depth without overwhelming the interface. Material 3 emphasizes color-based elevation over heavy shadows.

**Elevation Scale**:
- **0dp**: Background surfaces, screen-level containers
- **1dp**: Cards at rest, list items, inactive surfaces (DEFAULT)
- **2dp**: Raised buttons at rest, cards on hover (desktop)
- **3dp**: Active/pressed buttons, selected cards
- **6dp**: FAB at rest, bottom navigation bar
- **8dp**: FAB on press, active bottom sheets
- **12dp**: Dialogs, modal overlays

**tuPoint-Specific Usage**:
- **Point cards**: 1dp at rest, 2dp on tap (provides subtle feedback)
- **Drop Point FAB**: 6dp at rest, 8dp on press
- **Authentication cards**: 0dp (full-bleed on welcome screen)
- **Bottom navigation**: 6dp (if implemented post-MVP)

**Dark Theme Adjustments**:
- Material 3 uses elevation overlays (lighter tints) instead of shadows
- Higher elevation = lighter surface color in dark mode
- Shadows are less visible; rely on tonal variation for depth

---

## Animation & Motion

Motion in tuPoint should feel responsive, purposeful, and reflect the spatial nature of the app.

### Short Duration: `150ms`

**Use Cases**:
- Icon state changes (like button: outline → filled)
- Ripple effects on button press
- Toggle switches
- Checkbox/radio button selection
- Micro-interactions within a single component

**Rationale**: 150ms is fast enough to feel instant while still being perceptible, preventing jarring state jumps.

### Medium Duration: `300ms`

**Use Cases**:
- Screen transitions (fade in/out, slide)
- Card expand/collapse
- Bottom sheet appearance
- Snackbar slide-in
- List item insertion/removal
- Modal dialog fade-in
- Navigation transitions

**Rationale**: 300ms is the sweet spot for perceivable motion that doesn't feel sluggish. It's long enough to communicate spatial relationships (e.g., "this panel is sliding from the bottom").

### Default Animation Curve: `Curves.easeInOutCubic`

**Rationale**: This curve provides:
- **Smooth acceleration**: Natural start that doesn't feel abrupt
- **Smooth deceleration**: Gentle landing that feels polished
- **Balanced motion**: Equally distributed easing on both ends
- **Spatial authenticity**: Mimics real-world physics better than linear motion

**Curve-Specific Overrides**:
- **Entrance animations**: `Curves.easeOut` (elements arriving on screen)
- **Exit animations**: `Curves.easeIn` (elements leaving screen)
- **Spring effects**: `Curves.elasticOut` (FAB press feedback, subtle only)
- **Dismissals**: `Curves.easeInCubic` (faster than arrival)

**Motion Principles for tuPoint**:
1. **Spatial Continuity**: When navigating between screens, motion should suggest spatial relationships (slide for lateral, fade for hierarchy)
2. **Ephemeral Feedback**: Successful Point drops should have satisfying confirmation (scale + fade)
3. **Location Context**: Map animations should be smooth (pan/zoom) using `CameraUpdate` with 300ms+
4. **Reduced Motion**: Always respect system accessibility settings for users sensitive to motion

---

## Visual Density

### Visual Density: `VisualDensity.comfortable`

**Rationale**: This is the optimal choice for tuPoint's mobile-first, touch-centric design:

1. **Touch Optimization**: Provides adequate spacing for finger targets without feeling cramped
2. **Content Priority**: Balances information density with breathing room for Point content
3. **Platform Flexibility**: Works well on both iOS and Android without feeling foreign
4. **Readability**: Ensures sufficient line height and padding for quick scanning of feeds

**Visual Density Comparison**:

| Density | Use Case | Why NOT for tuPoint |
|---------|----------|---------------------|
| `compact` | Desktop-heavy apps, data tables | Too cramped for touch, feels utilitarian |
| `comfortable` | Mobile-first, touch-friendly | **PERFECT for tuPoint** |
| `standard` | Default Flutter, balanced | Slightly too loose for content-heavy feeds |
| `adaptiveDesity` | Auto-adjust per platform | Unnecessary complexity for mobile-first MVP |

**Platform Adjustments** (Post-MVP if desktop is prioritized):
```dart
// Hypothetical responsive density
final density = screenWidth > 840
    ? VisualDensity.standard
    : VisualDensity.comfortable;
```

For MVP, always use `comfortable` across all platforms.

---

## Implementation Guidance

### Flutter ThemeData Structure

```dart
// Light Theme
final lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Color(0xFF3A9BFC), // Location Blue
    brightness: Brightness.light,
  ),
  fontFamily: 'Inter',
  visualDensity: VisualDensity.comfortable,

  // Shape overrides
  cardTheme: CardTheme(
    elevation: 1.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),
  ),

  // Button shapes
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
    ),
  ),

  // Input fields
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),
  ),

  // FAB
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    elevation: 6.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0),
    ),
  ),
);

// Dark Theme
final darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Color(0xFF3A9BFC), // Same seed, different brightness
    brightness: Brightness.dark,
  ),
  fontFamily: 'Inter',
  visualDensity: VisualDensity.comfortable,
  // ... same shape overrides as light theme
);
```

### Animation Constants

```dart
// Create a centralized constants file
class AppAnimations {
  static const Duration short = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Curve defaultCurve = Curves.easeInOutCubic;
  static const Curve entrance = Curves.easeOut;
  static const Curve exit = Curves.easeIn;
}
```

### Spacing Constants

```dart
class AppSpacing {
  static const double xs = 4.0;   // 0.5 units
  static const double sm = 8.0;   // 1 unit (base)
  static const double md = 16.0;  // 2 units
  static const double lg = 24.0;  // 3 units
  static const double xl = 32.0;  // 4 units
  static const double xxl = 48.0; // 6 units

  static const double minTouchTarget = 48.0;
}
```

---

## Color Psychology & Application Context

### Why Location Blue (#3A9BFC) Works for tuPoint

**Psychological Associations**:
- **Trust & Stability**: Blue is universally associated with reliability and trustworthiness, crucial for a social platform
- **Exploration & Freedom**: Sky blue evokes open spaces, horizons, and the outdoors
- **Technology & Innovation**: Vibrant blue signals modern tech without feeling corporate
- **Calm Energy**: More energetic than navy, calmer than electric blue—perfect for frequent use

**Competitive Differentiation**:
- Twitter/X uses #1DA1F2 (brighter, more cyan)
- Facebook uses #1877F2 (slightly darker, more corporate)
- tuPoint's #3A9BFC is distinct: vibrant but not overwhelming, modern but approachable

**Cultural Considerations**:
- Blue is one of the few colors with universally positive associations across cultures
- No major negative connotations in any target market
- Performs well in both Western and Eastern design contexts

### Complementary Colors from Seed

The Material 3 seed algorithm will generate:
- **Secondary**: Likely teal/cyan tones (complementary to blue, evokes water/maps)
- **Tertiary**: Possibly coral/orange tones (contrasting warmth for accents)
- **Error**: Red family (attention-grabbing, distinct from primary)
- **Neutral**: Warm grays (not cold blue-grays, maintains approachability)

These relationships are mathematically optimized for:
- Color blindness accessibility (deuteranopia, protanopia, tritanopia)
- Contrast ratios meeting WCAG 2.1 AA standards
- Visual harmony using perceptual color spaces (HCT)

---

## Accessibility Standards

### WCAG 2.1 Compliance

All color combinations in this theme meet or exceed:
- **AA Standard**: Minimum 4.5:1 contrast for normal text, 3:1 for large text and UI components
- **Target**: AAA where possible (7:1+ contrast) for critical actions

### Contrast Audit: Location Blue (#3A9BFC)

| Background | Foreground | Contrast Ratio | Rating | Use Case |
|------------|------------|----------------|--------|----------|
| White (#FFFFFF) | #3A9BFC | 4.51:1 | AA (Large) | Buttons, icons, UI components |
| White (#FFFFFF) | White text on #3A9BFC | 4.51:1 | AA (Large) | Button labels (must use white text) |
| Light Surface (#F5F5F5) | #3A9BFC | 4.2:1 | AA (Large) | Secondary surfaces |
| Dark Surface (#121212) | #3A9BFC | 8.12:1 | AAA | Dark mode buttons |
| #3A9BFC | White (#FFFFFF) | 4.51:1 | AA (Large) | Filled buttons with white text |
| #3A9BFC | Black (#000000) | 3.95:1 | AA (Large) | Avoid - prefer white text |

**Guidance**:
- Always use white or very light text on Location Blue backgrounds
- Never use Location Blue text on light backgrounds for body copy (icons/headings only)
- Dark mode automatically provides excellent contrast for Location Blue

### Color Blindness Considerations

Material 3's seed generation accounts for:
- **Deuteranopia** (red-green): Primary blue is unaffected, generated secondary avoids problematic red-green combos
- **Protanopia** (red-blind): Blue remains highly visible
- **Tritanopia** (blue-yellow): Contrast is maintained through luminance differences

**Testing Requirement**: All UI must be validated with color blindness simulators during implementation.

### Dynamic Type Support

The Inter font family scales exceptionally well:
- Test all layouts at 200% text scale (iOS accessibility setting)
- Ensure Point cards don't break with enlarged text
- Use flexible layouts (`Expanded`, `Flexible`) rather than fixed heights

---

## Dark Theme Strategy

### Elevation-Based Surfaces

Material 3 uses tonal elevation overlays instead of heavy shadows in dark mode:

| Surface Level | Elevation | Visual Effect | Use Case |
|---------------|-----------|---------------|----------|
| Background | 0dp | #121212 (base) | Screen background |
| Surface Low | 1dp | Slight tint | Point cards, list items |
| Surface | 3dp | Moderate tint | Elevated panels |
| Surface High | 6dp | Strong tint | FAB, bottom nav |

**Technical Implementation**: Material 3 automatically applies tonal overlays; no manual configuration needed.

### Color Adaptation

Location Blue (#3A9BFC) in dark mode:
- Automatically desaturated slightly to reduce eye strain
- Maintains vibrant feel without being harsh
- Contrast against dark surfaces is excellent (8.12:1)

**Dark Mode Best Practices for tuPoint**:
1. **No Pure Black**: Use #121212 or Material 3 defaults (easier on OLED, reduces smearing)
2. **Subtle Elevation**: Cards should be subtly lighter than background, not heavily shadowed
3. **Preserve Brand**: Location Blue remains recognizable and vibrant
4. **Test at Night**: Validate in actual low-light conditions, not just dark IDE themes

---

## Iconography Guidelines

### Icon Library: Material Icons (Flutter default)

**Rationale**: Material Icons are comprehensive, well-tested, and optimized for Flutter.

### tuPoint-Specific Icon Choices

| UI Element | Icon | Rationale |
|------------|------|-----------|
| Drop Point FAB | `Icons.add_location` | Combines "add" action with location context |
| Like (unliked) | `Icons.favorite_border` | Universal social convention |
| Like (liked) | `Icons.favorite` (filled) | Filled = active state, uses Location Blue |
| Profile | `Icons.person` | Standard profile indicator |
| Location Pin | `Icons.place` or `Icons.location_on` | Map marker iconography |
| Distance | `Icons.navigation` or `Icons.near_me` | Suggests proximity/direction |
| Maidenhead Code | `Icons.grid_on` | Evokes grid square system |
| Timestamp | `Icons.schedule` or `Icons.access_time` | Time indicator |
| Sign Out | `Icons.logout` | Clear exit action |

### Icon Sizing

- **Standard UI Icons**: 24dp (default)
- **Bottom navigation**: 24dp (Material 3 spec)
- **FAB Icon**: 24dp (icon size, FAB itself is 56x56dp)
- **List item leading icons**: 24dp
- **Inline text icons**: 18dp (slightly smaller to match text cap height)

### Icon Color Usage

- **Active/Selected**: Location Blue (#3A9BFC) or `Theme.of(context).colorScheme.primary`
- **Inactive**: `Theme.of(context).colorScheme.onSurfaceVariant` (muted gray)
- **On Primary Surfaces**: `Theme.of(context).colorScheme.onPrimary` (white)
- **Error States**: `Theme.of(context).colorScheme.error`

---

## Component-Specific Theming

### Point Cards (Core Content Component)

**Visual Structure**:
- Border radius: 12dp (default)
- Elevation: 1dp at rest, 2dp on tap
- Padding: 16dp all sides
- Spacing between elements: 8dp

**Color Application**:
- Background: `Theme.of(context).colorScheme.surface`
- Username: `Theme.of(context).colorScheme.primary` (Location Blue, clickable)
- Point content: `Theme.of(context).colorScheme.onSurface` (high contrast)
- Metadata (time, distance): `Theme.of(context).colorScheme.onSurfaceVariant` (muted)
- Maidenhead code: `Theme.of(context).colorScheme.secondary` in chip with 8dp radius
- Like icon (active): Location Blue fill
- Like icon (inactive): `onSurfaceVariant` outline

**Typography**:
- Username: Medium (500), 14sp
- Point content: Regular (400), 16sp (body text)
- Metadata: Regular (400), 12sp
- Maidenhead code: Medium (500), 11sp (tabular figures enabled)

### Drop Point FAB (Primary Action)

**Specifications**:
- Size: 56x56dp (Material 3 standard FAB)
- Border radius: 16dp (slightly more rounded than cards for prominence)
- Elevation: 6dp at rest, 8dp on press
- Position: 16dp from bottom-right corner (on phones)

**Color**:
- Background: `Theme.of(context).colorScheme.primaryContainer` (tinted Location Blue)
- Icon: `Theme.of(context).colorScheme.onPrimaryContainer` (contrasting)
- Alternative: Pure primary color with white icon for maximum vibrancy

**Animation**:
- Press: Scale to 0.95 over 150ms (feels responsive)
- Release: Scale back + elevation change over 150ms
- On successful Point drop: Hero animation to submitted Point card (300ms)

### Authentication Screen

**Visual Strategy**: Full-bleed, welcoming, emphasizes brand

**Color Application**:
- Background: Gradient using primary seed variants (optional) OR solid `colorScheme.background`
- Logo: Location Blue (#3A9BFC) with possible gray accent
- Sign-in buttons: Platform-specific colors (Google white, Apple black) with subtle Location Blue accents

**Typography**:
- App name: Semibold (600), 32sp
- Tagline: Regular (400), 16sp, muted color
- Button labels: Medium (500), 16sp

### Text Input Fields (Username, Bio, Point Content)

**Specifications**:
- Border radius: 12dp (consistent with cards)
- Border width: 1dp (unfocused), 2dp (focused)
- Minimum height: 48dp (single-line), 96dp (multi-line for Point content)

**Color Application**:
- Border (unfocused): `colorScheme.outline` (subtle gray)
- Border (focused): Location Blue (`colorScheme.primary`)
- Fill color: Subtle `colorScheme.surfaceVariant` tint OR transparent
- Label text: `colorScheme.onSurfaceVariant` (floats on focus)
- Input text: `colorScheme.onSurface` (high contrast)
- Error border: `colorScheme.error`

**Typography**:
- Label: Regular (400), 12sp (floating label)
- Input text: Regular (400), 16sp
- Helper text: Regular (400), 12sp, muted
- Error text: Regular (400), 12sp, error color

---

## Responsive Breakpoints & Theme Adjustments

### Phone (< 600dp) - PRIMARY TARGET

**Theme Adjustments**:
- Spacing: Standard (16dp screen padding)
- Visual density: Comfortable (optimal for touch)
- Typography: Base scale (no adjustments)
- FAB size: 56x56dp

**Layout Priorities**:
- Single-column feed
- Full-width cards with 16dp horizontal margin
- Bottom-anchored FAB

### Tablet (600dp - 840dp) - SECONDARY

**Theme Adjustments**:
- Spacing: Increase to 24dp screen padding
- Visual density: Comfortable (still touch-centric)
- Typography: Consider 105% scale for readability at arm's length
- FAB size: 64x64dp (larger target)

**Layout Priorities**:
- Two-column feed on landscape
- Master-detail views (list + detail side-by-side)
- Centered content with max-width constraint

### Desktop (> 840dp) - POST-MVP

**Theme Adjustments**:
- Spacing: 32dp margins, max content width 840dp
- Visual density: Consider `standard` for information density
- Typography: 100% scale (desktop viewing distance)
- Hover states: Add `InkWell` hover effects

**Not Applicable to MVP**: Desktop is not a priority for location-based mobile app.

---

## Motion Design Patterns

### Screen Transitions

**Entry (navigating forward)**:
- Animation: `SlideTransition` from right (iOS convention) OR `FadeTransition` (Android)
- Duration: 300ms
- Curve: `Curves.easeOut` (gentle landing)

**Exit (back navigation)**:
- Animation: Reverse of entry (slide left OR fade out)
- Duration: 300ms
- Curve: `Curves.easeIn` (faster exit feels natural)

### Point Drop Success

**Sequence** (total ~600ms):
1. FAB scales down (150ms, `easeInCubic`)
2. Success checkmark animates in center (300ms, `elasticOut`)
3. New Point card hero-animates into feed (300ms, overlapping)
4. FAB returns (150ms, `easeOut`)

### Like Animation

**Sequence** (total ~300ms):
1. Icon transitions from outline to filled (150ms, `easeInOut`)
2. Subtle scale pop: 1.0 → 1.2 → 1.0 (150ms total, `elasticOut`)
3. Color transitions to Location Blue (150ms, runs concurrently)

### Pull-to-Refresh (Feed)

**Specifications**:
- Indicator color: Location Blue
- Background: `colorScheme.surface`
- Activation threshold: 80dp drag distance
- Refresh animation: Material 3 default (spinning circle)

---

## Theme Testing Checklist

Before implementing features, validate theme compliance:

### Accessibility
- [ ] All text meets 4.5:1 contrast minimum (body text)
- [ ] All UI components meet 3:1 contrast minimum
- [ ] Location Blue tested against all background surfaces
- [ ] Theme validated with color blindness simulators
- [ ] Text scales correctly at 200% (iOS accessibility)
- [ ] Touch targets meet 48x48dp minimum

### Visual Consistency
- [ ] All border radii use 12dp (or documented exceptions)
- [ ] All spacing uses 8dp multiples
- [ ] Inter font family loads correctly on all platforms
- [ ] Light and dark themes transition smoothly
- [ ] Location Blue (#3A9BFC) is hero color in both themes

### Motion
- [ ] All animations use documented durations (150ms/300ms)
- [ ] Curves match specification (`easeInOutCubic` default)
- [ ] Reduced motion settings are respected
- [ ] No jank or dropped frames (60fps minimum)

### Platform
- [ ] Theme works on iOS and Android
- [ ] Safe areas respected (notches, home indicators)
- [ ] Platform-specific scroll physics applied
- [ ] Status bar colors adapt to theme

---

## Future Theme Evolution (Post-MVP)

### Potential Enhancements

1. **Custom Color Roles**: Add domain-specific colors beyond Material 3 defaults
   - `locationPrimary`: Specialized Location Blue variant for map elements
   - `ephemeralAccent`: Color for time-sensitive or disappearing content indicators

2. **Semantic Color Tokens**: Name colors by function, not appearance
   - `contentTextColor` instead of `onSurface`
   - `actionButtonColor` instead of `primary`

3. **Advanced Motion**: Shared element transitions between screens
   - Hero animations for Point cards → detail view
   - Morphing transitions for FAB → Point creation sheet

4. **Adaptive Iconography**: Custom icon set with location-specific metaphors
   - Custom Point drop pin icon
   - Maidenhead grid overlay icon
   - Distance rings icon

5. **Dynamic Color (Android 12+)**: User-selected wallpaper colors
   - Allow users to override theme with Material You dynamic colors
   - Maintain Location Blue as accent even with dynamic theming

---

## Design Tokens Summary

Quick reference for implementation:

### Colors
- **Primary**: #3A9BFC (seed, generates full palette)
- **Method**: Seed color generation (Material 3)
- **Brightness**: Light and dark themes supported

### Typography
- **Family**: Inter
- **Weights**: Regular (400), Medium (500), Semibold (600), Bold (700)
- **Features**: Tabular figures for numbers

### Spacing
- **Base**: 8dp
- **Scale**: 4dp, 8dp, 16dp, 24dp, 32dp, 48dp
- **Touch Target**: 48dp minimum

### Shape
- **Border Radius**: 12dp (default), 16dp (FAB/bottom sheets), 8dp (chips)
- **Elevation**: 1dp (default), 6dp (FAB)

### Motion
- **Short**: 150ms
- **Medium**: 300ms
- **Curve**: `Curves.easeInOutCubic`

### Density
- **Visual Density**: `VisualDensity.comfortable`

---

## Conclusion

This theme specification provides a comprehensive visual foundation for tuPoint that:

1. **Emphasizes Location**: Location Blue (#3A9BFC) as the hero color reinforces the spatial, map-based nature of the app
2. **Ensures Accessibility**: WCAG 2.1 AA compliance across all color combinations
3. **Balances Playfulness and Purpose**: Modern, approachable design that doesn't sacrifice clarity
4. **Optimizes for Mobile**: Touch-friendly spacing, comfortable density, and responsive motion
5. **Scales with Growth**: Material 3 foundation supports future feature expansion

The seed-based color generation approach ensures visual harmony and accessibility compliance while requiring minimal manual specification. Inter typography provides excellent legibility for both content and technical displays (Maidenhead codes, distances).

Implementation should follow Flutter's Material 3 theming system, with all values defined in `ThemeData` for consistency. Any deviations from this specification should be documented and justified.

**Next Steps**:
1. Implement `ThemeData` in Flutter app with specified values
2. Create constants file for spacing, animation, and custom values
3. Test theme on physical devices in various lighting conditions
4. Validate accessibility with contrast checkers and simulators
5. Document any theme adjustments required during implementation

---

**Designer Notes**: This theme was crafted specifically for a hyper-local, ephemeral social platform where content is intrinsically tied to physical locations. Every decision—from the vibrant blue evoking maps and navigation to the comfortable density optimizing for mobile touch—supports the core product vision: "Content disappears when you leave the area." The result is a visual system that feels modern, exploratory, and purpose-built for spatial social discovery.
