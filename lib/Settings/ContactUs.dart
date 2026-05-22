
import 'package:burmapartner/Dashboard/Dashboard.dart';
import 'package:burmapartner/Dashboard/HomePage.dart';
import 'package:burmapartner/Settings/AboutApi.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Common/colors.dart' as custom_color;

class Contactus extends StatefulWidget {
  const Contactus({super.key});

  @override
  State<Contactus> createState() => _ContactusState();
}

class _ContactusState extends State<Contactus> {

final LocalStorage storage = new LocalStorage('app_store');
 
  late SharedPreferences pref;
  
  var device_id;
  bool isLoading = false;
  var userResponse;
  var accesstoken;
  var customer_id;
  var contacy_us;
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
      await ContactUs();
      setState(() {});
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
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        // Navigator.push(context, MaterialPageRoute(builder: (context)=>Dashboard()));
        Navigator.push(context,MaterialPageRoute(builder: (context) => Homepage()));
      },
      child: Scaffold(
         appBar: AppBar(
          backgroundColor: custom_color.app_color,
          title: Text("Contact Us",style: TextStyle(color: Colors.white),),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios,color: Colors.white,),
            onPressed: (){
              // Navigator.push(context, MaterialPageRoute(builder: (context)=>Dashboard()));
              Navigator.push(context,MaterialPageRoute(builder: (context) => Homepage()));
            },
          ),
        ),
        body: SafeArea(
  child: isLoading
      ? _buildShimmer()
      : contacy_us == null || contacy_us.toString().isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.description_outlined,
                      size: 80, color: Colors.grey),
                  const SizedBox(height: 10),
                  const Text(
                    "No Contacy Us Found",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  )
                ],
              ),
            )
      : SingleChildScrollView(
          child: Column(
            children: [

              /// 🔥 TOP GRADIENT CARD
              Container(
                margin: const EdgeInsets.all(15),
                padding: const EdgeInsets.symmetric(vertical: 35),
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      custom_color.app_color,
                      custom_color.app_color.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.15),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: Column(
                  children: const [
                    Icon(
                      Icons.call,
                      size: 80,
                      color: Colors.white,
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Contact Us",
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),

              /// 🔥 CONTACT DETAILS CARD
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.05),
                      blurRadius: 12,
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// 📞 PHONE
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.phone, color: Colors.grey),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Contact number",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 5),
                              GestureDetector(
                                onTap: () {
                                  final phone = contacy_us?['mobile'] ?? "";
                                  if (phone.isNotEmpty) launchUrl(Uri(scheme: 'tel', path: phone));
                                },
                                child: Text(
                                  contacy_us?['mobile'] ?? "",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 25),

                    /// 📧 EMAIL
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.email, color: Colors.grey),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Email",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 5),
                              GestureDetector(
                                onTap: () {
                                  final email = contacy_us?['mail']?.trim() ?? "";
                                  if (email.isNotEmpty) launchUrl(Uri(scheme: 'mailto', path: email));
                                },
                                child: Text(
                                  contacy_us?['mail']?.trim() ?? "",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 25),

                    /// 📍 ADDRESS
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on, color: Colors.grey),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Address",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 5),
                              // Text(
                              //   contacy_us?['address']?.trim() ?? "",
                              //   style: const TextStyle(
                              //     fontSize: 15,
                              //   ),
                              // ),
                              Text(
                                ((contacy_us?['address'] ?? "").toString().isNotEmpty)
                                    ? (contacy_us!['address'][0].toUpperCase() +
                                        contacy_us['address'].substring(1).toLowerCase())
                                    : "",
                                style: const TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
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
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(15),
              width: double.infinity,
              height: sh * 0.22,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
              child: Column(
                children: List.generate(3, (i) => Padding(
                  padding: EdgeInsets.only(bottom: sh * 0.025),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: sw * 0.06, height: sw * 0.06, color: Colors.white),
                      SizedBox(width: sw * 0.04),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(width: sw * 0.3, height: sh * 0.014, color: Colors.white),
                            SizedBox(height: sh * 0.01),
                            Container(width: sw * 0.55, height: sh * 0.02, color: Colors.white),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
              ),
            ),
            SizedBox(height: sh * 0.03),
          ],
        ),
      ),
    );
  }
}