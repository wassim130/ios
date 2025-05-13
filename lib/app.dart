import 'package:ahmini/screens/entreprise/job_detail.dart';
import 'package:ahmini/screens/freelancer_portfolio/creationportefolio.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:ahmini/screens/translations/messages.dart';
import 'package:ahmini/services/local_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/theme_controller.dart';
import 'screens/confidentialite/changemdp/changermdp.dart';
import 'screens/confidentialite/confidentialite.dart';
import 'screens/confidentialite/connected_devices/connected_devices.dart';
import 'screens/confidentialite/login_history/login_history.dart';
import 'screens/entreprise/create_entreprise.dart';
import 'screens/entreprise/entreprise.dart';
import 'screens/faq/faq.dart';
import 'screens/language/language.dart';
import 'screens/mainScreen/main_screen.dart';
import 'screens/contract/contract.dart';
import 'screens/notifactions/notification_settings.dart';
import 'screens/profile/edit_profile/edit_profile.dart';
import 'screens/messages/chats/chats.dart';
import 'screens/messages/chat_page/chat_page.dart';
import 'screens/notifactions/notification_details.dart';
import 'screens/register/documentverificationpage.dart';
import 'screens/statistic/main_screen.dart';
import 'screens/statistic/constants.dart';
import 'screens/subscription/home.dart';
import 'screens/login/login.dart';
import 'screens/register/register.dart';
import 'screens/entreprise/entreprise.dart';
import 'screens/freelancer_portfolio/freelancer_portfolio.dart';
import 'screens/freelancer_portfolio/creationportefolio.dart';
import 'screens/freelancer_portfolio/freelancer_portfolio.dart';
import 'screens/dashboard/dashboard.dart';
import 'screens/theme/theme.dart';
import 'theme.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<Uri?>? _sub;
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  void initState() {
    super.initState();
    _initDeepLinkListener();
  }

  void _initDeepLinkListener() {
    // _sub = uriLinkStream.listen((Uri? link) {
    // if (link != null) {
    // Uri uri = link;
    // if (uri.host == "open") {
    // Navigator.pushNamed(context, "/");
    // }
    // }
    // });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: myTheme,
      darkTheme: myDarkTheme,
      themeMode: themeController.isDarkMode.value
          ? ThemeMode.dark
          : ThemeMode.light,
      translations: Messages(),
      locale: Get.deviceLocale, // Will be overridden in initServices
      fallbackLocale: const Locale('fr', 'FR'),
      onGenerateRoute: _routes(),
      onInit: () async {
        await initServices();
      },
    ));
  }

  Future<void> initServices() async {
    // Initialize locale service
    final localeService = Get.put(LocaleService());
    // Load saved locale
    final savedLocale = await localeService.getLocale();
    Get.updateLocale(savedLocale);
  }

  RouteFactory _routes() {
    final Map<String, (Widget? Function(Map<String, dynamic>?), String?)>
    routes = {
      '/': (
          (args) {
        return MainScreen(
            key: GlobalKey<MainScreenState>(), user: args?['user']);
      },
      'instant'
      ),
      '/messages/home': ((args) => ChatsPage(), 'slideFromRight'),

      '/messages/conversation': (
          (args) {
        if (args == null ||
            !args.containsKey('conversationID'.tr) ||
            !args.containsKey('otherUsername'.tr) ||
            !args.containsKey('imageURL'.tr)) {
          return null;
        }
        return ChatPage(
          args['conversationID'],
          otherUsername: args['otherUsername'],
          imageURL: args['imageURL'],
        );
      },
      'push'
      ),
      '/notifications/': ((args) => NotificationsPage(), 'push'.tr),
      NotificationSettingsPage.routeName: (
          (args) => NotificationSettingsPage(),
      'push'
      ),
      // '/profile/home': ((args) => ProfileScreen(), 'push'),
      '/profile/edit': ((args) => ProfileEditScreen(), 'push'),
      '/profile/statistics': ((args) => StatisticsPage(), 'push'),
      '/profile/subscriptions/': ((args) => SubscriptionScreen(), 'push'),
      '/contract/': ((args) => ContractsPage(), 'push'),
      '/confidentialite': ((args) => SecurityPrivacyScreen(), 'push'),
      '/confidentialite/changemdp': ((args) => PasswordChangeScreen(), 'push'),
      '/confidentialite/connected_devices': (
          (args) => ConnectedDevicesPage(),
      'push'
      ),
      '/subscription': ((args) => SubscriptionScreen(), 'push'),
      '/faq': ((args) => FaqAndHelpScreen(), 'push'),
      '/language': ((args) => LanguageScreen(), 'push'),
      '/portefolioedit': (
          (args) {
        bool isFirstLogin = args?['isFirstLogin'] ?? false;
        return PortfolioOnboardingPage(isFirstLogin: isFirstLogin);
      },
      'push'
      ),
      '/freelancer_portfolio': (
          (args) {
        int? id = args?['portfolioID'];
        return MPortfolioPage(id: id);
      },
      'push'
      ),
      '/entreprise/home': (
          (args) {
        if (args == null || !args.containsKey('companyID')) {
          return EnterprisePage();
        }
        return EnterprisePage(companyID: args['companyID']);
      },
      'push'
      ),
      '/entreprise/create': (
          (args) {
        bool isFirstLogin = args?['isFirstLogin'] ?? false;
        return EntrepriseCreatePage(isFirstLogin: isFirstLogin);
      },
      'push'
      ),
      '/login': ((args) => LoginPage(), 'push'),
      '/inscription': ((args) => RegisterPage(), 'push'),
      // '/portefolioedit': ((args) => MPortfolioPage(), 'push'),
      '/confidentialite/login_history': ((args) => LoginHistoryPage(), 'push'),
      '/dashboard': ((args) => DashboardPage(), 'push'),
      '/theme': ((args) => ThemeSettingsPage(), 'push'),
      '/document-verification': (
          (args) {
        if (args == null || !args.containsKey('user')) return null;
        return DocumentVerificationPage(user: args['user']);
      },
      'push'
      ),
      '/job-detail': (
          (args) {
        if (args == null || !args.containsKey('job') || !args.containsKey('companyID')) {
          return null;
        }
        return JobDetailPage(
          job: args['job'],
          companyID: args['companyID'],
        );
      },
      'push'
      ),
    };

    return (RouteSettings settings) {
      final Map<String, dynamic>? arguments =
      settings.arguments as Map<String, dynamic>?;

      final tuple = routes[settings.name];
      if (tuple == null) return null;

      final screen = tuple.$1(arguments);
      if (screen == null) return null;
      final animationType = tuple.$2;

      return animationType == 'push' || animationType == null
          ? MaterialPageRoute(builder: (context) {
        return screen;
      })
          : PageRouteBuilder(
        settings: settings,
        transitionDuration: Duration(milliseconds: 250),
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) {
          return _buildPageTransition(animation, child, animationType);
        },
      );
    };
  }

  Widget _buildPageTransition(
      Animation<double> animation, Widget child, String animationType) {
    switch (animationType) {
      case 'fade':
        return FadeTransition(opacity: animation, child: child);
      case 'scale':
        return ScaleTransition(scale: animation, child: child);
      case 'slideFromLeft':
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      case 'slideFromBottom':
        return SlideTransition(
          position: Tween<Offset>(begin: Offset(0, 1), end: Offset.zero)
              .animate(animation),
          child: child,
        );
      case 'slideFromRight':
        return SlideTransition(
          position: Tween<Offset>(begin: Offset(1, 0), end: Offset.zero)
              .animate(animation),
          child: child,
        );
      case 'slideFromTop':
        return SlideTransition(
          position: Tween<Offset>(begin: Offset(0, -1), end: Offset.zero)
              .animate(animation),
          child: child,
        );
      default:
        return child;
    }
  }
}
