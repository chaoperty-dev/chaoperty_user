// ignore_for_file: file_names, unused_import
// flutter run -d chrome --web-browser-flag "--disable-web-security"
// flutter build web --dart-define=BROWSER_IMAGE_DECODING_ENABLED=false-browser-flag=--disable-web-security --no-tree-shake-icons
import 'package:flutter/material.dart';

class MyConstant {
  // http://localhost:3000/auth.html
  var url_ = 'https://chaoperties.com/#/';
  // var urlchaoise_ = 'https://dzentric.com/chao_perty/chao_api_user';
  ///////////------------------------------------------------------------->
  // dynamic Url_ = 'https://dzentric.com/chao_perty/#/';

  // String domain = 'https://dzentric.com/chaoperty_user/chao_api_user';
  // String domain_img = 'https://www.dzentric.com/chao_perty/chao_api';
  // String domain_chao = 'https://www.dzentric.com/chao_perty/chao_api';
  // var urlr_ = 'https://chaoperties.com/user/#/';

  ///////////------------------------------------------------------------->

  // String domain =
  //     '${'https://chaoperties.com/Choice/user/#/'.substring(0, 'https://chaoperties.com/Choice/user/#/'.length - 3)}/chao_api_user';
  // String domain_img =
  //     '${'https://chaoperties.com/Choice/user/#/'.substring(0, 'https://chaoperties.com/Choice/user/#/'.length - 8)}/chao_api';
  // String domain_chao =
  //     '${'https://chaoperties.com/Choice/user/#/'.substring(0, 'https://chaoperties.com/Choice/user/#/'.length - 8)}/chao_api';
  // String domain_chaoV2 =
  //     '${'https://chaoperties.com/Choice/user/#/'.substring(0, 'https://chaoperties.com/Choice/user/#/'.length - 8)}/chao_api/v2/choice';
  // String domain_chao_img =
  //     '${'https://chaoperties.com/Choice/user/#/'.substring(0, 'https://chaoperties.com/Choice/user/#/'.length - 8)}';
  ///////////------------------------------------------------------------->
  ///
  String get _baseUrl {
    final url = Uri.base.toString();
    if (url.contains('/user_test/')) {
      return 'https://chaoperties.com/user_test/';
    } else if (url.contains('/Choice/user/')) {
      return 'https://chaoperties.com/Choice/user/';
    } else if (url.contains('/user_intents/')) {
      return 'https://chaoperties.com/user_intents/';
    } else {
      // return 'http://192.168.1.227/';
      return 'https://chaoperties.com/user/';
    }
  }

  String get domain => _baseUrl + 'chao_api_user';
  String get domain_img => 'https://chaoperties.com/chao_api';
  String get domain_chao => 'https://chaoperties.com/chao_api';

  ///////////------------------------------------------------------------->
  ///
  // String domain = 'https://chaoperties.com/user/chao_api_user';
  // String domain_img = 'https://chaoperties.com/chao_api';
  // String domain_chao = 'https://chaoperties.com/chao_api';
  String domain_chaoV2 = 'https://chaoperties.com/chao_api/v2/choice';
  String domain_choice = 'https://chaoperties.com/Choice/chao_api';
  String domain_chao_img = 'https://chaoperties.com/chao_api';
  // String domain_chao_test = 'https://chaoperties.com/Admin_Test/chao_api';

  ///////////------------------------------------------------------------->
  // String domain = 'https://chaoperties.com/Choice/user/chao_api_user';
  // String domain_img = 'https://chaoperties.com/Choice/chao_api';
  // String domain_chao = 'https://chaoperties.com/Choice/chao_api';
  // String domain_chaoV2 = 'https://chaoperties.com/Choice/chao_api/v2/choice';
  // String domain_chao_img = 'https://chaoperties.com/Choice';

  // String domain = 'http://192.168.1.227/chao_api/user/chao_api_user';
//   String domain_img = 'http://192.168.1.227/chao_api';
  // String domain_chao = 'http://192.168.1.227/chao_api';
  ///////////------------------------------------------------------------->
  // String domain =
  //     '${Uri.base.toString().substring(0, Uri.base.toString().length - 3)}/chao_api_user';
  // String domain_img =
  //     '${Uri.base.toString().substring(0, Uri.base.toString().length - 8)}/chao_api';
  // String domain_chao =
  //     '${Uri.base.toString().substring(0, Uri.base.toString().length - 8)}/chao_api';

  // String domain = 'http://tananuwat.dynns.com:8080/APIQ';
  // String domain = 'http://goodviewcmu.cnxsolution.net:94/APIQ';
  // http://tananuwat.dynns.com:7080/webQR/#?1658194561/18,T01
  // String domain = 'http://192.168.1.23/chao_api';
  // String domain_= 'http://192.168.1.152/chao_api_user';
}

// class MyImage {
//   String domainActivity = 'https://mbstar.co.th/admin/files/activity/';
//   String domainCar = 'https://mbstar.co.th/admin/files/car/';
//   String domainCard = 'https://mbstar.co.th/admin/files/card/';
//   String domainCover = 'https://mbstar.co.th/admin/files/cover/';
//   String domainPromotion = 'https://mbstar.co.th/admin/files/promotion/';
//   String domainSalary = 'https://mbstar.co.th/admin/files/salary/';
//   String domainheaderweb_img =
//       'https://mbstar.co.th/admin/files/headerweb_img/';
// }
