import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lianliankan/constants.dart';
import 'package:lianliankan/game/path_painter.dart';
import 'package:lianliankan/game/player.dart';
import 'package:lianliankan/game/player_box.dart';

class GameHome extends StatefulWidget {
  const GameHome({super.key});

  @override
  State<GameHome> createState() => _GameHomeState();
}

enum FishType {
  fish01,
  fish02,
  fish03,
  fish04,
  fish05,
  fish06,
}

class _GameHomeState extends State<GameHome> {
  int _gridLength = 6;
  List<Player> _players = [];

  int _firstSelected = -1;
  int _secondSelected = -1;

  List<Offset> _pathOffset = [];

  Random random = Random();

  late double gameWidth;

  late Timer _timer;
  int time = 0;

  bool _gameStated = false;

  String _audioSource = "audio/10003.mp3";
  AudioPlayer _backgroundAudioPlay = AudioPlayer();
  AudioPlayer _clickPlayer = AudioPlayer();
  
  bool _isAudioPlay = true;



  void stateGame() async{

    setState((){
      _gameStated = true;

    });

    _timer = Timer.periodic(Duration(seconds: 1), (_) {

      setState(() {
        time++;
      });

      if(_checkGameOver()) {
        _timer.cancel();
        _gameStated = false;
         _showGameOverDialog().then((_){
           _initGame();
         });
      }


    });
  }

  bool _checkGameOver(){
    return !_players.any((element) => element.isShow);
  }

   Future<void> _showGameOverDialog() async{

    await showDialog(context: context, builder: (context){
      return AlertDialog(
        content: Text("游戏结束 耗时：$time"),
        actions: [
          TextButton(onPressed: (){
            Navigator.pop(context);
          }, child: Text("确定"))
        ],
      );
    });

  }


