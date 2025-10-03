import 'package:aptimaster/feature/home/controller/home_controller.dart';
import 'package:aptimaster/feature/home/model/aptitude_model.dart';
import 'package:aptimaster/core/controllers/theme_controller.dart';
import 'package:aptimaster/core/services/translation_service.dart';
import 'package:aptimaster/core/services/admob_manager.dart';
import 'package:aptimaster/core/theme/app_colors.dart';
import 'package:aptimaster/core/widgets/app_snackbar.dart';
import 'package:aptimaster/core/widgets/app_text.dart';
import 'package:aptimaster/core/widgets/banner_ad_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late final HomeController homeController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    homeController = Get.put(HomeController());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App resumed - refresh test statistics
      homeController.refreshTestStatistics();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.translate('app_name')),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.person),
          onPressed: () => Get.toNamed('/profile'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context, homeController),
          ),
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => Get.toNamed('/language'),
          ),
          IconButton(
            icon: Obx(
              () => Icon(
                Get.find<ThemeController>().isDarkMode
                    ? Icons.brightness_7
                    : Icons.brightness_4,
              ),
            ),
            onPressed: () {
              Get.find<ThemeController>().toggleTheme();
            },
          ),
        ],
      ),
      body: Obx(() {
        if (homeController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (homeController.errorMessage.isNotEmpty) {
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
                AppText.h3('Error Loading Data'),
                const SizedBox(height: 8),
                AppText.bodyMedium(
                  homeController.errorMessage,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => homeController.refreshCategories(),
                  child: AppText.button('Retry'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Header Stats
            _buildHeaderStats(homeController),

            // Search Bar
            _buildSearchBar(homeController, context),

            // Categories List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await homeController.refreshCategories();
                },
                child: homeController.categories.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.category_outlined,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            AppText.h3('No Categories Found'),
                            const SizedBox(height: 8),
                            AppText.bodyMedium(
                              'Pull down to refresh or check your connection',
                              color: AppColors.textSecondary,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : homeController.viewType.value == 'grid'
                    ? _buildGridView(homeController)
                    : _buildListView(homeController),
              ),
            ),

            // Banner Ad at bottom
            const BannerAdWidget(
              margin: EdgeInsets.only(bottom: 8),
            ),
          ],
        );
      }),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {
      //     AppSnackbar.showInfo(
      //       title: 'Coming Soon',
      //       message: 'Practice tests feature will be available soon!',
      //       icon: Icons.quiz,
      //     );
      //   },
      //   icon: const Icon(Icons.quiz),
      //   label: AppText.button('Practice Test'),
      // ),
    );
  }

  Widget _buildHeaderStats(HomeController controller) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          AppText.h1(
            AppTranslations.translate('home_welcome'),
            color: AppColors.white,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          AppText.bodyLarge(
            AppTranslations.translate('home_subtitle'),
            color: AppColors.white,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                '${controller.getTotalCategories()}',
                'Categories',
              ),
              _buildStatItem('${controller.getTotalSubCategories()}', 'Topics'),
              _buildStatItem('${controller.getTotalQuestions()}', 'Questions'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        AppText.h2(value, color: AppColors.white),
        AppText.caption(label, color: AppColors.white),
      ],
    );
  }

  Widget _buildSearchBar(HomeController controller, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: controller.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search categories and topics...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: controller.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: controller.clearSearch,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
          ),
          SizedBox(
            width: Get.width * 0.3,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    controller.viewType.value = 'grid';
                  },
                  child: _buildViewButton(Icons.grid_on_sharp, context),
                ),
                GestureDetector(
                  onTap: () => controller.viewType.value = 'list',
                  child: _buildViewButton(Icons.list, context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewButton(IconData icon, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Icon(
        icon,
        color: Theme.of(context).colorScheme.onSurface,
        size: 20,
      ),
    );
  }

  Widget _buildExpandableCategoryCard(
    CategoryModel category,
    HomeController controller,
  ) {
    final categoryColor = _getCategoryColor(category.slug);
    final categoryIcon = _getCategoryIcon(category.slug);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Theme(
        data: Theme.of(Get.context!).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: ValueKey(category.id),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(categoryIcon, color: categoryColor, size: 24),
          ),
          title: AppText.h3(category.name),
          subtitle: AppText.bodyMedium(
            category.description ?? 'No description available',
            color: AppColors.textSecondary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${category.subcategoriesCount}',
                  style: TextStyle(
                    color: categoryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.expand_more,
                color: Theme.of(
                  Get.context!,
                ).colorScheme.onSurface.withOpacity(0.6),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(categoryIcon, color: categoryColor, size: 32),
                        const SizedBox(height: 8),
                        AppText.h3(
                          '${category.subcategoriesCount} Topics Available',
                        ),
                        const SizedBox(height: 4),
                        AppText.bodyMedium(
                          'Tap to explore ${category.subcategoriesCount} subtopics in ${category.name}',
                          color: Theme.of(
                            Get.context!,
                          ).colorScheme.onSurface.withOpacity(0.7),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Show interstitial ad before navigation
                            AdMobManager().showInterstitialAd(
                              onAdDismissed: () {
                                // Navigate to subcategories page after ad (or immediately if no ad)
                                Get.toNamed(
                                  '/subcategories',
                                  arguments: {'category': category},
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: AppText.button('Start Practice'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: categoryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String slug) {
    switch (slug) {
      // Main categories
      case 'aptitude-test':
        return AppColors.primary;

      // Arithmetic Aptitude subcategories
      case 'arithmetic-aptitude':
        return AppColors.info;
      case 'numbers':
      case 'lcm-hcf':
      case 'simplification':
      case 'roots':
      case 'number-problems':
      case 'decimal-fractions':
      case 'surds-indices':
      case 'ratio-proportion':
      case 'chain-rule':
      case 'pipes-cistern':
      case 'time-work':
      case 'boats-streams':
      case 'simple-interest':
      case 'compound-interest':
      case 'logarithms':
      case 'area':
      case 'volume-surface-area':
      case 'races-games':
      case 'calendar':
      case 'clocks':
      case 'stocks-shares':
      case 'permutation-combination':
      case 'probability':
      case 'true-discount':
      case 'bankers-discount':
      case 'heights-distances':
      case 'odd-man-series':
      case 'data-interpretation':
        return AppColors.info;

      // Verbal Ability subcategories
      case 'verbal-ability':
        return AppColors.success;
      case 'spotting-errors':
      case 'antonyms':
      case 'synonyms':
      case 'spelling-test':
      case 'sentence-completion':
      case 'ordering-words':
      case 'ordering-sentences':
      case 'completing-statements':
      case 'idioms-phrases':
      case 'one-word-substitutes':
      case 'change-voice':
      case 'change-speech':
      case 'verbal-analogies':
      case 'common-errors':
      case 'sentence-improvement':
      case 'transformation':
      case 'selecting-words':
      case 'shuffling-sentence-parts':
      case 'shuffling-passage-sentences':
      case 'closet-test':
      case 'passage-completion':
      case 'substitution':
      case 'sentence-formation':
      case 'paragraph-formation':
      case 'theme-detection':
      case 'deriving-conclusions':
        return AppColors.success;

      // Reasoning subcategories
      case 'reasoning':
        return AppColors.warning;
      case 'logical-sequence-words':
      case 'verbal-classification':
      case 'essential-part':
      case 'artificial-language':
      case 'matching-definitions':
      case 'making-judgments':
      case 'verbal-reasoning':
      case 'logical-problems':
      case 'analyzing-arguments':
      case 'course-action':
      case 'statement-assumption':
      case 'statement-conclusion':
      case 'statement-arguments':
      case 'cause-effect':
      case 'logical-deduction':
      case 'letter-symbol-series':
      case 'number-series':
      case 'coding-decoding':
      case 'blood-relations':
      case 'direction-sense':
      case 'seating-arrangement':
      case 'syllogism':
      case 'input-output':
      case 'data-sufficiency':
      case 'decision-making':
      case 'statement-course-action':
      case 'assertion-reason':
      case 'situation-reaction':
      case 'character-puzzles':
      case 'classification':
      case 'series-completion':
      case 'analogy':
      case 'mirror-images':
      case 'water-images':
      case 'embedded-images':
      case 'pattern-completion':
      case 'figure-classification':
      case 'paper-folding':
      case 'paper-cutting':
      case 'rule-detection':
      case 'grouping-figures':
      case 'dice':
      case 'cubes':
      case 'venn-diagrams':
      case 'mathematical-operations':
      case 'arithmetic-reasoning':
      case 'missing-character':
      case 'incomplete-pattern':
      case 'embedded-figure':
      case 'construction-squares-triangles':
      case 'figure-matrix':
      case 'non-verbal-reasoning':
        return AppColors.warning;

      // Computer Programming subcategories
      case 'computer-programming':
        return AppColors.error;
      case 'c-programming':
      case 'cpp-programming':
      case 'java-programming':
      case 'python-programming':
      case 'data-structures':
      case 'algorithms':
      case 'database-concepts':
      case 'operating-systems':
      case 'computer-networks':
      case 'software-engineering':
      case 'web-technologies':
      case 'mobile-development':
        return AppColors.error;

      // General Knowledge subcategories
      case 'general-knowledge':
        return AppColors.secondary;
      case 'current-affairs':
      case 'indian-history':
      case 'world-history':
      case 'indian-geography':
      case 'world-geography':
      case 'indian-polity':
      case 'indian-economy':
      case 'science-technology':
      case 'sports':
      case 'literature':
      case 'art-culture':
      case 'environment':
        return AppColors.secondary;

      // Legacy categories (fallback)
      case 'general-aptitude':
        return AppColors.primary;
      case 'verbal-and-reasoning':
        return AppColors.info;
      case 'current-affairs-gk':
        return AppColors.success;
      case 'interview':
        return AppColors.warning;
      case 'engineering':
        return AppColors.error;
      case 'programming':
        return AppColors.secondary;
      case 'online-tests':
        return AppColors.accent;
      case 'technical-mcqs':
        return AppColors.primary;
      case 'technical-short-answers':
        return AppColors.info;
      case 'medical-science':
        return AppColors.success;
      case 'puzzles':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getCategoryIcon(String slug) {
    switch (slug) {
      // Main categories
      case 'aptitude-test':
        return Icons.quiz;

      // Arithmetic Aptitude subcategories
      case 'arithmetic-aptitude':
        return Icons.calculate;
      case 'numbers':
        return Icons.numbers;
      case 'lcm-hcf':
        return Icons.functions;
      case 'simplification':
        return Icons.calculate_outlined;
      case 'roots':
        return Icons.calculate;
      case 'number-problems':
        return Icons.help_outline;
      case 'decimal-fractions':
        return Icons.calculate;
      case 'surds-indices':
        return Icons.functions;
      case 'ratio-proportion':
        return Icons.compare;
      case 'chain-rule':
        return Icons.link;
      case 'pipes-cistern':
        return Icons.water_drop;
      case 'time-work':
        return Icons.schedule;
      case 'boats-streams':
        return Icons.directions_boat;
      case 'simple-interest':
        return Icons.account_balance;
      case 'compound-interest':
        return Icons.trending_up;
      case 'logarithms':
        return Icons.functions;
      case 'area':
        return Icons.crop_square;
      case 'volume-surface-area':
        return Icons.crop_square;
      case 'races-games':
        return Icons.sports;
      case 'calendar':
        return Icons.calendar_month;
      case 'clocks':
        return Icons.access_time;
      case 'stocks-shares':
        return Icons.trending_up;
      case 'permutation-combination':
        return Icons.shuffle;
      case 'probability':
        return Icons.casino;
      case 'true-discount':
        return Icons.local_offer;
      case 'bankers-discount':
        return Icons.account_balance;
      case 'heights-distances':
        return Icons.height;
      case 'odd-man-series':
        return Icons.find_in_page;
      case 'data-interpretation':
        return Icons.analytics;

      // Verbal Ability subcategories
      case 'verbal-ability':
        return Icons.psychology;
      case 'spotting-errors':
        return Icons.error_outline;
      case 'antonyms':
        return Icons.compare_arrows;
      case 'synonyms':
        return Icons.compare;
      case 'spelling-test':
        return Icons.spellcheck;
      case 'sentence-completion':
        return Icons.edit;
      case 'ordering-words':
        return Icons.sort;
      case 'ordering-sentences':
        return Icons.format_list_numbered;
      case 'completing-statements':
        return Icons.assignment;
      case 'idioms-phrases':
        return Icons.format_quote;
      case 'one-word-substitutes':
        return Icons.text_fields;
      case 'change-voice':
        return Icons.record_voice_over;
      case 'change-speech':
        return Icons.mic;
      case 'verbal-analogies':
        return Icons.compare_arrows;
      case 'common-errors':
        return Icons.warning;
      case 'sentence-improvement':
        return Icons.build;
      case 'transformation':
        return Icons.transform;
      case 'selecting-words':
        return Icons.text_format;
      case 'shuffling-sentence-parts':
        return Icons.shuffle;
      case 'shuffling-passage-sentences':
        return Icons.format_list_numbered;
      case 'closet-test':
        return Icons.quiz;
      case 'passage-completion':
        return Icons.article;
      case 'substitution':
        return Icons.swap_horiz;
      case 'sentence-formation':
        return Icons.create;
      case 'paragraph-formation':
        return Icons.format_align_left;
      case 'theme-detection':
        return Icons.lightbulb;
      case 'deriving-conclusions':
        return Icons.lightbulb;

      // Reasoning subcategories
      case 'reasoning':
        return Icons.psychology;
      case 'logical-sequence-words':
        return Icons.sort;
      case 'verbal-classification':
        return Icons.category;
      case 'essential-part':
        return Icons.star;
      case 'artificial-language':
        return Icons.language;
      case 'matching-definitions':
        return Icons.compare;
      case 'making-judgments':
        return Icons.gavel;
      case 'verbal-reasoning':
        return Icons.psychology;
      case 'logical-problems':
        return Icons.extension;
      case 'analyzing-arguments':
        return Icons.analytics;
      case 'course-action':
        return Icons.directions;
      case 'statement-assumption':
        return Icons.assignment;
      case 'statement-conclusion':
        return Icons.lightbulb;
      case 'statement-arguments':
        return Icons.forum;
      case 'cause-effect':
        return Icons.timeline;
      case 'logical-deduction':
        return Icons.psychology;
      case 'letter-symbol-series':
        return Icons.abc;
      case 'number-series':
        return Icons.numbers;
      case 'coding-decoding':
        return Icons.code;
      case 'blood-relations':
        return Icons.family_restroom;
      case 'direction-sense':
        return Icons.navigation;
      case 'seating-arrangement':
        return Icons.chair;
      case 'syllogism':
        return Icons.psychology;
      case 'input-output':
        return Icons.input;
      case 'data-sufficiency':
        return Icons.data_usage;
      case 'decision-making':
        return Icons.gavel;
      case 'statement-course-action':
        return Icons.directions;
      case 'assertion-reason':
        return Icons.fact_check;
      case 'situation-reaction':
        return Icons.psychology;
      case 'character-puzzles':
        return Icons.extension;
      case 'classification':
        return Icons.category;
      case 'series-completion':
        return Icons.format_list_numbered;
      case 'analogy':
        return Icons.compare;
      case 'mirror-images':
        return Icons.image;
      case 'water-images':
        return Icons.water;
      case 'embedded-images':
        return Icons.image_search;
      case 'pattern-completion':
        return Icons.pattern;
      case 'figure-classification':
        return Icons.category;
      case 'paper-folding':
        return Icons.folder;
      case 'paper-cutting':
        return Icons.content_cut;
      case 'rule-detection':
        return Icons.rule;
      case 'grouping-figures':
        return Icons.group;
      case 'dice':
        return Icons.casino;
      case 'cubes':
        return Icons.crop_square;
      case 'venn-diagrams':
        return Icons.circle;
      case 'mathematical-operations':
        return Icons.calculate;
      case 'arithmetic-reasoning':
        return Icons.calculate;
      case 'missing-character':
        return Icons.help_outline;
      case 'incomplete-pattern':
        return Icons.pattern;
      case 'embedded-figure':
        return Icons.image_search;
      case 'construction-squares-triangles':
        return Icons.crop_square;
      case 'figure-matrix':
        return Icons.grid_view;
      case 'non-verbal-reasoning':
        return Icons.psychology;

      // Computer Programming subcategories
      case 'computer-programming':
        return Icons.computer;
      case 'c-programming':
        return Icons.code;
      case 'cpp-programming':
        return Icons.code;
      case 'java-programming':
        return Icons.code;
      case 'python-programming':
        return Icons.code;
      case 'data-structures':
        return Icons.storage;
      case 'algorithms':
        return Icons.functions;
      case 'database-concepts':
        return Icons.storage;
      case 'operating-systems':
        return Icons.computer;
      case 'computer-networks':
        return Icons.network_check;
      case 'software-engineering':
        return Icons.engineering;
      case 'web-technologies':
        return Icons.web;
      case 'mobile-development':
        return Icons.phone_android;

      // General Knowledge subcategories
      case 'general-knowledge':
        return Icons.public;
      case 'current-affairs':
        return Icons.newspaper;
      case 'indian-history':
        return Icons.history;
      case 'world-history':
        return Icons.history_edu;
      case 'indian-geography':
        return Icons.map;
      case 'world-geography':
        return Icons.public;
      case 'indian-polity':
        return Icons.account_balance;
      case 'indian-economy':
        return Icons.trending_up;
      case 'science-technology':
        return Icons.science;
      case 'sports':
        return Icons.sports;
      case 'literature':
        return Icons.menu_book;
      case 'art-culture':
        return Icons.palette;
      case 'environment':
        return Icons.eco;

      // Legacy categories (fallback)
      case 'general-aptitude':
        return Icons.calculate;
      case 'verbal-and-reasoning':
        return Icons.psychology;
      case 'current-affairs-gk':
        return Icons.public;
      case 'interview':
        return Icons.work;
      case 'engineering':
        return Icons.engineering;
      case 'programming':
        return Icons.code;
      case 'online-tests':
        return Icons.quiz;
      case 'technical-mcqs':
        return Icons.help_outline;
      case 'technical-short-answers':
        return Icons.short_text;
      case 'medical-science':
        return Icons.medical_services;
      case 'puzzles':
        return Icons.extension;
      default:
        return Icons.category;
    }
  }

  void _showSearchDialog(BuildContext context, HomeController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: AppText.h3('Search'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search categories and topics...',
            border: OutlineInputBorder(),
          ),
          onChanged: controller.setSearchQuery,
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.clearSearch();
              Navigator.pop(context);
            },
            child: AppText.button('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: AppText.button('Close'),
          ),
        ],
      ),
    );
  }

  // Grid View Widget
  Widget _buildGridView(HomeController controller) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: controller.categories.length,
        itemBuilder: (context, index) {
          final category = controller.categories[index];
          return _buildGridCategoryCard(category, controller);
        },
      ),
    );
  }

  // List View Widget
  Widget _buildListView(HomeController controller) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.categories.length,
      itemBuilder: (context, index) {
        final category = controller.categories[index];
        return _buildExpandableCategoryCard(category, controller);
      },
    );
  }

  // Grid Category Card Widget
  Widget _buildGridCategoryCard(
    CategoryModel category,
    HomeController controller,
  ) {
    final categoryColor = _getCategoryColor(category.slug);
    final categoryIcon = _getCategoryIcon(category.slug);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: GestureDetector(
        //  borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Show interstitial ad before navigation
          AdMobManager().showInterstitialAd(
            onAdDismissed: () {
              // Navigate to subcategories page after ad (or immediately if no ad)
              Get.toNamed('/subcategories', arguments: {'category': category});
            },
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                categoryColor.withOpacity(0.1),
                categoryColor.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(categoryIcon, color: categoryColor, size: 28),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: AppText.caption('Active', color: AppColors.success),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              AppText.h3(
                category.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Description
              Expanded(
                child: AppText.bodySmall(
                  category.description ?? 'No description available',
                  color: AppColors.textSecondary,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 12),

              // Subtopics Count and Arrow
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: AppText.caption(
                      '${category.subcategoriesCount} Topics',
                      color: categoryColor,
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: categoryColor, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show Category Details Dialog
  void _showCategoryDetails(CategoryModel category, HomeController controller) {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getCategoryColor(category.slug).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getCategoryIcon(category.slug),
                color: _getCategoryColor(category.slug),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: AppText.h3(category.name)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,

          child: ListView(
            shrinkWrap: true,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _getCategoryColor(category.slug).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      _getCategoryIcon(category.slug),
                      color: _getCategoryColor(category.slug),
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    AppText.h3(
                      '${category.subcategoriesCount} Topics Available',
                    ),
                    const SizedBox(height: 8),
                    AppText.bodyMedium(
                      category.description ?? 'No description available',
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // Show interstitial ad before navigation
                        AdMobManager().showInterstitialAd(
                          onAdDismissed: () {
                            // Navigate to subcategories page after ad (or immediately if no ad)
                            Get.toNamed(
                              '/subcategories',
                              arguments: {'category': category},
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: AppText.button('Start Practice'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getCategoryColor(category.slug),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: AppText.button('Close'),
          ),
        ],
      ),
    );
  }
}
