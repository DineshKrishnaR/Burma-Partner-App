
import 'package:burmapartner/CartPages/Cart.dart';
import 'package:burmapartner/Dashboard/Dashboard.dart';
import 'package:burmapartner/MainCategory/ProductApi.dart';
import 'package:burmapartner/MainCategory/ProductDetails.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:localstorage/localstorage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../Common/colors.dart' as custom_color;

class Homefeaturesectionproductgrid extends StatefulWidget {
  final selected_data;
  const Homefeaturesectionproductgrid({super.key,required this.selected_data});

  @override
  State<Homefeaturesectionproductgrid> createState() => _HomefeaturesectionproductgridState();
}

class _HomefeaturesectionproductgridState extends State<Homefeaturesectionproductgrid> {

final LocalStorage storage = new LocalStorage('app_store');
 
  late SharedPreferences pref;
  

  bool isLoading = false;
  var userResponse;
  var accesstoken;
  var customer_id;
  var aboutus_us;
  var selecteddata;
  var section_product;
  Map<String, int> cartQty = {};
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
    selecteddata = widget.selected_data;
  }
      await getSectionProducts();
      await loadCartQty();
      setState(() {});
  }
  Future<void> getSectionProducts() async {
    setState(() => isLoading = true);
   var data = {
         "action": "get_products_by_section_item",
         "accesskey":"90336",
         "token":accesstoken,
         "act_type":userResponse['act_type'],
         "section_id":selecteddata['section_id'].toString(),
         "section_item_id":selecteddata['section_item_id'].toString()
   };
    final response = await Productapi().getHomeSectionProductGrid(data);

    print(response);

    if(response != null){
      section_product = response['res'] ?? [];
   

    setState(() => isLoading = false);
  }
 }

 Future<void> loadCartQty() async {
  final box = Hive.box('cart');

  List<dynamic> cartList = box.get('cartItems', defaultValue: []);

  cartQty.clear();

  for (var item in cartList) {
    cartQty[item['product_variant_id'].toString()] =
        int.parse(item['qty'].toString());
  }

  setState(() {});
}

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>Dashboard()));
      },
      child: Scaffold(
         appBar: AppBar(
          backgroundColor: custom_color.app_color,
          title: Text(selecteddata?['title'] ?? "Products",style: TextStyle(color: Colors.white),),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios,color: Colors.white,),
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>Dashboard()));
            },
          ),
           actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                onPressed: () async{
                  await storage.setItem('homefeatureproductgrid_cart',"homefeatureproductgrid_cart");
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Cart(selected_data : selecteddata,selecteddata_title : ""))).then((_) => loadCartQty());
                },
              ),
              // if (cartQty.values.fold(0, (sum, qty) => sum + qty) > 0)
               if (cartQty.length > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      // cartQty.values.fold(0, (sum, qty) => sum + qty).toString(),
                       cartQty.length.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
            ]
        ),
body: SafeArea(
  child: isLoading
            ? _buildShimmer()
            : (section_product == null || section_product.isEmpty)
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            "No Products Found",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade500),
                          ),
                         
                        ],
                      ),
                    )
            : GridView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: section_product?.length ?? 0,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.55,
                ),
                itemBuilder: (context, index) {
  
                  var p = section_product[index];
  
                  var variant = (p['vars'] != null && p['vars'].length > 0)
                      ? p['vars'][0]
                      : null;
  
                  return buildProductCard(p, variant);
                },
              ),
),
      ));
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: 6,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          childAspectRatio: 0.72,
        ),
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 8),
                Container(width: double.infinity, height: 13, color: Colors.white),
                const SizedBox(height: 6),
                Container(width: 80, height: 12, color: Colors.white),
                const SizedBox(height: 6),
                Container(width: 70, height: 14, color: Colors.white),
                const SizedBox(height: 8),
                Container(width: double.infinity, height: 34, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10))),
              ],
            ),
          ),
        ),
      ),
    );
  }

