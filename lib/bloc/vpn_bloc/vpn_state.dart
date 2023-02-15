import 'package:flutter/foundation.dart';

@immutable
abstract class VpnState {}

class VpnInitialState extends VpnState {}

class VpnConnectedState extends VpnState {
  final bool isConnected;
  final dynamic chatDocId;
  VpnConnectedState({required this.isConnected, required this.chatDocId});
}

class VpnDisconnectedState extends VpnState {}

class VpnSubscriptionPaidState extends VpnState {}

class VpnLoadingState extends VpnState {}

class VpnReturnState extends VpnState {}

class VpnErrorState extends VpnState {}
