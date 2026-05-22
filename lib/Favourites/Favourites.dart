
// import 'package:burmapartner/Dashboard/HomePage.dart';
// import 'package:burmapartner/MainCategory/ProductDetails.dart';
// import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:localstorage/localstorage.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:shimmer/shimmer.dart';
// import '../Common/colors.dart' as custom_color;

// class Favourites extends StatefulWidget {
//   const Favourites({super.key});

//   @override
//   State<Favourites> createState() => _FavouritesState();
// }

// class _FavouritesState extends State<Favourites> {

//   final LocalStorage storage = LocalStorage('app_store');

//   late SharedPreferences pref;

//   bool isLoading = false;
//   var userResponse;
//   var accesstoken;
//   var customer_id;
//   List favorites_list = [];
//   String sizeText = "";
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

//     await _loadFavourites();
//   }

//   Future<void> _loadFavourites() async {
//     final box = await Hive.openBox('favorites_list');
//     List<dynamic> favList = box.get('favorites', defaultValue: []);
//     setState(() {
//       favorites_list = favList.map((e) => e['product_data']).toList();
//     });
//   }

//   Future<void> removeFavorite(String productId) async {

//   final box = await Hive.openBox('favorites_list');

//   List<dynamic> favList = box.get('favorites', defaultValue: []);

//   favList.removeWhere(
//     (item) => item['product_data']?['product_id']?.toString() == productId
//   );

//   await box.put('favorites', favList);

//   setState(() {
//     favorites_list = favList.map((e) => e['product_data']).toList();
//   });

// }
//   @override
//   Widget build(BuildContext context) {
//     double screenHeight = MediaQuery.of(context).size.height;
//     double screenWidth = MediaQuery.of(context).size.width;
    
//     return PopScope(
//       canPop: false,
//       onPopInvoked: (didPop) {
//         Navigator.push(context, MaterialPageRoute(builder: (context)=>Homepage()));
//       },
//       child: Scaffold(
//          appBar: AppBar(
//         backgroundColor: custom_color.app_color,
//         title: const Text("Favourites", style: TextStyle(color: Colors.white)),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
//           onPressed: () {
//             Navigator.push(context,
//                 MaterialPageRoute(builder: (context) => Homepage()));
//           },
//         ),
//       ),
//       backgroundColor: const Color(0xFFF1F3F6),
//       body: SafeArea(
//         child: isLoading
//             ? _buildShimmer()
//             : favorites_list.isEmpty
//           //       ? Center(
//           //           child: Column(
//           //             mainAxisAlignment: MainAxisAlignment.center,
//           //             children: [
//           //                Container(
//           //   height: screenWidth * 0.45,
//           //   width: screenWidth * 0.45,
//           //   padding: EdgeInsets.all(screenWidth * 0.04),

//           //   decoration: BoxDecoration(
//           //     color: Colors.grey.shade100,
//           //     shape: BoxShape.circle,
//           //     boxShadow: [
//           //       BoxShadow(
//           //         color: Colors.black.withOpacity(0.05),
//           //         blurRadius: 15,
//           //         offset: const Offset(0, 6),
//           //       ),
//           //     ],
//           //   ),

