import 'package:flutter/material.dart';
import 'package:smrobotics/constants.dart';


class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  
  @override
  void initState() {
    super.initState();

    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SM Robotics"),
      ),
      body: FutureBuilder(
      ),
    );
  }
}