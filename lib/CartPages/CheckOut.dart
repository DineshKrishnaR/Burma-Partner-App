import 'dart:convert';

import 'package:burmapartner/CartPages/CartApi.dart';
import 'package:burmapartner/CartPages/PaymentFailedScreen.dart';
import 'package:burmapartner/CartPages/PaymentSuccessScreen.dart';
import 'package:burmapartner/Dashboard/DashboardApi.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:localstorage/localstorage.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Common/colors.dart' as custom_color;
import 'Cart.dart';

class Checkout extends StatefulWidget {

  final Map userDetails;
  final List cartData;
  final double deliveryCharge;
  final double gstPercent;
  final double totalAmount;
  final selected_data;

  const Checkout({
    super.key,
    required this.userDetails,
    required this.cartData,
    required this.deliveryCharge,
    required this.gstPercent,
    required this.totalAmount,
    required this.selected_data,
  });

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {

  TextEditingController promoController = TextEditingController();
  final LocalStorage storage = LocalStorage('app_store');
  var userResponse;
  var accesstoken;
  bool isLoading = false;
  late SharedPreferences pref;
  var customer_id;
  var wallet_amount;
  bool useWallet = false;
  double walletUsed = 0;
  var Razorpay_Details;
  late Razorpay _razorpay;
  String orderId = "";
  double finalAmount = 0;
  bool isPaying = false;
  bool isProcessingPayment = false;

  double discountAmount = 0;
  bool couponApplied = false;
  String appliedCoupon = "";
  double walletBalance = 0;
  double totalTax = 0;
  var order_user_type;
  var selecteddata;
  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();

  _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
  _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    initPreferences();
  }
@override
void dispose() {
  _razorpay.clear();
  super.dispose();
}
  initPreferences() async {
    pref = await SharedPreferences.getInstance();
    await storage.ready;
    userResponse = await storage.getItem('userResponse');
    order_user_type = await storage.getItem('order_user_type');
   
    if (userResponse != null) {
      accesstoken = userResponse['api_token'];
      customer_id = userResponse['customer_id'].toString();

    }
    
    await WalletDetails();
  }

