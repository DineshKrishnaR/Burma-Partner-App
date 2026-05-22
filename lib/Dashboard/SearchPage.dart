
// // import 'package:burmapartner/Dashboard/DashboardApi.dart';
// // import 'package:shimmer/shimmer.dart';
// // import 'package:burmapartner/MainCategory/ProductDetails.dart';
// // import 'package:flutter/material.dart';
// // import 'package:localstorage/localstorage.dart';
// // import '../Common/colors.dart' as custom_color;

// // class SearchPage extends StatefulWidget {
// //   const SearchPage({super.key});

// //   @override
// //   State<SearchPage> createState() => _SearchPageState();
// // }

// // class _SearchPageState extends State<SearchPage> {
// //   final LocalStorage storage = LocalStorage('app_store');
// //   final TextEditingController _searchController = TextEditingController();

// //   var userResponse;
// //   var accesstoken;
// //   var customer_id;

// //   List results = [];
// //   bool isLoading = false;
// //   bool hasSearched = false;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _init();
// //   }

// //   Future<void> _init() async {
// //     await storage.ready;
// //     userResponse = await storage.getItem('userResponse');
// //     if (userResponse != null) {
// //       accesstoken = userResponse['api_token'];
// //       customer_id = userResponse['customer_id'].toString();
// //     }
// //   }

// //   Future<void> _search(String keyword) async {
// //     if (keyword.trim().isEmpty) return;
// //     setState(() {
// //       isLoading = true;
// //       hasSearched = true;
// //     });

// //     var data = {
// //       "action": "get_productlist_by_searchterm",
// //       "accesskey": "90336",
// //       "token": accesstoken,
// //       "act_type": userResponse['act_type'].toString(),
// //       // "customer_id": customer_id.toString(),
// //       "search_term": keyword.trim(),
// //     };

