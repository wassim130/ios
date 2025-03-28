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

  @override
  void initState() {
    super.initState();
    fetchCompanies();
  }

  void fetchCompanies({id, filter}) async {
    final data = await CompanyModel.fetchAll(id, filter);
    companies = data ?? companies;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => fetchCompanies(),
      child: companies == null
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(15),
              itemCount: companies!.length,
              itemBuilder: (context, index) {
                return EntrepriseCard(
                  company: companies![index],
                );
              },
            ),
    );
  }
}