//           //   child: Image.asset(
//           //     'assets/images/favourites.png',
//           //     fit: BoxFit.contain,
//           //   ),
//           // ),
//           //               // Icon(Icons.favorite_border, size: 70, color: Colors.grey.shade400),
//           //               // const SizedBox(height: 10),
//           //               // const Text(
//           //               //   "No Favourites Yet",
//           //               //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey),
//           //               // ),
//           //               // const SizedBox(height: 5),
//           //               // const Text("Start adding products to favourites ❤️", style: TextStyle(color: Colors.grey)),
//           //             ],
//           //           ),
//           //         )
//           ? Center(
//     child: Padding(
//       padding: EdgeInsets.symmetric(
//         horizontal: screenWidth * 0.08,
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [

//           /// IMAGE
//           Container(
//             height: screenWidth * 0.42,
//             width: screenWidth * 0.42,
//             padding: EdgeInsets.all(screenWidth * 0.045),

//             decoration: BoxDecoration(
//               color: Colors.grey.shade100,
//               shape: BoxShape.circle,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 18,
//                   offset: const Offset(0, 8),
//                 ),
//               ],
//             ),

//             child: Image.asset(
//               'assets/images/favourites.png',
//               fit: BoxFit.contain,
//             ),
//           ),

//           SizedBox(height: screenHeight * 0.035),

//           /// TITLE
//           const Text(
//             "No Favourites Yet",
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//             ),
//           ),

//           SizedBox(height: screenHeight * 0.012),

//           /// SUBTITLE
//           Text(
//             "Start adding your favourite products\nand access them quickly anytime.",
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 15,
//               color: Colors.grey.shade600,
//               height: 1.5,
//             ),
//           ),

//         ],
//       ),
//     ),
//   )
//                 : GridView.builder(
//                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
//                     itemCount: favorites_list.length,
//                     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 2,
//                       mainAxisSpacing: 10,
//                       crossAxisSpacing: 10,
//                       childAspectRatio: 0.62,
//                     ),
//                     itemBuilder: (context, index) {
//                       var p = favorites_list[index];
//                       var variant = (p['vars'] != null && p['vars'].length > 0) ? p['vars'][0] : null;
//                       if (variant != null && variant['size'] != null) {
//                         sizeText = variant['size'].toString().split(',')[0].trim();
//                       }
//                       return buildProductCard(p, variant);
//                     },
//                   ),
//       ),
//       ),
//     );
//   }

// Widget buildProductCard(var p, var variant) {
//   String productId = p['product_id']?.toString() ?? "";
//   bool isAvailable = variant != null && variant['stock_status'] == "Available";
//   bool hasDiscount = variant != null && variant['disc_amt'] != "0";

//   String discountLabel = "";
//   if (hasDiscount && variant != null) {
//     try {
//       double original = double.parse(variant['price'].toString());
//       double discounted = double.parse(variant['discounted_price'].toString());
//       if (original > 0) {
//         int pct = ((original - discounted) / original * 100).round();
//         discountLabel = "$pct% off";
//       }
//     } catch (_) {}
//   }

//   return InkWell(
//     onTap: () async {
//       await storage.setItem('favourites_page', "favourites_page");
//       Navigator.push(context, MaterialPageRoute(
//         builder: (context) => Maincategoryproductdetails(selected_data: p, selecteddata_title: ""),
//       )).then((_) => _loadFavourites());
//     },
//     child: Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         boxShadow: [
//           BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 2))
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           /// IMAGE with badges
//           Stack(
//             children: [
//               ClipRRect(
//                 borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
//                 child: AspectRatio(
//                   aspectRatio: 1.2,
//                   child: safeNetworkImage(p['prod_img'], fit: BoxFit.contain),
//                 ),
//               ),
//               if (discountLabel.isNotEmpty)
//                 Positioned(
//                   top: 8, left: 8,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
//                     decoration: BoxDecoration(color: Colors.green.shade600, borderRadius: BorderRadius.circular(4)),
//                     child: Text(discountLabel, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
//                   ),
//                 ),
//               // Positioned(
//               //   top: 6, right: 6,
//               //   child: GestureDetector(
//               //     onTap: () async {
//               //       bool? confirm = await showDialog(
//               //         context: context,
//               //         builder: (context) => AlertDialog(
//               //           title: const Text("Remove Favourite"),
//               //           content: const Text("Are you sure you want to remove this item?"),
//               //           actions: [
//               //             TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
//               //             TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Remove")),
//               //           ],
//               //         ),
//               //       );
//               //       if (confirm == true) removeFavorite(variantId);
//               //     },
//               //     child: Container(
//               //       padding: const EdgeInsets.all(4),
//               //       decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle,
//               //         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]),
//               //       child: const Icon(Icons.favorite, color: Colors.red, size: 16),
//               //     ),
//               //   ),
//               // ),
//               Positioned(
//                     top: 10,
//                     right: 10,
//                     child: Container(
//                       padding: const EdgeInsets.all(7),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         shape: BoxShape.circle,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.10),
//                             blurRadius: 8,
//                             offset: const Offset(0, 3),
//                           ),
//                         ],
//                       ),
//                       child: GestureDetector(
//                         onTap: () => removeFavorite(productId),
//                         child: const Icon(
//                           Icons.favorite_rounded,
//                           color: Colors.red,
//                           size: 20,
//                         ),
//                       ),
//                     ),
//                   ),
//               if (!isAvailable)
//                 Positioned(
//                   top: 8, left: 8,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
//                     decoration: BoxDecoration(color: Colors.red.shade600, borderRadius: BorderRadius.circular(4)),
//                     child: const Text("Out of Stock", style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
//                   ),
//                 ),
//             ],
//           ),

//           Padding(
//             padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(
//                   height: 32,
//                   child: Text(
//                     p['name'] ?? "",
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
//                   ),
//                 ),
//                 if (sizeText.isNotEmpty) ...[  
//                   const SizedBox(height: 2),
//                   Text("Size: $sizeText", style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
//                 ],
//                 const SizedBox(height: 4),
//                 if (variant != null) ...[  
//                   Text(
//                     "₹${variant['discounted_price']}",
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: custom_color.app_color),
//                   ),
//                   if (hasDiscount)
//                     Row(
//                       children: [
//                         Text("₹${variant['price']}",
//                           style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 10)),
//                         const SizedBox(width: 4),
//                         Text(discountLabel,
//                           style: TextStyle(fontSize: 10, color: Colors.green.shade700, fontWeight: FontWeight.w600)),
//                       ],
//                     ),
//                 ],
//                 const SizedBox(height: 6),
//                 SizedBox(
//                     width: double.infinity,
//                     height: 30,
//                     child: ElevatedButton(
//                       onPressed: isAvailable
//                           ? () async {
//                               await storage.setItem('favourites_page', "favourites_page");
//                               Navigator.push(context, MaterialPageRoute(
//                                 builder: (context) => Maincategoryproductdetails(selected_data: p, selecteddata_title: ""),
//                               )).then((_) => _loadFavourites());
//                             }
//                           : null,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: isAvailable ? custom_color.button_color : Colors.grey.shade400,
//                         elevation: 0,
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
//                         padding: EdgeInsets.zero,
//                       ),
//                       child: Text(
//                         isAvailable ? "Buy Now" : "Unavailable",
//                         style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }

