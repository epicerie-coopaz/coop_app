import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_model.dart';

class Loading extends StatelessWidget {
  const Loading({super.key, required this.text});
  
  final String text;

  @override
  Widget build(BuildContext context) {
    AppModel appModel = context.watch<AppModel>();
    return Center(
        child: Column(children: [
      const SizedBox(
        width: 60,
        height: 60,
        child: CircularProgressIndicator(),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Text(text, textScaleFactor: appModel.zoomText),
      ),
    ]));
  }
}
