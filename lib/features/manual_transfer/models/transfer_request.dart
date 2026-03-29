import 'package:naqde_user/features/manual_transfer/models/bank_account.dart';

class TransferRequest {
  final int id;
  final int bankAccountId;
  final double amount;
  final String transactionReference;
  final String? senderName;
  final String status;
  final String? paymentScreenshot;
  final DateTime createdAt;
  final BankAccount? bankAccount;

  TransferRequest({
    required this.id,
    required this.bankAccountId,
    required this.amount,
    required this.transactionReference,
    this.senderName,
    required this.status,
    this.paymentScreenshot,
    required this.createdAt,
    this.bankAccount,
  });

  factory TransferRequest.fromJson(Map<String, dynamic> json) {
    return TransferRequest(
      id: json['id'],
      bankAccountId: json['bank_account_id'],
      amount: double.parse(json['amount'].toString()),
      transactionReference: json['transaction_reference'],
      senderName: json['sender_name'],
      status: json['status'],
      paymentScreenshot: json['payment_screenshot'],
      createdAt: DateTime.parse(json['created_at']),
      bankAccount: json['bank_account'] != null
          ? BankAccount.fromJson(json['bank_account'])
          : null,
    );
  }

  String get statusText {
    switch (status) {
      case 'pending': return 'Pending Approval';
      case 'approved': return 'Approved';
      case 'rejected': return 'Rejected';
      case 'expired': return 'Expired';
      default: return status;
    }
  }
}
