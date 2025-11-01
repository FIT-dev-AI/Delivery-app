import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_colors.dart';
import 'data/services/api_service.dart';
import 'data/services/auth_service.dart';
import 'data/services/order_service.dart';
import 'data/services/location_service.dart';
import 'data/services/stats_service.dart';
import 'data/services/admin_service.dart'; // ✅ NEW
import 'data/providers/auth_provider.dart';
import 'data/providers/order_provider.dart';
import 'data/providers/location_provider.dart';
import 'data/providers/stats_provider.dart';
import 'data/providers/admin_provider.dart'; // ✅ NEW
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/main_navigation_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

    // Initialize date formatting cho tiếng Việt
  await initializeDateFormatting('vi_VN', null);

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      // statusBarIconBrightness được quản lý bởi AppBarTheme
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize services
    final apiService = ApiService();
    final authService = AuthService(apiService);
    final orderService = OrderService(apiService);
    final statsService = StatsService(apiService);
    final adminService = AdminService(apiService); // ✅ NEW

    return MultiProvider(
      providers: [
        // Auth Provider
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService),
        ),

        // Order Provider
        ChangeNotifierProvider(
          create: (_) => OrderProvider(orderService),
        ),

        // Location Provider (UPDATED to use LocationService)
        ChangeNotifierProvider(
          create: (_) => LocationProvider(
            LocationService(apiService),
          ),
        ),

        // Stats Provider
        ChangeNotifierProvider(
          create: (_) => StatsProvider(statsService),
        ),

        // ✅ NEW: Admin Provider
        ChangeNotifierProvider(
          create: (_) => AdminProvider(adminService),
        ),
      ],
      child: MaterialApp(
        title: 'Delivery App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,

        // Localization
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('vi', 'VN'), // Vietnamese
          Locale('en', 'US'), // English (fallback)
        ],
        locale: const Locale('vi', 'VN'),

        // Initial route
        home: const SplashScreen(),
      ),
    );
  }
}

// Splash Screen - Kiểm tra đã đăng nhập chưa
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Dùng Future.microtask để đảm bảo có thể truy cập Provider sau khi build xong
    Future.microtask(() => _checkAuth());
  }

  // CẢI TIẾN LOGIC: Sử dụng AuthProvider để kiểm tra
  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2)); // Giữ màn hình chào mừng

    if (!mounted) return;

    // Yêu cầu AuthProvider tải thông tin người dùng từ storage
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.loadUserFromStorage();
      
    if (mounted) {
      if (authProvider.isAuthenticated) {
        // Đã đăng nhập, vào MainNavigationScreen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
      } else {
        // Chưa đăng nhập, vào LoginScreen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryOrange,
              secondaryOrange,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Hero(
                tag: 'app_logo',
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(51), // ✅ withAlpha instead of withOpacity
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.local_shipping_rounded,
                    size: 80,
                    color: primaryOrange,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // App name
              const Text(
                'Delivery App',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),

              const Text(
                'Quản lý giao hàng thông minh',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 48),

              // Loading indicator
              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}