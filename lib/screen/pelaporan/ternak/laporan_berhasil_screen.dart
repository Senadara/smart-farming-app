import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/service/auth_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/button.dart';

class LaporanBerhasilScreen extends StatefulWidget {
  final String? title;
  final String? message;

  const LaporanBerhasilScreen({
    super.key,
    this.title,
    this.message
  });

  @override
  State<LaporanBerhasilScreen> createState() => _LaporanBerhasilScreenState();
}

class _LaporanBerhasilScreenState extends State<LaporanBerhasilScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  int _countdown = 3;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() => _countdown--);
      } else {
        _timer?.cancel();
        _redirectToDashboard();
      }
    });
  }

  Future<void> _redirectToDashboard() async {
    if (mounted) {
      final role = await AuthService().getUserRole();
      if (mounted) {
        if (role == 'petugas') {
          context.go('/home-petugas');
        } else {
          context.go('/home');
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Success Animation Area
              ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                  opacity: _opacityAnimation,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: green1.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: green1,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: green1.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Success Text
              FadeTransition(
                opacity: _opacityAnimation,
                child: Column(
                  children: [
                    Text(
                      widget.title ?? 'Laporan Berhasil!',
                      style: bold20.copyWith(color: dark1, fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.message ?? 'Laporan ternak sakit telah berhasil disimpan ke sistem.',
                      style: regular16.copyWith(color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Redirect Info
              Text(
                'Mengalihkan ke beranda dalam $_countdown detik...',
                style: regular14.copyWith(color: Colors.grey.shade400),
              ),
              const SizedBox(height: 24),
              // Manual Button
              CustomButton(
                onPressed: _redirectToDashboard,
                buttonText: 'Kembali ke Beranda',
                backgroundColor: green1,
                textStyle: semibold16.copyWith(color: white),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
