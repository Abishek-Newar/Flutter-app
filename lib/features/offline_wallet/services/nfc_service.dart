// lib/features/offline_wallet/services/nfc_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:ndef/ndef.dart' as ndef;
import '../domain/models/offline_wallet_models.dart';

class NFCService {
  final _eventCtrl = StreamController<NFCEvent>.broadcast();
  Stream<NFCEvent> get nfcEvents => _eventCtrl.stream;

  bool _sessionActive = false;

  Future<bool> isNfcAvailable() async {
    try {
      final availability = await FlutterNfcKit.nfcAvailability;
      return availability == NFCAvailability.available;
    } catch (_) {
      return false;
    }
  }

  Future<void> initialize() async {
    // No persistent initialization needed for flutter_nfc_kit
  }

  /// Write a SignedTransaction to an NFC tag
  Future<void> writeTransaction(SignedTransaction tx) async {
    if (_sessionActive) return;
    _sessionActive = true;
    try {
      await FlutterNfcKit.poll(
        timeout: const Duration(seconds: 20),
        iosAlertMessage: 'Hold your iPhone near the recipient\'s device',
      );
      final payload = jsonEncode(tx.toJson());
      await FlutterNfcKit.writeNDEFRecords([
        ndef.TextRecord(text: payload),
      ]);
      _eventCtrl.add(const NFCEvent(type: NFCEventType.writeSuccess));
    } catch (e) {
      _eventCtrl.add(NFCEvent(
        type: NFCEventType.error,
        data: {'message': e.toString()},
      ));
    } finally {
      await stopSession();
    }
  }

  /// Listen for an incoming NFC tag containing a transaction
  Future<void> startReading() async {
    if (_sessionActive) return;
    _sessionActive = true;
    try {
      await FlutterNfcKit.poll(
        timeout: const Duration(seconds: 30),
        iosAlertMessage: 'Hold your iPhone near the sender\'s device',
      );
      final records = await FlutterNfcKit.readNDEFRecords(cached: false);
      if (records.isNotEmpty) {
        final raw = records.first.payload;
        if (raw != null) {
          _eventCtrl.add(NFCEvent(
            type: NFCEventType.transactionReceived,
            data: {'payload': raw},
          ));
        }
      }
    } catch (e) {
      _eventCtrl.add(NFCEvent(
        type: NFCEventType.error,
        data: {'message': e.toString()},
      ));
    } finally {
      await stopSession();
    }
  }

  Future<void> stopSession({String? alertMessage}) async {
    _sessionActive = false;
    try {
      await FlutterNfcKit.finish(iosAlertMessage: alertMessage);
    } catch (_) {}
  }

  void dispose() {
    _eventCtrl.close();
  }
}
