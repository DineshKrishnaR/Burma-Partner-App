
import 'package:burmapartner/CartPages/Cart.dart';
import 'package:burmapartner/Dashboard/Dashboard.dart';
import 'package:burmapartner/MainCategory/ProductApi.dart';
import 'package:burmapartner/MainCategory/ProductDetails.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:localstorage/localstorage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../Common/colors.dart' as custom_color;

class Homefeaturesectionsubcategory extends StatefulWidget {
  final selected_data;
  const Homefeaturesectionsubcategory({super.key, required this.selected_data});

  @override
  State<Homefeaturesectionsubcategory> createState() => _HomefeaturesectionsubcategoryState();
}

class _HomefeaturesectionsubcategoryState extends State<Homefeaturesectionsubcategory> {

  final LocalStorage storage = LocalStorage('app_store');
  late SharedPreferences pref;

  bool isLoading = false;
  var userResponse;
  var accesstoken;
  var customer_id;
  var selecteddata;
  var subcaragory_product;
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
    Mani_SubCategory = await storage.getItem('Mani_SubCategory');
    if (userResponse != null) {
      accesstoken = userResponse['api_token'];
      customer_id = userResponse['customer_id'].toString();
      selecteddata = widget.selected_data;
    }
    await getHomeSectionSubCategory();
    await loadCartQty();
    setState(() {});
  }

  Future<void> getHomeSectionSubCategory() async {
    setState(() => isLoading = true);
    var data = {
      "action": "get_productlist_by_subcategoryid",
      "accesskey": "90336",
      "token": accesstoken,
      "act_type": userResponse['act_type'],
      "sub_category_id": selecteddata['id'].toString(),
    };
    final response = await Productapi().getHomeSectionSubCategory(data);
    if (response != null) {
      subcaragory_product = response['res'] ?? [];
    } else {
      subcaragory_product = [];
    }
    setState(() => isLoading = false);
  }

  Future<void> loadCartQty() async {
    final box = Hive.box('cart');
    List<dynamic> cartList = box.get('cartItems', defaultValue: []);
    cartQty.clear();
    for (var item in cartList) {
      cartQty[item['product_variant_id'].toString()] = int.parse(item['qty'].toString());
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        Navigator.push(context, MaterialPageRoute(builder: (context) => Dashboard()));
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: custom_color.app_color,
          title: Text(
            selecteddata?['subcategory_name'] ?? "Products",
            style: const TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () async {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Dashboard()));
            },
          ),
          actions: [
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart, color: Colors.white),
                  onPressed: () async {
                    await storage.setItem('homefeaturesubcategory_cart', "homefeaturesubcategory_cart");
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Cart(selected_data: selecteddata, selecteddata_title: ""))).then((_) => loadCartQty());
                  },
                ),
                // if (cartQty.values.fold(0, (sum, qty) => sum + qty) > 0)
                 if (cartQty.length > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: Text(
                        // cartQty.values.fold(0, (sum, qty) => sum + qty).toString(),
                         cartQty.length.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        body: SafeArea(
          child: isLoading
              ? _buildShimmer()
              : (subcaragory_product == null || subcaragory_product.isEmpty)
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 70, color: Colors.grey.shade400),
                          const SizedBox(height: 10),
                          const Text("No Data Found", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey)),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(15),
                      itemCount: subcaragory_product?.length ?? 0,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 15,
                        crossAxisSpacing: 15,
                        childAspectRatio: .8,
                      ),
                      itemBuilder: (context, index) {
                        var p = subcaragory_product[index];
                        var variant = (p['vars'] != null && p['vars'].length > 0) ? p['vars'][0] : null;
                        return buildProductCard(p, variant);
                      },
                    ),
        ),
      ),
    );
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
          childAspectRatio: .8,
        ),
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
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
    String variantId = variant != null ? variant['product_variant_id'].toString() : "";
    int qty = cartQty[variantId] ?? 0;
    return InkWell(
      onTap: () {
        storage.setItem('feature_sub_category', "feature_sub_category");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Maincategoryproductdetails(selected_data: p, selecteddata_title: selecteddata),
          ),
        ).then((value) {
          loadCartQty();
        });
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
              Expanded(
                child: Center(
                  child: safeNetworkImage(p['prod_img'], fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                p['name'] ?? "",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              if (variant != null)
                Text(
                  variant['size'] ?? "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              const SizedBox(height: 6),
              if (variant != null)
                Row(
                  children: [
                    Text(
                      "₹ ${variant['discounted_price']}",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: custom_color.app_color),
                    ),
                    const SizedBox(width: 6),
                    if (variant['disc_amt'] != "0")
                      Text(
                        "₹ ${variant['price']}",
                        style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 11),
                      ),
                  ],
                ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 34,
                child: (variant != null && variant['stock_status'] != "Available")
                    ? ElevatedButton(
                        onPressed: null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Buy Now", style: TextStyle(color: Colors.white)),
                      )
                    : ElevatedButton(
                        onPressed: () {
                          storage.setItem('feature_sub_category', "feature_sub_category");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Maincategoryproductdetails(selected_data: p, selecteddata_title: selecteddata),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: custom_color.button_color,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Buy Now", style: TextStyle(color: Colors.white)),
                      ),
              ),
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
