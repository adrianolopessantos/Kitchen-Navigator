import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class KnifeCompassLogo extends StatelessWidget {
  const KnifeCompassLogo({super.key,this.size=48});
  final double size;
  @override Widget build(BuildContext context)=>CustomPaint(size:Size.square(size),painter:_Painter());
}
class _Painter extends CustomPainter {
  @override void paint(Canvas c,Size s){
    final center=Offset(s.width/2,s.height/2),r=s.width*.42;
    final p=Paint()..color=AppColors.primary..style=PaintingStyle.stroke..strokeWidth=s.width*.045;
    c.drawCircle(center,r,p);
    final t=Paint()..color=AppColors.primary..strokeWidth=s.width*.025..strokeCap=StrokeCap.round;
    for(var i=0;i<8;i++){final a=math.pi*2/8*i;c.drawLine(Offset(center.dx+math.cos(a)*r*.78,center.dy+math.sin(a)*r*.78),Offset(center.dx+math.cos(a)*r*.92,center.dy+math.sin(a)*r*.92),t);}
    c.save();c.translate(center.dx,center.dy);c.rotate(math.pi/4);
    final blade=Path()..moveTo(-s.width*.035,-s.height*.30)..quadraticBezierTo(s.width*.055,-s.height*.26,s.width*.055,-s.height*.18)..lineTo(s.width*.055,s.height*.02)..lineTo(-s.width*.045,s.height*.02)..close();
    c.drawPath(blade,Paint()..color=const Color(0xFFDDF6CF));
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-s.width*.045,s.height*.015,s.width*.10,s.height*.26),Radius.circular(s.width*.04)),Paint()..color=AppColors.primary);c.restore();c.drawCircle(center,s.width*.045,Paint()..color=AppColors.primary);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate)=>false;
}
