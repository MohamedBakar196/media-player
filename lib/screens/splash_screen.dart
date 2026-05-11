import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF08142A), Color(0xFF040B18)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 136,
              height: 136,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF2372FF), width: 3),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x662372FF),
                    blurRadius: 30,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.play_arrow_rounded,
                  size: 64,
                  color: Color(0xFF2372FF),
                ),
              ),
            ),
            const SizedBox(height: 28),
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 42, fontWeight: FontWeight.w700),
                children: <TextSpan>[
                  TextSpan(
                    text: 'ULTRA',
                    style: TextStyle(color: Colors.white),
                  ),
                  TextSpan(
                    text: 'REC',
                    style: TextStyle(color: Color(0xFF2875FF)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'STUDIO QUALITY CAPTURE',
              style: TextStyle(color: Color(0xFF8EA3C3), letterSpacing: 1.8),
            ),
          ],
        ),
      ),
    );
  }
}
