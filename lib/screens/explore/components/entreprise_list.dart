import 'package:ahmini/screens/explore/components/progress_indicator.dart';
import 'package:flutter/material.dart';

import '../../../models/company.dart';
import 'entreprise_card.dart';

class EntrepriseList extends StatefulWidget {
  const EntrepriseList({super.key});

  @override
  State<EntrepriseList> createState() => EntrepriseListState();
}

class EntrepriseListState extends State<EntrepriseList> {
  List<CompanyModel>? companies;
  int currentFilter = 0;
  String currentSearch = '';
  final ScrollController _scrollController = ScrollController();
  bool fetching = false;
  bool isLoading = false;
  bool isEndFetching = false;

  @override
  void initState() {
    super.initState();
    fetchCompanies();
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          !fetching &&
          !isEndFetching) {
        if (mounted) {
          setState(() {
            fetching = true;
          });
        }
        final newCompanies = await CompanyModel.fetchAll(
          filter: currentFilter,
          pagination: companies!.last.id,
          search: currentSearch,
        );
        if (newCompanies != null) {
          if (newCompanies.isEmpty) {
            isEndFetching = true;
          } else {
            for (var company in newCompanies) {
              if (!companies!.any(
                (element) => company.id == element.id,
              )) {
                companies!.add(company);
              }
            }
          }
        }
        if (mounted) {
          setState(() {
            fetching = false;
          });
        }
      }
    });
  }

  //removes the old list and get a new list from the backend
  Future<void> fetchCompanies({id, filter, pagination, search}) async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    filter = filter ?? currentFilter;
    search = search ?? currentSearch;
    final data = await CompanyModel.fetchAll(
      id: id,
      filter: filter,
      pagination: pagination,
      search: search,
    );
    companies = data ?? companies;
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async =>
          fetchCompanies(filter: currentFilter, search: currentSearch),
      child: companies == null
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                ListView.builder(
                  controller: _scrollController,
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(15),
                  itemCount: companies!.length,
                  itemBuilder: (context, index) {
                    return EntrepriseCard(
                      company: companies![index],
                    );
                  },
                ),
                // Only show the indicator when fetching or loading
                if (fetching || isLoading)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0, // This ensures it stays at the bottom
                    child: MovingLineIndicator(),
                  ),
              ],
            ),
    );
  }
}
