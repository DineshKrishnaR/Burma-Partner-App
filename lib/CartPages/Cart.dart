
import 'dart:convert';
import 'dart:math';

import 'package:burmapartner/CartPages/CartApi.dart';
import 'package:burmapartner/CartPages/CheckOut.dart';
import 'package:burmapartner/Common/Utils.dart';
import 'package:burmapartner/Dashboard/Dashboard.dart';
import 'package:burmapartner/Dashboard/DashboardApi.dart';
import 'package:burmapartner/Dashboard/HomePage.dart';
import 'package:burmapartner/HomeFeatureSections/HomeFeatureSectionMainCat.dart';
import 'package:burmapartner/HomeFeatureSections/HomeFeatureSectionProductGrid.dart';
import 'package:burmapartner/HomeFeatureSections/HomeFeatureSectionSubCategory.dart';
import 'package:burmapartner/HomeFeatureSections/HomeFeatureSectionsCategory.dart';
import 'package:burmapartner/MainCategory/MainCategorytoCategory.dart';
import 'package:burmapartner/MainCategory/MainCategorytoSubCategory.dart';
import 'package:burmapartner/MainCategory/MainSubCattoProduct.dart';
import 'package:burmapartner/MainCategory/ProductDetails.dart';
import 'package:burmapartner/ProfilePage/ProfilePageApi.dart';
import 'package:burmapartner/RefereCustomer/RefereCusApi.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart';
import 'package:localstorage/localstorage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../Common/colors.dart' as custom_color;

// Shared input formatters
final _cartNoEmoji = FilteringTextInputFormatter.allow(RegExp(r'[\x20-\x7E\u00A0-\u024F]'));
final _cartNoLeadingSpace = TextInputFormatter.withFunction((old, newVal) {
  if (newVal.text.startsWith(' ')) return old;
  return newVal;
});

class Cart extends StatefulWidget {
  final selected_data;
  final selecteddata_title;
  const Cart({super.key ,required this.selected_data,required this.selecteddata_title});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {

  final LocalStorage storage = LocalStorage('app_store');
  TextEditingController nameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController address2Controller = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController areaController = TextEditingController();
  TextEditingController pinController = TextEditingController();
  TextEditingController landmarkController = TextEditingController();


  TextEditingController editnameController = TextEditingController();
  TextEditingController editmobileController = TextEditingController();
  TextEditingController editaddressController = TextEditingController();
  TextEditingController editaddress2Controller = TextEditingController();
  TextEditingController editcityController = TextEditingController();
  TextEditingController editstateController = TextEditingController();
  TextEditingController editareaController = TextEditingController();
  TextEditingController editpinController = TextEditingController();
  TextEditingController editlandmarkController = TextEditingController();

  late SharedPreferences pref;

  bool isLoading = false;

  var userResponse;
  var accesstoken;
  var customer_id;
  var wallet_amount;
  var user_details;
  // var delivery_charges;
  List view_cart_data = [];
  List cartItems = [];
  List get_address = [];
  List StateList = [];
  int? selectedAddressIndex;

  double delivery_charges = 0;
  double gst_percentage = 0;
  double totalAmount = 0;
  bool isDataLoaded = false;
  
  //Customer Based
  String orderType = "myself";
  List customerList = [];
  Map<String, dynamic>? selectedCustomer;
  /////
  int limit = 100;
  int offset = 0;
  ScrollController _scrollController = ScrollController();
  bool isMoreLoading = false;
  bool hasMoreData = true;
  
  Map<String, dynamic>? myAddress;



  var selecteddatatitle;
  var selecteddata;
  var dashboard_cart;
  var maincategorytocat_cart;
  var maincategorytosub_cart;
  var mainsubcattoproduct_cart;
  var productdetails_cart;
  var homefeatureproductgrid_cart;
  var homefeaturemaincat_cart;
  var homefeaturecategory_cart;
  var homefeaturesubcategory_cart;
  @override
  void initState() {
    super.initState();
    initPreferencess();
  }

  initPreferencess() async {

    await storage.ready;

    final box = await Hive.openBox('cart');

    pref = await SharedPreferences.getInstance();

    userResponse = await storage.getItem('userResponse');
    dashboard_cart = await storage.getItem('dashboard_cart');
    maincategorytocat_cart = await storage.getItem('maincategorytocat_cart');
    maincategorytosub_cart = await storage.getItem('maincategorytosub_cart');
    mainsubcattoproduct_cart = await storage.getItem('mainsubcattoproduct_cart');
    productdetails_cart = await storage.getItem('productdetails_cart');
    homefeatureproductgrid_cart = await storage.getItem('homefeatureproductgrid_cart');
    homefeaturemaincat_cart = await storage.getItem('homefeaturemaincat_cart');
    homefeaturecategory_cart = await storage.getItem('homefeaturecategory_cart');
    homefeaturesubcategory_cart = await storage.getItem('homefeaturesubcategory_cart');

    // Ensure only ONE source key is active — clear all others to prevent stale navigation
    final List<String> allCartKeys = [
      'dashboard_cart', 'maincategorytocat_cart', 'maincategorytosub_cart',
      'mainsubcattoproduct_cart', 'productdetails_cart', 'homefeatureproductgrid_cart',
      'homefeaturemaincat_cart', 'homefeaturecategory_cart', 'homefeaturesubcategory_cart',
    ];
    final Map<String, dynamic> activeValues = {
      'dashboard_cart': dashboard_cart,
      'maincategorytocat_cart': maincategorytocat_cart,
      'maincategorytosub_cart': maincategorytosub_cart,
      'mainsubcattoproduct_cart': mainsubcattoproduct_cart,
      'productdetails_cart': productdetails_cart,
      'homefeatureproductgrid_cart': homefeatureproductgrid_cart,
      'homefeaturemaincat_cart': homefeaturemaincat_cart,
      'homefeaturecategory_cart': homefeaturecategory_cart,
      'homefeaturesubcategory_cart': homefeaturesubcategory_cart,
    };
    // Count how many keys are set — if more than one, clear all (stale state)
    int activeCount = activeValues.values.where((v) => v != null).length;
    if (activeCount > 1) {
      for (var key in allCartKeys) {
        await storage.deleteItem(key);
      }
      dashboard_cart = maincategorytocat_cart = maincategorytosub_cart =
          mainsubcattoproduct_cart = productdetails_cart = homefeatureproductgrid_cart =
          homefeaturemaincat_cart = homefeaturecategory_cart = homefeaturesubcategory_cart = null;
    }
    cartItems = box.get('cartItems', defaultValue: []);

    selecteddata = widget.selected_data;
    selecteddatatitle = widget.selecteddata_title;

    if (userResponse != null) {
      accesstoken = userResponse['api_token'];
      customer_id = userResponse['customer_id'].toString();
    }
    
    await ProfileDetails();
   
    await getAddress();
  //   var savedAddress = await storage.getItem('selected_address');
  // if (savedAddress != null) {
  //   user_details = savedAddress;
  // }
  myAddress = Map<String, dynamic>.from(user_details ?? {});

// ✅ THEN override with selected address if exists
var savedAddress = await storage.getItem('selected_address');

if (savedAddress != null) {
  user_details = Map<String, dynamic>.from(savedAddress);
  myAddress = Map<String, dynamic>.from(savedAddress); // 🔥 IMPORTANT
}
    await WalletDetails();
    await getViewCart();
    calculateTotal(); 
    await DeliveryCharges();
    await gerStateList();
    await getCustomersList();

    // Restore orderType
    var savedOrderType = await storage.getItem('order_user_type');
    if (savedOrderType != null) {
      orderType = savedOrderType.toString();
    }

    // Restore selectedCustomer and their address
    if (orderType == "customer") {
      var savedCustomer = await storage.getItem('selected_customer');
      if (savedCustomer != null) {
        selectedCustomer = Map<String, dynamic>.from(savedCustomer);
        await gerCustomerDetails(selectedCustomer!);
      }
    }

    setState(() {
      isDataLoaded = true;
    });
  }
void calculateTotal() {

  totalAmount = 0;

  for (var item in view_cart_data) {
    totalAmount += double.parse(item['amt'].toString());
  }

}



 Future<void> getCustomersList({bool isLoadMore = false}) async {
  if (isLoadMore) {
    setState(() => isMoreLoading = true);
  } else {
    setState(() => isLoading = true);
  }
 var data = {
         "action": "get_customer",
         "accesskey":"90336",
         "customer_id": customer_id,
         "token": accesstoken,
         "act_type": userResponse['act_type'],
         "limit": limit.toString(),
         "offset": offset.toString(),
   };
    final response = await Referecusapi().getCustomersList(data);

  if (response != null && response['res'] != null) {
    List newData = response['res'];

    if (newData.length < limit) {
      hasMoreData = false; // no more data
    }

    if (isLoadMore) {
      customerList.addAll(newData);
    } else {
      customerList = newData;
    }
  }

  setState(() {
    isLoading = false;
    isMoreLoading = false;
  });
}
  /// GET CART
//   Future<void> getViewCart() async {

//     // setState(() => isLoading = true);

//     var data = {
//       "action": "view_cart",
//       "accesskey": "90336",
//       "cart_items": jsonEncode(cartItems),
//       "customer_id": customer_id,
//       "token": accesstoken,
//       "act_type": userResponse['act_type'],
//     };

//     final response = await Cartapi().getViewCart(data);

//     // if (response != null) {
//     //   view_cart_data = response['res'] ?? [];
//     // } else {
//     //   view_cart_data = [];
//     // }
//  if (response != null && (response['res'] as List).isNotEmpty) {
//       view_cart_data = response['res'] ?? [];
//     } else {
//       /// fallback: use locally stored cart details from Hive
//       view_cart_data = cartItems.where((item) => item['product_name'] != null).toList();
//     }
//     setState(() => isLoading = false);
//   }
/// GET CART
Future<void> getViewCart() async {

  var data = {
    "action": "view_cart",
    "accesskey": "90336",
    "cart_items": jsonEncode(cartItems),
    "customer_id": customer_id,
    "token": accesstoken,
    "act_type": userResponse['act_type'],
  };

  final response = await Cartapi().getViewCart(data);

  print("GET CART RESPONSE : $response");

  /// 🔥 INVALID ACCESS / SESSION EXPIRED
  if (response != null &&
      response['code'] == 401) {

    Fluttertoast.showToast(
      msg: "Session expired. Please login again",
    );

    /// CLEAR STORAGE
    // await storage.deleteItem('userResponse');

    // /// OPTIONAL CLEAR
    // await storage.deleteItem('selected_address');
    // await storage.deleteItem('selected_customer');

    /// LOGOUT
    Helper().logout(context);

    return;
  }

  /// SUCCESS
  if (response != null &&
      response['status'] == "success" &&
      (response['res'] as List).isNotEmpty) {

    setState(() {
      view_cart_data = response['res'] ?? [];
    });

  }

  /// LOCAL FALLBACK
  else {

    setState(() {
      view_cart_data = cartItems
          .where(
            (item) =>
                item['product_name'] != null,
          )
          .toList();
    });
  }

  setState(() {
    isLoading = false;
  });
}
 Future<void> gerStateList() async {
    // setState(() => isLoading = true);
   var data = {
         "action": "get_state",
         "accesskey":"90336",
         "token":accesstoken,
   };
    final response = await Profilepageapi().gerStateList(data);

    print(response);

    if(response != null){
      StateList = response['res'] ?? [];
      

    // setState(() => isLoading = false);
  }
 }
  Future<void> DeliveryCharges() async {

  // Guard: skip if no address state available
  final state = user_details?['state']?.toString() ?? '';
  if (state.isEmpty) return;

  var data = {
    "accesskey": "90336",
    "cart_items": jsonEncode(cartItems),
    "fin_amt": totalAmount.toString(),   // FIX
    "token": accesstoken.toString(),     // safe
    "state": user_details['state'].toString(),
    "act_type": userResponse['act_type'].toString(),
  };

  final response = await Cartapi().DeliveryCharges(data);

  if (response != null) {
    setState(() {
      // delivery_charges = double.parse(response['deliv_charge'].toString());
      // gst_percentage = double.parse(response['gst_percentage'].toString());
      delivery_charges = double.tryParse(
        response['deliv_charge']?.toString() ?? "0") ?? 0;

gst_percentage = double.tryParse(
        response['gst_percentage']?.toString() ?? "0") ?? 0;
    });
  }
}
  /// UPDATE QTY
  // Future<void> updateCart(int index, int newQty) async {

  //   final box = Hive.box('cart');

  //   if (newQty <= 0) {
  //     cartItems.removeAt(index);
  //   } else {
  //     cartItems[index]['qty'] = newQty.toString();
  //   }

  //   await box.put('cartItems', cartItems);

  //   await getViewCart();
  // }

Future<void> updateCart(String variantId, int qty) async {

  final box = Hive.box('cart');
/// ❗ MIN QTY CHECK (Correct)
//   if (currentQty == 0 && newQty > 0 && newQty < minQty) {
//   newQty = minQty;
//   Fluttertoast.showToast(msg: "Minimum order is $minQty");
// }

// // if (newQty > 0 && newQty < minQty && newQty < currentQty) {
// //   Fluttertoast.showToast(msg: "Minimum order is $minQty");
// // }
// if (newQty > 0 && newQty < minQty && newQty < currentQty) {
//   Fluttertoast.showToast(msg: "Minimum order is $minQty");
//   return;
// }
  var data = {
    "action": "check_stock",
    "product_variant_id": variantId,
    "qty": qty.toString(),
    "accesskey": "90336",
    "token": accesstoken,
    "act_type": userResponse['act_type'],
    "customer_id": customer_id,
  };

  var stockResponse = await Cartapi().CheckStock(data);

  if (stockResponse == null) return;

  if (stockResponse['stock_status'] == "No Stock") {
    Fluttertoast.showToast(msg: "Product out of stock");
    return;
  }

  int stockQty = int.parse(stockResponse['stock_qty']);

  if (qty > stockQty) {
    Fluttertoast.showToast(msg: "Only $stockQty items available");
    return;
  }

  List<dynamic> cartList = box.get('cartItems', defaultValue: []);

  int index = cartList.indexWhere(
      (item) => item['product_variant_id'].toString() == variantId);

  if (index != -1) {

    if (qty <= 0) {
      cartList.removeAt(index);
    } else {
      cartList[index]['qty'] = qty.toString();
    }

  } else {

    if (qty > 0) {
      cartList.add({
        "product_variant_id": variantId,
        "qty": qty.toString(),
      });
    }

  }

  await box.put('cartItems', cartList);

  cartItems = cartList;

  await getViewCart();
}

 Future<void> ProfileDetails() async {
    // setState(() => isLoading = true);
   var data = {
         "action": "get_profile",
         "customer_id":customer_id,
         "accesskey":"90336",
         "token":accesstoken,
         "act_type":userResponse['act_type'],
   };
    final response = await DashboardApi().ProfileDetails(data);

    print(response);

    if(response != null){
      user_details = response ?? [];
   print(user_details);

    // setState(() => isLoading = false);
  }
 }
 Future<void> getAddress() async {

  var data = {
    "action": "get_address",
    "accesskey": "90336",
    "customer_id": customer_id,
    "act_type": userResponse['act_type'].toString(),
    "token": accesstoken.toString(), 
    
  };

  final response = await Cartapi().getAddress(data);

 if (response != null) {
      get_address = response['res'] ?? [];
    } else {
      get_address = [];
    }
}

 Future<void> WalletDetails() async {
    // setState(() => isLoading = true);
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
   

    // setState(() => isLoading = false);
  }
 }




Future<void> getAddressSelectedCustomer(Map<String, dynamic> selectedCustomer) async {

  var data = {
    "action": "get_address",
    "accesskey": "90336",
    "customer_id": selectedCustomer['customer_id'],
    "act_type": userResponse['act_type'].toString(),
    "token": accesstoken.toString(), 
  };

  final response = await Cartapi().getAddress(data);

  if (response != null) {
    setState(() {
      get_address = response['res'] ?? [];

      /// 🔥 IMPORTANT: set first address automatically
      if (get_address.isNotEmpty) {
        user_details = Map.from(get_address[0]);
      } else {
        user_details = {}; // no address
      }
    });
  } else {
    setState(() {
      get_address = [];
      user_details = {};
    });
  }
}
//  Future<void> deleteCartItem(int index) async {
//   final box = Hive.box('cart');

//   setState(() {
//     cartItems.removeAt(index);
//   });

//   await box.put('cartItems', cartItems);

//   await getViewCart();
// }
Future<void> deleteCartItem(String variantId) async {

  final box = Hive.box('cart');

  cartItems.removeWhere(
    (item) => item['product_variant_id'].toString() == variantId,
  );

  await box.put('cartItems', cartItems);

  await getViewCart();

  calculateTotal();

  await DeliveryCharges();

  setState(() {});
}
  /// SAFE IMAGE
  Widget safeNetworkImage(String? url) {

    if (url == null || url.isEmpty) {
      return Image.asset("assets/images/AppLogo.png", width: 90, height: 90);
    }

    return Image.network(
      url,
      width: 90,
      height: 90,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset("assets/images/AppLogo.png", width: 90, height: 90);
      },
    );
  }


