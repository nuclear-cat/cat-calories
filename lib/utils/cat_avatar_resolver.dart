import 'package:cat_calories/models/profile_model.dart';
import 'package:flutter/widgets.dart';

class CatAvatarResolver {
  static AssetImage getImageByProfle(ProfileModel profile) {

    // TODO: Сделать выбор картинки по последней цифре в ID

    return AssetImage('images/cats/cat_face_00.jpg');
  }
}