 Future<void> WalletDetails() async {
    setState(() => isLoading = true);
   var data = {
         "action": "wallet_dtl",
         "accesskey":"90336",
         "token":accesstoken,
         "customer_id":customer_id,
         "act_type":userResponse['act_type'],
   };
    final response = await DashboardApi().WalletDetails(data);

    print(response);

    if(response != null){
      wallet_amount = response ?? [];
   
      walletBalance =
    double.tryParse(wallet_amount['amount'].toString()) ?? 0;
    setState(() => isLoading = false);
  }
 }
  @override
  Widget build(BuildContext context) {

    // double subTotal = widget.totalAmount;

    // double gst = (subTotal * widget.gstPercent) / 100;

    // double finalTotal = subTotal + gst + widget.deliveryCharge;
// double subTotal = 0;
// double productGST = 0;

// /// Calculate product subtotal + product GST
// for (var item in widget.cartData) {

//   double price = double.parse(item['discounted_price'].toString());
//   int qty = int.parse(item['qty'].toString());
//   double gstPercent = double.parse(item['gst_percentage'].toString());

//   double itemTotal = price * qty;

//   double itemGST = (itemTotal * gstPercent) / 100;

//   subTotal += itemTotal;
//   productGST += itemGST;
// }

double subTotalExcl = 0;
double productGST = 0;

for (var item in widget.cartData) {

  double amt = double.tryParse(item['amt'].toString()) ?? 0;
  double gstPercent = double.tryParse(item['gst_percentage'].toString()) ?? 0;

  double basePrice = 0;
  double gstAmount = 0;

  if (item['gst_enabled'] == "1" && gstPercent > 0) {

    /// ✅ EXACT SAME AS CART
    basePrice = amt / (1 + gstPercent / 100);
    gstAmount = amt - basePrice;

  } else {
    basePrice = amt;
  }

  subTotalExcl += basePrice;
  productGST += gstAmount;
}

/// ✅ FINAL VALUES
double subTotal = subTotalExcl + productGST;

/// Delivery GST calculation
double deliveryBase = widget.deliveryCharge;
double deliveryGST = 0;

if (widget.gstPercent > 0) {
  deliveryBase = widget.deliveryCharge / (1 + widget.gstPercent / 100);
  deliveryGST = widget.deliveryCharge - deliveryBase;
}
 totalTax = productGST + deliveryGST;
/// Final total
// double finalTotal =
//     subTotal + productGST + widget.deliveryCharge;
// double finalTotal =
//     subTotal + productGST + widget.deliveryCharge - discountAmount;
double finalTotal =
    (subTotal + widget.deliveryCharge - discountAmount).roundToDouble();
    // double walletBalance = 0;

if (wallet_amount != null) {
  walletBalance = double.tryParse(wallet_amount['amount'].toString()) ?? 0;
}

// if (useWallet) {
//   walletUsed = walletBalance >= finalTotal ? finalTotal : walletBalance;
//   finalTotal = finalTotal - walletUsed;
// }

if (useWallet) {

  double maxWalletUse = finalTotal;

  walletUsed = walletBalance >= maxWalletUse
      ? maxWalletUse
      : walletBalance;

  // Extra safety (IMPORTANT)
  if (walletUsed > finalTotal) {
    walletUsed = finalTotal;
  }

  // finalTotal = finalTotal - walletUsed;
  finalTotal = (finalTotal - walletUsed).roundToDouble();
}
 else {
  walletUsed = 0;
}

    return PopScope(
      canPop: false,
      // onPopInvoked: (didPop) {
      //   Navigator.push(context,
      //       MaterialPageRoute(builder: (context)=>const Cart(selected_data: "",selecteddata_title: "",)));
      // },
onPopInvoked: (didPop) {
  if (didPop) return;
  Navigator.pop(context);
},
      child: Scaffold(

        appBar: AppBar(
          backgroundColor: custom_color.app_color,
          title: const Text("Check Out",
              style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios,
                color: Colors.white),
            // onPressed: () {
            //   Navigator.push(context,
            //       MaterialPageRoute(builder: (context)=>const Cart(selected_data: "",selecteddata_title: "",)));
            // },
                      onPressed: () {
  Navigator.pop(context);
},
          ),
        ),

        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
               children: [
                _sectionCard(
                  icon: Icons.location_on_outlined,
                  title: "Delivery Address",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow(Icons.person_outline, widget.userDetails['name'] ?? ""),
                      const SizedBox(height: 6),
                      _infoRow(Icons.home_outlined,
                        "${widget.userDetails['address']}, ${widget.userDetails['address2']}\n"
                        "${widget.userDetails['city']}, ${widget.userDetails['state']} - ${widget.userDetails['pin']}"),
                      const SizedBox(height: 6),
                      _infoRow(Icons.phone_outlined, widget.userDetails['mobile'] ?? ""),
                    ],
                  ),
                ),
          
                const SizedBox(height: 12),
          
                /// PROMO CODE
                // _sectionCard(
                //   icon: Icons.local_offer_outlined,
                //   title: "Promo Code",
                //   child: Row(
                //     children: [
                //       Expanded(
                //         child: TextField(
                //           controller: promoController,
                //           decoration: InputDecoration(
                //             hintText: "Enter promo code",
                //             hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                //             filled: true,
                //             fillColor: Colors.grey.shade50,
                //             contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                //             border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                //             enabledBorder: OutlineInputBorder(
                //               borderRadius: BorderRadius.circular(10),
                //               borderSide: BorderSide(color: Colors.grey.shade200),
                //             ),
                //             focusedBorder: OutlineInputBorder(
                //               borderRadius: BorderRadius.circular(10),
                //               borderSide: BorderSide(color: custom_color.app_color, width: 1.5),
                //             ),
                //           ),
                //         ),
                //       ),
                //       const SizedBox(width: 10),
                //       SizedBox(
                //         height: 48,
                //         child: ElevatedButton(
                //           style: ElevatedButton.styleFrom(
                //             backgroundColor: couponApplied ? Colors.grey.shade400 : custom_color.button_color,
                //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                //             elevation: 0,
                //           ),
                //           onPressed: couponApplied ? null : () async { await applyCoupon(finalTotal); },
                //           child: Text(couponApplied ? "Applied ✓" : "Apply", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
          //  _sectionCard(
                  
          //         icon: Icons.local_offer_outlined,
          //         title: "Promo Code",
          //         child: couponApplied
          //             ? Row(
          //                 children: [
          //                   Expanded(
          //                     child: Container(
          //                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          //                       decoration: BoxDecoration(
          //                         color: Colors.green.shade50,
          //                         borderRadius: BorderRadius.circular(10),
          //                         border: Border.all(color: Colors.green.shade200),
          //                       ),
          //                       child: Row(
          //                         children: [
          //                           Icon(Icons.check_circle, color: Colors.green.shade600, size: 16),
          //                           const SizedBox(width: 6),
          //                           Text(appliedCoupon, style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 14)),
          //                           const SizedBox(width: 6),
          //                           Text("- ₹${discountAmount.toStringAsFixed(0)}", style: TextStyle(color: Colors.green.shade600, fontSize: 13)),
          //                         ],
          //                       ),
          //                     ),
          //                   ),
          //                   const SizedBox(width: 10),
          //                   GestureDetector(
          //                     onTap: () {
          //                       setState(() {
          //                         couponApplied = false;
          //                         discountAmount = 0;
          //                         appliedCoupon = "";
          //                         promoController.clear();
          //                       });
          //                     },
          //                     child: Container(
          //                       padding: const EdgeInsets.all(10),
          //                       decoration: BoxDecoration(
          //                         color: Colors.red.shade50,
          //                         borderRadius: BorderRadius.circular(10),
          //                         border: Border.all(color: Colors.red.shade200),
          //                       ),
          //                       child: Icon(Icons.close, color: Colors.red.shade400, size: 18),
          //                     ),
          //                   ),
          //                 ],
          //               )
          //             : Row(
          //                 children: [
          //                   Expanded(
          //                     child: TextField(
          //                       controller: promoController,
          //                       decoration: InputDecoration(
          //                         hintText: "Enter promo code",
          //                         hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          //                         filled: true,
          //                         fillColor: Colors.grey.shade50,
          //                         contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          //                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          //                         enabledBorder: OutlineInputBorder(
          //                           borderRadius: BorderRadius.circular(10),
          //                           borderSide: BorderSide(color: Colors.grey.shade200),
          //                         ),
          //                         focusedBorder: OutlineInputBorder(
          //                           borderRadius: BorderRadius.circular(10),
          //                           borderSide: BorderSide(color: custom_color.app_color, width: 1.5),
          //                         ),
          //                       ),
          //                     ),
          //                   ),
          //                   const SizedBox(width: 10),
          //                   SizedBox(
          //                     height: 48,
          //                     child: ElevatedButton(
          //                       style: ElevatedButton.styleFrom(
          //                         backgroundColor: custom_color.button_color,
          //                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          //                         elevation: 0,
          //                       ),
          //                       onPressed: () async { await applyCoupon(subTotal); },
          //                       child: const Text("Apply", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          //                     ),
          //                   ),
          //                 ],
          //               ),
          //       ),
          _sectionCard(
                  
                  icon: Icons.local_offer_outlined,
                  title: "Promo Code",
                  child: couponApplied
                      ? Row(
                          children: [
                            // Expanded(
                            //   child: Container(
                            //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            //     decoration: BoxDecoration(
                            //       color: Colors.green.shade50,
                            //       borderRadius: BorderRadius.circular(10),
                            //       border: Border.all(color: Colors.green.shade200),
                            //     ),
                            //     child: Row(
                            //       children: [
                            //         Icon(Icons.check_circle, color: Colors.green.shade600, size: 16),
                            //         const SizedBox(width: 6),
                            //         Text(appliedCoupon, style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 14)),
                            //         const SizedBox(width: 6),
                            //         Text("- ₹${discountAmount.toStringAsFixed(0)}", style: TextStyle(color: Colors.green.shade600, fontSize: 13)),
                            //       ],
                            //     ),
                            //   ),
                            // ),
                            Expanded(
                              child: TextField(
                                controller: promoController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  hintText: "Enter promo code",
                                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey.shade200),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: custom_color.app_color, width: 1.5),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // GestureDetector(
                            //   onTap: () {
                            //     setState(() {
                            //       couponApplied = false;
                            //       discountAmount = 0;
                            //       appliedCoupon = "";
                            //       promoController.clear();
                            //     });
                            //   },
                            //   child: Container(
                            //     padding: const EdgeInsets.all(10),
                            //     decoration: BoxDecoration(
                            //       color: Colors.red.shade50,
                            //       borderRadius: BorderRadius.circular(10),
                            //       border: Border.all(color: Colors.red.shade200),
                            //     ),
                            //     child: Icon(Icons.close, color: Colors.red.shade400, size: 18),
                            //   ),
                            // ),
                              SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  elevation: 0,
                                ),
                                onPressed: () async { 
                                 setState(() {
                                  couponApplied = false;
                                  discountAmount = 0;
                                  appliedCoupon = "";
                                  promoController.clear();
                                });
                                   },
                                child: const Text("Remove", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: promoController,
                                decoration: InputDecoration(
                                  hintText: "Enter promo code",
                                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey.shade200),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: custom_color.app_color, width: 1.5),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: custom_color.button_color,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  elevation: 0,
                                ),
                                onPressed: () async { await applyCoupon(subTotal); },
                                child: const Text("Apply", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 12),
          
                /// ORDER SUMMARY
                _sectionCard(
                  icon: Icons.receipt_long_outlined,
                  title: "Order Summary",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(flex: 4, child: Text("Product", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black))),
                            SizedBox(width: 30, child: Text("Qty", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black))),
                            SizedBox(width: 65, child: Text("Price", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black))),
                            SizedBox(width: 70, child: Text("Total", textAlign: TextAlign.end, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...widget.cartData.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 4, child: Text("${item['product_name']} ${item['size']}", style: const TextStyle(fontSize: 13))),
                            SizedBox(width: 30, child: Text(item['qty'].toString(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 13))),
                            SizedBox(width: 65, child: Text("₹${item['discounted_price']}", textAlign: TextAlign.center, style: const TextStyle(fontSize: 13))),
                            SizedBox(width: 70, child: Text("₹${item['amt']}", textAlign: TextAlign.end, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
                          ],
                        ),
                      )).toList(),
                      const Divider(height: 20),
                      _priceDetailRow("Items Amount", "₹${subTotalExcl.toStringAsFixed(0)}"),
                      _priceDetailRow("Product GST", "₹${productGST.toStringAsFixed(0)}"),
                      _priceDetailRow("Items Total", "₹${subTotal.toStringAsFixed(0)}"),
                      _priceDetailRow("Delivery Charge", "₹${deliveryBase.toStringAsFixed(0)}"),
                      _priceDetailRow("Delivery GST", "₹${deliveryGST.toStringAsFixed(0)}"),
                      if (useWallet) _priceDetailRow("Wallet Used", "- ₹${walletUsed.toStringAsFixed(0)}", valueColor: Colors.green),
                      if (appliedCoupon.isNotEmpty) _priceDetailRow("Coupon ($appliedCoupon)", "- ₹${discountAmount.toStringAsFixed(0)}", valueColor: Colors.green),
                    ],
                  ),
                ),
          
                const SizedBox(height: 12),
          
                /// WALLET BALANCE
                _sectionCard(
                  icon: Icons.account_balance_wallet_outlined,
                  title: "Wallet Balance",
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: custom_color.app_color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.account_balance_wallet, color: custom_color.app_color, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Available Balance", style: TextStyle(fontSize: 13, color: Colors.grey)),
                            Text("₹ ${wallet_amount?['amount'] ?? 0}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Transform.scale(
                        scale: 1.1,
                        child: Checkbox(
                          value: useWallet,
                          activeColor: custom_color.app_color,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          onChanged: (value) => setState(() => useWallet = value!),
                        ),
                      ),
                    ],
                  ),
                ),
          
                const SizedBox(height: 12),
          
                /// PAYMENT METHOD
                _sectionCard(
                  icon: Icons.payment_outlined,
                  title: "Payment Method",
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: custom_color.app_color.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: custom_color.app_color.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.payments_outlined, color: custom_color.app_color, size: 24),
                        const SizedBox(width: 12),
                        const Expanded(child: Text("Online Payment", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
                        Icon(Icons.check_circle, color: custom_color.app_color, size: 20),
                      ],
                    ),
                  ),
                ),
             
          
          //               /// DELIVERY ADDRESS
          //               Container(
          //                 margin: const EdgeInsets.all(16),
          //                 padding: const EdgeInsets.all(16),
          //                 decoration: BoxDecoration(
          //                   // color: Colors.grey.shade200,
          //                   borderRadius: BorderRadius.circular(18),
          //                    color: Colors.white,
          //       border: Border(
          //                right: BorderSide(
          //               color: Colors.grey.shade300, // light color
          //               width: 2.5,
          //             ),
          //             bottom: BorderSide(
          //               color: Colors.grey.shade300, // light color
          //               width: 2.5,
          //             ),
          //           ),
          //                 ),
          
          //                 child: Column(
          //                   crossAxisAlignment: CrossAxisAlignment.start,
          //                   children: [
          
          //                     const Text(
          //                       "Delivery Address",
          //                       style: TextStyle(
          //                         fontSize: 22,
          //                         fontWeight: FontWeight.bold,
          //                         color: Colors.green,
          //                       ),
          //                     ),
          
          //                     const SizedBox(height: 16),
          
          //                     Row(
          //                       children: [
          //                         const SizedBox(width: 80, child: Text("Name",style: TextStyle(fontWeight: FontWeight.bold),)),
          //                         Text(widget.userDetails['name'] ?? ""),
          //                       ],
          //                     ),
          
          //                     const SizedBox(height: 6),
          
          //                     Row(
          //                       crossAxisAlignment: CrossAxisAlignment.start,
          //                       children: [
          //                         const SizedBox(width: 80, child: Text("Address",style: TextStyle(fontWeight: FontWeight.bold),)),
          //                         Expanded(
          //                           child: Text(
          //                             "${widget.userDetails['address']}, ${widget.userDetails['address2']}\n"
          //                             "${widget.userDetails['city']}, ${widget.userDetails['state']}\n"
          //                             "${widget.userDetails['pin']}",
          //                           ),
          //                         ),
          //                       ],
          //                     ),
          
          //                     const SizedBox(height: 6),
          
          //                     Row(
          //                       children: [
          //                         const SizedBox(width: 80, child: Text("Mobile",style: TextStyle(fontWeight: FontWeight.bold),)),
          //                         Text(widget.userDetails['mobile'] ?? ""),
          //                       ],
          //                     ),
          
          //                   ],
          //                 ),
          //               ),
          
          //               /// PROMO CODE
          //               Container(
          //                 margin: const EdgeInsets.symmetric(horizontal:16),
          //                 padding: const EdgeInsets.all(16),
          //                 decoration: BoxDecoration(
          //                   // color: Colors.grey.shade200,
          //                   borderRadius: BorderRadius.circular(18),
          //                    color: Colors.white,
          //       border: Border(
          //                right: BorderSide(
          //               color: Colors.grey.shade300, // light color
          //               width: 2.5,
          //             ),
          //             bottom: BorderSide(
          //               color: Colors.grey.shade300, // light color
          //               width: 2.5,
          //             ),
          //           ),
          //                 ),
          
          //                 child: Column(
          //                   crossAxisAlignment: CrossAxisAlignment.start,
          //                   children: [
          
          //                     const Text(
          //                       "Have a Promo Code?",
          //                       style: TextStyle(
          //                         fontSize:20,
          //                         fontWeight: FontWeight.bold,
          //                         color: Colors.green,
          //                       ),
          //                     ),
          
          //                     const SizedBox(height:12),
          
          //                     Row(
          //                       children: [
          
          //                         Expanded(
          //                           child: TextField(
          //                             controller: promoController,
          //                             decoration: InputDecoration(
          //                               hintText: "Enter the promo code",
          //                               filled: true,
          //                               fillColor: Colors.white,
          //                               border: OutlineInputBorder(
          //                                 borderRadius:
          //                                 BorderRadius.circular(30),
          //                               ),
          //                               enabledBorder: OutlineInputBorder(
          //                                 borderRadius: BorderRadius.circular(10),
          //                                 borderSide: BorderSide(
          //                                   color: custom_color.app_color,
          //                                   width: 1.5,
          //                                 ),
          //                              ),
          
          //                         focusedBorder: OutlineInputBorder(
          //                           borderRadius: BorderRadius.circular(10),
          //                           borderSide: BorderSide(
          //                             color: custom_color.app_color,
          //                             width: 2,
          //                           ),
          //                         ),
          //                             ),
          //                           ),
          //                         ),
          
          //                         const SizedBox(width:10),
          
          //                         // ElevatedButton(
          //                         //   style: ElevatedButton.styleFrom(
          //                         //     // backgroundColor:
          //                         //     // custom_color.button_color,
          //                         //     backgroundColor: couponApplied
          //                         //     ? Colors.grey // disabled color
          //                         //     : custom_color.button_color,
          
          //                         //   ),
          //                         //   onPressed:couponApplied  ? null : () async{
          //                         //      applyCoupon(finalTotal);
          //                         //   },
          //                         //   child:  Text(
          //                         //     // "APPLY",
          //                         //     couponApplied ? "APPLIED" : "APPLY",
          //                         //       style: TextStyle(
          //                         //           color: Colors.white)),
          //                         // )
          //                           ElevatedButton(
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: couponApplied
          //         ? Colors.grey
          //         : custom_color.button_color,
          //   ),
          //   onPressed: couponApplied
          //       ? null
          //       : () async {
          //           await applyCoupon(finalTotal);
          //         },
          //   child: Text(
          //     couponApplied ? "APPLIED" : "APPLY",
          //     style: const TextStyle(color: Colors.white),
          //   ),
          // )
          //                       ],
          //                     )
          
          //                   ],
          //                 ),
          //               ),
          
          //               const SizedBox(height:16),
          
          //               /// ORDER SUMMARY
          //               Container(
          //                 margin: const EdgeInsets.symmetric(horizontal:16),
          //                 padding: const EdgeInsets.all(16),
          //                 decoration: BoxDecoration(
          //                   // color: Colors.grey.shade200,
          //                   borderRadius: BorderRadius.circular(18),
          //                    color: Colors.white,
          //       border: Border(
          //                right: BorderSide(
          //               color: Colors.grey.shade300, // light color
          //               width: 2.5,
          //             ),
          //             bottom: BorderSide(
          //               color: Colors.grey.shade300, // light color
          //               width: 2.5,
          //             ),
          //           ),
          //                 ),
          
          //                 child: Column(
          //                   crossAxisAlignment: CrossAxisAlignment.start,
          //                   children: [
          
          //                     const Text(
          //                       "Order Summary",
          //                       style: TextStyle(
          //                         fontSize:22,
          //                         fontWeight: FontWeight.bold,
          //                         color: Colors.green,
          //                       ),
          //                     ),
          
          //                     const SizedBox(height:20),
          
          //                     const Row(
          //                       mainAxisAlignment:
          //                       MainAxisAlignment.spaceBetween,
          //                       children: [
          //                         Text("Product Name",
          //                             style: TextStyle(
          //                                 fontWeight: FontWeight.bold)),
          //                         Text("Qty",
          //                             style: TextStyle(
          //                                 fontWeight: FontWeight.bold)),
          //                         Text("Price",
          //                             style: TextStyle(
          //                                 fontWeight: FontWeight.bold)),
          //                         Text("Sub Total",
          //                             style: TextStyle(
          //                                 fontWeight: FontWeight.bold)),
          //                       ],
          //                     ),
          
          //                     const Divider(),
          
          //                     Column(
          //                       children: widget.cartData.map((item) {
          
          //                         return Padding(
          //                           padding: const EdgeInsets.symmetric(vertical: 8),
          
          //                           child: Row(
          //                             crossAxisAlignment: CrossAxisAlignment.start,
          //                             children: [
          
          //                               /// PRODUCT NAME
          //                               Expanded(
          //                                 flex: 4,
          //                                 child: Text(
          //                                   "${item['product_name']} ${item['size']}",
          //                                   style: const TextStyle(fontSize: 14),
          //                                   softWrap: true,
          //                                 ),
          //                               ),
          
          //                               const SizedBox(width: 10),
          
          //                               /// QTY
          //                               SizedBox(
          //                                 width: 35,
          //                                 child: Text(
          //                                   item['qty'].toString(),
          //                                   textAlign: TextAlign.center,
          //                                 ),
          //                               ),
          
          //                               /// PRICE
          //                               SizedBox(
          //                                 width: 70,
          //                                 child: Text(
          //                                   "Rs.${item['discounted_price']}",
          //                                   textAlign: TextAlign.center,
          //                                 ),
          //                               ),
          
          //                               /// SUBTOTAL
          //                               SizedBox(
          //                                 width: 80,
          //                                 child: Text(
          //                                   "Rs.${item['amt']}",
          //                                   textAlign: TextAlign.end,
          //                                   style: const TextStyle(fontWeight: FontWeight.bold),
          //                                 ),
          //                               ),
          //                             ],
          //                           ),
          //                         );
          
          //                       }).toList(),
          //                     ),
          //                      Divider(),
          
          //                     // priceRow("Sub Total", "Rs.${subTotal.toStringAsFixed(2)}"),
          //                     // priceRow("GST (${widget.gstPercent}%)",
          //                     //     "Rs.${gst.toStringAsFixed(2)}"),
          //                     // priceRow("Delivery Charge",
          //                     //     "Rs.${widget.deliveryCharge}"),
          //                     // priceRow("Sub Total", "Rs.${subTotal.toStringAsFixed(2)}"),
          // priceRow("Subtotal (Excl Tax)", "Rs.${subTotalExcl.toStringAsFixed(2)}"),
          // priceRow("Product GST", "Rs.${productGST.toStringAsFixed(2)}"),
          // priceRow("Subtotal (Incl Tax)", "Rs.${subTotal.toStringAsFixed(2)}"),
          //                     // priceRow("Product GST",
          //                     //     "Rs.${productGST.toStringAsFixed(2)}"),
          
          //                     priceRow("Delivery Charge + ",
          //                         "Rs.${deliveryBase.toStringAsFixed(2)}"),
          
          //                     priceRow("Delivery GST",
          //                         "Rs.${deliveryGST.toStringAsFixed(2)}"),
          
          //                     if(useWallet)
          //                     // priceRow("Wallet Used","Rs.${walletUsed.toStringAsFixed(2)}"),  
          //                     priceRow("Wallet Used","- Rs.${walletUsed.toStringAsFixed(2)}"), 
          
          //                     // if (couponApplied)
          //                     // if (appliedCoupon.isNotEmpty)
          //                     // priceRow(
          //                     //   "Coupon ($appliedCoupon)",
          //                     //   "- Rs.${discountAmount.toStringAsFixed(2)}",
          //                     // ), 
          // if (appliedCoupon.isNotEmpty && discountAmount > 0)
          //   priceRow(
          //     "Coupon ($appliedCoupon)",
          //     "- Rs.${discountAmount.toStringAsFixed(2)}",
          //   ),
          //                   ],
          //                 ),
          //               ),
          
          //                SizedBox(height:16),
          // /// WALLET BALANCE
          // Container(
          //   margin: const EdgeInsets.symmetric(horizontal: 16),
          //   padding: const EdgeInsets.all(16),
          //   decoration: BoxDecoration(
          //     // color: Colors.grey.shade200,
          //     borderRadius: BorderRadius.circular(18),
          //      color: Colors.white,
          //       border: Border(
          //                right: BorderSide(
          //               color: Colors.grey.shade300, // light color
          //               width: 2.5,
          //             ),
          //             bottom: BorderSide(
          //               color: Colors.grey.shade300, // light color
          //               width: 2.5,
          //             ),
          //           ),
          //   ),
          
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          
          //       const Text(
          //         "Wallet Balance :",
          //         style: TextStyle(
          //           fontSize: 22,
          //           fontWeight: FontWeight.bold,
          //           color: Colors.green,
          //         ),
          //       ),
          
          //       const SizedBox(height: 16),
          
          //       Row(
          //         children: [
          
          //           Icon(Icons.account_balance_wallet,
          //               color: custom_color.app_color, size: 30),
          
          //           const SizedBox(width: 10),
          
          //            Expanded(
          //             child: Column(
          //               crossAxisAlignment: CrossAxisAlignment.start,
          //               children: [
          
          //                 Text(
          //                   "Wallet Balance :",
          //                   style: TextStyle(
          //                       fontWeight: FontWeight.bold,
          //                       fontSize: 16),
          //                 ),
          
          //                 SizedBox(height: 4),
          
          //                 Text(
          //                  "Total Balance : Rs ${wallet_amount?['amount'] ?? 0}",
          //                   style: TextStyle(fontSize: 15),
          //                 ),
          //               ],
          //             ),
          //           ),
          
          //           Checkbox(
          //             value: useWallet,
          //             activeColor: custom_color.app_color,
          //             onChanged: (value) {
          //               setState(() {
          //                 useWallet = value!;
          //               });
          //             },
          //           )
          
          //         ],
          //       )
          
          //     ],
          //   ),
          // ),
          // /// PAYMENT METHOD
          // Container(
          //   margin: const EdgeInsets.all(16),
          //   padding: const EdgeInsets.all(16),
          //   decoration: BoxDecoration(
          //     // color: Colors.grey.shade200,
          //     borderRadius: BorderRadius.circular(18),
          //      color: Colors.white,
          //       border: Border(
          //                right: BorderSide(
          //               color: Colors.grey.shade300, // light color
          //               width: 2.5,
          //             ),
          //             bottom: BorderSide(
          //               color: Colors.grey.shade300, // light color
          //               width: 2.5,
          //             ),
          //           ),
          //   ),
          
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          
          //       const Text(
          //         "Payment Method",
          //         style: TextStyle(
          //           fontSize: 22,
          //           fontWeight: FontWeight.bold,
          //           color: Colors.green,
          //         ),
          //       ),
          
          //       const SizedBox(height: 16),
          
          //       Row(
          //         children: [
          
          //           Icon(Icons.payments,
          //               color: custom_color.app_color,
          //               size: 32),
          
          //           const SizedBox(width: 12),
          
          //           const Expanded(
          //             child: Text(
          //               "Online Payment",
          //               style: TextStyle(
          //                 fontSize: 18,
          //               ),
          //             ),
          //           ),
          
          //           Radio(
          //             value: 1,
          //             groupValue: 1,
          //             onChanged: (value) {},
          //             activeColor: custom_color.app_color,
          //           )
          
          //         ],
          //       )
          
          //     ],
          //   ),
          // ),
          //               /// TOTAL + PROCEED
          //               // Container(
          //               //   padding: const EdgeInsets.all(16),
          
          //               //   child: Row(
          //               //     mainAxisAlignment:
          //               //     MainAxisAlignment.spaceBetween,
          //               //     children: [
          
          //               //       Text(
          //               //         "Total : Rs.${finalTotal.toStringAsFixed(2)}",
          //               //         style: const TextStyle(
          //               //             fontSize:22,
          //               //             fontWeight: FontWeight.bold),
          //               //       ),
          
          //               //       ElevatedButton(
          //               //         style: ElevatedButton.styleFrom(
          //               //           backgroundColor:
          //               //           custom_color.app_color,
          //               //           padding: const EdgeInsets.symmetric(
          //               //               horizontal:30,vertical:14),
          //               //         ),
          //               //         onPressed: () {
          //               //           showConfirmDialog(finalTotal);
          //               //         },
          //               //         child: const Text(
          //               //           "Proceed",
          //               //           style: TextStyle(
          //               //               color: Colors.white,
          //               //               fontSize:16),
          //               //         ),
          //               //       )
          
          //               //     ],
          //               //   ),
          //               // )
                
              ],
            ),
          ),
        ),
           bottomNavigationBar: SafeArea(
  child: Container(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  decoration: BoxDecoration(
    color: Colors.white,
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 10,
        offset: Offset(0, -2),
      )
    ],
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [

      Flexible(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            "Total : ₹${finalTotal.toStringAsFixed(0)}",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),

      const SizedBox(width: 12),

      ElevatedButton(
        // style: ElevatedButton.styleFrom(
        //   backgroundColor: custom_color.button_color,
        //   padding: const EdgeInsets.symmetric(
        //       horizontal: 24, vertical: 12),
        // ),
         style: ElevatedButton.styleFrom(
                backgroundColor: custom_color.button_color,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(
                horizontal: 24, vertical: 12),
                elevation: 0,
         ),
     onPressed: () async {
  if (finalTotal == 0) {

    // await SaveOrders("WALLET_ONLY", finalTotal, {"status": "success"});
    await SaveOrders(
      "WALLET_ONLY",
      "WALLET_ORDER",
      "WALLET_SIGNATURE",
      finalTotal,
    );
   
    await clearCart();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentSuccessScreen(paymentId: "WALLET"),
      ),
      (route) => false,
    );

  } else {
    showConfirmDialog(finalTotal);
  }
},
        child: const Text(
          "Proceed",
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
          ),
        ),
      )

    ],
  ),
),
),
      ),
    );
  }
 Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: Colors.grey.shade700))),
      ],
    );
  }
  Widget priceRow(String title,String value){

    return Padding(
      padding: const EdgeInsets.symmetric(vertical:4),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold)),

          Text(value)

        ],
      ),
    );
  }

  Widget _sectionCard({required IconData icon, required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: custom_color.app_color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
   Widget _priceDetailRow(String title, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: valueColor ?? const Color(0xFF1A1A2E))),
        ],
      ),
    );
  }
