import 'package:flutter/material.dart';
import 'package:lianliankan/game/game_home.dart';

class Player {

  Player({required this.type});

  late double size;
  late Color color;
  FishType type;
  bool isShow =  true;
  bool isSelected = false;

  late AnimationController clickAnimationController;


  void click(){
    clickAnimationController.forward().then((value) => clickAnimationController.reverse());
  }



  void select(){
    isSelected = !isSelected;
  }

  void hind(){
    isShow = false;
  }

}