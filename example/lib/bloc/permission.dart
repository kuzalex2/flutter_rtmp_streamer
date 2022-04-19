

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  bool get isDenied => this == MyPermissionStatus.denied  || this == MyPermissionStatus.permanentlyDenied || this == MyPermissionStatus.restricted;

  bool get isGranted => this == MyPermissionStatus.granted || this == MyPermissionStatus.limited;

  // bool get isRestricted => this == MyPermissionStatus.restricted;
  // bool get isLimited => this == MyPermissionStatus.limited;

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

  const PermissionState( {
    required this.camStatus,
    required this.micStatus,
  });

  static const unknown = PermissionState(
      micStatus: MyPermissionStatus.unknown,
      camStatus:  MyPermissionStatus.unknown,
  );

  PermissionState copyWith({
    MyPermissionStatus? camStatus,
    MyPermissionStatus? micStatus,

  }) {
    return PermissionState(
      camStatus: camStatus ?? this.camStatus,
      micStatus: micStatus ?? this.micStatus,
    );
  }

  @override
  List<Object> get props => [
    camStatus,
    micStatus,
    // isPermissionStatusKnown,
  ];
}

class _SharedPrefs {

  late final SharedPreferences _prefs;

  ///
  ///
  /// isMicPermissionKnown/isCamPermissionKnown
  ///

  bool get isMicPermissionKnown => _prefs.getBool("isMicPermissionKnown") ?? false;

  set isMicPermissionKnown(bool value)  {
    _prefs.setBool("isMicPermissionKnown", value);
  }

  bool get isCamPermissionKnown => _prefs.getBool("isCamPermissionKnown") ?? false;

  set isCamPermissionKnown(bool value)  {
    _prefs.setBool("isCamPermissionKnown", value);
  }
}


class PermissionCubit extends Cubit<PermissionState> with _SharedPrefs {




  PermissionCubit({required PermissionState permissionState}) : super(permissionState)
  {
    _init();
  }

  _init() async {
    _prefs = await SharedPreferences.getInstance();

    await Future.delayed(const Duration(milliseconds: 400));

    if (isMicPermissionKnown) {
      Permission.microphone.status.then((value) {
        emit(state.copyWith(
            micStatus: MyPermissionStatusGetters.create(value)));
        isMicPermissionKnown = true;
      });
    } else {
      emit(state.copyWith(micStatus: MyPermissionStatus.undetermined));
    }

    if (isCamPermissionKnown) {
      Permission.camera.status.then((value) {
        emit(state.copyWith(
            camStatus: MyPermissionStatusGetters.create(value)));
        isCamPermissionKnown = true;
      });
    } else {
      emit(state.copyWith(camStatus: MyPermissionStatus.undetermined));
    }
  }

  Future<void> requestCamPermission() async {

    if (state.camStatus.isUndetermined) {
      final value = await Permission.camera.request();

      isCamPermissionKnown=true;
      emit(state.copyWith(camStatus: MyPermissionStatusGetters.create(value)));
    }

  }

  Future<void> requestMicPermission() async {
    if (state.micStatus.isUndetermined) {
      final value = await Permission.microphone.request();

      isMicPermissionKnown=true;
      emit(state.copyWith(micStatus: MyPermissionStatusGetters.create(value)));
    }
  }

}
