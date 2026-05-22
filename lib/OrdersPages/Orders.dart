
// import 'package:burmapartner/Dashboard/Dashboard.dart';
// import 'package:burmapartner/Dashboard/HomePage.dart';
// import 'package:burmapartner/OrdersPages/OrderDetailsPage.dart';
// import 'package:burmapartner/OrdersPages/OrdersApi.dart';
// import 'package:flutter/material.dart';
// import 'package:localstorage/localstorage.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:shimmer/shimmer.dart';
// import '../Common/colors.dart' as custom_color;

// class Orders extends StatefulWidget {
//   const Orders({super.key});

//   @override
//   State<Orders> createState() => _OrdersState();
// }

// class _OrdersState extends State<Orders> {

//   final LocalStorage storage = LocalStorage('app_store');

//   late SharedPreferences pref;

//   bool isLoading = false;
//   var userResponse;
//   var accesstoken;
//   var customer_id;

//   List orders_list = [];

//   String selectedTab = "All";

//   @override
//   void initState() {
//     super.initState();
//     initPreferencess();
//   }

//   initPreferencess() async {

//     await storage.ready;

//     pref = await SharedPreferences.getInstance();

//     userResponse = await storage.getItem('userResponse');

//     if (userResponse != null) {

//       accesstoken = userResponse['api_token'];

//       customer_id = userResponse['customer_id'].toString();
//     }

//     await getOrders();
//   }

//   Future<void> getOrders() async {

//     setState(() => isLoading = true);

//     var data = {
//       "action": "get_orders",
//       "customer_id": customer_id,
//       "accesskey": "90336",
//       "act_type": userResponse['act_type'],
//       "token": accesstoken,
//     };

//     final response = await Ordersapi().getOrders(data);

//     if (response != null) {
//       orders_list = response['res'] ?? [];
//     }
//     setState(() => isLoading = false);
//   }

// List getFilteredOrders() {
//   if (selectedTab == "All") return orders_list;

//   return orders_list.where((order) {
//     String status = getStatusFromId(order['order_status_id']);

//     if (selectedTab == "In Process") {
//       return status == "Received" || status == "Processed";
//     }

//     if (selectedTab == "Shipped") {
//       return status == "Shipped";
//     }

//     if (selectedTab == "Delivered") {
//       return status == "Delivered";
//     }

//     if (selectedTab == "Cancelled") {
//       return status == "Cancelled";
//     }

//     return true;
//   }).toList();
// }
// String getStatusFromId(String id) {
//   switch (id) {
//     case "1":
//       return "Received";
//     case "2":
//       return "Processed";
//     case "3":
//       return "Shipped";
//     case "4":
//       return "Delivered";
//     case "5":
//       return "Cancelled";
//     case "7":
//       return "Delivered"; // based on your API
//     default:
//       return "Received";
//   }
// }
//   @override
//   Widget build(BuildContext context) {
    
//     double screenHeight = MediaQuery.of(context).size.height;
//     double screenWidth = MediaQuery.of(context).size.width;
// bool isStepDone(String current, String step) {
//   List flow = ["Received", "Processed", "Shipped", "Delivered"];

//   int currentIndex = flow.indexOf(current);
//   int stepIndex = flow.indexOf(step);

//   return currentIndex >= stepIndex;
// }

//     return PopScope(
//       canPop: false,
//       onPopInvoked: (didPop) {
//         Navigator.push(context,MaterialPageRoute(builder: (context) => Homepage()));
//       },
//       child: Scaffold(
      
//         appBar: AppBar(
//           backgroundColor: custom_color.app_color,
//           title: const Text("Track Order", style: TextStyle(color: Colors.white)),
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
//             onPressed: () {
//               // Navigator.push(context,
//               //     MaterialPageRoute(builder: (context) => Dashboard()));
//               Navigator.push(context,MaterialPageRoute(builder: (context) => Homepage()));
//             },
//           ),
//         ),
      
//         body: SafeArea(
//           child: isLoading ? _buildShimmer() : Column(
//             children: [
              
//               /// STATUS TABS
//               orderTabs(),
          
//               Expanded(
                
