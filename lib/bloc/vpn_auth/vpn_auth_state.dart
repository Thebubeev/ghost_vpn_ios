import 'package:flutter/foundation.dart';

@immutable
abstract class VpnAuthState {}

class VpnAuthInitial extends VpnAuthState {}

class VpnAuthNavigatorState extends VpnAuthState {}

class VpnAuthLoginToastState extends VpnAuthState {}

class VpnAuthRegisterToastState extends VpnAuthState {}

class VpnAuthRecoveryPasswordState extends VpnAuthState {}

class VpnAuthPromoDataState extends VpnAuthState {}

class VpnAuthErrorState extends VpnAuthState {
  final String warning;
  VpnAuthErrorState({required this.warning});
}
