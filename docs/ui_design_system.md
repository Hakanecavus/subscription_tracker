# 🎨 Subscription Tracker - UI Design System

## 1. Design Tokens

### Renk Paleti

#### Light Mode
| Token | Hex | Kullanım |
|-------|-----|----------|
| Primary | #6366F1 | Ana aksiyonlar, FAB, selected states |
| Primary Dark | #4F46E5 | Hover/Press state |
| Primary Light | #EEF2FF | Light backgrounds, tags |
| Secondary | #8B5CF6 | Secondary aksiyonlar, accents |
| Surface | #FFFFFF | Card, sheet backgrounds |
| Background | #F8FAFC | Screen background |
| Error | #EF4444 | Hatalar, silme aksiyonları |
| Success | #22C55E | Başarılı işlemler, onay |
| Warning | #F59E0B | Uyarılar, dikkat gerektiren |
| Text Primary | #1E293B | Ana metinler |
| Text Secondary | #64748B | Alt metinler, hint |
| Text Tertiary | #94A3B8 | Placeholder, disabled |
| Border | #E2E8F0 | Divider, border |
| Border Light | #F1F5F9 | Subtle borders |

#### Dark Mode
| Token | Hex | Kullanım |
|-------|-----|----------|
| Primary | #818CF8 | Ana aksiyonlar |
| Primary Dark | #6366F1 | Hover/Press |
| Primary Light | #1E1B4B | Light backgrounds |
| Surface | #1E293B | Card, sheet backgrounds |
| Background | #0F172A | Screen background |
| Text Primary | #F8FAFC | Ana metinler |
| Text Secondary | #94A3B8 | Alt metinler |
| Text Tertiary | #64748B | Placeholder |
| Border | #334155 | Divider, border |

### Tipografi

**Font Family**: Inter (Google Fonts)

| Style | Size | Weight | Line Height | Usage |
|-------|------|--------|-------------|-------|
| H1 | 32px | Bold (700) | 40px | Screen titles |
| H2 | 24px | Semibold (600) | 32px | Section headers |
| H3 | 20px | Semibold (600) | 28px | Card titles |
| H4 | 18px | Medium (500) | 24px | Subsection titles |
| Body Large | 16px | Regular (400) | 24px | Primary body text |
| Body | 14px | Regular (400) | 20px | Secondary text |
| Body Small | 12px | Regular (400) | 16px | Captions, labels |
| Label | 12px | Semibold (600) | 16px | Tags, badges |
| Button | 14px | Semibold (600) | 20px | Button text |

### Spacing Scale

| Token | Value | Usage |
|-------|-------|-------|
| xs | 4px | Tight spacing, icon gaps |
| sm | 8px | Small gaps, icon padding |
| md | 12px | Default element spacing |
| lg | 16px | Card padding, section gaps |
| xl | 20px | Section padding |
| 2xl | 24px | Large gaps |
| 3xl | 32px | Screen edge padding (mobile) |
| 4xl | 40px | Large section spacing |
| 5xl | 48px | Screen edge padding (tablet) |
| 6xl | 64px | Hero sections |

### Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| sm | 4px | Small elements, tags |
| md | 8px | Buttons, inputs |
| lg | 12px | Cards, sheets |
| xl | 16px | Modals, dialogs |
| 2xl | 24px | Large cards |
| full | 9999px | Pills, avatars, FAB |

### Shadows

```dart
// Light mode shadows
BoxShadow shadowSm = BoxShadow(
  color: Colors.black.withOpacity(0.05),
  blurRadius: 2,
  offset: Offset(0, 1),
);

BoxShadow shadowMd = BoxShadow(
  color: Colors.black.withOpacity(0.1),
  blurRadius: 4,
  offset: Offset(0, 2),
);

BoxShadow shadowLg = BoxShadow(
  color: Colors.black.withOpacity(0.1),
  blurRadius: 8,
  offset: Offset(0, 4),
);

BoxShadow shadowXl = BoxShadow(
  color: Colors.black.withOpacity(0.15),
  blurRadius: 16,
  offset: Offset(0, 8),
);
```

