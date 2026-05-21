import 'dart:convert';
import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;
import '../Constant/Myconstant.dart';

dynamic captureAndConvertToBase64(base64String, Name, foder) async {
  // final boundary =
  //     chartKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
  // final image =
  //     await boundary.toImage(pixelRatio: 3.0); // Adjust pixelRatio as needed

  // // Convert the captured image to bytes
  // final byteData = await image.toByteData(format: ImageByteFormat.png);
  // final buffer = byteData!.buffer.asUint8List();

  // // Encode the bytes to base64
  // final base64String = base64Encode(buffer);
  int timestamp = DateTime.now().millisecondsSinceEpoch;
  //print(base64String);
  String fileName = '${Name}_$timestamp.png';
  await Future.delayed(Duration(milliseconds: 100));
  String Foder_ = '';
  try {
    final url =
        '${MyConstant().domain_chao}/File_downloadImg.php?name=$fileName&Foder=$Foder_';

    final response = await http.post(
      Uri.parse(url),
      body: {
        'image': base64String,
        'Foder': Foder_,
        'name': fileName
      }, // Send the image as a form field named 'image'
    );

    if (response.statusCode == 200) {
      // print('Image uploaded successfully');
      downloadImage(fileName, foder);
      // downloadImage('${MyConstant().domain}/files/$foder/contract/$Form_Img_',
      //         '${Form_Img_}')
      //     .deleteFile(fileName_Slip);
    } else {
      //print('Image upload failed');
    }
  } catch (e) {
    //print('Error during image processing: $e');
  }

  // return base64String;
}

Future<void> downloadImage(fileName, foder) async {
  dynamic Url_ = 'https://chaoperties.com/#/';
  String new_Url =
      '${Url_.toString().substring(0, Url_.toString().length - 3)}/chao_api';
  try {
    // first we make a request to the url like you did
    // in the android and ios version
    final http.Response r = await http.get(
      Uri.parse('${new_Url}/Awaitdownload/$fileName'),
    );

    // we get the bytes from the body
    final data = r.bodyBytes;
    // and encode them to base64
    final base64data = base64Encode(data);

    // then we create and AnchorElement with the html package
    final a = html.AnchorElement(href: 'data:image/jpeg;base64,$base64data');

    // set the name of the file we want the image to get
    // downloaded to
    a.download = 'Load_$fileName.png';

    // and we click the AnchorElement which downloads the image
    a.click();
    await Future.delayed(Duration(seconds: 2));
    deleteFile(fileName);
    // finally we remove the AnchorElement
    a.remove();
  } catch (e) {
    deleteFile(fileName);
    //print(e);
  }
}

// dynamic downloadImage(fileName, foder) async {
//   try {
//     // first we make a request to the url like you did
//     // in the android and ios version
//     final http.Response r = await http.get(
//       Uri.parse('${MyConstant().domain_chao}/chao_api/Awaitdownload/$fileName'),
//     );

//     // we get the bytes from the body
//     final data = r.bodyBytes;
//     // and encode them to base64
//     final base64data = base64Encode(data);

//     // then we create and AnchorElement with the html package
//     final a = html.AnchorElement(href: 'data:image/jpeg;base64,$base64data');

//     // set the name of the file we want the image to get
//     // downloaded to
//     a.download = 'Load_$fileName.png';

//     // and we click the AnchorElement which downloads the image
//     a.click();
//     // finally we remove the AnchorElement
//     a.remove();
//     await Future.delayed(Duration(seconds: 5));
//     deleteFile(fileName);
//   } catch (e) {
//     print(e);
//     deleteFile(fileName);
//   }
// }

dynamic deleteFile(fileName) async {
  String url =
      '${MyConstant().domain_chao}/File_Deleted_downloadImg.php?name=$fileName';

  try {
    var response = await http.get(Uri.parse(url));

    var result = json.decode(response.body);
    if (response.statusCode == 200) {
      final responseBody = response.body;
      if (responseBody == 'File deleted successfully.') {
//print('File deleted successfully!');
      } else {
//print('Failed to delete file: $responseBody');
      }
    } else {
      /// print('Failed to delete file. Status code: ${response.statusCode}');
    }
  } catch (e) {
    ///print('An error occurred: $e');
  }
}
