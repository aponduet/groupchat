import 'package:flutter/material.dart';

class ServerHome extends StatefulWidget {
  const ServerHome({Key? key}) : super(key: key);

  @override
  _ServerHomeState createState() => _ServerHomeState();
}

class _ServerHomeState extends State<ServerHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Server"),
      ),
      body: Container(
        child: const Center(
          child: Text("I am Server"),
        ),
      ),
    );
  }
}
