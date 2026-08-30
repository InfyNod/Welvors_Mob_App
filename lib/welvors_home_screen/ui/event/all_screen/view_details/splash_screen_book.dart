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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      transform: Matrix4.translationValues(0, isVisible ? 0 : 15, 0),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 500),
        opacity: isVisible ? 1.0 : 0.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isVisible ? const Color(0xFFE43A6A) : Colors.grey.shade300,
                  shape: BoxShape.circle,
                  boxShadow: isVisible 
                      ? [BoxShadow(color: const Color(0xFFE43A6A).withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))]
                      : null,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isVisible ? Colors.black87 : Colors.grey.shade500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF0F5), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Glowing Lottie Animation
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE43A6A).withOpacity(0.2),
                            blurRadius: 50,
                            spreadRadius: 30,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 190,
                      height: 190,
                      child: Lottie.asset('assets/Ticket.json', fit: BoxFit.contain),
                    ),
                  ],
                ),

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
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),

              const SizedBox(height: 48),

              // Premium Checklist Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: const Color(0xFFE43A6A).withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFFE43A6A).withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Column(
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
                    _buildChecklistItem('Reserving your spot', _currentStep >= 3),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}
