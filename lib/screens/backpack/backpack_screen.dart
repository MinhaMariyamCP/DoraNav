import 'package:flutter/material.dart';
import 'models/backpack_context.dart';
import 'models/suggestion_item.dart';
import 'services/mock_recommendation_service.dart';
import 'services/recommendation_service.dart';
import 'theme/backpack_theme.dart';
import 'widgets/added_items_sheet.dart';
import 'widgets/backpack_illustrations.dart';
import 'widgets/backpack_topbar.dart';
import 'widgets/categories_bar.dart';
import 'widgets/empty_backpack_view.dart';
import 'widgets/item_detail_modal.dart';
import 'widgets/scenario_selector_bar.dart';
import 'widgets/search_voice_row.dart';
import 'widgets/searching_speaking_view.dart';
import 'widgets/suggestion_card.dart';

/// Production-ready, responsive Backpack Screen for DoraNav.
///
/// Implements all 5 required UI states:
/// 1. Empty/default backpack
/// 2. Dora searching/speaking
/// 3. Dynamic suggested results
/// 4. Added/selected items
/// 5. Optional item-detail view
class BackpackScreen extends StatefulWidget {
  final RecommendationService? recommendationService;
  final BackpackScenario initialScenario;
  final bool startInEmptyState;

  const BackpackScreen({
    super.key,
    this.recommendationService,
    this.initialScenario = BackpackScenario.riverCrossing,
    this.startInEmptyState = false,
  });

  @override
  State<BackpackScreen> createState() => _BackpackScreenState();
}

class _BackpackScreenState extends State<BackpackScreen> {
  late RecommendationService _service;
  late TextEditingController _searchController;

  BackpackScenario _currentScenario = BackpackScenario.riverCrossing;
  late BackpackContext _currentContext;

  bool _isEmptyState = false;
  bool _isSearchingOrSpeaking = false;
  bool _isVoiceListening = false;

  ItemCategory _selectedCategory = ItemCategory.all;
  BackpackResponse? _response;

  // Track user-added items
  final Map<String, SuggestionItem> _addedItems = {};

