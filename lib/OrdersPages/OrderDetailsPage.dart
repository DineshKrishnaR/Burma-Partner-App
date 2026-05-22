
// import 'package:burmapartner/OrdersPages/Orders.dart';
// import 'package:burmapartner/OrdersPages/OrdersApi.dart';
// import 'package:burmapartner/Settings/AboutApi.dart';
// import 'package:flutter/material.dart';
// import 'package:localstorage/localstorage.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:shimmer/shimmer.dart';
// import '../Common/colors.dart' as custom_color;

// class Orderdetailspage extends StatefulWidget {
//   final orderData;
//   const Orderdetailspage({super.key, required this.orderData});

//   @override
//   State<Orderdetailspage> createState() => _OrderdetailspageState();
// }

// class _OrderdetailspageState extends State<Orderdetailspage> {
//   final LocalStorage storage = LocalStorage('app_store');

//   late SharedPreferences pref;

//   bool isLoading = false;
//   var userResponse;
//   var accesstoken;
//   var customer_id;

//   List view_details = [];
//   var invoice;
 
//   var selected_data;
//   var contacy_us;

//   double promo = 0;
//   double wallet = 0;
//   @override
//   void initState() {
//     super.initState();
//     initPreferencess();
//   }

//   initPreferencess() async {

//     await storage.ready;

//     pref = await SharedPreferences.getInstance();

//     userResponse = await storage.getItem('userResponse');
//     selected_data = widget.orderData;

//     if (userResponse != null) {

//       accesstoken = userResponse['api_token'];

//       customer_id = userResponse['customer_id'].toString();
//     }

//     await getOrdersDetails();
//     await getInvoice();
//     await ContactUs();
//   }

//   Future<void> getOrdersDetails() async {

//     setState(() => isLoading = true);

//     var data = {
//       "action": "get_order_info",
//       "customer_id": customer_id,
//       "orders_id" : selected_data['orders_id'],
//       "accesskey": "90336",
//       "act_type": userResponse['act_type'],
//       "token": accesstoken,
//     };

//     final response = await Ordersapi().getOrdersDetails(data);

//     if (response != null) {
//       view_details = response['res'] ?? [];
//     }

//     setState(() => isLoading = false);
//   }

//   Future<void> getInvoice() async {

//     setState(() => isLoading = true);

//     var data = {
//       "action": "get_invoice",
//       // "customer_id": customer_id,
//       "customer_id": "3",
//       "orders_id" : selected_data['orders_id'],
//       "accesskey": "90336",
//       "act_type": userResponse['act_type'],
//       "token": accesstoken,
//     };

//     final response = await Ordersapi().getInvoice(data);

//     if (response != null) {
//       invoice = response['invoice'] ?? [];
//     }

//     setState(() => isLoading = false);
//   }

//   Future<void> ContactUs() async {
//     setState(() => isLoading = true);
//         var data = {
//               "action": "contact_us",
//               "accesskey":"90336",
//               "token":accesstoken,
//               "customer_id":customer_id,
//               "act_type":userResponse['act_type'],
//         };
//     final response = await Aboutapi().ContactUs(data);

//     print(response);

//     if(response != null){
//       contacy_us = response ?? [];
   

//     setState(() => isLoading = false);
//   }else{
//     contacy_us = [];
//   }
//     setState(() => isLoading = false);
//  }bool isStepDone(String current, String step) {
//   List flow = ["Received", "Processed", "Shipped", "Delivered"];

//   int currentIndex = flow.indexOf(current);
//   int stepIndex = flow.indexOf(step);

//   return currentIndex >= stepIndex;
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
//       return "Delivered"; // keep same as orders page
//     default:
//       return "Received";
//   }
// }
//   @override
//   Widget build(BuildContext context) {
//     double screenHeight = MediaQuery.of(context).size.height;
//     double screenWidth = MediaQuery.of(context).size.width;
//   String currentStatus = "received";

// if (view_details.isNotEmpty) {
//   currentStatus = getStatusFromId(
//       view_details[0]['order_status_id'].toString());
// }

// if (view_details.isNotEmpty) {
//   promo = double.tryParse(
//     view_details[0]['promo_disc_amt']?.toString() ?? "0"
//   ) ?? 0;

