import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'core/router/router.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/repository/auth_repository.dart';
import 'features/auth/repository/mock_auth_repository.dart';
import 'features/transactions/bloc/transaction_bloc.dart';
import 'features/transactions/repository/transaction_repository.dart';
import 'features/transactions/repository/mock_transaction_repository.dart';
import 'features/cards/bloc/card_bloc.dart';
import 'features/cards/repository/card_repository.dart';
import 'features/cards/repository/mock_card_repository.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Firebase ─────────────────────────────────────────────
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (_) {
    // Already initialized on hot restart
  }

  // ── Stripe ───────────────────────────────────────────────
  Stripe.publishableKey = KlyraConstants.stripePublishableKey;
  Stripe.merchantIdentifier = 'merchant.app.klyra';
  await Stripe.instance.applySettings();

  // ── System UI ────────────────────────────────────────────
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const KlyraApp());
}

class KlyraApp extends StatefulWidget {
  const KlyraApp({super.key});
  @override State<KlyraApp> createState() => _KlyraAppState();
}

class _KlyraAppState extends State<KlyraApp> {
  late final AuthRepository      _authRepo;
  late final TransactionRepository _txRepo;
  late final CardRepository      _cardRepo;
  late final AuthBloc            _authBloc;
  late final TransactionBloc     _txBloc;
  late final CardBloc            _cardBloc;
  late final GoRouterRefreshStream _routerRefresh;
  late final GoRouter            _router;

  @override
  void initState() {
    super.initState();
    _authRepo  = MockAuthRepository();
    _txRepo    = MockTransactionRepository();
    _cardRepo  = MockCardRepository();

    _authBloc = AuthBloc(
      authRepository: _authRepo,
      localAuth: LocalAuthentication(),
      secureStorage: const FlutterSecureStorage(),
    )..add(const AuthStarted());

    _txBloc   = TransactionBloc(repository: _txRepo);
    _cardBloc = CardBloc(repository: _cardRepo);

    _routerRefresh = GoRouterRefreshStream(_authBloc.stream);
    _router = createRouter(_authBloc, _routerRefresh);

    // Reset other blocs when user logs out so stale data is cleared.
    _authBloc.stream.listen((state) {
      if (state is AuthUnauthenticated) {
        _txBloc.add(const TransactionReset());
        _cardBloc.add(const CardReset());
      }
    });
  }

  @override
  void dispose() {
    _routerRefresh.dispose();
    _authBloc.close();
    _txBloc.close();
    _cardBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _authRepo),
        RepositoryProvider.value(value: _txRepo),
        RepositoryProvider.value(value: _cardRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _authBloc),
          BlocProvider.value(value: _txBloc),
          BlocProvider.value(value: _cardBloc),
        ],
        child: MaterialApp.router(
          title: KlyraConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: KlyraTheme.light,
          routerConfig: _router,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.noScaling),
            child: child!,
          ),
        ),
      ),
    );
  }
}
