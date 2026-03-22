# Mr.Finn

Mr.Finn is a Flutter-based personal finance tracker focused on fast local transaction logging, debt tracking, and Android notification-assisted finance capture. The app is designed for personal daily use, with support for manual transactions, debt management, notification review, budget tracking, and dashboard insights.

## Features

- Manual income and expense tracking
- Debt management for:
  - Debt Owed
  - Debt Given
- Debt-linked repayment handling
- Android notification listener integration
- Queue-based review flow for Maybank notifications
- Confidence-based notification parsing
- Search and filter for:
  - Finance transactions
  - Debt history
- Dashboard insights including:
  - Total Balance
  - Income This Month
  - Spending This Month
  - Spending Today
  - Budget Remaining
  - Monthly Spending History
- Safe delete logic for:
  - normal transactions
  - debt repayments
  - debt-linked cashflow
- Modernized UI across dashboard, finance, debts, queue, and dialogs

## Tech Stack

- Flutter
- Dart
- Riverpod
- Drift (local database)
- fl_chart
- Android Notification Listener integration

## Current Scope

Mr.Finn is currently intended for Android personal use and local finance tracking. Data is stored locally on-device.

## Important Notes

- The app currently stores data locally.
- Uninstalling the app or clearing app storage may remove saved data.
- Notification parsing is focused on Maybank/MAE transaction patterns and may continue to improve over time.
- Android background and notification-listener behavior can vary by device/OS restrictions.

## Installation

### Run in development
```bash
flutter pub get
flutter run
