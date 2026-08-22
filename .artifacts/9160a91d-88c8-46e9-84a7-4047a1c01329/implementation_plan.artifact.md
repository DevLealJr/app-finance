# Implementation Plan - MeuControle Finance App

Create a 100% mobile Flutter application for personal finance management based on the provided UI design. The app will feature a dark theme with mint green accents and include dashboard, expense entry, history, and profile screens.

## User Review Required

> [!IMPORTANT]
> The implementation will focus on the UI and navigation. Mock data will be used for all balances, categories, and history items.

## Proposed Changes

### Core & Theme

#### [NEW] [app_theme.dart](file:///C:/develop/projetos/finance/lib/core/theme/app_theme.dart)
Defines the dark color scheme, typography, and component styles (buttons, text fields, cards) to match the screenshots.
- Background: `#1C1C2E`
- Surface: `#25253E`
- Primary: `#00D09E`
- Text: White (`#FFFFFF`) and secondary grey (`#A0A0A0`).

---

### Shared Widgets

#### [NEW] [custom_bottom_nav.dart](file:///C:/develop/projetos/finance/lib/features/presentation/widgets/custom_bottom_nav.dart)
A custom bottom navigation bar with the four icons: Início, Lançar, Histórico, and Perfil.

---

### Features: Presentation

#### [MODIFY] [app.dart](file:///C:/develop/projetos/finance/lib/app.dart)
Update to use the new `AppTheme` and set up a `MainScreen` that handles the navigation between the four main pages.

#### [NEW] [main_screen.dart](file:///C:/develop/projetos/finance/lib/features/presentation/pages/main_screen.dart)
A wrapper widget that contains the `Scaffold` with `IndexedStack` for the pages and the `CustomBottomNavBar`.

#### [MODIFY] [dashboard_page.dart](file:///C:/develop/projetos/finance/lib/features/presentation/pages/dashboard_page.dart)
Implement the dashboard UI:
- Monthly summary header.
- Circular progress chart for total spending.
- Horizontal list for credit, debit, and PIX balances.
- Grid for expense categories (Alimentação, Transporte, Lazer, Saúde).

#### [NEW] [add_expense_page.dart](file:///C:/develop/projetos/finance/lib/features/presentation/pages/add_expense_page.dart)
Implement the "Lançar Gasto" UI:
- Large amount display and input.
- Description text field.
- Payment method toggle buttons.
- Switch tiles for "Cartão Familiar" and "Parcelar Gasto?".
- Installment counter.
- Summary box and "Lançar Gasto" button.

#### [NEW] [history_page.dart](file:///C:/develop/projetos/finance/lib/features/presentation/pages/history_page.dart)
Implement the "Histórico" UI:
- Page title and month selector.
- Filter chips (Todos, Crédito, Débito, PIX).
- List of transaction tiles with icons, titles, categories/installments, and values.

#### [NEW] [profile_page.dart](file:///C:/develop/projetos/finance/lib/features/presentation/pages/profile_page.dart)
Implement the "Perfil" UI:
- User profile header (Avatar, name, email).
- "Meus Cartões" section.
- "Preferências" toggles.
- "Resumo do Mês" goal progress and stats.
- Logout button.

#### [NEW] [confirmation_bottom_sheet.dart](file:///C:/develop/projetos/finance/lib/features/presentation/widgets/confirmation_bottom_sheet.dart)
The confirmation UI shown when adding a duplicate or similar expense.

---

## Verification Plan

### Automated Tests
- I will run `flutter analyze` to ensure no linting errors.

### Manual Verification
- Run the app on the emulator using `flutter run -d emulator-5554`.
- Verify the navigation between all four tabs.
- Check that the UI matches the design provided in the images (colors, spacing, icons).
- Test the "Lançar Gasto" form interactions (toggles, counters).
- Open the confirmation bottom sheet from the "Lançar Gasto" button.