  @override
  void initState() {
    super.initState();
    _service = widget.recommendationService ?? MockRecommendationService();
    _searchController = TextEditingController();
    _currentScenario = widget.initialScenario;
    _isEmptyState = widget.startInEmptyState;
    _currentContext = MockRecommendationService.getScenarioContext(_currentScenario);

    if (!_isEmptyState) {
      _loadRecommendations();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecommendations() async {
    setState(() {
      _isSearchingOrSpeaking = true;
    });

    final resp = await _service.getRecommendations(_currentContext);

    if (mounted) {
      setState(() {
        _response = resp;
        _isSearchingOrSpeaking = false;
        _isVoiceListening = false;
      });
    }
  }

  void _onScenarioChanged(BackpackScenario scenario) {
    setState(() {
      _currentScenario = scenario;
      _isEmptyState = false;
      _searchController.clear();
      _currentContext = MockRecommendationService.getScenarioContext(scenario);
    });
    _loadRecommendations();
  }

  void _toggleEmptyState() {
    setState(() {
      _isEmptyState = !_isEmptyState;
      if (!_isEmptyState && _response == null) {
        _loadRecommendations();
      }
    });
  }

  void _onSearchChanged(String query) async {
    if (_isEmptyState) return;

    if (query.trim().isEmpty) {
      _loadRecommendations();
      return;
    }

    setState(() => _isSearchingOrSpeaking = true);
    final resp = await _service.searchItems(query, _currentContext);
    if (mounted) {
      setState(() {
        _response = resp;
        _isSearchingOrSpeaking = false;
      });
    }
  }

  void _onVoicePressed() {
    setState(() {
      _isVoiceListening = !_isVoiceListening;
      _isEmptyState = false;
      _searchController.text = 'We need something to cross the river';
    });

    if (_isVoiceListening) {
      _onSearchChanged(_searchController.text);
    }
  }

  void _onToggleAddItem(SuggestionItem item) {
    setState(() {
      if (_addedItems.containsKey(item.id)) {
        _addedItems.remove(item.id);
      } else {
        _addedItems[item.id] = item.copyWith(isAdded: true);
      }
    });
  }

  void _openItemDetail(SuggestionItem item) {
    // Current state from added items map if modified
    final currentItem = _addedItems[item.id] ?? item;

    ItemDetailModal.show(
      context,
      item: currentItem,
      onQuantityChanged: (newQty) {
        setState(() {
          if (_addedItems.containsKey(item.id)) {
            _addedItems[item.id] = _addedItems[item.id]!.copyWith(quantity: newQty);
          }
        });
      },
      onToggleAdd: (isAdded) {
        setState(() {
          if (isAdded) {
            _addedItems[item.id] = currentItem.copyWith(isAdded: true);
          } else {
            _addedItems.remove(item.id);
          }
        });
      },
    );
  }

  void _openAddedItemsSheet() {
    AddedItemsSheet.show(
      context,
      items: _addedItems.values.toList(),
      onRemoveItem: (item) {
        setState(() {
          _addedItems.remove(item.id);
        });
      },
      onLetsGo: () {
        Navigator.of(context).pop(_addedItems.values.toList());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backpack packed with ${_addedItems.length} items! Ready for adventure!'),
            backgroundColor: BackpackColors.primaryPurple,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      },
    );
  }

  List<SuggestionItem> _filterItems(List<SuggestionItem> allItems) {
    if (_selectedCategory == ItemCategory.all) {
      return allItems;
    }
    return allItems.where((i) => i.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BackpackColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTabletOrDesktop = constraints.maxWidth >= 768;
          final isWideDesktop = constraints.maxWidth >= 1024;

          return Column(
            children: [
              // Top Bar
              BackpackTopBar(
                statusText: _isEmptyState
                    ? "I'm ready to help!"
                    : _isSearchingOrSpeaking
                        ? 'Let me think...'
                        : (_response?.situationTitle ?? 'Great choices!'),
                addedCount: _addedItems.length,
                onBackpackIconPressed: _openAddedItemsSheet,
                onBackPressed: Navigator.of(context).canPop()
                    ? () => Navigator.of(context).pop()
                    : null,
                onSettingsPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('DoraNav Settings'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),

              // Developer Scenario Switcher
              ScenarioSelectorBar(
                activeScenario: _currentScenario,
                isEmptyState: _isEmptyState,
                onScenarioSelected: _onScenarioChanged,
                onToggleEmptyState: _toggleEmptyState,
              ),

              // Search & Voice Row
              SearchVoiceRow(
                controller: _searchController,
                onSearchChanged: _onSearchChanged,
                onVoicePressed: _onVoicePressed,
                isListening: _isVoiceListening,
                onClear: () {
                  _searchController.clear();
                  _loadRecommendations();
                },
              ),

              // Categories Segmented Pills
              CategoriesBar(
                selectedCategory: _selectedCategory,
                onCategorySelected: (cat) {
                  setState(() => _selectedCategory = cat);
                },
              ),
              const SizedBox(height: 8),

              // Body Area (Responsive layout)
              Expanded(
                child: Row(
                  children: [
                    // Main Suggestions / Empty / Thinking content
                    Expanded(
                      flex: 3,
                      child: _buildMainContent(isTabletOrDesktop),
                    ),

                    // Side inventory tray for Wide Desktop screens
                    if (isWideDesktop) ...[
                      const VerticalDivider(width: 1, color: BackpackColors.borderLight),
                      Expanded(
                        flex: 1,
                        child: _buildDesktopInventoryPanel(),
                      ),
                    ],
                  ],
                ),
              ),

              // Bottom sticky summary bar for mobile / tablet
              if (!isWideDesktop && _addedItems.isNotEmpty)
                _buildStickyBottomBar(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMainContent(bool isTabletOrDesktop) {
    // State 1: Empty Backpack
    if (_isEmptyState) {
      return EmptyBackpackView(
        onAskDoraPressed: () {
          setState(() {
            _isEmptyState = false;
            _isVoiceListening = true;
            _searchController.text = 'What do we need to cross the river?';
          });
          _loadRecommendations();
        },
      );
    }

    // State 2: Dora searching / speaking
    if (_isSearchingOrSpeaking) {
      return const SearchingSpeakingView();
    }

    // State 3 & 4: Suggested Results / Selected Items
    final rawSuggestions = _response?.suggestions ?? [];
    final filtered = _filterItems(rawSuggestions);

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, size: 54, color: BackpackColors.textMuted),
            const SizedBox(height: 12),
            Text(
              'No items found in ${_selectedCategory.label} category.',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: BackpackColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // Dora Situation Callout Banner
    Widget situationHeader = Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: BackpackColors.lightPurple,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: BackpackColors.softPurple.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          const DoraAvatarWidget(size: 38),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _response?.situationTitle ?? 'Adventure Time!',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: BackpackColors.primaryPurpleDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _response?.situationSubtitle ?? 'Pack these things to stay safe!',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: BackpackColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (isTabletOrDesktop) {
      // 2-column grid for tablet/desktop
      return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: situationHeader),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3.2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = filtered[index];
                  final isAdded = _addedItems.containsKey(item.id);
                  final displayItem = isAdded ? _addedItems[item.id]! : item;

                  return SuggestionCard(
                    item: displayItem,
                    onToggleAdd: () => _onToggleAddItem(displayItem),
                    onTapDetail: () => _openItemDetail(displayItem),
                  );
                },
                childCount: filtered.length,
              ),
            ),
          ),
        ],
      );
    }

    // 1-column list for Mobile
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: filtered.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return situationHeader;
        }

        final item = filtered[index - 1];
        final isAdded = _addedItems.containsKey(item.id);
        final displayItem = isAdded ? _addedItems[item.id]! : item;

        return SuggestionCard(
          item: displayItem,
          onToggleAdd: () => _onToggleAddItem(displayItem),
          onTapDetail: () => _openItemDetail(displayItem),
        );
      },
    );
  }

  /// Sticky Bottom Action Bar for mobile
  Widget _buildStickyBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: BackpackColors.primaryPurple.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Items (${_addedItems.length})',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: BackpackColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_addedItems.values.map((e) => e.name).take(2).join(', ')}${_addedItems.length > 2 ? '...' : ''}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: BackpackColors.textSecondary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _openAddedItemsSheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: BackpackColors.primaryPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                elevation: 3,
              ),
              icon: const Icon(Icons.check_circle_rounded, size: 18),
              label: const Text(
                'Done! Let\'s go! →',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Permanent side panel for Wide Desktop layouts
  Widget _buildDesktopInventoryPanel() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.backpack_rounded, color: BackpackColors.primaryPurple, size: 24),
              const SizedBox(width: 8),
              Text(
                'My Backpack (${_addedItems.length})',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: BackpackColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Expanded(
            child: _addedItems.isEmpty
                ? const Center(
                    child: Text(
                      'Your backpack is empty!\nClick Add on items to pack them.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: BackpackColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.separated(
                    itemCount: _addedItems.length,
                    separatorBuilder: (_, _) => const Divider(height: 12, color: BackpackColors.borderLight),
                    itemBuilder: (context, index) {
                      final item = _addedItems.values.elementAt(index);
                      return Row(
                        children: [
                          AdventureItemIconWidget(iconKey: item.iconKey, size: 40),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                                ),
                                Text(
                                  item.quantity > 1 ? 'Qty: ${item.quantity}' : item.category.label,
                                  style: const TextStyle(fontSize: 11, color: BackpackColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 16, color: BackpackColors.textSecondary),
                            onPressed: () => _onToggleAddItem(item),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _addedItems.isNotEmpty ? _openAddedItemsSheet : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: BackpackColors.primaryPurple,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(46),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: const Text('Confirm & Start Adventure', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}
