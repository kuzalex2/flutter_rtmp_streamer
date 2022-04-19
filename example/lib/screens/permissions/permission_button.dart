
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';
import '../../bloc/permission.dart';


class PermissionButton extends StatelessWidget {
  final String label;
  final MyPermissionStatus permissionStatus;
  final VoidCallback? onPressed;

  const PermissionButton({
    Key? key,
    required this.label,
    required this.permissionStatus,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    if (permissionStatus.isUndetermined){
      return _Button(
        label: label,
        onPressed: onPressed,
      );
    }

    if (permissionStatus.isGranted ){

      return _Button(
        label: '✓ $label',
        backgroudColor: Colors.green,
        onPressed: null,
      );

    }

    return _Button(
      label: '✗ $label',
      onPressed: null,
    );
  }
}


class _Button extends StatelessWidget {

  final String label;
  final VoidCallback? onPressed;
  final Color? backgroudColor;

  const _Button({
    Key? key,
    required this.label,
    required this.onPressed,
    this.backgroudColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final textTheme = Theme.of(context).textTheme;

    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: backgroudColor!=null ? MaterialStateProperty.all(backgroudColor) : null,
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              )
          )
      ),
      child: SizedBox(
          width: double.infinity,
          height: 40,
          child: Center(child: Text(label,style: textTheme.bodyText1,))
      ),
      onPressed: onPressed,
    );
  }
}