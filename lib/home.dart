import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'dart:ui';
import 'package:luminix/WebSocket.dart';

class ColorPickerPage extends StatefulWidget {
  const ColorPickerPage({super.key});

  @override
  State<ColorPickerPage> createState() => _ColorPickerPageState();
}

class _ColorPickerPageState extends State<ColorPickerPage>
    with TickerProviderStateMixin {
  Color selectedColor = const Color(0xFF00B8D4);
  String selectedMode = "Static";
  double brightness = 200.0;
  bool isConnected = false;
  late AnimationController _animationController;
  late WebSocketService webSocketService;

  // Settings variables
  String wifiSSID = "";
  String wifiPassword = "";
  String deviceName = "Luminix Device";
  bool autoConnect = true;
  int refreshRate = 30;
  bool debugMode = false;

  final List<Map<String, dynamic>> _modes = [
    {
      "id": 0,
      "label": "Static",
      "desc": "No blinking. Just plain old static light.",
      "color": Colors.green,
      "icon": FontAwesomeIcons.lightbulb,
    },
    {
      "id": 1,
      "label": "Blink",
      "desc": "Normal blinking. 50% on/off time.",
      "color": Colors.yellow,
      "icon": FontAwesomeIcons.bolt,
    },
    {
      "id": 2,
      "label": "Breath",
      "desc": "Standby-breathing effect. Fixed Speed.",
      "color": Colors.cyan,
      "icon": FontAwesomeIcons.wind,
    },
    {
      "id": 3,
      "label": "Color Wipe",
      "desc":
          "Lights all LEDs after each other up. Then turns them off in order.",
      "color": Colors.orange,
      "icon": FontAwesomeIcons.paintRoller,
    },
    {
      "id": 4,
      "label": "Color Wipe Inverse",
      "desc": "Same as Color Wipe, except swaps on/off colors.",
      "color": Colors.pink,
      "icon": FontAwesomeIcons.palette,
    },
    {
      "id": 5,
      "label": "Color Wipe Reverse",
      "desc": "Lights all LEDs, then turns them off in reverse.",
      "color": Colors.purple,
      "icon": FontAwesomeIcons.exchangeAlt,
    },
    {
      "id": 6,
      "label": "Color Wipe Reverse Inverse",
      "desc": "Reverse + color swap.",
      "color": Colors.deepPurple,
      "icon": FontAwesomeIcons.random,
    },
    {
      "id": 7,
      "label": "Color Wipe Random",
      "desc": "Turns all LEDs after each other to random colors.",
      "color": Colors.red,
      "icon": FontAwesomeIcons.random,
    },
    {
      "id": 8,
      "label": "Random Color",
      "desc": "All LEDs light in one random color, then changes.",
      "color": Colors.greenAccent,
      "icon": FontAwesomeIcons.shapes,
    },
    {
      "id": 9,
      "label": "Single Dynamic",
      "desc": "Changes one random LED at a time.",
      "color": Colors.teal,
      "icon": FontAwesomeIcons.circle,
    },
    {
      "id": 10,
      "label": "Multi Dynamic",
      "desc": "Changes all LEDs to new random colors.",
      "color": Colors.deepPurpleAccent,
      "icon": FontAwesomeIcons.cubes,
    },
    {
      "id": 11,
      "label": "Rainbow",
      "desc": "Cycles all LEDs through a rainbow.",
      "color": Colors.blue,
      "icon": FontAwesomeIcons.rainbow,
    },
    {
      "id": 12,
      "label": "Rainbow Cycle",
      "desc": "Cycles rainbow over entire strip.",
      "color": Colors.orangeAccent,
      "icon": FontAwesomeIcons.rainbow,
    },
    {
      "id": 13,
      "label": "Scan",
      "desc": "Runs a single pixel back and forth.",
      "color": Colors.deepOrange,
      "icon": FontAwesomeIcons.eye,
    },
    {
      "id": 14,
      "label": "Dual Scan",
      "desc": "Two pixels back and forth opposite.",
      "color": Colors.grey,
      "icon": FontAwesomeIcons.exchangeAlt,
    },
    {
      "id": 15,
      "label": "Fade",
      "desc": "Fades LEDs on and off.",
      "color": Colors.brown,
      "icon": FontAwesomeIcons.adjust,
    },
    {
      "id": 16,
      "label": "Theater Chase",
      "desc": "Theatre-style crawling lights.",
      "color": Colors.blueGrey,
      "icon": FontAwesomeIcons.theaterMasks,
    },
    {
      "id": 17,
      "label": "Theater Chase Rainbow",
      "desc": "Theatre-style with rainbow.",
      "color": Colors.pinkAccent,
      "icon": FontAwesomeIcons.theaterMasks,
    },
    {
      "id": 18,
      "label": "Running Lights",
      "desc": "Smooth sine transition running lights.",
      "color": Colors.blueAccent,
      "icon": FontAwesomeIcons.running,
    },
    {
      "id": 19,
      "label": "Twinkle",
      "desc": "Blink several LEDs on, reset, repeat.",
      "color": Colors.amber,
      "icon": FontAwesomeIcons.star,
    },
    {
      "id": 20,
      "label": "Twinkle Random",
      "desc": "Blink several LEDs in random colors.",
      "color": Colors.green,
      "icon": FontAwesomeIcons.random,
    },
    {
      "id": 21,
      "label": "Twinkle Fade",
      "desc": "Blink several LEDs, fading out.",
      "color": Colors.purple,
      "icon": FontAwesomeIcons.starHalf,
    },
    {
      "id": 22,
      "label": "Twinkle Fade Random",
      "desc": "Random fading twinkles.",
      "color": Colors.cyan,
      "icon": FontAwesomeIcons.random,
    },
    {
      "id": 23,
      "label": "Sparkle",
      "desc": "Blinks one LED at a time.",
      "color": Colors.deepOrange,
      "icon": FontAwesomeIcons.solidStar,
    },
    {
      "id": 24,
      "label": "Flash Sparkle",
      "desc": "All LEDs in color. Flashes single white pixels.",
      "color": Colors.purpleAccent,
      "icon": FontAwesomeIcons.bolt,
    },
    {
      "id": 25,
      "label": "Hyper Sparkle",
      "desc": "More flashes.",
      "color": Colors.orange,
      "icon": FontAwesomeIcons.bolt,
    },
    {
      "id": 26,
      "label": "Strobe",
      "desc": "Classic strobe effect.",
      "color": Colors.lightBlue,
      "icon": FontAwesomeIcons.a,
    },
    {
      "id": 27,
      "label": "Strobe Rainbow",
      "desc": "Strobe cycling rainbow.",
      "color": Colors.lightGreen,
      "icon": FontAwesomeIcons.rainbow,
    },
    {
      "id": 28,
      "label": "Multi Strobe",
      "desc": "Strobe with different count and pause.",
      "color": Colors.pink,
      "icon": FontAwesomeIcons.bolt,
    },
    {
      "id": 29,
      "label": "Blink Rainbow",
      "desc": "Blink effect cycling rainbow.",
      "color": Colors.yellow,
      "icon": FontAwesomeIcons.rainbow,
    },
    {
      "id": 30,
      "label": "Chase White",
      "desc": "Color running on white.",
      "color": Colors.white,
      "icon": FontAwesomeIcons.running,
    },
    {
      "id": 31,
      "label": "Chase Color",
      "desc": "White running on color.",
      "color": Colors.blue,
      "icon": FontAwesomeIcons.paintRoller,
    },
    {
      "id": 32,
      "label": "Chase Random",
      "desc": "White running followed by random color.",
      "color": Colors.red,
      "icon": FontAwesomeIcons.random,
    },
    {
      "id": 33,
      "label": "Chase Rainbow",
      "desc": "White running on rainbow.",
      "color": Colors.orange,
      "icon": FontAwesomeIcons.rainbow,
    },
    {
      "id": 34,
      "label": "Chase Flash",
      "desc": "White flashes running on color.",
      "color": Colors.green,
      "icon": FontAwesomeIcons.bolt,
    },
    {
      "id": 35,
      "label": "Chase Flash Random",
      "desc": "White flashes running on random color.",
      "color": Colors.purple,
      "icon": FontAwesomeIcons.random,
    },
    {
      "id": 36,
      "label": "Chase Rainbow White",
      "desc": "Rainbow running on white.",
      "color": Colors.yellow,
      "icon": FontAwesomeIcons.rainbow,
    },
    {
      "id": 37,
      "label": "Chase Blackout",
      "desc": "Black running on color.",
      "color": Colors.black,
      "icon": FontAwesomeIcons.solidCircle,
    },
    {
      "id": 38,
      "label": "Chase Blackout Rainbow",
      "desc": "Black running on rainbow.",
      "color": Colors.black87,
      "icon": FontAwesomeIcons.rainbow,
    },
    {
      "id": 39,
      "label": "Color Sweep Random",
      "desc": "Random color alternating from start/end.",
      "color": Colors.teal,
      "icon": FontAwesomeIcons.random,
    },
    {
      "id": 40,
      "label": "Running Color",
      "desc": "Alternating color/white pixels running.",
      "color": Colors.cyan,
      "icon": FontAwesomeIcons.running,
    },
    {
      "id": 41,
      "label": "Running Red Blue",
      "desc": "Alternating red/blue pixels running.",
      "color": Colors.red,
      "icon": FontAwesomeIcons.running,
    },
    {
      "id": 42,
      "label": "Running Random",
      "desc": "Random colored pixels running.",
      "color": Colors.purple,
      "icon": FontAwesomeIcons.random,
    },
    {
      "id": 43,
      "label": "Larson Scanner",
      "desc": "K.I.T.T. scanning effect.",
      "color": Colors.red,
      "icon": FontAwesomeIcons.eye,
    },
    {
      "id": 44,
      "label": "Comet",
      "desc": "Firing comets from one end.",
      "color": Colors.orange,
      "icon": FontAwesomeIcons.meteor,
    },
    {
      "id": 45,
      "label": "Fireworks",
      "desc": "Firework sparks.",
      "color": Colors.redAccent,
      "icon": FontAwesomeIcons.fire,
    },
    {
      "id": 46,
      "label": "Fireworks Random",
      "desc": "Random colored firework sparks.",
      "color": Colors.orangeAccent,
      "icon": FontAwesomeIcons.fire,
    },
    {
      "id": 47,
      "label": "Merry Christmas",
      "desc": "Alternating green/red pixels running.",
      "color": Colors.green,
      "icon": FontAwesomeIcons.gifts,
    },
    {
      "id": 48,
      "label": "Fire Flicker",
      "desc": "Fire flickering effect.",
      "color": Colors.red,
      "icon": FontAwesomeIcons.fire,
    },
    {
      "id": 49,
      "label": "Fire Flicker (soft)",
      "desc": "Fire flickering slower/softer.",
      "color": Colors.orange,
      "icon": FontAwesomeIcons.fire,
    },
    {
      "id": 50,
      "label": "Fire Flicker (intense)",
      "desc": "Fire flickering with more range.",
      "color": Colors.redAccent,
      "icon": FontAwesomeIcons.fire,
    },
    {
      "id": 51,
      "label": "Circus Combustus",
      "desc": "Alternating white/red/black pixels running.",
      "color": Colors.red,
      "icon": FontAwesomeIcons.certificate,
    },
    {
      "id": 52,
      "label": "Halloween",
      "desc": "Alternating orange/purple pixels running.",
      "color": Colors.orange,
      "icon": FontAwesomeIcons.ghost,
    },
    {
      "id": 53,
      "label": "Bicolor Chase",
      "desc": "Two LEDs running on a background color.",
      "color": Colors.blue,
      "icon": FontAwesomeIcons.circleHalfStroke,
    },
    {
      "id": 54,
      "label": "Tricolor Chase",
      "desc": "Alternating three color pixels running.",
      "color": Colors.green,
      "icon": FontAwesomeIcons.cubes,
    },
    {
      "id": 55,
      "label": "TwinkleFOX",
      "desc": "Lights fading in and out randomly.",
      "color": Colors.purple,
      "icon": FontAwesomeIcons.star,
    },
  ];

  // final List<Map<String, dynamic>> _modes = [
  //   {"id": 0, "label": "Static", "desc": "No blinking. Just plain old static light.", "color": Color(0xFF1DB954)},
  //   {"id": 1, "label": "Blink", "desc": "Normal blinking. 50% on/off time.", "color": Color(0xFFFFD23F)},
  //   {"id": 2, "label": "Breath", "desc": "Does the 'standby-breathing' of well known i-Devices. Fixed Speed.", "color": Color(0xFF00D4FF)},
  //   {"id": 3, "label": "Color Wipe", "desc": "Lights all LEDs after each other up. Then turns them in that order off. Repeat.", "color": Color(0xFFFF6B35)},
  //   {"id": 4, "label": "Color Wipe Inverse", "desc": "Same as Color Wipe, except swaps on/off colors.", "color": Color(0xFFFF3864)},
  //   {"id": 5, "label": "Color Wipe Reverse", "desc": "Lights all LEDs after each other up. Then turns them in reverse order off. Repeat.", "color": Color(0xFF9C44DC)},
  //   {"id": 6, "label": "Color Wipe Reverse Inverse", "desc": "Same as Color Wipe Reverse, except swaps on/off colors.", "color": Color(0xFF7209B7)},
  //   {"id": 7, "label": "Color Wipe Random", "desc": "Turns all LEDs after each other to a random color. Then starts over with another color.", "color": Color(0xFFE91E63)},
  //   {"id": 8, "label": "Random Color", "desc": "Lights all LEDs in one random color up. Then switches them to the next random color.", "color": Color(0xFF4CAF50)},
  //   {"id": 9, "label": "Single Dynamic", "desc": "Lights every LED in a random color. Changes one random LED after the other to a random color.", "color": Color(0xFF00BCD4)},
  //   {"id": 10, "label": "Multi Dynamic", "desc": "Lights every LED in a random color. Changes all LED at the same time to new random colors.", "color": Color(0xFF673AB7)},
  //   {"id": 11, "label": "Rainbow", "desc": "Cycles all LEDs at once through a rainbow.", "color": Color(0xFF2196F3)},
  //   {"id": 12, "label": "Rainbow Cycle", "desc": "Cycles a rainbow over the entire string of LEDs.", "color": Color(0xFFFF9800)},
  //   {"id": 13, "label": "Scan", "desc": "Runs a single pixel back and forth.", "color": Color(0xFFFF5722)},
  //   {"id": 14, "label": "Dual Scan", "desc": "Runs two pixel back and forth in opposite directions.", "color": Color(0xFF9E9E9E)},
  //   {"id": 15, "label": "Fade", "desc": "Fades the LEDs on and (almost) off again.", "color": Color(0xFF795548)},
  //   {"id": 16, "label": "Theater Chase", "desc": "Theatre-style crawling lights. Inspired by the Adafruit examples.", "color": Color(0xFF607D8B)},
  //   {"id": 17, "label": "Theater Chase Rainbow", "desc": "Theatre-style crawling lights with rainbow effect.", "color": Color(0xFFE91E63)},
  //   {"id": 18, "label": "Running Lights", "desc": "Running lights effect with smooth sine transition.", "color": Color(0xFF2196F3)},
  //   {"id": 19, "label": "Twinkle", "desc": "Blink several LEDs on, reset, repeat.", "color": Color(0xFFFFC107)},
  //   {"id": 20, "label": "Twinkle Random", "desc": "Blink several LEDs in random colors on, reset, repeat.", "color": Color(0xFF4CAF50)},
  //   {"id": 21, "label": "Twinkle Fade", "desc": "Blink several LEDs on, fading out.", "color": Color(0xFF9C27B0)},
  //   {"id": 22, "label": "Twinkle Fade Random", "desc": "Blink several LEDs in random colors on, fading out.", "color": Color(0xFF00BCD4)},
  //   {"id": 23, "label": "Sparkle", "desc": "Blinks one LED at a time.", "color": Color(0xFFFF5722)},
  //   {"id": 24, "label": "Flash Sparkle", "desc": "Lights all LEDs in the selected color. Flashes single white pixels randomly.", "color": Color(0xFF673AB7)},
  //   {"id": 25, "label": "Hyper Sparkle", "desc": "Like flash sparkle. With more flash.", "color": Color(0xFFFF9800)},
  //   {"id": 26, "label": "Strobe", "desc": "Classic Strobe effect.", "color": Color(0xFF03A9F4)},
  //   {"id": 27, "label": "Strobe Rainbow", "desc": "Classic Strobe effect. Cycling through the rainbow.", "color": Color(0xFF8BC34A)},
  //   {"id": 28, "label": "Multi Strobe", "desc": "Strobe effect with different strobe count and pause, controlled by speed setting.", "color": Color(0xFFFF4081)},
  //   {"id": 29, "label": "Blink Rainbow", "desc": "Classic Blink effect. Cycling through the rainbow.", "color": Color(0xFFFFEB3B)},
  //   {"id": 30, "label": "Chase White", "desc": "Color running on white.", "color": Color(0xFF607D8B)},
  //   {"id": 31, "label": "Chase Color", "desc": "White running on color.", "color": Color(0xFF9C27B0)},
  //   {"id": 32, "label": "Chase Random", "desc": "White running followed by random color.", "color": Color(0xFF00BCD4)},
  //   {"id": 33, "label": "Chase Rainbow", "desc": "White running on rainbow.", "color": Color(0xFFFF9800)},
  //   {"id": 34, "label": "Chase Flash", "desc": "White flashes running on color.", "color": Color(0xFFFF5722)},
  //   {"id": 35, "label": "Chase Flash Random", "desc": "White flashes running, followed by random color.", "color": Color(0xFF673AB7)},
  //   {"id": 36, "label": "Chase Rainbow White", "desc": "Rainbow running on white.", "color": Color(0xFF4CAF50)},
  //   {"id": 37, "label": "Chase Blackout", "desc": "Black running on color.", "color": Color(0xFF9E9E9E)},
  //   {"id": 38, "label": "Chase Blackout Rainbow", "desc": "Black running on rainbow.", "color": Color(0xFFFFEB3B)},
  //   {"id": 39, "label": "Color Sweep Random", "desc": "Random color introduced alternating from start and end of strip.", "color": Color(0xFF03A9F4)},
  //   {"id": 40, "label": "Running Color", "desc": "Alternating color/white pixels running.", "color": Color(0xFFFFC107)},
  //   {"id": 41, "label": "Running Red Blue", "desc": "Alternating red/blue pixels running.", "color": Color(0xFFF44336)},
  //   {"id": 42, "label": "Running Random", "desc": "Random colored pixels running.", "color": Color(0xFF4CAF50)},
  //   {"id": 43, "label": "Larson Scanner", "desc": "K.I.T.T.", "color": Color(0xFF03A9F4)},
  //   {"id": 44, "label": "Comet", "desc": "Firing comets from one end.", "color": Color(0xFFFF5722)},
  //   {"id": 45, "label": "Fireworks", "desc": "Firework sparks.", "color": Color(0xFFFF9800)},
  //   {"id": 46, "label": "Fireworks Random", "desc": "Random colored firework sparks.", "color": Color(0xFF673AB7)},
  //   {"id": 47, "label": "Merry Christmas", "desc": "Alternating green/red pixels running.", "color": Color(0xFF4CAF50)},
  //   {"id": 48, "label": "Fire Flicker", "desc": "Fire flickering effect. Like in harsh wind.", "color": Color(0xFFFF9800)},
  //   {"id": 49, "label": "Fire Flicker (soft)", "desc": "Fire flickering effect. Runs slower/softer.", "color": Color(0xFFFFB74D)},
  //   {"id": 50, "label": "Fire Flicker (intense)", "desc": "Fire flickering effect. More range of color.", "color": Color(0xFFFF5722)},
  //   {"id": 51, "label": "Circus Combustus", "desc": "Alternating white/red/black pixels running.", "color": Color(0xFF9C27B0)},
  //   {"id": 52, "label": "Halloween", "desc": "Alternating orange/purple pixels running.", "color": Color(0xFFFF9800)},
  //   {"id": 53, "label": "Bicolor Chase", "desc": "Two LEDs running on a background color.", "color": Color(0xFF00BCD4)},
  //   {"id": 54, "label": "Tricolor Chase", "desc": "Alternating three color pixels running.", "color": Color(0xFF4CAF50)},
  //   {"id": 55, "label": "TwinkleFOX", "desc": "Lights fading in and out randomly.", "color": Color(0xFFFF4081)},
  // ];

  // Compact LED modes - Govee style
  // static const List<Map<String, dynamic>> _modes = [
  //   {
  //     "icon": FontAwesomeIcons.solidCircle,
  //     "label": "Static",
  //     "desc": "No blinking. Just plain old static light.",
  //     "color": Color(0xFF1DB954),
  //   },
  //   {
  //     "icon": FontAwesomeIcons.bolt,
  //     "label": "Blink",
  //     "desc": "Normal blinking. 50% on/off time.",
  //     "color": Color(0xFFFFD23F),
  //   },
  //   {
  //     "icon": FontAwesomeIcons.heart,
  //     "label": "Breath",
  //     "desc": "Standby breathing effect like i-Devices.",
  //     "color": Color(0xFF00D4FF),
  //   },
  //   {
  //     "icon": FontAwesomeIcons.arrowRight,
  //     "label": "Color Wipe",
  //     "desc": "Lights all LEDs up then off in order.",
  //     "color": Color(0xFFFF6B35),
  //   },
  //   {
  //     "icon": FontAwesomeIcons.arrowRightArrowLeft,
  //     "label": "Color Wipe Inverse",
  //     "desc": "Same as Color Wipe but inverse colors.",
  //     "color": Color(0xFFFF3864),
  //   },
  //   {
  //     "icon": FontAwesomeIcons.arrowLeft,
  //     "label": "Color Wipe Reverse",
  //     "desc": "Lights LEDs up then off in reverse order.",
  //     "color": Color(0xFF9C44DC),
  //   },
  //   {
  //     "icon": FontAwesomeIcons.repeat,
  //     "label": "C.Wipe Rev Inv",
  //     "desc": "Reverse wipe with inverse colors.",
  //     "color": Color(0xFF7209B7),
  //   },
  //   {
  //     "icon": FontAwesomeIcons.shuffle,
  //     "label": "Color Wipe Random",
  //     "desc": "Wipe LEDs with random colors.",
  //     "color": Color(0xFFE91E63),
  //   },
  //   {
  //     "icon": FontAwesomeIcons.paintbrush,
  //     "label": "Random Color",
  //     "desc": "All LEDs light up in one random color.",
  //     "color": Color(0xFF4CAF50),
  //   },
  //   {
  //     "icon": FontAwesomeIcons.dice,
  //     "label": "Single Dynamic",
  //     "desc": "Each LED gets a random color dynamically.",
  //     "color": Color(0xFF00BCD4),
  //   },
  //   {
  //     "icon": FontAwesomeIcons.rainbow,
  //     "label": "Rainbow",
  //     "desc": "Smooth rainbow color transitions.",
  //     "color": Color(0xFF673AB7),
  //   },
  //   {
  //     "icon": FontAwesomeIcons.water,
  //     "label": "Rainbow Cycle",
  //     "desc": "Rainbow colors moving across LEDs.",
  //     "color": Color(0xFF2196F3),
  //   },
  // ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _initializeWebSocket();

    // Request current state after a short delay
    Future.delayed(const Duration(seconds: 1), () {
      _requestCurrentState();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    try {
      webSocketService.dispose(); // Close WebSocket connection
    } catch (e) {
      debugPrint("Error disposing WebSocket: $e");
    }
    super.dispose();
  }
void sendSelectedMode(String selectedLabel) {
  final mode = _modes.firstWhere(
    (m) => m['label'] == selectedLabel,
    orElse: () => {"id": -1},
  );

  if (mode['id'] != -1) {
    final data = {
      "modeId": mode['id'], // نرسل ID بدل الاسم
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    };

    // send over WebSocket أو API
        print(data);
        
  }
}
  void _initializeWebSocket() {
    try {
      webSocketService = WebSocketService();

      // Listen to incoming data (String format)
      webSocketService.incomingMessages.listen((data) {
        _handleIncomingData(data);
      });

      webSocketService.connectionStatus.listen((connectionStatus) {
        setState(() {});
      });

      setState(() {
        isConnected = true;
      });
    } catch (e) {
      setState(() {
        isConnected = false;
      });
      debugPrint("WebSocket initialization error: $e");
    }
  }

  void _handleIncomingData(dynamic data) {
    try {
      Map<String, dynamic> jsonData;

      // Check if data is String and parse it
      if (data is String) {
        jsonData = jsonDecode(data);
      } else if (data is Map<String, dynamic>) {
        jsonData = data;
      } else {
        debugPrint("Received unknown data type: ${data.runtimeType}");
        return;
      }

      setState(() {
        // Handle color data
        if (jsonData.containsKey('color')) {
          final colorData = jsonData['color'];
          if (colorData is Map<String, dynamic>) {
            selectedColor = Color.fromARGB(
              255,
              (colorData['r'] as num?)?.toInt() ?? selectedColor.red,
              (colorData['g'] as num?)?.toInt() ?? selectedColor.green,
              (colorData['b'] as num?)?.toInt() ?? selectedColor.blue,
            );
          }
        }

        // Handle brightness data
        if (jsonData.containsKey('brightness')) {
          final brightnessValue = jsonData['brightness'];
          if (brightnessValue is num) {
            brightness = brightnessValue.toDouble().clamp(1.0, 255.0);
          }
        }

        // Handle mode data
        if (jsonData.containsKey('mode')) {
          final mode = jsonData['mode'] as String?;
          if (mode != null && _modes.any((m) => m['label'] == mode)) {
            selectedMode = mode;
          }
        }

        // Handle power state
        if (jsonData.containsKey('power')) {
          final powerState = jsonData['power'] as bool?;
          if (powerState != null) {
            // You can add power state handling here if needed
            debugPrint("Power state: $powerState");
          }
        }

        // Handle status messages
        if (jsonData.containsKey('status')) {
          final status = jsonData['status'] as String?;
          if (status != null) {}
        }

        // Handle device info
        if (jsonData.containsKey('device')) {
          debugPrint("Connected to: ${jsonData['device']}");
          if (jsonData.containsKey('led_count')) {
            debugPrint("LED count: ${jsonData['led_count']}");
          }
          if (jsonData.containsKey('wifi_signal')) {
            debugPrint("WiFi signal: ${jsonData['wifi_signal']} dBm");
          }
        }
      });
    } catch (e) {
      debugPrint("Error handling incoming data: $e");
      debugPrint("Raw data received: $data");
    }
  }

  Future<void> _requestCurrentState() async {
    if (!isConnected) return;

    try {
      Map<String, dynamic> requestData = {
        "action": "get_current_state",
        "timestamp": DateTime.now().millisecondsSinceEpoch,
      };

      webSocketService.sendJsonData(requestData);
    } catch (e) {
      debugPrint("Error requesting current state: $e");
    }
  }

  Future<void> _sendData(String type) async {
    if (!isConnected) return;

    try {
      Map<String, dynamic> data = {};

      if (type == "color") {
        data = {
          "color": {
            "r": selectedColor.red,
            "g": selectedColor.green,
            "b": selectedColor.blue,
          },
          "timestamp": DateTime.now().millisecondsSinceEpoch,
        };
      } else if (type == "brightness") {
        data = {
          "brightness": brightness.round(),
          "timestamp": DateTime.now().millisecondsSinceEpoch,
        };
      } else if (type == "mode") {
        data = {
          "mode": selectedMode,
          "timestamp": DateTime.now().millisecondsSinceEpoch,
        };
      } else if (type == "wifi_config") {
        data = {
          "action": "configure_wifi",
          "wifi_ssid": wifiSSID,
          "wifi_password": wifiPassword,
          "timestamp": DateTime.now().millisecondsSinceEpoch,
        };
      }

      if (data.isNotEmpty) {
        webSocketService.sendJsonData(data);
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  void _showSettingsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSettingsModal(),
    );
  }

  Widget _buildSettingsModal() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Settings header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Settings",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12),
          // Settings content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWiFiSection(),
                  const SizedBox(height: 24),
                  _buildDeviceSection(),
                  const SizedBox(height: 24),
                  _buildAdvancedSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWiFiSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(FontAwesomeIcons.wifi, color: selectedColor, size: 20),
              const SizedBox(width: 12),
              const Text(
                "WiFi Configuration",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // SSID Field
          TextField(
            style: const TextStyle(color: Colors.white),
            onChanged: (value) => setState(() => wifiSSID = value),
            decoration: InputDecoration(
              labelText: "Network Name (SSID)",
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              prefixIcon: Icon(Icons.router, color: selectedColor),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: selectedColor),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Password Field
          TextField(
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            onChanged: (value) => setState(() => wifiPassword = value),
            decoration: InputDecoration(
              labelText: "Password",
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              prefixIcon: Icon(Icons.lock, color: selectedColor),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: selectedColor),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Connect Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (wifiSSID.isNotEmpty && wifiPassword.isNotEmpty) {
                  _sendData("wifi_config");
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("WiFi configuration sent to device"),
                      backgroundColor: selectedColor,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Configure WiFi",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(FontAwesomeIcons.microchip, color: selectedColor, size: 20),
              const SizedBox(width: 12),
              const Text(
                "Device Settings",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Device Name Field
          TextField(
            style: const TextStyle(color: Colors.white),
            onChanged: (value) => setState(() => deviceName = value),
            controller: TextEditingController(text: deviceName),
            decoration: InputDecoration(
              labelText: "Device Name",
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              prefixIcon: Icon(Icons.device_hub, color: selectedColor),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: selectedColor),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Auto Connect Toggle
          _buildSwitchTile(
            "Auto Connect",
            "Automatically connect when app opens",
            autoConnect,
            (value) => setState(() => autoConnect = value),
            FontAwesomeIcons.bolt,
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(FontAwesomeIcons.gear, color: selectedColor, size: 20),
              const SizedBox(width: 12),
              const Text(
                "Advanced Settings",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Refresh Rate Slider
          Text(
            "Refresh Rate: ${refreshRate}Hz",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: selectedColor,
              inactiveTrackColor: Colors.white.withOpacity(0.1),
              thumbColor: selectedColor,
              overlayColor: selectedColor.withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              trackHeight: 3,
            ),
            child: Slider(
              value: refreshRate.toDouble(),
              onChanged: (val) => setState(() => refreshRate = val.round()),
              min: 10,
              max: 60,
              divisions: 5,
            ),
          ),
          const SizedBox(height: 16),
          // Debug Mode Toggle
          _buildSwitchTile(
            "Debug Mode",
            "Show detailed connection logs",
            debugMode,
            (value) => setState(() => debugMode = value),
            FontAwesomeIcons.bug,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: selectedColor, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: selectedColor,
            inactiveThumbColor: Colors.white.withOpacity(0.4),
            inactiveTrackColor: Colors.white.withOpacity(0.1),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Column(
        children: [
          _buildCompactHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).padding.bottom + 16,
              ),
              child: Column(
                children: [
                  _buildColorSection(),
                  const SizedBox(height: 16),
                  _buildBrightnessSection(),
                  const SizedBox(height: 16),
                  _buildModesGrid(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactHeader() {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [selectedColor.withOpacity(0.2), Colors.transparent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Luminix",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          Row(
            children: [
              GestureDetector(
                onTap: () {
                  webSocketService.redial();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    FontAwesomeIcons.refresh,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              GestureDetector(
                onTap: _showSettingsModal,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    FontAwesomeIcons.gear,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Connection Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isConnected ? Colors.green : Colors.red).withOpacity(
                    0.2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isConnected ? Colors.green : Colors.red,
                    width: 1,
                  ),
                ),
                child: GestureDetector(
                  onTap: () {
                    if (isConnected) {
                      _requestCurrentState();
                    } else {
                      _initializeWebSocket();
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isConnected ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isConnected ? "ON" : "OFF",
                        style: TextStyle(
                          color: isConnected ? Colors.green : Colors.red,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        isConnected ? Icons.refresh : Icons.wifi_off,
                        color: isConnected ? Colors.green : Colors.red,
                        size: 12,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorSection() {
    return Container(
      width: double.infinity,
      height: 350,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: selectedColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Color",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: selectedColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: 0.90,
                child: ColorPicker(
                  enableAlpha: true,
                  showLabel: false,
                  portraitOnly: false,
                  colorPickerWidth: 250,
                  pickerColor: selectedColor,
                  onColorChanged: (Color color) {
                    setState(() {
                      selectedColor = color;
                    });
                    _sendData("color");
                  },
                  paletteType: PaletteType.hueWheel,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrightnessSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Brightness",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: selectedColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "${((brightness / 255) * 100).round()}%",
                  style: TextStyle(
                    color: selectedColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: selectedColor,
              inactiveTrackColor: Colors.white.withOpacity(0.1),
              thumbColor: selectedColor,
              overlayColor: selectedColor.withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              trackHeight: 4,
            ),
            child: Slider(
              value: brightness,
              onChanged: (val) {
                setState(() {
                  brightness = val;
                });
              },
              onChangeEnd: (val) => _sendData("brightness"),
              min: 1,
              max: 255,
            ),
          ),
        ],
      ),
    );
  }

  // أضف هذه المتغيرات في أعلى الكلاس
  bool _showAllModes = false;

  Widget _buildModesGrid() {
    // تحديد عدد العناصر المعروضة
    final int displayCount = _showAllModes ? _modes.length : 9;
    final List modestoShow = _modes.take(displayCount).toList();
    final bool hasMoreItems = _modes.length > 10;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Effects",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (hasMoreItems) ...[
                const SizedBox(height: 16),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _showAllModes = !_showAllModes;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _showAllModes ? "Show Less" : "Show More",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            _showAllModes
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.white70,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: modestoShow.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final mode = modestoShow[index];
              final isActive = selectedMode == mode["label"];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedMode = mode["label"];
                  });
                  _sendData("mode");
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isActive
                        ? mode["color"].withOpacity(0.2)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isActive
                          ? mode["color"]
                          : Colors.white.withOpacity(0.1),
                      width: isActive ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        mode["icon"],
                        color: isActive ? mode["color"] : Colors.white60,
                        size: 18,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        mode["label"],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isActive ? mode["color"] : Colors.white60,
                          fontSize: mode["label"].length > 7 ? 9 : 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // زر إظهار المزيد/إخفاء
        ],
      ),
    );
  }
}
