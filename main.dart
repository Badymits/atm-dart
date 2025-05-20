import 'dart:io';
import 'fileActions.dart';

void main() {
  // Read user data from JSON file
  final userData = readUserData();
  if (userData.isEmpty) {
    print("Failed to load user data. Exiting program.");
    exit(1);
  }

  login(userData);
}

void login(List<Map<String, dynamic>> userData) {
  int tries = 0;

  while (tries < 3) {
    stdout.write('Please enter your PIN:');
    String? enteredPin = stdin.readLineSync();

    if (enteredPin == null || enteredPin.isEmpty) {
      print("Invalid input. Please enter a PIN.");
      continue;
    }

    final user = findUserByPin(enteredPin, userData);

    if (user != null) {
      print("\nLogin successful! Welcome, ${user['name']}!");
      mainPortal(user, userData);
      return;
    } else {
      tries++;
      if (tries < 3) {
        print("Incorrect PIN, please try again.\n");
      } else {
        print("Too many unsuccessful attempts. Exiting Program");
        exit(0);
      }
    }
  }
}

void mainPortal(
  Map<String, dynamic> currentUser,
  List<Map<String, dynamic>> allUsers,
) {
  bool continueSession = true;

  while (continueSession) {
    print('\nWelcome to the ATM Portal!');
    print("This project is for educational purposes only.");

    print("\nPlease select an option:");
    print("1. Check Balance");
    print("2. Deposit Money");
    print("3. Withdraw Money");
    print("4. Exit");

    int? choice = int.tryParse(stdin.readLineSync() ?? '');
    switch (choice) {
      case 1:
        CheckBalance(currentUser);
        break;
      case 2:
        currentUser = DepositMoney(currentUser);
        // Update the user data in the list
        updateUserInList(currentUser, allUsers);
        // Save updated data back to file
        writeUserData(allUsers);
        break;
      case 3:
        currentUser = WithdrawMoney(currentUser);
        // Update the user data in the list
        updateUserInList(currentUser, allUsers);
        // Save updated data back to file
        writeUserData(allUsers);
        break;
      case 4:
        print("Thank you for using our ATM. Goodbye!");
        continueSession = false;
        break;
      default:
        print("Invalid choice. Please try again.");
    }
  }
}

void CheckBalance(Map<String, dynamic> user) {
  print("Check Balance");
  print("Your current balance is: \$${user['balance']}");
}

// Helper function to update user data in the list
void updateUserInList(
  Map<String, dynamic> user,
  List<Map<String, dynamic>> allUsers,
) {
  final index = allUsers.indexWhere((u) => u['pin'] == user['pin']);
  if (index != -1) {
    allUsers[index] = user;
  }
}

// noticed that the DepositMoney and WithdrawMoney functions are mostly the same
// so I tried to refactor them to reduce redundancy
Map<String, dynamic> handleTransaction(
  Map<String, dynamic> user,
  bool transactionType,
) {
  String transactionName = transactionType ? "Deposit" : "Withdraw";
  String transactionVerb = transactionType ? "Deposited" : "Withdrawn";

  print("$transactionName Money");

  while (true) {
    print(
      "Enter the amount to $transactionName (or press X and enter to cancel):",
    );
    String? input = stdin.readLineSync();

    if (input == null) {
      continue; // skip if null input
    }

    input = input.trim();

    if (input.toLowerCase() == 'x') {
      print("Transaction cancelled. Returning to main menu.");
      break;
    }

    int? amount = int.tryParse(input);

    if (amount == null || amount <= 0) {
      stdout.write('\x1B[1A'); // Move cursor up
      stdout.write('\x1B[2K'); // Clear entire line
      print("INVALID INPUT.");
      continue;
    }

    if (!transactionType && amount > user['balance']) {
      stdout.write('\x1B[1A');
      stdout.write('\x1B[2K');
      print(
        "INSUFFICIENT FUNDS. Your current balance is: \$${user['balance']}",
      );
      continue;
    }

    user['balance'] =
        transactionType ? user['balance'] + amount : user['balance'] - amount;

    // adding success message for both deposit and withdraw
    print(
      "You have successfully $transactionVerb \$${amount}. Your new balance is: \$${user['balance']}",
    );

    print("Transaction successful. Returning to main menu.");
    break;
  }
  return user;
}

Map<String, dynamic> DepositMoney(Map<String, dynamic> user) {
  return handleTransaction(user, true);
}

Map<String, dynamic> WithdrawMoney(Map<String, dynamic> user) {
  return handleTransaction(user, false);
}
