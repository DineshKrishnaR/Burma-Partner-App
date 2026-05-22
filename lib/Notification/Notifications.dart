
import 'package:burmapartner/Dashboard/Dashboard.dart';
import 'package:burmapartner/Dashboard/DashboardApi.dart';
import 'package:burmapartner/Dashboard/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../Common/colors.dart' as custom_color;

class Notificationpage extends StatefulWidget {
  const Notificationpage({super.key});

  @override
  State<Notificationpage> createState() => _NotificationpageState();
}

class _NotificationpageState extends State<Notificationpage> {

final LocalStorage storage = new LocalStorage('app_store');
 
  late SharedPreferences pref;
  

  bool isLoading = false;
  var userResponse;
  var accesstoken;
  var customer_id;
  var notification;
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
      await AboutUs();
      setState(() {});
  }
  Future<void> AboutUs() async {
    setState(() => isLoading = true);
   var data = {
         "action": "notification",
         "accesskey":"90336",
         "customer_id":customer_id,
         "act_type":userResponse['act_type'],
         "limit":'100',
         "offset":"0",
         "token":accesstoken,
   };
    final response = await DashboardApi().getNotification(data);

    print(response);

    if(response != null){
      notification = response['data'] ?? [];
      // Mark all notifications as read
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('last_seen_notif_count', (notification as List).length);
    setState(() => isLoading = false);
  }else{
    notification = [];
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
        title: Text(
          "Notification",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            // Navigator.push(context,
            //     MaterialPageRoute(builder: (context) => Homepage()));
            Navigator.push(context,MaterialPageRoute(builder: (context) => Homepage()));
          },
        ),
      ),

      body: SafeArea(
        child: isLoading
            ? _buildShimmer()
            : notification == null || notification.length == 0
                ? const Center(
                    child: Text(
                      "No Notifications",
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: notification.length,
                    itemBuilder: (context, index) {
                      var item = notification[index];
        
                      return InkWell(
                         onTap: () {
        
                      /// Example navigation based on type
                      if(item['type'] == "product"){
                        print("Open product ${item['id']}");
                      }
                      else if(item['type'] == "category"){
                        print("Open category ${item['id']}");
                      }else if(item['type'] == "default"){
                        print("Open default ${item['id']}");
                      }
        
                    },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade200,
                                blurRadius: 6,
                                spreadRadius: 2,
                              )
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                        
                              /// ICON
                              Container(
                                height: 45,
                                width: 45,
                                decoration: BoxDecoration(
                                  color: custom_color.app_color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.notifications,
                                  color: Colors.black,
                                ),
                              ),
                        
                              const SizedBox(width: 12),
                        
                              /// TEXT
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                        
                                    /// TITLE
                                    Text(
                                      item['name'] ?? "",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                        
                                    const SizedBox(height: 5),
                        
                                    /// SUBTITLE
                                    Text(
                                      item['subtitle'] ?? "",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    ),
  );
}

  Widget _buildShimmer() {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: 8,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: sw * 0.11,
                height: sw * 0.11,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(width: sw * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: double.infinity, height: sh * 0.018, color: Colors.white),
                    SizedBox(height: sh * 0.01),
                    Container(width: sw * 0.55, height: sh * 0.014, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}