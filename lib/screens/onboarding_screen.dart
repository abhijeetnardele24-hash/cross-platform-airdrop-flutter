import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  final VoidCallback onGetStarted;
  const OnboardingScreen({super.key, required this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_tethering, size: 80, color: Theme.of(context).primaryColor),
              const SizedBox(height: 32),
              Text(
                'Welcome to AirDrop Pro!',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Share files seamlessly across all your devices',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: onGetStarted,
                child: const Text('Get Started'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
