import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'dashboard_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AuthProvider>(context);
    final user = provider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              provider.logout();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          )
        ],
      ),
      body: Center(
        child: user == null
            ? const Text('No user data')
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Welcome, ${user['first_name'] ?? user['name'] ?? 'User'}!', style: const TextStyle(fontSize: 20)),
                    const SizedBox(height: 12),
                    if (user['address'] != null) ...[
                      Text('Address: ${user['address']['street_number'] ?? ''} ${user['address']['street_name'] ?? ''}'),
                      const SizedBox(height: 8),
                    ],
                    Text('Customer id: ${user['id'] ?? 'N/A'}'),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.bar_chart),
                      label: const Text('View Dashboard'),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DashboardScreen()));
                      },
                    )
                  ],
                ),
              ),
      ),
    );
  }
}

