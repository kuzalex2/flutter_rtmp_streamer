

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:permission_handler/permission_handler.dart';

enum MyPermissionStatus {
  unknown,
  undetermined,
  denied,
  granted,
  restricted,
  limited,
  permanentlyDenied,
}

extension MyPermissionStatusGetters on MyPermissionStatus {

  bool get isUnknown => this == MyPermissionStatus.unknown;

  bool get isUndetermined => this == MyPermissionStatus.undetermined;

  bool get isDenied => this == MyPermissionStatus.denied;

  bool get isGranted => this == MyPermissionStatus.granted;

  bool get isRestricted => this == MyPermissionStatus.restricted;

  bool get isPermanentlyDenied => this == MyPermissionStatus.permanentlyDenied;

  bool get isLimited => this == MyPermissionStatus.limited;

  static MyPermissionStatus create(PermissionStatus status){
    switch(status){
      case PermissionStatus.denied: return MyPermissionStatus.denied;
      case PermissionStatus.granted: return MyPermissionStatus.granted;
      case PermissionStatus.restricted: return MyPermissionStatus.restricted;
      case PermissionStatus.limited: return MyPermissionStatus.limited;
      case PermissionStatus.permanentlyDenied: return MyPermissionStatus.permanentlyDenied;
    }

  }
}

class PermissionState extends Equatable {

  final MyPermissionStatus camStatus;
  final MyPermissionStatus micStatus;
  final bool isPermissionStatusKnown;

  bool get isPermissionStatusUnknown => !isPermissionStatusKnown;

  bool get allPermissionsAreGranted => camStatus.isGranted && micStatus.isGranted;
  bool get allPermissionsAreNotGranted => !allPermissionsAreGranted;

  const PermissionState( {
    required this.camStatus,
    required this.micStatus,
    required this.isPermissionStatusKnown,
  });

  static const unknown = PermissionState(
      micStatus: PermissionStatus.denied,
      camStatus: PermissionStatus.denied,
      isPermissionStatusKnown: false
  );

  PermissionState copyWith({
    PermissionStatus? camStatus,
    PermissionStatus? micStatus,
    bool? isPermissionStatusKnown,

  }) {
    return PermissionState(
      camStatus: camStatus ?? this.camStatus,
      micStatus: micStatus ?? this.micStatus,
      isPermissionStatusKnown: isPermissionStatusKnown ?? this.isPermissionStatusKnown,
    );
  }

  @override
  List<Object> get props => [
    camStatus,
    micStatus,
    isPermissionStatusKnown,
  ];
}


class PermissionCubit extends Cubit<PermissionState> {

  PermissionCubit({required PermissionState permissionState}) : super(permissionState)
  {

  }

}
