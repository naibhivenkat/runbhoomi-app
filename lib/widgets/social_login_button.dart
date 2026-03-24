import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {

  final IconData icon;
  final String text;
  final VoidCallback onPressed;

  const SocialLoginButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      height: 50,

      child: OutlinedButton.icon(

        icon: Icon(icon),

        label: Text(text),

        onPressed: onPressed,

      ),
    );

  }

}