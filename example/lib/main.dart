
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rtmp_streamer_example/screens/loader.dart';
import 'package:flutter_rtmp_streamer_example/screens/permission_denied.dart';

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

        theme: ThemeData(
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
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

          return const PermissionDeniedScreen();

          if (state.isPermissionStatusUnknown) {
            return const Loader();
          }

          if (state.allPermissionsAreNotGranted){
            return const PermissionDeniedScreen(/*micStatus: state.micStatus, camStatus: styate.camStatus*/);
          }

          return const CameraScreen();
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





