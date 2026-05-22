import 'package:burmapartner/Dashboard/HomePage.dart';
import 'package:burmapartner/ProfilePage/ProfilePageApi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:localstorage/localstorage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';
import '../Common/colors.dart' as custom_color;

class Referearn extends StatefulWidget {
  const Referearn({super.key});

  @override
  State<Referearn> createState() => _ReferearnState();
}

class _ReferearnState extends State<Referearn> {
   final LocalStorage storage = LocalStorage('app_store');
  var userResponse;
  var accesstoken;
  bool isLoading = false;
  late SharedPreferences pref;
  var customer_id;

  bool isProfileLoaded = false;

  String selectedType = "customer";
  @override
  void initState() {
    super.initState();
    initPreferences();
  }

  initPreferences() async {
    pref = await SharedPreferences.getInstance();
    await storage.ready;
    userResponse = await storage.getItem('userResponse');
     
    if (userResponse != null) {
      accesstoken = userResponse['api_token'];
      customer_id = userResponse['customer_id'].toString();

    }
 
    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>Homepage()));
      },
      child: Scaffold(
           appBar: AppBar(
          backgroundColor: custom_color.app_color,
          title: Text("Refere & Earn",style: TextStyle(color: Colors.white),),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios,color: Colors.white,),
            onPressed: (){
              Navigator.push(context,MaterialPageRoute(builder: (context) => Homepage()));
            },
          ),
        ),
        body: SafeArea(
          child: isLoading
              ? _buildShimmer()
              : Container(
          width: double.infinity,
          color: Colors.grey.shade100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
          
              /// Top Text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  "Refer Your Friends And Can Earn. You Can Use It When Order Placement!!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          
              SizedBox(height: 30),
          
              /// Gift Icon
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: custom_color.app_color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.card_giftcard,
                  size: 40,
                  color: custom_color.app_color,
                ),
              ),
          
              SizedBox(height: 15),
          
              /// Title
              Text(
                "Refer & Earn",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
          
              SizedBox(height: 15),
          
              /// Subtitle
              Text(
                "Your Referral Code",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
          
              SizedBox(height: 15),
          
              /// Referral Code Box
              Container(
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: custom_color.app_color,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  userResponse?['referral_code'] ?? "",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
          
              SizedBox(height: 10),
          
              /// Tap to Copy
              GestureDetector(
                onTap: () {
                  final code = userResponse?['referral_code'] ?? "";
                  Clipboard.setData(ClipboardData(text: code));
          
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   SnackBar(content: Text("Copied: $code")),
                  // );
                  Fluttertoast.showToast(msg: "Copied : $code");
                },
                child: Text(
                  "Tap To Copy",
                  style: TextStyle(
                    color: custom_color.app_color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          
              SizedBox(height: 40),
          
              /// REFER NOW Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: custom_color.app_color,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      showReferDialog();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.share, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          "REFER NOW",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
                ),
        ),
      ));
  }

  Widget _buildShimmer() {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        color: Colors.grey.shade100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: sw * 0.75, height: sh * 0.05, color: Colors.white),
            SizedBox(height: sh * 0.04),
            Container(width: sw * 0.2, height: sw * 0.2, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
            SizedBox(height: sh * 0.02),
            Container(width: sw * 0.3, height: sh * 0.025, color: Colors.white),
            SizedBox(height: sh * 0.02),
            Container(width: sw * 0.35, height: sh * 0.018, color: Colors.white),
            SizedBox(height: sh * 0.02),
            Container(
              width: sw * 0.5,
              height: sh * 0.055,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            ),
            SizedBox(height: sh * 0.015),
            Container(width: sw * 0.25, height: sh * 0.016, color: Colors.white),
            SizedBox(height: sh * 0.05),
            Container(
              width: sw * 0.7,
              height: sh * 0.065,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
            ),
          ],
        ),
      ),
    );
  }

  void showReferDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text("Wish to Refer"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile(
                  value: "customer",
                  groupValue: selectedType,
                   activeColor: custom_color.app_color,
                  onChanged: (value) {
                    setStateDialog(() {
                      selectedType = value!;
                    });
                  },
                  title: Text("Customer"),
                ),
                RadioListTile(
                  value: "others",
                  groupValue: selectedType,
                   activeColor: custom_color.app_color,
                  onChanged: (value) {
                    setStateDialog(() {
                      selectedType = value!;
                    });
                  },
                  title: Text("Others (Retailer)"),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);

                  if (selectedType == "customer") {
                    openCustomerApp();
                  } else {
                    openPartnerApp();
                  }
                },
                child: Text("Continue",style: TextStyle(color: custom_color.app_color),),
              )
            ],
          );
        },
      );
    },
  );
}
Future<void> openCustomerApp() async {
  final Uri url = Uri.parse(
      "https://play.google.com/store/apps/details?id=YOUR_CUSTOMER_APP_ID");

  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    throw "Could not launch $url";
  }
}

Future<void> openPartnerApp() async {
  final Uri url = Uri.parse(
      "https://play.google.com/store/apps/details?id=YOUR_PARTNER_APP_ID");

  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    throw "Could not launch $url";
  }
}
}