//                 child: getFilteredOrders().isEmpty
//                     ? Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Image.asset(
//                   "assets/images/AppLogo.png", // ✅ add image
//                   height: 120,
//                 ),
//                 const SizedBox(height: 15),
//                 const Text(
//                   "No Orders Found",
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.grey,
//                   ),
//                 ),
//                 const SizedBox(height: 5),
//                 const Text(
//                   "You haven’t placed any orders yet",
//                   style: TextStyle(
//                     fontSize: 13,
//                     color: Colors.grey,
//                   ),
//                 ),
//               ],
//             ),
//           )
//                     : ListView.builder(
          
//                   padding: const EdgeInsets.all(12),
          
//                   itemCount: getFilteredOrders().length,
          
//                   itemBuilder: (context, index) {
          
//                     var order = getFilteredOrders()[index];
//                     // var product = order['order_dtl'][0];
//                     var product = (order['order_dtl'] != null &&
//                         order['order_dtl'] is List &&
//                         order['order_dtl'].isNotEmpty)
//                     ? order['order_dtl'][0]
//                     : {};
//                     // String currentStatus =
//                     //     (product['order_status'] ?? "Received").toString();
//                     String currentStatus = getStatusFromId(order['order_status_id']);
          
//                     // Fix lowercase
//                     currentStatus =
//                         currentStatus[0].toUpperCase() + currentStatus.substring(1);
//                         double promo = double.tryParse(order['promo_disc_amt'].toString()) ?? 0;
//                         double wallet = double.tryParse(order['wallet_balance'].toString()) ?? 0;
//                     return Column(
//                       children: [
          
//                         /// ORDER CARD
//                         Card(
//                           color: Colors.white,
//                           elevation: 3,
          
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12)),
          
//                           child: Padding(
//                             padding: const EdgeInsets.all(12),
          
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
          
//                               children: [
          
//                                 /// HEADER
//                                 Row(
//                                   mainAxisAlignment:
//                                   MainAxisAlignment.spaceBetween,
          
//                                   children: [
          
//                                     Expanded(
//                                       child: Column(
//                                         crossAxisAlignment:
//                                         CrossAxisAlignment.start,
          
//                                         children: [
          
//                                           Text(
//                                             "Order ID : ${order['orders_id']}",
//                                             style: const TextStyle(
//                                                 fontWeight: FontWeight.bold),
//                                           ),
          
//                                           Text(
//                                             "Ordered Date : ${order['created_date']}",
//                                             style: const TextStyle(
//                                                 color: Colors.grey),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
          
//                                     ElevatedButton(
//                                       style: ElevatedButton.styleFrom(
//                                         backgroundColor:
//                                         custom_color.button_color,
//                                       ),
//                                       onPressed: () {
//                                         print(order);
//                                         Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (context) => Orderdetailspage(orderData: order),
//                                           ),
//                                         );
//                                       },
          
//                                       child: const Text("View Details",style: TextStyle(color: Colors.white),),
//                                     )
//                                   ],
//                                 ),
          
//                                 const Divider(height: 25),
          
//                                 /// PRODUCT ROW
//                                 Row(
//                                   children: [
          
//                                     ClipRRect(
//                                       borderRadius:
//                                       BorderRadius.circular(8),
          
//                                       //  child: safeNetworkImage(product['img'], fit: BoxFit.cover),
//                                        child: safeNetworkImage(
//                                         product['img'],
//                                         width: screenWidth * 0.22,
//                                         height: screenWidth * 0.22,
//                                         fit: BoxFit.contain,
//                                         borderRadius: 8,
//                                       ),
                                      
//                                     ),
          
//                                     SizedBox(width: 12),
          
//                                     Expanded(
//                                       child: Column(
//                                         crossAxisAlignment:
//                                         CrossAxisAlignment.start,
          
//                                         children: [
          
//                                           Text(
//                                             // product['name'],
//                                             product['name']?.toString() ?? "No Product",
//                                             style: const TextStyle(
//                                                 fontWeight: FontWeight.bold,
//                                                 fontSize: 15),
//                                           ),
          
//                                           const SizedBox(height: 4),
          
//                                           Text(
//                                               "Quantity : ${product['qty']}"),
          
//                                           const SizedBox(height: 4),
          
