import 'package:burmapartner/CartPages/Cart.dart';
import 'package:burmapartner/Common/DeviceInfo.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:burmapartner/Common/FirebaseApi.dart';
import 'package:burmapartner/Common/Utils.dart';
import 'package:burmapartner/Dashboard/Dashboard.dart';
import 'package:burmapartner/Dashboard/DashboardApi.dart';
import 'package:burmapartner/Dashboard/Dashboardmenu.dart';
import 'package:burmapartner/Favourites/Favourites.dart';
import 'package:burmapartner/LeaderBoard/LeaderBoard.dart';
import 'package:burmapartner/Notification/Notifications.dart';
import 'package:burmapartner/OrdersPages/Orders.dart';
import 'package:burmapartner/ProfilePage/ProfilePage.dart';
import 'package:burmapartner/RefereCustomer/Referecustomer.dart';
import 'package:burmapartner/Sales/Sales.dart';
import 'package:burmapartner/Wallet/WalletScreens.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../Common/colors.dart' as custom_color;

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final LocalStorage storage = LocalStorage('app_store');
  late SharedPreferences pref;

  bool isLoading = true;
  int _currentBanner = 0;
  int _currentCert = 0;
  int _currentNavIndex = 0;
  int _cartCount = 0;
  int _notifCount = 0;

  var userResponse, accesstoken, customer_id, device_id;
  var fcmToken, deviceName, deviceModel, osVersion;
  List banners = [];
  List certification_list = [];
  var wallet_amount;

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
    await Device().initPlatformState();
    device_id = await storage.getItem('device_id');
    deviceName = storage.getItem('device_name') ?? "";
    deviceModel = storage.getItem('device_model') ?? "";
    osVersion = storage.getItem('os_version') ?? "";
    await FirebaseApi().initNotifications();
    fcmToken = await storage.getItem('fcmToken');
    await HomeBanner();
    await WalletDetails();
    await getCertification();
    await _loadCartCount();
    await _loadNotifCount();
    setState(() {});
  }

  Future<void> _loadCartCount() async {
    final box = await Hive.openBox('cart');
    final items = box.get('cartItems', defaultValue: []) as List;
    setState(() => _cartCount = items.length);
  }

  Future<void> _loadNotifCount() async {
    var data = {
      "action": "notification",
      "accesskey": "90336",
      "customer_id": customer_id,
      "act_type": userResponse['act_type'],
      "limit": '100',
      "offset": "0",
      "token": accesstoken,
    };
    final response = await DashboardApi().getNotification(data);
    if (response != null && response['data'] != null) {
      final total = (response['data'] as List).length;
      final lastSeen = pref.getInt('last_seen_notif_count') ?? 0;
      setState(() => _notifCount = (total - lastSeen).clamp(0, total));
    }
  }

  Future<void> HomeBanner() async {
    setState(() => isLoading = true);
    var data = {
      "action": "get_banner",
      "accesskey": "90336",
      "token": accesstoken,
      "act_type": userResponse['act_type'],
      "customer_id": customer_id,
    };
    final response = await DashboardApi().HomeBanner(data);
    if (response != null) {
      banners = (response['res'] ?? []).map((e) => e['img']).toList();
    }
    setState(() => isLoading = false);
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
      await storage.setItem('wallet_amount', response);
      setState(() => isLoading = false);
    }
 }

  Future<void> getCertification() async {
    setState(() => isLoading = true);
    var data = {
      "action": "certification",
      "accesskey": "90336",
      "token": accesstoken,
      "act_type": userResponse['act_type'],
      "customer_id": customer_id,
    };
    final response = await DashboardApi().getCertification(data);
    if (response != null) {
      certification_list = response['res'];
    }
    setState(() => isLoading = false);
  }
   DateTime? currentBackPressTime;
   Future<bool> onWillPop() async {
    DateTime now = DateTime.now();

    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {

      currentBackPressTime = now;

      Fluttertoast.showToast(msg: 'Press back again to exit');
      return false;
    }

    return true;
  }
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FA),
        
        drawer: const Dashboardmenu(),
        appBar: _buildAppBar(),
        body: SafeArea(child: isLoading ? _buildLoader() : _buildBody(screenHeight)),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor:custom_color.app_color ,
      // flexibleSpace: Container(
      //   decoration: BoxDecoration(
      //     gradient: LinearGradient(
      //       colors: [custom_color.app_color, Colors.lightBlueAccent],
      //       begin: Alignment.topLeft,
      //       end: Alignment.bottomRight,
      //     ),
      //   ),
      // ),
      titleSpacing: 0, 
      title: Row(
        children: [
          Image.asset("assets/images/AppLogo.png", height: 32, errorBuilder: (_, __, ___) => const SizedBox()),
          // const SizedBox(width: 8),
          // Expanded(child: const Text("Burma Partner", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18))),
          SizedBox(width: MediaQuery.of(context).size.width * 0.02),

      /// Title (important fix)
      Expanded(
        child: Text(
          "Burma Partner",
          maxLines: 1,
          overflow: TextOverflow.ellipsis, // prevent overflow
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: MediaQuery.of(context).size.width * 0.045,
          ),
        ),
      ),
        ],
      ),
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => Cart(selected_data: "",selecteddata_title: "",)));
                _loadCartCount();
              },
            ),
            if (_cartCount > 0)
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
                    '$_cartCount',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => Notificationpage()));
                setState(() => _notifCount = 0);
              },
            ),
            if (_notifCount > 0)
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
                    '$_notifCount',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildLoader() {
    final screenHeight = MediaQuery.of(context).size.height;
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner skeleton
              const SizedBox(height: 4),
              Container(
                height: screenHeight * 0.22,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              ),
              const SizedBox(height: 24),
              // Section title skeleton
              Container(width: 120, height: 16, color: Colors.white),
              const SizedBox(height: 12),
              // Grid skeleton
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (_, __) => Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                ),
              ),
              const SizedBox(height: 24),
              // Certifications skeleton
              Container(width: 140, height: 16, color: Colors.white),
              const SizedBox(height: 12),
              Container(
                height: screenHeight * 0.18,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(double screenHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // _buildWelcomeHeader(),
        Expanded(
          child: SingleChildScrollView(
            // physics: const BouncingScrollPhysics(),
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBannerSection(screenHeight),
                _buildSectionTitle("Quick Access"),
                _buildMenuGrid(),
                if (certification_list.isNotEmpty) ...[  
                  _buildSectionTitle("Certifications"),
                  _buildCertificationSection(),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeHeader() {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: BoxDecoration(
        color: custom_color.app_color,
        // gradient: LinearGradient(
        //   colors: [custom_color.app_color, Colors.lightBlueAccent],
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        // ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Welcome back 👋", style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 2),
                const Text("Good to see you!", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          // Container(
          //   height: screenHeight*0.05,
          //   padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          //   decoration: BoxDecoration(
          //     color: Colors.white.withOpacity(0.2),
          //     borderRadius: BorderRadius.circular(20),
          //   ),
          //   child: Row(
          //     children:  [
          //       Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 16),
          //       SizedBox(width: 6),
          //       // Text("Wallet : ₹ ${Helper().isvalidElement(wallet_amount) ? wallet_amount['amount'] : "0"}", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
          //       TextButton(
          //         onPressed: () {
          //           Navigator.push(
          //             context,
          //             MaterialPageRoute(builder: (context) => Walletscreens()),
          //           );
          //         },
          //         child: Text(
          //           "Wallet : ₹ ${Helper().isvalidElement(wallet_amount) ? wallet_amount['amount'] : "0"}",
          //           style: TextStyle(
          //             color: Colors.white,
          //             fontSize: 13,
          //             fontWeight: FontWeight.w500,
          //           ),
          //         ),
          //       )
          //     ],
          //   ),
          // ),
          Container(
  height: screenHeight * 0.055, // slightly flexible
  padding: EdgeInsets.symmetric(
    horizontal: screenWidth * 0.03,
    vertical: screenHeight * 0.008,
  ),
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.2),
    borderRadius: BorderRadius.circular(20),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        Icons.account_balance_wallet_outlined,
        color: Colors.white,
        size: screenWidth * 0.045, // responsive icon
      ),
      SizedBox(width: screenWidth * 0.02),

      /// Flexible prevents overflow
      Flexible(
        child: TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero, // remove extra padding
            minimumSize: Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Walletscreens()),
            );
          },
          child: Text(
            "Wallet : ₹ ${Helper().isvalidElement(wallet_amount) ? wallet_amount['amount'] : "0"}",
            overflow: TextOverflow.ellipsis, // prevent overflow
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.032, // responsive text
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    ],
  ),
)
        ],
      ),
    );
  }

  Widget _buildBannerSection(double screenHeight) {
    if (banners.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CarouselSlider.builder(
              itemCount: banners.length,
              itemBuilder: (context, index, _) {
                return Image.network(
                  Uri.encodeFull(banners[index]),
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.asset("assets/images/AppLogo.jpg", fit: BoxFit.cover, width: double.infinity),
                );
              },
              options: CarouselOptions(
                height: screenHeight * 0.22,
                viewportFraction: 1.0,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 3),
                autoPlayCurve: Curves.easeInOut,
                onPageChanged: (index, _) => setState(() => _currentBanner = index),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(banners.length, (i) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _currentBanner == i ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _currentBanner == i ? custom_color.app_color : Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
    );
  }

  Widget _buildMenuGrid() {
    final items = [
      {"icon": Icons.inventory_2_outlined, "label": "Products", "color": const Color(0xFF0D6EFD)},
      {"icon": Icons.assignment_outlined, "label": "Orders", "color": const Color(0xFF06826f)},
      {"icon": Icons.people_outline, "label": "Add Customer", "color": const Color(0xFFE67E22)},
      {"icon": Icons.percent_outlined, "label": "Sales", "color": const Color(0xFF8E44AD)},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.1,
        ),
        itemBuilder: (context, i) {
          final item = items[i];
          final color = item['color'] as Color;
          return _buildMenuCard(item['icon'] as IconData, item['label'] as String, color);
        },
      ),
    );
  }

  Widget _buildMenuCard(IconData icon, String label, Color color) {
    return GestureDetector(
      // onTap: () => print("$label tapped"),
      onTap: () {
        if(label == "Products"){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>Dashboard()));
        }else if(label == "Orders"){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>Orders()));
        }else if(label == "Add Customer"){
          Navigator.push(context, MaterialPageRoute(builder: (context) => Referecustomer()));
        }else if(label == "Sales"){
          Navigator.push(context, MaterialPageRoute(builder: (context) => Sales()));
        }
      },
      child: Container(
        // decoration: BoxDecoration(
        //   color: Colors.white,
        //   borderRadius: BorderRadius.circular(18),
        //   boxShadow: [
        //     BoxShadow(color: color.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4)),
        //   ],
        // ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),

            // Right & Bottom light shadow
          boxShadow: [
                    BoxShadow(color: color.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4)),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificationSection() {
    final screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CarouselSlider.builder(
              itemCount: certification_list.length,
              itemBuilder: (context, index, _) {
                final url = certification_list[index].toString();
                return Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(child: Image.asset("assets/images/AppLogo.png", width: 60, fit: BoxFit.contain));
                    },
                    errorBuilder: (_, __, ___) => Image.asset("assets/images/AppLogo.png", fit: BoxFit.contain),
                  ),
                );
              },
              options: CarouselOptions(
                height: screenHeight * 0.18,
                viewportFraction: 1.0,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 3),
                autoPlayCurve: Curves.easeInOut,
                onPageChanged: (index, _) => setState(() => _currentCert = index),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(certification_list.length, (i) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _currentCert == i ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _currentCert == i ? custom_color.app_color : Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {"icon": Icons.home_rounded, "label": "Home"},
      {"icon": Icons.emoji_events_outlined, "label": "Leaderboard"},
      {"icon": Icons.favorite_border_rounded, "label": "Favourites"},
      {"icon": Icons.person_outline_rounded, "label": "Profile"},
    ];

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, -4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (i) {
            final isActive = _currentNavIndex == i;
            return GestureDetector(
              // onTap: () => setState(() => _currentNavIndex = i),
              onTap: () {
                if(i == 0){
                  //do nothing
                  }else if(i == 1){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Leaderboard()));
                  }else if(i == 2){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>Favourites()));
                  }else if(i == 3){
                     Navigator.push(context, MaterialPageRoute(builder: (context)=>Profilepage()));
                  }
      
                  setState(() => _currentNavIndex = i);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive ? custom_color.app_color.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(items[i]['icon'] as IconData, color: isActive ? custom_color.app_color : Colors.grey[400], size: 22),
                    const SizedBox(height: 3),
                    Text(
                      items[i]['label'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                        color: isActive ? custom_color.app_color : Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
