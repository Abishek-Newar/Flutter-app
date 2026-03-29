import 'package:flutter/material.dart';

class GlobalKeyManagerModel {
  final GlobalKey appbarBalanceKey;
  final GlobalKey sendMoneyKey;
  final GlobalKey cashOutKey;
  final GlobalKey addMoneyKey;
  final GlobalKey requestMoneyKey;
  final GlobalKey sendMoneyRequestKey;
  final GlobalKey withdrawKey;
  final GlobalKey scrollableKey;

  // Row-2 keys (must be distinct from Row-1 keys to avoid GlobalKey conflicts)
  final GlobalKey sendAbroadKey;
  final GlobalKey offlineWalletKey;
  final GlobalKey referFriendKey;

  // List to store all the keys
  final List<GlobalKey> visibleKeys = [];

  // Constructor to initialize all the keys
  GlobalKeyManagerModel()
      : appbarBalanceKey = GlobalKey(),
        sendMoneyKey = GlobalKey(),
        cashOutKey = GlobalKey(),
        addMoneyKey = GlobalKey(),
        requestMoneyKey = GlobalKey(),
        sendMoneyRequestKey = GlobalKey(),
        withdrawKey = GlobalKey(),
        scrollableKey = GlobalKey(),
        sendAbroadKey = GlobalKey(),
        offlineWalletKey = GlobalKey(),
        referFriendKey = GlobalKey() {
    // Initialize the list with all the keys
    visibleKeys.addAll([
      appbarBalanceKey,
      sendMoneyKey,
      cashOutKey,
      addMoneyKey,
      requestMoneyKey,
      sendMoneyRequestKey,
      withdrawKey,
      scrollableKey,
    ]);
  }

  // Method to get the list of all keys
  List<GlobalKey> getAllKeys() {
    return visibleKeys;
  }
}