void showConfirmDialog(double finalTotal) {
  if (isPaying) return;

  double subTotalExcl = 0;
  double productGST = 0;

  for (var item in widget.cartData) {
    double amt = double.tryParse(item['amt'].toString()) ?? 0;
    double gstPercent = double.tryParse(item['gst_percentage'].toString()) ?? 0;
    double basePrice = 0;
    double gstAmount = 0;
    if (item['gst_enabled'] == "1" && gstPercent > 0) {
      basePrice = amt / (1 + gstPercent / 100);
      gstAmount = amt - basePrice;
    } else {
      basePrice = amt;
    }
    subTotalExcl += basePrice;
    productGST += gstAmount;
  }

  double deliveryBase = widget.deliveryCharge;
  double deliveryGST = 0;
  if (widget.gstPercent > 0) {
    deliveryBase = widget.deliveryCharge / (1 + widget.gstPercent / 100);
    deliveryGST = widget.deliveryCharge - deliveryBase;
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return SafeArea(
            child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Handle bar + header (fixed)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: custom_color.app_color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.receipt_long_outlined, color: custom_color.app_color, size: 20),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Order Summary",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                /// Scrollable price content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            children: [
                              _dialogPriceRow("Items Amount", "₹${subTotalExcl.toStringAsFixed(0)}"),
                              _dialogPriceRow("Product GST", "₹${productGST.toStringAsFixed(0)}"),
                              _dialogPriceRow("Delivery Charge", "₹${deliveryBase.toStringAsFixed(0)}"),
                              _dialogPriceRow("Delivery GST", "₹${deliveryGST.toStringAsFixed(0)}"),
                              if (useWallet) _dialogPriceRow("Wallet Used", "- ₹${walletUsed.toStringAsFixed(0)}", valueColor: Colors.green),
                              if (discountAmount > 0) _dialogPriceRow("Discount", "- ₹${discountAmount.toStringAsFixed(0)}", valueColor: Colors.green),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: custom_color.app_color.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: custom_color.app_color.withOpacity(0.25)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Total Payable", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                              Text(
                                "₹${finalTotal.toStringAsFixed(0)}",
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: custom_color.app_color),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),

                /// Buttons always pinned at bottom
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 20),
                  child: isPaying
                    ? Column(
                        children: [
                          CircularProgressIndicator(color: custom_color.app_color),
                          const SizedBox(height: 10),
                          const Text("Processing payment...", style: TextStyle(color: Colors.grey)),
                        ],
                      )
                    : Row(
                      children: [
                        Expanded(
                            flex: 2,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: Colors.grey.shade400),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: Text("Cancel", style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: custom_color.button_color,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            onPressed: () async {
                              setDialogState(() => isPaying = true);
                              setState(() => isPaying = true);
                              await getRazorpayDetails(finalTotal);
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.lock_outline, color: Colors.white, size: 16),
                                SizedBox(width: 6),
                                Text("Pay Now", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                ),
              ],
            ),
          ),
          );
        },
      );
    },
  );
}

