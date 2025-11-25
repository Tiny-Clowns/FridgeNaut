import "package:flutter/material.dart";

class FilterDefinition<T> {
  final String label;
  final bool Function(T item) predicate;

  const FilterDefinition({required this.label, required this.predicate});
}

/// Generic, reusable list with:
/// - search box
/// - filter chips in custom order
/// - optional "All" chip (first or last)
/// - optional pull-to-refresh
/// - custom itemBuilder
class SearchFilterList<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T item) searchText;
  final List<FilterDefinition<T>> filters;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final Future<void> Function()? onRefresh;

  /// Index of the initially selected chip, where the chip order is:
  ///
  /// - if [showAllFilter] && [allFilterFirst]:
  ///      [All] + filters in the given order
  /// - if [showAllFilter] && ![allFilterFirst]:
  ///      filters in the given order + [All]
  /// - if ![showAllFilter]:
  ///      filters in the given order only
  ///
  /// Defaults to 0 (the first chip).
  final int initialFilterIndex;

  /// Whether to show the synthetic "All" chip.
  final bool showAllFilter;

  /// Label for the synthetic "All" chip when [showAllFilter] is true.
  final String allLabel;

  /// If true, place the "All" chip before the filters.
  /// If false, place "All" after the filters.
  final bool allFilterFirst;

  /// Optional predicate for the "All" chip. If null, all items are shown.
  final bool Function(T item)? allPredicate;

  const SearchFilterList({
    super.key,
    required this.items,
    required this.searchText,
    required this.filters,
    required this.itemBuilder,
    this.onRefresh,
    this.initialFilterIndex = 0,
    this.showAllFilter = true,
    this.allLabel = "All",
    this.allFilterFirst = true,
    this.allPredicate,
  });

  @override
  State<SearchFilterList<T>> createState() => _SearchFilterListState<T>();
}

class _SearchFilterListState<T> extends State<SearchFilterList<T>> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  late int _activeFilterIndex;

  @override
  void initState() {
    super.initState();
    _ensureValidConfiguration();
    _activeFilterIndex = _normaliseInitialIndex(widget.initialFilterIndex);
    _searchController.addListener(_handleSearchChanged);
  }

  @override
  void didUpdateWidget(covariant SearchFilterList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    final filtersChanged = oldWidget.filters.length != widget.filters.length;
    final showAllChanged = oldWidget.showAllFilter != widget.showAllFilter;
    final allFirstChanged = oldWidget.allFilterFirst != widget.allFilterFirst;
    final initialIndexChanged =
        oldWidget.initialFilterIndex != widget.initialFilterIndex;

    if (filtersChanged || showAllChanged || allFirstChanged) {
      _ensureValidConfiguration();
    }

    if (filtersChanged ||
        showAllChanged ||
        allFirstChanged ||
        initialIndexChanged) {
      _activeFilterIndex = _normaliseInitialIndex(widget.initialFilterIndex);
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Configuration helpers
  // ---------------------------------------------------------------------------

  void _ensureValidConfiguration() {
    if (!widget.showAllFilter && widget.filters.isEmpty) {
      throw ArgumentError(
        "SearchFilterList: when showAllFilter is false, you must provide at least one filter.",
      );
    }
  }

  int _chipCount() {
    final base = widget.filters.length;
    return widget.showAllFilter ? base + 1 : base;
  }

  int _allChipIndex() {
    if (!widget.showAllFilter) return -1;
    return widget.allFilterFirst ? 0 : widget.filters.length;
  }

  bool _hasAllChip() {
    return widget.showAllFilter;
  }

  bool _isAllChipSelected() {
    final idx = _allChipIndex();
    if (idx < 0) return false;
    return _activeFilterIndex == idx;
  }

  /// Maps the chip index (position in the UI) to the index within [filters].
  /// Returns null if the chip represents the "All" filter.
  int? _filterIndexForChipIndex(int chipIndex) {
    if (!_hasAllChip()) {
      if (chipIndex < 0 || chipIndex >= widget.filters.length) {
        return null;
      }
      return chipIndex;
    }

    final allIndex = _allChipIndex();
    if (chipIndex == allIndex) {
      return null;
    }

    if (widget.allFilterFirst) {
      final filterIndex = chipIndex - 1;
      if (filterIndex < 0 || filterIndex >= widget.filters.length) {
        return null;
      }
      return filterIndex;
    } else {
      // All is at the end, so chip index == filter index for normal filters
      if (chipIndex < 0 || chipIndex >= widget.filters.length) {
        return null;
      }
      return chipIndex;
    }
  }

  int _normaliseInitialIndex(int value) {
    final count = _chipCount();
    if (count == 0) return 0;
    if (value < 0) return 0;
    if (value >= count) return count - 1;
    return value;
  }

  // ---------------------------------------------------------------------------
  // Filtering helpers
  // ---------------------------------------------------------------------------

  void _handleSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  bool _matchesActiveFilter(T item) {
    if (_isAllChipSelected()) {
      final allPredicate = widget.allPredicate;
      if (allPredicate == null) return true;
      return allPredicate(item);
    }

    final filterIndex = _filterIndexForChipIndex(_activeFilterIndex);
    if (filterIndex == null) {
      // Should not happen, but fail closed: don't show the item.
      return false;
    }

    if (filterIndex < 0 || filterIndex >= widget.filters.length) {
      return false;
    }

    final predicate = widget.filters[filterIndex].predicate;
    return predicate(item);
  }

  bool _matchesSearchQuery(T item) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return true;

    final text = widget.searchText(item).toLowerCase();
    return text.contains(query);
  }

  List<T> _calculateFilteredItems() {
    return widget.items.where((item) {
      if (!_matchesActiveFilter(item)) return false;
      if (!_matchesSearchQuery(item)) return false;
      return true;
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // UI helpers
  // ---------------------------------------------------------------------------

  void _handleChipSelected(int chipIndex) {
    setState(() {
      _activeFilterIndex = chipIndex;
    });
  }

  Widget _buildChip(int chipIndex, String label) {
    final selected = _activeFilterIndex == chipIndex;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => _handleChipSelected(chipIndex),
    );
  }

  List<Widget> _buildFilterChipWidgets() {
    final chips = <Widget>[];

    if (widget.showAllFilter && widget.allFilterFirst) {
      // All first
      chips.add(_buildChip(_allChipIndex(), widget.allLabel));
    }

    for (var i = 0; i < widget.filters.length; i++) {
      final chipIndex = widget.showAllFilter && widget.allFilterFirst
          ? i + 1
          : i;
      final filter = widget.filters[i];
      chips.add(_buildChip(chipIndex, filter.label));
    }

    if (widget.showAllFilter && !widget.allFilterFirst) {
      // All last
      chips.add(_buildChip(_allChipIndex(), widget.allLabel));
    }

    return chips;
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: "Search",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: _buildFilterChipWidgets()),
        ],
      ),
    );
  }

  Widget _buildListItem(BuildContext context, int index, List<T> visibleItems) {
    if (index == 0) {
      return _buildHeader();
    }

    final item = visibleItems[index - 1];
    return widget.itemBuilder(context, item);
  }

  Widget _buildListView() {
    final visibleItems = _calculateFilteredItems();

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: visibleItems.length + 1,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) =>
          _buildListItem(context, index, visibleItems),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _buildListView();
    if (widget.onRefresh == null) {
      return list;
    }

    return RefreshIndicator(onRefresh: widget.onRefresh!, child: list);
  }
}
