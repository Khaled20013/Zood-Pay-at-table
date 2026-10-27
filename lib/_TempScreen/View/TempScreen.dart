import 'package:flutter/material.dart';

import '../Controller/TempController.dart';

class TempScreen extends StatefulWidget {
  const TempScreen({super.key});
  static const String routeName = "/TempScreen";

  @override
  TempScreenState createState() => TempScreenState();
}

class TempScreenState extends State<TempScreen> {
  late TempController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TempController(refresh);
    _controller.onInit();
  }

  void refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Container());
  }
}
