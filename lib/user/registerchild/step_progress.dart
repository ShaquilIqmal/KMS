import 'package:flutter/material.dart';

class CustomStepIndicator extends StatelessWidget {
  final int currentStep; // Current active step (0-based index)
  final List<String> stepLabels; // List of step labels

  CustomStepIndicator({
    super.key,
    required this.currentStep,
    required this.stepLabels,
  });

  // Define a list of colors for completed steps
  final List<LinearGradient> stepGradients = [
    const LinearGradient(
      colors: [Colors.green, Colors.lightGreen],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    const LinearGradient(
      colors: [Colors.blue, Colors.lightBlue],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    const LinearGradient(
      colors: [Colors.purple, Colors.purpleAccent],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    const LinearGradient(
      colors: [Colors.red, Colors.orange],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    const LinearGradient(
      colors: [Colors.teal, Colors.greenAccent],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ];

  Widget _buildStepDot(int stepIndex) {
    Color dotColor = Colors.grey[400]!; // Default color for uncompleted steps
    Icon? stepIcon;

    if (currentStep == stepIndex) {
      dotColor = Colors.grey[800]!; // Color for the current step
    } else if (currentStep > stepIndex) {
      return Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: stepGradients[stepIndex % stepGradients.length],
        ),
        child: const Center(
          child: Icon(Icons.check, color: Colors.white, size: 18),
        ),
      );
    }

    return CircleAvatar(
      radius: 15,
      backgroundColor: dotColor,
      child: stepIcon ??
          Text(
            '${stepIndex + 1}',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
    );
  }

  Widget _buildStepText(int stepIndex, String text) {
    Color textColor;

    if (currentStep == stepIndex) {
      textColor = Colors.grey[700]!; // Color for the current step label
    } else if (currentStep > stepIndex) {
      // For completed steps, use the same colors as step dots
      textColor = stepGradients[stepIndex % stepGradients.length].colors.first;
    } else {
      textColor = Colors.grey; // Default color for uncompleted steps
    }

    return Text(
      text,
      style: TextStyle(
          fontWeight: FontWeight.bold, color: textColor, fontSize: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(stepLabels.length, (stepIndex) {
        return Column(
          children: [
            _buildStepDot(stepIndex),
            const SizedBox(height: 8.0),
            _buildStepText(stepIndex, stepLabels[stepIndex]),
          ],
        );
      }),
    );
  }
}
