# Balance Manager 💸

A simple and efficient Flutter application to track money transactions between you and your friends. Never forget who owes you money or who you need to pay back!

## 🚀 Features

-   **Friend Management**: Add and remove friends from your tracking list.
-   **Transaction Tracking**: Record every time you give (lend) or receive (borrow) money.
-   **Balance Dashboard**: 
    -   **Green**: Money you've given (friend owes you).
    -   **Red**: Money you've received (you owe them).
-   **Detailed History**: View a chronological list of all transactions for each friend.
-   **Smart Summary**: See your total "Owed to Me" and "I Owe" balances right on the home screen.
-   **Settle Up**: Quickly clear the balance with a single tap once a debt is paid.
-   **Persistent Storage**: All data is saved locally on your device using SQLite.

## 🛠️ Built With

-   **Flutter**: UI Framework.
-   **Provider**: State management.
-   **Sqflite**: Local database for data persistence.
-   **Intl**: For date and currency formatting.

## 📸 Screenshots

| Home Screen | Friend Details | Add Transaction |
| :---: | :---: | :---: |
| Overview of all friends and total balances. | History of specific transactions. | Easy input for new records. |

## 🏁 Getting Started

### Prerequisites
-   [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
-   An Android/iOS emulator or a physical device.

### Installation
1.  Clone the repository:
    ```bash
    git clone https://github.com/yourusername/balance_calculator.git
    ```
2.  Navigate to the project directory:
    ```bash
    cd balance_calculator
    ```
3.  Install dependencies:
    ```bash
    flutter pub get
    ```
4.  Run the app:
    ```bash
    flutter run
    ```

## 📝 License
This project is open source. Feel free to use and modify it!