Widget _dialogPriceRow(String title, String value, {Color? valueColor}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: valueColor ?? const Color(0xFF1A1A2E))),
      ],
    ),
  );
}

Future<void> getRazorpayDetails(double finalTotal) async {
  try {
    var data = {
      "action": "get_razorpay_details",
      "accesskey": "90336",
      "token": accesstoken,
      "act_type": userResponse['act_type'],
      "customer_id": customer_id,
    };

    final response = await Cartapi().getRazorpayDetails(data);

    if (response != null && response['keyid'] != null) {
      Razorpay_Details = response;
      await RAZORPAYORDERCREATEAPI(finalTotal);
    } else {
      setState(() => isPaying = false);
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Failed to get payment details");
    }
  } catch (e) {
    setState(() => isPaying = false);
    Navigator.pop(context);
    Fluttertoast.showToast(msg: "Error: ${e.toString()}");
  }
}

Future<void> RAZORPAYORDERCREATEAPI(double finalTotal) async {
  try {
    var data = {
      "action": "razorpay_order",
      "accesskey": "90336",
      "token": accesstoken,
      "act_type": userResponse['act_type'],
      "customer_id": customer_id,
      "amount": ((finalTotal * 100).toInt()).toString(),
    };

    final response = await Cartapi().RAZORPAYORDERCREATEAPI(data);

    if (response != null && response['id'] != null) {
      orderId = response['id'];
      finalAmount = finalTotal;
      Navigator.pop(context);
      openRazorpay(orderId, finalTotal);
    } else {
      setState(() => isPaying = false);
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Failed to create order");
    }
  } catch (e) {
    setState(() => isPaying = false);
    Navigator.pop(context);
    Fluttertoast.showToast(msg: "Error creating order: ${e.toString()}");
  }
}
void openRazorpay(String orderId, double amount) {
  try {
    var options = {
      'key': Razorpay_Details?['keyid'] ?? '',
      'amount': (amount * 100).toInt(),
      'order_id': orderId,
      'name': 'Burma Traders',
      'description': 'Order Payment',
      'prefill': {
        'contact': widget.userDetails['mobile'] ?? '',
        'email': widget.userDetails['email'] ?? ''
      },
      'theme': {
        'color': '#4CAF50'
      }
    };
    _razorpay.open(options);
  } catch (e) {
    setState(() => isPaying = false);
    debugPrint("Razorpay Error: $e");
    Fluttertoast.showToast(msg: "Failed to open payment gateway");
  }
}
void _handlePaymentSuccess(PaymentSuccessResponse response) async{
  setState(() => isProcessingPayment = true);
  
  String paymentId = response.paymentId ?? "";
  String razorOrderId = response.orderId ?? "";
  String signature = response.signature ?? "";

  debugPrint("Payment Success - ID: $paymentId");
  
  if (paymentId.isEmpty || razorOrderId.isEmpty || signature.isEmpty) {
    setState(() {
      isPaying = false;
      isProcessingPayment = false;
    });
    Fluttertoast.showToast(msg: "Invalid payment response");
    return;
  }
  // SaveOrders(paymentId, finalAmount);
  await SaveOrders(
    paymentId,
    razorOrderId,
    signature,
    finalAmount,
  );
  // verifyPayment(paymentId, razorOrderId, signature);
}
// Future<void> SaveOrders(String paymentId, double finalTotal) async {
Future<void> SaveOrders(
  String paymentId,
  String razorOrderId,
  String signature,
  double finalTotal,
) async {

  try {

    String address =
        "${widget.userDetails['address']}, ${widget.userDetails['address2']}, "
        "${widget.userDetails['city']}, ${widget.userDetails['state']} - ${widget.userDetails['pin']}";

    var data = {
      "action": "save_order",
      "accesskey": "90336",
      "customer_id": customer_id,
      "customer_address": address,
      "cart_items": jsonEncode(widget.cartData),
      // "tot_amt": (finalTotal + walletUsed - widget.deliveryCharge).toStringAsFixed(2),
      "tot_amt": (finalTotal + walletUsed).toStringAsFixed(2),
      "delivery_charge": widget.deliveryCharge.toString(),
      "tax_amt": totalTax.toStringAsFixed(2),
      "tax_percent": widget.gstPercent.toString(),
      "final_amt": finalTotal.toStringAsFixed(2),
      // "pay_type": "online",
      // "pay_type": finalTotal == 0 ? "wallet" : "online",
      "pay_type": finalTotal == 0 ? "wallet" : "online",
      "txn_id": paymentId,
      "mobile": widget.userDetails['mobile'] ?? "",
      "name": widget.userDetails['name'] ?? "",
      "token": accesstoken,
      // "pay_status": payResponse['status'],
      "pay_status": "Success",
      "razorpay_order_id": orderId,
      "act_type": userResponse['act_type'],
      "wallet_used": walletUsed.toStringAsFixed(2),
      // "wallet_balance": walletBalance.toStringAsFixed(2),
      "wallet_balance": (walletBalance - walletUsed).toStringAsFixed(2),
      // "refer_order":"",
      "refer_order": order_user_type == "myself" ? "true" : "false",
      // "refer_id": "",
       "refer_id": order_user_type == "myself"
      ? userResponse['customer_id'].toString()
      : widget.userDetails['customer_id'].toString(),
      "refer_type": order_user_type == "myself"
      ? userResponse['act_type']
      : widget.userDetails['distributor'],
      // "refer_type": "",
      "promo_code": appliedCoupon,
      "promo_disc_amt": discountAmount.toStringAsFixed(2),
    };
    print(data);
    final response = await Cartapi().SaveOrders(data);

    print(response);

    if (response != null && response["status"] == "success") {
     verifyPayment(paymentId, razorOrderId, signature ,response);
    } else {

      Fluttertoast.showToast(msg: "Order save failed");

    }

  } catch (e) {

    debugPrint("Save Order Error: $e");
    Fluttertoast.showToast(msg: "Error saving order");

  }
}
Future<void> verifyPayment(String paymentId, String razorOrderId, String signature,orderResponse) async {

  try {
    var data = {
      "action": "get_pay_status",
      "accesskey": "90336",
      "customer_id": customer_id,
      // "orders_id": razorOrderId,
      "orders_id": orderResponse['orders_id'].toString(),
      "final_amt": finalAmount.toStringAsFixed(2),
      // "pay_type": "online",
      "pay_type": finalAmount == 0 ? "wallet" : "online",
      "txn_id": paymentId,
      "signature": signature,
      "token": accesstoken,
      "act_type": userResponse['act_type'],
      // "pay_status": "Success"
      "pay_status": "paid"
    };

    final response = await Cartapi().getPaymentStatus(data);
    print(response);
    setState(() {
      isPaying = false;
      isProcessingPayment = false;
    });
//  SaveOrders(paymentId, finalAmount,response);
    if (response != null && response["status"].toString().toLowerCase() == "success") {
      // await SaveOrders(paymentId, finalAmount, response);
      await clearCart();
      
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentSuccessScreen(
              paymentId: paymentId,
            ),
          ),
          (route) => false,
        );
      }
      
    } else {
      //  await SaveOrders(paymentId, finalAmount, response);
      //  await clearCart();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const PaymentFailedScreen(
              message: "Payment verification failed",
            ),
          ),
        );
      }
    }
  } catch (e) {
    setState(() {
      isPaying = false;
      isProcessingPayment = false;
    });
    
    debugPrint("Verification Error: $e");
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentFailedScreen(
            message: "Error: ${e.toString()}",
          ),
        ),
      );
    }
  }
}
// void _handlePaymentError(PaymentFailureResponse response) {
//   setState(() {
//     isPaying = false;
//     isProcessingPayment = false;
//   });
  