//   wallet = double.tryParse(
//     view_details[0]['wallet_balance']?.toString() ?? "0"
//   ) ?? 0;
// }
// var img = (view_details.isNotEmpty &&
//         view_details[0]['order_dtl'] != null &&
//         view_details[0]['order_dtl'].isNotEmpty)
//     ? view_details[0]['order_dtl'][0]['img'] ?? ""
//     : "";
//     var name = (view_details.isNotEmpty &&
//         view_details[0]['order_dtl'] != null &&
//         view_details[0]['order_dtl'].isNotEmpty)
//     ? view_details[0]['order_dtl'][0]['name'] ?? ''
//     : '';
//     return PopScope(
//       canPop: false,
//       onPopInvoked: (didPop) {
//         Navigator.push(context, MaterialPageRoute(builder: (context)=>Orders()));
//       },
//       child: Scaffold(
//          appBar: AppBar(
//         backgroundColor: custom_color.app_color,
//         title: const Text("View Details", style: TextStyle(color: Colors.white)),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
//           onPressed: () {
//             Navigator.push(context,
//                 MaterialPageRoute(builder: (context) => Orders()));
//           },
//         ),
//       ),
//       body: SafeArea(
//         child: isLoading
//             ? _buildShimmer()
//             : view_details.isEmpty
//           ? const Center(child: Text("No Details Found"))
//           : SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.all(12),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
        
//                     Text(
//                       "Order ID : ${view_details[0]['orders_id']}",
//                       style: const TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
//                     ),
        
//                     const SizedBox(height: 5),
        
//                     Text(
//                       "Ordered Date : ${view_details[0]['created_date']}",
//                       style: const TextStyle(color: Colors.grey),
//                     ),
        
//                     const Divider(height: 30),
        
//                     /// PRODUCT DETAILS
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
        
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(8),
//                           // child: Image.network(
//                           //   // view_details[0]['order_dtl'][0]['img'],
//                           //   img,
//                           //   width: 90,
//                           //   height: 90,
//                           //   fit: BoxFit.cover,
//                           // ),
//                           child: safeNetworkImage(img, fit: BoxFit.contain),
//                         ),
        
//                         const SizedBox(width: 12),
        
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
        
//                               Text(
//                                 // view_details[0]['order_dtl'][0]['name'] ?? '',
//                                 name,
//                                 style: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 16),
//                               ),
        
//                               const SizedBox(height: 5),
        
//                               Text(
//                                   // "Quantity : ${view_details[0]['order_dtl'][0]['qty'] ?? 0}"
//                                    "Quantity : ${(
//             view_details.isNotEmpty &&
//             view_details[0]['order_dtl'] != null &&
//             view_details[0]['order_dtl'].isNotEmpty
//           )
//         ? view_details[0]['order_dtl'][0]['qty'] ?? 0
//         : 0}"
//                                   ),
        
//                               const SizedBox(height: 5),
        
//                               // Text(
//                               //   "Rs.${view_details[0]['final_amt']}",
//                               //   style: const TextStyle(fontWeight: FontWeight.bold),
//                               // ),
//                                Text(
//                                           "Rs.${(view_details[0]['order_dtl'] != null && view_details[0]['order_dtl'].isNotEmpty) 
//                                               ? view_details[0]['order_dtl'][0]['discounted_price'] 
//                                               : '0.00'}",
//                                           style: const TextStyle(
//                                             fontWeight: FontWeight.w600,
//                                           ),
//                                         ),
//                                 if (promo > 0)
//                                   priceRow("Promo Applied", "- Rs.$promo"),
        
//                                 if (wallet > 0)
//                                   priceRow("Wallet Used", "- Rs.$wallet"),
//                               const SizedBox(height: 5),
        
//                               // Text(
//                               //   "Via Online Payment",
//                               //   style: TextStyle(
//                               //       color: custom_color.app_color,
//                               //       fontWeight: FontWeight.w600),
//                               // ),
//           Text(
//                                             "Via ${view_details[0]['pay_type'].toString().substring(0,1).toUpperCase()}${view_details[0]['pay_type'].toString().substring(1).toLowerCase()}",
//                                             style: TextStyle(
//                                               color: custom_color.app_color,
//                                               fontWeight: FontWeight.w600,
//                                             ),
//                                           ),
//                               const SizedBox(height: 5),
        
//                               Row(
//                                 children: [
        
//                                   const Text("Payment Status : "),
        
//                                   Text(
//                                     view_details[0]['pay_status'],
//                                     style: TextStyle(
//                                         color: view_details[0]['pay_status'] == "Pending"
//                                             ? Colors.red
//                                             : Colors.green,
//                                         fontWeight: FontWeight.bold),
//                                   )
//                                 ],
//                               ),
        
//                               const SizedBox(height: 5),
        
//                               Text(
//                                 // view_details[0]['order_dtl'][0]['order_status'],
//                                  "${(
//             view_details.isNotEmpty &&
//             view_details[0]['order_dtl'] != null &&
//             view_details[0]['order_dtl'].isNotEmpty
//           )
//         ? view_details[0]['order_dtl'][0]['order_status'] ?? ''
//         : ''}",
//                                 style: const TextStyle(color: Colors.grey),
//                               ),
//                             ],
//                           ),
//                         )
//                       ],
//                     ),
        