var customer_details;
 Future<void> gerCustomerDetails(value) async {
    setState(() => isLoading = true);
   var data = {
         "action": "get_customer_dtl",
         "accesskey":"90336",
         "customer_id":customer_id.toString(),
         "cust_id":value['customer_id'].toString(),
         "token":accesstoken,
         "act_type": userResponse['act_type'],
   };
    final response = await Referecusapi().gerCustomerDetails(data);

     print(response);

  if (response != null && response['res'] != null) {

    /// ✅ FIX: directly assign to user_details
    setState(() {
      user_details = Map<String, dynamic>.from(response['res'][0]);
    });

  }

  setState(() => isLoading = false);
 }
  @override
  Widget build(BuildContext context) {
double screenHeight = MediaQuery.of(context).size.height;
double screenWidth = MediaQuery.of(context).size.width;
   

    // for (var item in view_cart_data) {
    //   totalAmount += double.parse(item['amt'].toString());
    // }
// double subTotal = 0;

// for (var item in view_cart_data) {
//   subTotal += double.parse(item['amt'].toString());
// }

// double gst = (subTotal * gst_percentage) / 100;

// double totalAmount = subTotal + gst + delivery_charges;
double subTotalExcl = 0;
double gstTotal = 0;

for (var item in view_cart_data) {

  double amt = double.tryParse(item['amt'].toString()) ?? 0;
  double gstPercent = double.tryParse(item['gst_percentage'].toString()) ?? 0;

  double basePrice = 0;
  double gstAmount = 0;

  if (item['gst_enabled'] == "1" && gstPercent > 0) {

    /// ✅ REMOVE GST FROM AMOUNT (IMPORTANT)
    basePrice = amt / (1 + gstPercent / 100);
    gstAmount = amt - basePrice;

  } else {
    basePrice = amt;
  }

  subTotalExcl += basePrice;
  gstTotal += gstAmount;
}
// double totalAmount = subTotal + gstTotal + delivery_charges;

// double deliveryBase = delivery_charges;
// double deliveryGST = 0;

// if (gst_percentage > 0) {
//   deliveryBase = delivery_charges / (1 + gst_percentage / 100);
//   deliveryGST = delivery_charges - deliveryBase;
// }
double subTotalIncl = subTotalExcl + gstTotal;
// double totalAmount = subTotalIncl + delivery_charges;
double totalAmount =
    (subTotalIncl + delivery_charges).roundToDouble();

double deliveryBase = 0;
double deliveryGST = 0;

if (delivery_charges > 0 && gst_percentage > 0) {
  deliveryBase = delivery_charges / (1 + gst_percentage / 100);
  deliveryGST = delivery_charges - deliveryBase;
}

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        if(dashboard_cart == "dashboard_cart"){
           Navigator.push(context, MaterialPageRoute(builder: (context)=>Dashboard()));
           await storage.deleteItem('dashboard_cart');
        }else if(maincategorytocat_cart == "maincategorytocat_cart"){
           Navigator.push(context, MaterialPageRoute(builder: (context)=>Maincategorytocategory(selected_data: selecteddata,)));
           await storage.deleteItem('maincategorytocat_cart');
        }else if(maincategorytosub_cart == "maincategorytosub_cart"){
           Navigator.push(context, MaterialPageRoute(builder: (context)=>Maincategorytosubcategory(selected_data: selecteddata,)));
           await storage.deleteItem('maincategorytosub_cart');
        }else if(mainsubcattoproduct_cart == "mainsubcattoproduct_cart"){
           Navigator.push(context, MaterialPageRoute(builder: (context)=>Mainsubcattoproduct(selected_data: selecteddata,selecteddata_title: selecteddatatitle ,)));
           await storage.deleteItem('mainsubcattoproduct_cart');
        }else if(productdetails_cart == "productdetails_cart"){
           await storage.deleteItem('productdetails_cart');
           Navigator.pop(context);
        }else if(homefeatureproductgrid_cart == "homefeatureproductgrid_cart"){
           Navigator.push(context, MaterialPageRoute(builder: (context)=>Homefeaturesectionproductgrid(selected_data: selecteddata,)));
           await storage.deleteItem('homefeatureproductgrid_cart');
        }else if(homefeaturemaincat_cart == "homefeaturemaincat_cart"){
           Navigator.push(context, MaterialPageRoute(builder: (context)=>Homefeaturesectionmaincat(selected_data: selecteddata,)));
           await storage.deleteItem('homefeaturemaincat_cart');
        }else if(homefeaturecategory_cart == "homefeaturecategory_cart"){
           Navigator.push(context, MaterialPageRoute(builder: (context)=>Homefeaturesectionscategory(selected_data: selecteddata,)));
           await storage.deleteItem('homefeaturecategory_cart');
        }else if(homefeaturesubcategory_cart == "homefeaturesubcategory_cart"){
           Navigator.push(context, MaterialPageRoute(builder: (context)=>Homefeaturesectionsubcategory(selected_data: selecteddata,)));
           await storage.deleteItem('homefeaturesubcategory_cart');
        }else{
          await storage.deleteItem('dashboard_cart');
          await storage.deleteItem('maincategorytocat_cart');
          await storage.deleteItem('maincategorytosub_cart');
          await storage.deleteItem('mainsubcattoproduct_cart');
          await storage.deleteItem('productdetails_cart');
          await storage.deleteItem('homefeatureproductgrid_cart');
          await storage.deleteItem('homefeaturemaincat_cart');
          await storage.deleteItem('homefeaturecategory_cart');
          await storage.deleteItem('homefeaturesubcategory_cart');
          Navigator.push(context, MaterialPageRoute(builder: (context)=>Homepage()));
        }
      },
      child: Scaffold(
      
        appBar: AppBar(
          backgroundColor: custom_color.app_color,
          title: const Text("Cart", style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios,color: Colors.white),
            onPressed: ()async {
             if(dashboard_cart == "dashboard_cart"){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>Dashboard()));
                await storage.deleteItem('dashboard_cart');
              }else if(maincategorytocat_cart == "maincategorytocat_cart"){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>Maincategorytocategory(selected_data: selecteddata,)));
                await storage.deleteItem('maincategorytocat_cart');
              }else if(maincategorytosub_cart == "maincategorytosub_cart"){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>Maincategorytosubcategory(selected_data: selecteddata,)));
                await storage.deleteItem('maincategorytosub_cart');
              }else if(mainsubcattoproduct_cart == "mainsubcattoproduct_cart"){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>Mainsubcattoproduct(selected_data: selecteddata,selecteddata_title: selecteddatatitle,)));
                await storage.deleteItem('mainsubcattoproduct_cart');
              }else if(productdetails_cart == "productdetails_cart"){
                await storage.deleteItem('productdetails_cart');
                Navigator.pop(context);
              }else if(homefeatureproductgrid_cart == "homefeatureproductgrid_cart"){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>Homefeaturesectionproductgrid(selected_data: selecteddata,)));
                await storage.deleteItem('homefeatureproductgrid_cart');
              }else if(homefeaturemaincat_cart == "homefeaturemaincat_cart"){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>Homefeaturesectionmaincat(selected_data: selecteddata,)));
                await storage.deleteItem('homefeaturemaincat_cart');
              }else if(homefeaturecategory_cart == "homefeaturecategory_cart"){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>Homefeaturesectionscategory(selected_data: selecteddata,)));
                await storage.deleteItem('homefeaturecategory_cart');
              }else if(homefeaturesubcategory_cart == "homefeaturesubcategory_cart"){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>Homefeaturesectionsubcategory(selected_data: selecteddata,)));
                await storage.deleteItem('homefeaturesubcategory_cart');
              }else{
                 await storage.deleteItem('dashboard_cart');
                 await storage.deleteItem('maincategorytocat_cart');
                 await storage.deleteItem('maincategorytosub_cart');
                 await storage.deleteItem('mainsubcattoproduct_cart');
                 await storage.deleteItem('productdetails_cart');
                 await storage.deleteItem('homefeatureproductgrid_cart');
                 await storage.deleteItem('homefeaturemaincat_cart');
                 await storage.deleteItem('homefeaturecategory_cart');
                 await storage.deleteItem('homefeaturesubcategory_cart');
                 Navigator.push(context, MaterialPageRoute(builder: (context)=>Homepage()));
              }
            },
          ),
        ),
      
        body: SafeArea(
          child: !isDataLoaded
               ? _buildShimmer()
              : view_cart_data.isEmpty
              ? emptyCartUI()
              : Scaffold(
            backgroundColor: Colors.grey.shade100,
            // bottomNavigationBar: _buildPriceSummary(subTotalExcl, gstTotal, subTotalIncl, deliveryBase, deliveryGST, totalAmount),
            
            body: SingleChildScrollView(
            child: Column(
            children: [
              
            Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              // color: Colors.grey.shade200,
              
              borderRadius: BorderRadius.circular(18),
              color: Colors.white,
                border: Border(
                 right: BorderSide(
                color: Colors.grey.shade300, // light color
                width: 2.5,
              ),
              bottom: BorderSide(
                color: Colors.grey.shade300, // light color
                width: 2.5,
              ),
            ),
            ),
            child: Column(
              children: [
          
                /// 🔹 MYSELF / CUSTOMER
                Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              children: [
                Radio(
                  value: "myself",
                  groupValue: orderType,
                  activeColor: custom_color.app_color,
                  // onChanged: (value) {
                  //   setState(() {
                  //     orderType = value!;
                  //   });
                  // },
                  // onChanged: (value) async {
                  //   setState(() {
                  //     orderType = value!;
                  //   });
          
                  //   if (value == "myself") {
                  //     // 🔥 Restore your own address
                  //     await ProfileDetails();  // OR getAddress()
          
                  //     var savedAddress = await storage.getItem('selected_address');
          
                  //     if (savedAddress != null) {
                  //       user_details = savedAddress;
                  //     }
                  //   }
                  // }
                  onChanged: (value) {
                    setState(() {
                      orderType = value!;
                      user_details = Map<String, dynamic>.from(myAddress ?? {});
                      selectedCustomer = null;
                    });
                    storage.setItem('order_user_type', "myself");
                    storage.deleteItem('selected_customer');
                  }
                ),
                Text("Myself"),
              ],
            ),
          
            Row(
              children: [
                Radio(
                  value: "customer",
                  groupValue: orderType,
                  activeColor: custom_color.app_color,
                  onChanged: (value) async {
                    setState(() {
                      orderType = value!;
                      selectedCustomer = null;
                      user_details = {};
                    });
                    storage.setItem('order_user_type', "customer");
                    await getCustomersList();
                  },
                ),
                Text("Customer"),
              ],
            ),
          ],
                ),
          
                /// 🔥 CUSTOMER SECTION
                if (orderType == "customer") ...[
          
            const SizedBox(height: 10),
          
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: custom_color.app_color,
          // color: custom_color.button_color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: customerList.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                "No Customers Found",
                style: TextStyle(color: Colors.white),
              ),
            )
          : DropdownButton<Map<String, dynamic>>(
              value: selectedCustomer != null && customerList.isNotEmpty
                  ? customerList.cast<Map<String, dynamic>>().firstWhere(
                      (c) => c['customer_id'].toString() == selectedCustomer!['customer_id'].toString(),
                      orElse: () => selectedCustomer!,
                    )
                  : null,
          
              hint: Text(
                "Select Customer",
                style: TextStyle(color: Colors.white),
              ),
          
              dropdownColor: custom_color.app_color,
              isExpanded: true,
              underline: SizedBox(),
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.white),
          
              items: customerList.map((customer) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: customer,
                  child: Text(
                    customer['name'] ?? "",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
          
              onChanged: (value) async {
                setState(() {
                  selectedCustomer = value;
                });
                if (value != null) {
                  await storage.setItem('selected_customer', value);
                  await gerCustomerDetails(value);
                }
              },
            ),
            ),
          ],
              ],
            ),
          ),
          
              /// ADDRESS CARD
              if (orderType == "myself")
                _buildMyAddressCard(),
          /// 👉 CUSTOMER ADDRESS
          /// 👉 CUSTOMER ADDRESS
          if (orderType == "customer" && selectedCustomer != null)
          
          // Container(
          //   margin: const EdgeInsets.all(16),
          //   padding: const EdgeInsets.all(16),
          //   decoration: BoxDecoration(
          //     // color: Colors.grey.shade200,
          //     borderRadius: BorderRadius.circular(18),
          //      color: Colors.white,
          //       border: Border(
          //        right: BorderSide(
          //       color: Colors.grey.shade300, // light color
          //       width: 2.5,
          //     ),
          //     bottom: BorderSide(
          //       color: Colors.grey.shade300, // light color
          //       width: 2.5,
          //     ),
          //   ),
          //   ),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          
          //       const Text(
          // "Address :",
          // style: TextStyle(
          //   fontSize: 20,
          //   fontWeight: FontWeight.bold,
          //   color: Colors.green,
          // ),
          //       ),
          
          //       const SizedBox(height: 12),
          
          //       /// ✅ NAME (from selected customer)
          //       Row(
          // children: [
          //   const SizedBox(width: 80, child: Text("Name")),
          //   Text(selectedCustomer!['name'] ?? ""),
          // ],
          //       ),
          
          //       const SizedBox(height: 6),
          
          //       /// ✅ ADDRESS (from user_details)
          //       if (user_details != null && user_details.isNotEmpty)
          // Row(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: [
          //     const SizedBox(width: 80, child: Text("Address",style: TextStyle(fontWeight: FontWeight.bold),)),
          //     Expanded(
          //       child: Text(
          //         "${user_details['address'] ?? ""}, ${user_details['address2'] ?? ""}\n"
          //         "${user_details['city'] ?? ""}, ${user_details['state'] ?? ""}\n"
          //         "${user_details['pin'] ?? ""}",
          //       ),
          //     ),
          //   ],
          // )
          //       else
          // const Text("No Address Found"),
          
          //       const SizedBox(height: 6),
          
          //       /// ✅ MOBILE
          //       Row(
          // children: [
          //   const SizedBox(width: 80, child: Text("Mobile",style: TextStyle(fontWeight: FontWeight.bold),)),
          //   Text(user_details['mobile'] ?? ""),
          // ],
          //       ),
          
          //       const SizedBox(height: 12),
          
          //       // Row(
          //       //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //       //   children: [
          
          //       //     ElevatedButton(
          //       //       style: ElevatedButton.styleFrom(
          //       //         backgroundColor: custom_color.button_color,
          //       //       ),
          //       //       onPressed: () async {
          //       //         await gerCustomerDetails(selectedCustomer!);
          //       //         showAddressDialog();
          //       //       },
          //       //       child: const Text("Choose Address1",
          //       //           style: TextStyle(color: Colors.white)),
          //       //     ),
          //       //   ],
          //       // )
          //     ],
          //   ),
          // ),
                 Container(
                      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
                              Icon(Icons.location_on, color: custom_color.app_color, size: 20),
                              const SizedBox(width: 6),
                              const Text("Delivery Address", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Divider(height: 1),
                          const SizedBox(height: 10),
                          _addressRow(Icons.person_outline, user_details['name'] ?? ""),
                          const SizedBox(height: 6),
                          _addressRow(Icons.home_outlined,
                            "${user_details['address']}, ${user_details['address2']}\n"
                            "${user_details['city']}, ${user_details['state']} - ${user_details['pin']}"),
                          const SizedBox(height: 6),
                          _addressRow(Icons.phone_outlined, user_details['mobile'] ?? ""),
                        ],
                      ),
                    ),
              /// PRODUCT LIST
              ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: view_cart_data.length,
                  itemBuilder: (context,index){
                
                    var item = view_cart_data[index];
                
                    return InkWell(
                      onTap: (){
                        print('object');
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Maincategoryproductdetails(selected_data: item, selecteddata_title: "")));
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal:16,vertical:8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          // color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(18),
                           color: Colors.white,
                                      border: Border(
                                       right: BorderSide(
                                      color: Colors.grey.shade300, // light color
                                      width: 2.5,
                                    ),
                                    bottom: BorderSide(
                                      color: Colors.grey.shade300, // light color
                                      width: 2.5,
                                    ),
                                  ),
                        ),
                                      
                        child: Row(
                          children: [
                                      
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                      
                                  Text(item['product_name'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                      
                                  SizedBox(height:6),
                                Row(
                                  children: [
                                    Text("Size : ",style: TextStyle(fontWeight: FontWeight.bold),),
                                    Text("${item['size']}"),
                                  ],
                                ),
                                 Row(
                                  children: [
                                    Text("Quantity : ",style: TextStyle(fontWeight: FontWeight.bold),),
                                    Text("${item['qty']}"),
                                  ],
                                ),
                                 Row(
                                  children: [
                                    Text("Price : ",style: TextStyle(fontWeight: FontWeight.bold),),
                                    Text("${item['discounted_price']}"),
                                  ],
                                ),
                                  // Text("Size : ${item['size']}"),
                                  // Text("Quantity : ${item['qty']}"),
                                  // Text("Price : Rs.${item['discounted_price']}"),
                                      
                                  const SizedBox(height:10),
                                      
                                  Row(
                                    children: [
                                      
                                      const Text("Qty : ",style: TextStyle(fontWeight: FontWeight.bold),),
                                      
                                      Container(
                                        decoration: BoxDecoration(
                                          color: custom_color.button_color,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      
                                        child: Row(
                                          children: [
                                      
                                            IconButton(
                                              icon: const Icon(Icons.remove,color: Colors.white),
                                              onPressed: (){
                                                // updateCart(index,
                                                //     int.parse(item['qty']) - 1);
                                                updateCart(
                                                  item['product_variant_id'].toString(),
                                                  int.parse(item['qty']) - 1,
                                                );
                                              },
                                            ),
                                      
                                            Text(item['qty'].toString(),
                                                style: const TextStyle(color: Colors.white)),
                                      
                                            IconButton(
                                              icon: const Icon(Icons.add,color: Colors.white),
                                              onPressed: (){
                                                // updateCart(index,
                                                //     int.parse(item['qty']) + 1);
                                                 updateCart(
                                                    item['product_variant_id'].toString(),
                                                    int.parse(item['qty']) + 1,
                                                  );
                                              },
                                            ),
                                      
                                          ],
                                        ),
                                      )
                                      
                                    ],
                                  )
                                      
                                ],
                              ),
                            ),
                                      
                            Column(
                              children: [
                                // Icon(Icons.delete,color: custom_color.app_color),
                                 IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      // deleteCartItem(index);
                                      // deleteCartItem(item['product_variant_id'].toString());
                                      confirmDelete(item['product_variant_id'].toString());
                                    },
                                  ),
                                // const SizedBox(height:05),
                                      
                                safeNetworkImage(item['img']),
                                      
                                const SizedBox(height:10),
                                      
                                Text(
                                  "Total : Rs.${item['amt']}",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                )
                                      
                              ],
                            )
                                      
                          ],
                        ),
                      ),
                    );
                  },
              ),
               _buildPriceSummary(subTotalExcl, gstTotal, subTotalIncl, deliveryBase, deliveryGST, totalAmount),
              const SizedBox(height: 8),
            ],
          ),
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildMyAddressCard() {
    final bool hasAddress = user_details != null &&
        user_details['address']?.toString().isNotEmpty == true;

    if (!hasAddress) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "No delivery address found",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.orange.shade800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Please complete your profile with a delivery address before placing an order.",
              style: TextStyle(fontSize: 13, color: Colors.orange.shade700),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => showAddAddressDialog(StateList),
                    icon: const Icon(Icons.add_location_alt_outlined, size: 18, color: Colors.white),
                    label: const Text("Add Address", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: custom_color.button_color,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
              Icon(Icons.location_on, color: custom_color.app_color, size: 20),
              const SizedBox(width: 6),
              const Text("Delivery Address", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          _addressRow(Icons.person_outline, user_details['name'] ?? ""),
          const SizedBox(height: 6),
          _addressRow(Icons.home_outlined,
            "${user_details['address']}, ${user_details['address2']}\n"
            "${user_details['city']}, ${user_details['state']} - ${user_details['pin']}"),
          const SizedBox(height: 6),
          _addressRow(Icons.phone_outlined, user_details['mobile'] ?? ""),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => showAddAddressDialog(StateList),
                  icon: const Icon(Icons.add_location_alt_outlined),
                  label: const Text("Add Address", overflow: TextOverflow.ellipsis),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: custom_color.app_color,
                    side: BorderSide(color: custom_color.app_color),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => showAddressDialog(),
                  icon: const Icon(Icons.swap_horiz, size: 18, color: Colors.white),
                  label: const Text("Change", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: custom_color.button_color,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // address card shimmer
            _shimmerBox(height: 120, radius: 18),
            const SizedBox(height: 12),
            // cart item shimmers
            ...List.generate(4, (_) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _shimmerBox(height: 14, width: 160),
                          const SizedBox(height: 8),
                          _shimmerBox(height: 12, width: 100),
                          const SizedBox(height: 6),
                          _shimmerBox(height: 12, width: 80),
                          const SizedBox(height: 6),
                          _shimmerBox(height: 32, width: 120, radius: 8),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _shimmerBox(height: 90, width: 90, radius: 8),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox({double height = 16, double? width, double radius = 8}) {
    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _addressRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: TextStyle(fontSize: 13, color: Colors.grey.shade800)),
        ),
      ],
    );
  }
  Widget _buildPriceSummary(double subTotalExcl, double gstTotal, double subTotalIncl, double deliveryBase, double deliveryGST, double totalAmount) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border(
          right: BorderSide(color: Colors.grey.shade300, width: 2.5),
          bottom: BorderSide(color: Colors.grey.shade300, width: 2.5),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            priceRow("Subtotal (Excl. Tax)", "₹${subTotalExcl.toStringAsFixed(0)}"),
            priceRow("Total Tax", "₹${gstTotal.toStringAsFixed(0)}"),
            priceRow("Subtotal (Incl. Tax)", "₹${subTotalIncl.toStringAsFixed(0)}"),
            priceRow(
              "Delivery (Base: ₹${deliveryBase.toStringAsFixed(1)} + Tax: ₹${deliveryGST.toStringAsFixed(1)})",
              "₹${delivery_charges.toStringAsFixed(0)}",
            ),
            const Divider(),
            // priceRow("Total", "₹${totalAmount.toStringAsFixed(0)}", bold: true),
            priceRow(
              "Total",
              "₹${totalAmount.round()}",
              bold: true,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  // "${view_cart_data.length} Items  ₹${totalAmount.toStringAsFixed(2)}",
                  "${view_cart_data.length} Items  ₹${totalAmount.round()}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: custom_color.button_color,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    if (orderType == "myself") {
                      final bool hasAddress = user_details != null &&
                          user_details['address']?.toString().isNotEmpty == true;
                      if (!hasAddress) {
                        Fluttertoast.showToast(msg: "Please add a delivery address first");
                        return;
                      }
                    }
                    if (orderType == "customer") {
                      if (selectedCustomer == null) {
                        Fluttertoast.showToast(msg: "Please select customer");
                        return;
                      }
                      if (user_details == null || user_details.isEmpty) {
                        Fluttertoast.showToast(msg: "Please select address");
                        return;
                      }
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Checkout(
                          userDetails: orderType == "customer"
                              ? user_details
                              : Map<String, dynamic>.from(myAddress ?? {}),
                          cartData: view_cart_data,
                          deliveryCharge: delivery_charges,
                          gstPercent: gst_percentage,
                          totalAmount: totalAmount,
                          selected_data: selecteddata,
                        ),
                      ),
                    );
                  },
                  child: const Text("Buy Now", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget priceRow(String title,String value,{bool bold=false}){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical:4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(
                  fontWeight: bold?FontWeight.bold:FontWeight.bold)),
          Text(value,
              style: TextStyle(
                  fontWeight: bold?FontWeight.bold:FontWeight.normal)),
        ],
      ),
    );
  }
  
