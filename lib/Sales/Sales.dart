import 'package:burmapartner/Api/Api.dart';
import 'package:burmapartner/Common/UrlPath.dart';
import 'package:burmapartner/Dashboard/HomePage.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../Common/colors.dart' as custom_color;

class Sales extends StatefulWidget {
  const Sales({super.key});

  @override
  State<Sales> createState() => _SalesState();
}

class _SalesState extends State<Sales> {
  final LocalStorage storage = new LocalStorage('app_store');
 
  late SharedPreferences pref;
  var userResponse;
  var accesstoken;
  var customer_id;
  bool isLoading = false;
  List sales_list = [];
  String selectedReport = "today"; 


  double totalSales = 0;
  List chartData = [];

  int limit = 10;
  int offset = 0;
  bool isMoreLoading = false;
  bool hasMoreData = true;
  List leaderboard_list = [];
  @override
  void initState() {
    super.initState();
    initPreferences();
  }

  initPreferences() async {
    pref = await SharedPreferences.getInstance();
    await storage.ready;
    userResponse = await storage.getItem('userResponse');
    
    if (userResponse != null) {
      accesstoken = userResponse['api_token'];
      customer_id = userResponse['customer_id'].toString();
    }
    await getSalesReport();
    await getLeaderBoard();
    setState(() {});
  }

 Future<void> getSalesReport({bool isLoadMore = false}) async {
 
    setState(() => isLoading = true);

  var data = {
    "action": "get_product_report",
    "accesskey": "90336",
    "token": accesstoken,
    "customer_id": customer_id,
    "act_type": userResponse['act_type'],
    "report" : selectedReport,
   
  };

  final response = await Api().getSalesReport(data);

    if(response != null){
      sales_list = response['res'] ?? [];
      totalSales = 0;
  chartData.clear();

  for (var item in sales_list) {

    /// 🔥 SAFE PARSING
    double amount = double.tryParse(item['final_amt'].toString()) ?? 0;
    int qty = int.tryParse(item['sum_of_qty'].toString()) ?? 0;

    totalSales += amount;

    chartData.add({
      "name": item['product_name'] ?? "",
      "value": amount,
      "qty": qty,
    });
  }
    setState(() => isLoading = false);
    }else{
      sales_list = [];
    }

  setState(() {
    isLoading = false;
    
  });
}