//                     const SizedBox(height: 20),
        
//                     /// ORDER TRACKER
//                     // Row(
//                     //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     //   children: [
        
//                     //     orderStep("Order Placed", true),
        
//                     //     orderLine(),
        
//                     //     orderStep("Processed", false),
        
//                     //     orderLine(),
        
//                     //     orderStep("Shipped", false),
        
//                     //     orderLine(),
        
//                     //     orderStep("Delivered", false),
//                     //   ],
//                     // ),
//                         // Row(
//                         //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         //   children: [
        
//                         //     orderStep("Received",
//                         //         isStepDone(currentStatus, "Received")),
//                         //     orderLine(),
        
//                         //     orderStep("Processed",
//                         //         isStepDone(currentStatus, "Processed")),
//                         //     orderLine(),
        
//                         //     orderStep("Shipped",
//                         //         isStepDone(currentStatus, "Shipped")),
//                         //     orderLine(),
        
//                         //     orderStep("Delivered",
//                         //         isStepDone(currentStatus, "Delivered")),
//                         //   ],
//                         // ),
//                        Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             orderStep("Received", isStepDone(currentStatus, "Received")),
//             orderLine(),
//             orderStep("Processed", isStepDone(currentStatus, "Processed")),
//             orderLine(),
//             orderStep("Shipped", isStepDone(currentStatus, "Shipped")),
//             orderLine(),
//             orderStep("Delivered", isStepDone(currentStatus, "Delivered")),
        
//             if (currentStatus == "Cancelled") ...[
//         orderLine(),
//         orderStep("Cancelled", true),
//             ]
//           ],
//         ),
//                     const SizedBox(height: 5),
        
//                     Text(view_details[0]['created_date'],style: const TextStyle(color: Colors.grey)),
        
//                     const SizedBox(height: 20),
        
//                     const Divider(thickness: 2),
        
//                     const SizedBox(height: 10),
        
//                     /// PRICE DETAILS
//                     const Text("Price Details :",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16)),
        
//                     const SizedBox(height: 10),
        
//                     priceRow("Item Price", "Rs.${view_details[0]['tot_amt']}"),
        
//                     priceRow("Delivery Charge", "+ Rs.${view_details[0]['delivery_charge']}"),
        
//                     priceRow("Discount", "- Rs.${view_details[0]['disc_amt']}"),
        
//                     priceRow("Promo Applied", "- Rs.${view_details[0]['promo_disc_amt']}"),
        
//                     priceRow("Wallet Balance", "- Rs.${view_details[0]['wallet_balance']}"),
        
//                     const Divider(),
        
//                     priceRow(
//                       "Final Total",
//                       "Rs.${view_details[0]['final_amt']}",
//                       isBold: true,
//                     ),
        
//                     const SizedBox(height: 20),
        
//                     const Divider(thickness: 2),
        
//                     const SizedBox(height: 10),
        
//                     /// OTHER DETAILS
//                     const Text("Other Details :",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16)),
        
//                     const SizedBox(height: 10),
        
//                     Text("Name : ${view_details[0]['name']}"),
        
//                     const SizedBox(height: 5),
        
//                     Text("Mobile No : ${view_details[0]['mobile']}"),
        
//                     const SizedBox(height: 5),
        
//                     Text(
//                       "Address : ${view_details[0]['customer_address']}",
//                       style: const TextStyle(color: Colors.grey),
//                     ),
        
//                     SizedBox(height: 20),
//                     Divider(thickness: 2,color: Colors.grey.shade300),
        
//                     SizedBox(height: 15),
        
//                     Center(
//                       child: Container(
//                         //  width: screenWidth*0.40,
//                         child: ElevatedButton.icon(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: custom_color.button_color,
//                             padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(25),
//                             ),
//                           ),
//                           onPressed: () {
//                              downloadInvoice();
//                           },
//                           icon: const Icon(Icons.download,color: Colors.white),
//                           label: const Text("Download Invoice",style: TextStyle(color: Colors.white),),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 10,),
//                     /// BUTTONS
//                      Center(
//                        child: Container(
//                         width: screenWidth*0.48,
//                          child: ElevatedButton(
//                            style: ElevatedButton.styleFrom(
//                              backgroundColor: custom_color.button_color,
//                              padding: const EdgeInsets.symmetric(vertical: 14),
//                            ),
//                            onPressed: () async{
//                               String phone = contacy_us?['mobile'] ?? "";
                         
