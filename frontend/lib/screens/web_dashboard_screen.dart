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
  List<String> _tempHistoryLabels = [];
  double _tempChartMinY = 0;
  double _tempChartMaxY = 40;

  Timer? _sensorTimer;
  
  // Device States
  bool lightOn = false;
  int fanSpeed = 0;
  // bool acOn = false;
  // bool dehumOn = false;

  // Color to index
  int _colorToInt(Color color) {
    if (color == Colors.white) return 1;
    if (color == Colors.red) return 2;
    if (color == Colors.orange) return 3;
    if (color == Colors.yellow) return 4;
    if (color == Colors.green) return 5;
    if (color == Colors.blue) return 6;
    return 0; // Default to white if the color is unknown
  }
  
  // The selected color for the light (starts green based on your design)
  Color selectedLightColor = Colors.white;

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
    final data = await SensorService.getHumidity();
    if (data != null && mounted){
      setState(() {
        double rawHumid = (data['value'] as num).toDouble();
        _humidity = rawHumid.toStringAsFixed(1);
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
        final spots = history.asMap().entries.map((entry) {
          int index = entry.key; // X-axis position for each time sample
          double value = (entry.value['value'] as num).toDouble(); // Y-axis (Temperature)
          return FlSpot(index.toDouble(), value);
        }).toList();

        _tempHistorySpots = spots;
        _tempHistoryLabels = history.asMap().entries.map((entry) {
          final rawTime = entry.value['created_at'] ?? '';
          final parsed = DateTime.tryParse(rawTime.toString());
          if (parsed != null) {
            return '${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}';
          }
          return rawTime.toString();
        }).toList();

        final values = spots.map((spot) => spot.y).toList();
        final maxValue = values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b) : 0;
        final minValue = values.isNotEmpty ? values.reduce((a, b) => a < b ? a : b) : 0;
        _tempChartMaxY = (maxValue + 1).toDouble();
        _tempChartMinY = (minValue - 1).toDouble();
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
    int colorIndex = _colorToInt(selectedColor);
    bool success = await DeviceService.changeLedColor(colorIndex);
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isMobile = constraints.maxWidth < 700;
          return _buildBody(isMobile);
        },
      ),
    );
  }

  Widget _buildBody(bool isMobile) {
    final EdgeInsets padding = isMobile
        ? const EdgeInsets.all(16.0)
        : const EdgeInsets.all(30.0);

    return SingleChildScrollView(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isMobile),
          const SizedBox(height: 24),

          // Top Row: Sensors — stacked on mobile, side-by-side on desktop
          isMobile
              ? Column(
                  children: [
                    _buildSensorCard('Nhiệt độ', '$_temperature°C', 'Cập nhật: $_lastUpdateTemp', Colors.green),
                    const SizedBox(height: 12),
                    _buildSensorCard('Độ ẩm', '$_humidity%', 'Cập nhật: $_lastUpdateHumid', Colors.green),
                    const SizedBox(height: 12),
                    _buildSensorCard('Độ sáng', '$_brightness lx', 'Cập nhật: $_lastUpdateBright', Colors.green),
                  ],
                )
              : Row(
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
          isMobile
              ? Column(
                  children: [
                    _buildPanel('Biểu đồ nhiệt độ', _buildTempChart()),
                    const SizedBox(height: 20),
                    _buildDeviceControls(),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 1, child: _buildPanel('Biểu đồ nhiệt độ', _buildTempChart())),
                    const SizedBox(width: 20),
                    Expanded(flex: 1, child: _buildDeviceControls()),
                  ],
                ),
          const SizedBox(height: 20),

          // Bottom Row: Alerts & Settings
          isMobile
              ? Column(
                  children: [
                    _buildAlertsPanel(),
                    const SizedBox(height: 20),
                    _buildSettingsPanel(),
                  ],
                )
              : Row(
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
    );
  }

  // Extracted chart widget to avoid duplication
  Widget _buildTempChart() {
    return SizedBox(
      height: 250,
      child: _tempHistorySpots.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : LineChart(
              LineChartData(
                minY: _tempChartMinY,
                maxY: _tempChartMaxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: ((_tempChartMaxY - _tempChartMinY) / 5).clamp(0.1, 5),
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.shade300,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: _tempHistorySpots.isNotEmpty
                          ? (_tempHistorySpots.length / 5).floorToDouble().clamp(1, _tempHistorySpots.length.toDouble())
                          : 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= _tempHistoryLabels.length) {
                          return const SizedBox.shrink();
                        }
                        return Text(_tempHistoryLabels[index], style: const TextStyle(fontSize: 11, color: Colors.grey));
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: ((_tempChartMaxY - _tempChartMinY) / 5).clamp(0.1, 5),
                      getTitlesWidget: (value, meta) {
                        return Text(value.toStringAsFixed(1), style: const TextStyle(fontSize: 11, color: Colors.grey));
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
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
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildHeader(bool isMobile) {
    final titleSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Smart Home Dashboard',
          style: TextStyle(fontSize: isMobile ? 20 : 24, fontWeight: FontWeight.bold),
        ),
        const Text('Bảng điều khiển quản trị', style: TextStyle(color: Colors.grey)),
      ],
    );

    final actionButtons = Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: isMobile ? WrapAlignment.start : WrapAlignment.end,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WebProfileScreen()),
            );
          },
          icon: const Icon(Icons.account_circle, color: Colors.black),
          label: Text(_userName, style: const TextStyle(color: Colors.black)),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            await AuthService.logout();
            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const WebLoginScreen()),
                (route) => false,
              );
            }
          },
          icon: const Icon(Icons.logout, color: Colors.black),
          label: const Text('Đăng xuất', style: TextStyle(color: Colors.black)),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
        ),
      ],
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleSection,
          const SizedBox(height: 12),
          actionButtons,
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        titleSection,
        actionButtons,
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
          _buildFanSpeedControl(
            'Quạt phòng ngủ',
            fanSpeed,
            (newSpeed) => setState(() => fanSpeed = newSpeed),
            (endSpeed) async {
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
          const SizedBox(height: 10),
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

  Widget _buildFanSpeedControl(String name, int speed, ValueChanged<int> onChanged, ValueChanged<double> onChangeEnd) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('$speed%', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          Slider(
            value: speed.toDouble(),
            min: 0,
            max: 100,
            divisions: 100,
            label: '$speed%',
            onChanged: (double newValue) {
              onChanged(newValue.round());
            },
            onChangeEnd: onChangeEnd,
            activeColor: Colors.green,
            inactiveColor: Colors.grey.shade300,
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