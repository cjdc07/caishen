import 'package:cjdc_money_manager/user_profile/user_profile_model.dart';
import 'package:flutter/material.dart';

class UserProfileNotifier extends ChangeNotifier {
  UserProfile _userProfile;

  UserProfile getUserProfile() => _userProfile;

  void setUserProfile(UserProfile userProfile, {bool notify = false}) {
    _userProfile = userProfile;
    if (notify) {
      notifyListeners();
    }
  }
}
