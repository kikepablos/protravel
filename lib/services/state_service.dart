import 'package:velocity_x/velocity_x.dart';
import '../models/user_model.dart';

class AppStore extends VxStore {
  UserModel user = UserModel();
}

class UpdateUser extends VxMutation<AppStore> {
  final UserModel user;
  UpdateUser(this.user);
  @override
  perform() {
    store!.user = user;
  }
}
