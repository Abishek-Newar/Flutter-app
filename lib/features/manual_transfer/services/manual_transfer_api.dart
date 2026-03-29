import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import '../models/bank_account.dart';
import '../models/transfer_request.dart';

class ManualTransferApi {
  final String baseUrl;
  final String token;

  ManualTransferApi({required this.baseUrl, required this.token});

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $token',
    'Accept': 'application/json',
  };

  Future<List<BankAccount>> getBanks() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/manual-transfer/banks'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['data'] as List)
          .map((json) => BankAccount.fromJson(json))
          .toList();
    }
    throw Exception('Failed to load banks');
  }

  Future<Map<String, dynamic>> submitTransfer({
    required int bankAccountId,
    required double amount,
    required String reference,
    String? senderName,
    required File screenshot,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/v1/manual-transfer/submit'),
    );

    request.headers.addAll(_headers);
    request.fields['bank_account_id'] = bankAccountId.toString();
    request.fields['amount'] = amount.toString();
    request.fields['transaction_reference'] = reference;
    if (senderName != null) request.fields['sender_name'] = senderName;

    var stream = http.ByteStream(screenshot.openRead());
    var length = await screenshot.length();
    
    request.files.add(http.MultipartFile(
      'screenshot',
      stream,
      length,
      filename: basename(screenshot.path),
      contentType: MediaType('image', 'jpeg'),
    ));

    var response = await request.send();
    var responseData = await response.stream.bytesToString();

    if (response.statusCode == 201) {
      return jsonDecode(responseData);
    } else if (response.statusCode == 429) {
      throw Exception('Too many requests. Please try again later.');
    } else {
      final error = jsonDecode(responseData);
      throw Exception(error['message'] ?? error['errors']?.toString() ?? 'Submission failed');
    }
  }

  Future<List<TransferRequest>> getMyRequests() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/manual-transfer/my-requests'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['data']['data'] as List)
          .map((json) => TransferRequest.fromJson(json))
          .toList();
    }
    throw Exception('Failed to load requests');
  }
}
