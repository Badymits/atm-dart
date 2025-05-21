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
    print("4. Pay Bills");
    print("5. Transfer Money");
    print("6. Change PIN");
    print("7. Exit");

    int? choice = int.tryParse(stdin.readLineSync() ?? '');
    switch (choice) {
      case 1:
        CheckBalance(currentUser);
        break;
      case 2:
        currentUser = DepositMoney(currentUser);
        updateUserInList(currentUser, allUsers);
        writeUserData(allUsers);
        break;
      case 3:
        currentUser = WithdrawMoney(currentUser);
        updateUserInList(currentUser, allUsers);
        writeUserData(allUsers);
        break;
      case 4:
        currentUser = PayBills(currentUser);
        updateUserInList(currentUser, allUsers);
        writeUserData(allUsers);
        break;
      case 5:
        currentUser = TransferMoney(currentUser, allUsers);
        updateUserInList(currentUser, allUsers);
        writeUserData(allUsers);
        break;
      case 6:
        currentUser = ChangePin(currentUser);
        updateUserInList(currentUser, allUsers);
        writeUserData(allUsers);
        break;
      case 7:
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
  final index = allUsers.indexWhere((u) => u['pin'].toString() == user['pin'].toString());
  if (index != -1) {
    allUsers[index] = user;
  }
}

// Deposit/Withdraw logic
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

    double? amount = double.tryParse(input);

    if (amount == null || amount <= 0) {
      print("INVALID INPUT.");
      continue;
    }

    if (!transactionType && amount > user['balance']) {
      print(
        "INSUFFICIENT FUNDS. Your current balance is: \$${user['balance']}",
      );
      continue;
    }

    user['balance'] =
        transactionType ? user['balance'] + amount : user['balance'] - amount;

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

// Pay Bills logic
Map<String, dynamic> PayBills(Map<String, dynamic> user) {
  print("Pay Bills");
  print("Enter the bill amount to pay (or press X and enter to cancel):");
  while (true) {
    String? input = stdin.readLineSync();
    if (input == null) continue;
    input = input.trim();
    if (input.toLowerCase() == 'x') {
      print("Bill payment cancelled. Returning to main menu.");
      break;
    }
    double? amount = double.tryParse(input);
    if (amount == null || amount <= 0) {
      print("INVALID INPUT.");
      continue;
    }

    // select biller category
    List<String> categories = ['Utilities', 'Internet', 'Mobile', 'Other'];
    print("Select biller category:");
    for (int i = 0; i < categories.length; i++) {
      print("${i + 1}. ${categories[i]}");
    }
    int? catChoice = int.tryParse(stdin.readLineSync() ?? '');
    if (catChoice == null || catChoice < 1 || catChoice > categories.length) {
      print("Invalid category. Cancelling bill payment.");
      break;
    }
    String selectedCategory = categories[catChoice - 1];

    // select biller
    Map<String, List<String>> billers = {
      'Utilities': ['Meralco', 'Maynilad', 'LPG'],
      'Internet': ['PLDT', 'Converge', 'Globe', 'Sky'],
      'Mobile': ['Globe', 'Dito', 'Smart'],
      'Other': ['Biller1', 'Biller2'],
    };
    List<String> billerList = billers[selectedCategory]!;
    print("Select desired biller:");
    for (int i = 0; i < billerList.length; i++) {
      print("${i + 1}. ${billerList[i]}");
    }
    int? billerChoice = int.tryParse(stdin.readLineSync() ?? '');
    if (billerChoice == null || billerChoice < 1 || billerChoice > billerList.length) {
      print("Invalid biller. Cancelling bill payment.");
      break;
    }
    String selectedBiller = billerList[billerChoice - 1];

    // Confirm payment
    print("You are about to pay \$${amount} to $selectedBiller under $selectedCategory category.");
    print("Type 'yes' to confirm or any other key to cancel:");
    String? confirm = stdin.readLineSync();
    if (confirm == null || confirm.toLowerCase() != 'yes') {
      print("Bill payment cancelled. Returning to main menu.");
      break;
    }
    if (amount > user['balance']) {
      print("INSUFFICIENT FUNDS. Your current balance is: \$${user['balance']}");
      continue;
    }
    user['balance'] -= amount;
    print("Bill of \$${amount} paid successfully. New balance: \$${user['balance']}");
    break;
  }
  return user;
}

// Transfer Money logic
Map<String, dynamic> TransferMoney(Map<String, dynamic> user, List<Map<String, dynamic>> allUsers) {
  print("Transfer Money");
  print("Enter recipient PIN (or press X and enter to cancel):");
  while (true) {
    String? recipientPin = stdin.readLineSync();
    if (recipientPin == null) continue;
    recipientPin = recipientPin.trim();
    if (recipientPin.toLowerCase() == 'x') {
      print("Transfer cancelled. Returning to main menu.");
      break;
    }
    if (recipientPin == user['pin'].toString()) {
      print("You cannot transfer to your own account.");
      continue;
    }
    final recipient = findUserByPin(recipientPin, allUsers);
    if (recipient == null) {
      print("Recipient not found. Please enter a valid PIN.");
      continue;
    }
    print("Enter amount to transfer:");
    String? input = stdin.readLineSync();
    if (input == null) continue;
    input = input.trim();
    double? amount = double.tryParse(input);
    if (amount == null || amount <= 0) {
      print("INVALID AMOUNT.");
      continue;
    }
    if (amount > user['balance']) {
      print("INSUFFICIENT FUNDS. Your current balance is: \$${user['balance']}");
      continue;
    }
    user['balance'] -= amount;
    recipient['balance'] += amount;
    print("Transferred \$${amount} to ${recipient['name']}. New balance: \$${user['balance']}");
    updateUserInList(recipient, allUsers);
    break;
  }
  return user;
}

// Change PIN logic
Map<String, dynamic> ChangePin(Map<String, dynamic> user) {
  print("Change PIN");

  // Verify current PIN first for security
  print("For security, please enter your current PIN:");
  String? currentPin = stdin.readLineSync();

  if (currentPin == null ||
      currentPin.isEmpty ||
      currentPin != user['pin'].toString()) {
    print("Invalid PIN. PIN change canceled.");
    return user;
  }

  // Get new PIN
  while (true) {
    print("Enter your new PIN (4 digits):");
    String? newPin = stdin.readLineSync();

    if (newPin == null || newPin.isEmpty) {
      print("Invalid input. Please try again.");
      continue;
    }

    // Validate PIN format - should be numeric and ideally 4 digits
    int? pinValue = int.tryParse(newPin);
    if (pinValue == null) {
      print("PIN must contain only numbers. Please try again.");
      continue;
    }

    if (newPin.length != 4) {
      print("PIN must be exactly 4 digits. Please try again.");
      continue;
    }

    // Confirm new PIN
    print("Confirm your new PIN:");
    String? confirmPin = stdin.readLineSync();

    if (confirmPin != newPin) {
      print("PINs do not match. Please try again.");
      continue;
    }

    // Update PIN
    user['pin'] = pinValue;
    print("Your PIN has been successfully changed!");
    break;
  }

  return user;
}