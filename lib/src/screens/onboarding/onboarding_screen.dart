import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'onboarding_view_model.dart';

class OnboardingPage extends ConsumerWidget {
  Future<void> onGetStarted(BuildContext context, WidgetRef ref) async {
    final onboardingViewModel = ref.read(onboardingViewModelProvider.notifier);
    await onboardingViewModel.completeOnboarding();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Track your time.\nBecause time counts.',
              style: Theme.of(context).textTheme.headline4,
              textAlign: TextAlign.center,
            ),
            ElevatedButton(
              onPressed: () => onGetStarted(context, ref),
              child: Text(
                'Get Started',
                style: Theme.of(context)
                    .textTheme
                    .headline5!
                    .copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}