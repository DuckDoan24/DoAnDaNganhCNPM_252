import 'package:flutter/material.dart';
import 'package:frontend/screens/web_profile_screen.dart';

class WebDashboardScreen extends StatefulWidget {
  const WebDashboardScreen({super.key});

  @override
  State<WebDashboardScreen> createState() => _WebDashboardScreenState();
}

class _WebDashboardScreenState extends State<WebDashboardScreen> {
  // --- 1. STATE VARIABLES ---
  
  // Sensor Data
  String temperature = "--";
  String humidity = "--";
  String smokeStatus = "--";
  
  // Device States
  bool lightOn = true;
  bool fanOn = true;
  bool acOn = false;
  bool dehumOn = false;
  
  // The selected color for the light (starts green based on your design)
  Color selectedLightColor = Colors.green;

  // Alerts and Logs (Empty by default as requested)
  List<dynamic> recentAlerts = []; 
  List<dynamic> systemLogs = [];

  // Threshold Settings
  final _tempLowCtrl = TextEditingController(text: '15');
  final _tempHighCtrl = TextEditingController(text: '35');
  final _humLowCtrl = TextEditingController(text: '30');
  final _humHighCtrl = TextEditingController(text: '80');

  @override
  void initState() {
    super.initState();
    // Fetch all initial data when the dashboard loads
    _fetchAllDashboardData();
  }

  // --- 2. BACKEND API PLACEHOLDERS ---

  void _fetchAllDashboardData() {
    _fetchSensorData();
    _fetchDeviceStates();
    _fetchAlerts();
    _fetchLogs();
  }

  Future<void> _fetchSensorData() async {
    // TODO: Add your GET request here for sensors
    // final response = await http.get(Uri.parse('$baseUrl/sensors'));
    // setState(() { temperature = ... });
  }

  Future<void> _fetchDeviceStates() async {
    // TODO: Add your GET request here for device status
  }

  Future<void> _fetchAlerts() async {
    // TODO: Add your GET request here for "Cảnh báo gần đây"
    // Leave empty for now, so recentAlerts remains []
  }

  Future<void> _fetchLogs() async {
    // TODO: Add your GET request here for "Nhật ký hệ thống"
    // Leave empty for now, so systemLogs remains []
  }

  // --- 3. COLOR PICKER LOGIC ---

  void _showColorPickerDialog() {
    // The 6 colors from your provided image
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
                  // TODO: Add a POST/PUT request here to tell backend the color changed
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

  // --- 4. UI BUILDER ---

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
                Expanded(child: _buildSensorCard('Nhiệt độ', '$temperature°C', 'Cập nhật: ...', Colors.green)),
                const SizedBox(width: 20),
                Expanded(child: _buildSensorCard('Độ ẩm', '$humidity%', 'Cập nhật: ...', Colors.green)),
                const SizedBox(width: 20),
                Expanded(child: _buildSensorCard('Cảm biến khói', smokeStatus, 'Không phát hiện khói', Colors.green)),
              ],
            ),
            const SizedBox(height: 20),

            // Middle Row: Chart & Devices
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 1, child: _buildPanel('Biểu đồ nhiệt độ', Container(height: 250))),
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
          child: const Text(/*TODO: Display user's name */"Thanh", textAlign: TextAlign.right),
        ),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () { 
                /* Logout logic */
                //TODO: Implement logout functionality (e.g., clear tokens, navigate to login screen)
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
          _buildDeviceSwitch('Đèn phòng khách', lightOn, (val) => setState(() => lightOn = val), hasColorPicker: true),
          const SizedBox(height: 10),
          _buildDeviceSwitch('Quạt phòng ngủ', fanOn, (val) => setState(() => fanOn = val)),
          const SizedBox(height: 10),
          _buildDeviceSwitch('Máy lạnh', acOn, (val) => setState(() => acOn = val)),
          const SizedBox(height: 10),
          _buildDeviceSwitch('Máy hút ẩm', dehumOn, (val) => setState(() => dehumOn = val)),
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
              // TODO: Add POST request to backend to flip the switch
            },
            activeThumbColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsPanel() {
    return _buildPanel(
      'Cảnh báo gần đây',
      recentAlerts.isEmpty 
          ? const Center(child: Text("Không có cảnh báo nào.", style: TextStyle(color: Colors.grey)))
          : Column(children: recentAlerts.map((e) => Text(e.toString())).toList()), // Will populate when API is written
    );
  }

  Widget _buildLogsPanel() {
    return _buildPanel(
      'Nhật ký hệ thống',
      systemLogs.isEmpty 
          ? const Center(child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("Chưa có nhật ký hệ thống.", style: TextStyle(color: Colors.grey)),
            ))
          : Column(children: systemLogs.map((e) => Text(e.toString())).toList()), // Will populate when API is written
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