// //     final response = await DashboardApi().SearchProducts(data);
// //     setState(() {
// //       results = response?['res'] ?? [];
// //       isLoading = false;
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       appBar: AppBar(
// //         backgroundColor: custom_color.app_color,
// //         leading: IconButton(
// //           icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
// //           onPressed: () => Navigator.pop(context),
// //         ),
// //         title: TextField(
// //           controller: _searchController,
// //           autofocus: true,
// //           style: const TextStyle(color: Colors.white),
// //           cursorColor: Colors.white,
// //           decoration: const InputDecoration(
// //             hintText: "Search products...",
// //             hintStyle: TextStyle(color: Colors.white70),
// //             border: InputBorder.none,
// //           ),
// //           onChanged: (value) {
// //             if (value.trim().length >= 3) {
// //               _search(value);
// //             } else {
// //               setState(() {
// //                 results = [];
// //                 hasSearched = false;
// //               });
// //             }
// //           },
// //           onSubmitted: _search,
// //           textInputAction: TextInputAction.search,
// //         ),
// //         actions: [
// //           IconButton(
// //             icon: const Icon(Icons.search, color: Colors.white),
// //             onPressed: () => _search(_searchController.text),
// //           ),
// //         ],
// //       ),
// //       body: SafeArea(
// //         child: isLoading
// //             ? _buildShimmerGrid()
// //             : !hasSearched
// //                 ? const Center(
// //                     child: Text("Search for products", style: TextStyle(color: Colors.grey)),
// //                   )
// //                 : results.isEmpty
// //                     ? const Center(
// //                         child: Text("No products found", style: TextStyle(color: Colors.grey)),
// //                       )
// //                     : GridView.builder(
// //                         padding: const EdgeInsets.all(15),
// //                         itemCount: results.length,
// //                         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
// //                           crossAxisCount: 2,
// //                           mainAxisSpacing: 15,
// //                           crossAxisSpacing: 15,
// //                           // childAspectRatio: .75,
// //                            childAspectRatio: 0.62,
// //                         ),
// //                         itemBuilder: (context, index) {
// //                           var p = results[index];
// //                           var variant = (p['vars'] != null && p['vars'].length > 0)
// //                               ? p['vars'][0]
// //                               : null;
// //                           return _buildProductCard(p, variant);
// //                         },
// //                       ),
// //       ),
// //     );
// //   }

// //   Widget _buildShimmerGrid() {
// //     return GridView.builder(
// //       padding: const EdgeInsets.all(15),
// //       itemCount: 6,
// //       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
// //         crossAxisCount: 2,
// //         mainAxisSpacing: 15,
// //         crossAxisSpacing: 15,
// //         childAspectRatio: .75,
// //       ),
// //       itemBuilder: (_, __) => Shimmer.fromColors(
// //         baseColor: Colors.grey.shade300,
// //         highlightColor: Colors.grey.shade100,
// //         child: Container(
// //           decoration: BoxDecoration(
// //             color: Colors.white,
// //             borderRadius: BorderRadius.circular(18),
// //           ),
// //           padding: const EdgeInsets.all(10),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               Expanded(
// //                 child: Container(
// //                   decoration: BoxDecoration(
// //                     color: Colors.grey,
// //                     borderRadius: BorderRadius.circular(12),
// //                   ),
// //                 ),
// //               ),
// //               const SizedBox(height: 8),
// //               Container(height: 12, width: double.infinity, color: Colors.grey),
// //               const SizedBox(height: 4),
// //               Container(height: 12, width: 80, color: Colors.grey),
// //               const SizedBox(height: 8),
// //               Container(height: 34, width: double.infinity, color: Colors.grey),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildProductCard(var p, var variant) {
// //     return GestureDetector(
// //       onTap: () => Navigator.push(
// //         context,
// //         MaterialPageRoute(
// //           builder: (context) => Maincategoryproductdetails(selected_data: p, selecteddata_title: ""),
// //         ),
// //       ),
// //       child: Container(
// //         decoration: BoxDecoration(
// //           color: Colors.white,
// //           borderRadius: BorderRadius.circular(18),
// //           boxShadow: [
// //             BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 12, offset: const Offset(0, 4))
// //           ],
// //           border: Border(
// //             right: BorderSide(color: Colors.grey.shade300, width: 3),
// //             bottom: BorderSide(color: Colors.grey.shade300, width: 3),
// //           ),
// //         ),
// //         child: Padding(
// //           padding: const EdgeInsets.all(10),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               Expanded(
// //                 child: Center(
// //                   child: ClipRRect(
// //                     borderRadius: BorderRadius.circular(12),
// //                     child: _safeImage(p['prod_img']),
// //                   ),
// //                 ),
// //               ),
// //               const SizedBox(height: 8),
// //               Text(
// //                 p['name'] ?? "",
// //                 maxLines: 2,
// //                 overflow: TextOverflow.ellipsis,
// //                 style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
// //               ),
// //               if (variant != null) ...[
// //                 const SizedBox(height: 4),
// //                 Row(
// //                   children: [
// //                     Text(
// //                       "₹ ${variant['discounted_price']}",
// //                       style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: custom_color.app_color),
// //                     ),
// //                     const SizedBox(width: 6),
// //                     if (variant['disc_amt'] != "0")
// //                       Text(
// //                         "₹ ${variant['price']}",
// //                         style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 11),
// //                       ),
// //                   ],
// //                 ),
// //               ],
// //               const SizedBox(height: 8),
// //               SizedBox(
// //                 width: double.infinity,
// //                 height: 34,
// //                 child: ElevatedButton(
// //                   onPressed: variant != null && variant['stock_status'] == "Available"
// //                       ? () => Navigator.push(
// //                             context,
// //                             MaterialPageRoute(
// //                               builder: (context) => Maincategoryproductdetails(selected_data: p, selecteddata_title: ""),
// //                             ),
// //                           )
// //                       : null,
// //                   style: ElevatedButton.styleFrom(
// //                     backgroundColor: variant != null && variant['stock_status'] == "Available"
// //                         ? custom_color.button_color
// //                         : Colors.grey,
// //                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
// //                   ),
// //                   child: const Text("Buy Now", style: TextStyle(color: Colors.white)),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _safeImage(String? url) {
// //     String clean = (url ?? "").replaceAll(RegExp(r'(?<!:)//+'), '/');
// //     if (clean.isEmpty || !clean.startsWith('http')) {
// //       return Image.asset("assets/images/AppLogo.png", fit: BoxFit.contain);
// //     }
// //     return Image.network(
// //       clean,
// //       fit: BoxFit.contain,
// //       errorBuilder: (_, __, ___) => Image.asset("assets/images/AppLogo.png", fit: BoxFit.contain),
// //     );
// //   }
// // }



// import 'dart:async';

// import 'package:burmapartner/Dashboard/DashboardApi.dart';
// import 'package:burmapartner/MainCategory/ProductDetails.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:localstorage/localstorage.dart';
// import 'package:shimmer/shimmer.dart';
// import '../Common/colors.dart' as custom_color;

// class SearchPage extends StatefulWidget {
//   const SearchPage({super.key});

//   @override
//   State<SearchPage> createState() => _SearchPageState();
// }

// class _SearchPageState extends State<SearchPage> {
//   final LocalStorage storage = LocalStorage('app_store');
//   final TextEditingController _searchController = TextEditingController();

//   var userResponse;
//   var accesstoken;
//   var customer_id;

//   List results = [];
//   bool isLoading = false;
//   bool hasSearched = false;
//   Timer? _debounce;
//   List<String> _searchHistory = [];

//   @override
//   void initState() {
//     super.initState();
//     _init();
//   }
// void dispose() {
//   _debounce?.cancel();
//   _searchController.dispose();
//   super.dispose();
// }
//   Future<void> _init() async {
//     await storage.ready;
//     userResponse = await storage.getItem('userResponse');
//     if (userResponse != null) {
//       accesstoken = userResponse['api_token'];
//       customer_id = userResponse['customer_id'].toString();
//     }
//     final history = storage.getItem('search_history');
//     if (history != null) {
//       setState(() => _searchHistory = List<String>.from(history));
//     }
//   }

//   void _saveHistory(String keyword) {
//     _searchHistory.remove(keyword);
//     _searchHistory.insert(0, keyword);
//     if (_searchHistory.length > 10) _searchHistory = _searchHistory.sublist(0, 10);
//     storage.setItem('search_history', _searchHistory);
//   }

//   Future<void> _search(String keyword) async {
//     if (keyword.trim().isEmpty) return;
//     setState(() {
//       isLoading = true;
//       hasSearched = true;
//     });

//     var data = {
//      "action": "get_productlist_by_searchterm",
//       "accesskey": "90336",
//       "token": accesstoken,
//       "act_type": userResponse['act_type'].toString(),
//       // "customer_id": customer_id.toString(),
//       "search_term": keyword.trim(),
//     };

//     _saveHistory(keyword.trim());
//     final response = await DashboardApi().SearchProducts(data);
//     setState(() {
//       results = response?['res'] ?? [];
//       isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenHeight = MediaQuery.of(context).size.height;
//     double screenWidth = MediaQuery.of(context).size.width;
//     return PopScope(
//       canPop: false,
//   onPopInvoked: (didPop) async {
//     if (didPop) return;

//     /// clear search
//     if (_searchController.text.isNotEmpty || results.isNotEmpty) {
//       setState(() {
//         _searchController.clear();
//         results.clear();
//         hasSearched = false;
//       });
//     } else {
//       Navigator.pop(context);
//     }
//   },
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           backgroundColor: custom_color.app_color,
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
//             onPressed: () => Navigator.pop(context),
//           ),
//           title: TextField(
//             controller: _searchController,
//             autofocus: true,
//             inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ]'))],
//             style: const TextStyle(color: Colors.white),
//             cursorColor: Colors.white,
//             decoration: const InputDecoration(
//               hintText: "Search products...",
//               hintStyle: TextStyle(color: Colors.white70),
//               border: InputBorder.none,
//             ),
//             // onSubmitted: _search,
//             onChanged: (value) {
//         if (_debounce?.isActive ?? false) _debounce!.cancel();
      
//         _debounce = Timer(const Duration(milliseconds: 500), () {
//       if (value.length >= 3) {
//         _search(value);
//       } else {
//         setState(() {
//           results.clear();
//           hasSearched = false;
//         });
//       }
//         });
//       },
//             textInputAction: TextInputAction.search,
//           ),
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.search, color: Colors.white),
//               onPressed: () => _search(_searchController.text),
//             ),
//           ],
//         ),
//         body: SafeArea(
//           child: isLoading
//               ? _buildShimmer()
//               : !hasSearched
//                   // ? const Center(
//                   //     child: Text("Search for products", style: TextStyle(color: Colors.grey)),
//                   //   )
//                    ? _searchHistory.isEmpty
//                       ? Center(
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Container(
//                                 height: 150,
//                                 width: 150,
//                                 padding: const EdgeInsets.all(28),
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   color: Colors.grey.shade100,
//                                 ),
//                                 child: Image.asset("assets/images/favourites.png"),
//                               ),
//                               const SizedBox(height: 20),
//                               const Text(
//                                 "Search Products",
//                                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//                               ),
//                               const SizedBox(height: 8),
//                               Text(
//                                 "Find your favourite products instantly",
//                                 style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
//                               ),
//                             ],
//                           ),
//                         )
//                       : Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   const Text("Recent Searches",
//                                       style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
//                                   GestureDetector(
//                                     onTap: () {
//                                       storage.deleteItem('search_history');
//                                       setState(() => _searchHistory.clear());
//                                     },
//                                     child: Text("Clear",
//                                         style: TextStyle(color: custom_color.app_color, fontSize: 13)),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Expanded(
//                               child: ListView.builder(
//                                 itemCount: _searchHistory.length,
//                                 itemBuilder: (context, index) {
//                                   final term = _searchHistory[index];
//                                   return ListTile(
//                                     leading: const Icon(Icons.history, color: Colors.grey),
//                                     title: Text(term),
//                                     onTap: () {
//                                       _searchController.text = term;
//                                       _search(term);
//                                     },
//                                     trailing: IconButton(
//                                       icon: const Icon(Icons.close, size: 16, color: Colors.grey),
//                                       onPressed: () {
//                                         setState(() => _searchHistory.removeAt(index));
//                                         storage.setItem('search_history', _searchHistory);
//                                       },
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ),
//                           ],
//                         )
//                 : results.isEmpty
//       ? Center(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 30),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
      
