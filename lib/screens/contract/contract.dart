import 'package:ahmini/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/theme_controller.dart';
import '../../models/contract.dart';

class ContractPage extends StatefulWidget {
  const ContractPage({super.key});

  @override
  State<ContractPage> createState() => _ContractPageState();
}

class _ContractPageState extends State<ContractPage> {
  List<Contract>? contracts;
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  void initState() {
    super.initState();
    _fetchContracts();
  }

  Future<void> _fetchContracts() async {
    try {
      contracts = await Contract.fetchAll();
      setState(() {});
    } catch (error) {
      //idk something
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeController.isDarkMode.value;
      final primaryColorTheme = isDark ? darkPrimaryColor : primaryColor;
      final secondaryColorTheme = isDark ? darkSecondaryColor : secondaryColor;
      final backgroundColorTheme = isDark ? darkBackgroundColor : backgroundColor;
      final textColor = isDark ? Colors.white : Colors.black;
      final textColorSecondary = isDark ? Colors.white70 : Colors.black54;

      return Theme(
        data: ThemeData(
          fontFamily: "Poppins",
        ),
        child: Scaffold(
          backgroundColor: primaryColorTheme,
          appBar: AppBar(
            backgroundColor: primaryColorTheme,
            elevation: 0,
            title: Text('Contrats'.tr,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                )),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              contracts = null;
              setState(() {});
              _fetchContracts();
            },
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text(
                      'Contrats Actifs'.tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      itemCount: contracts != null ? contracts!.length : 0,
                      itemBuilder: (context, index) {
                        return SmallContract(
                          contract: contracts![index],
                          isDark: isDark,
                          primaryColorTheme: primaryColorTheme,
                          secondaryColorTheme: secondaryColorTheme,
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: backgroundColorTheme,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                    ),
                    child: contracts != null
                        ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tous les Contrats'.tr,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: 15),
                        ...contracts!.map(
                                (contract) => ContractBox(
                              contract: contract,
                              isDark: isDark,
                              primaryColorTheme: primaryColorTheme,
                              secondaryColorTheme: secondaryColorTheme,
                            ))
                      ],
                    )
                        : Center(
                        child: CircularProgressIndicator(
                          color: primaryColorTheme,
                        )),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

class SmallContract extends StatelessWidget {
  final Contract contract;
  final bool isDark;
  final Color primaryColorTheme;
  final Color secondaryColorTheme;

  const SmallContract({
    super.key,
    required this.contract,
    required this.isDark,
    required this.primaryColorTheme,
    required this.secondaryColorTheme,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : Colors.black;
    final textColorSecondary = isDark ? Colors.white70 : Colors.black54;

    return Container(
      width: 250,
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: secondaryColorTheme,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  contract.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: contract.status ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  contract.status ? "Actif" : "Inactif",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat.yMMMM().format(contract.date),
                style: TextStyle(color: textColorSecondary),
              ),
              Text(
                "${contract.amount} Da",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: contract.progress,
              backgroundColor: isDark ? Colors.grey[700] : Colors.white,
              valueColor: AlwaysStoppedAnimation<Color>(
                primaryColorTheme,
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class ContractBox extends StatelessWidget {
  final Contract contract;
  final bool isDark;
  final Color primaryColorTheme;
  final Color secondaryColorTheme;

  const ContractBox({
    super.key,
    required this.contract,
    required this.isDark,
    required this.primaryColorTheme,
    required this.secondaryColorTheme,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? Colors.grey[800] : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final textColorSecondary = isDark ? Colors.white70 : Colors.black54;
    final borderColor = isDark ? Colors.grey[700] : Colors.grey.withOpacity(0.2);

    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: borderColor!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  contract.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: secondaryColorTheme,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  DateFormat.yMMMd().format(contract.date),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.person,
                    color: primaryColorTheme,
                    size: 20,
                  ),
                  SizedBox(width: 5),
                  Text(
                    contract.client,
                    style: TextStyle(color: textColorSecondary),
                  ),
                ],
              ),
              SizedBox(width: 20),
              Row(
                children: [
                  Icon(
                    Icons.attach_money,
                    color: primaryColorTheme,
                    size: 20,
                  ),
                  SizedBox(width: 5),
                  Text(
                    "${contract.amount} Da",
                    style: TextStyle(color: textColorSecondary),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  backgroundColor: primaryColorTheme,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Voir plus",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

