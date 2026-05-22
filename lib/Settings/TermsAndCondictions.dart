
import 'package:burmapartner/Dashboard/Dashboard.dart';
import 'package:burmapartner/Dashboard/HomePage.dart';
import 'package:burmapartner/Settings/AboutApi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:localstorage/localstorage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../Common/colors.dart' as custom_color;

class Termsandcondictions extends StatefulWidget {
  const Termsandcondictions({super.key});

  @override
  State<Termsandcondictions> createState() => _TermsandcondictionsState();
}

class _TermsandcondictionsState extends State<Termsandcondictions> {
  
final LocalStorage storage = new LocalStorage('app_store');
 
  late SharedPreferences pref;
  
  
  bool isLoading = false;
  var userResponse;
  var accesstoken;
  var customer_id;
  var terms_conditions;
  List sections = [];
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
       TamesCondictions();
      setState(() {});
  }
  Future<void> TamesCondictions() async {
    setState(() => isLoading = true);
   var data = {
         "method": "terms_conditions",
         "accesskey":"90336",
         "token":accesstoken,
   };
    final response = await Aboutapi().TamesCondictions(data);

    print(response);

    if(response != null){
      terms_conditions = response['message'] ?? [];
      sections = _buildSections(terms_conditions ?? "");

    setState(() => isLoading = false);
  }else{
    terms_conditions = [];
    setState(() => isLoading = false);
  }

 }

  List<Map<String, dynamic>> _buildSections(String html) {
    List<String> parts = html
        .split(RegExp(r'</p>|<br>|\r\n\r\n'))
        .map((s) => s.replaceAll(RegExp(r'<[^>]*>'), '').replaceAll('&nbsp;', ' ').trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final icons = [
      Icons.gavel_outlined,
      Icons.check_circle_outline,
      Icons.shield_outlined,
      Icons.lock_outline,
      Icons.verified_outlined,
      Icons.rule_outlined,
      Icons.handshake_outlined,
      Icons.info_outline,
    ];

    return parts.asMap().entries.map((e) => {
      "icon": icons[e.key % icons.length],
      "text": e.value,
    }).toList();
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
          title: Text("Terms & Condictions",style: TextStyle(color: Colors.white),),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios,color: Colors.white,),
            onPressed: (){
              // Navigator.push(context, MaterialPageRoute(builder: (context)=>Dashboard()));
              Navigator.push(context,MaterialPageRoute(builder: (context) => Homepage()));
            },
          ),
        ),
        // body: SafeArea(
        //   child: isLoading
        //     ? _buildShimmer()
        //     : terms_conditions == null || terms_conditions.toString().isEmpty
        //   ? Center(
        //       child: Column(
        //         mainAxisAlignment: MainAxisAlignment.center,
        //         children: [
        //           Icon(Icons.description_outlined,
        //               size: 80, color: Colors.grey),
        //           const SizedBox(height: 10),
        //           const Text(
        //             "No Terms & Condictions Found",
        //             style: TextStyle(fontSize: 18, color: Colors.grey),
        //           )
        //         ],
        //       ),
        //     )
        //     : SingleChildScrollView(
        //         child: Column(
        //           children: [
          
        //             /// 🔥 TOP GRADIENT CARD
        //             Container(
        //               margin: const EdgeInsets.all(15),
        //               padding: const EdgeInsets.symmetric(vertical: 35),
        //               width: double.infinity,
        //               decoration: BoxDecoration(
        //                 gradient: LinearGradient(
        //                   colors: [
        //                     custom_color.app_color,
        //                     custom_color.app_color.withOpacity(0.8),
        //                   ],
        //                   begin: Alignment.topLeft,
        //                   end: Alignment.bottomRight,
        //                 ),
        //                 borderRadius: BorderRadius.circular(20),
        //                 boxShadow: [
        //                   BoxShadow(
        //                     color: Colors.black.withOpacity(.15),
        //                     blurRadius: 12,
        //                     offset: const Offset(0, 6),
        //                   )
        //                 ],
        //               ),
        //               child: Column(
        //                 children: const [
        //                   Icon(
        //                     Icons.description_outlined,
        //                     size: 80,
        //                     color: Colors.white,
        //                   ),
        //                   SizedBox(height: 10),
        //                   Text(
        //                     "Terms & Condictions",
        //                     style: TextStyle(
        //                       fontSize: 22,
        //                       color: Colors.white,
        //                       fontWeight: FontWeight.bold,
        //                     ),
        //                   )
        //                 ],
        //               ),
        //             ),
          
        //             /// 🔥 CONTENT BOX
        //             Container(
        //               margin: const EdgeInsets.symmetric(horizontal: 15),
        //               padding: const EdgeInsets.all(18),
        //               decoration: BoxDecoration(
        //                 color: Colors.white,
        //                 borderRadius: BorderRadius.circular(15),
        //                 boxShadow: [
        //                   BoxShadow(
        //                     color: Colors.black.withOpacity(.05),
        //                     blurRadius: 10,
        //                   )
        //                 ],
        //               ),
        //               child: Html(
        //                 data: terms_conditions ?? "",
        //                 style: {
        //                   "p": Style(
        //                     fontSize: FontSize(16),
        //                     color: Colors.black87,
        //                     lineHeight: const LineHeight(1.6),
        //                   ),
        //                 },
        //               ),
        //             ),
          
        //             const SizedBox(height: 25),
        //           ],
        //         ),
        //       ),
        // ),
         body: SafeArea(
          child: isLoading
            // ?Center(
            //   child: Column(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: [
            //       Image.asset(
            //         "assets/images/AppLogo.png",
            //         width: 100,
            //         height: 100,
            //       ),
            //       const SizedBox(height: 20),
            //        CircularProgressIndicator(color: custom_color.app_color,),
            //     ],
            //   ),
            // )
             ? _buildShimmer()
             : sections.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.description_outlined, size: 80, color: Colors.grey),
                  const SizedBox(height: 10),
                  const Text("No Terms & Conditions Found",
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    /// TOP GRADIENT CARD
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
                      child: const Column(
                        children: [
                          Icon(Icons.description_outlined, size: 80, color: Colors.white),
                          SizedBox(height: 10),
                          Text(
                            "Terms & Conditions",
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ),

                    /// POINTS
                    Column(
                      children: sections.map((item) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.05),
                                blurRadius: 10,
                              )
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: custom_color.app_color.withOpacity(.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  item['icon'],
                                  color: custom_color.app_color,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item['text'],
                                  style: const TextStyle(
                                    fontSize: 15,
                                    height: 1.6,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 25),
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
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(8, (i) => Padding(
                  padding: EdgeInsets.only(bottom: sh * 0.015),
                  child: Container(
                    width: i % 3 == 0 ? sw * 0.6 : double.infinity,
                    height: sh * 0.016,
                    color: Colors.white,
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