// lib/screens/mobile_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';

// Update these imports to match your project structure
import '../services/auth_service.dart';
import '../services/device_service.dart';
import '../services/sensor_service.dart';
import 'mobile_profile_screen.dart'; // Assuming you have a mobile profile screen
import 'mobile_login_screen.dart';

class MobileDashboardScreen extends StatefulWidget {
  const MobileDashboardScreen({super.key});

  @override
  State<MobileDashboardScreen> createState() => _MobileDashboardScreenState();
}

class _MobileDashboardScreenState extends State<MobileDashboardScreen> {

  String _userName = "Đang tải...";

  // Sensor Data
  String _temperature = "--";
  String _lastUpdateTemp = "Đang tải...";

  String _humidity = "--";
  String _lastUpdateHumid = "Đang tải...";

  String _brightness = "--";
  String _lastUpdateBright = "Đang tải...";

  List<FlSpot> _tempHistorySpots = [];

  Timer? _sensorTimer;

  // Device States
  bool lightOn = false;
  int fanSpeed = 0;

  // Color to index
  int _colorToInt(Color color) {
    if (color == Colors.white) return 1;
    if (color == Colors.red) return 2;
    if (color == Colors.orange) return 3;
    if (color == Colors.yellow) return 4;
    if (color == Colors.green) return 5;
    if (color == Colors.blue) return 6;
    return 0;
  }

  Color selectedLightColor = Colors.white;

  // Colors for Mobile UI
  static const Color _primaryGreen = Color(0xFF4ADE80);
  static const Color _textDark = Color(0xFF1A1A1A);
  static const Color _borderColor = Color(0xFFE5E7EB);


