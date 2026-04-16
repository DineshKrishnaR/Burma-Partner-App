
import 'package:burmapartner/CartPages/Cart.dart';
import 'package:burmapartner/Dashboard/Dashboard.dart';
import 'package:burmapartner/MainCategory/MainCategorytoSubCategory.dart';
import 'package:burmapartner/MainCategory/ProductApi.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:localstorage/localstorage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Common/colors.dart' as custom_color;

class Maincategorytocategory extends StatefulWidget {
  final selected_data;
  const Maincategorytocategory({super.key,required this.selected_data});

  @override
  State<Maincategorytocategory> createState() => _MaincategorytocategoryState();
}

class _MaincategorytocategoryState extends State<Maincategorytocategory> {

final LocalStorage storage = new LocalStorage('app_store');
 
  late SharedPreferences pref;
  

  bool isLoading = false;
  var userResponse;
  var accesstoken;
  var customer_id;
  var aboutus_us;
  var selecteddata;
  var Mani_SubCategory;
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
      await ManiCategorytoCategory();
      await loadCartQty();
      setState(() {});
  }
  Future<void> ManiCategorytoCategory() async {
    setState(() => isLoading = true);
   var data = {
         "action": "get_categorylist_by_maincategory_id",
         "accesskey":"90336",
         "token":accesstoken,
         "act_type":userResponse['act_type'],
         "main_category_id":selecteddata['main_category_id'].toString(),
   };
    final response = await Productapi().ManiCategorytoCategory(data);

    print(response);

    if(response != null){
      Mani_SubCategory = response['data'] ?? [];
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
          title: Text("Category",style: TextStyle(color: Colors.white),),
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
                  await storage.setItem('maincategorytocat_cart',"maincategorytocat_cart");
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Cart(selected_data : selecteddata,selecteddata_title : ""))).then((_) => loadCartQty());
                },
              ),
              if (cartQty.values.fold(0, (sum, qty) => sum + qty) > 0)
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
                      cartQty.values.fold(0, (sum, qty) => sum + qty).toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
            ]
        ),
body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/AppLogo.png",
                    width: 100,
                    height: 100,
                  ),
                  const SizedBox(height: 20),
                   CircularProgressIndicator(color: custom_color.app_color,),
                ],
              ),
            ): Mani_SubCategory == null || Mani_SubCategory.isEmpty
        ? Center(
            child: Text(
              "No Sub Categories Found",
              style: TextStyle(fontSize: 16),
            ),
          )
          : GridView.builder(
  padding: const EdgeInsets.all(15),
  itemCount: Mani_SubCategory.length,
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    mainAxisSpacing: 15,
    crossAxisSpacing: 15,
    childAspectRatio: .9,
  ),
  itemBuilder: (context, index) {
      
    var cat = Mani_SubCategory[index];

    return GestureDetector(
      onTap: ()async {
  print(cat);
 
        Navigator.push(context, MaterialPageRoute(builder: (context)=>Maincategorytosubcategory(selected_data: cat,)));

      },

      child: Container(
        // decoration: BoxDecoration(
        //   color: Colors.white,
        //   borderRadius: BorderRadius.circular(18),
        //   boxShadow: [
        //     BoxShadow(
        //       color: Colors.black.withOpacity(.05),
        //       blurRadius: 12,
        //       offset: const Offset(0, 4),
        //     )
        //   ],
        // ),
decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),

    // Right & Bottom light shadow
    boxShadow: [
      BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
        
    ],

    // Optional border for sharp edge effect
    border: Border(
      right: BorderSide(
        color: Colors.grey.shade300,
        // color: custom_color.app_color.withOpacity(0.3),
        width: 3,
      ),
      bottom: BorderSide(
        color: Colors.grey.shade300,
        // color: custom_color.app_color.withOpacity(0.3), 
        width: 3,
      ),
    ),
  ),
        child: Column(
          children: [

            /// CATEGORY IMAGE
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: safeNetworkImage(
                  cat['img'],
                  fit: BoxFit.cover,
                ),
              ),
            ),

            /// CATEGORY NAME
            // Padding(
            //   padding: const EdgeInsets.all(10),
            //   child: Text(
            //     cat['name'] ?? "",
            //     maxLines: 2,
            //   overflow: TextOverflow.ellipsis,
            //     textAlign: TextAlign.center,
            //     style: const TextStyle(
            //       fontWeight: FontWeight.w600,
            //       fontSize: 14,
            //     ),
            //   ),
            // ),
            Container(
  height: 45, // ✅ fixed space for 2 lines
  alignment: Alignment.center,
  padding: const EdgeInsets.symmetric(horizontal: 8),
  child: Text(
    cat['name'] ?? "",
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
    textAlign: TextAlign.center,
    style: const TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 14,
    ),
  ),
),
          ],
        ),
      ),
    );
  },
)
      ));
  }