void showAddAddressDialog1(StateList) {
  
double screenHeight = MediaQuery.of(context).size.height;
double screenWidth = MediaQuery.of(context).size.width;
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title:  Text("Add Address",style: TextStyle(color: custom_color.app_color),),
        content: SizedBox(
          height: screenHeight * 0.55, // popup height (75% screen)
          width: screenWidth,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                      controller: nameController,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                      ],

                      decoration: InputDecoration(
                        labelText: 'Name *',
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: custom_color.app_color,
                              width: 1.5,
                            ),
                          ),
          
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: custom_color.app_color,
                              width: 2,
                            ),
                          ),
                      ),
                    ),
                    SizedBox(height: screenHeight*0.02,),
                TextFormField(
                      controller: mobileController,
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
  ],
                      decoration: InputDecoration(
                        labelText: 'Mobile *',
                        counterText: '',
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: custom_color.app_color,
                              width: 1.5,
                            ),
                          ),
          
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: custom_color.app_color,
                              width: 2,
                            ),
                          ),
                      ),
                    ),
                     SizedBox(height: screenHeight*0.02,),
               TextFormField(
                      controller: addressController,
                      decoration: InputDecoration(
                        labelText: 'Address *',
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: custom_color.app_color,
                              width: 1.5,
                            ),
                          ),
          
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: custom_color.app_color,
                              width: 2,
                            ),
                          ),
                      ),
                    ),
                     SizedBox(height: screenHeight*0.02,),
               TextFormField(
                      controller: address2Controller,
                      decoration: InputDecoration(
                        labelText: 'Address 2 *',
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: custom_color.app_color,
                              width: 1.5,
                            ),
                          ),
          
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: custom_color.app_color,
                              width: 2,
                            ),
                          ),
                      ),
                    ),
                     SizedBox(height: screenHeight*0.02,),
               TextFormField(
                      controller: cityController,
                      decoration: InputDecoration(
                        labelText: 'City *',
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: custom_color.app_color,
                              width: 1.5,
                            ),
                          ),
          
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: custom_color.app_color,
                              width: 2,
                            ),
                          ),
                      ),
                    ),
                     SizedBox(height: screenHeight*0.02,),
                Container(
                  color: Colors.white,
                          child: Container(
                            //  decoration: ShapeDecoration(
                            //   shape: RoundedRectangleBorder(
                            //     side: BorderSide(color: custom_color.app_color, width: 1.0),
                            //     borderRadius: BorderRadius.circular(5),
                            //   ),
                            //  ),
                             child: DropdownSearch<Map<String, dynamic>>(
                                items: StateList.cast<Map<String, dynamic>>(),
                                itemAsString: (item) => item['state'].toString(),
          
                                popupProps: PopupProps.menu(
                                  showSearchBox: true,
                                  searchFieldProps: TextFieldProps(
                                    decoration: InputDecoration(
                                      hintText: "Search State",
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
          
                                dropdownDecoratorProps: DropDownDecoratorProps(
                                  dropdownSearchDecoration: InputDecoration(
                                    
                                    labelText: "State *",
                                    fillColor: Colors.grey.shade100,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: custom_color.app_color),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: custom_color.app_color, width: 2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
          
                                onChanged: (value) {
                                  if (value != null) {
                                    stateController.text = value['state'].toString();
                                  }
                                },
          
                                selectedItem: StateList.isNotEmpty
                                    ? StateList.firstWhere(
                                        (item) => item['state'] == stateController.text,
                                        orElse: () => StateList.first,
                                      )
                                    : null,
                              ),
                            
                          ),
                        ),
                         SizedBox(height: screenHeight*0.02,),
                 TextFormField(
                      controller: areaController,
                      decoration: InputDecoration(
                        labelText: 'Area *',
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: custom_color.app_color,
                              width: 1.5,
                            ),
                          ),
          
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: custom_color.app_color,
                              width: 2,
                            ),
                          ),
                      ),
                    ),
                     SizedBox(height: screenHeight*0.02,),
                TextFormField(
                      controller: pinController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                       inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        labelText: 'Pin *',
                          counterText: '',
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: custom_color.app_color,
                              width: 1.5,
                            ),
                          ),
          
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: custom_color.app_color,
                              width: 2,
                            ),
                          ),
                      ),
                    ),
                     SizedBox(height: screenHeight*0.02,),
                TextFormField(
                      controller: landmarkController,
                      decoration: InputDecoration(
                        labelText: 'Landmark *',
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: custom_color.app_color,
                              width: 1.5,
                            ),
                          ),
          
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: custom_color.app_color,
                              width: 2,
                            ),
                          ),
                      ),
                    ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: custom_color.button_color,
            ),
            onPressed: () async{
              if(nameController.text.isEmpty){
                Fluttertoast.showToast(msg: 'Enter your Name');
              } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(nameController.text)) {
                Fluttertoast.showToast(msg: 'Enter valid name');
              } else if(mobileController.text.isEmpty){
                Fluttertoast.showToast(msg: 'Enter your Mobile Number');
              }else if (!RegExp(r'^[6-9]\d{9}$').hasMatch(mobileController.text)) {
                Fluttertoast.showToast(msg: 'Enter valid mobile number');
              }else if(addressController.text.isEmpty){
                Fluttertoast.showToast(msg: 'Enter your Address');
              }else if(address2Controller.text.isEmpty){
                Fluttertoast.showToast(msg: 'Enter your Address2');
              }else if(cityController.text.isEmpty){
                Fluttertoast.showToast(msg: 'Enter your City');
              }else if(stateController.text.isEmpty){
                Fluttertoast.showToast(msg: 'Enter your State');
              }else if(areaController.text.isEmpty){
                Fluttertoast.showToast(msg: 'Enter your Area');
              }else if(pinController.text.isEmpty){
                Fluttertoast.showToast(msg: 'Enter your Pincode');
              }else if(landmarkController.text.isEmpty){
                Fluttertoast.showToast(msg: 'Enter your Landmark');
              }else{
              var data = {
                "action": "save_address",
                'mobile': mobileController.text,
                "customer_id":customer_id,
                "accesskey": "90336",
                'city': cityController.text,
                'state': stateController.text,
                'address': addressController.text,
                'address2': address2Controller.text,
                'name': nameController.text,
                'pin': pinController.text,
                'landmark': landmarkController.text,
                'area': areaController.text,
                "act_type":userResponse['act_type'],
                "token": accesstoken,
              };
              print(data);
              final response =await Cartapi().SaveDeliveryAddress(data);
              if (response == null) return;
              if (response['status'] == "success") {
                  Fluttertoast.showToast(msg: 'Address added successfully!');
                  await getAddress();

  /// ✅ Optional: auto select newly added address
  if (get_address.isNotEmpty) {
    user_details = get_address.last;
    await storage.setItem('selected_address', user_details);
  }

                  Navigator.pop(context);
                } else {
                    Fluttertoast.showToast(msg: response['message'] ?? "Something went wrong");
                }
              }
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}