 Future<void> getLeaderBoard({bool isLoadMore = false}) async {
  if (isLoadMore) {
    setState(() => isMoreLoading = true);
  } else {
    setState(() => isLoading = true);
  }

  var data = {
    "action": "dist_leader_board",
    "accesskey": "90336",
    "token": accesstoken,
    "customer_id": customer_id,
    "act_type": userResponse['act_type'],
    "limit": limit.toString(),
    "offset": offset.toString()
  };

  final response = await Api().getLeaderBoard(data);

  if (response != null && response['res'] != null) {
    List newData = response['res'];

    if (newData.length < limit) {
      hasMoreData = false; // no more data
    }

    if (isLoadMore) {
      leaderboard_list.addAll(newData);
    } else {
      leaderboard_list = newData;
    }
  }

  setState(() {
    isLoading = false;
    isMoreLoading = false;
  });
}
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>Homepage()));
      },
      child: Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),
          appBar: AppBar(
            backgroundColor: custom_color.app_color,
            elevation: 0,
            title: const Text("Sales Reports",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Homepage()));
              },
            ),
          ),

  body: SafeArea(
    child: Column(
      children: [
        SizedBox(height: sh * 0.02),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: sw * 0.02),
          child: Row(
            children: [
              buildFilter("today", "Today"),
              buildFilter("weekly", "Week"),
              buildFilter("monthly", "Month"),
              buildFilter("yearly", "Year"),
            ],
          ),
        ),
        SizedBox(height: sh * 0.02),
    
        // 🔥 CONTENT
        Expanded(
          child: isLoading
              ? _buildShimmer()
              : sales_list.isEmpty
                  ? buildEmptyUI()
                  // : ListView.builder(
                  //     itemCount: sales_list.length,
                  //     itemBuilder: (context, index) {
                  //       var item = sales_list[index];
                  //       // return buildSalesCard(item);
                  //        return GestureDetector(
                  //         onTap: () {
                  //           print("Clicked item index: $index");
                  //           print("Product: ${item['product_name']}");
                  //         },
                  //         child: buildSalesCard(item),
                  //       );
                  //     },
                  //   ),
                  :SingleChildScrollView(
                    child: Column(
                      children: [
                        /// 📊 CHART
                        buildChart(),
                  
                        /// 🏆 LEADERBOARD (STATIC or API later)
                        buildLeaderboard(),
                  
                        /// 📦 PRODUCTS
                        ListView.builder(
                          itemCount: sales_list.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return buildProductCard(sales_list[index]);
                          },
                        ),
                      ],
                    ),
                  ),
        ),
      ],
    ),
  ),
  bottomNavigationBar: (!isLoading && sales_list.isNotEmpty)
    ? SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: sw * 0.04,
            vertical: sh * 0.016,
          ),
          decoration: BoxDecoration(
            color: custom_color.app_color,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: Offset(0, -2),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.bar_chart, color: Colors.white70, size: sw * 0.05),
                  SizedBox(width: sw * 0.02),
                  Text("Total Sales",
                      style: TextStyle(color: Colors.white70, fontSize: sw * 0.038)),
                ],
              ),
              Text("Rs.${totalSales.toStringAsFixed(0)}",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: sw * 0.045,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      )
    : null,
),
      );
  }
  Widget _buildShimmer() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sw = constraints.maxWidth;
        final sh = MediaQuery.of(context).size.height;
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sh * 0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chart skeleton
                Container(
                  width: double.infinity,
                  height: sh * 0.25,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                SizedBox(height: sh * 0.02),
                // Leaderboard title
                Container(width: sw * 0.35, height: sh * 0.022, color: Colors.white),
                SizedBox(height: sh * 0.015),
                // Leaderboard cards
                ...List.generate(3, (_) => Container(
                  margin: EdgeInsets.only(bottom: sh * 0.015),
                  padding: EdgeInsets.all(sw * 0.04),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(width: sw * 0.08, height: sw * 0.08, color: Colors.white),
                      SizedBox(width: sw * 0.03),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(width: sw * 0.12, height: sh * 0.014, color: Colors.white),
                          SizedBox(height: sh * 0.008),
                          Container(width: sw * 0.08, height: sh * 0.018, color: Colors.white),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(width: sw * 0.28, height: sh * 0.018, color: Colors.white),
                          SizedBox(height: sh * 0.008),
                          Container(width: sw * 0.2, height: sh * 0.014, color: Colors.white),
                          SizedBox(height: sh * 0.008),
                          Container(width: sw * 0.15, height: sh * 0.016, color: Colors.white),
                        ],
                      ),
                    ],
                  ),
                )),
                SizedBox(height: sh * 0.01),
                // Product cards
                ...List.generate(4, (_) => Container(
                  margin: EdgeInsets.only(bottom: sh * 0.015),
                  padding: EdgeInsets.all(sw * 0.03),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: sw * 0.14,
                        height: sw * 0.14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      SizedBox(width: sw * 0.03),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(width: double.infinity, height: sh * 0.018, color: Colors.white),
                            SizedBox(height: sh * 0.008),
                            Container(width: sw * 0.3, height: sh * 0.014, color: Colors.white),
                          ],
                        ),
                      ),
                      SizedBox(width: sw * 0.03),
                      Container(width: sw * 0.15, height: sh * 0.02, color: Colors.white),
                    ],
                  ),
                )),
              ],
            ),
          ),
        );
      },
    );
  }

Widget buildFilter(String value, String label) {
  final sw = MediaQuery.of(context).size.width;
  final sh = MediaQuery.of(context).size.height;
  bool isSelected = selectedReport == value;
  return GestureDetector(
    onTap: () {
      setState(() => selectedReport = value);
      getSalesReport();
      getLeaderBoard();
    },
    child: Container(
      margin: EdgeInsets.symmetric(horizontal: sw * 0.02),
      padding: EdgeInsets.symmetric(horizontal: sw * 0.05, vertical: sh * 0.015),
      decoration: BoxDecoration(
        color: isSelected ? custom_color.app_color : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.calendar_today,
              size: sw * 0.055,
              color: isSelected ? Colors.white : custom_color.app_color),
          SizedBox(height: sh * 0.005),
          Text(label,
              style: TextStyle(
                fontSize: sw * 0.035,
                color: isSelected ? Colors.white : custom_color.app_color,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    ),
  );
}
Widget buildEmptyUI() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          "assets/images/AppLogo.png",
          width: 200,
          height: 70,
        ),
        const SizedBox(height: 20),
         Text(
          "No Sales found",
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: Colors.green),
        ),
      ],
    ),
  );
}