//                                if (phone.isNotEmpty) {
//                                  final Uri url = Uri(scheme: 'tel', path: phone);
                         
//                                  if (await canLaunchUrl(url)) {
//                                    await launchUrl(url);
//                                  } else {
//                                    print("Cannot open dialer");
//                                  }
//                                }
//                            },
//                            child: const Text("Cancel Order",style: TextStyle(color: Colors.white),),
//                          ),
//                        ),
//                      ),
//                     // Row(
//                     //   children: [
//                     //     Expanded(
                          
//                     //       child: ElevatedButton(
//                     //         style: ElevatedButton.styleFrom(
//                     //           backgroundColor: custom_color.button_color,
//                     //           padding: const EdgeInsets.symmetric(vertical: 14),
//                     //         ),
//                     //         onPressed: () async{
//                     //            String phone = contacy_us?['mobile'] ?? "";
        
//                     //             if (phone.isNotEmpty) {
//                     //               final Uri url = Uri(scheme: 'tel', path: phone);
        
//                     //               if (await canLaunchUrl(url)) {
//                     //                 await launchUrl(url);
//                     //               } else {
//                     //                 print("Cannot open dialer");
//                     //               }
//                     //             }
//                     //         },
//                     //         child: const Text("Cancel Order",style: TextStyle(color: Colors.white),),
//                     //       ),
//                     //     ),
        
//                     //     const SizedBox(width: 10),
        
//                     //     Expanded(
//                     //       child: ElevatedButton(
//                     //         style: ElevatedButton.styleFrom(
//                     //           backgroundColor: custom_color.button_color,
//                     //           padding: const EdgeInsets.symmetric(vertical: 14),
//                     //         ),
//                     //         onPressed: () {},
//                     //         child: const Text("Tracking Details",style: TextStyle(color: Colors.white),),
//                     //       ),
//                     //     ),
//                     //   ],
//                     // ),
        
