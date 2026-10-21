import 'package:chitieu/api/investment/investment_provider.dart';
import 'package:chitieu/api/investment/investment_service.dart';
import 'package:chitieu/api/transaction/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

// --- Voice ---
import 'package:chitieu/core/voice/voice_synonym_store.dart';

// --- Auth ---
import 'package:chitieu/auth/auth_provider.dart';
import 'package:chitieu/auth/auth_service.dart';

// --- Settings ---
import 'pages/setting/settings_provider.dart';

// --- Pages ---
import 'pages/budgets_page.dart';
import 'pages/analytics_page.dart';
import 'pages/setting/setting_page.dart';
import 'pages/setting/money_settings_page.dart';
import 'pages/note_page.dart';

// --- Roommate & Quỹ phòng (TrọPay) ---
import 'package:chitieu/roommate/roommate_provider.dart';
import 'package:chitieu/pages/roommate_page.dart';

// --- i18n ---
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:chitieu/l10n/app_localizations.dart';

// --- BankAccount ---
import 'api/bankaccount/bank_account_service.dart';
import 'api/bankaccount/bank_account_provider.dart';
import 'package:chitieu/pages/accounts_page.dart';

// --- Money ---
import 'core/money/money_settings_provider.dart';
import 'core/money/money_settings_service.dart';

// --- Budgets ---
import 'core/budget/budget_service.dart';
import 'core/budget/budgets_provider.dart';

// --- Category ---
import 'api/category/category_provider.dart';

// --- Transactions (Mới) ---
import 'api/in_invoice/in_invoice_service.dart';
import 'api/in_invoice/in_invoice_provider.dart';
import 'api/out_invoice/out_invoice_service.dart';
import 'api/out_invoice/out_invoice_provider.dart';
import 'api/bank_transaction/bank_transaction_service.dart';
import 'api/bank_transaction/bank_transaction_provider.dart';
import 'pages/transactions_page.dart';

// --- Date ---
import 'core/date/year_month_provider.dart';

// --- Income ---
import 'api/income/income_service.dart';
import 'api/income/income_provider.dart';

import 'api/saving/saving_service.dart';
import 'api/saving/saving_provider.dart';

