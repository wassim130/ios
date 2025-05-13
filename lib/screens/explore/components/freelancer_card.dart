import 'package:ahmini/models/freelancer.dart';
import 'package:flutter/material.dart';

class FreelancerCard extends StatelessWidget {
  final FreelancerModel freelancer;
  final Color backgroundColor;
  final Color primaryColor;
  final Color secondaryColor;
  const FreelancerCard({
    super.key,
    required this.freelancer,
    required this.backgroundColor,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: backgroundColor,
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
            Icons.person,
            color: primaryColor,
          ),
        ),
        title: Text(
          // 'Freelancer ${index + 1}',
          freelancer.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5),
            ...freelancer.technologies
                .take(3)
                .map((technology) => Text(technology.name)),
            if (freelancer.technologies.length > 3) Text("..."),
            SizedBox(height: 5),
            Row(
              children: [
                Icon(
                  Icons.star,
                  size: 16,
                  color: Colors.amber,
                ),
                Text(' 4.8 (156 avis)'),
              ],
            ),
            SizedBox(height: 5),
            Wrap(
              spacing: 5,
              children: [
                Chip(
                  // label: Text(tools[index]!.name),
                  label: Text(freelancer.tools.isNotEmpty
                      ? freelancer.tools.first.name
                      : ""),
                  backgroundColor: secondaryColor,
                  labelStyle: TextStyle(
                    color: primaryColor,
                  ),
                ),
                if (freelancer.tools.length > 1)
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/freelancer_portfolio',
                          arguments: {'portfolioID': freelancer.id});
                    },
                    child: Chip(
                      label: Text("..."),
                      backgroundColor: secondaryColor,
                      labelStyle: TextStyle(
                        color: primaryColor,
                      ),
                    ),
                  ),

                // Chip(
                //   label: Text('Node.js'),
                //   backgroundColor: secondaryColor,
                // ),
              ],
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/freelancer_portfolio',
                arguments: {'portfolioID': freelancer.id});
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
