import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:deenify/main.dart';

class loginpage extends StatelessWidget{
  loginpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
        Text("Hello"),
        ElevatedButton(onPressed: (){
          Navigator.push(context,MaterialPageRoute(builder: (context) => SidebarXExampleApp()));
        },
            child: Text("Press", style: TextStyle(color: Colors.white),)
        ),
        ],
      ),
    );
  }
}