// Widget _shimmerBox({double? width, double? height, double radius = 4}) {
//     return Container(
//       width: width,
//       height: height,
//       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(radius)),
//     );
//   }

//   Widget _buildShimmer() {
//     return Shimmer.fromColors(
//       baseColor: const Color(0xFFE8ECF0),
//       highlightColor: const Color(0xFFF5F7FA),
//       child: GridView.builder(
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
//         itemCount: 6,
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           mainAxisSpacing: 10,
//           crossAxisSpacing: 10,
//           childAspectRatio: 0.62,
//         ),
//         itemBuilder: (_, __) => Container(
//           decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               AspectRatio(
//                 aspectRatio: 1.2,
//                 child: Container(
//                   decoration: const BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _shimmerBox(width: double.infinity, height: 13),
//                     const SizedBox(height: 6),
//                     _shimmerBox(width: 80, height: 11),
//                     const SizedBox(height: 6),
//                     _shimmerBox(width: 60, height: 16),
//                     const SizedBox(height: 6),
//                     _shimmerBox(width: double.infinity, height: 30),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

// Widget _fallbackImage({double? width, double? height}) {
//   return Container(
//     width: width ?? double.infinity,
//     height: height,
//     color: Colors.grey.shade100,
//     child: Center(
//       child: Image.asset("assets/images/AppLogo.png", fit: BoxFit.contain, width: 60),
//     ),
//   );
// }