void showAddAddressDialog(StateList) {
  double screenHeight = MediaQuery.of(context).size.height;
  Map<String, dynamic>? selectedStateItem;
  nameController.clear();
  mobileController.clear();
  addressController.clear();
  address2Controller.clear();
  cityController.clear();
  stateController.clear();
  areaController.clear();
  pinController.clear();
  landmarkController.clear();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (dialogContext) {
       return StatefulBuilder(
       builder: (context, setSheetState) {
      return DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: custom_color.app_color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.add_location_alt_outlined, color: custom_color.app_color, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Text("Add Address", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(onPressed: () => Navigator.pop(dialogContext), icon: const Icon(Icons.close,color: Colors.red,)),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
                    child: Column(
                      children: [
                        _editField(nameController, "Name", Icons.person_outline,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
                            TextInputFormatter.withFunction((o, n) => n.text.contains('  ') ? o : n),
                          ],
                          maxLength: 50,
                        ),
                        _editField(mobileController, "Mobile", Icons.phone_outlined,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          maxLength: 10,
                        ),
                        // _editField(addressController, "Address Line 1", Icons.home_outlined),
                        // _editField(address2Controller, "Address Line 2", Icons.home_work_outlined),
                        // _editField(cityController, "City", Icons.location_city_outlined),
                         _editField(addressController, "Address Line 1", Icons.home_outlined,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ,./\-]'))],
                        ),
                        _editField(address2Controller, "Address Line 2", Icons.home_work_outlined,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ,./\-]'))],
                        ),
                        _editField(cityController, "City", Icons.location_city_outlined,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]'))],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          // child: DropdownSearch<Map<String, dynamic>>(
                          //   items: StateList.cast<Map<String, dynamic>>(),
                          //   itemAsString: (item) => item['state'].toString(),
                          //   popupProps: PopupProps.menu(
                          //     showSearchBox: true,
                          //     searchFieldProps: TextFieldProps(
                          //       decoration: const InputDecoration(hintText: "Search State", border: OutlineInputBorder()),
                          //     ),
                          //   ),
                          //   dropdownDecoratorProps: DropDownDecoratorProps(
                          //     dropdownSearchDecoration: InputDecoration(
                          //       labelText: "State *",
                          //       prefixIcon: Icon(Icons.map_outlined, color: custom_color.app_color),
                          //       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          //       enabledBorder: OutlineInputBorder(
                          //         borderRadius: BorderRadius.circular(12),
                          //         borderSide: BorderSide(color: custom_color.app_color, width: 1.5),
                          //       ),
                          //       focusedBorder: OutlineInputBorder(
                          //         borderRadius: BorderRadius.circular(12),
                          //         borderSide: BorderSide(color: custom_color.app_color, width: 2),
                          //       ),
                          //     ),
                          //   ),
                          //   onChanged: (value) {
                          //     if (value != null) stateController.text = value['state'].toString();
                          //   },
                          //   selectedItem: StateList.isNotEmpty
                          //       ? StateList.firstWhere(
                          //           (item) => item['state'] == stateController.text,
                          //           orElse: () => StateList.first,
                          //         )
                          //       : null,
                          // ),
                          child:   DropdownSearch<Map<String, dynamic>>(
  items: StateList.cast<Map<String, dynamic>>(),

  selectedItem: selectedStateItem,

  itemAsString: (item) => item['state'].toString(),

  popupProps: PopupProps.menu(
    showSearchBox: true,
    searchFieldProps: const TextFieldProps(
      decoration: InputDecoration(
        hintText: "Search State",
        border: OutlineInputBorder(),
      ),
    ),
  ),

  dropdownDecoratorProps: DropDownDecoratorProps(
    dropdownSearchDecoration: InputDecoration(
      hintText: "Select State",
      labelText: "State *",

      prefixIcon: Icon(
        Icons.map_outlined,
        color: custom_color.app_color,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: custom_color.app_color,
          width: 1.5,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: custom_color.app_color,
          width: 2,
        ),
      ),
    ),
  ),

  onChanged: (value) {
    setSheetState(() {
      selectedStateItem = value;

      stateController.text =
          value?['state']?.toString() ?? "";
    });
  },
),
                        ),
                        // _editField(areaController, "Area", Icons.place_outlined),
                         _editField(areaController, "Area", Icons.place_outlined,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ,./\-]'))],
                        ),
                        _editField(pinController, "Pincode", Icons.pin_drop_outlined,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          maxLength: 6,
                        ),
                        // _editField(landmarkController, "Landmark", Icons.flag_outlined),
                          _editField(landmarkController, "Landmark", Icons.flag_outlined,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ,./\-]'))],
                          required: false,
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: custom_color.button_color,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: () async {
                              if (nameController.text.isEmpty) { Fluttertoast.showToast(msg: 'Enter your Name'); return; }
                              else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(nameController.text)) { Fluttertoast.showToast(msg: 'Enter valid name'); return; }
                              else if (mobileController.text.isEmpty) { Fluttertoast.showToast(msg: 'Enter your Mobile Number'); return; }
                              else if (!RegExp(r'^[6-9]\d{9}$').hasMatch(mobileController.text)) { Fluttertoast.showToast(msg: 'Enter valid mobile number'); return; }
                              else if (addressController.text.isEmpty) { Fluttertoast.showToast(msg: 'Enter your Address'); return; }
                              else if (address2Controller.text.isEmpty) { Fluttertoast.showToast(msg: 'Enter your Address2'); return; }
                              else if (cityController.text.isEmpty) { Fluttertoast.showToast(msg: 'Enter your City'); return; }
                              else if (stateController.text.isEmpty) { Fluttertoast.showToast(msg: 'Enter your State'); return; }
                              else if (areaController.text.isEmpty) { Fluttertoast.showToast(msg: 'Enter your Area'); return; }
                              else if (pinController.text.isEmpty) { Fluttertoast.showToast(msg: 'Enter your Pincode'); return; }
                              // else if (landmarkController.text.isEmpty) { Fluttertoast.showToast(msg: 'Enter your Landmark'); return; }
                              var data = {
                "action": "save_address",
                'mobile': mobileController.text,
                "customer_id":customer_id,
                "accesskey": "90336",
                'city': cityController.text,
                'state': stateController.text,
                'address': addressController.text,
                'address2': address2Controller.text,
                'name': nameController.text,
                'pin': pinController.text,
                'landmark': landmarkController.text,
                'area': areaController.text,
                "act_type":userResponse['act_type'],
                "token": accesstoken,
              };
              print(data);
              final response =await Cartapi().SaveDeliveryAddress(data);
                              if (response == null) return;
                              if (response['status'] == "success") {
                                Fluttertoast.showToast(msg: 'Address added successfully!');
                                await getAddress();
                                if (get_address.isNotEmpty) {
                                  user_details = get_address.last;
                                  await storage.setItem('selected_address', user_details);
                                }
                                Navigator.pop(dialogContext);
                              } else {
                                Fluttertoast.showToast(msg: response['message'] ?? "Something went wrong");
                              }
                            },
                            child: const Text("Save Address",
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                         SizedBox(height: screenHeight*0.05,)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
  
    }
       );
}
  );
}
void showAddressDialog() {
  double screenHeight = MediaQuery.of(context).size.height;

  // Pre-select the currently active address
  if (user_details != null && get_address.isNotEmpty) {
    int idx = get_address.indexWhere((a) =>
        a['customer_address_id']?.toString() ==
        user_details['customer_address_id']?.toString());
    if (idx < 0) {
      // fallback: match by mobile + address
      idx = get_address.indexWhere((a) =>
          a['mobile']?.toString() == user_details['mobile']?.toString() &&
          a['address']?.toString() == user_details['address']?.toString());
    }
    selectedAddressIndex = idx >= 0 ? idx : 0;
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder: (_, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40, height: 4,
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: custom_color.app_color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.location_on_outlined, color: custom_color.app_color, size: 22),
                          ),
                          const SizedBox(width: 12),
                          const Text("Choose Address", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          IconButton(onPressed: () => Navigator.pop(dialogContext), icon: const Icon(Icons.close, color: Colors.red)),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: get_address.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.location_off_outlined, size: 60, color: Colors.grey),
                                  SizedBox(height: 10),
                                  Text("No addresses found", style: TextStyle(color: Colors.grey, fontSize: 15)),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: get_address.length,
                              itemBuilder: (context, index) {
                                var address = get_address[index];
                                bool isSelected = selectedAddressIndex == index;
                                bool isCurrentAddress = false;
                                if (user_details != null) {
                                  isCurrentAddress =
                                      (address['customer_address_id']?.toString() ==
                                          user_details['customer_address_id']?.toString()) ||
                                      (address['mobile']?.toString() == user_details['mobile']?.toString() &&
                                          address['address']?.toString() == user_details['address']?.toString());
                                }
                                return GestureDetector(
                                  // onTap: () => setDialogState(() => selectedAddressIndex = index),
                                   onTap: () {
                                    setDialogState(() => selectedAddressIndex = index);
                                    setState(() => user_details = Map.from(address));
                                    storage.setItem('selected_address', address);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: isSelected ? custom_color.app_color.withOpacity(0.05) : Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: isSelected ? custom_color.app_color : Colors.grey.shade200,
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.person_outline, size: 16, color: custom_color.app_color),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(address['name'] ?? "",
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                            ),
                                            if (isSelected)
                                              Icon(Icons.check_circle, color: custom_color.app_color, size: 20),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Icon(Icons.home_outlined, size: 16, color: Colors.grey.shade500),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                "${address['address'] ?? ''}, ${address['address2'] ?? ''}, "
                                                "${address['city'] ?? ''}, ${address['state'] ?? ''} - ${address['pin'] ?? ''}",
                                                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.phone_outlined, size: 16, color: Colors.grey.shade500),
                                            const SizedBox(width: 6),
                                            Text(address['mobile'] ?? "",
                                                style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            OutlinedButton.icon(
                                              onPressed: () => showEditAddressDialog(address, setDialogState),
                                              icon: const Icon(Icons.edit_outlined, size: 16),
                                              label: const Text("Edit"),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: custom_color.app_color,
                                                side: BorderSide(color: custom_color.app_color),
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            if (!isCurrentAddress) ...[  
                                              OutlinedButton.icon(
                                                onPressed: () => showDeleteConfirmDialog(index, setDialogState),
                                                icon: const Icon(Icons.delete_outline, size: 16),
                                                label: const Text("Delete"),
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor: Colors.red,
                                                  side: const BorderSide(color: Colors.red),
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    //   child: SizedBox(
                    //     width: double.infinity,
                    //     height: 52,
                    //     child: ElevatedButton(
                    //       style: ElevatedButton.styleFrom(
                    //         backgroundColor: custom_color.button_color,
                    //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    //       ),
                    //       onPressed: () async {
                    //         if (selectedAddressIndex != null) {
                    //           var selectedAddress = get_address[selectedAddressIndex!];
                    //           setState(() {
                    //             user_details = Map.from(selectedAddress);
                    //             myAddress = Map.from(selectedAddress);
                    //           });
                    //           await storage.setItem('selected_address', selectedAddress);
                    //           Navigator.pop(dialogContext);
                    //           await DeliveryCharges();
                    //         } else {
                    //           Fluttertoast.showToast(msg: "Please select an address");
                    //         }
                    //       },
                    //       child: const Text("Deliver to this Address",
                    //           style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    //     ),
                    //   ),
                    // ),
                    SizedBox(height: screenHeight * 0.05),
                  ],
                ),
              );
            },
          );
        },
      );
    },
  );
}