import 'api/saving_transaction/saving_transaction_service.dart';
import 'api/saving_transaction/saving_transaction_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Tải dữ liệu học giọng nói sớm trước khi app chạy
  final voiceStore = VoiceSynonymStore();
  await voiceStore.load();
  print('✅ VoiceSynonymStore loaded at startup');

  const rawBase = String.fromEnvironment(
    'API_BASE',
    defaultValue: 'http://192.168.1.68:8000',
  );

  final authApi = AuthService(rawBase);

  final dio = Dio(BaseOptions(
    baseUrl: '$rawBase/',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Accept': 'application/json'},
    validateStatus: (s) => s != null && s < 500,
  ));

  // Thêm token vào mọi request
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      var p = options.path;
      if (!p.startsWith('http')) {
        if (p.startsWith('/')) p = p.substring(1);
        if (!p.startsWith('api/')) p = 'api/$p';
        options.path = p;
      }

      final token = await authApi.getToken();
      if (token != null && token.isNotEmpty && token != 'null') {
        options.headers['Authorization'] = 'Bearer $token';
      } else {
        options.headers.remove('Authorization');
      }
      handler.next(options);
    },
  ));

  final moneyProv = MoneySettingsProvider(MoneySettingsService());
  await moneyProv.init();

  final roommateProv = RoommateProvider();
  await roommateProv.init();

  runApp(
    MultiProvider(
      providers: [
        Provider<Dio>(create: (_) => dio),
        ChangeNotifierProvider(create: (_) => YearMonthProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider<MoneySettingsProvider>.value(value: moneyProv),
        ChangeNotifierProvider<RoommateProvider>.value(value: roommateProv),
        ChangeNotifierProvider(create: (_) => AuthProvider(authApi)),

        // ===== BankAccount =====
        ChangeNotifierProxyProvider<AuthProvider, BankAccountProvider>(
          create: (context) {
            final auth = context.read<AuthProvider>();
            final dioLocal = Dio(BaseOptions(
                baseUrl: '$rawBase/', headers: {'Accept': 'application/json'}));
            dioLocal.interceptors.add(InterceptorsWrapper(
              onRequest: (options, handler) async {
                final token = auth.token;
                if (token != null && token.isNotEmpty && token != 'null') {
                  options.headers['Authorization'] = 'Bearer $token';
                } else {
                  options.headers.remove('Authorization');
                }
                handler.next(options);
              },
            ));
            return BankAccountProvider(service: BankAccountService(dioLocal));
          },
          update: (context, auth, prev) {
            final dioLocal = Dio(BaseOptions(
                baseUrl: '$rawBase/', headers: {'Accept': 'application/json'}));
            dioLocal.interceptors.add(InterceptorsWrapper(
              onRequest: (options, handler) async {
                final token = auth.token;
                if (token != null && token.isNotEmpty && token != 'null') {
                  options.headers['Authorization'] = 'Bearer $token';
                } else {
                  options.headers.remove('Authorization');
                }
                handler.next(options);
              },
            ));
            final service = BankAccountService(dioLocal);
            final provider = prev ?? BankAccountProvider(service: service);
            provider.updateService(service);

            if (auth.isAuthenticated) {
              provider.fetchAccounts(token: auth.token);
            } else {
              provider.clear();
            }
            return provider;
          },
        ),

        // ===== Category =====
        ChangeNotifierProxyProvider<AuthProvider, CategoryProvider>(
          create: (ctx) =>
              CategoryProvider(ctx.read<Dio>(), ctx.read<AuthProvider>()),
          update: (ctx, auth, prev) {
            final p = prev ?? CategoryProvider(ctx.read<Dio>(), auth);
            if ((auth.token ?? '').isEmpty) {
              p.clear();
            } else if (p.items.isEmpty && !p.loading) {
              p.refresh();
            }
            return p;
          },
        ),

        // ===== Budgets =====
        ChangeNotifierProxyProvider<AuthProvider, BudgetsProvider>(
          create: (context) {
            final auth = context.read<AuthProvider>();
            final dioInstance = context.read<Dio>();
            return BudgetsProvider(BudgetService(dioInstance, auth));
          },
          update: (context, auth, prev) {
            final dioInstance = context.read<Dio>();
            final provider =
                prev ?? BudgetsProvider(BudgetService(dioInstance, auth));

            if ((auth.token ?? '').isEmpty) {
              provider.clear();
            } else {
              final ym = context.read<YearMonthProvider>().ym;
              if (provider.items.isEmpty && !provider.loading) {
                provider.loadForMonth(year: ym.year, month: ym.month);
              }
            }
            return provider;
          },
        ),

        // ===== Income =====
        ChangeNotifierProxyProvider<AuthProvider, IncomeProvider>(
          create: (context) =>
              IncomeProvider(IncomeService(dio), context.read<AuthProvider>()),
          update: (context, auth, prev) {
            final p = prev ?? IncomeProvider(IncomeService(dio), auth);
            final token = auth.token ?? '';
            final ym = context.read<YearMonthProvider>().ym;

            if (token.isEmpty) {
              p.clear();
            } else if (!p.loading) {
              p.fetch(year: ym.year, month: ym.month);
            }
            return p;
          },
        ),

        ChangeNotifierProvider(
          create: (ctx) => InInvoiceProvider(
            api: InInvoiceService(dio),
            bankAccounts: ctx.read<BankAccountProvider>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => OutInvoiceProvider(
            api: OutInvoiceService(dio),
            bankAccounts: ctx.read<BankAccountProvider>(),
            budgets: ctx.read<BudgetsProvider>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => BankTransactionProvider(
            api: BankTransactionService(dio),
            bankAccounts: ctx.read<BankAccountProvider>(),
          ),
        ),

        ChangeNotifierProvider(
          create: (context) => TransactionProvider(
            context.read<Dio>(),
            context.read<AuthProvider>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => SavingProvider(
            api: SavingService(ctx.read<Dio>()),
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => SavingTransactionProvider(
            api: SavingTransactionService(ctx.read<Dio>()),
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => InvestmentProvider(
            api: InvestmentService(ctx.read<Dio>()),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('vi'), Locale('en')],
      locale: settings.locale,
      themeMode: settings.themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: settings.seed,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardTheme(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: settings.seed,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),
      title: 'TrọPay',
      home: const HomeScaffold(),
      routes: {
        '/roommate': (_) => const RoommatePage(),
        '/settings/money': (_) => const MoneySettingsPage(),
        '/transactions': (_) => const TransactionsPage(),
      },
    );
  }
}

class HomeScaffold extends StatefulWidget {
  const HomeScaffold({super.key});
  @override
  State<HomeScaffold> createState() => _HomeScaffoldState();
}

class _HomeScaffoldState extends State<HomeScaffold> {
  int _currentIndex = 0;
  final List<Widget> _pages = const [
    RoommatePage(),
    BudgetsPage(),
    AccountsPage(),
    AnalyticsPage(),
    SettingsPage(),
  ];

  void _onTabSelected(int index) => setState(() => _currentIndex = index);
  void _onFabPressed() => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => const NotePage()));

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final appScaffold = Scaffold(
      extendBody: false,
      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: _pages),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onFabPressed,
        elevation: 4,
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        tooltip: 'Ghi chép AI & Giọng nói',
        child: const Icon(Icons.mic_rounded, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          currentIndex: _currentIndex,
          onTap: _onTabSelected,
          selectedItemColor: const Color(0xFF2563EB),
          unselectedItemColor: Colors.black45,
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.apartment_rounded),
              label: t.tabRoommate,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.wallet_rounded),
              label: t.tabBudgets,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.account_balance_rounded),
              label: t.tabAccounts,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.insights_rounded),
              label: t.tabAnalytics,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_rounded),
              label: t.tabSettings,
            ),
          ],
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= 540) {
          return appScaffold;
        }

        // Trên màn hình máy tính / web rộng: hiển thị khung mô phỏng điện thoại tinh tế
        return Scaffold(
          backgroundColor: const Color(0xFF0F172A),
          body: Center(
            child: Container(
              width: 440,
              height: constraints.maxHeight.clamp(640, 920),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(36),
                border: Border.all(color: const Color(0xFF334155), width: 6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 36,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: appScaffold,
            ),
          ),
        );
      },
    );
  }
}
