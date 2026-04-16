import 'package:burmapartner/Dashboard/HomePage.dart';
import 'package:burmapartner/RefereCustomer/AddRefereCustomer.dart';
import 'package:burmapartner/RefereCustomer/RefereCusApi.dart';
import 'package:burmapartner/RefereCustomer/RefereCusDeails.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Common/colors.dart' as custom_color;

class Referecustomer extends StatefulWidget {
  const Referecustomer({super.key});

  @override
  State<Referecustomer> createState() => _ReferecustomerState();
}

class _ReferecustomerState extends State<Referecustomer> {

final LocalStorage storage = new LocalStorage('app_store');
 
  late SharedPreferences pref;
  

  bool isLoading = false;
  var userResponse;
  var accesstoken;
  var customer_id;

  int limit = 100;
  int offset = 0;
  ScrollController _scrollController = ScrollController();
  bool isMoreLoading = false;
  bool hasMoreData = true;

  List customer_list = [];
  @override
  void initState() {
    super.initState();
    initPreferencess();
        _scrollController.addListener(() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !isMoreLoading &&
        hasMoreData) {
      loadMoreData();
    }
  });
  }

 initPreferencess() async {
    await storage.ready;
    pref = await SharedPreferences.getInstance();
    userResponse = await storage.getItem('userResponse');

  if (userResponse != null) {
    accesstoken = userResponse['api_token'];
    customer_id = userResponse['customer_id'].toString();
  }
      await getCustomersList();
      setState(() {});
  }
void loadMoreData() {
  offset += limit;
  getCustomersList(isLoadMore: true);
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
      customer_list.addAll(newData);
    } else {
      customer_list = newData;
    }
  }

  setState(() {
    isLoading = false;
    isMoreLoading = false;
  });
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
          title: Text("Customer",style: TextStyle(color: Colors.white),),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios,color: Colors.white,),
            onPressed: (){
              Navigator.push(context,MaterialPageRoute(builder: (context) => Homepage()));
            },
          ),
        ),
        body: SafeArea(
          child: isLoading
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
            )
             : customer_list.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  const Text(
                    "No Customer Found",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  )
                ],
              ),
            )
          : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: customer_list.length + (isMoreLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == customer_list.length) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: CircularProgressIndicator(color: custom_color.app_color),
                    ),
                  );
                }
                return _customerCard(customer_list[index]);
              },
            )
          
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context)=>Addreferecustomer()));
          },
          child: Icon(Icons.add,color: Colors.white,),
          backgroundColor: custom_color.app_color,
        ),
      ));
  }

  Widget _customerCard(Map item) {
  return InkWell(
    onTap: () {
       Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Referecusdeails(
            selected_data: item,
          ),
        ),
      );
    },
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 26,
            backgroundColor: custom_color.app_color.withOpacity(0.1),
            child: Text(
              (item['name'] ?? "U")[0].toUpperCase(),
              style: TextStyle(
                color: custom_color.app_color,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
    
          const SizedBox(width: 12),
    
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] ?? "",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['mobile'] ?? "",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
    
          // Sales badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Sales : ₹${item['sales'] ?? 0}",
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}