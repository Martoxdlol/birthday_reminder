import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Hyperlink extends StatelessWidget {
  const Hyperlink({
    super.key,
    required this.child,
    required this.url,
  });
  final Widget child;
  final String url;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: DefaultTextStyle(
        style: DefaultTextStyle.of(context).style.copyWith(
              color: Colors.blue,
            ),
        child: child,
      ),
      onTap: () => launchUrl(Uri.parse(url)),
    );
  }
}
