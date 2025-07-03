import 'package:flutter/material.dart';

class CustomToast {
  static void show(BuildContext context, String message, {Color? backgroundColor}) {
    final overlay = Overlay.of(context);
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final Color bgColor = (backgroundColor ?? Colors.black).withOpacity(0.85);

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: (keyboardHeight > 0) ? keyboardHeight + 20 : 80,
        left: 0,
        right: 0,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: IntrinsicWidth(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: backgroundColor?.withOpacity(0.5) ?? Colors.black.withOpacity(0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2)).then((_) => overlayEntry.remove());
  }
}