//                                           // Text(
//                                           //   "Rs.${order['final_amt']}",
//                                           //   style: const TextStyle(
//                                           //       fontWeight:
//                                           //       FontWeight.bold),
//                                           // ),
//                                           Text(
//                                             "Rs.${(order['order_dtl'] != null && order['order_dtl'].isNotEmpty) 
//                                                 ? order['order_dtl'][0]['discounted_price'] 
//                                                 : '0.00'}",
//                                             style: const TextStyle(
//                                               fontWeight: FontWeight.w600,
//                                             ),
//                                           ),
//                                       if (promo > 0)
//                                         Text("Promo: - Rs.$promo",
//                                             style: TextStyle(color: Colors.green, fontSize: 12)),
          
//                                       if (wallet > 0)
//                                         Text("Wallet: - Rs.$wallet",
//                                             style: TextStyle(color: Colors.green, fontSize: 12)),
//                                           const SizedBox(height: 4),
          
//                                           // Text(
//                                           //   // "Via Online Payment",
//                                           //   "${order['pay_type']}",
//                                           //   style: TextStyle(
//                                           //       color: custom_color.app_color,
//                                           //       fontWeight:
//                                           //       FontWeight.w600),
//                                           // ),
//                                             // Text(
//                                             //   "Via ${order['pay_type'].toString().substring(0,1).toUpperCase()}${order['pay_type'].toString().substring(1).toLowerCase()}",
//                                             //   style: TextStyle(
//                                             //     color: custom_color.app_color,
//                                             //     fontWeight: FontWeight.w600,
//                                             //   ),
//                                             // ),
//                                             Text(
//                                               "Via ${((order['pay_type'] ?? '').toString().isNotEmpty)
//                                                   ? "${order['pay_type'].toString()[0].toUpperCase()}${order['pay_type'].toString().substring(1).toLowerCase()}"
//                                                   : "-"}",
//                                               style: TextStyle(
//                                                 color: custom_color.app_color,
//                                                 fontWeight: FontWeight.w600,
//                                               ),
//                                             ),
//                                           const SizedBox(height: 4),
          
//                                           Row(
//                                             children: [
          
//                                               Text(
//                                                   "Payment Status : "),
//                                               Text(
//                                                 order['pay_status'],
//                                                 style: TextStyle(
//                                                   color: order['pay_status'] ==
//                                                       "Pending"
//                                                       ? Colors.red
//                                                       : Colors.green,
//                                                   fontWeight:
//                                                   FontWeight.bold,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
          
//                                           const SizedBox(height: 4),
          
//                                           Text(
//                                             // product['order_status'],
//                                             product['order_status']?.toString() ?? "",
//                                             style: const TextStyle(
//                                                 color: Colors.grey),
//                                           ),
//                                         ],
//                                       ),
//                                     )
//                                   ],
//                                 )
//                               ],
//                             ),
//                           ),
//                         ),
          
//                         /// TRACKING CARD
//                         Card(
//                           color: Colors.white,
//                           elevation: 2,
//                           margin: const EdgeInsets.only(bottom: 12),
          
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12)),
          
//                           child: Padding(
//                             padding: const EdgeInsets.all(12),
          
//                             child: Column(
//                               children: [
          
//                                     Row(
//                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         orderStep("Received", isStepDone(currentStatus, "Received")),
//                                         orderLine(),
//                                         orderStep("Processed", isStepDone(currentStatus, "Processed")),
//                                         orderLine(),
//                                         orderStep("Shipped", isStepDone(currentStatus, "Shipped")),
//                                         orderLine(),
//                                         orderStep("Delivered", isStepDone(currentStatus, "Delivered")),
          
//                                         if (currentStatus == "Cancelled") ...[
//                                           orderLine(),
//                                           orderStep("Cancelled", true),
//                                         ]
//                                       ],
//                                     ),
//                                 const SizedBox(height: 8),
          
//                                 Align(
//                                   alignment: Alignment.centerLeft,
          
