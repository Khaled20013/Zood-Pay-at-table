import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Helper/kPrint.dart';

class MyBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    kLog('onCreate -- ${bloc.runtimeType}', logType: kLogType.info);
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    kLog('onChange -- ${bloc.runtimeType}, $change', logType: kLogType.info);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    kLog('onError -- ${bloc.runtimeType}, $error', logType: kLogType.info);
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    kLog('onClose -- ${bloc.runtimeType}', logType: kLogType.info);
  }
}
