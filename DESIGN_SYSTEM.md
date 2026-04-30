# AAST-CONNECT Design System

## Overview

The AAST-CONNECT app uses a comprehensive design system built on Material Design 3 with custom theming, reusable widgets, and consistent layout patterns. This document serves as the single source of truth for all design tokens, components, and usage patterns.

## Theme System

### Color Scheme

#### Light Theme
- **Primary**: `#284B8C` (Deep Blue)
- **Secondary**: `#637E99` (Steel Blue)
- **Surface**: `#FFFFFF` (White)
- **Background**: `#F9F9F9` (Light Gray)
- **Error**: `#F44336` (Red)

#### Dark Theme
- **Primary**: `#4A90E2` (Lighter Blue)
- **Secondary**: `#637E99` (Steel Blue)
- **Surface**: `#2A2A2A` (Dark Gray)
- **Background**: `#1A1A1A` (Very Dark Gray)
- **Error**: `#F44336` (Red Accent)

#### Status Colors
- **Approved**: `#4CAF50` (Green)
- **Pending**: `#FFC107` (Amber)
- **Rejected**: `#F44336` (Red)
- **Canceled**: `#757575` (Gray)

### Typography

**Font Family**: Inter

#### Text Styles
- **Headline Large**: Bold, 22+px
- **Headline Medium**: Bold, 18-22px
- **Body Large**: Regular, 16px
- **Body Medium**: Regular, 14px
- **Label Large**: Regular, 12-14px

## Widget Architecture

### Directory Structure
```
lib/widgets/
├── home_widgets/          # Home screen specific widgets
├── opportunities_wigdet/  # Opportunities screen widgets
├── profile_widgets/       # Profile screen widgets
└── [miscellaneous]       # Reusable components
```

## Core Components

### 1. RoundedContainer
**Location**: `lib/widgets/rounded_container.dart`

The foundational container component used throughout the app.

**Parameters**:
- `child`: Widget content
- `backgroundColor`: Container background color
- `borderColor`: Border color
- `borderRadius`: Corner radius (default: 20.0)
- `padding`: Internal padding (default: 20px)
- `margin`: External margin
- `width/height`: Dimensions
- `border`: Custom border
- `boxShadow`: Shadow effects

**Usage**:
```dart
RoundedContainer(
  backgroundColor: Theme.of(context).colorScheme.surface,
  borderRadius: 15.0,
  padding: EdgeInsets.all(16),
  child: Text('Content'),
)
```

### 2. BaseModal
**Location**: `lib/widgets/base_modal.dart`

Standard modal component with consistent styling.

**Parameters**:
- `title`: Modal title
- `child`: Modal content
- `heightFactor`: Height percentage (default: 0.9)
- `actions`: Additional action buttons

**Features**:
- Responsive height (90% of screen)
- Rounded top corners (30px radius)
- Theme-aware colors
- Close button

### 3. ModalFormField
**Location**: `lib/widgets/modal_form_field.dart`

Form field component for modal dialogs.

**Parameters**:
- `label`: Field label
- `hintText`: Placeholder text
- `controller`: Text controller
- `maxLines`: Maximum lines (default: 1)
- `isDark`: Dark mode flag
- `keyboardType`: Keyboard type

**Features**:
- Integrated label styling
- Theme-aware background
- Rounded corners (15px)

### 4. SkillChip
**Location**: `lib/widgets/skill_chip.dart`

Chip component for displaying skills with proficiency levels.

**Parameters**:
- `skill`: Skill name
- `level`: Proficiency level (beginner/intermediate/advanced)
- `isDark`: Dark mode flag

**Level Colors**:
- **Beginner**: Blue (`#2196F3`)
- **Intermediate**: Orange (`#FF9800`)
- **Advanced**: Green (`#4CAF50`)

### 5. TrackingStatusChip
**Location**: `lib/widgets/tracking_status_chip.dart`

Status chip for application tracking.

**Parameters**:
- `status`: Status text

**Status Mappings**:
- `APPROVED` → "Accepted" (Green, check icon)
- `PENDING` → "Pending" (Amber, hourglass icon)
- `REJECTED` → "Rejected" (Red, cancel icon)
- `CANCELED` → "Canceled" (Gray, do not disturb icon)

### 6. DocumentCard
**Location**: `lib/widgets/document_card.dart`

Card component for displaying document information.

**Parameters**:
- `name`: Document name
- `date`: Upload date
- `type`: Document type
- `onTap`: Click handler
- `onDelete`: Delete handler
- `showDeleteButton`: Delete button visibility

**Features**:
- File icon with brand color background
- Document metadata display
- Optional delete functionality

## Screen-Specific Widgets

### Home Screen Widgets
**Location**: `lib/widgets/home_widgets/`

#### StudentHomeStatCard
Displays statistics with icon and numbers.

**Parameters**:
- `backgroundColor`: Card background
- `number`: Stat value
- `label`: Stat description
- `icon`: Icon widget

#### StudentHomeSectionHeader
Section header with action button.