//                     const SizedBox(height: 40),
//                   ],
//                 ),
//               ),
//             ),
//       ),
//       ));
//   }
//   Widget _buildShimmer() {
//     final sw = MediaQuery.of(context).size.width;
//     return Shimmer.fromColors(
//       baseColor: Colors.grey[300]!,
//       highlightColor: Colors.grey[100]!,
//       child: SingleChildScrollView(
//         physics: const NeverScrollableScrollPhysics(),
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Order ID & date
//             Container(width: 180, height: 16, color: Colors.white),
//             const SizedBox(height: 8),
//             Container(width: 140, height: 13, color: Colors.white),
//             const Divider(height: 30),
//             // Product row
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(width: sw * .22, height: sw * .22, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Container(width: double.infinity, height: 16, color: Colors.white),
//                       const SizedBox(height: 8),
//                       Container(width: 80, height: 13, color: Colors.white),
//                       const SizedBox(height: 8),
//                       Container(width: 60, height: 13, color: Colors.white),
//                       const SizedBox(height: 8),
//                       Container(width: 120, height: 13, color: Colors.white),
//                       const SizedBox(height: 8),
//                       Container(width: 140, height: 13, color: Colors.white),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             // Tracking bar
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: List.generate(4, (_) => Column(
//                 children: [
//                   Container(width: 22, height: 22, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
//                   const SizedBox(height: 4),
//                   Container(width: 50, height: 10, color: Colors.white),
//                 ],
//               )),
//             ),
//             const SizedBox(height: 20),
//             const Divider(thickness: 2),
//             const SizedBox(height: 10),
//             // Price details
//             Container(width: 120, height: 16, color: Colors.white),
//             const SizedBox(height: 12),
//             ...List.generate(5, (_) => Padding(
//               padding: const EdgeInsets.symmetric(vertical: 6),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Container(width: 100, height: 13, color: Colors.white),
//                   Container(width: 70, height: 13, color: Colors.white),
//                 ],
//               ),
//             )),
//             const Divider(),
//             const SizedBox(height: 20),
//             const Divider(thickness: 2),
//             const SizedBox(height: 10),
//             // Other details
//             Container(width: 120, height: 16, color: Colors.white),
//             const SizedBox(height: 12),
//             Container(width: 160, height: 13, color: Colors.white),
//             const SizedBox(height: 8),
//             Container(width: 140, height: 13, color: Colors.white),
//             const SizedBox(height: 8),
//             Container(width: double.infinity, height: 13, color: Colors.white),
//             const SizedBox(height: 30),
//             // Buttons
//             Center(child: Container(width: 180, height: 44, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)))),
//             const SizedBox(height: 12),
//             Center(child: Container(width: sw * 0.48, height: 44, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)))),
//           ],
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
//           fontSize: 11,
//           color: isCancelled ? Colors.red : Colors.black,
//         ),
//       )
//     ],
//   );
// }

// Widget orderLine() {
//   return Expanded(
//     child: Divider(
//       color: Colors.grey.shade400,
//       thickness: 1,
//     ),
//   );
// }

// Widget priceRow(String title,String value,{bool isBold=false}) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(vertical: 3),
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(title,style: TextStyle(
//           fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//         )),
//         Text(value,style: TextStyle(
//           fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//           color: isBold ? Colors.green : Colors.black,
//         )),
//       ],
//     ),
//   );
// }
// Future<void> downloadInvoice() async {

//   if (invoice == null) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Invoice not available")),
//     );
//     return;
//   }

//   final Uri url = Uri.parse(invoice);

//   if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
//     throw Exception('Could not open invoice');
//   }
// }

//   Widget safeNetworkImage(
//   String? url, {
//   double? width,
//   double? height,
//   BoxFit fit = BoxFit.cover,
//   double borderRadius = 0,
// }) {
//   double screenHeight = MediaQuery.of(context).size.height;
//     double screenWidth = MediaQuery.of(context).size.width;
//   // Fix double slashes in URL
//   String cleanUrl = (url ?? "").replaceAll(RegExp(r'(?<!:)//+'), '/');
  
//   // Check if URL is valid
//   if (cleanUrl.isEmpty || !cleanUrl.startsWith('http')) {
//     return SizedBox(
//        width: screenWidth * .22,
//          height: screenWidth * .22,
//       child: Image.asset(
//         "assets/images/AppLogo.png",
//         // width: 90,
//         // height: 90,
//         // fit: BoxFit.contain,
//          width: screenWidth * .22,
//          height: screenWidth * .22,
//          fit: BoxFit.cover,
//       ),
//     );
//   }

//   return ClipRRect(
//     borderRadius: BorderRadius.circular(borderRadius),
//     child: SizedBox(
//        width: screenWidth * .22,
//          height: screenWidth * .22,
//       child: Image.network(
//         cleanUrl,
//         fit: fit,
//         loadingBuilder: (context, child, loadingProgress) {
//           if (loadingProgress == null) return child;
//           return Center(
//             child: Image.asset(
//               "assets/images/AppLogo.png",
//               width: screenWidth * .22,
//          height: screenWidth * .22,
//          fit: BoxFit.cover,
//             ),
//           );
//         },
//         errorBuilder: (context, error, stackTrace) {
//           return SizedBox(
//             width: width,
//             height: height,
//             child: Image.asset(
//               "assets/images/AppLogo.png",
//               width: screenWidth * .22,
//          height: screenWidth * .22,
//          fit: BoxFit.cover,
//             ),
//           );
//         },
//       ),
//     ),
//   );
// }
// }

import 'package:burmapartner/OrdersPages/OrdersApi.dart';
import 'package:burmapartner/Settings/AboutApi.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';
import '../Common/colors.dart' as custom_color;

class Orderdetailspage extends StatefulWidget {
  final orderData;
  const Orderdetailspage({super.key, required this.orderData});

  @override
  State<Orderdetailspage> createState() => _OrderdetailspageState();
}

class _OrderdetailspageState extends State<Orderdetailspage> {
  final LocalStorage storage = LocalStorage('app_store');

  late SharedPreferences pref;

  bool isLoading = false;
  var userResponse;
  var accesstoken;
  var customer_id;

  List view_details = [];
  var invoice;
 
  var selected_data;
  var contacy_us;

  double promo = 0;
  double wallet = 0;
  @override
  void initState() {
    super.initState();
    initPreferencess();
  }

  initPreferencess() async {

    await storage.ready;

    pref = await SharedPreferences.getInstance();

    userResponse = await storage.getItem('userResponse');
    selected_data = widget.orderData;

    if (userResponse != null) {

      accesstoken = userResponse['api_token'];

      customer_id = userResponse['customer_id'].toString();
    }

    await getOrdersDetails();
    await getInvoice();
    await ContactUs();
  }

  Future<void> getOrdersDetails() async {

    setState(() => isLoading = true);

    var data = {
      "action": "get_order_info",
      "customer_id": customer_id,
      "orders_id" : selected_data['orders_id'],
      "accesskey": "90336",
      "act_type": userResponse['act_type'],
      "token": accesstoken,
    };

    final response = await Ordersapi().getOrdersDetails(data);

    if (response != null) {
      view_details = response['res'] ?? [];
    }

    setState(() => isLoading = false);
  }

  Future<void> getInvoice() async {

    setState(() => isLoading = true);

    var data = {
      "action": "get_invoice",
      // "customer_id": customer_id,
      "customer_id": "3",
      "orders_id" : selected_data['orders_id'],
      "accesskey": "90336",
      "act_type": userResponse['act_type'],
      "token": accesstoken,
    };

    final response = await Ordersapi().getInvoice(data);

    if (response != null) {
      invoice = response['invoice'] ?? [];
    }

    setState(() => isLoading = false);
  }

  Future<void> ContactUs() async {
    setState(() => isLoading = true);
        var data = {
              "action": "contact_us",
              "accesskey":"90336",
              "token":accesstoken,
              "customer_id":customer_id,
              "act_type":userResponse['act_type'],
        };
    final response = await Aboutapi().ContactUs(data);

    print(response);

    if(response != null){
      contacy_us = response ?? [];
   

    setState(() => isLoading = false);
  }else{
    contacy_us = [];
  }
    setState(() => isLoading = false);
 }

bool isStepDone(String current, String step) {
  if (current == "Cancelled") return step == "Received";
  List flow = ["Received", "Processed", "Shipped", "Delivered", "Returned"];
  return flow.indexOf(current) >= flow.indexOf(step);
}

String getOrderStatus(data) {
  final statusList = data['status'];
  if (statusList != null && statusList is List && statusList.isNotEmpty) {
    final last = statusList.last;
    if (last is List && last.isNotEmpty) {
      final s = last[0].toString();
      return s[0].toUpperCase() + s.substring(1).toLowerCase();
    }
  }
  final dtl = data['order_dtl'];
  if (dtl != null && dtl is List && dtl.isNotEmpty) {
    return (dtl[0]['order_status'] ?? 'Received').toString();
  }
  return 'Received';
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
      final String label    = steps[si]["label"];
      final IconData icon   = steps[si]["icon"];
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
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
  String currentStatus = view_details.isNotEmpty
      ? getOrderStatus(view_details[0])
      : 'Received';

if (view_details.isNotEmpty) {
  final d = view_details[0];
  promo = double.tryParse(d['promo_disc_amt']?.toString() ?? '0') ?? 0;

  // wallet_balance from API is unreliable (shows 0 even when wallet was used)
  // Calculate actual wallet used: tot_amt + delivery_charge - promo - final_amt
  final double tot    = double.tryParse(d['tot_amt']?.toString() ?? '0') ?? 0;
  final double del    = double.tryParse(d['delivery_charge']?.toString() ?? '0') ?? 0;
  final double final_ = double.tryParse(d['final_amt']?.toString() ?? '0') ?? 0;
  final double walletRaw = double.tryParse(d['wallet_balance']?.toString() ?? '0') ?? 0;

  // If wallet_balance field has a real value use it, else compute from totals
  wallet = walletRaw > 0 ? walletRaw : ((tot + del - promo - final_) > 0 ? (tot + del - promo - final_) : 0);
}
return Scaffold(
         appBar: AppBar(
        backgroundColor: custom_color.app_color,
        title: const Text("View Details", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? _buildShimmer()
            : view_details.isEmpty
          ? const Center(child: Text("No Details Found"))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
        
                    Text(
                      "Order ID : ${view_details[0]['orders_id']}",
                      style: const TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                    ),
        
                    const SizedBox(height: 5),
        
                    Text(
                      "Ordered Date : ${view_details[0]['created_date']}",
                      style: const TextStyle(color: Colors.grey),
                    ),
        
                    const Divider(height: 30),

                    /// PRODUCT LIST
                    const Text("Products :", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    ...List.generate(
                      (view_details[0]['order_dtl'] as List? ?? []).length,
                      (i) {
                        final p = view_details[0]['order_dtl'][i];
                        return Card(
                          color: Colors.white,
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                safeNetworkImage(p['img'], fit: BoxFit.contain),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(p['name']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      const SizedBox(height: 4),
                                      Text("Qty : ${p['qty']}", style: const TextStyle(color: Colors.grey)),
                                      const SizedBox(height: 4),
                                      Text("₹${p['discounted_price']}", style: const TextStyle(fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(p['order_status']?.toString() ?? '', style: TextStyle(color: custom_color.app_color, fontSize: 12)),
                                          if (currentStatus == "Delivered" && p['is_returnable']?.toString() == "1") ...[  
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: Colors.purple.shade50,
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(color: Colors.purple.shade200),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: const [
                                                  Icon(Icons.assignment_return_outlined, size: 11, color: Colors.purple),
                                                  SizedBox(width: 3),
                                                  Text("Returnable", style: TextStyle(fontSize: 10, color: Colors.purple, fontWeight: FontWeight.bold)),
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
                          ),
                        );
                      },
                    ),

                    /// PAYMENT INFO
                    Row(
                      children: [
                        Text(
                          "Via ${view_details[0]['pay_type'].toString().substring(0,1).toUpperCase()}${view_details[0]['pay_type'].toString().substring(1).toLowerCase()}",
                          style: TextStyle(color: custom_color.app_color, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 12),
                        const Text("Payment : "),
                        Text(
                          view_details[0]['pay_status'],
                          style: TextStyle(
                            color: view_details[0]['pay_status'] == "Pending" ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
        
                    const SizedBox(height: 20),
        
                    /// ORDER TRACKER
                    _buildTracker(currentStatus),
                    const SizedBox(height: 5),
        
                    Text(view_details[0]['created_date'],style: const TextStyle(color: Colors.grey)),
        
                    const SizedBox(height: 20),
        
                    const Divider(thickness: 2),
        
                    const SizedBox(height: 10),
        
                    /// PRICE DETAILS
                    const Text("Price Details :",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16)),
        
                    const SizedBox(height: 10),
        
                    priceRow("Item Price", "₹${view_details[0]['tot_amt']}"),

                    priceRow("Delivery Charge", "+ ₹${view_details[0]['delivery_charge']}"),

                    if ((double.tryParse(view_details[0]['disc_amt']?.toString() ?? '0') ?? 0) > 0)
                      priceRow("Discount", "- ₹${view_details[0]['disc_amt']}"),

                    if (promo > 0)
                      priceRow("Promo Applied", "- ₹${view_details[0]['promo_disc_amt']}"),

                    if (wallet > 0)
                      priceRow("Wallet Applied", "- ₹${wallet.toStringAsFixed(2)}", isWallet: true),
        
                    const Divider(),
        
                    priceRow(
                      "Final Total",
                      "₹${view_details[0]['final_amt']}",
                      isBold: true,
                    ),
        
                    const SizedBox(height: 20),
        
                    const Divider(thickness: 2),
        
                    const SizedBox(height: 10),
        
                    /// OTHER DETAILS
                    const Text("Other Details :",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16)),
        
                    const SizedBox(height: 10),
        
                    Text("Name : ${view_details[0]['name']}"),
        
                    const SizedBox(height: 5),
        
                    Text("Mobile No : ${view_details[0]['mobile']}"),
        
                    const SizedBox(height: 5),
        
                    Text(
                      "Address : ${view_details[0]['customer_address']}",
                      style: const TextStyle(color: Colors.grey),
                    ),
        
                    SizedBox(height: 20),
                    Divider(thickness: 2,color: Colors.grey.shade300),
        
                    SizedBox(height: 15),
        
                    Center(
                      child: Container(
                        //  width: screenWidth*0.40,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: custom_color.button_color,
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          onPressed: () {
                             downloadInvoice();
                          },
                          icon: const Icon(Icons.download,color: Colors.white),
                          label: const Text("Download Invoice",style: TextStyle(color: Colors.white),),
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                    /// BUTTONS
                     Center(
                       child: Container(
                        width: screenWidth*0.48,
                         child: ElevatedButton(
                           style: ElevatedButton.styleFrom(
                             backgroundColor: custom_color.button_color,
                             padding: const EdgeInsets.symmetric(vertical: 14),
                           ),
                           onPressed: () async{
                              String phone = contacy_us?['mobile'] ?? "";
                         
                               if (phone.isNotEmpty) {
                                 final Uri url = Uri(scheme: 'tel', path: phone);
                         
                                 if (await canLaunchUrl(url)) {
                                   await launchUrl(url);
                                 } else {
                                   print("Cannot open dialer");
                                 }
                               }
                           },
                           child: const Text("Cancel Order",style: TextStyle(color: Colors.white),),
                         ),
                       ),
                     ),
                    // Row(
                    //   children: [
                    //     Expanded(
                          
                    //       child: ElevatedButton(
                    //         style: ElevatedButton.styleFrom(
                    //           backgroundColor: custom_color.button_color,
                    //           padding: const EdgeInsets.symmetric(vertical: 14),
                    //         ),
                    //         onPressed: () async{
                    //            String phone = contacy_us?['mobile'] ?? "";
        
                    //             if (phone.isNotEmpty) {
                    //               final Uri url = Uri(scheme: 'tel', path: phone);
        
                    //               if (await canLaunchUrl(url)) {
                    //                 await launchUrl(url);
                    //               } else {
                    //                 print("Cannot open dialer");
                    //               }
                    //             }
                    //         },
                    //         child: const Text("Cancel Order",style: TextStyle(color: Colors.white),),
                    //       ),
                    //     ),
        
                    //     const SizedBox(width: 10),
        
                    //     Expanded(
                    //       child: ElevatedButton(
                    //         style: ElevatedButton.styleFrom(
                    //           backgroundColor: custom_color.button_color,
                    //           padding: const EdgeInsets.symmetric(vertical: 14),
                    //         ),
                    //         onPressed: () {},
                    //         child: const Text("Tracking Details",style: TextStyle(color: Colors.white),),
                    //       ),
                    //     ),
                    //   ],
                    // ),
        
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
      ),
      );
  }

Widget priceRow(String title, String value, {bool isBold = false, bool isWallet = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (isWallet) ...[  
              const Icon(Icons.account_balance_wallet_outlined, size: 13, color: Colors.teal),
              const SizedBox(width: 4),
            ],
            Text(title, style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isWallet ? Colors.teal : Colors.black87,
            )),
          ],
        ),
        Text(value, style: TextStyle(
          fontWeight: isBold || isWallet ? FontWeight.bold : FontWeight.normal,
          color: isBold ? Colors.green : isWallet ? Colors.teal : Colors.black,
        )),
      ],
    ),
  );
}
Future<void> downloadInvoice() async {

  if (invoice == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Invoice not available")),
    );
    return;
  }

  final Uri url = Uri.parse(invoice);

  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    throw Exception('Could not open invoice');
  }
}

  Widget _shimmerBox({double? width, double? height, double radius = 10}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _buildShimmer() {
    final w = MediaQuery.of(context).size.width;
    return Shimmer.fromColors(
      baseColor: const Color(0xFFDDE4F0),
      highlightColor: const Color(0xFFEEF3FF),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// order id + date
            _shimmerBox(width: w * 0.4, height: 16, radius: 6),
            const SizedBox(height: 8),
            _shimmerBox(width: w * 0.3, height: 12, radius: 6),
            const Divider(height: 30),
            /// product row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerBox(width: w * 0.22, height: w * 0.22, radius: 8),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBox(width: w * 0.5, height: 16, radius: 6),
                    const SizedBox(height: 8),
                    _shimmerBox(width: w * 0.3, height: 12, radius: 6),
                    const SizedBox(height: 8),
                    _shimmerBox(width: w * 0.2, height: 12, radius: 6),
                    const SizedBox(height: 8),
                    _shimmerBox(width: w * 0.25, height: 12, radius: 6),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            /// tracking steps
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (_) => _shimmerBox(width: 40, height: 40, radius: 20)),
            ),
            const SizedBox(height: 20),
            const Divider(thickness: 2),
            const SizedBox(height: 10),
            /// price details
            _shimmerBox(width: w * 0.3, height: 16, radius: 6),
            const SizedBox(height: 12),
            ...List.generate(5, (_) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _shimmerBox(width: w * 0.35, height: 12, radius: 6),
                  _shimmerBox(width: w * 0.2, height: 12, radius: 6),
                ],
              ),
            )),
            const Divider(),
            const SizedBox(height: 20),
            /// buttons
            Center(child: _shimmerBox(width: w * 0.5, height: 44, radius: 25)),
            const SizedBox(height: 10),
            Center(child: _shimmerBox(width: w * 0.48, height: 44, radius: 8)),
          ],
        ),
      ),
    );
  }

  Widget safeNetworkImage(
  String? url, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  double borderRadius = 0,
}) {
  double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
  // Fix double slashes in URL
  String cleanUrl = (url ?? "").replaceAll(RegExp(r'(?<!:)//+'), '/');
  
  // Check if URL is valid
  if (cleanUrl.isEmpty || !cleanUrl.startsWith('http')) {
    return SizedBox(
       width: screenWidth * .22,
         height: screenWidth * .22,
      child: Image.asset(
        "assets/images/AppLogo.png",
        // width: 90,
        // height: 90,
        // fit: BoxFit.contain,
         width: screenWidth * .22,
         height: screenWidth * .22,
         fit: BoxFit.cover,
      ),
    );
  }

  return ClipRRect(
    borderRadius: BorderRadius.circular(borderRadius),
    child: SizedBox(
       width: screenWidth * .22,
         height: screenWidth * .22,
      child: Image.network(
        cleanUrl,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: Image.asset(
              "assets/images/AppLogo.png",
              width: screenWidth * .22,
         height: screenWidth * .22,
         fit: BoxFit.cover,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return SizedBox(
            width: width,
            height: height,
            child: Image.asset(
              "assets/images/AppLogo.png",
              width: screenWidth * .22,
         height: screenWidth * .22,
         fit: BoxFit.cover,
            ),
          );
        },
      ),
    ),
  );
}
}