  @override
  void initState() {
    super.initState();
    _fetchAllDashboardData();
    _sensorTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchSensorData();
    });
  }

  @override
  void dispose() {
    _sensorTimer?.cancel();
    super.dispose();
  }

  void _fetchAllDashboardData() {
    _fetchUserProfile();
    _fetchSensorData();
  }

  Future<void> _fetchSensorData() async {
    await Future.wait([
      _fetchTemp(),
      _fetchHumid(),
      _fetchBrightness(),
      _fetchTempHistory(),
    ]);
  }

  Future<void> _fetchTemp() async {
    final data = await SensorService.getTemperature();
    if (data != null && mounted) {
      setState(() {
        double rawTemp = (data['value'] as num).toDouble();
        _temperature = rawTemp.toStringAsFixed(1);
        _lastUpdateTemp = data['created_at'] ?? 'Vừa xong';
      });
    }
  }

  Future<void> _fetchHumid() async {
    final data =
        await SensorService.getTemperature(); // Note: Check if this should be getHumidity() based on your web code
    if (data != null && mounted) {
      setState(() {
        double rawHumid = (data['value'] as num).toDouble();
        _humidity = rawHumid.toStringAsFixed(0);
        _lastUpdateHumid = data['created_at'] ?? 'Vừa xong';
      });
    }
  }

  Future<void> _fetchBrightness() async {
    final data = await SensorService.getBrightness();
    if (data != null && mounted) {
      setState(() {
        double rawBright = (data['value'] as num).toDouble();
        _brightness = rawBright.toStringAsFixed(0);
        _lastUpdateBright = data['created_at'] ?? 'Vừa xong';
      });
    }
  }

  Future<void> _fetchTempHistory() async {
    final history = await SensorService.getTemperatureHistory(limit: 15);

    if (history != null && mounted) {
      setState(() {
        _tempHistorySpots = history.asMap().entries.map((entry) {
          int index = entry.key;
          double value = (entry.value['value'] as num).toDouble();
          return FlSpot(index.toDouble(), value);
        }).toList();
      });
    }
  }

  Future<void> _fetchUserProfile() async {
    final userData = await AuthService.getUserProfile();

    if (userData != null && mounted) {
      setState(() {
        _userName = userData['fullname'] ?? 'Người dùng';
      });
    } else if (mounted) {
      setState(() {
        _userName = 'Khách';
      });
    }
  }

  void _onColorSelected(Color selectedColor) async {
    int colorIndex = _colorToInt(selectedColor);
    bool success = await DeviceService.changeLedColor(colorIndex);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lỗi: Không thể chọn được màu đèn'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showColorPickerDialog() {
    final List<Color> availableColors = [
      Colors.white,
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chọn màu đèn'),
          content: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: availableColors.map((color) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedLightColor = color;
                  });
                  _onColorSelected(selectedLightColor);
                  Navigator.pop(context);
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey, width: 2),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // ==========================================
  // MOBILE UI BUILDER
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildSensorsSection(),
              const SizedBox(height: 16),
              _buildChartSection(),
              const SizedBox(height: 16),
              _buildDevicesSection(),
              const SizedBox(height: 16),
              _buildAlertsSection(),
              const SizedBox(height: 16),
              _buildSettingsSection(),
              const SizedBox(height: 16),
              _buildLogsSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            const Icon(Icons.home_work, color: Colors.blue, size: 32),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Smart Home Dashboard',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  'Bảng điều khiển quản trị',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MobileProfileScreen(),
                  ),
                );
              },
              child: Row(
                children: [
                  const Text('Chủ nhà', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _primaryGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () async {
                await AuthService.logout();
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MobileLoginScreen(),
                    ),
                    (route) => false,
                  );
                }
              },
              child: Row(
                children: [
                  Icon(Icons.logout, size: 14, color: Colors.grey.shade800),
                  const SizedBox(width: 4),
                  const Text(
                    'Đăng xuất',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSensorsSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSensorCard(
                title: 'Nhiệt độ',
                value: '$_temperature°C',
                subtext: 'Cập nhật: $_lastUpdateTemp',
                icon: Icons.thermostat,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSensorCard(
                title: 'Độ ẩm',
                value: '$_humidity%',
                subtext: 'Cập nhật: $_lastUpdateHumid',
                icon: Icons.water_drop_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSensorCard(
                title: 'Độ sáng',
                value: '$_brightness lx',
                subtext: 'Cập nhật: $_lastUpdateBright',
                icon: Icons.light_mode_outlined,
              ),
            ),
            const Spacer(),
          ],
        ),
      ],
    );
  }

  Widget _buildChartSection() {
    return _buildSectionWrapper(
      title: 'Biểu đồ nhiệt độ',
      child: SizedBox(
        height: 200, // Slightly smaller height for mobile
        child: _tempHistorySpots.isEmpty
            ? const Center(
                child: CircularProgressIndicator(color: Colors.green),
              )
            : LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _tempHistorySpots,
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.green.withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildDevicesSection() {
    return _buildSectionWrapper(
      title: 'Điều khiển thiết bị',
      child: Column(
        children: [
          // 1. Light Control (With Color Picker)
          _buildDeviceToggle(
            name: 'Đèn phòng khách',
            isOn: lightOn,
            icon: Icons.lightbulb_outline,
            hasColorPicker: true,
            onChanged: (newVal) async {
              setState(() => lightOn = newVal);
              bool success = await DeviceService.toggleLed(newVal);
              if (!success && mounted) {
                setState(() => lightOn = !newVal);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lỗi: Không thể kết nối với đèn phòng khách'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),

          // 2. Fan Control (Slider)
          _buildFanSpeedControl(),

          // Static placeholders matching your web code
          _buildDeviceToggle(
            name: 'Máy lạnh',
            isOn: false,
            icon: Icons.ac_unit,
            onChanged: (val) {},
          ),
          _buildDeviceToggle(
            name: 'Máy hút ẩm',
            isOn: false,
            icon: Icons.air,
            onChanged: (val) {},
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsSection() {
    return _buildSectionWrapper(
      title: 'Cảnh báo gần đây',
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Text(
            "Không có cảnh báo nào.",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return _buildSectionWrapper(
      title: 'Cài đặt ngưỡng cảnh báo',
      child: Column(
        children: [
          const Center(
            child: Text(
              "Các trường nhập liệu sẽ ở đây...",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryGreen,
              minimumSize: const Size(double.infinity, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Lưu cài đặt',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsSection() {
    return _buildSectionWrapper(
      title: 'Nhật ký hệ thống',
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Text(
            "Chưa có nhật ký hệ thống.",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // HELPER WIDGETS
  // ==========================================

  Widget _buildSectionWrapper({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildSensorCard({
    required String title,
    required String value,
    required String subtext,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _borderColor),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: _primaryGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtext,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
              ),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Icon(icon, size: 20, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceToggle({
    required String name,
    required bool isOn,
    required IconData icon,
    required Function(bool) onChanged,
    bool hasColorPicker = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: isOn ? _primaryGreen : Colors.black87, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  isOn ? 'Đang bật' : 'Đang tắt',
                  style: TextStyle(
                    fontSize: 10,
                    color: isOn ? _primaryGreen : Colors.grey.shade600,
                    fontWeight: isOn ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          if (hasColorPicker)
            GestureDetector(
              onTap: _showColorPickerDialog,
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: selectedLightColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade400),
                ),
              ),
            ),
          SizedBox(
            height: 24,
            child: CupertinoSwitch(
              value: isOn,
              activeTrackColor: _primaryGreen,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFanSpeedControl() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.cyclone,
                color: fanSpeed > 0 ? _primaryGreen : Colors.black87,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Quạt phòng ngủ',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '$fanSpeed%',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Slider(
            value: fanSpeed.toDouble(),
            min: 0,
            max: 100,
            divisions: 100,
            activeColor: _primaryGreen,
            inactiveColor: Colors.grey.shade200,
            onChanged: (double newValue) {
              setState(() => fanSpeed = newValue.round());
            },
            onChangeEnd: (double endSpeed) async {
              bool success = await DeviceService.setFanSpeed(endSpeed.round());
              if (!success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lỗi: Không thể kết nối với quạt'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