**Parameters**:
- `title`: Section title
- `actionText`: Action button text
- `onActionTap`: Action handler

#### StudentHomeProgramCard
Program opportunity card for home screen.

#### StudentHomeProgressCard
Progress tracking card.

#### StudentHomeDeadlineCard
Deadline reminder card.

### Opportunities Screen Widgets
**Location**: `lib/widgets/opportunities_wigdet/`

#### StudentOpportunitiesProgramCard
Main program card with save/apply functionality.

**Features**:
- Category-based colors and icons
- Save/bookmark functionality
- Apply button
- View details action

**Category Mapping**:
- `development` → Green, computer icon
- `it` → Blue, storage icon
- `security` → Red, security icon
- `design` → Orange, design icon
- `data` → Teal, analytics icon
- `cloud` → Light blue, cloud icon
- `ai` → Indigo, psychology icon

#### StudentOpportunitiesFilterChips
Filter chips for program categories.

#### StudentOpportunitiesSearchBar
Search functionality with filters.

#### StudentOpportunitiesApplyModal
Application form modal.

#### StudentOpportunitiesDetailsModal
Program details modal.

### Profile Screen Widgets
**Location**: `lib/widgets/profile_widgets/`

#### StudentProfileEditModal
Profile editing modal.

#### StudentProfileSkillsModal
Skills management modal.

#### StudentProfileDocumentsModal
Document management modal.

#### StudentProfilePortfolioModal
Portfolio items modal.

#### StudentProfileSubmitHoursModal
Hours submission modal.

## Layout Patterns

### Navigation Structure
- **Bottom Navigation**: 4 tabs (Home, Training, Profile, Support)
- **IndexedStack**: Preserves screen state
- **Tab Icons**: Outlined/filled variants

### Screen Layout
```dart
Scaffold(
  body: IndexedStack(
    index: _currentIndex,
    children: [
      StudentHome(...),
      StudentOpportunities(),
      StudentProfile(...),
      StudentSupport(),
    ],
  ),
  bottomNavigationBar: BottomNavigationBar(...),
)
```

### Common Patterns

#### Card Layout
```dart
RoundedContainer(
  backgroundColor: Theme.of(context).colorScheme.surface,
  borderRadius: 15.0,
  padding: EdgeInsets.all(16),
  child: Column(
    children: [
      // Content
    ],
  ),
)
```

#### Modal Pattern
```dart
BaseModal(
  title: "Modal Title",
  child: Column(
    children: [
      // Modal content
    ],
  ),
)
```

#### Section Pattern
```dart
Column(
  children: [
    StudentHomeSectionHeader(
      title: "Section Title",
      actionText: "See All",
      onActionTap: () {},
    ),
    // Section content
  ],
)
```

## Design Tokens

### Spacing
- **XS**: 4px
- **S**: 8px
- **M**: 16px
- **L**: 20px
- **XL**: 24px
- **XXL**: 32px

### Border Radius
- **Small**: 10px (chips, buttons)
- **Medium**: 15px (cards, form fields)
- **Large**: 20px (containers)
- **XL**: 30px (modals)

### Shadows
- **Cards**: Elevation 2
- **Modals**: None (handled by container styling)

## Theme Implementation

### Theme Provider
**Location**: `lib/services/theme_provider.dart`

**Features**:
- Persistent theme preference
- Light/dark theme switching
- Material 3 design system
- Custom color schemes

**Usage**:
```dart
Consumer<ThemeProvider>(
  builder: (context, themeProvider, child) {
    return MaterialApp(
      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
      themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
    );
  },
)
```

## Best Practices

### Component Usage
1. **Always use RoundedContainer** for consistent styling
2. **Use BaseModal** for all modal dialogs
3. **Leverage theme colors** instead of hardcoded values
4. **Follow the widget organization** by screen

### Color Usage
1. **Primary color** for main actions and navigation
2. **Secondary color** for secondary elements
3. **Status colors** for state indicators
4. **Surface colors** for cards and containers

### Typography
1. **Use theme text styles** for consistency
2. **Maintain hierarchy** with headline/body/label styles
3. **Keep font weights consistent** (bold for headers, regular for body)

### Responsive Design
1. **Use MediaQuery** for screen dimensions
2. **Implement flexible layouts** with Flex/Column/Row
3. **Test on different screen sizes**

## Dependencies

### UI Packages
- `flutter`: Core framework
- `cupertino_icons`: iOS-style icons
- `provider`: State management for themes
- `shared_preferences`: Theme persistence

### Feature Packages
- `supabase_flutter`: Backend services
- `file_picker`: File selection
- `url_launcher`: Link handling
- `awesome_snackbar_content`: Enhanced notifications
- `timelines_plus`: Timeline components

## Conclusion

This design system ensures consistency across the AAST-CONNECT application while providing flexibility for future enhancements. All components are built to be reusable, theme-aware, and maintainable.

When adding new components:
1. Follow the established naming conventions
2. Use the design tokens defined above
3. Make components theme-aware
4. Document usage patterns
5. Test in both light and dark themes
