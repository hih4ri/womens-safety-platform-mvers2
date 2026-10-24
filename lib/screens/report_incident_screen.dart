// lib/screens/report_incident_screen.dart
import 'package:flutter/material.dart';
import '../app_theme.dart';

class ReportIncidentScreen extends StatefulWidget {
  const ReportIncidentScreen({super.key});

  @override
  State<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends State<ReportIncidentScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _incidentController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isLocating = false;
  bool _isSubmitting = false;

  final List<String> _quickCategories = [
    'Suspicious Activity',
    'Harassment',
    'Unsafe Lighting',
    'Medical Emergency',
    'Other'
  ];

  @override
  void dispose() {
    _incidentController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _fetchCurrentLocation() async {
    setState(() => _isLocating = true);
    // Simulate GPS fetch delay
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    setState(() {
      _locationController.text = "Current Location (GPS Auto-detected)";
      _isLocating = false;
    });
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    // Simulate API call for incident report submission
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Incident report submitted successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPurple,
                  size: 28,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 12),

              // MAIN CONTAINER
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.containerBg,
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.05),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Header Card
                        Container(
                          height: 160,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFF141927),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.06),
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Stack(
                              children: [
                                // Title Text
                                const Positioned(
                                  top: 20,
                                  left: 20,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Report',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.accentYellow,
                                          height: 1.1,
                                        ),
                                      ),
                                      Text(
                                        'INCIDENT',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.accentYellow,
                                          letterSpacing: 0.5,
                                          height: 1.1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Panther Graphic
                                Positioned(
                                  right: 12,
                                  bottom: 0,
                                  child: Image.asset(
                                    'assets/images/pantherbravelook.png',
                                    height: 135,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Form Inputs
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildLabel('Type of Incident'),
                                const SizedBox(height: 8),

                                // Quick Category Selection Chips
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  child: Row(
                                    children: _quickCategories.map((cat) {
                                      final isSelected = _incidentController.text == cat;
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: ChoiceChip(
                                          label: Text(
                                            cat,
                                            style: TextStyle(
                                              color: isSelected
                                                  ? AppColors.background
                                                  : AppColors.textPurple,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          selected: isSelected,
                                          selectedColor: AppColors.accentYellow,
                                          backgroundColor: const Color(0xFF141927),
                                          side: BorderSide(
                                            color: Colors.white.withOpacity(0.08),
                                          ),
                                          onSelected: (selected) {
                                            setState(() {
                                              _incidentController.text = selected ? cat : '';
                                            });
                                          },
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                const SizedBox(height: 10),

                                _buildFormField(
                                  controller: _incidentController,
                                  hintText: 'e.g., Suspicious activity, Harassment',
                                  textInputAction: TextInputAction.next,
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return 'Please specify the incident type';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                _buildLabel('Location'),
                                const SizedBox(height: 6),
                                _buildFormField(
                                  controller: _locationController,
                                  hintText: 'Enter location details',
                                  textInputAction: TextInputAction.next,
                                  suffixIcon: IconButton(
                                    icon: _isLocating
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppColors.accentYellow,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.my_location_rounded,
                                            color: AppColors.accentYellow,
                                            size: 20,
                                          ),
                                    onPressed: _isLocating ? null : _fetchCurrentLocation,
                                  ),
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return 'Please enter the incident location';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                _buildLabel('Description'),
                                const SizedBox(height: 6),
                                _buildFormField(
                                  controller: _descriptionController,
                                  hintText: 'Provide details about the incident...',
                                  maxLines: 4,
                                  textInputAction: TextInputAction.done,
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return 'Please provide a brief description';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        ),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF141927),
                              foregroundColor: AppColors.textPurple,
                              disabledBackgroundColor: const Color(0xFF141927).withOpacity(0.5),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: Colors.white.withOpacity(0.08),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: AppColors.textPurple,
                                    ),
                                  )
                                : const Text(
                                    'Submit Report',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPurple,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPER METHODS ---

  Widget _buildLabel(String labelText) {
    return Text(
      labelText,
      style: const TextStyle(
        fontSize: 13,
        color: AppColors.textPurple,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    String? hintText,
    int maxLines = 1,
    TextInputAction textInputAction = TextInputAction.next,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      textInputAction: textInputAction,
      style: const TextStyle(color: AppColors.textWhite),
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: AppColors.textPurple.withOpacity(0.4),
          fontSize: 14,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFF141927),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        errorStyle: const TextStyle(
          color: Colors.redAccent,
          fontSize: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.accentYellow,
            width: 1,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 1,
          ),
        ),
      ),
    );
  }
}