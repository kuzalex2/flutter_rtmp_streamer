
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rtmp_streamer_example/screens/loader.dart';
import 'package:flutter_rtmp_streamer_example/screens/permissions/permission_screen.dart';

import 'bloc/permission.dart';


void main() {
  runApp(const MyApp());
}




class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PermissionCubit>(
          create: (BuildContext context) => PermissionCubit(permissionState: PermissionState.unknown),
        )
      ],
      child: MaterialApp(


        darkTheme: ThemeData(
          brightness: Brightness.dark,
          textTheme: const TextTheme(
              bodyText1: TextStyle(fontSize: 16.0),
          ),
        ),
        themeMode: ThemeMode.dark,

        home: const AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light,
            child: MainScreen()
        ),
      )
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PermissionCubit, PermissionState>(
        builder: (context, state) {

          if (state.micStatus.isUnknown || state.camStatus.isUnknown) {
            return const Loader();
          }

          if (state.micStatus.isGranted && state.camStatus.isGranted){
            return const CameraScreen();
          }

          return PermissionsScreen(permissionState: state,);
        }
      ),

    );
  }
}



class CameraScreen extends StatelessWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}





