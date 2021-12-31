import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_demo_image/pages/file_cached_page.dart';
import 'package:flutter_demo_image/pages/image_page.dart';
import 'package:flutter_example/flutter_example.dart';

void main() {
  //
  CachedNetworkImage.logLevel = CacheManagerLogLevel.debug;

  //
  runApp(ExampleHomePage(
    pages: [
      ImagePage.createPage(),
      ImageListPage.createPage(),
      ImageGridPage.createPage(),
      FilePage.createPage(),
    ],
    appName: 'Demo',
    pubUrl: 'https://github.com/',
    repoUrl: 'https://pub.dev/packages/',
  ));
}
