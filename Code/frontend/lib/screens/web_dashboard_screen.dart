import 'package:flutter/material.dart';
import 'package:frontend/screens/web_profile_screen.dart';
import 'package:frontend/services/auth_service.dart';
import '../services/device_service.dart';
import 'dart:async';
import '../services/sensor_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'web_login_screen.dart';

class WebDashboardScreen extends StatefulWidget {
  const WebDashboardScreen({super.key});

  @override
  State<WebDashboardScreen> createState() => _WebDashboardScreenState();
}

class _WebDashboardScreenState extends State<WebDashboardScreen> {
  String _userName = "Đang tải...";

  // Sensor Data
  String _temperature = "--";
  String _lastUpdateTemp = "Đang tải...";

  String _humidity = "--";
  String _lastUpdateHumid = "Đang tải...";

  //String smokeStatus = "--";
  String _brightness = "--";
  String _lastUpdateBright = "Đang tải...";

  List<FlSpot> _tempHistorySpots = [];

  Timer? _sensorTimer;
  
  // Device States
  bool lightOn = false;
  bool fanOn = false;
  // bool acOn = false;
  // bool dehumOn = false;

  // Color to Hex
  String _colorToHex(Color color) {
    // toRadixString(16) converts the color to hex. 
    // We padLeft to ensure it's always 8 characters (AARRGGBB).
    // Then we substring(2, 8) to strip the Alpha (opacity) channel, leaving RRGGBB.
    final hexString = color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2, 8).toUpperCase();
    return '#$hexString';
  }
  
  // The selected color for the light (starts green based on your design)
  Color selectedLightColor = Colors.green;

  // // Alerts and Logs (Empty by default as requested)
  // List<dynamic> recentAlerts = []; 
  // List<dynamic> systemLogs = [];

  // // Threshold Settings
  // final _tempLowCtrl = TextEditingController(text: '15');
  // final _tempHighCtrl = TextEditingController(text: '35');
  // final _humLowCtrl = TextEditingController(text: '30');
  // final _humHighCtrl = TextEditingController(text: '80');

  @override
  void initState() {
    super.initState();
    _fetchAllDashboardData();
    _sensorTimer = Timer.periodic(const Duration(seconds: 5), (timer){
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
    // _fetchDeviceStates();
    // _fetchAlerts();
    // _fetchLogs();
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
    if (data != null && mounted){
      setState(() {
        double rawTemp = (data['value'] as num).toDouble();
        _temperature = rawTemp.toStringAsFixed(1);
        _lastUpdateTemp = data['created_at'] ?? 'Vừa xong';
      });
    }
  }

  Future<void> _fetchHumid() async {
    final data = await SensorService.getTemperature();
    if (data != null && mounted){
      setState(() {
        double rawHumid = (data['value'] as num).toDouble();
        _humidity = rawHumid.toStringAsFixed(0);
        _lastUpdateHumid = data['created_at'] ?? 'Vừa xong';
      });
    }
  }

  Future<void> _fetchBrightness() async {
    final data = await SensorService.getBrightness();
    if (data != null && mounted){
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
        // Map the JSON array into a list of (X, Y) coordinates for the chart
        _tempHistorySpots = history.asMap().entries.map((entry) {
          int index = entry.key; // X-axis (0, 1, 2, 3...)
          double value = (entry.value['value'] as num).toDouble(); // Y-axis (Temperature)
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
      // If fetching fails (e.g. token expired), default to 'Khách' (Guest)
      setState(() {
        _userName = 'Khách';
      });
    }
  }

  // Future<void> _fetchDeviceStates() async {
  //   // TODO: Add your GET request here for device status
  // }

  // Future<void> _fetchAlerts() async {
  //   // TODO: Add your GET request here for "Cảnh báo gần đây"
  // }

  // Future<void> _fetchLogs() async {
  //   // TODO: Add your GET request here for "Nhật ký hệ thống"
  // }

  void _onColorSelected(Color selectedColor) async {
    String hexColor = _colorToHex(selectedColor);
    bool success = await DeviceService.changeLedColor(hexColor);
    if (!success && mounted){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lỗi: Không thể chọn được màu đèn'),
          backgroundColor: Colors.red,)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA), // Light grey background
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 30),
            
            // Top Row: Sensors
            Row(
              children: [
                Expanded(child: _buildSensorCard('Nhiệt độ', '$_temperature°C', 'Cập nhât: $_lastUpdateTemp', Colors.green)),
                const SizedBox(width: 20),
                Expanded(child: _buildSensorCard('Độ ẩm', '$_humidity%', 'Cập nhật: $_lastUpdateHumid', Colors.green)),
                const SizedBox(width: 20),
                Expanded(child: _buildSensorCard('Độ sáng', '$_brightness lx', 'Cập nhật: $_lastUpdateBright', Colors.green)),
              ],
            ),
            const SizedBox(height: 20),

            // Middle Row: Chart & Devices
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 1, child: _buildPanel('Biểu đồ nhiệt độ',
                  SizedBox(
                    height: 250,
                    child: _tempHistorySpots.isEmpty
                    ? const Center(child: CircularProgressIndicator(color: Colors.green))
                    : LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _tempHistorySpots,
                            isCurved: true, // Makes the line smooth instead of jagged
                            color: Colors.green, // Brand color
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false), // Hides the dots on the line
                                  
                            // Adds a cool semi-transparent gradient below the line
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.green.withValues(alpha: 0.2), 
                            ),
                          ),
                        ],
                      ),
                      ),
                    ),
                  )
                ),
                const SizedBox(width: 20),
                Expanded(flex: 1, child: _buildDeviceControls()),
              ],
            ),
            const SizedBox(height: 20),

            // Bottom Row: Alerts & Settings
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 1, child: _buildAlertsPanel()),
                const SizedBox(width: 20),
                Expanded(flex: 1, child: _buildSettingsPanel()),
              ],
            ),
            const SizedBox(height: 20),

            // Footer: Logs
            _buildLogsPanel(),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Smart Home Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('Bảng điều khiển quản trị', style: TextStyle(color: Colors.grey)),
          ],
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WebProfileScreen()),
            );
          },
          child: Text(_userName, textAlign: TextAlign.right),
        ),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () async { 
                await AuthService.logout();

                if (mounted){
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const WebLoginScreen()), 
                    (route) => false
                  );
                }
                },
              icon: const Icon(Icons.logout, color: Colors.black),
              label: const Text('Đăng xuất', style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            )
          ],
        )
      ],
    );
  }

  Widget _buildSensorCard(String title, String value, String subtext, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade300)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: valueColor)),
          const SizedBox(height: 5),
          Text(subtext, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildPanel(String title, Widget content) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade300)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          content,
        ],
      ),
    );
  }

  Widget _buildDeviceControls() {
    return _buildPanel(
      'Điều khiển thiết bị',
      Column(
        children: [
          _buildDeviceSwitch('Đèn phòng khách', lightOn, 
          (newVal) async {
            setState(() => lightOn = newVal);
            bool success = await DeviceService.toggleLed(newVal);
            if (!success && mounted){
              setState(() => lightOn = !newVal);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Lỗi: Không thể kết nối với đèn phòng khách'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
            hasColorPicker: true
          ), 
          const SizedBox(height: 10),
          _buildDeviceSwitch('Quạt phòng ngủ', fanOn, 
          (newVal) async {
            setState(() => fanOn = newVal);
            bool success = await DeviceService.toggleFan(newVal);
            if (!success && mounted){
              setState(() => fanOn = !newVal);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Lỗi: Không thể kết nối với quạt'),
                backgroundColor: Colors.red,));
              }
            },
          ),
          const SizedBox(height: 10),
          _buildDeviceSwitch('Máy lạnh', false, (val) => setState(() => false)),
          const SizedBox(height: 10),
          _buildDeviceSwitch('Máy hút ẩm', false, (val) => setState(() => false)),
        ],
      ),
    );
  }

  Widget _buildDeviceSwitch(String name, bool value, Function(bool) onChanged, {bool hasColorPicker = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: value ? Colors.green.withValues(alpha: 0.1) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.device_hub, color: value ? Colors.green : Colors.grey),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(value ? 'Đang bật' : 'Đang tắt', style: TextStyle(fontSize: 12, color: value ? Colors.green : Colors.grey)),
              ],
            ),
          ),
          if (hasColorPicker)
            GestureDetector(
              onTap: _showColorPickerDialog, // This triggers the popup
              child: Container(
                margin: const EdgeInsets.only(right: 15),
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: selectedLightColor, // Dynamic color
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey),
                ),
              ),
            ),
          Switch(
            value: value,
            onChanged: (newVal) {
              onChanged(newVal);
            },
            activeThumbColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsPanel() {
    return _buildPanel(
      'Cảnh báo gần đây', const Center(child: Text("Không có cảnh báo nào.", style: TextStyle(color: Colors.grey)))
      // recentAlerts.isEmpty 
      //     ? const Center(child: Text("Không có cảnh báo nào.", style: TextStyle(color: Colors.grey)))
      //     : Column(children: recentAlerts.map((e) => Text(e.toString())).toList()), // Will populate when API is written
    );
  }

  Widget _buildLogsPanel() {
    return _buildPanel(
      'Nhật ký hệ thống', 
      const Center(child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("Chưa có nhật ký hệ thống.", style: TextStyle(color: Colors.grey)),
            ))
      // systemLogs.isEmpty 
      //     ? const Center(child: Padding(
      //         padding: EdgeInsets.all(20.0),
      //         child: Text("Chưa có nhật ký hệ thống.", style: TextStyle(color: Colors.grey)),
      //       ))
      //     : Column(children: systemLogs.map((e) => Text(e.toString())).toList()), // Will populate when API is written
    );
  }

  Widget _buildSettingsPanel() {
    return _buildPanel(
      'Cài đặt ngưỡng cảnh báo',
      Column(
        children: [
          // Simplified for brevity - in reality you'd build rows of TextFields here
          const Text("Các trường nhập liệu sẽ ở đây..."),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Add POST request to send settings to backend
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Lưu cài đặt', style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }
}