//   debugPrint("Payment Error: ${response.code} - ${response.message}");
  
//   String errorMessage = "Payment failed";
  
//   if (response.code == 0) {
//     errorMessage = "Payment cancelled by user";
//   } else if (response.code == 2) {
//     errorMessage = "Network error. Please check your connection";
//   } else {
//     errorMessage = response.message ?? "Payment failed";
//   }
  
//   Fluttertoast.showToast(msg: errorMessage);
  
//   if (mounted) {
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (_) => PaymentFailedScreen(
//           message: errorMessage,
//         ),
//       ),
//     );
//   }
// }
void _handlePaymentError(PaymentFailureResponse response) {
  setState(() {
    isPaying = false;
    isProcessingPayment = false;
  });

  debugPrint("Payment Error: ${response.code} - ${response.message}");
  debugPrint("Full Error: ${response.error}");

  String errorMessage;

  switch (response.code) {
    case Razorpay.PAYMENT_CANCELLED:
      errorMessage = "Payment cancelled by user";
      break;

    case Razorpay.NETWORK_ERROR:
      errorMessage = "Network error. Please check your internet connection";
      break;

    case Razorpay.INVALID_OPTIONS:
      errorMessage = "Invalid payment configuration";
      break;

    default:
      errorMessage =
      (response.message != null &&
          response.message!.trim().isNotEmpty &&
          response.message != "undefined")
          ? response.message!
          : "Payment failed. Please try again";
  }

  Fluttertoast.showToast(msg: errorMessage);

  if (!mounted) return;

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => PaymentFailedScreen(
        message: errorMessage,
      ),
    ),
  );
}
void _handleExternalWallet(ExternalWalletResponse response) {
  debugPrint("External Wallet Selected: ${response.walletName}");
  Fluttertoast.showToast(msg: "External wallet: ${response.walletName}");
}

