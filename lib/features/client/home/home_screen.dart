import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gen_confi/app/routes/app_routes.dart';
import 'package:gen_confi/core/providers/auth_provider.dart';
import 'package:gen_confi/core/constants/api_constants.dart';

class ClientHomeScreen extends ConsumerStatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  ConsumerState<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends ConsumerState<ClientHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.shade400,
              Colors.purple.shade600,
              Colors.pink.shade400,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _buildWelcomeCard(),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'What would you like to do?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(child: _buildQuickActions()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: Colors.white,
        foregroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add),
        label: const Text('New Request'),
      ),
    );
  }

  Widget _buildAppBar() {
    final user = ref.watch(currentUserProvider);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Gen Confi',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.clientProfile),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: ClipOval(child: _buildAvatarImage(context, user)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarImage(BuildContext context, user) {
    if (user?.avatarUrl != null) {
      final url = user!.avatarUrl!;
      if (url.startsWith('http')) {
        return Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholderIcon(),
        );
      } else {
        // Assume local relative path from backend
        final fullUrl =
            "${ApiConstants.baseUrl.replaceAll('/api/v1', '')}/api/v1/$url";
        return Image.network(
          fullUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholderIcon(),
        );
      }
    }
    return _buildPlaceholderIcon();
  }

  Widget _buildPlaceholderIcon() {
    return const Icon(Icons.person_rounded, size: 24, color: Colors.white);
  }

  Widget _buildWelcomeCard() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepPurple.shade400,
                          Colors.purple.shade600,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.waving_hand,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome Back!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Text(
                          'Ready to manage your projects?',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildStatItem('Active', '12', Icons.pending_actions),
                  _buildStatItem('Completed', '47', Icons.check_circle),
                  _buildStatItem('Pending', '5', Icons.hourglass_empty),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.deepPurple, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      childAspectRatio: 1.1,
      children: [
        _buildActionCard(
          'Grooming',
          Icons.spa_rounded,
          const Color(0xFF0D9488), // Teal
          () => Navigator.pushNamed(context, AppRoutes.clientGroomingAnalysis),
        ),
        _buildActionCard(
          'New Project',
          Icons.folder_open_rounded,
          Colors.orange,
          () {},
        ),
        _buildActionCard(
          'Messages',
          Icons.chat_bubble_outline_rounded,
          Colors.blue,
          () {},
        ),
        _buildActionCard(
          'Documents',
          Icons.description_outlined,
          Colors.green,
          () {},
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
