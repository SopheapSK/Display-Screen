import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marquee/marquee.dart';
import 'package:phonecallstate/phonecallstate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sky_park_display/item.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent
    ));
    return MaterialApp(

      debugShowCheckedModeBanner: false,
      title: 'SP Display',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'SP Display'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var DISPLAY_TEXT = Item.WELCOME_TEXT;
  var DIPLAY_SPEED = Item.DISPLAY_SPEED_DEFAULT;
  var DISPLAY_TXT_COLOR = Colors.white;
  var DISPLAY_BG_COLOR = Colors.black54;
  var DISPLAY_TXT_SIZE = 20.0;
  var ICON_BAR_COLOR = Colors.white;
  TextEditingController _textEditingController = new TextEditingController();
  Phonecallstate  phonecallstate;
  PhonecallState phonecallstatus;

  var  phonecallstatuslog;

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  bool isSettingHide = true;


  void initPhonecallstate() async {
    print("Phonecallstate init");

    phonecallstate = new Phonecallstate();
    phonecallstatus = PhonecallState.none;


    phonecallstate.setIncomingHandler(() {
      setState(() {
        phonecallstatus = PhonecallState.incoming;
        phonecallstatuslog =  phonecallstatuslog.toString() + PhonecallState.incoming.toString()+"\n";
      });
    });

    phonecallstate.setDialingHandler(() {
      setState(() {
        phonecallstatus = PhonecallState.dialing;
        phonecallstatuslog =  phonecallstatuslog.toString() + PhonecallState.dialing.toString()+"\n";
      });
    });

    phonecallstate.setConnectedHandler(() {
      setState(() {
        phonecallstatus = PhonecallState.connected;
        phonecallstatuslog =  phonecallstatuslog.toString() + PhonecallState.connected.toString()+"\n";
      });
    });

    phonecallstate.setDisconnectedHandler(() {
      setState(() {
        phonecallstatus = PhonecallState.disconnected;
        phonecallstatuslog =  phonecallstatuslog.toString() + PhonecallState.disconnected.toString()+"\n";
      });
    });

    phonecallstate.setErrorHandler((msg) {

    });
  }
  @override
  void dispose() {
    // TODO: implement dispose
    _textEditingController.dispose();

    super.dispose();

  }

  @override
  void initState() {
    // TODO: implement initState
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    super.initState();

    if (mounted) {


      _prefs.then((_) {
        var text = _.getString(Item.KEY_DISPLAY_TEXT);
        if (text != null) {
          setState(() {
            DISPLAY_TEXT = Item.getDisplayText(text);
          });
        }

        var speed = _.getInt(Item.KEY_SPEED);
        if(speed != null){
          setState(() {
           DIPLAY_SPEED = speed;
          });
        }

        var txtColor = _.getString(Item.KEY_TEXT_COLOR);
        if(txtColor != null){
          setState(() {
            DISPLAY_TXT_COLOR = Item.getDisplayTextColor(txtColor);
          });
        }

        var bgColor = _.getString(Item.KEY_BG);
        if(txtColor != null){
          setState(() {
            DISPLAY_BG_COLOR = Item.getDisplayBGColor(bgColor);
          });
        }

        var fontSize = _.getInt(Item.KEY_FONT_SIZE);
        if(fontSize != null){
          setState(() {
            DISPLAY_TXT_SIZE = fontSize.toDouble();
          });
        }



      });
      initPhonecallstate();
    }


  }

  @override
  Widget build(BuildContext context) {
    final topContent = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 30.0, right: 16.0, left: 16.0),
          child: IconButton(
            onPressed: () {
              _showBottomSheetColor(context);
            },
            icon: Icon(Icons.opacity, color: ICON_BAR_COLOR),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 30.0, right: 16.0, left: 16.0),
          child: IconButton(
            onPressed: () {
              _showBottomSheetSpeed(context);
            },
            icon: Icon(Icons.shutter_speed, color: ICON_BAR_COLOR),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 30.0, right: 16.0, left: 16.0),
          child: IconButton(
            onPressed: () {
              _showBottomSheetFontSize(context);
            },
            icon: Icon(Icons.text_fields, color:ICON_BAR_COLOR),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 30.0, right: 16.0, left: 16.0),
          child: IconButton(
            onPressed: () {
              _showBottomSheetEditText(context);
            },
            icon: Icon(Icons.font_download, color: ICON_BAR_COLOR),
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: DISPLAY_BG_COLOR,
      body: GestureDetector(
        onTap: () {
          setState(() {
            isSettingHide = !isSettingHide;
          });

          if (!isSettingHide) {
            // if it show on screen, hide it after a while
            Future.delayed(const Duration(seconds: 7), () {
              setState(() {
                isSettingHide = true;
              });
            });
          }
        },
        child: Container(
          alignment: Alignment.center,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(1.0),
                child: isSettingHide ? Container() : topContent,
              ),
              SizedBox(height: 90.0,),
              new Text('Last state: $phonecallstatuslog', style: TextStyle(color: Colors.white),),
              Expanded(
                child: _buildMarquee(),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMarquee() {
    return Marquee(
      text: '$DISPLAY_TEXT ',
      style: TextStyle(

          fontWeight: FontWeight.bold, color: DISPLAY_TXT_COLOR, fontSize: DISPLAY_TXT_SIZE),
      velocity: DIPLAY_SPEED.toDouble(),
    );
  }

  void _showBottomSheetColor(BuildContext context) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Color(0xFF2d3447),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
        ),
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      height: 16.0,
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Change Text Color: ',
                          style: TextStyle(color: Colors.white),
                        )),
                    SizedBox(
                      height: 8.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: new SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: listOfTextColor(context),
                      ),
                    ),
                    SizedBox(
                      height: 32.0,
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Change Background Color: ',
                          style: TextStyle(color: Colors.white),
                        )),
                    SizedBox(
                      height: 8.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: new SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: listOfBGColor(context),
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        });
  }
  Widget listOfFontSize(BuildContext context) {
    List<Widget> list = new List<Widget>();
    list.add( new SizedBox(width: 16.0,));
    for(var i = 0; i < Item.TEXT_SIZE_LIST.length; i++){
      list.add(  Container(
          height: 40.0,
          width: 100.0,
          child: Material(
            borderRadius: BorderRadius.circular(20.0),
            shadowColor: Colors.black54,
            color: i % 2 == 0  ? Colors.blueAccent : Colors.redAccent,
            elevation: 7.0,
            child: InkWell(
              onTap: () {
                _funcChangeTextSize(Item.TEXT_SIZE_LIST[i]);
                Navigator.pop(context);
              },
              child: Center(
                child: Text(
                  '${Item.TEXT_SIZE_LIST[i]}',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Montserrat'),
                ),
              ),
            ),
          )),);

      list.add(SizedBox(width: 16.0,));
    }


    return new Row(children: list);
  }
  Widget listOfSpeed(BuildContext context) {
    var len = Item.SPEED_LIST.length;
    var hLen = len /2;
    List<Widget> list = new List<Widget>();
    list.add( new SizedBox(width: 16.0,));
    for(var i = 0; i < len; i++){
      list.add(  Container(
          height: 40.0,
          width: 100.0,
          child: Material(
            borderRadius: BorderRadius.circular(20.0),
            shadowColor: Colors.black54,
            color: i < hLen  ? Colors.blueAccent : Colors.redAccent,
            elevation: 7.0,
            child: InkWell(
              onTap: () {
                _funcAddSpeed(Item.SPEED_LIST[i]);
                Navigator.pop(context);
              },
              child: Center(
                child: Text(
                  '${Item.SPEED_LIST[i]}',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Montserrat'),
                ),
              ),
            ),
          )),);

      list.add(SizedBox(width: 16.0,));
    }


    return new Row(children: list);
  }
  Widget listOfTextColor(BuildContext context) {

    List<Widget> list = new List<Widget>();
    list.add( new SizedBox(width: 16.0,));
    for(var i = 0; i < Item.COLOR_LIST.length; i++){
      list.add(  Container(
          height: 40.0,
          width: 100.0,
          child: Material(
            borderRadius: BorderRadius.circular(20.0),
            shadowColor: Colors.black54,
            color:Item.COLOR_LIST[i] ,
            elevation: 7.0,
            child: InkWell(
              onTap: () {
                _funcChangeTextColor(Item.COLOR_LIST_STR[i]);
                Navigator.pop(context);
              },
              child: Center(
                child: Text(
                  '',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Montserrat'),
                ),
              ),
            ),
          )),);

      list.add(SizedBox(width: 16.0,));
    }


    return new Row(children: list);
  }
  Widget listOfBGColor(BuildContext context) {

    List<Widget> list = new List<Widget>();
    list.add( new SizedBox(width: 16.0,));
    for(var i = 0; i < Item.COLOR_LIST.length; i++){
      list.add(  Container(
          height: 40.0,
          width: 100.0,
          child: Material(
            borderRadius: BorderRadius.circular(20.0),
            shadowColor: Colors.black54,
            color:Item.COLOR_LIST[i] ,
            elevation: 7.0,
            child: InkWell(
              onTap: () {
                _funcChangeBGColor(Item.COLOR_LIST_STR[i]);
                Navigator.pop(context);
              },
              child: Center(
                child: Text(
                  '',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Montserrat'),
                ),
              ),
            ),
          )),);

      list.add(SizedBox(width: 16.0,));
    }


    return new Row(children: list);
  }


  void _showBottomSheetFontSize(BuildContext context) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Color(0xFF2d3447),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
        ),
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      height: 16.0,
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Change Font Size: ',
                          style: TextStyle(color: Colors.white),
                        )),
                    SizedBox(
                      height: 8.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: new SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: listOfFontSize(context)
                      ),
                    ),
                    SizedBox(
                      height: 32.0,
                    ),


                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        });
  }
  void _showBottomSheetSpeed(BuildContext context) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Color(0xFF2d3447),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
        ),
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      height: 16.0,
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Change Speed: ',
                          style: TextStyle(color: Colors.white),
                        )),
                    SizedBox(
                      height: 16.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: new SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: listOfSpeed(context)
                      ),
                    ),
                    SizedBox(
                      height: 32.0,
                    ),


                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        });
  }

  void _showBottomSheetEditText(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Color(0xFF2d3447),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
        ),
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      height: 16.0,
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          'Input Text here:',
                          style: TextStyle(color: Colors.white),
                        )),
                    SizedBox(
                      height: 8.0,
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.0),
                      child: new TextField(
                        controller: _textEditingController,
                        keyboardType: TextInputType.text,
                        // controller: _controllers[index],
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintStyle: TextStyle(color: Colors.white70),
                          prefixIcon: Icon(
                            Icons.edit,
                            size: 14.0,
                            color: Colors.white,
                          ),
                          hintText: '${Item.WELCOME_TEXT}',
                          contentPadding:
                              EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 10.0),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24.0)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24.0),
                            borderSide:
                                BorderSide(width: 1, color: Colors.white70),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24.0),
                            borderSide:
                                BorderSide(width: 1, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 4.0,
                    ),
                    _buttonSubmit(context),
                    SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget _buttonSubmit(BuildContext context) {
    return new Center(
        child: new RaisedButton(
            onPressed: () async {
              //updateData(provider, index, property);
              var text = _textEditingController.text;
              if (text.isNotEmpty) {
                setState(() {
                  DISPLAY_TEXT = text;
                });
                _prefs.then((_) {
                  _.setString(Item.KEY_DISPLAY_TEXT, text);
                  Navigator.pop(context);
                });
              }
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.0),
            ),
            color: Colors.blueAccent,
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new Icon(
                  Icons.cloud_done,
                  color: Colors.white,
                  size: 24.0,
                ),
                SizedBox(
                  width: 16.0,
                ),
                new Text(
                  ' \t CONFIRM \t \t \t \t',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold),
                ),
              ],
            )));
  }

  void _funcAddSpeed(int speed){
    setState(() {
      DIPLAY_SPEED = speed;
    });

    _prefs.then((_){
      _.setInt(Item.KEY_SPEED, speed);

    });
  }
  void _funcChangeTextColor(String color){
    setState(() {
      DISPLAY_TXT_COLOR = Item.getDisplayTextColor(color);
    });

    _prefs.then((_){
      _.setString(Item.KEY_TEXT_COLOR, color);

    });
  }

  void _funcChangeBGColor(String color){
    setState(() {
      DISPLAY_BG_COLOR = Item.getDisplayBGColor(color);
    });

    _prefs.then((_){
      _.setString(Item.KEY_BG, color);

    });

    if(color== Item.C_WHITE){
      setState(() {
        ICON_BAR_COLOR = Colors.black54;
      });
    }else{
      setState(() {
        ICON_BAR_COLOR = Colors.white;
      });
    }
  }

  void _funcChangeTextSize(int size){
    setState(() {
      DISPLAY_TXT_SIZE = size.toDouble();
    });

    _prefs.then((_){
      _.setInt(Item.KEY_FONT_SIZE, size);
    });
  }





}
