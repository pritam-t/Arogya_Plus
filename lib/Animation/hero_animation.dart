import 'package:flutter/material.dart';

class HeroAnimation extends StatefulWidget {
  const HeroAnimation({super.key});

  @override
  State<HeroAnimation> createState() => _HeroAnimationState();
}

class _HeroAnimationState extends State<HeroAnimation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hero Animation"),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: (){
              Navigator.push(
                  context, MaterialPageRoute(
                  builder: (context)=> HeroAnimation2())
              );
            },
            child: Container(
              child: Center(
                child: Hero(
                    tag: 'Background',
                    child: Image.asset('assets/images/appicon.png',width: 100,height: 100,)
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
class HeroAnimation2 extends StatefulWidget {
  const HeroAnimation2({super.key});

  @override
  State<HeroAnimation2> createState() => _HeroAnimation2State();
}

class _HeroAnimation2State extends State<HeroAnimation2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hero Animation Extended"),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Column(
        children: [
          Container(
            child: Center(
              child: Hero(
                  tag: 'Background',
                  child: Image.asset('assets/images/appicon.png',)
              ),
            ),
          )
        ],
      ),
    );
  }
}

