import 'package:ahmini/screens/explore/components/entreprise_list.dart';
import 'package:ahmini/theme.dart';
import 'package:flutter/material.dart';
import '../../../models/technologies.dart';

class Filter extends StatefulWidget {
  final listKey;
  final bool isEnterprise;
  const Filter({super.key, required this.listKey, this.isEnterprise = false});

  @override
  State<Filter> createState() => _FilterState();
}

class _FilterState extends State<Filter> {
  TechnologyModel? selectedFilter;
  List<TechnologyModel> filters = [TechnologyModel(id: 0, name: 'Tous')];
  bool isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchFilters();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _fetchFilters() async {
    if (isLoading) return;
    isLoading = true;

    List<TechnologyModel> newFilters =
        await TechnologyModel.fetchAll(filters.last.id);
    for (var filter in newFilters) {
      if (!filters.any((f) => filter.id == f.id)) {
        filters.add(filter);
      }
    }
    isLoading = false;
    if (mounted) {
      setState(() {});
    }
  }

  void _onScroll() {
    if (_scrollController.position.maxScrollExtent -
            _scrollController.position.pixels <=
        50) {
      _fetchFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 15),
        itemCount:
            filters.length + (isLoading ? 1 : 0), // Show loader if fetching
        itemBuilder: (context, index) {
          if (index == filters.length) {
            return Center();
          }

          final filter = filters.elementAt(index);
          return Container(
            margin: EdgeInsets.only(right: 10),
            child: FilterChip(
              selected: selectedFilter == filter,
              label: Text(filter.name),
              onSelected: (selected) {
                setState(() {
                  selectedFilter = filter;
                  if (!widget.isEnterprise) {
                    widget.listKey.currentState
                        ?.fetchCompanies(filter: filter.id);
                  } else {
                    widget.listKey.currentState
                        ?.fetchFreeLancers(filter: filter.id);
                  }
                });
              },
              backgroundColor: Colors.white,
              selectedColor: secondaryColor,
              labelStyle: TextStyle(
                color: selectedFilter == filter
                    ? primaryColor
                    : Colors.black54,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: selectedFilter == filter
                      ? primaryColor
                      : Colors.grey.shade300,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
