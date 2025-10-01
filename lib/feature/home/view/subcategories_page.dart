import 'package:aptimaster/feature/home/model/aptitude_model.dart';
import 'package:aptimaster/core/models/api_models.dart';
import 'package:aptimaster/feature/home/controller/subcategory_controller.dart';
import 'package:aptimaster/feature/questions/view/question_screen.dart';
import 'package:aptimaster/core/widgets/app_text.dart';
import 'package:aptimaster/core/widgets/banner_ad_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SubcategoriesPage extends StatefulWidget {
  const SubcategoriesPage({super.key});

  @override
  State<SubcategoriesPage> createState() => _SubcategoriesPageState();
}

class _SubcategoriesPageState extends State<SubcategoriesPage> {
  late SubcategoryController _controller;
  late CategoryModel _category;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    // Get category from arguments
    final args = Get.arguments as Map<String, dynamic>;
    _category = args['category'] as CategoryModel;

    // Initialize controller
    _controller = Get.put(SubcategoryController());

    // Load subcategories
    _loadSubcategories();
  }

  Future<void> _loadSubcategories() async {
    await _controller.loadSubcategories(_category.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppText.h3(_category.name),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSubcategories,
          ),
        ],
      ),
      body: Obx(() {
        return Column(
          children: [
            Expanded(
              child: _buildBody(),
            ),
            // Banner Ad at bottom
            const BannerAdContainer(pageId: 'subcategories'),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAllFormulasSheet,
        icon: const Icon(Icons.functions),
        label: AppText.button('All Formulas'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildBody() {
    if (_controller.loading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.error.value.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            AppText.h3('Error Loading Subcategories'),
            const SizedBox(height: 8),
            AppText.bodyMedium(
              _controller.error.value,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSubcategories,
              child: AppText.button('Retry'),
            ),
          ],
        ),
      );
    }

    if (_controller.subcategories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            AppText.h3('No Subcategories Found'),
            const SizedBox(height: 8),
            AppText.bodyMedium(
              'This category doesn\'t have any subtopics yet.',
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSubcategories,
              child: AppText.button('Refresh'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSubcategories,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _controller.subcategories.length,
        itemBuilder: (context, index) {
          final subcategory = _controller.subcategories[index];
          return _buildSubcategoryCard(subcategory);
        },
      ),
    );
  }

  Widget _buildSubcategoryCard(SubcategoryModel subcategory) {
    final categoryColor = _getCategoryColor(subcategory.slug);
    final categoryIcon = _getCategoryIcon(subcategory.slug);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _handleSubcategoryTap(subcategory),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(categoryIcon, color: categoryColor, size: 28),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.h3(subcategory.name),
                    const SizedBox(height: 4),
                    AppText.bodyMedium(
                      subcategory.description ?? 'No description available',
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: categoryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: AppText.caption(
                            '${subcategory.questionCount} Questions',
                            color: categoryColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: AppText.caption(
                            'Active',
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSubcategoryTap(SubcategoryModel subcategory) {
    // Show mode selection dialog
    _showModeSelectionDialog(subcategory);
  }

  void _showModeSelectionDialog(SubcategoryModel subcategory) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: AppText.h3('Choose Mode'),
        content: AppText.bodyMedium(
          'How would you like to proceed with this subcategory?',
        ),
        actions: [
          // Learning Mode Button
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToQuestionScreen(subcategory, isLearningMode: true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: AppText.button('Learn'),
          ),
          const SizedBox(width: 8),
          // Test Mode Button
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToQuestionScreen(subcategory, isLearningMode: false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Theme.of(context).colorScheme.onSecondary,
            ),
            child: AppText.button('Test'),
          ),
        ],
      ),
    );
  }

  void _navigateToQuestionScreen(
    SubcategoryModel subcategory, {
    required bool isLearningMode,
  }) {
    Get.to(
      () => QuestionScreen(
        subcategoryId: subcategory.id,
        subcategoryName: subcategory.name,
        isLearningMode: isLearningMode,
      ),
    );
  }

  void _showAllFormulasSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAllFormulasSheet(),
    );
  }

  Widget _buildAllFormulasSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.functions,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppText.h2(
                    'All Formulas & Concepts',
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(children: _buildAllFormulasContent()),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAllFormulasContent() {
    final formulas = _getAllFormulas();
    return formulas.entries.map((entry) {
      final topic = entry.key;
      final formulasList = entry.value;
      final topicColor = _getTopicColor(topic);

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: topicColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_getTopicIcon(topic), color: topicColor, size: 20),
            ),
            title: AppText.h3(
              topic,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            subtitle: AppText.caption(
              '${formulasList.split('\n').length} formulas',
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: AppText.bodyMedium(
                  formulasList,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Color _getCategoryColor(String slug) {
    switch (slug) {
      case 'arithmetic-aptitude':
        return const Color(0xFF2196F3);
      case 'data-interpretation':
        return const Color(0xFF4CAF50);
      case 'verbal-ability':
        return const Color(0xFF9C27B0);
      case 'logical-reasoning':
        return const Color(0xFFFF9800);
      case 'verbal-reasoning':
        return const Color(0xFF607D8B);
      case 'nonverbal-reasoning':
        return const Color(0xFFE91E63);
      default:
        return const Color(0xFF757575);
    }
  }

  IconData _getCategoryIcon(String slug) {
    switch (slug) {
      case 'arithmetic-aptitude':
        return Icons.calculate;
      case 'data-interpretation':
        return Icons.analytics;
      case 'verbal-ability':
        return Icons.psychology;
      case 'logical-reasoning':
        return Icons.lightbulb;
      case 'verbal-reasoning':
        return Icons.chat;
      case 'nonverbal-reasoning':
        return Icons.visibility;
      default:
        return Icons.category;
    }
  }

  Map<String, String> _getAllFormulas() {
    return {
      'Numbers':
          '• Prime Numbers: Numbers divisible only by 1 and themselves\n• Even Numbers: Divisible by 2\n• Odd Numbers: Not divisible by 2\n• Composite Numbers: Have more than 2 factors\n• HCF: Highest Common Factor\n• LCM: Lowest Common Multiple\n• Divisibility Rules: 2, 3, 4, 5, 6, 8, 9, 10, 11',
      'Percentage':
          '• Percentage = (Part/Whole) × 100\n• Percentage Change = ((New Value - Old Value)/Old Value) × 100\n• Compound Interest = P(1 + r/n)^(nt)\n• Simple Interest = (P × R × T)/100\n• Profit % = (Profit/Cost Price) × 100\n• Loss % = (Loss/Cost Price) × 100\n• Markup % = (Markup/Cost Price) × 100',
      'Profit & Loss':
          '• Profit = Selling Price - Cost Price\n• Loss = Cost Price - Selling Price\n• Profit % = (Profit/Cost Price) × 100\n• Loss % = (Loss/Cost Price) × 100\n• Selling Price = Cost Price + Profit\n• Cost Price = Selling Price - Profit\n• Markup = Selling Price - Cost Price',
      'Time & Work':
          '• Work = Time × Rate\n• Rate = Work/Time\n• Time = Work/Rate\n• If A can do work in x days, then A\'s 1 day work = 1/x\n• If A and B work together, combined work = 1/x + 1/y\n• Efficiency = Work done/Time taken\n• Total Work = Individual work × Number of workers',
      'Time & Distance':
          '• Speed = Distance/Time\n• Distance = Speed × Time\n• Time = Distance/Speed\n• Average Speed = Total Distance/Total Time\n• Relative Speed = Sum of speeds (same direction)\n• Relative Speed = Difference of speeds (opposite direction)\n• Speed in km/hr = (5/18) × Speed in m/sec',
      'Ratio & Proportion':
          '• Ratio = a:b = a/b\n• Proportion = a:b = c:d\n• If a:b = c:d, then ad = bc\n• Compound Ratio = (a×c):(b×d)\n• Mean Proportional = √(a×b)\n• Third Proportional = b²/a\n• Fourth Proportional = (b×c)/a',
      'Average':
          '• Average = Sum of all values/Number of values\n• Weighted Average = (w1×x1 + w2×x2)/(w1 + w2)\n• If average increases by x, total increases by n×x\n• If average decreases by x, total decreases by n×x\n• Combined Average = (n1×a1 + n2×a2)/(n1 + n2)\n• Average Speed = 2ab/(a + b) [for equal distances]',
      'Ages':
          '• Present Age = Current Year - Birth Year\n• Age Difference = Constant (never changes)\n• If A is x years older than B, then A\'s age = B\'s age + x\n• After n years: Age = Present Age + n\n• Before n years: Age = Present Age - n\n• Sum of ages = Number of people × Average age',
      'Simple Interest':
          '• Simple Interest = (Principal × Rate × Time)/100\n• Amount = Principal + Simple Interest\n• Principal = (Simple Interest × 100)/(Rate × Time)\n• Rate = (Simple Interest × 100)/(Principal × Time)\n• Time = (Simple Interest × 100)/(Principal × Rate)\n• If rate changes, new SI = P × (R1×T1 + R2×T2)/100',
      'Compound Interest':
          '• Compound Interest = P[(1 + r/100)^n - 1]\n• Amount = P(1 + r/100)^n\n• For half-yearly: r/2 and 2n\n• For quarterly: r/4 and 4n\n• Effective Rate = (1 + r/100)^n - 1\n• Difference between CI and SI = P(r/100)² × (n + 1)',
      'Area & Volume':
          '• Rectangle Area = Length × Breadth\n• Square Area = Side²\n• Triangle Area = (1/2) × Base × Height\n• Circle Area = πr²\n• Cylinder Volume = πr²h\n• Sphere Volume = (4/3)πr³\n• Cone Volume = (1/3)πr²h\n• Cuboid Volume = Length × Breadth × Height',
      'Algebra':
          '• (a + b)² = a² + 2ab + b²\n• (a - b)² = a² - 2ab + b²\n• a² - b² = (a + b)(a - b)\n• (a + b)³ = a³ + 3a²b + 3ab² + b³\n• (a - b)³ = a³ - 3a²b + 3ab² - b³\n• a³ + b³ = (a + b)(a² - ab + b²)\n• a³ - b³ = (a - b)(a² + ab + b²)',
      'Geometry':
          '• Sum of angles in triangle = 180°\n• Sum of angles in quadrilateral = 360°\n• Pythagoras Theorem: a² + b² = c²\n• Area of parallelogram = Base × Height\n• Perimeter of rectangle = 2(Length + Breadth)\n• Circumference of circle = 2πr\n• Area of trapezium = (1/2) × (sum of parallel sides) × height',
      'Trigonometry':
          '• sin²θ + cos²θ = 1\n• tanθ = sinθ/cosθ\n• sin(A + B) = sinAcosB + cosAsinB\n• cos(A + B) = cosAcosB - sinAsinB\n• sin2θ = 2sinθcosθ\n• cos2θ = cos²θ - sin²θ\n• tan2θ = 2tanθ/(1 - tan²θ)\n• sin(A - B) = sinAcosB - cosAsinB',
      'Probability':
          '• Probability = Favorable outcomes/Total outcomes\n• P(A or B) = P(A) + P(B) - P(A and B)\n• P(A and B) = P(A) × P(B) [Independent events]\n• P(not A) = 1 - P(A)\n• Conditional Probability = P(A and B)/P(B)\n• P(A|B) = P(A and B)/P(B)\n• Bayes\' Theorem: P(A|B) = P(B|A) × P(A)/P(B)',
      'Permutation & Combination':
          '• Permutation: nPr = n!/(n-r)!\n• Combination: nCr = n!/[r!(n-r)!]\n• nCr = nC(n-r)\n• nCr + nC(r-1) = (n+1)Cr\n• Total arrangements = n!\n• Circular Permutation = (n-1)!\n• Permutation with repetition = n^r',
      'Data Interpretation':
          '• Percentage = (Value/Total) × 100\n• Average = Sum/Count\n• Growth Rate = (New - Old)/Old × 100\n• Ratio = First Value/Second Value\n• Proportion = Part/Whole\n• Percentage Point = Difference between percentages\n• Compound Annual Growth Rate (CAGR) = (End Value/Start Value)^(1/n) - 1',
      'Logical Reasoning':
          '• If A then B: A → B\n• If and only if: A ↔ B\n• Contrapositive: If not B then not A\n• Modus Ponens: If A→B and A, then B\n• Modus Tollens: If A→B and not B, then not A\n• Syllogism: All A are B, All B are C, therefore All A are C\n• Venn Diagrams: Visual representation of logical relationships',
      'Verbal Reasoning':
          '• Synonyms: Words with similar meanings\n• Antonyms: Words with opposite meanings\n• Analogies: A:B :: C:D relationship\n• Word Formation: Prefix + Root + Suffix\n• Context Clues: Meaning from surrounding text\n• Idioms: Expressions with figurative meanings\n• Word Relationships: Cause-effect, part-whole, function',
      'Non-Verbal Reasoning':
          '• Pattern Recognition: Identify sequence\n• Spatial Reasoning: 3D visualization\n• Mirror Images: Reflection across axis\n• Water Images: Reflection across water surface\n• Paper Folding: 2D to 3D transformation\n• Figure Classification: Group similar figures\n• Series Completion: Find the next figure in sequence',
    };
  }

  Color _getTopicColor(String topic) {
    switch (topic.toLowerCase()) {
      case 'numbers':
        return const Color(0xFF2196F3); // Blue
      case 'percentage':
        return const Color(0xFF4CAF50); // Green
      case 'profit & loss':
        return const Color(0xFF9C27B0); // Purple
      case 'time & work':
        return const Color(0xFFFF9800); // Orange
      case 'time & distance':
        return const Color(0xFF607D8B); // Blue Grey
      case 'ratio & proportion':
        return const Color(0xFFE91E63); // Pink
      case 'average':
        return const Color(0xFF795548); // Brown
      case 'ages':
        return const Color(0xFF009688); // Teal
      case 'simple interest':
        return const Color(0xFF3F51B5); // Indigo
      case 'compound interest':
        return const Color(0xFF673AB7); // Deep Purple
      case 'area & volume':
        return const Color(0xFFF44336); // Red
      case 'algebra':
        return const Color(0xFF00BCD4); // Cyan
      case 'geometry':
        return const Color(0xFF8BC34A); // Light Green
      case 'trigonometry':
        return const Color(0xFFFF5722); // Deep Orange
      case 'probability':
        return const Color(0xFF9E9E9E); // Grey
      case 'permutation & combination':
        return const Color(0xFFCDDC39); // Lime
      case 'data interpretation':
        return const Color(0xFFFFC107); // Amber
      case 'logical reasoning':
        return const Color(0xFF3F51B5); // Indigo
      case 'verbal reasoning':
        return const Color(0xFFE91E63); // Pink
      case 'non-verbal reasoning':
        return const Color(0xFF607D8B); // Blue Grey
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  IconData _getTopicIcon(String topic) {
    switch (topic.toLowerCase()) {
      case 'numbers':
        return Icons.numbers;
      case 'percentage':
        return Icons.percent;
      case 'profit & loss':
        return Icons.trending_up;
      case 'time & work':
        return Icons.work;
      case 'time & distance':
        return Icons.speed;
      case 'ratio & proportion':
        return Icons.compare_arrows;
      case 'average':
        return Icons.bar_chart;
      case 'ages':
        return Icons.cake;
      case 'simple interest':
        return Icons.account_balance;
      case 'compound interest':
        return Icons.account_balance_wallet;
      case 'area & volume':
        return Icons.crop_square;
      case 'algebra':
        return Icons.functions;
      case 'geometry':
        return Icons.shape_line;
      case 'trigonometry':
        return Icons.calculate;
      case 'probability':
        return Icons.casino;
      case 'permutation & combination':
        return Icons.perm_media;
      case 'data interpretation':
        return Icons.analytics;
      case 'logical reasoning':
        return Icons.lightbulb;
      case 'verbal reasoning':
        return Icons.chat;
      case 'non-verbal reasoning':
        return Icons.visibility;
      default:
        return Icons.functions;
    }
  }
}
