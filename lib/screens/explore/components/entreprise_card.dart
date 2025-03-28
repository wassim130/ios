import 'package:ahmini/theme.dart';
import 'package:flutter/material.dart';

import '../../../models/company.dart';

class EntrepriseCard extends StatelessWidget {
  final CompanyModel company;
  const EntrepriseCard({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: company.mine ? secondaryColor.withValues(alpha: 0.5) : backgroundColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(15),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: secondaryColor,
          child: Icon(
            Icons.business,
            color: primaryColor,
          ),
        ),
        title: Text(
          company.companyName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5),
            Text('Recherche: Développeur Web Frontend'),
            SizedBox(height: 5),
            if (company.productsList.isNotEmpty)
              Wrap(
                spacing: 5,
                children: [
                  Chip(
                    label: Text(company.productsList.first.title),
                    backgroundColor: secondaryColor,
                    labelStyle: TextStyle(
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/entreprise/home',
                arguments: {'companyID': company.id});
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            'Voir plus',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