// Widget buildProductCard(var p, var variant) {
//   String variantId = variant['product_variant_id'].toString();
// int qty = cartQty[variantId] ?? 0;
//   return Container(
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(18),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(.05),
//           blurRadius: 12,
//           offset: const Offset(0, 4),
//         )
//       ],
//     ),
//     child: Padding(
//       padding: const EdgeInsets.all(10),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [

//           /// PRODUCT IMAGE
//           Expanded(
//             child: Center(
//               child: safeNetworkImage(
//                 p['prod_img'],
//                 fit: BoxFit.contain,
//               ),
//             ),
//           ),

//           const SizedBox(height: 8),

//           /// PRODUCT NAME
//           Text(
//             p['name'] ?? "",
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//             style: const TextStyle(
//               fontWeight: FontWeight.w600,
//               fontSize: 13,
//             ),
//           ),
//         //  SizedBox(height: 1),
//           if (variant != null)
//             Text(
//               variant['size'] ?? "",
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(
//                 fontSize: 11,
//                 color: Colors.grey,
//               ),
//             ),
//           const SizedBox(height: 6),

//           /// PRICE
//           if (variant != null)
//             Row(
//               children: [
//                 Text(
//                   "₹ ${variant['discounted_price']}",
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 14,
//                     color: custom_color.app_color,
//                   ),
//                 ),
//                 const SizedBox(width: 6),

//                 if (variant['disc_amt'] != "0")
//                   Text(
//                     "₹ ${variant['price']}",
//                     style: const TextStyle(
//                       decoration: TextDecoration.lineThrough,
//                       color: Colors.grey,
//                       fontSize: 11,
//                     ),
//                   ),
//               ],
//             ),

//           const SizedBox(height: 8),

//           /// ADD TO CART BUTTON
//           // SizedBox(
//           //   width: double.infinity,
//           //   height: 34,
//           //   child: ElevatedButton(
//           //     onPressed: variant != null &&
//           //             variant['stock_status'] != "Sold Out"
//           //         ? () {
//           //             print("Add ${p['product_id']}");
//           //           }
//           //         : null,
//           //     style: ElevatedButton.styleFrom(
//           //       backgroundColor: custom_color.app_color,
//           //       elevation: 2,
//           //       shape: RoundedRectangleBorder(
//           //         borderRadius: BorderRadius.circular(10),
//           //       ),
//           //     ),
//           //     child: const Text(
//           //       "Add to Cart",
//           //       style: TextStyle(fontSize: 13, color: Colors.white),
//           //     ),
//           //   ),
//           // ),
//           SizedBox(
//   width: double.infinity,
//   height: 34,
//   child: qty == 0
//       ? ElevatedButton(
//           onPressed: () {
//             updateCart(variantId, 1);
//           },
//           style: ElevatedButton.styleFrom(
//             backgroundColor: custom_color.app_color,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//           child: const Text(
//             "Add",
//             style: TextStyle(color: Colors.white),
//           ),
//         )
//       : Container(
//           decoration: BoxDecoration(
//             color: custom_color.app_color,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               GestureDetector(
//                 onTap: () {
//                   updateCart(variantId, qty - 1);
//                 },
//                 child: const Icon(Icons.remove, color: Colors.white),
//               ),
//               Text(
//                 qty.toString(),
//                 style: const TextStyle(
//                     color: Colors.white, fontWeight: FontWeight.bold),
//               ),
//               GestureDetector(
//                 onTap: () {
//                   updateCart(variantId, qty + 1);
//                 },
//                 child: const Icon(Icons.add, color: Colors.white),
//               ),
//             ],
//           ),
//         ),
// )
//         ],
//       ),
//     ),
//   );
// }
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