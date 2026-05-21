import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../models/lab_test.dart';
import '../../providers/lab_test_provider.dart';
import '../../theme/app_theme.dart';
import '../../cards/lab_test/lab_test_header_card.dart';
import '../../cards/lab_test/lab_test_description_parameter_card.dart';
import '../../cards/lab_test/lab_test_sample_report_card.dart';
import '../../cards/lab_test/lab_test_precautions_card.dart';
import '../../cards/lab_test/lab_test_reviews_card.dart';
import '../../cards/lab_test/lab_test_pricing_card.dart';
import '../../cards/lab_test/lab_test_booking_bar.dart';

class LabTestDetailsScreen extends ConsumerStatefulWidget {
  final String testId;

  const LabTestDetailsScreen({super.key, required this.testId});

  @override
  ConsumerState<LabTestDetailsScreen> createState() => _LabTestDetailsScreenState();
}

class _LabTestDetailsScreenState extends ConsumerState<LabTestDetailsScreen> {
  late ScrollController _scrollController;
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    Future.microtask(() {
      ref.read(labTestProvider.notifier).fetchTestById(widget.testId);
    });
  }

  void _scrollListener() {
    if (_scrollController.hasClients) {
      final isCollapsed = _scrollController.offset > (350 - kToolbarHeight - 50);
      if (isCollapsed != _isCollapsed) {
        setState(() {
          _isCollapsed = isCollapsed;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labTestState = ref.watch(labTestProvider);
    final test = labTestState.selectedTest;

    if (labTestState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (test == null) {
      return Scaffold(
        body: Center(child: Text(labTestState.error ?? 'Test not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Premium Header with SliverAppBar
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.primary,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: _isCollapsed ? Colors.transparent : Colors.black.withAlpha(50),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Iconsax.arrow_left_2,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
            title: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _isCollapsed ? 1.0 : 0.0,
              child: Text(
                test.coreTestDetails?.testName ?? 'Test Details',
                style: AppTextStyles.header.copyWith(fontSize: 18, color: Colors.white),
              ),
            ),
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: LabTestHeaderCard(test: test),
            ),
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 32),
                LabTestDescriptionParameterCard(test: test),
                LabTestSampleReportCard(test: test),
                LabTestPrecautionsCard(test: test),
                LabTestReviewsCard(test: test),
                LabTestPricingCard(test: test),
                const SizedBox(height: 120), // Bottom padding for button
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: LabTestBookingBar(
        test: test,
        onBookNow: () => _onBookNow(context, test),
      ),
      extendBody: true,
    );
  }

  void _onBookNow(BuildContext context, LabTestInventoryModel test) {
    context.push(
      '/book-test-package?type=lab_test&itemId=${test.testId}',
    );
  }
}