//                                   child: Text(
//                                     order['created_date'],
//                                     style: const TextStyle(
//                                         color: Colors.grey),
//                                   ),
//                                 )
//                               ],
//                             ),
//                           ),
//                         )
//                       ],
//                     );
//                   },
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildShimmer() {
//     final screenWidth = MediaQuery.of(context).size.width;
//     return Shimmer.fromColors(
//       baseColor: Colors.grey[300]!,
//       highlightColor: Colors.grey[100]!,
//       child: SingleChildScrollView(
//         physics: const NeverScrollableScrollPhysics(),
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           children: List.generate(4, (_) => Padding(
//             padding: const EdgeInsets.only(bottom: 12),
//             child: Column(
//               children: [
//                 // Order card skeleton
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Container(width: 160, height: 14, color: Colors.white),
//                               const SizedBox(height: 6),
//                               Container(width: 120, height: 12, color: Colors.white),
//                             ],
//                           ),
//                           Container(width: 90, height: 34, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
//                         ],
//                       ),
//                       const SizedBox(height: 12),
//                       const Divider(height: 1),
//                       const SizedBox(height: 12),
//                       Row(
//                         children: [
//                           Container(width: screenWidth * .22, height: screenWidth * .22, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Container(width: double.infinity, height: 14, color: Colors.white),
//                                 const SizedBox(height: 6),
//                                 Container(width: 80, height: 12, color: Colors.white),
//                                 const SizedBox(height: 6),
//                                 Container(width: 60, height: 12, color: Colors.white),
//                                 const SizedBox(height: 6),
//                                 Container(width: 100, height: 12, color: Colors.white),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 // Tracking card skeleton
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: List.generate(4, (i) => Column(
//                       children: [
//                         Container(width: 22, height: 22, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
//                         const SizedBox(height: 4),
//                         Container(width: 50, height: 10, color: Colors.white),
//                       ],
//                     )),
//                   ),
//                 ),
//               ],
//             ),
//           )),
//         ),
//       ),
//     );
//   }

//   Widget orderStep(String title, bool done) {

//   bool isCancelled = title == "Cancelled";

//   return Column(
//     children: [

//       Container(
//         height: 22,
//         width: 22,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           border: Border.all(
//             color: isCancelled
//                 ? Colors.red
//                 : done
//                     ? Colors.teal
//                     : Colors.grey,
//             width: 2,
//           ),
//           color: isCancelled
//               ? Colors.red
//               : done
//                   ? Colors.teal
//                   : Colors.white,
//         ),
//       ),

//       const SizedBox(height: 4),

//       Text(
//         title,
//         style: TextStyle(
//           fontSize: 10,
//           color: isCancelled ? Colors.red : Colors.black,
//         ),
//       )
//     ],
//   );
// }
//   Widget orderLine() {
//     return Expanded(
//       child: Divider(color: Colors.grey.shade400, thickness: 1),
//     );
//   }

//   /// TOP TABS
//   Widget orderTabs() {

//     List tabs = ["All", "In Process", "Shipped", "Delivered", "Cancelled"];

//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: SizedBox(
//         height: 45,
      
//         child: ListView.builder(
      
//           scrollDirection: Axis.horizontal,
      
//           itemCount: tabs.length,
      
//           itemBuilder: (context, index) {
      
//             bool isSelected = selectedTab == tabs[index];
      
//             return GestureDetector(
//               onTap: () {
//                 setState(() {
//                   selectedTab = tabs[index];
//                 });
//               },
      
//               child: Container(
      
//                 margin: const EdgeInsets.symmetric(
//                     horizontal: 6, vertical: 8),
      
//                 padding:
//                 const EdgeInsets.symmetric(horizontal: 18),
      
//                 alignment: Alignment.center,
      
//                 decoration: BoxDecoration(
      
//                   color: isSelected
//                       ? custom_color.app_color
//                       : Colors.grey.shade300,
      
//                   borderRadius: BorderRadius.circular(20),
//                 ),
      
//                 child: Text(
//                   tabs[index],
      
//                   style: TextStyle(
//                     color: isSelected ? Colors.white : Colors.black,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

// //   Widget safeNetworkImage(
// //   String? url, {
// //   double? width,
// //   double? height,
// //   BoxFit fit = BoxFit.cover,
// //   double borderRadius = 0,
// // }) {
// //   double screenHeight = MediaQuery.of(context).size.height;
// //     double screenWidth = MediaQuery.of(context).size.width;
// //   // Fix double slashes in URL
// //   String cleanUrl = (url ?? "").replaceAll(RegExp(r'(?<!:)//+'), '/');
  
// //   // Check if URL is valid
// //   if (cleanUrl.isEmpty || !cleanUrl.startsWith('http')) {
// //     return SizedBox(
// //        width: screenWidth * .22,
// //          height: screenWidth * .22,
// //       child: Image.asset(
// //         "assets/images/AppLogo.png",
// //         // width: 90,
// //         // height: 90,
// //         // fit: BoxFit.contain,
// //          width: screenWidth * .22,
// //          height: screenWidth * .22,
// //          fit: BoxFit.cover,
// //       ),
// //     );
// //   }

// //   return ClipRRect(
// //     borderRadius: BorderRadius.circular(borderRadius),
// //     child: SizedBox(
// //        width: screenWidth * .22,
// //          height: screenWidth * .22,
// //       child: Image.network(
// //         cleanUrl,
// //         fit: fit,
// //         loadingBuilder: (context, child, loadingProgress) {
// //           if (loadingProgress == null) return child;
// //           return Center(
// //             child: Image.asset(
// //               "assets/images/AppLogo.png",
// //               width: screenWidth * .22,
// //          height: screenWidth * .22,
// //          fit: BoxFit.cover,
// //             ),
// //           );
// //         },
// //         errorBuilder: (context, error, stackTrace) {
// //           return SizedBox(
// //             width: width,
// //             height: height,
// //             child: Image.asset(
// //               "assets/images/AppLogo.png",
// //               width: screenWidth * .22,
// //          height: screenWidth * .22,
// //          fit: BoxFit.cover,
// //             ),
// //           );
// //         },
// //       ),
// //     ),
// //   );
// // }

// Widget safeNetworkImage(
//   String? url, {
//   double? width,
//   double? height,
//   BoxFit fit = BoxFit.cover,
//   double borderRadius = 0,
// }) {

//   // Fix double slashes in URL
//   String cleanUrl = (url ?? "").replaceAll(RegExp(r'(?<!:)//+'), '/');

//   // Default size
//   width ??= 90;
//   height ??= 90;

//   // Invalid URL
//   if (cleanUrl.isEmpty || !cleanUrl.startsWith('http')) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(borderRadius),
//       child: Image.asset(
//         "assets/images/AppLogo.png",
//         width: width,
//         height: height,
//         fit: fit,
//       ),
//     );
//   }

//   return ClipRRect(
//     borderRadius: BorderRadius.circular(borderRadius),
//     child: Image.network(
//       cleanUrl,
//       width: width,
//       height: height,
//       fit: fit,

//       loadingBuilder: (context, child, loadingProgress) {
//         if (loadingProgress == null) return child;

//         return Image.asset(
//           "assets/images/AppLogo.png",
//           width: width,
//           height: height,
//           fit: fit,
//         );
//       },

//       errorBuilder: (context, error, stackTrace) {
//         return Image.asset(
//           "assets/images/AppLogo.png",
//           width: width,
//           height: height,
//           fit: fit,
//         );
//       },
//     ),
//   );
// }
// }

import 'package:burmapartner/Dashboard/Dashboard.dart';
import 'package:burmapartner/Dashboard/HomePage.dart';
import 'package:burmapartner/OrdersPages/OrderDetailsPage.dart';
import 'package:burmapartner/OrdersPages/OrdersApi.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../Common/colors.dart' as custom_color;

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  final LocalStorage storage = LocalStorage('app_store');
  late SharedPreferences pref;

  bool isLoading = false;
  var userResponse;
  var accesstoken;
  var customer_id;

  List orders_list = [];
  String selectedTab = "All";

  @override
  void initState() {
    super.initState();
    initPreferencess();
  }

  initPreferencess() async {
    await storage.ready;
    pref = await SharedPreferences.getInstance();
    userResponse = await storage.getItem('userResponse');
    if (userResponse != null) {
      accesstoken = userResponse['api_token'];
      customer_id = userResponse['customer_id'].toString();
    }
    await getOrders();
  }

  Future<void> getOrders() async {
    setState(() => isLoading = true);
    var data = {
      "action": "get_orders",
      "customer_id": customer_id,
      "accesskey": "90336",
      "act_type": userResponse['act_type'],
      "token": accesstoken,
    };
    final response = await Ordersapi().getOrders(data);
    if (response != null) {
      orders_list = response['res'] ?? [];
    }
    setState(() => isLoading = false);
  }

  String getOrderStatus(order) {
    final statusList = order['status'];
    if (statusList != null && statusList is List && statusList.isNotEmpty) {
      final last = statusList.last;
      if (last is List && last.isNotEmpty) {
        final s = last[0].toString();
        return s[0].toUpperCase() + s.substring(1).toLowerCase();
      }
    }
    final dtl = order['order_dtl'];
    if (dtl != null && dtl is List && dtl.isNotEmpty) {
      return (dtl[0]['order_status'] ?? 'Received').toString();
    }
    return 'Received';
  }

  List getFilteredOrders() {
    if (selectedTab == "All") return orders_list;
    return orders_list.where((order) {
      String status = getOrderStatus(order);
      if (selectedTab == "In Process") return status == "Received" || status == "Processed";
      if (selectedTab == "Shipped") return status == "Shipped";
      if (selectedTab == "Delivered") return status == "Delivered";
      if (selectedTab == "Cancelled") return status == "Cancelled";
      if (selectedTab == "Returned") return status == "Returned";
      return true;
    }).toList();
  }

  bool isStepDone(String current, String step) {
    if (current == "Cancelled") return step == "Received";
    List flow = ["Received", "Processed", "Shipped", "Delivered", "Returned"];
    return flow.indexOf(current) >= flow.indexOf(step);
  }

  Color statusColor(String status) {
    switch (status) {
      case "Delivered": return Colors.green;
      case "Shipped": return Colors.blue;
      case "Processed": return Colors.orange;
      case "Cancelled": return Colors.red;
      case "Returned": return Colors.purple;
      default: return custom_color.app_color;
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => Homepage()));
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          backgroundColor: custom_color.app_color,
          title: const Text("My Orders", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Homepage())),
          ),
        ),
        body: SafeArea(
          child: isLoading
              ? _buildShimmer()
              : Column(
                  children: [
                    orderTabs(),
                    Expanded(
                      child: getFilteredOrders().isEmpty
                          ? _buildEmpty()
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                              itemCount: getFilteredOrders().length,
                              itemBuilder: (context, index) {
                                final order = getFilteredOrders()[index];
                                final String currentStatus = getOrderStatus(order);
                                final List dtl = (order['order_dtl'] as List? ?? []);
                                final double promo = double.tryParse(order['promo_disc_amt']?.toString() ?? '0') ?? 0;
                                final double wallet = double.tryParse(order['wallet_balance']?.toString() ?? '0') ?? 0;
                                final String payType = (order['pay_type'] ?? '').toString();
                                final String payStatus = (order['pay_status'] ?? '').toString();
                                final bool isCancelled = currentStatus == "Cancelled";

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.07),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      )
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      /// ── HEADER ──
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: custom_color.app_color.withOpacity(0.06),
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Order #${order['orders_id']}",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    color: custom_color.app_color,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  order['created_date']?.toString() ?? '',
                                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: statusColor(currentStatus).withOpacity(0.12),
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(color: statusColor(currentStatus).withOpacity(0.4)),
                                              ),
                                              child: Text(
                                                currentStatus,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: statusColor(currentStatus),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      /// ── PRODUCT LIST ──
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                                        child: Column(
                                          children: List.generate(dtl.length, (i) {
                                            final p = dtl[i];
                                            final bool isLast = i == dtl.length - 1;
                                            return Column(
                                              children: [
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    /// product image
                                                    Container(
                                                      width: w * 0.22,
                                                      height: w * 0.22,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey.shade100,
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(8),
                                                        child: safeNetworkImage(
                                                          p['img'],
                                                          width: w * 0.22,
                                                          height: w * 0.22,
                                                          fit: BoxFit.contain,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            p['name']?.toString() ?? '',
                                                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                                            maxLines: 2,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                          const SizedBox(height: 4),
                                                          Row(
                                                            children: [
                                                              _infoChip("Qty: ${p['qty']}"),
                                                              const SizedBox(width: 6),
                                                              _infoChip("₹${p['discounted_price']}", bold: true),
                                                            ],
                                                          ),
                                                          const SizedBox(height: 4),
                                                          Row(
                                                            children: [
                                                              Icon(Icons.circle, size: 8, color: statusColor(p['order_status']?.toString() ?? 'Received')),
                                                              const SizedBox(width: 4),
                                                              Text(
                                                                p['order_status']?.toString() ?? '',
                                                                style: TextStyle(
                                                                  fontSize: 11,
                                                                  color: statusColor(p['order_status']?.toString() ?? 'Received'),
                                                                  fontWeight: FontWeight.w500,
                                                                ),
                                                              ),
                                                              if (currentStatus == "Delivered" && p['is_returnable']?.toString() == "1") ...[  
                                                                const SizedBox(width: 6),
                                                                Container(
                                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                                  decoration: BoxDecoration(
                                                                    color: Colors.purple.shade50,
                                                                    borderRadius: BorderRadius.circular(6),
                                                                    border: Border.all(color: Colors.purple.shade200),
                                                                  ),
                                                                  child: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: const [
                                                                      Icon(Icons.assignment_return_outlined, size: 10, color: Colors.purple),
                                                                      SizedBox(width: 3),
                                                                      Text("Returnable", style: TextStyle(fontSize: 9, color: Colors.purple, fontWeight: FontWeight.bold)),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                if (!isLast)
                                                  Divider(height: 18, color: Colors.grey.shade200),
                                              ],
                                            );
                                          }),
                                        ),
                                      ),

                                      /// ── PAYMENT + PROMO ──
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                                        child: Row(
                                          children: [
                                            Icon(
                                              payType.toLowerCase() == 'wallet'
                                                  ? Icons.account_balance_wallet_outlined
                                                  : Icons.credit_card_outlined,
                                              size: 14,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              payType.isNotEmpty
                                                  ? "${payType[0].toUpperCase()}${payType.substring(1).toLowerCase()}"
                                                  : "-",
                                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                                            ),
                                            const SizedBox(width: 10),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: payStatus.toLowerCase() == 'pending'
                                                    ? Colors.red.shade50
                                                    : Colors.green.shade50,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                payStatus,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: payStatus.toLowerCase() == 'pending' ? Colors.red : Colors.green,
                                                ),
                                              ),
                                            ),
                                            const Spacer(),
                                            Text(
                                              "Total: ₹${order['final_amt']}",
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      ),

                                      if (promo > 0 || wallet > 0)
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(14, 4, 14, 0),
                                          child: Wrap(
                                            spacing: 8,
                                            children: [
                                              if (promo > 0)
                                                Text("Promo: ₹${order['promo_disc_amt']}", style: const TextStyle(color: Colors.green, fontSize: 11)),
                                              if (wallet > 0)
                                                Text("Wallet: ₹$wallet", style: const TextStyle(color: Colors.green, fontSize: 11)),
                                            ],
                                          ),
                                        ),

                                      /// ── TRACKER ──
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                                        child: _buildTracker(currentStatus),
                                      ),

                                      /// ── VIEW DETAILS BUTTON ──
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                                        child: SizedBox(
                                          width: double.infinity,
                                          child: OutlinedButton(
                                            style: OutlinedButton.styleFrom(
                                              side: BorderSide(color: custom_color.button_color),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              padding: const EdgeInsets.symmetric(vertical: 10),
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (_) => Orderdetailspage(orderData: order)),
                                              );
                                            },
                                            child: Text(
                                              "View Details",
                                              style: TextStyle(color: custom_color.button_color, fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _infoChip(String text, {bool bold = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: bold ? FontWeight.bold : FontWeight.normal, color: Colors.black87),
      ),
    );
  }

  Widget _buildTracker(String currentStatus) {
    final bool isCancelled = currentStatus == "Cancelled";
    final bool isReturned  = currentStatus == "Returned";
    final List<Map<String, dynamic>> steps = [
      {"label": "Received",  "icon": Icons.receipt_long_outlined,       "color": Colors.teal},
      {"label": "Processed", "icon": Icons.inventory_2_outlined,         "color": Colors.teal},
      {"label": "Shipped",   "icon": Icons.local_shipping_outlined,      "color": Colors.teal},
      {"label": "Delivered", "icon": Icons.check_circle_outline,         "color": Colors.teal},
      if (isCancelled) {"label": "Cancelled", "icon": Icons.cancel_outlined,            "color": Colors.red},
      if (isReturned)  {"label": "Returned",  "icon": Icons.assignment_return_outlined,  "color": Colors.purple},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final int nextIdx = (i + 1) ~/ 2;
          final bool lineActive = isStepDone(currentStatus, steps[nextIdx]["label"]);
          final bool isSpecialLine = (isCancelled || isReturned) && nextIdx == steps.length - 1;
          final Color specialColor = isCancelled ? Colors.red.shade300 : Colors.purple.shade300;
          return Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.only(bottom: 22, left: 2, right: 2),
              decoration: BoxDecoration(
                color: isSpecialLine ? specialColor : lineActive ? Colors.teal : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }
        final int si = i ~/ 2;
        final String label  = steps[si]["label"];
        final IconData icon = steps[si]["icon"];
        final Color stepColor = steps[si]["color"];
        final bool isSpecialStep = label == "Cancelled" || label == "Returned";
        final bool done = isSpecialStep ? true : isStepDone(currentStatus, label);

        return Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? stepColor : Colors.grey.shade300,
                boxShadow: done
                    ? [BoxShadow(color: stepColor.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))]
                    : [],
              ),
              child: Icon(icon, size: 16, color: done ? Colors.white : Colors.grey.shade500),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: done ? FontWeight.bold : FontWeight.normal,
                color: done ? stepColor : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/images/AppLogo.png", height: 110),
          const SizedBox(height: 16),
          const Text("No Orders Found", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(height: 4),
          const Text("You haven't placed any orders yet", style: TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget orderTabs() {
    final List tabs = ["All", "In Process", "Shipped", "Delivered", "Cancelled", "Returned"];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        height: 36,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          itemCount: tabs.length,
          itemBuilder: (context, index) {
            final bool isSelected = selectedTab == tabs[index];
            return GestureDetector(
              onTap: () => setState(() => selectedTab = tabs[index]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? custom_color.app_color : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? custom_color.app_color : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _shimmerBox({double? width, double? height, double radius = 10}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(radius)),
    );
  }

  Widget _buildShimmer() {
    final w = MediaQuery.of(context).size.width;
    return Shimmer.fromColors(
      baseColor: const Color(0xFFDDE4F0),
      highlightColor: const Color(0xFFEEF3FF),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: 4,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _shimmerBox(width: w * 0.3, height: 14, radius: 6),
                      const SizedBox(height: 6),
                      _shimmerBox(width: w * 0.25, height: 11, radius: 6),
                    ]),
                    _shimmerBox(width: 70, height: 24, radius: 12),
                  ],
                ),
                const SizedBox(height: 14),
                Row(children: [
                  _shimmerBox(width: w * 0.22, height: w * 0.22, radius: 8),
                  const SizedBox(width: 10),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _shimmerBox(width: w * 0.45, height: 13, radius: 6),
                    const SizedBox(height: 6),
                    _shimmerBox(width: w * 0.25, height: 11, radius: 6),
                  ]),
                ]),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(4, (_) => _shimmerBox(width: 20, height: 20, radius: 10)),
                ),
                const SizedBox(height: 12),
                _shimmerBox(width: double.infinity, height: 36, radius: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget safeNetworkImage(String? url, {double? width, double? height, BoxFit fit = BoxFit.cover, double borderRadius = 0}) {
    String cleanUrl = (url ?? "").replaceAll(RegExp(r'(?<!:)//+'), '/');
    width ??= 70;
    height ??= 70;
    if (cleanUrl.isEmpty || !cleanUrl.startsWith('http')) {
      return Image.asset("assets/images/AppLogo.png", width: width, height: height, fit: fit);
    }
    return Image.network(
      cleanUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (_, child, progress) => progress == null ? child : Image.asset("assets/images/AppLogo.png", width: width, height: height, fit: fit),
      errorBuilder: (_, __, ___) => Image.asset("assets/images/AppLogo.png", width: width, height: height, fit: fit),
    );
  }
}