// Widget safeNetworkImage(
//   String? url, {
//   double? width,
//   double? height,
//   BoxFit fit = BoxFit.contain,
//   double borderRadius = 0,
// }) {
//   final validUrl = url != null && url.trim().isNotEmpty;
//   return ClipRRect(
//     borderRadius: BorderRadius.circular(borderRadius),
//     child: SizedBox(
//       width: width ?? double.infinity,
//       height: height,
//       child: validUrl
//           ? Image.network(
//               url!,
//               fit: fit,
//               loadingBuilder: (context, child, loadingProgress) {
//                 if (loadingProgress == null) return child;
//                 return _fallbackImage(width: width, height: height);
//               },
//               errorBuilder: (context, error, stackTrace) =>
//                   _fallbackImage(width: width, height: height),
//             )
//           : _fallbackImage(width: width, height: height),
//     ),
//   );
// }
// }

import 'package:burmapartner/Dashboard/HomePage.dart';
import 'package:burmapartner/MainCategory/ProductDetails.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:localstorage/localstorage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../Common/colors.dart' as custom_color;

class Favourites extends StatefulWidget {
  const Favourites({super.key});

  @override
  State<Favourites> createState() => _FavouritesState();
}

class _FavouritesState extends State<Favourites> {

  final LocalStorage storage = LocalStorage('app_store');

  late SharedPreferences pref;

  bool isLoading = false;
  var userResponse;
  var accesstoken;
  var customer_id;
  List favorites_list = [];
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
    final box = await Hive.openBox('favorites_list');

    List<dynamic> favList = box.get('favorites', defaultValue: []);

    setState(() {
      // Store the full fav item so we have the saved product_variant_id
      favorites_list = List<dynamic>.from(favList);
    });

  }

  Future<void> removeFavorite(String productId) async {

    final box = await Hive.openBox('favorites_list');

    List<dynamic> favList = List<dynamic>.from(box.get('favorites', defaultValue: []));

    favList.removeWhere(
      (item) => item['product_id'].toString() == productId,
    );

    await box.put('favorites', favList);

    setState(() {
      favorites_list = List<dynamic>.from(favList);
    });

  }
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>Homepage()));
      },
      child: Scaffold(
         appBar: AppBar(
        backgroundColor: custom_color.app_color,
        title: const Text("Favourites", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => Homepage()));
          },
        ),
      ),
      backgroundColor: const Color(0xFFF1F3F6),
      body: SafeArea(
        child: isLoading
            ? _buildShimmer()
            : favorites_list.isEmpty
                // ? Center(
                //     child: Column(
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       children: [
                //         Icon(Icons.favorite_border, size: 70, color: Colors.grey.shade400),
                //         const SizedBox(height: 10),
                //         const Text(
                //           "No Favourites Yet",
                //           style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey),
                //         ),
                //         const SizedBox(height: 5),
                //         const Text("Start adding products to favourites ❤️", style: TextStyle(color: Colors.grey)),
                //       ],
                //     ),
                //   )
                 ? Center(
    child: Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.08,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          /// IMAGE
          Container(
            height: screenWidth * 0.42,
            width: screenWidth * 0.42,
            padding: EdgeInsets.all(screenWidth * 0.045),

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

          SizedBox(height: screenHeight * 0.035),

          /// TITLE
          const Text(
            "No Favourites Yet",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: screenHeight * 0.012),

          /// SUBTITLE
          Text(
            "Start adding your favourite products\nand access them quickly anytime.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),

        ],
      ),
    ),
  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    itemCount: favorites_list.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.55,
                    ),
                    itemBuilder: (context, index) {
                      var favItem = favorites_list[index];
                      var p = favItem['product_data'];
                      String productId = favItem['product_id'].toString();
                      var variant = (p['vars'] != null && (p['vars'] as List).isNotEmpty)
                          ? p['vars'][0]
                          : null;
                      return buildProductCard(p, variant, productId);
                    },
                  ),
      ),
      ),
    );
  }

