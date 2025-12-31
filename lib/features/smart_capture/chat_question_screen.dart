import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/onboarding_store.dart';
import '../../services/auth_store.dart';
import '../../core/constants/app_colors.dart';
import 'analyzing_features_screen.dart';

class ChatQuestionScreen extends StatefulWidget {
  final String imagePath;

  const ChatQuestionScreen({
    Key? key,
    required this.imagePath,
  }) : super(key: key);

  @override
  State<ChatQuestionScreen> createState() => _ChatQuestionScreenState();
}

class _ChatQuestionScreenState extends State<ChatQuestionScreen> {
  final ScrollController _scrollController = ScrollController();
  int _currentQuestionIndex = 0;
  String? _userName;
  
  // Chat messages history
  final List<ChatMessage> _chatMessages = [];

  // Question data structure
  final List<QuestionData> _questions = [
    QuestionData(
      question: "How would you describe your daily routine?",
      options: [
        "Mostly indoors",
        "Office / Corporate",
        "College / Student",
        "Outdoor / Field work",
        "Very active lifestyle",
      ],
      isMultiSelect: false,
      key: 'dailyRoutine',
    ),
    QuestionData(
      question: "How much effort do you prefer for hair styling?",
      options: [
        "Low maintenance (quick & simple)",
        "Medium (a few times a week)",
        "High (daily styling is okay)",
      ],
      isMultiSelect: false,
      key: 'stylingPreference',
    ),
    QuestionData(
      question: "What occasions do you usually style for?",
      options: [
        "Everyday / Office",
        "College",
        "Weddings & functions",
        "Festivals / traditional wear",
        "Dates & social outings",
        "Interviews / professional meetings",
      ],
      isMultiSelect: true,
      key: 'occasions',
    ),
    QuestionData(
      question: "Are you facing any hair or scalp concerns?",
      options: [
        "Hair fall",
        "Dandruff",
        "Thinning hair",
        "Dry scalp",
        "Oily scalp",
        "Frizzy hair",
        "None",
      ],
      isMultiSelect: true,
      key: 'concerns',
      showIcons: true,
    ),
    QuestionData(
      question: "What kind of style do you usually like?",
      options: [
        "Clean & professional",
        "Trendy / modern",
        "Natural / minimal",
        "Bold & experimental",
        "Traditional",
      ],
      isMultiSelect: true,
      key: 'personalStyle',
    ),
  ];

  // Store answers
  final Map<String, dynamic> _answers = {};

  @override
  void initState() {
    super.initState();
    _userName = _getUserName();
    _initializeAnswers();
    _initializeChat();
  }
  
  void _initializeChat() {
    // Add welcome message
    _chatMessages.add(ChatMessage(
      text: _userName != null
          ? "Hi $_userName! 👋\n\nI'd love to learn a bit more about you to personalize your style recommendations."
          : "Hi there! 👋\n\nI'd love to learn a bit more about you to personalize your style recommendations.",
      isUser: false,
    ));
    
    // Add first question
    _addQuestionToChat(0);
  }
  
  void _addQuestionToChat(int questionIndex) {
    if (questionIndex < _questions.length) {
      final question = _questions[questionIndex];
      _chatMessages.add(ChatMessage(
        text: _userName != null
            ? "$_userName, ${question.question}"
            : question.question,
        isUser: false,
      ));
      _scrollToBottom();
    }
  }
  
  void _addUserAnswerToChat(int questionIndex) {
    if (questionIndex < _questions.length) {
      final question = _questions[questionIndex];
      final answer = _answers[question.key];
      
      String answerText;
      if (question.isMultiSelect) {
        final selectedSet = answer as Set<String>;
        if (selectedSet.isEmpty) {
          answerText = "Skip";
        } else {
          answerText = selectedSet.join(", ");
        }
      } else {
        answerText = answer ?? "Skip";
      }
      
      _chatMessages.add(ChatMessage(
        text: answerText,
        isUser: true,
      ));
      _scrollToBottom();
    }
  }