Widget _editField(
  TextEditingController controller,
  String label,
  IconData icon, {
  TextInputType keyboardType = TextInputType.text,
  List<TextInputFormatter>? inputFormatters,
  int? maxLength,
  bool required = true,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      decoration: InputDecoration(
        // labelText: "${label} *",
        labelText: required ? "$label *" : label,
        counterText: "",
        prefixIcon: Icon(icon, color: custom_color.app_color, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: custom_color.app_color, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: custom_color.app_color, width: 2),
        ),
      ),
    ),
  );
}


// void showEditAddressDialog(Map<String, dynamic> address) {
  
//       double screenHeight = MediaQuery.of(context).size.height;
//       double screenWidth = MediaQuery.of(context).size.width;
//       editnameController.text = address['name'] ?? "";
//       editmobileController.text = address['mobile'] ?? "";
//       editaddressController.text = address['address'] ?? "";
//       editaddress2Controller.text = address['address2'] ?? "";
//       editcityController.text = address['city'] ?? "";
//       editstateController.text = address['state'] ?? "";
//       editareaController.text = address['area'] ?? "";
//       editpinController.text = address['pin'] ?? "";
//       editlandmarkController.text = address['landmark'] ?? "";
//   showDialog(
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//         title:  Text("Edit Address",style: TextStyle(color: custom_color.app_color),),
//         content: SizedBox(
//           height: screenHeight * 0.55,
//           width: screenWidth,
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextFormField(
//                       controller: editnameController,
//                       decoration: InputDecoration(
//                         labelText: 'Name *',
//                         fillColor: Colors.grey.shade100,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: BorderSide(
//                               color: custom_color.app_color,
//                               width: 1.5,
//                             ),
//                           ),
          
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: BorderSide(
//                               color: custom_color.app_color,
//                               width: 2,
//                             ),
//                           ),
//                       ),
//                     ),
//                     SizedBox(height: screenHeight*0.02,),
//                 TextFormField(
//                       controller: editmobileController,
//                       keyboardType: TextInputType.number,
//                       maxLength: 10,
//                       decoration: InputDecoration(
//                         labelText: 'Mobile *',
//                         counterText: '',
//                         fillColor: Colors.grey.shade100,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: BorderSide(
//                               color: custom_color.app_color,
//                               width: 1.5,
//                             ),
//                           ),
          
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: BorderSide(
//                               color: custom_color.app_color,
//                               width: 2,
//                             ),
//                           ),
//                       ),
//                     ),
//                      SizedBox(height: screenHeight*0.02,),
//                TextFormField(
//                       controller: editaddressController,
//                       decoration: InputDecoration(
//                         labelText: 'Address *',
//                         fillColor: Colors.grey.shade100,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: BorderSide(
//                               color: custom_color.app_color,
//                               width: 1.5,
//                             ),
//                           ),
          
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: BorderSide(
//                               color: custom_color.app_color,
//                               width: 2,
//                             ),
//                           ),
//                       ),
//                     ),
//                      SizedBox(height: screenHeight*0.02,),
//                TextFormField(
//                       controller: editaddress2Controller,
//                       decoration: InputDecoration(
//                         labelText: 'Address 2 *',
//                         fillColor: Colors.grey.shade100,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: BorderSide(
//                               color: custom_color.app_color,
//                               width: 1.5,
//                             ),
//                           ),
          
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: BorderSide(
//                               color: custom_color.app_color,
//                               width: 2,
//                             ),
//                           ),
//                       ),
//                     ),
//                      SizedBox(height: screenHeight*0.02,),
//                TextFormField(
//                       controller: editcityController,
//                       decoration: InputDecoration(
//                         labelText: 'City *',
//                         fillColor: Colors.grey.shade100,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: BorderSide(
//                               color: custom_color.app_color,
//                               width: 1.5,
//                             ),
//                           ),
          
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: BorderSide(
//                               color: custom_color.app_color,
//                               width: 2,
//                             ),
//                           ),
//                       ),
//                     ),
//                      SizedBox(height: screenHeight*0.02,),
//                 Container(
//                           child: Container(
//                             //  decoration: ShapeDecoration(
//                             //   shape: RoundedRectangleBorder(
//                             //     side: BorderSide(color: custom_color.app_color, width: 1.0),
//                             //     borderRadius: BorderRadius.circular(5),
//                             //   ),
//                             //  ),
//                              child: DropdownSearch<Map<String, dynamic>>(
//                                 items: StateList.cast<Map<String, dynamic>>(),
//                                 itemAsString: (item) => item['state'].toString(),
          
//                                 popupProps: PopupProps.menu(
//                                   showSearchBox: true,
//                                   searchFieldProps: TextFieldProps(
//                                     decoration: InputDecoration(
//                                       hintText: "Search State",
//                                       border: OutlineInputBorder(),
//                                     ),
//                                   ),
//                                 ),
          
//                                 dropdownDecoratorProps: DropDownDecoratorProps(
//                                   dropdownSearchDecoration: InputDecoration(
                                    
//                                     labelText: "State *",
//                                     fillColor: Colors.grey.shade100,
//                                     border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                     enabledBorder: OutlineInputBorder(
//                                       borderSide: BorderSide(color: custom_color.app_color),
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                     focusedBorder: OutlineInputBorder(
//                                       borderSide: BorderSide(color: custom_color.app_color, width: 2),
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                   ),
//                                 ),
          
//                                 onChanged: (value) {
//                                   if (value != null) {
//                                     editstateController.text = value['state'].toString();
//                                   }
//                                 },
          
//                                 selectedItem: StateList.isNotEmpty
//                                     ? StateList.firstWhere(
//                                         (item) => item['state'] == editstateController.text,
//                                         orElse: () => StateList.first,
//                                       )
//                                     : null,
//                               ),
                            
//                           ),
//                         ),
//                          SizedBox(height: screenHeight*0.02,),
//                  TextFormField(
//                       controller: editareaController,
//                       decoration: InputDecoration(
//                         labelText: 'Area *',
//                         fillColor: Colors.grey.shade100,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: BorderSide(
//                               color: custom_color.app_color,
//                               width: 1.5,
//                             ),
//                           ),
          
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: BorderSide(
//                               color: custom_color.app_color,
//                               width: 2,
//                             ),
//                           ),
//                       ),
//                     ),
//                      SizedBox(height: screenHeight*0.02,),
//                 TextFormField(
//                       controller: editpinController,
//                       keyboardType: TextInputType.number,
//                       maxLength: 6,
//                       decoration: InputDecoration(
//                         labelText: 'Pin *',
//                           counterText: '',
//                         fillColor: Colors.grey.shade100,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: BorderSide(
//                               color: custom_color.app_color,
//                               width: 1.5,
//                             ),
//                           ),
          
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: BorderSide(
//                               color: custom_color.app_color,
//                               width: 2,
//                             ),
//                           ),
//                       ),
//                     ),
//                      SizedBox(height: screenHeight*0.02,),
//                 TextFormField(
//                       controller: editlandmarkController,
//                       decoration: InputDecoration(
//                         labelText: 'Landmark *',
//                         fillColor: Colors.grey.shade100,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: BorderSide(
//                               color: custom_color.app_color,
//                               width: 1.5,
//                             ),
//                           ),
          
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: BorderSide(
//                               color: custom_color.app_color,
//                               width: 2,
//                             ),
//                           ),
//                       ),
//                     ),
//               ],
//             ),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Cancel"),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: custom_color.button_color,
//             ),
//             onPressed: () async{
//               if(editnameController.text.isEmpty){
//                 Fluttertoast.showToast(msg: 'Enter your Name');
//               }else if(editmobileController.text.isEmpty){
//                 Fluttertoast.showToast(msg: 'Enter your Mobile Number');
//               }else if(editaddressController.text.isEmpty){
//                 Fluttertoast.showToast(msg: 'Enter your Address');
//               }else if(editaddress2Controller.text.isEmpty){
//                 Fluttertoast.showToast(msg: 'Enter your Address2');
//               }else if(editcityController.text.isEmpty){
//                 Fluttertoast.showToast(msg: 'Enter your City');
//               }else if(editstateController.text.isEmpty){
//                 Fluttertoast.showToast(msg: 'Enter your State');
//               }else if(editareaController.text.isEmpty){
//                 Fluttertoast.showToast(msg: 'Enter your Area');
//               }else if(editpinController.text.isEmpty){
//                 Fluttertoast.showToast(msg: 'Enter your Pincode');
//               }else if(editlandmarkController.text.isEmpty){
//                 Fluttertoast.showToast(msg: 'Enter your Landmark');
//               }else{
//               var data = {
//                 "customer_address_id": address['customer_address_id'],
//                 "action": "update_address",
//                 'mobile': editmobileController.text,
//                 "customer_id":customer_id,
//                 "accesskey": "90336",
//                 'city': editcityController.text,
//                 'state': editstateController.text,
//                 'address': editaddressController.text,
//                 'address2': editaddress2Controller.text,
//                 'name': editnameController.text,
//                 'pin': editpinController.text,
//                 'landmark': editlandmarkController.text,
//                 'area': editareaController.text,
//                 "act_type":userResponse['act_type'],
//                 "token": accesstoken,
//               };
//               print(data);
//               final response =await Cartapi().EditDeliveryAddress(data);
//               if (response == null) return;
//               if (response['status'] == "success") {
               
//                   Fluttertoast.showToast(msg: 'Address updated successfully!');
//                     if (get_address.isNotEmpty) {
//                   user_details = get_address.last;
//                   await storage.setItem('selected_address', user_details);
//                 }

//                    await getAddress(); 
//                     setState(() {}); 

//                     Navigator.pop(context);

//                     showAddressDialog();  
//                 } else {
//                     Fluttertoast.showToast(msg: response['message'] ?? "Something went wrong");
//                 }
//               }
//             },
//             child: const Text("Save", style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       );
//     },
//   );
// }

void showEditAddressDialog(Map<String, dynamic> address, StateSetter setAddressDialogState) {
  double screenHeight = MediaQuery.of(context).size.height;
  final w = MediaQuery.of(context).size.width;
  editnameController.text = address['name'] ?? '';
  editmobileController.text = address['mobile'] ?? '';
  editaddressController.text = address['address'] ?? '';
  editaddress2Controller.text = address['address2'] ?? '';
  editcityController.text = address['city'] ?? '';
  editstateController.text = address['state'] ?? '';
  editareaController.text = address['area'] ?? '';
  editpinController.text = address['pin'] ?? '';
  editlandmarkController.text = address['landmark'] ?? '';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (dialogContext) {
      return DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                /// handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                /// header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: custom_color.app_color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.edit_location_alt_outlined, color: custom_color.app_color, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Text("Edit Address",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        icon: const Icon(Icons.close,color: Colors.red),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                /// fields
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
                    child: Column(
                      children: [
                        _editField(editnameController, "Name", Icons.person_outline,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z ]")),
                            TextInputFormatter.withFunction((o, n) => n.text.contains("  ") ? o : n),
                          ],
                          maxLength: 50,
                        ),
                        _editField(editmobileController, "Mobile", Icons.phone_outlined,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          maxLength: 10,
                        ),
                        // _editField(editaddressController, "Address Line 1", Icons.home_outlined),
                        // _editField(editaddress2Controller, "Address Line 2", Icons.home_work_outlined),
                        // _editField(editcityController, "City", Icons.location_city_outlined),
                           _editField(editaddressController, "Address Line 1", Icons.home_outlined,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ,./\-]'))],
                        ),
                        _editField(editaddress2Controller, "Address Line 2", Icons.home_work_outlined,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ,./\-]'))],
                        ),
                        _editField(editcityController, "City", Icons.location_city_outlined,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]'))],
                        ),
                        /// state dropdown
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: DropdownSearch<Map<String, dynamic>>(
                            items: StateList.cast<Map<String, dynamic>>(),
                            itemAsString: (item) => item["state"].toString(),
                            popupProps: PopupProps.menu(
                              showSearchBox: true,
                              searchFieldProps: TextFieldProps(
                                decoration: const InputDecoration(hintText: "Search State", border: OutlineInputBorder()),
                              ),
                            ),
                            dropdownDecoratorProps: DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                labelText: "State *",
                                prefixIcon: Icon(Icons.map_outlined, color: custom_color.app_color),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: custom_color.app_color, width: 1.5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: custom_color.app_color, width: 2),
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              if (value != null) editstateController.text = value["state"].toString();
                            },
                            selectedItem: StateList.isNotEmpty
                                ? StateList.firstWhere(
                                    (item) => item["state"] == editstateController.text,
                                    orElse: () => StateList.first,
                                  )
                                : null,
                          ),
                        ),
                        // _editField(editareaController, "Area", Icons.place_outlined),
                        // _editField(editpinController, "Pincode", Icons.pin_drop_outlined,
                        //   keyboardType: TextInputType.number,
                        //   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        //   maxLength: 6,
                        // ),
                        // _editField(editlandmarkController, "Landmark", Icons.flag_outlined),
                          _editField(editareaController, "Area", Icons.place_outlined,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ,./\-]'))],
                        ),
                        _editField(editpinController, "Pincode", Icons.pin_drop_outlined,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          maxLength: 6,
                        ),
                        _editField(editlandmarkController, "Landmark", Icons.flag_outlined,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ,./\-]'))],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: custom_color.button_color,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: () async {
                              if (editnameController.text.isEmpty) {
                                Fluttertoast.showToast(msg: "Enter your Name"); return;
                              } else if (editmobileController.text.isEmpty) {
                                Fluttertoast.showToast(msg: "Enter your Mobile Number"); return;
                              } else if (editaddressController.text.isEmpty) {
                                Fluttertoast.showToast(msg: "Enter your Address"); return;
                              } else if (editaddress2Controller.text.isEmpty) {
                                Fluttertoast.showToast(msg: "Enter your Address2"); return;
                              } else if (editcityController.text.isEmpty) {
                                Fluttertoast.showToast(msg: "Enter your City"); return;
                              } else if (editstateController.text.isEmpty) {
                                Fluttertoast.showToast(msg: "Enter your State"); return;
                              } else if (editareaController.text.isEmpty) {
                                Fluttertoast.showToast(msg: "Enter your Area"); return;
                              } else if (editpinController.text.isEmpty) {
                                Fluttertoast.showToast(msg: "Enter your Pincode"); return;
                              } 
                              var data = {
                                "customer_address_id": address["customer_address_id"],
                                "action": "update_address",
                                "mobile": editmobileController.text,
                                "customer_id": customer_id,
                                "accesskey": "90336",
                                "city": editcityController.text,
                                "state": editstateController.text,
                                "address": editaddressController.text,
                                "address2": editaddress2Controller.text,
                                "name": editnameController.text,
                                "pin": editpinController.text,
                                "landmark": editlandmarkController.text,
                                "area": editareaController.text,
                                "act_type": userResponse["act_type"],
                                "token": accesstoken,
                              };
                               if (address['customer_address_id'] == null) {
                                  Fluttertoast.showToast(msg: "Primary Address cannot be edited");
                                  return;
                                }
                              final response = await Cartapi().EditDeliveryAddress(data);
                              if (response == null) return;
                              if (response["status"] == "success") {
                                Fluttertoast.showToast(msg: "Address updated successfully!");
                                if (get_address.isNotEmpty) {
                                  user_details = get_address.last;
                                  await storage.setItem("selected_address", user_details);
                                }
                                await getAddress();
                                setState(() {});
                                setAddressDialogState(() {});
                                Navigator.pop(dialogContext);
                              } else {
                                Fluttertoast.showToast(msg: response["message"] ?? "Something went wrong");
                              }
                            },
                            child: const Text("Save Changes",
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        SizedBox(height: screenHeight*0.05,)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

void showDeleteConfirmDialog1(int index, StateSetter setDialogState) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Delete Address"),
        content: const Text("Are you sure you want to delete this address?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // close confirm

              var address = get_address[index];

              var data = {
                "action": "delete_address",
                "accesskey": "90336",
                "customer_id": customer_id,
                "act_type": userResponse['act_type'],
                "customer_address_id": address['customer_address_id'],
                "token": accesstoken,
              };
                    if (address['customer_address_id'] == null) {
                          Fluttertoast.showToast(msg: "This is a Primary Address and cannot be deleted");
                          return;
                        }
              final response = await Cartapi().deleteAddress(data);
// var response;

              if (response != null && response['status'] == "success") {
                Fluttertoast.showToast(msg: "Deleted successfully");

                setDialogState(() {
                  get_address.removeAt(index);
                });

                /// reset selection if deleted item selected
                if (selectedAddressIndex == index) {
                  selectedAddressIndex = null;
                }

              } else {
                Fluttertoast.showToast(msg: "Delete failed");
              }
            },
            child: const Text("Delete"),
          ),
        ],
      );
    },
  );
}

