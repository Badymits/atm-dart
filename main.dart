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
  int balance = 1000; // Example balance, you can change it as needed
  print('Welcome to the ATM Portal!');
  print("This project is for educational purposes only.");

  print("Please select an option:");
  print("1. Check Balance");
  print("2. Deposit Money");
  print("3. Withdraw Money");
  print("4. Exit");

  // maybe add a while loop to keep the menu open until the user chooses to exit(?)
  int? choice = int.tryParse(stdin.readLineSync()!);
  switch (choice) {
    case 1:
      CheckBalance();
      break;
    case 2:
      balance = DepositMoney(balance);
      break;
    case 3:
      balance = WithdrawMoney(balance);
      break;
    case 4:
      print("Exiting...");
      break;
    default:
      print("Invalid choice. Please try again.");
  }
}

void CheckBalance() {
  print("Check Balance");
  // Code to check balance
  double balance = 1000.00; // Example balance
  print("Your current balance is: \$${balance}");
}

// noticed that the DepositMoney and WithdrawMoney functions are mostly the same
// so I tried to refactor them to reduce redundancy
int handleTransaction(int balance, bool transactionType) {
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

int DepositMoney(int balance) {
  return handleTransaction(balance, true);
}

int WithdrawMoney(int balance) {
  return handleTransaction(balance, false);
}