---

## 2. Component Library

### Buttons

#### Primary Button
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    minimumSize: Size(0, 48),
    padding: EdgeInsets.symmetric(horizontal: 24),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 0,
  ),
  child: Text('Button', style: AppTypography.button),
)
```
- Height: 48dp
- Padding: 24dp horizontal
- Border Radius: 12dp
- States:
  - Enabled: #6366F1
  - Pressed: Scale 0.98 + #4F46E5
  - Disabled: #6366F1 with 38% opacity
  - Loading: Spinner + text dimmed

#### Secondary Button
- Background: Surface color
- Border: 1dp Primary color
- Text: Primary color

#### Ghost Button
- Background: Transparent
- Text: Primary color
- Pressed: Primary Light background

#### Danger Button
- Background: Error color
- For destructive actions

#### FAB (Floating Action Button)
- Size: 56dp x 56dp
- Icon: 24dp
- Shadow: shadowLg

### Input Fields

#### Text Input
```dart
TextField(
  decoration: InputDecoration(
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.error),
    ),
  ),
)
```
- Height: 52dp
- Border Radius: 12dp
- Focus: 2dp Primary border
- Error: Error color border + error text below

### Cards

#### Subscription Card
```dart
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [AppShadows.sm],
  ),
  child: Row(
    children: [
      // Leading: Icon/Logo (48dp)
      // Content: Title, subtitle
      // Trailing: Price, arrow
    ],
  ),
)
```
- Padding: 16dp
- Border Radius: 12dp
- Shadow: shadowSm
- Press State: Scale 0.99 + shadowMd

#### Stat Card
- Large number on top
- Label below
- Optional trend indicator

### List Items

#### Standard List Item
- Height: 72dp
- Padding: 16dp horizontal
- Leading: Icon/Avatar (40dp)
- Title: Body Large
- Subtitle: Body
- Trailing: Icon or Text
- Divider: 1dp border

#### With Swipe Actions
- Swipe right: Edit action
- Swipe left: Delete action
- Background color changes during swipe

### Chips/Tags

#### Category Chip
- Height: 32dp
- Padding: 12dp horizontal
- Border Radius: full (pill)
- Background: Primary Light
- Text: Primary Dark

#### Status Chip
- Success: Green background + icon
- Warning: Amber background + icon
- Error: Red background + icon

### Bottom Navigation

```dart
BottomNavigationBar(
  items: [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analytics'),
    BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
  ],
  selectedItemColor: AppColors.primary,
  unselectedItemColor: AppColors.textTertiary,
)
```
- Height: 80dp (includes safe area)
- Labels: Always show
- Active: Primary color + scale 1.1

### App Bar

- Height: 56dp (standard), 96dp (large)
- Title: H3
- Actions: Icon buttons (48dp touch target)
- Background: Transparent or Surface
- Elevation: 0 or shadowSm when scrolled

### Dialogs/Modals

#### Alert Dialog
- Border Radius: 16dp
- Padding: 24dp
- Max Width: 320dp (mobile)
- Buttons: Right aligned

#### Bottom Sheet
- Border Radius: 24dp (top corners)
- Initial Height: 50%
- Max Height: 90%
- Drag handle: 36dp x 4dp

### Snackbar/Toast

```dart
SnackBar(
  content: Row(
    children: [
      Icon(Icons.check_circle, color: Colors.white),
      SizedBox(width: 12),
      Text('Message'),
    ],
  ),
  backgroundColor: AppColors.textPrimary,
  behavior: SnackBarBehavior.floating,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  margin: EdgeInsets.all(16),
)
```
- Duration: 3-4 seconds
- Position: Bottom, floating
- Action: Optional text button

---

## 3. Screen Designs

### Onboarding Flow

#### Screen 1: Welcome
```
┌─────────────────────────────┐
│                             │
│        [LOGO/ICON]          │
│         (120dp)             │
│                             │
│      Track Your Subs        │
│       (H1, centered)        │
│                             │
│   Manage all subscriptions  │
│   in one place. Never miss  │
│    a payment. (Body Large)  │
│                             │
│                             │
│    [Get Started Button]     │
│      (Primary, full)        │
│                             │
└─────────────────────────────┘
```

#### Screen 2: Notifications
```
┌─────────────────────────────┐
│                             │
│     [ILLUSTRATION/BELL]     │
│                             │
│    Stay in the Loop         │
│                             │
│   Get notified before       │
│   payments are due.         │
│                             │
│    [Allow Notifications]    │
│      (Primary, full)        │
│                             │
│    [Skip for now]           │
│      (Ghost, center)        │
│                             │
└─────────────────────────────┘
```

#### Screen 3: First Subscription
```
┌─────────────────────────────┐
│                             │
│  ┌─────────────────────┐   │
│  │  📱 Add from Template │   │
│  │     Quick setup       │   │
│  └─────────────────────┘   │
│                             │
│         ─── OR ───          │
│                             │
│  ┌─────────────────────┐   │
│  │  ✏️ Add Manually     │   │
│  │     Full control      │   │
│  └─────────────────────┘   │
│                             │
│                             │
│    [Skip for now →]         │
│                             │
└─────────────────────────────┘
```

#### Screen 4: Premium Preview
```
┌─────────────────────────────┐
│                             │
│       ✨ Premium            │
│                             │
│  • Unlimited subscriptions  │
│  • Advanced analytics       │
│  • Cloud backup             │
│  • Custom categories        │
│                             │
│    [Start Free Trial]       │
│     7 days, then $4.99/mo   │
│                             │
│    [Continue with Free]     │
│          (Ghost)            │
│                             │
└─────────────────────────────┘
```

### Dashboard

```
┌─────────────────────────────┐
│  My Subscriptions      ⚙️   │
├─────────────────────────────┤
│                             │
│  ┌─────────────────────┐    │
│  │  Monthly Total      │    │
│  │  $247.50           │    │
│  │  💳 Next: $89.99   │    │
│  └─────────────────────┘    │
│                             │
│  Upcoming (7 days)          │
│  ┌─────────────────────┐    │
│  │ [ICON] Netflix      │    │
│  │        $15.99       │    │
│  │        in 3 days   │    │
│  └─────────────────────┘    │
│                             │
│  All Subscriptions        +  │
│  ┌─────────────────────┐    │
│  │ [🎬] Streaming    → │    │
│  │ Netflix    $15.99   │    │
│  ├─────────────────────┤    │
│  │ [☁️] Cloud       → │    │
│  │ Dropbox    $9.99    │    │
│  ├─────────────────────┤    │
│  │ [🎵] Music       → │    │
│  │ Spotify    $9.99    │    │
│  └─────────────────────┘    │
│                             │
│         [+  FAB]            │
├─────────────────────────────┤
│  🏠    📊        ⚙️         │
└─────────────────────────────┘
```

### Add Subscription

```
┌─────────────────────────────┐
│  ←  Add Subscription        │
├─────────────────────────────┤
│ [Templates] [Manual]        │
├─────────────────────────────┤
│                             │
│  Search templates...        │
│                             │
│  ┌─────────────────────┐    │
│  │ [NETFLIX ICON]      │    │
│  │ Netflix            │    │
│  │ $15.99/mo          │    │
│  └─────────────────────┘    │
│  ┌─────────────────────┐    │
│  │ [SPOTIFY ICON]      │    │
│  │ Spotify            │    │
│  │ $9.99/mo           │    │
│  └─────────────────────┘    │
│                             │
│  [Can't find? Add manually] │
│                             │
└─────────────────────────────┘
```

### Subscription Detail

```
┌─────────────────────────────┐
│  ←                 🗑️  ✏️  │
├─────────────────────────────┤
│                             │
│        [APP ICON]          │
│        (80dp, round)       │
│                             │
│        Netflix              │
│     Streaming Services      │
│                             │
│    $15.99 / month          │
│                             │
│  ┌─────────────────────┐    │
│  │ Next Payment        │    │
│  │ January 15, 2026   │    │
│  │ in 3 days 🔴        │    │
│  └─────────────────────┘    │
│                             │
│  Payment History           >│
│  ┌─────────────────────┐    │
│  │ Dec 15, 2025        │    │
│  │ $15.99             │    │
│  ├─────────────────────┤    │
│  │ Nov 15, 2025        │    │
│  │ $15.99             │    │
│  └─────────────────────┘    │
│                             │
└─────────────────────────────┘
```

### Analytics

```
┌─────────────────────────────┐
│  Analytics             ⚙️   │
├─────────────────────────────┤
│  [Monthly ▼]                │
├─────────────────────────────┤
│                             │
│  ┌─────────────────────┐    │
│  │ Total Spent         │    │
│  │ $247.50            │    │
│  │ ▲ 12% vs last mo   │    │
│  └─────────────────────┘    │
│                             │
│  Spending by Category       │
│        [PIE CHART]          │
│                             │
│  🎬 Streaming    $45.99   │
│  🎵 Music        $29.99   │
│  ☁️ Cloud        $9.99    │
│                             │
│  Monthly Trend              │
│       [BAR CHART]           │
│                             │
└─────────────────────────────┘
```

### Settings

```
┌─────────────────────────────┐
│  Settings                  │
├─────────────────────────────┤
│                             │
│  Preferences               │
│  ┌─────────────────────┐    │
│  │ Default Currency  >│    │
│  │ USD $                │    │
│  ├─────────────────────┤    │
│  │ Theme              >│    │
│  │ System              │    │
│  ├─────────────────────┤    │
│  │ Language           >│    │
│  │ English             │    │
│  └─────────────────────┘    │
│                             │
│  Security                  │
│  ┌─────────────────────┐    │
│  │ Biometric Lock     ●│    │
│  ├─────────────────────┤    │
│  │ Export Data        >│    │
│  ├─────────────────────┤    │
│  │ Import Data        >│    │
│  └─────────────────────┘    │
│                             │
│  About                     │
│  ┌─────────────────────┐    │
│  │ Version 1.0.0      │    │
│  ├─────────────────────┤    │
│  │ Rate App           >│    │
│  ├─────────────────────┤    │
│  │ Privacy Policy     >│    │
│  └─────────────────────┘    │
│                             │
└─────────────────────────────┘
```

---

## 4. Interaction Patterns

### Navigation

#### App Structure
```
- Home
  - Dashboard
  - Add Subscription
    - Template Selection
    - Manual Form
  - Subscription Detail
    - Edit
    - Payment History
- Analytics
- Settings
  - Premium (if not subscribed)
```

#### Transitions
- Screen to screen: Fade + slide (200ms)
- Modal bottom sheet: Slide up (300ms)
- Dialog: Scale + fade (150ms)
- FAB to screen: Shared element (hero)

### Micro-interactions

#### Button Press
```dart
AnimatedScale(
  scale: isPressed ? 0.98 : 1.0,
  duration: Duration(milliseconds: 100),
  child: child,
)
```

#### Card Press
```dart
AnimatedContainer(
  duration: Duration(milliseconds: 150),
  transform: isPressed ? Matrix4.diagonal3Values(0.99, 0.99, 1) : Matrix4.identity,
  decoration: BoxDecoration(
    boxShadow: isPressed ? shadowMd : shadowSm,
  ),
)
```

#### List Item Swipe
- Swipe > 20%: Background color visible
- Swipe > 40%: Action icon appears
- Release: Snaps to action or back
- Haptic feedback on action trigger

#### Pull to Refresh
- Pull > threshold: Loading indicator
- Release: Triggers refresh
- Spinner: Circular progress
- Success: Checkmark + bounce

### Empty States

#### No Subscriptions Yet
```
┌─────────────────────────────┐
│                             │
│                             │
│     [ILLUSTRATION]          │
│      Empty inbox/doc        │
│                             │
│   No subscriptions yet      │
│                             │
│   Add your first            │
│   subscription to start     │
│   tracking.                 │
│                             │
│   [Add Subscription]        │
│                             │
│                             │
└─────────────────────────────┘
```

#### No Results
- Search icon + "No results found"
- "Try different keywords" hint

### Loading States

#### Skeleton Loading
```dart
Shimmer.fromColors(
  baseColor: Colors.grey[300]!,
  highlightColor: Colors.grey[100]!,
  child: Container(
    width: double.infinity,
    height: 72,
    color: Colors.white,
  ),
)
```

#### Pull to Refresh
```dart
RefreshIndicator(
  onRefresh: () async { ... },
  color: AppColors.primary,
  backgroundColor: AppColors.surface,
  child: ListView(...),
)
```

### Error States

#### Network Error
```
┌─────────────────────────────┐
│                             │
│     [ERROR ICON]            │
│      Cloud with X           │
│                             │
│   Couldn't load data        │
│                             │
│   Check your connection     │
│   and try again.            │
│                             │
│   [Try Again]               │
│                             │
└─────────────────────────────┘
```

---

## 5. Accessibility

### Touch Targets
- Minimum: 48dp x 48dp
- Recommended: 56dp x 56dp (buttons)
- Spacing between targets: 8dp minimum

### Color Contrast
- Text Primary: 4.5:1 minimum (WCAG AA)
- Text Large: 3:1 minimum
- Interactive elements: 3:1 minimum

### Screen Readers
```dart
IconButton(
  icon: Icon(Icons.edit),
  onPressed: () {},
  tooltip: 'Edit subscription',
)

// Or
Semantics(
  label: 'Netflix subscription, $15.99 per month',
  child: SubscriptionCard(...),
)
```

### Focus Indicators
- Outline: 2dp Primary color
- Offset: 2dp from element

### Text Scaling
- Support up to 200% text scale
- Use `maxLines` and `overflow` properly
- Flexible layouts, avoid fixed heights

---

## 6. Responsive Considerations

### Breakpoints
| Breakpoint | Width | Usage |
|------------|-------|-------|
| Mobile S | 320dp | Small phones |
| Mobile M | 375dp | Standard phones |
| Mobile L | 414dp | Large phones |
| Tablet | 768dp+ | Tablets, foldables |

### Layout Behavior

#### Phone (< 600dp)
- Single column
- Bottom navigation
- Full-width cards
- Modal bottom sheets

#### Tablet (600dp+)
- Two-column layout possible
- Side navigation or rail
- Larger cards with more info
- Side sheets instead of bottom

### Safe Areas
```dart
SafeArea(
  child: Padding(
    padding: EdgeInsets.symmetric(horizontal: 16),
    child: content,
  ),
)
```

### Keyboard Handling
```dart
SingleChildScrollView(
  child: Padding(
    padding: EdgeInsets.only(
      bottom: MediaQuery.of(context).viewInsets.bottom,
    ),
    child: form,
  ),
)
```

---

## 7. Animation Guidelines

### Duration
- Micro (press, hover): 100-150ms
- Small (transitions): 200-250ms
- Medium (modals): 300ms
- Large (page transitions): 300-400ms

### Easing
```dart
// Standard
Curves.easeInOut

// Enter
Curves.easeOut

// Exit
Curves.easeIn

// Bounce
Curves.elasticOut
```

### Shared Element (Hero)
```dart
Hero(
  tag: 'subscription_${subscription.id}',
  child: SubscriptionCard(subscription),
)
```