Widget buildSalesCard(dynamic item) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 6,
        )
      ],
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            item['product_name'] ?? "",
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text("Qty : ${item['sum_of_qty']}"),
            Text("₹${item['final_amt']}"),
          ],
        )
      ],
    ),
  );
}


Widget buildChart() {
  if (chartData.isEmpty) return SizedBox();

  double maxY = chartData
      .map((e) => e['value'] as double)
      .reduce((a, b) => a > b ? a : b);

  return Container(
    height: 250,
    padding: EdgeInsets.all(16),
    child: BarChart(
      BarChartData(
        maxY: maxY + (maxY * 0.2),

        /// 🔥 GRID LINES (LIKE IMAGE)
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.shade300,
              strokeWidth: 1,
            );
          },
        ),

        /// 🔥 REMOVE BORDER
        borderData: FlBorderData(show: false),

        /// 🔥 X AXIS (PRODUCT NAME)
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= chartData.length) return SizedBox();

                return Text(
                  chartData[index]['name'],
                  style: TextStyle(fontSize: 10),
                );
              },
            ),
          ),

          /// 🔥 Y AXIS VALUES
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(fontSize: 10),
                );
              },
            ),
          ),

          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),

        /// 🔥 BAR DATA
        barGroups: List.generate(chartData.length, (index) {
          var item = chartData[index];

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: item['value'],
                width: 30,
                borderRadius: BorderRadius.circular(6),
                color: Colors.primaries[index % Colors.primaries.length],
              ),
            ],
          );
        }),
      ),
    ),
  );
}

Widget buildLeaderboard() {
  if (leaderboard_list.isEmpty) return SizedBox();

  return Padding(
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Leaderboard",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

        SizedBox(height: 10),

        /// 🔥 DYNAMIC LIST
        ListView.builder(
          itemCount: leaderboard_list.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            var item = leaderboard_list[index];

            /// 🏆 RANK TEXT
            String rankText = "${item['rank']}";

            /// 🎨 COLOR BASED ON RANK
            Color color;
            if (item['rank'] == 1) {
              color = Colors.orange;
            } else if (item['rank'] == 2) {
              color = Colors.grey;
            } else {
              color = Colors.brown;
            }

            return buildLeaderCard(
              rankText,
              item['name'] ?? "",
              item['district'] ?? "",
              item['final_amt'] ?? "0",
              color,
            );
          },
        ),
      ],
    ),
  );
}
Widget buildLeaderCard(
    String rank,
    String name,
    String district,
    String amount,
    Color color) {
  return Container(
    margin: EdgeInsets.symmetric(vertical: 8),
    padding: EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 6,
          offset: Offset(0, 2),
        )
      ],
    ),
    child: Row(
      children: [

        /// 👑 ICON
        Icon(Icons.emoji_events, color: color, size: 30),

        SizedBox(width: 12),

        /// 🔥 RANK TEXT
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Rank",
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text(rank,
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),

        Spacer(),

        /// 🔥 NAME + DISTRICT + AMOUNT
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(name,
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold)),

            Text(district,
                style: TextStyle(color: Colors.grey)),

            Text("₹$amount",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: custom_color.app_color)),
          ],
        ),
      ],
    ),
  );
}
Widget buildLeader(String rank, String name, String city, Color color) {
  return Container(
    margin: EdgeInsets.symmetric(vertical: 8),
    padding: EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 6,
          offset: Offset(0, 2),
        )
      ],
    ),
    child: Row(
      children: [

        /// 👑 ICON
        Icon(Icons.emoji_events, color: color, size: 30),

        SizedBox(width: 12),

        /// RANK
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Rank",
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text(rank,
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),

        Spacer(),

        /// NAME + CITY
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(name,
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold)),
            Text(city,
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      ],
    ),
  );
}
Widget buildProductCard(dynamic item) {
  final sw = MediaQuery.of(context).size.width;
  final sh = MediaQuery.of(context).size.height;
  return Container(
    margin: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sh * 0.01),
    padding: EdgeInsets.all(sw * 0.03),
    decoration: BoxDecoration(
      border: Border.all(color: custom_color.app_color),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Container(
          width: sw * 0.14,
          height: sw * 0.14,
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.image),
        ),
        SizedBox(width: sw * 0.03),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item['product_name'] ?? "",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: sw * 0.04)),
              Text("No. of Pads : ${item['sum_of_qty']}",
                  style: TextStyle(fontSize: sw * 0.033)),
            ],
          ),
        ),
        Text("₹${item['final_amt']}",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: sw * 0.04)),
      ],
    ),
  );
}
}