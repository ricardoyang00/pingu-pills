import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'API_KEY')
  static const String API_KEY = _Env.API_KEY;

  @EnviedField(varName: 'PROJECT_ID')
  static const String PROJECT_ID = _Env.PROJECT_ID;

  @EnviedField(varName: 'MESSAGING_SENDER_ID')
  static const String MESSAGING_SENDER_ID = _Env.MESSAGING_SENDER_ID;

  @EnviedField(varName: 'APP_ID')
  static const String APP_ID = _Env.APP_ID;
}