void showDeleteConfirmDialog(int index, StateSetter setDialogState) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              /// 🔴 ICON
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 32,
                ),
              ),

              const SizedBox(height: 16),

              /// TITLE
              const Text(
                "Delete Address",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              /// DESCRIPTION
              const Text(
                "Are you sure you want to delete this address?\nThis action cannot be undone.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 24),

              /// BUTTONS
              Row(
                children: [
                  /// CANCEL
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  /// DELETE
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        Navigator.pop(context);

                        var address = get_address[index];

                        var data = {
                          "action": "delete_address",
                          "accesskey": "90336",
                          "customer_id": customer_id,
                          "act_type": userResponse['act_type'],
                          "customer_address_id": address['customer_address_id'],
                          "token": accesstoken,
                        };
                        if (address['customer_address_id'] == null) {
                          Fluttertoast.showToast(msg: "This is a Primary Address and cannot be deleted");
                          return;
                        }
                        final response = await Cartapi().deleteAddress(data);

                        if (response != null && response['status'] == "success") {
                          Fluttertoast.showToast(msg: "Deleted successfully");

                          setDialogState(() {
                            get_address.removeAt(index);
                            // Adjust selectedAddressIndex after deletion
                            if (selectedAddressIndex == index) {
                              // Deleted the currently selected address — pick first available
                              if (get_address.isNotEmpty) {
                                selectedAddressIndex = 0;
                                setState(() {
                                  user_details = Map.from(get_address[0]);
                                });
                                storage.setItem('selected_address', get_address[0]);
                              } else {
                                selectedAddressIndex = null;
                                setState(() => user_details = null);
                                storage.deleteItem('selected_address');
                              }
                            } else if (selectedAddressIndex != null &&
                                selectedAddressIndex! > index) {
                              // Shift index down if deleted item was above selected
                              selectedAddressIndex = selectedAddressIndex! - 1;
                            }
                          });

                        } else {
                          Fluttertoast.showToast(msg: "Delete failed");
                        }
                      },
                      child: const Text(
                        "Delete",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
// Widget emptyCartUI() {
//   return Center(
//     child: Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [

//         Image.asset(
//           "assets/images/AppLogo.png",
//           height: 180,
//         ),

//         const SizedBox(height: 20),

//         const Text(
//           "Your Cart is empty",
//           style: TextStyle(
//             fontSize: 18,
//             color: Colors.green,
//             fontWeight: FontWeight.w500,
//           ),
//         ),

//         const SizedBox(height: 10),

//         const Text(
//           "No Items Found!",
//           style: TextStyle(
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//           ),
//         ),

//         const SizedBox(height: 20),

//         ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: custom_color.button_color,
//             padding: const EdgeInsets.symmetric(
//                 horizontal: 30, vertical: 14),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(30),
//             ),
//           ),
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => Dashboard()),
//             );
//           },
//           child: const Text(
//             "Shop Now",
//             style: TextStyle(
//               fontSize: 18,
//               color: Colors.white,
//             ),
//           ),
//         )
//       ],
//     ),
//   );
// }
Widget emptyCartUI() {

  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  return Center(
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          /// IMAGE CONTAINER
          Container(
            height: screenWidth * 0.45,
            width: screenWidth * 0.45,
            padding: EdgeInsets.all(screenWidth * 0.04),

            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),

            child: Image.asset(
              'assets/images/cart.png',
              fit: BoxFit.contain,
            ),
          ),

          SizedBox(height: screenHeight * 0.03),

          /// TITLE
          const Text(
            "Your Cart Is Empty",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: screenHeight * 0.012),

          /// SUBTITLE
          Text(
            "Looks like you haven’t added\nanything to your cart yet.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),

          // SizedBox(height: screenHeight * 0.04),

          // /// BUTTON
          // SizedBox(
          //   width: screenWidth * 0.6,
          //   height: 52,
          //   child: ElevatedButton(
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: custom_color.button_color,
          //       elevation: 0,
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(30),
          //       ),
          //     ),

          //     onPressed: () {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //           builder: (context) => Dashboard(),
          //         ),
          //       );
          //     },

          //     child: const Text(
          //       "Start Shopping",
          //       style: TextStyle(
          //         fontSize: 16,
          //         fontWeight: FontWeight.w600,
          //         color: Colors.white,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    ),
  );
}
// void confirmDelete(String variantId) {
//   showDialog(
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//         title: const Text("Remove Item"),
//         content: const Text("Are you sure you want to remove this item from cart?"),
//         actions: [

//           TextButton(
//             onPressed: () {
//               Navigator.pop(context); // ❌ Cancel
//             },
//             child: const Text("Cancel"),
//           ),

//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//             ),
//             onPressed: () {
//               Navigator.pop(context); // close dialog
//               deleteCartItem(variantId); // ✅ delete
//             },
//             child: const Text("Remove", style: TextStyle(color: Colors.white)),
//           ),

//         ],
//       );
//     },
//   );
// }

void confirmDelete(String variantId) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              /// 🟠 ICON
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.remove_shopping_cart_outlined,
                  color: Colors.orange,
                  size: 32,
                ),
              ),

              const SizedBox(height: 16),

              /// TITLE
              const Text(
                "Remove Item",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              /// MESSAGE
              const Text(
                "Are you sure you want to remove this item from your cart?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 24),

              /// BUTTONS
              Row(
                children: [
                  /// CANCEL
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  /// REMOVE
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        deleteCartItem(variantId);
                      },
                      child: const Text(
                        "Remove",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
}