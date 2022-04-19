
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';
import '../../bloc/permission.dart';

enum PermissionType {
  cam,
  mic,
}

class PermissionIcon extends StatelessWidget {
  final PermissionType permissionType;
  final MyPermissionStatus permissionStatus;

  const PermissionIcon({
    Key? key,
    required this.permissionType,
    required this.permissionStatus,
  }) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return Icon(_getIcon(), size: 45, color: _getColor());

  }

  IconData _getIcon() {
    switch (permissionType) {
      case PermissionType.cam:
        if (permissionStatus.isDenied ) {
          return UniconsLine.video_slash;
        }
        return UniconsLine.video;
      case PermissionType.mic:
      default:
        if (permissionStatus.isDenied ) {
          return UniconsLine.microphone_slash;
        }
        return UniconsLine.microphone;
    }
  }

  Color _getColor() {

    return permissionStatus.isGranted
        ? Colors.blue
        : permissionStatus.isDenied
        ? Colors.red
        : Colors.white70;
  }
}
