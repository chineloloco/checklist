import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/errors/app_failure.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/domain/auth_session.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/checklists/presentation/home_screen.dart';
import 'app_dependencies.dart';

class ChecklistApp extends StatefulWidget {
  const ChecklistApp({required this.dependencies, super.key});
  final AppDependencies dependencies;

  @override
  State<ChecklistApp> createState() => _ChecklistAppState();
}

class _ChecklistAppState extends State<ChecklistApp>
    with WidgetsBindingObserver {
  static const _activeUserKey = 'active_user_id_v1';

  bool _loading = true;
  AuthSession? _session;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_restore());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(widget.dependencies.dispose());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _session != null) {
      unawaited(widget.dependencies.syncCoordinator.syncNow());
    }
  }

  Future<void> _restore() async {
    final session = await widget.dependencies.auth.restore();
    if (!mounted) return;
    setState(() {
      _session = session;
      _loading = false;
    });
    if (session != null) {
      unawaited(_refreshAfterRestore());
    }
  }

  Future<void> _refreshAfterRestore() async {
    try {
      await widget.dependencies.syncCoordinator.bootstrap();
    } on Object {
      // Os dados locais continuam disponíveis quando o aparelho inicia offline.
    }
    await widget.dependencies.syncCoordinator.syncNow();
  }

  Future<void> _signIn(String employeeNumber, String password) async {
    setState(() => _error = null);
    try {
      final session = await widget.dependencies.auth.signIn(
        employeeNumber: employeeNumber,
        password: password,
      );
      final identity = await widget.dependencies.checklistApi.me();
      final userId = identity['userId']?.toString() ?? session.subject;
      final activeUser = await widget.dependencies.secureStorage.read(
        key: _activeUserKey,
      );
      if (activeUser != null && userId != null && activeUser != userId) {
        await widget.dependencies.auth.signOut();
        throw const AuthenticationFailure(
          'Este aparelho possui dados locais de outra conta. A troca segura de usuário precisa ser definida antes de continuar.',
        );
      }
      if (userId != null) {
        await widget.dependencies.secureStorage.write(
          key: _activeUserKey,
          value: userId,
        );
      }
      await widget.dependencies.syncCoordinator.bootstrap();
      if (!mounted) return;
      setState(() {
        _session = session;
        _error = null;
      });
      unawaited(widget.dependencies.syncCoordinator.syncNow());
    } on AppFailure catch (error) {
      await widget.dependencies.auth.signOut();
      if (mounted) setState(() => _error = error.message);
    } on Object catch (error) {
      await widget.dependencies.auth.signOut();
      if (mounted) setState(() => _error = 'Não foi possível entrar: $error');
    }
  }

  Future<void> _signOut() async {
    await widget.dependencies.auth.signOut();
    if (!mounted) return;
    setState(() {
      _session = null;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Checklists operacionais',
    theme: buildAppTheme(),
    builder: (context, child) =>
        SafeArea(top: false, child: child ?? const SizedBox.shrink()),
    locale: const Locale('pt', 'BR'),
    supportedLocales: const [Locale('pt', 'BR')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: _loading
        ? const _LaunchScreen()
        : _session == null
        ? LoginScreen(
            config: widget.dependencies.config,
            onSignIn: _signIn,
            error: _error,
          )
        : HomeScreen(
            dependencies: widget.dependencies,
            onSignOut: _signOut,
            initialWarning: _error,
          ),
  );
}

class _LaunchScreen extends StatelessWidget {
  const _LaunchScreen();

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.fact_check_outlined, size: 48, color: FieldColors.steel),
          SizedBox(height: 18),
          CircularProgressIndicator(),
          SizedBox(height: 12),
          Text('Abrindo dados salvos…'),
        ],
      ),
    ),
  );
}
