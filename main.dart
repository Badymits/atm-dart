import 'dart:io';

void main() {
  login();
}

void login() {
  var pin = '1234';
  int tries = 0;

  while (tries < 3) {
    stdout.write('Please enter your PIN:');
    String? enteredPin = stdin.readLineSync();
    if (enteredPin == pin) {
      print("\nLogin successful!");
      mainPortal();
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

void mainPortal() {
  double balance = 1000; // balance changed to double for more accurate calculations
  print('Welcome to the ATM Portal!');
  print("This project is for educational purposes only.");

  // maybe add a while loop to keep the menu open until the user chooses to exit(?)
  while (true) {
    print("Please select an option:");
    print("1. Check Balance");
    print("2. Deposit Money");
    print("3. Withdraw Money");
    print("4. Pay Bills");
    print("5. Transfer Money");
    print("6. Exit");

    int? choice = int.tryParse(stdin.readLineSync()!);
    switch (choice) {
      case 1:
        CheckBalance(balance);
        break;
      case 2:
        balance = DepositMoney(balance);
        break;
      case 3:
        balance = WithdrawMoney(balance);
        break;
      case 4:
        balance = PayBills(balance);
        break;
      case 5:
        balance = TransferMoney(balance);
        break;
      case 6:
        print("Exiting...");
        return;
      default:
        print("Invalid choice. Please try again.");
    }
  }
}

void CheckBalance(double balance) {
  print("Check Balance");
  // Code to check balance
  print("Your current balance is: \$${balance}");
}

// noticed that the DepositMoney and WithdrawMoney functions are mostly the same
// so I tried to refactor them to reduce redundancy
double handleTransaction(double balance, bool transactionType) {
  String transactionName = transactionType ? "Deposit" : "Withdraw";
  String transactionVerb = transactionType ? "Deposited" : "Withdrawed";

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

    if (!transactionType && amount > balance) {
      stdout.write('\x1B[1A');
      stdout.write('\x1B[2K');
      print("INSUFFICIENT FUNDS. Your current balance is: \$${balance}");
      continue;
    }

    balance = transactionType ? balance + amount : balance - amount;

    // adding success message for both deposit and withdraw
    print(
      "You have successfully $transactionVerb \$${amount}. Your new balance is: \$${balance}",
    );

    print("Transaction successful. Returning to main menu.");
    break;
  }
  return balance;
}

double DepositMoney(double balance) {
  return handleTransaction(balance, true);
}

double WithdrawMoney(double balance) {
  return handleTransaction(balance, false);
}

double PayBills(double balance) {
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
    if (amount > balance) {
      print("INSUFFICIENT FUNDS. Your current balance is: \$${balance}");
      continue;
    }
    balance -= amount;
    print("Bill of \$${amount} paid successfully. New balance: \$${balance}");
    break;
  }
  return balance;
}

double TransferMoney(double balance) {
  print("Transfer Money");
  print("Enter recipient account number (or press X and enter to cancel):");
  while (true) {
    String? account = stdin.readLineSync();
    if (account == null) continue;
    account = account.trim();
    if (account.toLowerCase() == 'x') {
      print("Transfer cancelled. Returning to main menu.");
      return balance;
    }
    if (account.isEmpty || int.tryParse(account) == null) {
      print("INVALID ACCOUNT NUMBER. Please enter a valid numeric account number.");
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
    if (amount > balance) {
      print("INSUFFICIENT FUNDS. Your current balance is: \$${balance}");
      continue;
    }
    balance -= amount;
    print("Transferred \$${amount} to account $account. New balance: \$${balance}");
    break;
  }
  return balance;
}