  void _playerClick(int index) async{

    if(!_gameStated){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.white,
          content: Text("请开始游戏",style: TextStyle(color: Colors.black,fontSize: 19),)));
      return;
    }

    _players[index].click();

    await _clickPlayer.stop();
    await _clickPlayer.play(AssetSource("audio/10001.mp3"));


    if (_firstSelected == -1) {
      setState(() {
        _firstSelected = index;
        _players[index].select();
      });
    } else if (_secondSelected == -1) {

      if(_firstSelected == index){
        setState(() {
          _players[_firstSelected].select();
          _firstSelected = -1;
        });
        return;
      }   /// 重复选择

      setState(() {
        _secondSelected = index;
        _players[index].select();
      });


      List<int> connectList = canConnect(_firstSelected, _secondSelected);

      if(connectList.isNotEmpty && _players[_firstSelected].type == _players[_secondSelected].type){

        double gridSize = (gameWidth - 20) / _gridLength;
        List<Offset> tempList = [];

        connectList.forEach((element) {
          double x = gridSize * (element % _gridLength) +  gridSize/2;
          double y = gridSize * (element ~/ _gridLength) + gridSize/2;

          tempList.add(Offset(x, y));

          tempList.add(Offset(x, y));
        });
        setState(() {
          _pathOffset = tempList;
        });

        await Future.delayed(Duration(milliseconds: 500));

        setState(() {
          _pathOffset = [];

          _players[_firstSelected].select();
          _players[_secondSelected].select();

          _players[_firstSelected].isShow = false;
          _players[_secondSelected].isShow = false;

          _firstSelected = -1;
          _secondSelected = -1;
        });
      }else{
        setState(() {
          _players[_firstSelected].select();
          _players[_secondSelected].select();

          _firstSelected = -1;
          _secondSelected = -1;
        });
      }

    }
  }

  List<int> canConnect(int index1,int index2){

    if(canConnectOne(index1, index2))return[index1,index2];

    List<int> towList = canConnectTwo(index1, index2);
    if(towList.isNotEmpty)return towList;

    List<int> threeList = canConnectThree(index1, index2);
    if(threeList.isNotEmpty)return threeList;

    return [];
  }

  bool canConnectOne(int index1, int index2) {

    if (index1 ~/ _gridLength == index2 ~/ _gridLength) {
      for (int i = min(index1, index2) + 1; i < max(index1, index2); i++) {
        if (_players[i].isShow) {
          return false;
        }
      }
      return true;
    }


    if (index1 % _gridLength == index2 % _gridLength) {
      for (int i = min(index1, index2) + _gridLength; i < max(index1, index2); i += _gridLength) {
        if (_players[i].isShow) {
          return false;
        }
      }
      return true;
    }

    return false;
  }

  List<int> canConnectTwo(int index1, int index2){

    int x2 = index2 % _gridLength;
    int y1 = index1 ~/ _gridLength;
    int count1 = y1 * _gridLength + x2;

    if(canConnectOne(index1, count1) && canConnectOne(count1, index2) && !_players[count1].isShow){
      return [index1,count1,index2];
    }

    int x1 = index1 % _gridLength;
    int y2 = index2 ~/ _gridLength;
    int count2 = y2 * _gridLength + x1;

    if(canConnectOne(index1, count2) && canConnectOne(count2, index2) && !_players[count2].isShow){
      return [index1,count2,index2];
    }


    return [];
  }

  List<int> canConnectThree(int index1, int index2){

    for(int i = 0; i < _players.length; i++){
      if(_players[i].isShow) continue;
      for(int j = 0; j < _players.length; j++){
        if(_players[j].isShow) continue;
        if(canConnectOne(index1, i) && canConnectOne(i, j) && canConnectOne(j, index2)){
          return [index1,i,j,index2];
        }
      }
    }

    return [];
  }

  
  void _changeAudioPlay(){
    print('111');

    setState(() {
  _isAudioPlay = !_isAudioPlay;
  
    });
    if(_isAudioPlay){
      _backgroundAudioPlay.play(AssetSource(_audioSource));
    }else{
      _backgroundAudioPlay.stop();
    }
  }


  void _initGame() async {

    if(_gameStated){_timer.cancel();}

    List<Player> newPlayers = [];

    int pairNum = _gridLength * _gridLength ~/ 2;
    for (int i = 0; i < pairNum; i++) {
      newPlayers.add(Player(type: FishType.values[i % _gridLength]));
      newPlayers.add(Player(type: FishType.values[i % _gridLength]));
    }

    // 洗牌算法
    for (int i = newPlayers.length - 1; i > 0; i--) {
      int num = random.nextInt(i);
      var temp = newPlayers[i];
      newPlayers[i] = newPlayers[num];
      newPlayers[num] = temp;
    }

    setState(() {
      _gameStated = false;
      time = 0;
      _players = newPlayers;
      _firstSelected = -1;
      _secondSelected = -1;

    });


  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _initGame();

    _backgroundAudioPlay.play(AssetSource(_audioSource));
    _backgroundAudioPlay.onPlayerComplete.listen((event) {
      if(_isAudioPlay){
        _backgroundAudioPlay.play(AssetSource(_audioSource));
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    _backgroundAudioPlay.stop();
    _backgroundAudioPlay.dispose();
    _clickPlayer.dispose();
  }

  @override
  Widget build(BuildContext context) {
     gameWidth = MediaQuery.of(context).size.width;
     if(kIsWeb){
       gameWidth = 600;
     }

    double gridSize = gameWidth / _gridLength;

    _players.forEach((element) {
      element.size = gridSize - 10;
    });

    return Scaffold(
        body: Center(
          child: SizedBox(
            width: kIsWeb? 700 :double.infinity,
            height: kIsWeb? 1000: double.infinity,
            child: Stack(
      children: [
            // 背景
            Container(
              width: double.infinity,
              height: double.infinity,
              child: Image.asset(
                BACKGROUND_IMAGE,
                fit: BoxFit.cover,
              ),
            ),

            Container(
              alignment: Alignment(0, 0),
              child: Stack(
                children: [
                  Container(
                    width: gameWidth - 20,
                    height: gameWidth - 20,
                    child: GridView.builder(
                        padding: EdgeInsets.zero,
                        // shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _players.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: _gridLength),
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.all(1.5),
                            child: PlayerBox(
                                key: Key(_players[index].hashCode.toString()),
                                player: _players[index],
                                onTap: () {
                                  _playerClick(index);
                                }),
                          );
                        }),
                  ),
                  CustomPaint(
                    painter: PathPainter(
                      points: _pathOffset
                    ),
                  )
                ],
              )
            ),

            /// 底部按钮
            Container(
              alignment: Alignment(0,0.9),
              child: Container(
                width: double.infinity,
                height: 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:[ TextButton(
                    child: Text("开始游戏",style: TextStyle(color: _gameStated?Colors.white.withOpacity(0.5) :Colors.white,fontSize: 35),),
                    onPressed: _gameStated? null: (){
                      stateGame();

                    },
                  ),
                  TextButton(onPressed: (){
                    _initGame();
                  }, child: Text("重置游戏",style: TextStyle(color: Colors.white),))
                  ]
                ),
              ),
            ),

            /// 时间
            Container(
              alignment: Alignment(-0.7, -0.8),
              child: Text("当前时间：${time>9?time:('0${time.toString()}')}",style: TextStyle(fontSize: 30,color: Colors.white),),
            ),

            /// 音频播放
            Container(
              alignment: Alignment(0.8,-0.8),
              child:Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                 color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle
                ),
                child:  IconButton(
                  onPressed: (){
                    _changeAudioPlay();
                  },
                  icon: Icon(Icons.audiotrack_outlined,color:_isAudioPlay? Colors.white:Colors.white.withOpacity(0.5),),
                ),
              )
            )

      ],
    ),
          ),
        ));
  }
}
