import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../providers/patho_lab_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';
import '../../cards/patho_lab/lab_card.dart';

class PathoLabListScreen extends ConsumerStatefulWidget {
  const PathoLabListScreen({super.key});

  @override
  ConsumerState<PathoLabListScreen> createState() => _PathoLabListScreenState();
}

class _PathoLabListScreenState extends ConsumerState<PathoLabListScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(pathoLabProvider.notifier).fetchLabs());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(pathoLabProvider.notifier).fetchLabs(name: query);
  }

  @override
  Widget build(BuildContext context) {
    final pathoLabState = ref.watch(pathoLabProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: _isSearching ? null : 'Patho Labs',
        subtitle: _isSearching ? null : 'Find diagnostic centers near you',
        showBackButton: false,
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Iconsax.close_circle : Iconsax.search_normal_1,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _onSearchChanged('');
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
                vertical: 8,
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search patho labs...',
                  prefixIcon: const Icon(
                    Iconsax.search_normal,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          Expanded(
            child: pathoLabState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : pathoLabState.error != null
                ? Center(child: Text('Error: ${pathoLabState.error}'))
                : RefreshIndicator(
                    onRefresh: () =>
                        ref.read(pathoLabProvider.notifier).fetchLabs(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.screenPadding),
                      itemCount: pathoLabState.labs.length,
                      itemBuilder: (context, index) {
                        final lab = pathoLabState.labs[index];
                        return LabCard(
                          lab: lab,
                          onTap: () {
                            context.push('/patho-lab-details/${lab.labId}');
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