//                 /// IMAGE
//                 Container(
//                   height: 170,
//                   width: 170,
//                   padding: const EdgeInsets.all(25),
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade100,
//                     shape: BoxShape.circle,
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.05),
//                         blurRadius: 18,
//                         offset: const Offset(0, 8),
//                       ),
//                     ],
//                   ),
//                   child: Image.asset(
//                     'assets/images/favourites.png',
//                     fit: BoxFit.contain,
//                   ),
//                 ),
      
//                 const SizedBox(height: 28),
      
//                 /// TITLE
//                 const Text(
//                   "No Products Found",
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
      
//                 const SizedBox(height: 10),
      
//                 /// SUBTITLE
//                 Text(
//                   "We couldn't find any matching products.\nTry searching with another keyword.",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 14,
//                     height: 1.5,
//                     color: Colors.grey.shade600,
//                   ),
//                 ),
      
//                 const SizedBox(height: 30),
      
//                 /// BUTTON
//                 SizedBox(
//                   width: 160,
//                   height: 48,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       _searchController.clear();
      
//                       setState(() {
//                         hasSearched = false;
//                         results.clear();
//                       });
//                     },
//                     style: ElevatedButton.styleFrom(
//                       elevation: 0,
//                       backgroundColor: custom_color.button_color,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14),
//                       ),
//                     ),
//                     child: const Text(
//                       "Search Again",
//                       style: TextStyle(
//                         fontWeight: FontWeight.w600,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         )
//                       : GridView.builder(
//                           padding: const EdgeInsets.all(15),
//                           itemCount: results.length,
//                           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisCount: 2,
//                             mainAxisSpacing: 15,
//                             crossAxisSpacing: 15,
//                             childAspectRatio: 0.62,
//                           ),
//                           itemBuilder: (context, index) {
//                             var p = results[index];
//                             var variant = (p['vars'] != null && p['vars'].length > 0)
//                                 ? p['vars'][0]
//                                 : null;
//                             return _buildProductCard(p, variant);
//                           },
//                         ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProductCard(var p, var variant) {
//     return GestureDetector(
//       onTap: () => Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => Maincategoryproductdetails(selected_data: p, selecteddata_title: ""),
//         ),
//       ),
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(18),
//           boxShadow: [
//             BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 12, offset: const Offset(0, 4))
//           ],
//           border: Border(
//             right: BorderSide(color: Colors.grey.shade300, width: 3),
//             bottom: BorderSide(color: Colors.grey.shade300, width: 3),
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(10),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Expanded(
//                 child: Center(
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(12),
//                     child: _safeImage(p['prod_img']),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 p['name'] ?? "",
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
//               ),
//               if (variant != null) ...[
//                 const SizedBox(height: 4),
//                 Row(
//                   children: [
//                     Text(
//                       "₹ ${variant['discounted_price']}",
//                       style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: custom_color.app_color),
//                     ),
//                     const SizedBox(width: 6),
//                     if (variant['disc_amt'] != "0")
//                       Text(
//                         "₹ ${variant['price']}",
//                         style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 11),
//                       ),
//                   ],
//                 ),
//               ],
//               const SizedBox(height: 8),
//               SizedBox(
//                 width: double.infinity,
//                 height: 34,
//                 child: ElevatedButton(
//                   onPressed: variant != null && variant['stock_status'] == "Available"
//                       ? () => Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => Maincategoryproductdetails(selected_data: p, selecteddata_title: ""),
//                             ),
//                           )
//                       : null,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: variant != null && variant['stock_status'] == "Available"
//                         ? custom_color.button_color
//                         : Colors.grey,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                   ),
//                   child: const Text("Buy Now", style: TextStyle(color: Colors.white)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _shimmerBox({double? width, double? height, double radius = 10}) {
//     return Container(
//       width: width,
//       height: height,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(radius),
//       ),
//     );
//   }

//   Widget _buildShimmer() {
//     final w = MediaQuery.of(context).size.width;
//     final itemW = (w - 15 * 2 - 15) / 2;
//     return Shimmer.fromColors(
//       baseColor: const Color(0xFFDDE4F0),
//       highlightColor: const Color(0xFFEEF3FF),
//       child: GridView.builder(
//         padding: const EdgeInsets.all(15),
//         itemCount: 6,
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           mainAxisSpacing: 15,
//           crossAxisSpacing: 15,
//           childAspectRatio: 0.62,
//         ),
//         itemBuilder: (_, __) => Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(18),
//             border: Border(
//               right: BorderSide(color: Colors.grey.shade300, width: 3),
//               bottom: BorderSide(color: Colors.grey.shade300, width: 3),
//             ),
//           ),
//           child: Column(
//             children: [
//               Expanded(
//                 child: _shimmerBox(width: double.infinity, radius: 18),
//               ),
//               const SizedBox(height: 6),
//               _shimmerBox(width: itemW * 0.6, height: 14, radius: 6),
//               const SizedBox(height: 12),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _safeImage(String? url) {
//     String clean = (url ?? "").replaceAll(RegExp(r'(?<!:)//+'), '/');
//     if (clean.isEmpty || !clean.startsWith('http')) {
//       return Image.asset("assets/images/AppLogo.png", fit: BoxFit.contain);
//     }
//     return Image.network(
//       clean,
//       fit: BoxFit.contain,
//       errorBuilder: (_, __, ___) => Image.asset("assets/images/AppLogo.png", fit: BoxFit.contain),
//     );
//   }
// }
import 'dart:async';
import 'package:burmapartner/Dashboard/DashboardApi.dart';
import 'package:burmapartner/MainCategory/ProductDetails.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localstorage/localstorage.dart';
import 'package:shimmer/shimmer.dart';
import '../Common/colors.dart' as custom_color;

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final LocalStorage storage = LocalStorage('app_store');
  final TextEditingController _searchController = TextEditingController();

  var userResponse;
  var accesstoken;
  var customer_id;

  List results = [];
  bool isLoading = false;
  bool hasSearched = false;
  Timer? _debounce;
  List<String> _searchHistory = [];

  @override
  void initState() {
    super.initState();
    _init();
  }
void dispose() {
  _debounce?.cancel();
  _searchController.dispose();
  super.dispose();
}
  Future<void> _init() async {
    await storage.ready;
    userResponse = await storage.getItem('userResponse');
    if (userResponse != null) {
      accesstoken = userResponse['api_token'];
      customer_id = userResponse['customer_id'].toString();
    }
    final history = storage.getItem('search_history');
    if (history != null) {
      setState(() => _searchHistory = List<String>.from(history));
    }
  }

  void _saveHistory(String keyword) {
    _searchHistory.remove(keyword);
    _searchHistory.insert(0, keyword);
    if (_searchHistory.length > 10) _searchHistory = _searchHistory.sublist(0, 10);
    storage.setItem('search_history', _searchHistory);
  }

  Future<void> _search(String keyword) async {
    if (keyword.trim().isEmpty) return;
    setState(() {
      isLoading = true;
      hasSearched = true;
    });

    var data = {
      "action": "get_productlist_by_searchterm",
      "accesskey": "90336",
      "token": accesstoken,
      "act_type": userResponse['act_type'].toString(),
      "customer_id": customer_id.toString(),
      "keyword": keyword.trim(),
    };

    _saveHistory(keyword.trim());
     final response = await DashboardApi().SearchProducts(data);
    setState(() {
      results = response?['res'] ?? [];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return PopScope(
        canPop: false,
  onPopInvoked: (didPop) async {
    if (didPop) return;

    /// clear search
    if (_searchController.text.isNotEmpty || results.isNotEmpty) {
      setState(() {
        _searchController.clear();
        results.clear();
        hasSearched = false;
      });
    } else {
      Navigator.pop(context);
    }
  },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: custom_color.app_color,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: TextField(
            controller: _searchController,
            autofocus: true,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ]'))],
            style: const TextStyle(color: Colors.white),
            cursorColor: Colors.white,
            decoration: const InputDecoration(
              hintText: "Search products...",
              hintStyle: TextStyle(color: Colors.white70),
              border: InputBorder.none,
            ),
            // onSubmitted: _search,
            onChanged: (value) {
        if (_debounce?.isActive ?? false) _debounce!.cancel();
      
        _debounce = Timer(const Duration(milliseconds: 500), () {
      if (value.length >= 3) {
        _search(value);
      } else {
        setState(() {
          results.clear();
          hasSearched = false;
        });
      }
        });
      },
            textInputAction: TextInputAction.search,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () => _search(_searchController.text),
            ),
          ],
        ),
        body: SafeArea(
          child: isLoading
              ? _buildShimmer()
              : !hasSearched
                  // ? const Center(
                  //     child: Text("Search for products", style: TextStyle(color: Colors.grey)),
                  //   )
                   ? _searchHistory.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 150,
                                width: 150,
                                padding: const EdgeInsets.all(28),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey.shade100,
                                ),
                                child: Image.asset("assets/images/favourites.png"),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                "Search Products",
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Find your favourite products instantly",
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Recent Searches",
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  GestureDetector(
                                    onTap: () {
                                      storage.deleteItem('search_history');
                                      setState(() => _searchHistory.clear());
                                    },
                                    child: Text("Clear",
                                        style: TextStyle(color: custom_color.app_color, fontSize: 13)),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: _searchHistory.length,
                                itemBuilder: (context, index) {
                                  final term = _searchHistory[index];
                                  return ListTile(
                                    leading: const Icon(Icons.history, color: Colors.grey),
                                    title: Text(term),
                                    onTap: () {
                                      _searchController.text = term;
                                      _search(term);
                                    },
                                    trailing: IconButton(
                                      icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                                      onPressed: () {
                                        setState(() => _searchHistory.removeAt(index));
                                        storage.setItem('search_history', _searchHistory);
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        )
                : results.isEmpty
      ? Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
      
                /// IMAGE
                Container(
                  height: 170,
                  width: 170,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/favourites.png',
                    fit: BoxFit.contain,
                  ),
                ),
      
                const SizedBox(height: 28),
      
                /// TITLE
                const Text(
                  "No Products Found",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
      
                const SizedBox(height: 10),
      
                /// SUBTITLE
                Text(
                  "We couldn't find any matching products.\nTry searching with another keyword.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.grey.shade600,
                  ),
                ),
      
                const SizedBox(height: 30),
      
                /// BUTTON
                SizedBox(
                  width: 160,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      _searchController.clear();
      
                      setState(() {
                        hasSearched = false;
                        results.clear();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: custom_color.button_color,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Search Again",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(15),
                          itemCount: results.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 15,
                            crossAxisSpacing: 15,
                            childAspectRatio: 0.55,
                          ),
                          itemBuilder: (context, index) {
                            var p = results[index];
                            var variant = (p['vars'] != null && p['vars'].length > 0)
                                ? p['vars'][0]
                                : null;
                            return _buildProductCard(p, variant);
                          },
                        ),
        ),
      ),
    );
  }

  Widget _buildProductCard(var p, var variant) {
    double screenHeight = MediaQuery.of(context).size.height;
    bool isAvailable = variant != null && variant['stock_status'] == "Available";
    bool hasDiscount = variant != null && variant['disc_amt'] != "0";

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (context) => Maincategoryproductdetails(selected_data: p, selecteddata_title: ""),
      )),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 12, offset: const Offset(0, 4))],
          border: Border(
            right: BorderSide(color: Colors.grey.shade300, width: 3),
            bottom: BorderSide(color: Colors.grey.shade300, width: 3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: SizedBox(
              height: 200,
              width: double.infinity,
              child: Stack(
                children: [
                  Center(child: safeNetworkImage(p['prod_img'], fit: BoxFit.contain)),
                  if (isAvailable && hasDiscount)
                    Positioned(
                      top: 0, left: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.only(bottomRight: Radius.circular(6)),
                        ),
                        child: Text(
                          variant!['disc_type'] == "Amount"
                              ? "₹ ${(double.parse(variant['price'].toString()) - double.parse(variant['discounted_price'].toString())).toStringAsFixed(0)} OFF"
                              : "${(((double.parse(variant['price'].toString()) - double.parse(variant['discounted_price'].toString())) / double.parse(variant['price'].toString())) * 100).round()}% OFF",
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  if (!isAvailable)
                    Positioned(
                      top: 0, right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(6)),
                        ),
                        child: const Text("Out of Stock",
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            ),
          ),
            SizedBox(height: screenHeight*0.01,),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 36,
                      child: Text(p['name'] ?? "", maxLines: 2, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                   SizedBox(height: screenHeight*0.01,),
                    SizedBox(
                      height: 20,
                      child: variant != null
                          ? Row(children: [
                              Text("₹ ${double.tryParse(variant['discounted_price'].toString())?.toStringAsFixed(0) ?? variant['discounted_price']}",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: custom_color.app_color)),
                              const SizedBox(width: 6),
                              if (hasDiscount)
                                Text("₹ ${double.tryParse(variant['price'].toString())?.toStringAsFixed(0) ?? variant['price']}",
                                    style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 11)),
                            ])
                          : const SizedBox(),
                    ),
                    // const Spacer(),
                    SizedBox(height: screenHeight*0.01,),
                    SizedBox(
                      width: double.infinity,
                      height: 34,
                      child: ElevatedButton(
                        onPressed: isAvailable
                            ? () => Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => Maincategoryproductdetails(selected_data: p, selecteddata_title: ""),
                                ))
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isAvailable ? custom_color.button_color : Colors.grey,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(isAvailable ? "Buy Now" : "Unavailable",
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
    final itemW = (w - 15 * 2 - 15) / 2;
    return Shimmer.fromColors(
      baseColor: const Color(0xFFDDE4F0),
      highlightColor: const Color(0xFFEEF3FF),
      child: GridView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: 6,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          childAspectRatio: 0.62,
        ),
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border(
              right: BorderSide(color: Colors.grey.shade300, width: 3),
              bottom: BorderSide(color: Colors.grey.shade300, width: 3),
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: _shimmerBox(width: double.infinity, radius: 18),
              ),
              const SizedBox(height: 6),
              _shimmerBox(width: itemW * 0.6, height: 14, radius: 6),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

 
Widget safeNetworkImage(String? url, {double? width, double? height, BoxFit fit = BoxFit.cover, double borderRadius = 0}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: width,
        height: height,
        child: Image.network(
          url ?? "",
          fit: fit,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(child: Image.asset("assets/images/AppLogo.png", width: 90, height: 90, fit: BoxFit.contain));
          },
          errorBuilder: (context, error, stackTrace) {
            return SizedBox(width: width, height: height, child: Image.asset("assets/images/AppLogo.png", width: 90, height: 90, fit: BoxFit.contain));
          },
        ),
      ),
    );
  }

}
