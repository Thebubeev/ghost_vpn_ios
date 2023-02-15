import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ghost_vpn_ios/bloc/vpn_auth/vpn_auth_bloc.dart';
import 'package:ghost_vpn_ios/bloc/vpn_bloc/vpn_bloc.dart';
import 'package:ghost_vpn_ios/screens/services_screens/toggle_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<VpnBloc>(create: (_) => VpnBloc()),
        BlocProvider<VpnAuthBloc>(create: (_) => VpnAuthBloc())
      ],
      child: MaterialApp(
          title: 'GhostVPN',
          builder: EasyLoading.init(),
          theme: ThemeData(
              primaryColor: Colors.white,
              scaffoldBackgroundColor: Colors.white54),
          debugShowCheckedModeBanner: false,
          home: ToggleScreen()),
    );
  }
}
