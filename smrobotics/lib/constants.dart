import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:url_launcher/url_launcher.dart';

import 'config.dart';

String baseURL = "https://theorangealliance.org/api/";

Map<String, String> requiredHeadersWithSeason = {
  "Content-Type":"application/json",
  "X-TOA-Key":apiKey,
  "X-Application-Origin":"SM Robotics",
  "season_key":currentSeason
};
Map<String, String> requiredHeadersWithoutSeason = {
  "Content-Type":"application/json",
  "X-TOA-Key":apiKey,
  "X-Application-Origin":"SM Robotics",
};

launchWebview(BuildContext context, {@required String url, @required String title}){
  launch(url);
  // Navigator.of(context).push(
  //   MaterialPageRoute(
  //     fullscreenDialog: true,
  //     maintainState: true,
  //     builder: (c)=>WebviewScaffold(
  //       appBar: AppBar(
  //         title: Text(title),
  //         actions: <Widget>[
  //           IconButton(icon: Icon(Icons.launch),onPressed: ()=>launch(url),)
  //         ],
          
  //       ),
  //       url: url,
  //       allowFileURLs: true,
  //       withJavascript: true,
  //     )
  //   )
  // );
}