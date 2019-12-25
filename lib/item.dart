
import 'dart:ui';

import 'package:flutter/material.dart';

class Item {

  static const String C_RED = "red";
  static const String C_RED_ACCENT = "redAccent";
  static const String C_BLUE_ACCENT = "blueAccent";
  static const String C_BLACK = "black";
  static const String C_WHITE = "white";

  static final String WELCOME_TEXT = "WELCOME TO SKY PARK";
  static final int DISPLAY_SPEED_DEFAULT = 50;

  static String KEY_DISPLAY_TEXT = "KEY_DIPLAY_TEXT";
  static String KEY_FONT = "KEY_FONT";
  static String KEY_SPEED = "KEY_SPEED";
  static String KEY_BG = "KEY_BG";
  static String KEY_TEXT_COLOR = "KEY_TEXT_COLOR";
  static String KEY_FONT_SIZE = "KEY_FONT_SIZE";




  static String getDisplayText(String text){
    if(text == null) return WELCOME_TEXT;
    if(text.isEmpty) return WELCOME_TEXT;
    return text;
  }

  static List COLOR_LIST = [Colors.white, Colors.black54, Colors.blueAccent, Colors.red, Colors.redAccent];
  static List COLOR_LIST_STR = [C_WHITE, C_BLACK, C_BLUE_ACCENT, C_RED, C_RED_ACCENT];


  static List SPEED_LIST = [50, 60, 80, 100, 120, 150, 180 , 200 , 250 , 300, 400, 500, 800, 1000];
  static List TEXT_SIZE_LIST = [12, 14, 16, 18, 20, 24, 26 , 30 , 36 , 40, 50, 60, 70, 80, 90, 100, 110, 120, 150, 180, 200, 250, 300, 400, 500, 600, 700, 1000];



  static Color getDisplayTextColor(String text){
    var c ;
    switch (text){
      case C_RED :
         c = Colors.red;
        break;
      case C_RED_ACCENT :
        c = Colors.redAccent;
        break;
      case C_BLUE_ACCENT :
        c = Colors.blueAccent;
        break;
      case C_BLACK:
        c = Colors.black;
        break;
      case C_WHITE :
        c = Colors.white;
        break;



      default: c = Colors.white;

    }

    return c;

  }

  static Color getDisplayBGColor(String text){
    var c ;
    switch (text){
      case C_RED :
        c = Colors.red;
        break;
      case C_RED_ACCENT :
        c = Colors.redAccent;
        break;
      case C_BLUE_ACCENT :
        c = Colors.blueAccent;
        break;
      case C_BLACK:
        c = Colors.black54;
        break;
      case C_WHITE :
        c = Colors.white;
        break;



      default: c = Colors.black54;

    }

    return c;

  }
}

enum PhonecallState { incoming, dialing, connected, disconnected, none }