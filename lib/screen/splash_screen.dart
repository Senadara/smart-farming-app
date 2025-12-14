import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme/telkom_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/service/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:smart_farming_app/service/user_service.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  late AnimationController _controller;
  late Animation<double> _animation;
  bool _noInternet = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _animation = Tween<double>(begin: 0.9, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();

    // Mulai navigasi setelah animasi
    _navigateToNextScreen();
  }

  Future<bool> hasRealInternet() async {
    try {
      final response = await http
          .get(Uri.parse('https://www.google.com/generate_204'))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  Future<void> _navigateToNextScreen() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    // Cek status jaringan dulu
    await Future.delayed(const Duration(seconds: 2));
    if (connectivityResult
        .every((result) => result == ConnectivityResult.none)) {
      setState(() {
        _noInternet = true;
      });
      return;
    }

    // Cek benar-benar ada akses internet
    final realInternet = await hasRealInternet();
    if (!realInternet) {
      setState(() {
        _noInternet = true;
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    if (isFirstLaunch) {
      await prefs.setBool('isFirstLaunch', false);
      if (!mounted) return;
      context.go('/introduction');
      return;
    }

    final user = await _authService.getUser();
    final userData = await _userService.getUserById(user?['id'] ?? '');
    if (userData['isActive'] == false) {
      await _authService.logout();
      if (mounted) {
        showAppToast(
            context, 'Akun Anda telah dinonaktifkan. Silakan hubungi admin.');
      }
      context.go('/login');
      return;
    }

    // Cek validitas token
    final isRefreshTokenValid = await _authService.refreshToken();
    if (!isRefreshTokenValid) {
      await _authService.logout();
      if (!mounted) return;
      context.go('/login');
      return;
    }

    // Cek role pengguna dan arahkan ke halaman sesuai role
    final role = await _authService.getUserRole();
    if (!mounted) return;
    if (role == 'petugas') {
      context.go('/home-petugas');
    } else {
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TelkomColors.background,
      body: Stack(
        children: [
          // Logo selalu di tengah layar
          Center(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _animation.value,
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 150,
                    height: 150,
                  ),
                );
              },
            ),
          ),
          // Supported by section dengan 3 logo di bagian bawah
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Supported by',
                  style: bold16.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/t4g_logo.png',
                      width: 60,
                      height: 60,
                    ),
                    const SizedBox(width: 24),
                    Image.asset(
                      'assets/images/f4o_logo.png',
                      width: 60,
                      height: 60,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Pesan error di bawah logo, tetap di tengah layar
          if (_noInternet)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 180),
                child: Text(
                  'Ups! Tidak ada koneksi internet.\nSilakan periksa jaringan Anda dan coba lagi.',
                  key: const Key('no_internet_message'),
                  style: bold16.copyWith(color: TelkomColors.primary),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
