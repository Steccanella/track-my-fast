import 'package:flutter/material.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  int _selectedCategoryIndex = 0;

  final List<String> _categories = [
    'Getting Started',
    'Science',
    'Tips & Tricks',
    'Meal Planning',
    'Common Questions',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios),
                    iconSize: 24,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Learn & Grow',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Category Tabs
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final isSelected = index == _selectedCategoryIndex;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategoryIndex = index;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey[300]!,
                        ),
                      ),
                      child: Text(
                        _categories[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Content
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedCategoryIndex) {
      case 0:
        return _buildGettingStartedContent();
      case 1:
        return _buildScienceContent();
      case 2:
        return _buildTipsContent();
      case 3:
        return _buildMealPlanningContent();
      case 4:
        return _buildFAQContent();
      default:
        return _buildGettingStartedContent();
    }
  }

  Widget _buildGettingStartedContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Welcome Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.emoji_emotions,
                      color: Colors.white,
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Welcome to Fasting!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Intermittent fasting is a simple, effective way to improve your health and achieve your wellness goals. Let\'s start your journey!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Quick Start Guide
          _buildArticleCard(
            'Quick Start Guide',
            'Everything you need to know to begin your first fast',
            '5 min read',
            Icons.play_circle_outline,
            Colors.blue,
            false,
            () => _showQuickStartDialog(),
          ),

          const SizedBox(height: 16),

          _buildArticleCard(
            'Choosing Your First Fast',
            'Find the perfect fasting schedule for your lifestyle',
            '7 min read',
            Icons.schedule,
            Colors.green,
            false,
          ),

          const SizedBox(height: 16),

          _buildArticleCard(
            'What to Expect',
            'Timeline of benefits and potential challenges',
            '10 min read',
            Icons.timeline,
            Colors.orange,
            false, // Made free
          ),

          const SizedBox(height: 16),

          _buildArticleCard(
            'Tracking Your Progress',
            'How to measure success beyond the scale',
            '6 min read',
            Icons.trending_up,
            Colors.purple,
            false, // Made free
          ),
        ],
      ),
    );
  }

  Widget _buildScienceContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildArticleCard(
            'The Science of Autophagy',
            'How fasting helps your cells clean and repair themselves',
            '12 min read',
            Icons.science,
            Colors.blue,
            false, // Made free
          ),
          const SizedBox(height: 16),
          _buildArticleCard(
            'Hormonal Changes During Fasting',
            'Understanding insulin, growth hormone, and more',
            '15 min read',
            Icons.biotech,
            Colors.green,
            true,
          ),
          const SizedBox(height: 16),
          _buildArticleCard(
            'Research Studies',
            'Latest scientific findings on intermittent fasting',
            '20 min read',
            Icons.library_books,
            Colors.purple,
            true,
          ),
        ],
      ),
    );
  }

  Widget _buildTipsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildTipCard(
            '💧',
            'Stay Hydrated',
            'Drink plenty of water, herbal tea, and black coffee during your fast',
            Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildTipCard(
            '😴',
            'Get Quality Sleep',
            'Poor sleep can disrupt hunger hormones and make fasting harder',
            Colors.purple,
          ),
          const SizedBox(height: 16),
          _buildTipCard(
            '🏃‍♀️',
            'Light Exercise',
            'Gentle walking or yoga can help manage hunger and boost energy',
            Colors.green,
          ),
          const SizedBox(height: 16),
          _buildTipCard(
            '🧘‍♀️',
            'Manage Stress',
            'High stress can trigger emotional eating - try meditation',
            Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildTipCard(
            '💡',
            'Advanced Strategies',
            'Explore advanced fasting techniques and optimization tips',
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildMealPlanningContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildArticleCard(
            'Breaking Your Fast Right',
            'What to eat when your eating window opens',
            '8 min read',
            Icons.restaurant,
            Colors.green,
            false,
          ),
          const SizedBox(height: 16),
          _buildArticleCard(
            'Nutrient-Dense Meals',
            'Maximizing nutrition in your eating window',
            '12 min read',
            Icons.eco,
            Colors.blue,
            false, // Made free
          ),
          const SizedBox(height: 16),
          _buildArticleCard(
            '16:8 Meal Plans',
            'Complete meal plans for different dietary preferences',
            '15 min read',
            Icons.menu_book,
            Colors.orange,
            false, // Made free
          ),
          const SizedBox(height: 16),
          _buildArticleCard(
            'Weekly Meal Plans',
            'Complete meal planning guides for successful fasting',
            '20 min read',
            Icons.calendar_today,
            Colors.purple,
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildFAQContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildFAQCard(
            'Can I drink coffee while fasting?',
            'Yes! Black coffee, tea, and water are fine during your fast.',
          ),
          const SizedBox(height: 12),
          _buildFAQCard(
            'What if I feel dizzy or weak?',
            'Listen to your body. Break your fast if needed and consult a healthcare provider.',
          ),
          const SizedBox(height: 12),
          _buildFAQCard(
            'How long should I fast as a beginner?',
            'Start with 12-16 hours and gradually increase as you feel comfortable.',
          ),
          const SizedBox(height: 12),
          _buildFAQCard(
            'Can I exercise while fasting?',
            'Light exercise is fine. For intense workouts, you may need to adjust timing.',
          ),
          const SizedBox(height: 12),
          _buildFAQCard(
            'What are the long-term benefits?',
            'Improved insulin sensitivity, cellular repair, and metabolic health.',
          ),
          const SizedBox(height: 12),
          _buildFAQCard(
            'How do I break a plateau?',
            'Try varying your fasting schedule or adjusting your eating window.',
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(
    String title,
    String description,
    String readTime,
    IconData icon,
    Color color,
    bool isPremium, [
    VoidCallback? onTap,
  ]) {
    return GestureDetector(
      onTap: onTap ??
          () {
            if (isPremium) {
              _showPremiumDialog();
            } else {
              // Navigate to article
            }
          },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isPremium
              ? Border.all(color: Colors.amber.withOpacity(0.3))
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
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
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const Spacer(),
                if (isPremium)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'PREMIUM',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  readTime,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(
      String emoji, String title, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQCard(String question, String answer) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumTipsCard() {
    return GestureDetector(
      onTap: _showPremiumDialog,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFB74D), Color(0xFFFFA726)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.star, color: Colors.white, size: 24),
                SizedBox(width: 8),
                Text(
                  'Premium Tips & Strategies',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Unlock 50+ advanced tips, meal timing strategies, and personalized recommendations',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Upgrade to Premium',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumMealPlanCard() {
    return GestureDetector(
      onTap: _showPremiumDialog,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.restaurant_menu, color: Colors.white, size: 24),
                SizedBox(width: 8),
                Text(
                  'Personalized Meal Plans',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Get custom meal plans based on your fasting schedule, dietary preferences, and health goals',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Get Custom Plans',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumFAQCard() {
    return GestureDetector(
      onTap: _showPremiumDialog,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.support_agent, color: Colors.white, size: 24),
                SizedBox(width: 8),
                Text(
                  'Expert Q&A Access',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Ask questions directly to our team of nutritionists and fasting experts',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Ask the Experts',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickStartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Quick Start Guide'),
        content: const Text(
          '1. Choose your fasting window (start with 16:8)\n'
          '2. Pick consistent start and end times\n'
          '3. Stay hydrated during your fast\n'
          '4. Listen to your body\n'
          '5. Track your progress\n\n'
          'Remember: Start slowly and be patient with yourself!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Premium Content'),
        content: const Text(
          'This content is available with a Premium subscription.\n\n'
          'Upgrade to access:\n'
          '• Expert-written articles\n'
          '• Personalized meal plans\n'
          '• 1-on-1 coaching sessions\n'
          '• Advanced analytics\n'
          '• And much more!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to subscription screen
            },
            child: const Text('Upgrade Now'),
          ),
        ],
      ),
    );
  }
}