  void _initializeAnswers() {
    for (var question in _questions) {
      if (question.isMultiSelect) {
        _answers[question.key] = <String>{};
      } else {
        _answers[question.key] = null;
      }
    }
  }

  String? _getUserName() {
    final authStore = AuthStore();
    final userEmail = authStore.userEmail;
    
    if (userEmail != null && userEmail.isNotEmpty) {
      final name = userEmail.split('@')[0];
      if (name.isNotEmpty) {
        return name[0].toUpperCase() + (name.length > 1 ? name.substring(1) : '');
      }
    }
    return null;
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

  void _handleOptionSelect(String option, QuestionData question) {
    setState(() {
      if (question.isMultiSelect) {
        final selectedSet = _answers[question.key] as Set<String>;
        if (question.key == 'concerns' && option == "None") {
          selectedSet.clear();
          selectedSet.add("None");
        } else if (question.key == 'concerns') {
          // Remove "None" if any other option is selected
          selectedSet.remove("None");
          if (selectedSet.contains(option)) {
            selectedSet.remove(option);
          } else {
            selectedSet.add(option);
          }
        } else {
          // Regular multi-select behavior
          if (selectedSet.contains(option)) {
            selectedSet.remove(option);
          } else {
            selectedSet.add(option);
          }
        }
      } else {
        _answers[question.key] = option;
      }
    });
  }

  void _handleNext() {
    // Add current answer to chat
    _addUserAnswerToChat(_currentQuestionIndex);
    
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _addQuestionToChat(_currentQuestionIndex);
      });
    } else {
      _handleComplete();
    }
  }

  void _handleSkip() {
    // Add skip message to chat
    _addUserAnswerToChat(_currentQuestionIndex);
    
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _addQuestionToChat(_currentQuestionIndex);
      });
    } else {
      _handleComplete();
    }
  }

  void _handleComplete() {
    // Save preferences to OnboardingStore
    final store = OnboardingStore();
    
    // Combine all preferences into styleTags
    final allStyleTags = <String>[];
    if (_answers['dailyRoutine'] != null) {
      allStyleTags.add(_answers['dailyRoutine']);
    }
    if (_answers['stylingPreference'] != null) {
      allStyleTags.add(_answers['stylingPreference']);
    }
    if (_answers['occasions'] != null) {
      allStyleTags.addAll(_answers['occasions'] as Set<String>);
    }
    if (_answers['personalStyle'] != null) {
      allStyleTags.addAll(_answers['personalStyle'] as Set<String>);
    }
    
    // Update draft with style tags and concerns
    final currentDraft = store.draft;
    store.update(
      currentDraft.copyWith(
        styleTags: allStyleTags,
        groomingConcerns: (_answers['concerns'] as Set<String>?)?.toList() ?? [],
      ),
    );

    // Navigate to analyzing features screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => AnalyzingFeaturesScreen(
          imagePath: widget.imagePath,
        ),
      ),
    ).then((result) {
      // When analysis completes, return to previous screen with image path
      if (result != null && mounted) {
        Navigator.pop(context, result);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          // Premium Background Aura
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gradientStart.withOpacity(isDark ? 0.15 : 0.1),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -150,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gradientEnd.withOpacity(isDark ? 0.1 : 0.08),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: colorScheme.onSurface,
                          size: 18,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 28,
                          minHeight: 28,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      // Progress indicator
                      Text(
                        "${_currentQuestionIndex + 1}/${_questions.length}",
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMutedLight,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),

                // Chat Messages Area - Scrollable
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    itemCount: _chatMessages.length,
                    itemBuilder: (context, index) {
                      final message = _chatMessages[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: message.isUser
                            ? _buildUserMessage(message.text, isDark: isDark, colorScheme: colorScheme)
                            : _buildAiMessage(message.text, isDark: isDark, colorScheme: colorScheme),
                      );
                    },
                  ),
                ),

                // Options and Actions
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Options
                      _buildOptions(
                        question: currentQuestion,
                        isDark: isDark,
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(height: 12),
                      
                      // Action Buttons
                      Row(
                        children: [
                          // Skip Button
                          Expanded(
                            child: TextButton(
                              onPressed: _handleSkip,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Skip',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.textMutedDark
                                      : AppColors.textMutedLight,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          
                          // Next/Continue Button
                          Expanded(
                            flex: 2,
                            child: _canProceed(currentQuestion)
                                ? Container(
                                    height: 44,
                                    decoration: BoxDecoration(
                                      gradient: AppColors.primaryGradient,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.gradientStart
                                              .withOpacity(isDark ? 0.2 : 0.15),
                                          blurRadius: 12,
                                          offset: const Offset(0, 6),
                                        )
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: _handleNext,
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: Text(
                                            _currentQuestionIndex < _questions.length - 1
                                                ? 'NEXT'
                                                : 'CONTINUE',
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 1.5,
                                              color: Colors.white,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppColors.surfaceDark
                                          : AppColors.surfaceLight,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isDark
                                            ? AppColors.borderDark
                                            : AppColors.borderLight,
                                        width: 1,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      _currentQuestionIndex < _questions.length - 1
                                          ? 'NEXT'
                                          : 'CONTINUE',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.5,
                                        color: isDark
                                            ? AppColors.textMutedDark
                                            : AppColors.textMutedLight,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed(QuestionData question) {
    if (question.isMultiSelect) {
      final selected = _answers[question.key] as Set<String>;
      return selected.isNotEmpty;
    } else {
      return _answers[question.key] != null;
    }
  }

  Widget _buildAiMessage(String text, {required bool isDark, required ColorScheme colorScheme}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AI Avatar
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.smart_toy_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        // Message Bubble
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 1,
              ),
            ),
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
                height: 1.4,
              ),
            ),
          ),
        ),
        const SizedBox(width: 48), // Space for user messages alignment
      ],
    );
  }

  Widget _buildUserMessage(String text, {required bool isDark, required ColorScheme colorScheme}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const SizedBox(width: 48), // Space for AI messages alignment
        // Message Bubble
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(4),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                height: 1.4,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // User Avatar
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 1,
            ),
          ),
          child: Icon(
            Icons.person_rounded,
            color: colorScheme.onSurface,
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildOptions({
    required QuestionData question,
    required bool isDark,
    required ColorScheme colorScheme,
  }) {
    final selected = _answers[question.key];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: question.options.map((option) {
        final isSelected = question.isMultiSelect
            ? (selected as Set<String>).contains(option)
            : (selected as String?) == option;

        return InkWell(
          onTap: () => _handleOptionSelect(option, question),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.gradientStart
                  : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? AppColors.gradientStart
                    : (isDark ? AppColors.borderDark : AppColors.borderLight),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (question.showIcons) ...[
                  Icon(
                    _getIconForConcern(option),
                    size: 16,
                    color: isSelected
                        ? Colors.white
                        : (isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight),
                  ),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    option,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : colorScheme.onSurface,
                    ),
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Colors.white,
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _getIconForConcern(String concern) {
    switch (concern.toLowerCase()) {
      case 'hair fall':
        return Icons.water_drop_outlined;
      case 'dandruff':
        return Icons.medical_services_outlined;
      case 'thinning hair':
        return Icons.visibility_outlined;
      case 'dry scalp':
        return Icons.wb_sunny_outlined;
      case 'oily scalp':
        return Icons.opacity_outlined;
      case 'frizzy hair':
        return Icons.waves_outlined;
      case 'none':
        return Icons.check_circle_outline;
      default:
        return Icons.info_outline;
    }
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({
    required this.text,
    required this.isUser,
  });
}

class QuestionData {
  final String question;
  final List<String> options;
  final bool isMultiSelect;
  final String key;
  final bool showIcons;

  QuestionData({
    required this.question,
    required this.options,
    required this.isMultiSelect,
    required this.key,
    this.showIcons = false,
  });
}

