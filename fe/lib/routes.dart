import 'package:fe/main.dart';
import 'package:fe/src/screens/profile_page.dart';
import 'package:flutter/material.dart';

import 'package:fe/src/screens/board_list.dart';

final routes = {
  '/': (BuildContext context) => MyProfile(),
  '/board': (BuildContext context) => BoardListPage(),
};
