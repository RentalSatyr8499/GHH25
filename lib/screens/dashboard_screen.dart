import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, double>? _summary;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final provider = Provider.of<AuthProvider>(context, listen: false);
      final summary = await provider.getSpendingHabits();
      setState(() {
        _summary = summary;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (_loading) {
      content = const CircularProgressIndicator();
    } else if (_error != null) {
      content = Text('Error: $_error');
    } else if (_summary == null || _summary!.isEmpty) {
      content = const Text('No spending data available');
    } else {
      content = Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _summary!.entries
              .map((e) => ListTile(
                    title: Text(e.key),
                    trailing: Text('\$${e.value.toStringAsFixed(2)}'),
                  ))
              .toList(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Center(child: content),
    );
  }
}
