import "package:flutter/material.dart";

class FilterDefinition<T> {
  final String label;
  final bool Function(T item) predicate;

  const FilterDefinition({required this.label, required this.predicate});
}

/// Generic, reusable list with:
/// - search box
/// - filter chips
/// - optional pull-to-refresh
/// - custom itemBuilder
class SearchFilterList<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T item) searchText;
  final List<FilterDefinition<T>>
  filters; // excludes "All" (added automatically)
  final Widget Function(BuildContext context, T item) itemBuilder;
  final Future<void> Function()? onRefresh;

  /// 0 = All, 1..filters.length = specific filter
  final int initialFilterIndex;

  const SearchFilterList({
    super.key,
    required this.items,
    required this.searchText,
    required this.filters,
    required this.itemBuilder,
    this.onRefresh,
    this.initialFilterIndex = 0,
  });

  @override
  State<SearchFilterList<T>> createState() => _SearchFilterListState<T>();
}

class _SearchFilterListState<T> extends State<SearchFilterList<T>> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  late int _activeFilterIndex; // 0 -> all

  @override
  void initState() {
    super.initState();
    _activeFilterIndex = widget.initialFilterIndex.clamp(
      0,
      widget.filters.length,
    );
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void didUpdateWidget(covariant SearchFilterList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialFilterIndex != widget.initialFilterIndex) {
      _activeFilterIndex = widget.initialFilterIndex.clamp(
        0,
        widget.filters.length,
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<T> get _filteredItems {
    final q = _searchQuery.trim().toLowerCase();

    bool Function(T item) activePredicate;
    if (_activeFilterIndex == 0) {
      activePredicate = (_) => true; // All
    } else {
      activePredicate = widget.filters[_activeFilterIndex - 1].predicate;
    }

    return widget.items.where((item) {
      if (!activePredicate(item)) return false;
      if (q.isEmpty) return true;
      return widget.searchText(item).toLowerCase().contains(q);
    }).toList();
  }

  Widget _buildChip(int index, String label) {
    final selected = _activeFilterIndex == index;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() => _activeFilterIndex = index);
      },
    );
  }

  Widget _buildFilterChips() {
    final chips = <Widget>[
      _buildChip(0, "All"),
      for (var i = 0; i < widget.filters.length; i++)
        _buildChip(i + 1, widget.filters[i].label),
    ];
    return Wrap(spacing: 8, children: chips);
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
          _buildFilterChips(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final visibleItems = _filteredItems;

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: visibleItems.length + 1,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        if (index == 0) return _buildHeader();
        final item = visibleItems[index - 1];
        return widget.itemBuilder(context, item);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _buildBody();
    if (widget.onRefresh == null) return list;

    return RefreshIndicator(onRefresh: widget.onRefresh!, child: list);
  }
}
