import 'package:flutter/material.dart';
import 'package:lianliankan/game/game_home.dart';
import 'package:lianliankan/game/player.dart';
import 'package:lianliankan/constants.dart';

class PlayerBox extends StatefulWidget {
   PlayerBox({super.key,required this.player,required this.onTap});

   Player player;
   VoidCallback onTap;


  @override
  State<PlayerBox> createState() => _PlayerBoxState();
}

class _PlayerBoxState extends State<PlayerBox> with TickerProviderStateMixin{
   String _path = "";

   late AnimationController _controller;
   late AnimationController _scaleController;



   @override
  void initState() {
    // TODO: implement initState
    super.initState();

    switch (widget.player.type){
      case FishType.fish01:
        _path = FISH_TILE_001;
        break;
      case FishType.fish02:
        _path = FISH_TILE_002;
        break;
      case FishType.fish03:
        _path = FISH_TILE_003;
        break;
      case FishType.fish04:
        _path = FISH_TILE_004;
        break;
      case FishType.fish05:
        _path = FISH_TILE_005;
        break;
      case FishType.fish06:
        _path = FISH_TILE_006;
        break;
    }

    widget.player.clickAnimationController = AnimationController(vsync: this,duration: Duration(milliseconds: 100));
    _scaleController = AnimationController(vsync: this,duration: Duration(milliseconds: 300));

    _scaleController.forward();


  }
   @override
   Widget build(BuildContext context) {
     return InkWell(
       onTap: () {
         widget.onTap();
       },
       child: ScaleTransition(
         scale: Tween<double>(begin: 0, end: 1).animate(_scaleController),
         child: AnimatedScale(
           duration: const Duration(milliseconds: 200),
           scale: widget.player.isShow ? 1.0 : 0.0,
           child: AnimatedBuilder(
             animation: widget.player.clickAnimationController,
             builder: (context, child) {
               return AnimatedContainer(
                 duration: const Duration(milliseconds: 130),
       
                 decoration: BoxDecoration(
                   color: widget.player.isSelected
                       ? const Color.fromRGBO(243, 209, 102, 0.8)
                       : const Color.fromRGBO(1, 1, 1, 0.4),
                   borderRadius: BorderRadius.circular(5)
                 ),
                 child: Center(
                   child: SizedBox(
                     width: Tween(begin: widget.player.size, end: widget.player.size + 60)
                         .animate(widget.player.clickAnimationController)
                         .value,
                     height: Tween(begin: widget.player.size, end: widget.player.size + 60)
                         .animate(widget.player.clickAnimationController)
                         .value,
                     child: Image.asset(_path, fit: BoxFit.fill),
                   ),
                 ),
               );
             },
           ),
         ),
       ),
     );
   }
}
