import 'package:forever_fusion/controllers/auth_service.dart';
import 'package:forever_fusion/firebase_options.dart';
import 'package:forever_fusion/providers/cart_provider.dart';
import 'package:forever_fusion/providers/user_provider.dart';
import 'package:forever_fusion/views/cart_page.dart';
import 'package:forever_fusion/views/checkout_page.dart';
import 'package:forever_fusion/views/discount_page.dart';
import 'package:forever_fusion/views/home_nav.dart';
import 'package:forever_fusion/views/login.dart';
import 'package:forever_fusion/views/orders_page.dart';
import 'package:forever_fusion/views/signup.dart';
import 'package:forever_fusion/views/specific_products.dart';
import 'package:forever_fusion/views/update_profile.dart';
import 'package:forever_fusion/views/view_product.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Load environment variables
  await dotenv.load(fileName: "assets/.env");

  // Configure Stripe
  Stripe.publishableKey = dotenv.env["STRIPE_PUBLISH_KEY"] ?? "";
  Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
  Stripe.urlScheme = 'flutterstripe';
  await Stripe.instance.applySettings();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'ForeverFusion',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        routes: {
          "/": (context) => const CheckUser(),
          "/login": (context) => const LoginPage(),
          "/home": (context) => const HomeNav(),
          "/signup": (context) => const SignupPage(),
          "/update_profile": (context) => const UpdateProfile(),
          "/discount": (context) => const DiscountPage(),
          "/specific": (context) => const SpecificProducts(),
          "/view_product": (context) => const ViewProduct(),
          "/cart": (context) => const CartPage(),
          "/checkout": (context) => const CheckoutPage(),
          "/orders": (context) => const OrdersPage(),
        },
      ),
    );
  }
}

class CheckUser extends StatefulWidget {
  const CheckUser({super.key});

  @override
  State<CheckUser> createState() => _CheckUserState();
}

class _CheckUserState extends State<CheckUser> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    bool isLoggedIn = await AuthService().isLoggedIn();
    if (mounted) {
      Navigator.pushReplacementNamed(context, isLoggedIn ? "/home" : "/login");
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}