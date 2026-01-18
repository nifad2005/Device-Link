import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'features/onboarding/screens/welcome_screen.dart';
import 'features/desktop/screens/desktop_hub_screen.dart';
import 'services/connection_service.dart';
import 'services/platform_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final connectionService = ConnectionService();
  await connectionService.init();

  runApp(const DeviceLinkerApp());
}

class DeviceLinkerApp extends StatelessWidget {
  const DeviceLinkerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Device Linker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      // If we are on desktop, show the Desktop Hub.
      // If we are on mobile, show the Welcome Screen.
      home: PlatformService.isDesktop 
          ? const DesktopHubScreen() 
          : const WelcomeScreen(),
    );
  }
}
