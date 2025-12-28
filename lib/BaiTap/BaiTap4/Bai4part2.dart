import 'dart:async';

import 'package:flutter/material.dart';

class CountdownTimerScreen extends StatefulWidget {
  const CountdownTimerScreen({super.key});

  @override
  State<CountdownTimerScreen> createState() => _CountdownTimerScreenState();
}

class _CountdownTimerScreenState extends State<CountdownTimerScreen> {
  final TextEditingController _secondsController = TextEditingController();
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  String? _message;

  @override
  void dispose() {
    _timer?.cancel();
    _secondsController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    final rawInput = _secondsController.text.trim();
    final seconds = int.tryParse(rawInput);
    if (seconds == null || seconds <= 0) {
      setState(() {
        _message = 'Vui lòng nhập số giây hợp lệ.';
      });
      return;
    }

    _timer?.cancel();
    setState(() {
      _remainingSeconds = seconds;
      _isRunning = true;
      _message = null;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remainingSeconds = 0;
          _isRunning = false;
          _message = '⏰ Hết thời gian!';
        });
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  void _stopCountdown() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetCountdown() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = 0;
      _isRunning = false;
      _message = null;
      _secondsController.clear();
    });
  }

  String get _formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bộ đếm thời gian'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Nhập số giây cần đếm:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            TextField(
              controller: _secondsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ví dụ: 10',
              ),
              enabled: !_isRunning,
            ),
            const SizedBox(height: 24),
            Text(
              _formattedTime,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isRunning ? null : _startCountdown,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Bắt đầu'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isRunning ? _stopCountdown : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Dừng'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _resetCountdown,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade700,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Làm lại'),
                ),
              ],
            ),
            if (_message != null) ...[
              const SizedBox(height: 24),
              Text(
                _message!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}