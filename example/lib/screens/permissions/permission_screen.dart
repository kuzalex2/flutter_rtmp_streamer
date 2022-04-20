
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rtmp_streamer_example/screens/permissions/permission_button.dart';
import 'package:flutter_rtmp_streamer_example/screens/permissions/permission_icon.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../bloc/permission.dart';


///
///

class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({Key? key, required this.permissionState}) : super(key: key);

  final PermissionState permissionState;

  String _getDescription() {
    if (permissionState.camStatus.isDenied && permissionState.micStatus.isDenied) {
      return "You can give access to camera and microphone in";
    } else if (permissionState.camStatus.isDenied) {
      return "You can give access to camera in";
    } else if (permissionState.micStatus.isDenied) {
      return "You can give access to microphone in";
    } else {
      return "A little more and you will be able to start broadcasting";
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal:20.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Text(
                "Permissions to use camera and microphone".toUpperCase(),
                textAlign: TextAlign.center,
                style: textTheme.bodyText1,
              ),
              Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      PermissionIcon(
                          permissionType: PermissionType.cam,
                          permissionStatus: permissionState.camStatus
                      ),
                      PermissionIcon(
                        permissionType: PermissionType.mic,
                        permissionStatus: permissionState.micStatus,
                      )
                    ],
                  )
              ),

              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan( text: _getDescription(), style: textTheme.bodyText1,),


                    TextSpan(
                      text: permissionState.camStatus.isDenied || permissionState.micStatus.isDenied ? " Settings" : "",
                      style: textTheme.bodyText1?.copyWith(color: Colors.blue),
                      recognizer: TapGestureRecognizer()..onTap = openAppSettings,
                    ),
                  ],
                ),
              ),


              const SizedBox(height: 24),
              Visibility(
                visible: permissionState.camStatus.isUndetermined || permissionState.micStatus.isUndetermined,
                replacement: const SizedBox(height: 40),
                child: Column(
                  children: [
                    PermissionButton(
                      label:  "Enable camera",
                      permissionStatus: permissionState.camStatus,
                      onPressed: context.read<PermissionCubit>().requestCamPermission
                    ),
                    const SizedBox(height: 24),
                    PermissionButton(
                      label:  "Enable microphone",
                      permissionStatus: permissionState.micStatus,
                      onPressed: context.read<PermissionCubit>().requestMicPermission
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



