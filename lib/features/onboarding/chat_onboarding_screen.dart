import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gen_confi/app/routes/app_routes.dart';
import 'package:gen_confi/core/constants/app_colors.dart';
import 'package:gen_confi/core/storage/token_storage.dart';
import 'package:gen_confi/features/onboarding/widgets/chat_bubble.dart';
import 'package:gen_confi/features/smart_capture/smart_capture_screen.dart';
import 'package:gen_confi/services/auth_store.dart';
import 'package:gen_confi/services/onboarding_store.dart';

class ChatOnboardingScreen extends StatefulWidget {
  const ChatOnboardingScreen({super.key});

  @override
  State<ChatOnboardingScreen> createState() => _ChatOnboardingScreenState();
}

class _ChatOnboardingScreenState extends State<ChatOnboardingScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  int _currentStep = 0; // 0:Intro, 1:Gender, 2:Selfie, 3:Goal, 4:Style, 5:Fit, 6:Colors, 7:Done

  // Data Stores
  String? _selectedGender;
  String? _selectedGoal;
  final List<String> _selectedStyles = [];
  String? _selectedFit;
  final List<String> _selectedColors = [];

  @override
  void initState() {
    super.initState();
    _startConversation();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _addAiMessage(String text, {int delayMs = 1000}) async {
    setState(() => _isTyping = true);
    _scrollToBottom();
    await Future.delayed(Duration(milliseconds: delayMs));
    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(text: text, isUser: false));
      });
      _scrollToBottom();
    }
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
    });
    _scrollToBottom();
  }

  Future<void> _startConversation() async {
    await _addAiMessage("Hi there! I'm your Gen Confi AI Stylist. \u2728");
    await _addAiMessage("I'm here to build your personal style profile. It'll just take a minute.");
    await _addAiMessage("First things first, who am I styling today?");
    setState(() => _currentStep = 1); // Enable Gender Input
  }

  // --- Step Handlers ---

  Future<void> _handleGenderSelection(String gender) async {
    _selectedGender = gender;
    _addUserMessage(gender);
    setState(() => _currentStep = -1); // Loading...

    // Save to store
    String genderCode = gender == 'Men' ? 'Male' : (gender == 'Women' ? 'Female' : 'Kid');
    OnboardingStore().updateDraft(gender: genderCode);

    await _addAiMessage("Got it! $gender style is my specialty.");
    await _addAiMessage("To give you the best advice, I'd love to analyze your face shape and skin tone. \uD83D\uDCF8");
    await _addAiMessage("Mind taking a quick selfie? It's private and secure.");
    setState(() => _currentStep = 2); // Enable Selfie Input
  }

  Future<void> _handleSelfieCapture() async {
    // Navigate to Smart Capture
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SmartCaptureScreen()),
    );

    if (result != null && result is String) {
      _addUserMessage("📸 Selfie captured"); // Could show generic image icon
      setState(() => _currentStep = -1);
      
      await _addAiMessage("Analyzing...", delayMs: 1500);
      await _addAiMessage("Looking good! I see an Oval face shape and warm skin tones. \uD83D\uDE0E");
      await _addAiMessage("I can definitely work with this.");
      await _addAiMessage("What's your main goal right now?");
      setState(() => _currentStep = 3); // Enable Goal Input
    }
  }

  Future<void> _handleGoalSelection(String goal) async {
    _selectedGoal = goal;
    _addUserMessage(goal);
    setState(() => _currentStep = -1);
    
    OnboardingStore().updateDraft(skinGoal: goal);

    await _addAiMessage("Nice choice using '$goal'.");
    await _addAiMessage("Which of these styles vibes with you? (Pick as many as you like)");
    setState(() => _currentStep = 4); // Enable Style Input
  }

  Future<void> _handleStyleSubmission() async {
    if (_selectedStyles.isEmpty) return;
    String styleStr = _selectedStyles.join(", ");
    _addUserMessage(styleStr);
    setState(() => _currentStep = -1);
    
    final draft = OnboardingStore().draft;
    OnboardingStore().update(draft.copyWith(styleTags: _selectedStyles));

    await _addAiMessage("I love those styles! distinct and sharp.");
    await _addAiMessage("How do you like your clothes to fit?");
    setState(() => _currentStep = 5); // Enable Fit Input
  }

  Future<void> _handleFitSelection(String fit) async {
    _selectedFit = fit;
    _addUserMessage(fit);
    setState(() => _currentStep = -1);
    
    final draft = OnboardingStore().draft;
    OnboardingStore().update(draft.copyWith(fitPreference: fit));

    await _addAiMessage("Noted. $fit fit.");
    await _addAiMessage("Finally, any favorite colors you wear often?");
    setState(() => _currentStep = 6); // Enable Color Input
  }

  Future<void> _handleColorSubmission() async {
    if (_selectedColors.isEmpty && _selectedColors.isNotEmpty) return; // Allow empty? No, force at least one maybe? Let's say yes.
    String colorStr = _selectedColors.join(", ");
    if (_selectedColors.isEmpty) colorStr = "Surprise me";
    
    _addUserMessage(colorStr);
    setState(() => _currentStep = -1);

    final draft = OnboardingStore().draft;
    OnboardingStore().update(draft.copyWith(colorPrefs: _selectedColors));

    await _addAiMessage("Perfect! I have everything I need.");
    await _addAiMessage("Building your personalized profile now...");
    
    // Finalize - mark onboarding as complete
    AuthStore().markOnboardingCompleteForCurrentRole();
    await TokenStorage.markOnboardingComplete();
    
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
       Navigator.pushNamedAndRemoveUntil(context, AppRoutes.clientShell, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary,
              radius: 14,
              child: Icon(Icons.auto_awesome, size: 16, color: Colors.white),
            ),
            SizedBox(width: 8),
            Text("AI Stylist", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false, // No back button effectively, typical for onboarding start
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              controller: _scrollController,
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return const ChatBubble(message: "", isTyping: true);
                }
                final msg = _messages[index];
                return ChatBubble(message: msg.text, isUser: msg.isUser);
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _getInputForStep(),
        ),
      ),
    );
  }

  Widget _getInputForStep() {
    switch (_currentStep) {
      case 1: // Gender
        return _buildOptionsGrid([
          _OptionItem("Men", Icons.man),
          _OptionItem("Women", Icons.woman),
          _OptionItem("Kids", Icons.child_care),
        ], (val) => _handleGenderSelection(val));
      
      case 2: // Selfie
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _handleSelfieCapture,
            icon: const Icon(Icons.camera_alt),
            label: const Text("Take Selfie"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        );

      case 3: // Goal
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              "Everyday clean", "Professional", "Glow-up", "Wedding", "Low maintenance"
            ].map((g) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                label: Text(g),
                onPressed: () => _handleGoalSelection(g),
                backgroundColor: Colors.white,
                shape: const StadiumBorder(side: BorderSide(color: AppColors.border)),
              ),
            )).toList(),
          ),
        );

      case 4: // Style (Multi)
        return Column(
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ["Casual", "Minimal", "Street", "Formal", "Sporty", "Classic"].map((s) {
                final isSelected = _selectedStyles.contains(s);
                return FilterChip(
                  label: Text(s),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) _selectedStyles.add(s);
                      else _selectedStyles.remove(s);
                    });
                  },
                  checkmarkColor: Colors.white,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            if (_selectedStyles.isNotEmpty)
              ElevatedButton(
                onPressed: _handleStyleSubmission,
                child: const Text("Done"),
              )
          ],
        );

      case 5: // Fit
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ["Slim", "Regular", "Relaxed"].map((f) => ActionChip(
             label: Text(f),
             onPressed: () => _handleFitSelection(f),
          )).toList(),
        );

      case 6: // Colors (Multi)
        final colors = {
          "Black": Colors.black, "White": Colors.grey[200]!, "Blue": Colors.blue, "Red": Colors.red, "Beige": Colors.amber[100]!
        };
        return Column(
          children: [
            Wrap(
              spacing: 12,
              children: colors.entries.map((e) {
                 final isSelected = _selectedColors.contains(e.key);
                 return GestureDetector(
                   onTap: () {
                     setState(() {
                       if (isSelected) _selectedColors.remove(e.key);
                       else _selectedColors.add(e.key);
                     });
                   },
                   child: Container(
                     width: 40,
                     height: 40,
                     decoration: BoxDecoration(
                       color: e.value,
                       shape: BoxShape.circle,
                       border: Border.all(color: isSelected ? AppColors.primary : Colors.grey[300]!, width: isSelected ? 3 : 1),
                       boxShadow: [if(isSelected) const BoxShadow(color: Colors.black12, blurRadius: 4)]
                     ),
                     child: isSelected ? const Icon(Icons.check, size: 20, color: AppColors.primary) : null,
                   ),
                 );
              }).toList(),
            ),
            const SizedBox(height: 12),
             ElevatedButton(
                onPressed: _handleColorSubmission,
                child: const Text("Finish Profile"),
              )
          ],
        );
      
      default:
        return const SizedBox(height: 50, child: Center(child: Text("...", style: TextStyle(color: Colors.grey))));
    }
  }

  Widget _buildOptionsGrid(List<_OptionItem> options, Function(String) onSelect) {
    return Row(
      children: options.map((opt) => Expanded(
        child: GestureDetector(
          onTap: () => onSelect(opt.label),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(opt.icon, color: AppColors.primary),
                const SizedBox(height: 8),
                Text(opt.label, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      )).toList(),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class _OptionItem {
  final String label;
  final IconData icon;
  _OptionItem(this.label, this.icon);
}
