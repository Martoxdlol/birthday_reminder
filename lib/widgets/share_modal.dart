import 'package:flutter/material.dart';

class ShareModal extends StatelessWidget {
  const ShareModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
    );
  }
}

void showShareModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return ShareModal();
    },
  );
}
