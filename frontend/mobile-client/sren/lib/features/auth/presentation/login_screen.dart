import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../routing/app_router.dart';
import '../../../widgets/error_view.dart';
import '../../../widgets/primary_button.dart';
import '../state/auth_controller.dart';
import 'auth_validators.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final formKey = useMemoized(GlobalKey<FormState>.new);

    final authState = ref.watch(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);

    useEffect(() {
      if (authState.hasError) {
        final message = authState.error is String
            ? authState.error as String
            : 'We could not sign you in.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
      return null;
    }, [authState.hasError]);

    final current = authState.valueOrNull;
    final isLoading = current?.isLoading ?? authState.isLoading;
    final errorMessage = current?.errorMessage;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              Text(
                'Welcome to SREN',
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Text(
                'Capture your mood, get curated recommendations, and stay in control of your emotional journey.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ErrorView(
                    title: 'Sign-in failed',
                    message: errorMessage,
                  ),
                ),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.alternate_email),
                      ),
                      validator: validateEmail,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: validatePassword,
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      text: isLoading ? 'Signing in…' : 'Sign In',
                      onPressed: isLoading
                          ? null
                          : () async {
                              if (formKey.currentState?.validate() ?? false) {
                                await controller.login(
                                  email: emailController.text.trim(),
                                  password: passwordController.text,
                                );
                              }
                            },
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => context.goNamed(AppRoute.register.name),
                      child: const Text('Create an account'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
