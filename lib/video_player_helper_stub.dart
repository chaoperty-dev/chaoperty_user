import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showInlineVideoDialog(BuildContext context, String url) async {
  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}
