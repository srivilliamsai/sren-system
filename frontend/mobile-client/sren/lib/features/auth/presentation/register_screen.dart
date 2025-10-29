import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../routing/app_router.dart';
import '../../../widgets/primary_button.dart';
import '../state/register_controller.dart';
import 'auth_validators.dart';

class RegisterScreen extends HookConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController();
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final formKey = useMemoized(GlobalKey<FormState>.new);

    final registerState = ref.watch(registerControllerProvider);
    final controller = ref.read(registerControllerProvider.notifier);

    ref.listen<AsyncValue<String?>>(
      registerControllerProvider,
      (_, state) {
        state.whenOrNull(
          data: (id) {
            if (id != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account created successfully.'),
                ),
              );
              context.goNamed(AppRoute.login.name);
            }
          },
          error: (error, _) {
            final message =
                error is String ? error : 'Registration failed. Try again.';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          },
        );
      },
    );

    final isLoading = registerState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Full name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: validateName,
                ),
                const SizedBox(height: 16),
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
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: validatePassword,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Confirm password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) {
                    if (value != passwordController.text) {
                      return 'Passwords must match.';
                    }
                    return validatePassword(value);
                  },
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: isLoading ? 'Creating…' : 'Create account',
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (formKey.currentState?.validate() ?? false) {
                            await controller.register(
                              name: nameController.text.trim(),
                              email: emailController.text.trim(),
                              password: passwordController.text,
                            );
                          }
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
