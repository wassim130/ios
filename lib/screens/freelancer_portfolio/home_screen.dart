// // import 'package:ahmini/screens/portfolio/aboutme.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// // import 'constants.dart';
// import 'package:url_launcher/url_launcher.dart';

// class PortfolioPage extends StatelessWidget {
//   const PortfolioPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: primaryColor,
//       appBar: AppBar(
//         backgroundColor: primaryColor,
//         elevation: 0,
//         leading: IconButton(
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           icon: Icon(Icons.arrow_back_ios, color: Colors.white),
//         ),
//         title: Text(
//           'portfolio'.tr,
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.help_outline, color: Colors.white),
//             onPressed: () {
//               showDialog(
//                 context: context,
//                 builder: (context) => AlertDialog(
//                   title: Text('aide'.tr),
//                   content: Text('aide_portfolio'.tr),
//                   actions: [
//                     TextButton(
//                       onPressed: () => Navigator.pop(context),
//                       child: Text('fermer'.tr),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // Profile Header Section with Animated Background
//             Container(
//               width: double.infinity,
//               height: 300,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topRight,
//                   end: Alignment.bottomLeft,
//                   colors: [
//                     primaryColor,
//                     primaryColor,
//                   ],
//                 ),
//               ),
//               child: Stack(
//                 children: [
//                   // Animated Design Elements

//                   // Profile Content
//                   Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Stack(
//                           children: [
//                             Container(
//                               width: 120,
//                               height: 120,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 border:
//                                 Border.all(color: Colors.white, width: 3),
//                                 image: DecorationImage(
//                                   image: AssetImage(imagePath),
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                             ),
//                             Positioned(
//                               bottom: 0,
//                               right: 0,
//                               child: Container(
//                                 padding: EdgeInsets.all(4),
//                                 decoration: BoxDecoration(
//                                   color: Colors.green,
//                                   shape: BoxShape.circle,
//                                   border:
//                                   Border.all(color: Colors.white, width: 2),
//                                 ),
//                                 child: Icon(Icons.check,
//                                     size: 16, color: Colors.white),
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 15),
//                         Text(
//                           name,
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         Text(
//                           "@$username",
//                           style: TextStyle(
//                             color: Colors.white.withOpacity(0.9),
//                             fontSize: 16,
//                           ),
//                         ),
//                         SizedBox(height: 15),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             _buildStatCard('projets'.tr, '12'.tr),
//                             _buildStatCard('clients'.tr, '25'.tr),
//                             _buildStatCard('evaluation'.tr, '4.9'.tr),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Main Content
//             Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(30),
//                   topRight: Radius.circular(30),
//                 ),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Quick Actions
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                       children: [
//                         _buildActionButton(
//                           icon: Icons.description_outlined,
//                           label: 'cv'.tr,
//                           onTap: () async {
//                             final Uri url = Uri.parse(resumeLink);
//                             await launchUrl(url);
//                           },
//                         ),
//                         _buildActionButton(
//                           icon: Icons.mail_outline,
//                           label: 'contact'.tr,
//                           onTap: () async {
//                             final Uri emailLaunchUri = Uri(
//                               scheme: 'mailto'.tr,
//                               path: contactEmail,
//                             );
//                             await launchUrl(emailLaunchUri);
//                           },
//                         ),
//                         _buildActionButton(
//                           icon: Icons.work_outline,
//                           label: 'projets'.tr,
//                           onTap: () {},
//                         ),
//                       ],
//                     ),

//                     SizedBox(height: 25),

//                     // Experience Section
//                     _buildSection(
//                       title: 'experience'.tr,
//                       content: aboutWorkExperience,
//                       icon: Icons.work,
//                     ),

//                     // About Me Section
//                     _buildSection(
//                       title: 'a propos de moi'.tr,
//                       content: aboutMeSummary,
//                       icon: Icons.person,
//                     ),

//                     // Contact Information Card
//                     Card(
//                       elevation: 3,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(20),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             _buildContactRow(Icons.location_on, location),
//                             SizedBox(height: 10),
//                             _buildContactRow(Icons.language, website),
//                             SizedBox(height: 10),
//                             _buildContactRow(Icons.work, portfolio),
//                             SizedBox(height: 10),
//                             _buildContactRow(Icons.email, email),
//                           ],
//                         ),
//                       ),
//                     ),

//                     SizedBox(height: 25),

//                     // Projects Grid
//                     Text(
//                       'projets_recents'.tr,
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     SizedBox(height: 15),
//                     GridView.builder(
//                       shrinkWrap: true,
//                       physics: NeverScrollableScrollPhysics(),
//                       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 2,
//                         childAspectRatio: 0.8,
//                         crossAxisSpacing: 15,
//                         mainAxisSpacing: 15,
//                       ),
//                       itemCount: projectList.length,
//                       itemBuilder: (context, index) {
//                         return _buildProjectCard(projectList[index].toMap());
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatCard(String label, String value) {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 10),
//       padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.2),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Column(
//         children: [
//           Text(
//             value,
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           Text(
//             label,
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 14,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionButton({
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         width: 100,
//         padding: EdgeInsets.all(15),
//         decoration: BoxDecoration(
//           color: secondaryColor,
//           borderRadius: BorderRadius.circular(15),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, size: 24),
//             SizedBox(height: 8),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSection({
//     required String title,
//     required String content,
//     required IconData icon,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Icon(icon, color: primaryColor),
//             SizedBox(width: 10),
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 10),
//         Text(
//           content,
//           style: TextStyle(
//             fontSize: 16,
//             color: Colors.black87,
//             height: 1.5,
//           ),
//         ),
//         SizedBox(height: 25),
//       ],
//     );
//   }

//   Widget _buildContactRow(IconData icon, String text) {
//     return Row(
//       children: [
//         Container(
//           padding: EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: secondaryColor,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Icon(icon, size: 20),
//         ),
//         SizedBox(width: 15),
//         Expanded(
//           child: Text(
//             text,
//             style: TextStyle(fontSize: 16),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildProjectCard(Map<String, dynamic> project) {
//     return Container(
//       decoration: BoxDecoration(
//         color: secondaryColor,
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
//             child: Image.network(
//               project['image'],
//               height: 100,
//               width: double.infinity,
//               fit: BoxFit.cover,
//               errorBuilder: (context, error, stackTrace) {
//                 return Image.asset(
//                   'assets/images/352688797_1199166850770091_2962373362408828409_n.jpg'.tr,
//                   height: 100,
//                   width: double.infinity,
//                   fit: BoxFit.cover,
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   project['title'],
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: 5),
//                 Text(
//                   project['description'],
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 SizedBox(height: 8),
//                 Wrap(
//                   spacing: 5,
//                   children: (project['technologies'] as List<String>)
//                       .map((tech) => Chip(
//                     label: Text(
//                       tech,
//                       style: TextStyle(fontSize: 10),
//                     ),
//                     padding: EdgeInsets.zero,
//                     materialTapTargetSize:
//                     MaterialTapTargetSize.shrinkWrap,
//                   ))
//                       .toList(),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

