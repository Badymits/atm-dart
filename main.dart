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
  print('Welcome to the ATM Project!');
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
      DepositMoney();
      break;
    case 3:
      WithdrawMoney();
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

void DepositMoney() {
  print("Deposit Money");
  // Code to deposit money
}

void WithdrawMoney() {
  print("Withdraw Money");
  // Code to withdraw money
}
