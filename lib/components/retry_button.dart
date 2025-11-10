import 'package:flutter/material.dart';

class RetryButton extends StatelessWidget {
  final void Function() onRetryPressed;

  const RetryButton({super.key, required this.onRetryPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final locale = S.of(context);

    return FilledButton.tonalIcon(
      style: theme.filledButtonTheme.style,
      icon: const Icon(
        Icons.refresh_outlined,
        color: Colors.white,
      ),
      label: Text(
        "Retry",
        style: const TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
      ),
      onPressed: onRetryPressed,
    );
  }
}
