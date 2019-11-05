import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:smrobotics/config.dart';

class GameTimer extends StatefulWidget {
  @override
  _GameTimerState createState() => _GameTimerState();
}

class _GameTimerState extends State<GameTimer> with TickerProviderStateMixin{

  AnimationController timerController;
  AnimationController playButtonController;

  int time = 150;
//time
  @override
  void initState() {
    super.initState();
    timerController = new AnimationController(
      vsync: this,
      duration: Duration(seconds: 5),
    );
    playButtonController = new AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200)
    );

    timerController.addListener((){
      
      if(timerController.value==0){
        playButtonController.reverse();
      }
    });

  }

  @override
  Widget build(BuildContext context) {
       return Scaffold(
         appBar: AppBar(title: Text("Game Timer"),),
         floatingActionButton: FloatingActionButton(
           heroTag: "Play Button",
            onPressed: () {
              if (timerController.isAnimating){
                timerController.stop();
                playButtonController.reverse();
              }else {
                timerController.reverse(from: timerController.value == 0.0 ? 1.0: timerController.value);
                playButtonController.forward();
              }
            },
            child: AnimatedIcon(icon: AnimatedIcons.play_pause, progress: playButtonController)
          ),
        backgroundColor: Colors.white,
        body: Center(
          child:AnimatedBuilder(
            animation: timerController,
            builder: (context, child) {
              return Center(
                child: Container(
                  height: MediaQuery.of(context).size.width-60,
                  width: MediaQuery.of(context).size.width-60,
                  child: AnimatedBuilder(
                    animation: timerController,
                    builder: (BuildContext context, Widget child) {
                      return CustomPaint(
                        painter: CustomTimerPainter(
                          animation: timerController,
                          backgroundColor: Colors.white,
                          color: secondaryColor,
                        )
                      );
                    },
                  )
                ),
              );
          }
        )
      ),
    );  
  }
  @override
  void dispose() {
    super.dispose();
    timerController.dispose();
    playButtonController.dispose();
  }
}
class CustomTimerPainter extends CustomPainter{
  CustomTimerPainter({
    this.animation,
    this.backgroundColor,
    this.color,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color backgroundColor, color;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint.color = Colors.black;
    paint.strokeWidth = 15.0;
    paint.strokeCap = StrokeCap.round;
    paint.style = PaintingStyle.stroke;  

    canvas.drawCircle(size.center(Offset.zero), size.width / 2.0, paint);
    paint.color = color;
    double progress = (1.0 - animation.value) * 2 * math.pi;
    canvas.drawArc(Offset.zero & size, math.pi*1.5, -progress, false, paint);
    //canvas.drawArc(Offset.zero & size, math.pi * 2, sweepAngle, useCenter, paint)
  }

  @override
  bool shouldRepaint(CustomTimerPainter old) {
    return animation.value != old.animation.value ||
        color != old.color ||
        backgroundColor != old.backgroundColor;
  }
  
  
  
}
