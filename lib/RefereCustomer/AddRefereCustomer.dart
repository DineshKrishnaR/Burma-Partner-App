import 'package:burmapartner/Dashboard/HomePage.dart';
import 'package:burmapartner/ProfilePage/ProfilePageApi.dart';
import 'package:burmapartner/RefereCustomer/RefereCusApi.dart';
import 'package:burmapartner/RefereCustomer/Referecustomer.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:localstorage/localstorage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../Common/colors.dart' as custom_color;

class Addreferecustomer extends StatefulWidget {
  const Addreferecustomer({super.key});

  @override
  State<Addreferecustomer> createState() => _AddreferecustomerState();
}

class _AddreferecustomerState extends State<Addreferecustomer> {
  final LocalStorage storage = new LocalStorage('app_store');
  TextEditingController namecontroller = TextEditingController();
  TextEditingController mobilecontroller = TextEditingController();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController gendercontroller = TextEditingController();
  TextEditingController addresscontroller = TextEditingController();
  TextEditingController address2controller = TextEditingController();
  TextEditingController areacontroller = TextEditingController();
  TextEditingController citycontroller = TextEditingController();
  TextEditingController landmarkcontroller = TextEditingController();
  TextEditingController statecontroller = TextEditingController();
  TextEditingController pincontroller = TextEditingController();
  TextEditingController gstcontroller = TextEditingController();
  late SharedPreferences pref;
  bool isLoading = false;
  var userResponse;
  var accesstoken;
  var customer_id;
  List StateList = [];
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
      await gerStateList();
      setState(() {});
  }

 Future<void> gerStateList() async {
    setState(() => isLoading = true);
   var data = {
         "action": "get_state",
         "accesskey":"90336",
         "token":accesstoken,
   };
    final response = await Profilepageapi().gerStateList(data);

    print(response);

    if(response != null){
      StateList = response['res'] ?? [];
      

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
          title: Text("Add Customer",style: TextStyle(color: Colors.white),),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios,color: Colors.white,),
            onPressed: (){
              Navigator.push(context,MaterialPageRoute(builder: (context) => Referecustomer()));
            },
          ),
        ),
        body: SafeArea(
          child: isLoading
            ? _buildShimmer()
            : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                    Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [

                  // buildTextField("Name",required:true),
                  TextFormField(
                    controller: namecontroller,
                   inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        return newValue.text.contains("  ") ? oldValue : newValue;
                      }),
                    ],
                        maxLength: 50,
                    decoration: InputDecoration(
                      labelText: 'Name *',
                      counterText: "",
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
                    controller: mobilecontroller,
                    maxLength: 10,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'Mobile Number *',
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
                    controller: emailcontroller,
                    decoration: InputDecoration(
                      labelText: 'Email *',
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
                   
                  //   Container(
                  //   child: TextField(
                  //     controller: dobcontroller,
                  //     decoration: InputDecoration(
                  //         border: OutlineInputBorder(
                  //           borderRadius: BorderRadius.circular(10),
                  //         ),
                  //          enabledBorder: OutlineInputBorder(
                  //         borderRadius: BorderRadius.circular(10),
                  //         borderSide: BorderSide(
                  //           color: custom_color.app_color,
                  //           width: 1.5,
                  //         ),
                  //       ),

                  //       focusedBorder: OutlineInputBorder(
                  //         borderRadius: BorderRadius.circular(10),
                  //         borderSide: BorderSide(
                  //           color: custom_color.app_color,
                  //           width: 2,
                  //         ),
                  //       ),
                  //         fillColor: Colors.grey.shade100,
                  //         prefixIcon: Icon(
                  //           Icons.calendar_month,
                  //           color: custom_color.app_color,
                  //         ),
                          
                  //         labelText: "D.O.B"),
                          
                  //     readOnly: true,
                  //     onTap: (() {
                  //       _selectDate();
                  //     }),
                  //   ),
                  // ),
                  SizedBox(height: screenHeight*0.02,),

                  const SizedBox(height:10),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Gender",
                        style: TextStyle(
                            fontSize:16,
                            fontWeight: FontWeight.w600)),
                  ),

                  const SizedBox(height:10),

                 Row(
                  children: [
                    genderButton("Male", gendercontroller.text == "Male"),
                    const SizedBox(width:10),
                    genderButton("Female", gendercontroller.text == "Female"),
                  ],
                ),

                  const SizedBox(height:16),
                    TextFormField(
                      controller: gstcontroller,
                    decoration: InputDecoration(
                      labelText: 'GST No',
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
                    controller: addresscontroller,
                    decoration: InputDecoration(
                      labelText: 'Address Line 1 *',
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
                    controller: address2controller,
                    decoration: InputDecoration(
                      labelText: 'Address Line 2 *',
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
                    controller: areacontroller,
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
                    controller: landmarkcontroller,
                    decoration: InputDecoration(
                      labelText: 'Landmark',
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
                    controller: citycontroller,
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
                  //  TextFormField(
                  //   controller: statecontroller,
                  //   decoration: InputDecoration(
                  //     labelText: 'State *',
                  //     fillColor: Colors.grey.shade100,
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(10),
                  //     ),
                  //      enabledBorder: OutlineInputBorder(
                  //         borderRadius: BorderRadius.circular(10),
                  //         borderSide: BorderSide(
                  //           color: custom_color.app_color,
                  //           width: 1.5,
                  //         ),
                  //       ),

                  //       focusedBorder: OutlineInputBorder(
                  //         borderRadius: BorderRadius.circular(10),
                  //         borderSide: BorderSide(
                  //           color: custom_color.app_color,
                  //           width: 2,
                  //         ),
                  //       ),
                  //   ),
                  // ),
                  Container(
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
                                  statecontroller.text = value['state'].toString();
                                }
                              },

                              selectedItem: StateList.isNotEmpty
                                  ? StateList.firstWhere(
                                      (item) => item['state'] == statecontroller.text,
                                      orElse: () => StateList.first,
                                    )
                                  : null,
                            ),
                          
                        ),
                      ),
                  SizedBox(height: screenHeight*0.02,),
                  
                   TextFormField(
                    controller: pincontroller,
                    maxLength: 6,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'Pincode *',
                      counterText: "",
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

                  const SizedBox(height:20),

                  /// UPDATE BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: custom_color.button_color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
  
                      onPressed: () async {

                      if(isLoading) return; // prevent multiple click

                      String name = namecontroller.text.trim();
                      String email = emailcontroller.text.trim();

                      // ✅ NAME VALIDATION
                      if(name.isEmpty){
                        Fluttertoast.showToast(msg: 'Enter your Name');
                        return;
                      }

                      RegExp nameRegex = RegExp(r"^[a-zA-Z ]{2,50}$");
                      if(!nameRegex.hasMatch(name)){
                        Fluttertoast.showToast(msg: 'Enter valid name (only letters)');
                        return;
                      }

                      // ✅ EMAIL VALIDATION
                      if(email.isEmpty){
                        Fluttertoast.showToast(msg: 'Enter your Email');
                        return;
                      }

                      RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if(!emailRegex.hasMatch(email)){
                        Fluttertoast.showToast(msg: 'Enter valid email');
                        return;
                      }

                      // ✅ ADDRESS VALIDATION
                      if(addresscontroller.text.trim().isEmpty){
                        Fluttertoast.showToast(msg: 'Enter Address Line 1');
                        return;
                      }

                      if(address2controller.text.trim().isEmpty){
                        Fluttertoast.showToast(msg: 'Enter Address Line 2');
                        return;
                      }

                      if(areacontroller.text.trim().isEmpty){
                        Fluttertoast.showToast(msg: 'Enter Area');
                        return;
                      }

                      if(citycontroller.text.trim().isEmpty){
                        Fluttertoast.showToast(msg: 'Enter City');
                        return;
                      }

                      if(statecontroller.text.trim().isEmpty){
                        Fluttertoast.showToast(msg: 'Enter State');
                        return;
                      }

                      if(pincontroller.text.trim().length != 6){
                        Fluttertoast.showToast(msg: 'Enter valid Pincode');
                        return;
                      }

                      // ✅ GST VALIDATION
                      RegExp gstRegex = RegExp(
                        r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$'
                      );

                      

                      // ✅ API CALL
                      setState(() => isLoading = true);

                      var data = {
                        "action":"referal_customer_register",
                        "name": name,
                        "mobile": mobilecontroller.text.trim(),
                        "email": email,
                        "gender": gendercontroller.text.trim(),
                        "address": addresscontroller.text.trim(),
                        "address2": address2controller.text.trim(),
                        "area": areacontroller.text.trim(),
                        "city": citycontroller.text.trim(),
                        "landmark": landmarkcontroller.text.trim(),
                        "state": statecontroller.text.trim(),
                        "pin": pincontroller.text.trim(),
                        "wtob":"CUST",
                        "accesskey":"90336",
                        "act_type": userResponse['act_type'],
                        "token": accesstoken,
                        "customer_id": customer_id,
                        "gstno":gstcontroller.text.toString()
                      };

                      final response = await Referecusapi().AddrefereCustomer(data);
                      setState(() => isLoading = false);

                      if (response == null) return;

                      if(response['code'] == 200){
                         
                        Fluttertoast.showToast(msg: 'Registration successful');
                       
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => Referecustomer()),
                          (route) => false,
                        );

                      } else {
                        Fluttertoast.showToast(msg: response?['message'] ?? 'Update failed');
                      }
                    },
                      child: const Text(
                        "Save",
                        style: TextStyle(fontSize:18,color: Colors.white),
                      ),
                    ),
                  ),

                   SizedBox(height:screenHeight*0.05)
                ],
              ),
            )
                ],
              ),
            ),
          )),
    ));
  }

  Widget _buildShimmer() {
    final sh = MediaQuery.of(context).size.height;
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(26),
        child: Column(
          children: [
            ...List.generate(8, (_) => Padding(
              padding: EdgeInsets.only(bottom: sh * 0.02),
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            )),
            // Gender row
            Padding(
              padding: EdgeInsets.only(bottom: sh * 0.02),
              child: Row(
                children: [
                  Expanded(child: Container(height: 52, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)))),
                  const SizedBox(width: 10),
                  Expanded(child: Container(height: 52, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)))),
                ],
              ),
            ),
            // Save button
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget genderButton(String text, bool selected) {
  return Expanded(
    child: GestureDetector(
      onTap: (){
        setState(() {
          gendercontroller.text = text;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical:14),
        decoration: BoxDecoration(
          color: selected ? custom_color.app_color : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: custom_color.app_color),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: selected ? Colors.white : custom_color.app_color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ),
  );
}
}