import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const LiveStreamApp());
}

class LiveStreamApp extends StatelessWidget {
  const LiveStreamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Live Stream App',
      theme: ThemeData(primarySwatch: Colors.purple),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const StreamingScreen(),
    const WalletScreen(),
    const AdminSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.live_tv),
            label: 'Live',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wallet),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings),
            label: 'Admin',
          ),
        ],
      ),
    );
  }
}

class StreamingScreen extends StatelessWidget {
  const StreamingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Stream Room')),
      body: Stack(
        children: [
          Container(
            color: Colors.black,
            child: const Center(
              child: Text(
                '🔴 LIVE STREAMING VIDEO',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Gift Sent: 100 Coins!')),
                    );
                  },
                  icon: const Icon(Icons.card_giftcard, color: Colors.white),
                  label: const Text('Send Gift (100 Coins)', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int coins = 1500; // User Balance
  final int minWithdrawal = 3000;
  String adminNumber = "01401912576"; // Default Nagad Number

  @override
  void initState() {
    super.initState();
    _loadAdminNumber();
  }

  Future<void> _loadAdminNumber() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      adminNumber = prefs.getString('admin_nagad') ?? "01401912576";
    });
  }

  Future<void> _sendTelegramNotification(String message) async {
    final url = Uri.parse('https://t.me/Nxhiokgxsun?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _requestRecharge() {
    _sendTelegramNotification("Recharge Request: User wants to add balance. Nagad Number: $adminNumber");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recharge request sent via Telegram!')),
    );
  }

  void _requestWithdrawal() {
    if (coins < minWithdrawal) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Minimum withdrawal threshold is $minWithdrawal coins.')),
      );
    } else {
      _sendTelegramNotification("Withdrawal Request: User requested withdrawal for $coins coins to Nagad: $adminNumber");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Withdrawal request sent to Admin successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coin Wallet (1 BDT = 1 Coin)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text('Available Balance', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    const SizedBox(height: 10),
                    Text('$coins Coins', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.purple)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Payment Channel (Nagad): $adminNumber', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size.fromHeight(50)),
              onPressed: _requestRecharge,
              child: const Text('Recharge Coins (Manual Nagad)', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, minimumSize: const Size.fromHeight(50)),
              onPressed: _requestWithdrawal,
              child: Text('Withdraw Coins (Min: $minWithdrawal)', style: const TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final TextEditingController _numberController = TextEditingController();
  String currentNumber = "01401912576";

  @override
  void initState() {
    super.initState();
    _loadSavedNumber();
  }

  Future<void> _loadSavedNumber() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentNumber = prefs.getString('admin_nagad') ?? "01401912576";
      _numberController.text = currentNumber;
    });
  }

  Future<void> _saveAdminNumber() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('admin_nagad', _numberController.text);
    setState(() {
      currentNumber = _numberController.text;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Admin Nagad number updated dynamically!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dynamic Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Nagad Number: $currentNumber', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: _numberController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Update Nagad Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              onPressed: _saveAdminNumber,
              child: const Text('Save Number'),
            ),
          ],
        ),https://github.com/qwetyuioonbcxza-ops/live-stream-/commit/bea14549e3eac6438ab897128255d7d093589798
      ),
    );
  }
}https://github.com/qwetyuioonbcxza-ops/live-stream-/commit/bea14549e3eac6438ab897128255d7d093589798https://github.com/qwetyuioonbcxza-ops/live-stream-/commit/bea14549e3eac6438ab897128255d7d093589798https://github.com/qwetyuioonbcxza-ops/live-stream-/commit/bea14549e3eac6438ab897128255d7d093589798https://github.com/qwetyuioonbcxza-ops/live-stream-/commit/bea14549e3eac6438ab897128255d7d093589798https://github.com/qwetyuioonbcxza-ops/live-stream-/commit/bea14549e3eac6438ab897128255d7d093589798
