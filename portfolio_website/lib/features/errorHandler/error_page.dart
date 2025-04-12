import 'package:flutter/material.dart';
import 'package:portfolio_website/utils/constants/strings.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(child: Text(MyAppStrings.errorString));
  }
}