Future<void> clearCart() async {
  final box = await Hive.openBox('cart');
  await box.delete('cartItems');
}

Future<void> applyCoupon(double totalAmount) async {

  if (couponApplied) return;


  if (promoController.text.trim().isEmpty) {
    Fluttertoast.showToast(msg: "Enter promo code");
    return;
  }

  var data = {
    "action": "get_promo",
    "accesskey": "90336",
    "token": accesstoken,
    "customer_id": customer_id,
    "act_type": userResponse['act_type'],
    "tot_amt": totalAmount.toString(),
    "code": promoController.text.trim(),
  };

  final response = await Cartapi().PromoCodeValidaction(data);

  if (response != null && response['status'] == "success") {

setState(() {
 
  var promoData = response['res'][0];

  discountAmount = double.tryParse(promoData['discounted_amount']?.toString() ?? "0") ?? 0;

  appliedCoupon = promoData['promo_code'] ?? promoController.text.trim();

  couponApplied = true;
});
   
Fluttertoast.showToast(msg: "Promo code applied successfully");
  } else {
    final rawMsg = response?['message']?.toString().toLowerCase() ?? "";
    final String friendlyMsg;
    if (rawMsg.contains('inactive') || rawMsg.contains('not active') || rawMsg.contains('disabled')) {
      friendlyMsg = "This promo code is no longer active.";
    } else if (rawMsg.contains('one time') || rawMsg.contains('one-time') || rawMsg.contains('1 time') || rawMsg.contains('already used') || rawMsg.contains('already been used')) {
      friendlyMsg = "This offer is valid for one-time use only.";
    } else if (rawMsg.contains('minimum')) {
      final minMatch = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(rawMsg);
      final minAmt = minMatch != null ? double.tryParse(minMatch.group(1)!) : null;
      friendlyMsg = "Add items worth ₹${minAmt?.toStringAsFixed(0) ?? ''} or more to use this promo code.";
    } else if (rawMsg.contains('invalid') || rawMsg.contains('not found') || rawMsg.contains('does not exist')) {
      friendlyMsg = "Invalid promo code. Please check and try again.";
    } else if (rawMsg.contains('expired')) {
      friendlyMsg = "This promo code has expired.";
    } else if (rawMsg.isNotEmpty) {
      friendlyMsg = response?['message']?.toString() ?? "Something went wrong. Please try again.";
    } else {
      friendlyMsg = "Invalid promo code. Please try another.";
    }
    Fluttertoast.showToast(msg: friendlyMsg);
  }
}

}