Widget buildProductCard(var p, var variant, String productId) {
  double screenHeight = MediaQuery.of(context).size.height;
  bool isAvailable = variant != null && variant['stock_status'] == "Available";
  bool hasDiscount = variant != null && variant['disc_amt'] != "0";
  String sizeText = (variant != null && variant['size'] != null)
      ? variant['size'].toString().split(',')[0].trim()
      : "";

  String discountLabel = "";
  if (hasDiscount && variant != null) {
    try {
      double original = double.parse(variant['price'].toString());
      double discounted = double.parse(variant['discounted_price'].toString());
      if (original > 0) {
        int pct = ((original - discounted) / original * 100).round();
        discountLabel = "$pct% off";
      }
    } catch (_) {}
  }

  return InkWell(
    borderRadius: BorderRadius.circular(10),
    onTap: () async {
      await storage.setItem('favourites_page', "favourites_page");
       Navigator.push(context, MaterialPageRoute(
                                builder: (context) => Maincategoryproductdetails(selected_data: p, selecteddata_title: ""),
                              )).then((_) => initPreferencess());
    },
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
          /// IMAGE — fixed height
          SizedBox(
            height: 200,
            width: double.infinity,
            child: Stack(
              children: [
                Center(
                  child: safeNetworkImage(p['prod_img'], fit: BoxFit.contain),
                ),
                if (discountLabel.isNotEmpty && isAvailable)
                  Positioned(
                    top: 6, left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(color: Colors.green.shade600, borderRadius: BorderRadius.circular(4)),
                      child: Text(discountLabel, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ),
                if (!isAvailable)
                  Positioned(
                    top: 6, left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(color: Colors.red.shade600, borderRadius: BorderRadius.circular(4)),
                      child: const Text("Out of Stock", style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ),
                Positioned(
                  top: 6, right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 6)],
                    ),
                    child: const Icon(Icons.favorite_rounded, color: Colors.red, size: 18),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: screenHeight*0.01,),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// NAME — always reserves 2-line height
                  SizedBox(
                    height: 36,
                    child: Text(
                      p['name'] ?? "",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                  SizedBox(height: screenHeight*0.01,),
                  /// PRICE — always reserves 1-line height
                  SizedBox(
                    height: 20,
                    child: variant != null
                        ? Row(
                            children: [
                              Text(
                                "₹ ${variant['discounted_price']}",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: custom_color.app_color),
                              ),
                              const SizedBox(width: 6),
                              if (hasDiscount)
                                Text(
                                  "₹ ${variant['price']}",
                                  style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 11),
                                ),
                            ],
                          )
                        : const SizedBox(),
                  ),
                  // const Spacer(),
                  /// BUTTON — always at bottom
                  SizedBox(height: screenHeight*0.01,),
                  SizedBox(
                    width: double.infinity,
                    height: 34,
                    child: ElevatedButton(
                      onPressed: isAvailable
                          ? () async {
                              await storage.setItem('favourites_page', "favourites_page");
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) => Maincategoryproductdetails(selected_data: p, selecteddata_title: ""),
                              )).then((_) => initPreferencess());
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAvailable ? custom_color.button_color : Colors.grey,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        isAvailable ? "Buy Now" : "Unavailable",
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
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

Widget _shimmerBox({double? width, double? height, double radius = 4}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(radius)),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE8ECF0),
      highlightColor: const Color(0xFFF5F7FA),
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        itemCount: 6,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.45,
        ),
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1.1,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBox(width: double.infinity, height: 13),
                    const SizedBox(height: 6),
                    _shimmerBox(width: 80, height: 11),
                    const SizedBox(height: 8),
                    _shimmerBox(width: 60, height: 16),
                    const SizedBox(height: 8),
                    _shimmerBox(width: double.infinity, height: 34),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

Widget _fallbackImage({double? width, double? height}) {
  return Container(
    width: width ?? double.infinity,
    height: height,
    color: Colors.grey.shade100,
    child: Center(
      child: Image.asset("assets/images/AppLogo.png", fit: BoxFit.contain, width: 60),
    ),
  );
}

Widget safeNetworkImage(
  String? url, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.contain,
  double borderRadius = 0,
}) {
  final validUrl = url != null && url.trim().isNotEmpty;
  return ClipRRect(
    borderRadius: BorderRadius.circular(borderRadius),
    child: SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: validUrl
          ? Image.network(
              url!,
              fit: fit,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _fallbackImage(width: width, height: height);
              },
              errorBuilder: (context, error, stackTrace) =>
                  _fallbackImage(width: width, height: height),
            )
          : _fallbackImage(width: width, height: height),
    ),
  );
}
}