Widget buildProductCard(var p, var variant) {
  double screenHeight = MediaQuery.of(context).size.height;
  String variantId = variant != null ? variant['product_variant_id'].toString() : "";
  bool isAvailable = variant != null && variant['stock_status'] == "Available";
  bool hasDiscount = variant != null && variant['disc_amt'] != "0";

  return InkWell(
    onTap: () async {
      await storage.setItem('section_product',"section_product");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Maincategoryproductdetails(selected_data: p,selecteddata_title: selecteddata,),
        ),
      );
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
                          ? () async {
                                         await storage.setItem('section_product',"section_product");
                 Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Maincategoryproductdetails(selected_data: p,selecteddata_title: selecteddata,),
                  ),
                );
                            }
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
Widget buildProductCard1(var p, var variant) {
   double screenHeight = MediaQuery.of(context).size.height;
  String variantId = variant != null ? variant['product_variant_id'].toString() : "";
  bool isAvailable = variant != null && variant['stock_status'] == "Available";
  bool hasDiscount = variant != null && variant['disc_amt'] != "0";

int qty = cartQty[variantId] ?? 0;
  return InkWell(
    
    onTap: ()async {
       await storage.setItem('section_product',"section_product");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Maincategoryproductdetails(selected_data: p,selecteddata_title: selecteddata,),
        ),
      );
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
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
    
            /// PRODUCT IMAGE
            // Expanded(
            //   child: Center(
            //     child: safeNetworkImage(
            //       p['prod_img'],
            //       fit: BoxFit.contain,
            //     ),
            //   ),
            // ),
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
    
//             const SizedBox(height: 8),
    
//             /// PRODUCT NAME
//              SizedBox(
//   height: 36,
//   child: Text(
//     p['name'] ?? "",
//     maxLines: 2,
//     overflow: TextOverflow.ellipsis,
//     style: const TextStyle(
//       fontWeight: FontWeight.w600,
//       fontSize: 13,
//       height: 1.3,
//       color: Colors.black87,
//     ),
//   ),
// ),
//           //  SizedBox(height: 1),
//             // if (variant != null)
//             //   Text(
//             //     variant['size'] ?? "",
//             //     maxLines: 1,
//             //     overflow: TextOverflow.ellipsis,
//             //     style: const TextStyle(
//             //       fontSize: 11,
//             //       color: Colors.grey,
//             //     ),
//             //   ),
//             const SizedBox(height: 6),
    
//             /// PRICE
//             if (variant != null)
//               Row(
//                 children: [
//                   Text(
//                     "₹ ${variant['discounted_price']}",
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 14,
//                       color: custom_color.app_color,
//                     ),
//                   ),
//                   const SizedBox(width: 6),
    
//                   if (variant['disc_amt'] != "0")
//                     Text(
//                       "₹ ${variant['price']}",
//                       style: const TextStyle(
//                         decoration: TextDecoration.lineThrough,
//                         color: Colors.grey,
//                         fontSize: 11,
//                       ),
//                     ),
//                 ],
//               ),
    
//             const SizedBox(height: 8),
    
//             SizedBox(
//   width: double.infinity,
//   height: 34,
//   child:  (variant != null &&
//         // (variant['stock_status'] == "Sold Out" ||
//         //  variant['stock_status'] == "No Stock" || variant['stock_status'] == "Shop Closed" || variant['stock_status'] == "Not Available"))?
//          (variant['stock_status'] != "Available"))?
//                         ElevatedButton(
                         
//           onPressed: null,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.grey,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
         
//            child:  Text(
//            "Buy Now",
//             style: const TextStyle(color: Colors.white),
//           ),
//         )
//          : ElevatedButton(
//               onPressed: () async{
//                 // updateCart(variantId, 1);
//                 await storage.setItem('section_product',"section_product");
//                  Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => Maincategoryproductdetails(selected_data: p,selecteddata_title: selecteddata,),
//                   ),
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: custom_color.button_color,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               child: const Text(
//                 "Buy Now",
//                 style: TextStyle(color: Colors.white),
//               ),
//             )
         
// )
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
                          ? () async {
                            await storage.setItem('section_product',"section_product");
                 Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Maincategoryproductdetails(selected_data: p,selecteddata_title: selecteddata,),
                  ),
                );
                            }
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
          return Center(
            child: Image.asset(
              "assets/images/AppLogo.png",
              width: 90,
              height: 90,
              fit: BoxFit.contain,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return SizedBox(
            width: width,
            height: height,
            child: Image.asset(
              "assets/images/AppLogo.png",
              // fit: fit,
               width: 90,
              height: 90,
              fit: BoxFit.contain,
            ),
          );
        },
      ),
    ),
  );
}
}