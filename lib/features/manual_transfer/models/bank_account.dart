class BankAccount {
  final int id;
  final String bankName;
  final String accountName;
  final String accountNumber;
  final String? iban;
  final String? instructions;

  BankAccount({
    required this.id,
    required this.bankName,
    required this.accountName,
    required this.accountNumber,
    this.iban,
    this.instructions,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['id'],
      bankName: json['bank_name'],
      accountName: json['account_name'],
      accountNumber: json['account_number'],
      iban: json['iban'],
      instructions: json['instructions'],
    );
  }
}
