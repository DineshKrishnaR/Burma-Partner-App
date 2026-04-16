import 'package:burmapartner/RefereCustomer/RefereCusApi.dart';
import 'package:burmapartner/RefereCustomer/RefereCustomer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Common/colors.dart' as custom_color;

class Referecusdeails extends StatefulWidget {
  final selected_data;
  const Referecusdeails({super.key,required this.selected_data});

  @override
  State<Referecusdeails> createState() => _ReferecusdeailsState();
}

class _ReferecusdeailsState extends State<Referecusdeails> {
  final LocalStorage storage = new LocalStorage('app_store');
  late SharedPreferences pref;
  bool isLoading = false;
  var userResponse;
  var accesstoken;
  var customer_id;
  List customer_details = [];
  var selecteddata;
  String selectedFilter = "Today";
  List salesList = [];
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
      await gerCustomerDetails();
      setState(() {});
  }

 Future<void> gerCustomerDetails() async {
    setState(() => isLoading = true);
   var data = {
         "action": "get_customer_dtl",
         "accesskey":"90336",
         "customer_id":customer_id.toString(),
         "cust_id":selecteddata['customer_id'].toString(),
         "token":accesstoken,
         "act_type": userResponse['act_type'],
   };
    final response = await Referecusapi().gerCustomerDetails(data);

    print(response);

    if(response != null){
      customer_details = response['res'] ?? [];
      

    setState(() => isLoading = false);
  }
 }
  @override
  Widget build(BuildContext context) {
     double screenHeight = MediaQuery.of(context).size.height;
     double screenWidth = MediaQuery.of(context).size.width; 
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>Referecustomer()));
      },
      child: Scaffold(
         appBar: AppBar(
          backgroundColor: custom_color.app_color,
          title: Text("Customer Details",style: TextStyle(color: Colors.white),),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios,color: Colors.white,),
            onPressed: (){
              Navigator.push(context,MaterialPageRoute(builder: (context) => Referecustomer()));
            },
          ),
        ),
        body: SafeArea(
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: custom_color.app_color,
                  ),
                )
              : _buildUI(),
        ),
      ));
  }
  Widget _buildUI() {
  var data = customer_details.isNotEmpty ? customer_details[0] : {};

  return Column(
    children: [
      _customerHeader(data),
      const SizedBox(height: 12),
      _dateDropdown(),
      const SizedBox(height: 20),
      Expanded(
        child: _salesSection(),
      ),
    ],
  );
}
Widget _customerHeader(Map data) {
  return Container(
    margin: const EdgeInsets.all(12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 10,
          offset: Offset(0, 4),
        )
      ],
    ),
    child: Row(
      children: [
        // Avatar
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade200,
          ),
          child: Icon(Icons.person, size: 40),
        ),

        const SizedBox(width: 12),

        // Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data['name'] ?? "",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),

              Row(
                children: [
                  Icon(Icons.phone, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(data['mobile'] ?? ""),
                ],
              ),

              const SizedBox(height: 6),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "${data['address'] ?? ""}, ${data['city'] ?? ""}, ${data['state'] ?? ""}, ${data['pin'] ?? ""}",
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
Widget _dateDropdown() {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 12),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      border: Border.all(color: custom_color.app_color),
      borderRadius: BorderRadius.circular(30),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: selectedFilter,
        isExpanded: true,
        icon: Icon(Icons.keyboard_arrow_down),
        items: ["Today", "Week", "Month", "Year"]
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ))
            .toList(),
        onChanged: (val) {
          setState(() {
            selectedFilter = val!;
          });
          getReferalCustomerReport();
        },
      ),
    ),
  );
}
String getFilterValue(String uiValue) {
  switch (uiValue) {
    case "Today":
      return "today";
    case "Week":
      return "weekly";
    case "Month":
      return "monthly";
    case "Year":
      return "yearly";
    default:
      return "today";
  }
}
Widget _salesSection() {
  if (salesList.isEmpty) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          "assets/images/AppLogo.png",
          height: 180,
        ),
        const SizedBox(height: 10),
        Text(
          "No Sales found",
          style: TextStyle(
            color: custom_color.app_color,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  return ListView.builder(
    itemCount: salesList.length,
    itemBuilder: (context, index) {
      var item = salesList[index];

      return ListTile(
        title: Text("Order ID: ${item['id'] ?? ''}"),
        subtitle: Text("Amount: ₹${item['amount'] ?? 0}"),
      );
    },
  );
}

getReferalCustomerReport()async{

  var data = {
    "action": "get_customer_report",
    "accesskey":"90336",
    "customer_id":customer_id.toString(),
    "refer_customer":"Y",
    "cust_id":selecteddata['customer_id'].toString(),
    "token":accesstoken,
    "act_type": userResponse['act_type'],
    "report": getFilterValue(selectedFilter),
  };
  
  final response = await Referecusapi().getReferalCustomerReport(data);

  if (response != null) {
    setState(() {
      salesList = response['sales'] ?? [];
    });
  }
}
}