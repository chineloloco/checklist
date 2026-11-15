import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    required this.config,
    required this.onSignIn,
    this.error,
    super.key,
  });

  final AppConfig config;
  final Future<void> Function() onSignIn;
  final String? error;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;

  Future<void> _signIn() async {
    setState(() => _loading = true);
    try {
      await widget.onSignIn();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: FieldColors.steel,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.fact_check_outlined,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Inspeção pronta para o campo.',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Entre com internet para baixar seus veículos e modelos. Depois, o preenchimento continua mesmo sem sinal.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: FieldColors.notApplicable,
                          ),
                    ),
                    const SizedBox(height: 28),
                    if (!widget.config.hasApi || !widget.config.hasOidc)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: FieldColors.amberSoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.settings_outlined,
                                color: Color(0xFF805000)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Configuração pendente: ${widget.config.missingSettings.join(', ')}.',
                                style: const TextStyle(color: Color(0xFF664000)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (widget.error != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: FieldColors.nonCompliantSoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: FieldColors.nonCompliant),
                            const SizedBox(width: 10),
                            Expanded(child: Text(widget.error!)),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: _loading || !widget.config.hasOidc ? null : _signIn,
                      icon: _loading
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.login),
                      label: Text(_loading ? 'Entrando…' : 'Entrar com identidade corporativa'),
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lock_outline, size: 18, color: FieldColors.steel),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'O aplicativo nunca recebe credenciais do Neon. Tokens ficam no armazenamento seguro do aparelho.',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
