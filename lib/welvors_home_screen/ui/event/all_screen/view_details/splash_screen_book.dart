import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';

import 'booking_confirm.dart'; // Ensure correct import for booking_confirm.dart

class SplashScreenBook extends StatefulWidget {
  final double totalPayable;
  final String title;
  final String date;
  final String location;
  
  const SplashScreenBook({
    Key? key,
    required this.totalPayable,
    this.title = '',
    this.date = '',
    this.location = '',
  }) : super(key: key);

  @override
  State<SplashScreenBook> createState() => _SplashScreenBookState();
}

class _SplashScreenBookState extends State<SplashScreenBook> {
  int _currentStep = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startProgress();
  }

  void _startProgress() {
    // Step 1: Contacting your bank
    _timer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _currentStep = 1);
      
      // Step 2: Authorising amount
      _timer = Timer(const Duration(milliseconds: 1500), () {
        if (mounted) setState(() => _currentStep = 2);
        
        // Step 3: Reserving your spot
        _timer = Timer(const Duration(milliseconds: 1500), () {
          if (mounted) setState(() => _currentStep = 3);
          
          // Step 4: Navigate to confirmation screen
          _timer = Timer(const Duration(milliseconds: 1000), () {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => BookingConfirmationScreen(
                    title: widget.title,
                    date: widget.date,
                    location: widget.location,
                  ),
                ),
              );
            }
          });
        });
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _buildChecklistItem(String text, bool isVisible) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: isVisible ? 1.0 : 0.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50), // Green check color
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 14,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lottie Animation (Ticket)
              SizedBox(
                width: 150,
                height: 150,
                child: Lottie.asset(
                  'assets/Ticket.json',
                  fit: BoxFit.contain,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Title
              const Text(
                'Processing payment...',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Subtitle
              Text(
                "Please don't close or go back. This takes a few seconds.",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Checklist
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildChecklistItem(
                    'Contacting your bank',
                    _currentStep >= 1,
                  ),
                  _buildChecklistItem(
                    'Authorising ₹${widget.totalPayable.toStringAsFixed(0)}',
                    _currentStep >= 2,
                  ),
                  _buildChecklistItem(
                    'Reserving your spot',
                    _currentStep >= 3,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
