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

  // Compact LED modes - Govee style
  static const List<Map<String, dynamic>> _modes = [
    {
      "icon": FontAwesomeIcons.solidCircle,
      "label": "Static",
      "desc": "No blinking. Just plain old static light.",
      "color": Color(0xFF1DB954),
    },
    {
      "icon": FontAwesomeIcons.bolt,
      "label": "Blink",
      "desc": "Normal blinking. 50% on/off time.",
      "color": Color(0xFFFFD23F),
    },
    {
      "icon": FontAwesomeIcons.heart,
      "label": "Breath",
      "desc": "Standby breathing effect like i-Devices.",
      "color": Color(0xFF00D4FF),
    },
    {
      "icon": FontAwesomeIcons.arrowRight,
      "label": "Color Wipe",
      "desc": "Lights all LEDs up then off in order.",
      "color": Color(0xFFFF6B35),
    },
    {
      "icon": FontAwesomeIcons.arrowRightArrowLeft,
      "label": "Color Wipe Inverse",
      "desc": "Same as Color Wipe but inverse colors.",
      "color": Color(0xFFFF3864),
    },
    {
      "icon": FontAwesomeIcons.arrowLeft,
      "label": "Color Wipe Reverse",
      "desc": "Lights LEDs up then off in reverse order.",
      "color": Color(0xFF9C44DC),
    },
    {
      "icon": FontAwesomeIcons.repeat,
      "label": "C.Wipe Rev Inv",
      "desc": "Reverse wipe with inverse colors.",
      "color": Color(0xFF7209B7),
    },
    {
      "icon": FontAwesomeIcons.shuffle,
      "label": "Color Wipe Random",
      "desc": "Wipe LEDs with random colors.",
      "color": Color(0xFFE91E63),
    },
    {
      "icon": FontAwesomeIcons.paintbrush,
      "label": "Random Color",
      "desc": "All LEDs light up in one random color.",
      "color": Color(0xFF4CAF50),
    },
    {
      "icon": FontAwesomeIcons.dice,
      "label": "Single Dynamic",
      "desc": "Each LED gets a random color dynamically.",
      "color": Color(0xFF00BCD4),
    },
    {
      "icon": FontAwesomeIcons.rainbow,
      "label": "Rainbow",
      "desc": "Smooth rainbow color transitions.",
      "color": Color(0xFF673AB7),
    },
    {
      "icon": FontAwesomeIcons.water,
      "label": "Rainbow Cycle",
      "desc": "Rainbow colors moving across LEDs.",
      "color": Color(0xFF2196F3),
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _initializeWebSocket();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeWebSocket() {
    try {
      webSocketService = WebSocketService();
      setState(() {
        isConnected = true;
      });
    } catch (e) {
      setState(() {
        isConnected = false;
      });
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
      }

      if (data.isNotEmpty) {
        webSocketService.sendJsonData(data);
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      // إزالة SafeArea من هنا وإضافته داخليًا حسب الحاجة
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
                // إضافة padding للأسفل لتجنب مشاكل الـ home indicator
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
      // إضافة SafeArea للهيدر فقط
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: MediaQuery.of(context).padding.top + 12, // تجنب الـ notch
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: (isConnected ? Colors.green : Colors.red).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isConnected ? Colors.green : Colors.red,
                width: 1,
              ),
            ),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSection() {
    return Container(
      width: double.infinity,
      // تقليل الارتفاع قليلاً لتجنب مشاكل الشاشة
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

  Widget _buildModesGrid() {
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
          const Text(
            "Effects",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _modes.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final mode = _modes[index];
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
        ],
      ),
    );
  }
}
