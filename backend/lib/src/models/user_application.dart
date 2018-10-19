import 'package:angel_model/angel_model.dart';
import 'package:angel_serialize/angel_serialize.dart';
part 'user_application.g.dart';
part 'user_application.serializer.g.dart';

@serializable
abstract class _UserApplication extends Model {
  String get name;

  String get path;
}
