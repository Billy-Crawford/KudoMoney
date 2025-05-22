// lib/screens/dashboardTogo_screen.dart

import 'package:flutter/material.dart';
import '../widgets/transaction_card.dart';

class DashboardTogoScreen extends StatefulWidget {
  final String username;
  final String balance;

  const DashboardTogoScreen({
    Key? key,
    required this.username,
    required this.balance,
  }) : super(key: key);

  @override
  State<DashboardTogoScreen> createState() => _DashboardTogoScreenState();
}

class _DashboardTogoScreenState extends State<DashboardTogoScreen> {
  bool _isBalanceVisible = true;
  late double _balance;

  @override
  void initState() {
    super.initState();
    _balance = double.tryParse(widget.balance) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(), // Menu latéral à personnaliser plus tard
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.apps, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.notifications_none, color: Colors.black),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Tableau de bord",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              "Bienvenue, ${widget.username}",
              style: const TextStyle(
                fontSize: 20,
                fontFamily: 'DancingScript',
              ),
            ),
            const SizedBox(height: 20),
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(left: 100),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "Solde",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isBalanceVisible = !_isBalanceVisible;
                              });
                            },
                            child: Icon(
                              _isBalanceVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _isBalanceVisible
                            ? "${_balance.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ' ')} XAF"
                            : "********",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end, // 👈 placé à droite
                        children: const [
                          Column(
                            children: [
                              Icon(Icons.download),
                              SizedBox(height: 4),
                              Text("Retirer de\nl'argent",
                                  textAlign: TextAlign.center),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  bottom: 0,
                  top: 0,
                  child: Image.asset(
                    'assets/pointing_man.png',
                    width: 140,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              "Transactions réussies",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // ✅ Première transaction réussie
            TransactionCard(
              beneficiary: "JoeCobra",
              amount: "300,000,000",
              dateTime: "13-11-25/13:10",
              status: "Succès",
            ),
            const SizedBox(height: 10),

            // ✅ Deuxième transaction réussie
            TransactionCard(
              beneficiary: "AnnaKossi",
              amount: "1,200,000",
              dateTime: "13-11-26/10:45",
              status: "Succès",
            ),
          ],
        ),
      ),
    );
  }
}
