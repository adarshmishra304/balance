# 💰 Balance Manager

A simple and user-friendly **personal balance management mobile application** built with **Flutter and Dart** for tracking money given to and received from friends.

The application uses a local **SQLite database** to persist friends, transactions, and calculated balances directly on the device.

## ✨ Features

* 👥 Add and manage friends
* 💸 Record money given to friends
* 💰 Record money received from friends
* 📊 Track total amount owed to you
* 📉 Track total amount you owe
* 🧾 View complete transaction history for each friend
* 📅 Display transaction dates
* 📝 Add optional transaction descriptions
* 🗑️ Delete friends and transactions
* 🔄 Automatically recalculate balances after transactions
* 💾 Persistent local data using SQLite
* 🌙 Light and Dark Theme support
* 📱 Material 3 responsive UI

## 🛠️ Tech Stack

* **Flutter**
* **Dart**
* **SQLite**
* **sqflite**
* **Provider**
* **Material 3**
* **intl**

## 🏗️ Architecture

The application follows a modular structure separating the UI, state management, models, and database operations.

```text
balance_manager/
│
├── lib/
│   ├── main.dart
│   │
│   ├── database/
│   │   └── db_helper.dart
│   │
│   ├── models/
│   │   ├── friend.dart
│   │   └── transaction.dart
│   │
│   ├── providers/
│   │   └── balance_provider.dart
│   │
│   └── screens/
│       ├── home_screen.dart
│       └── friend_detail_screen.dart
│
├── android/
├── ios/
├── pubspec.yaml
└── README.md
```

## 💾 Local Database

The application uses **SQLite** through the `sqflite` package.

Two tables are created:

### Friends

```text
friends
├── id
├── name
└── totalBalance
```

### Transactions

```text
transactions
├── id
├── friend_id
├── amount
├── description
├── date
└── type
```

A foreign key connects each transaction to its corresponding friend. Deleting a friend also removes the associated transactions using **cascade deletion**.

## 💸 Balance Calculation

Transactions are divided into two types:

```dart
enum TransactionType {
  given,
  received,
}
```

### Money Given

When money is given to a friend, the amount is added to the friend's balance.

```text
Balance = Balance + Given Amount
```

### Money Received

When money is received from a friend, the amount is subtracted.

```text
Balance = Balance - Received Amount
```

This allows the application to determine whether:

* 🟢 The friend owes you
* 🔴 You owe the friend
* ⚪ The balance is settled

## 📊 Dashboard

The home screen provides an overview of the user's balances.

### Owed to Me

Displays the total amount currently owed to the user by friends.

### I Owe

Displays the total amount the user owes to friends.

Each friend is also displayed with their current balance and status.

## 👤 Friend Management

Users can:

* Add a new friend
* View a friend's balance
* Open detailed transaction history
* Delete a friend

Deleting a friend also deletes their associated transaction history.

## 🧾 Transaction Management

For each friend, users can add transactions with:

* Amount
* Description
* Transaction type
* Current date

Transactions are displayed in reverse chronological order.

### Given

Shown as a positive transaction:

```text
+500.00
Money given
```

### Received

Shown as a negative transaction:

```text
-200.00
Money received
```

Transactions can also be deleted, after which the friend's balance is recalculated automatically.

## 🔄 State Management

The application uses the **Provider** package with `ChangeNotifier` for state management.

`BalanceProvider` manages:

* Friend list
* Loading state
* Total amount owed to the user
* Total amount the user owes
* Adding and deleting friends
* Adding and deleting transactions
* Fetching transaction history

This keeps database operations separate from the UI.

## 🎨 UI & Theme

The application uses **Material 3** and supports both light and dark themes.

```dart
themeMode: ThemeMode.system,
```

The application automatically follows the device's system theme.

## 🚀 Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/your-username/balance-manager.git
cd balance-manager
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Run the application

```bash
flutter run
```

## 📱 Build APK

To create a release APK:

```bash
flutter build apk --release
```

The generated APK will be available in:

```text
build/app/outputs/flutter-apk/
```

For architecture-specific APKs:

```bash
flutter build apk --release --split-per-abi
```

## 🔮 Future Improvements

* 🔐 PIN or biometric app lock
* 🔍 Search and filter friends
* 📈 Balance statistics and charts
* 📤 Export transactions
* 📄 Generate transaction reports
* 🔔 Payment reminders
* 💱 Multiple currency support
* ☁️ Cloud backup and synchronization
* ✏️ Edit existing transactions

## 👨‍💻 Author

**Adarsh Mishra**

Computer Science Engineering Student

Interested in Flutter, Java, C++, DSA and Software Development.

## 📄 License

This project is available for educational and personal use.
