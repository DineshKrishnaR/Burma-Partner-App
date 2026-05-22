
import 'package:burmapartner/Common/FirebaseApi.dart';
import 'package:burmapartner/Dashboard/Dashboard.dart';
import 'package:burmapartner/Dashboard/HomePage.dart';
import 'package:burmapartner/ProfilePage/ProfilePageApi.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:localstorage/localstorage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../Common/colors.dart' as custom_color;

class Profilepage extends StatefulWidget {
  const Profilepage({super.key});

  @override
  State<Profilepage> createState() => _ProfilepageState();
}

// Blocks emoji and non-basic characters
final _noEmoji = FilteringTextInputFormatter.allow(RegExp(r'[\x20-\x7E\u00A0-\u024F]'));

// Blocks leading space
final _noLeadingSpace = TextInputFormatter.withFunction((old, newVal) {
  if (newVal.text.startsWith(' ')) return old;
  return newVal;
});

// Letters + single space only (for name, city)
final _lettersOnly = FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]'));

// No double space
final _noDoubleSpace = TextInputFormatter.withFunction((old, newVal) {
  if (newVal.text.contains('  ')) return old;
  return newVal;
});

// Address: letters, digits, space, comma, dot, hyphen, slash only
final _addressChars = FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ,./\-]'));

// Email: letters, digits, @, dot, underscore, hyphen only
final _emailChars = FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@._\-]'));

class _ProfilepageState extends State<Profilepage> {

  final LocalStorage storage = new LocalStorage('app_store');
  TextEditingController namecontroller = TextEditingController();
  TextEditingController mobilenocontroller = TextEditingController();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController dobcontroller = TextEditingController();
  TextEditingController gendercontroller = TextEditingController();
  TextEditingController gstcontroller = TextEditingController();
  TextEditingController address1controller = TextEditingController();
  TextEditingController address2controller = TextEditingController();
  TextEditingController areacontroller = TextEditingController();
  TextEditingController landmarkcontroller = TextEditingController();
  TextEditingController citycontroller = TextEditingController();
  TextEditingController statecontroller = TextEditingController();
  TextEditingController pincodecontroller = TextEditingController();
 
  late SharedPreferences pref;
  bool isLoading = false;
  var userResponse;
  var accesstoken;
  var customer_id;
  var fcmToken;
  var profile_details;
  List StateList = [];
  @override
  void initState() {
    super.initState();
    initPreferencess();
  }

 initPreferencess() async {
  setState(() => isLoading = true); 
    await storage.ready;
    pref = await SharedPreferences.getInstance();
    userResponse = await storage.getItem('userResponse');
    await FirebaseApi().initNotifications();
    fcmToken = await storage.getItem('fcmToken');
    if (userResponse != null) {
      accesstoken = userResponse['api_token'];
      customer_id = userResponse['customer_id'].toString();
    }
      await ProfileDetails();
      await gerStateList();
      setState(() => isLoading = false); 
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
    final response = await Profilepageapi().ProfileDetails(data);

    print(response);

    if(response != null){
      profile_details = response ?? [];
      namecontroller.text = profile_details['name'].toString();
      mobilenocontroller.text = profile_details['mobile'].toString();
      emailcontroller.text = profile_details['email'].toString();
      dobcontroller.text = profile_details['dob'].toString();
      setState(() {
        gendercontroller.text = profile_details['gender'].toString().toLowerCase();
      });
      gstcontroller.text = profile_details['gst_no'].toString();
      address1controller.text = profile_details['address'].toString();
      address2controller.text = profile_details['address2'].toString();
      areacontroller.text = profile_details['area'].toString();
      landmarkcontroller.text = profile_details['landmark'].toString();
      citycontroller.text = profile_details['city'].toString();
      statecontroller.text = profile_details['state'].toString();
      pincodecontroller.text = profile_details['pin'].toString();

    // setState(() => isLoading = false);
  }
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
  Map<String, dynamic>? selectedStateItem;
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        // Navigator.push(context, MaterialPageRoute(builder: (context) => Dashboard()));
        Navigator.push(context,MaterialPageRoute(builder: (context) => Homepage()));
      },
      child: Scaffold(
          appBar: AppBar(
          backgroundColor: custom_color.app_color,
          title: Text("Profile",style: TextStyle(color: Colors.white),),
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
           : SingleChildScrollView(
          child: Column(
            children: [
          
              /// HEADER
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 120,
                    color: custom_color.app_color,
                  ),
          
                  Positioned(
                    // bottom: -40,
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage("assets/images/user.png"),
                      ),
                    ),
                  )
                ],
              ),
          
              const SizedBox(height: 50),
          
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
          
                    // buildTextField("Name",required:true),
                    TextFormField(
                      controller: namecontroller,
                      inputFormatters: [_lettersOnly, _noLeadingSpace, _noDoubleSpace],
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
                    //  TextFormField(
                    //   controller: mobilenocontroller,
                    //   readOnly: true,
                    //   decoration: InputDecoration(
                    //     labelText: 'Mobile Number *',
                    //     fillColor: Colors.grey.shade100,
                    //     border: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(10),
                    //     ),
                    //   ),
                    // ),
                     TextFormField(
                      controller: mobilenocontroller,
                      readOnly: true,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'Mobile Number',
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
                        ),
                        suffixIcon: Icon(Icons.lock_outline, color: Colors.grey, size: 18),
                      ),
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    SizedBox(height: screenHeight*0.02,),
                     TextFormField(
                      controller: emailcontroller,
                      maxLength: 100,
                      inputFormatters: [_emailChars, _noLeadingSpace],
                      decoration: InputDecoration(
                        labelText: 'Email *',
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
                     
                      Container(
                      child: TextField(
                        controller: dobcontroller,
                        decoration: InputDecoration(
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
                            fillColor: Colors.grey.shade100,
                            prefixIcon: Icon(
                              Icons.calendar_month,
                              color: custom_color.app_color,
                            ),
                            
                            labelText: "D.O.B"),
                            
                        readOnly: true,
                        onTap: (() {
                          _selectDate();
                        }),
                      ),
                    ),
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
                      genderButton("Male", "male"),
                      const SizedBox(width:10),
                      genderButton("Female", "female"),
                    ],
                  ),
          
                    // const SizedBox(height:16),
                    //   TextFormField(
                    //     controller: gstcontroller,
                    //   decoration: InputDecoration(
                    //     labelText: 'GST No',
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
                    SizedBox(height: screenHeight*0.02,),
                     TextFormField(
                      controller: address1controller,
                      maxLength: 100,
                      inputFormatters: [_addressChars, _noLeadingSpace],
                      decoration: InputDecoration(
                        labelText: 'Address Line 1 *',
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
                      controller: address2controller,
                      maxLength: 100,
                      inputFormatters: [_addressChars, _noLeadingSpace],
                      decoration: InputDecoration(
                        labelText: 'Address Line 2 *',
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
                      controller: areacontroller,
                      maxLength: 100,
                      inputFormatters: [_addressChars, _noLeadingSpace],
                      decoration: InputDecoration(
                        labelText: 'Area *',
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
                      controller: landmarkcontroller,
                      maxLength: 100,
                      inputFormatters: [_addressChars, _noLeadingSpace],
                      decoration: InputDecoration(
                        labelText: 'Landmark',
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
                      controller: citycontroller,
                      maxLength: 50,
                      inputFormatters: [_lettersOnly, _noLeadingSpace, _noDoubleSpace],
                      decoration: InputDecoration(
                        labelText: 'City *',
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
                    // Container(
                    //       child: Container(
                    //         //  decoration: ShapeDecoration(
                    //         //   shape: RoundedRectangleBorder(
                    //         //     side: BorderSide(color: custom_color.app_color, width: 1.0),
                    //         //     borderRadius: BorderRadius.circular(5),
                    //         //   ),
                    //         //  ),
                    //          child: DropdownSearch<Map<String, dynamic>>(
                    //             items: StateList.cast<Map<String, dynamic>>(),
                    //             itemAsString: (item) => item['state'].toString(),
          
                    //             popupProps: PopupProps.menu(
                    //               showSearchBox: true,
                    //               searchFieldProps: TextFieldProps(
                    //                 decoration: InputDecoration(
                    //                   hintText: "Search State",
                    //                   border: OutlineInputBorder(),
                    //                 ),
                    //               ),
                    //             ),
          
                    //             dropdownDecoratorProps: DropDownDecoratorProps(
                    //               dropdownSearchDecoration: InputDecoration(
                                    
                    //                 labelText: "State *",
                    //                 fillColor: Colors.grey.shade100,
                    //                 border: OutlineInputBorder(
                    //                   borderRadius: BorderRadius.circular(10),
                    //                 ),
                    //                 enabledBorder: OutlineInputBorder(
                    //                   borderSide: BorderSide(color: custom_color.app_color),
                    //                   borderRadius: BorderRadius.circular(10),
                    //                 ),
                    //                 focusedBorder: OutlineInputBorder(
                    //                   borderSide: BorderSide(color: custom_color.app_color, width: 2),
                    //                   borderRadius: BorderRadius.circular(10),
                    //                 ),
                    //               ),
                    //             ),
          
                    //             onChanged: (value) {
                    //               if (value != null) {
                    //                 statecontroller.text = value['state'].toString();
                    //               }
                    //             },
          
                    //             selectedItem: StateList.isNotEmpty
                    //                 ? StateList.firstWhere(
                    //                     (item) => item['state'] == statecontroller.text,
                    //                     orElse: () => StateList.first,
                    //                   )
                    //                 : null,
                    //           ),
                            
                    //       ),
                    //     ),
                     Container(
                       child: DropdownSearch<Map<String, dynamic>>(
                       
                         items: StateList.cast<Map<String, dynamic>>(),
                       
                         // selectedItem: selectedStateItem,
                           selectedItem: statecontroller.text.isNotEmpty
                             ? StateList.firstWhere(
                                 (item) =>
                                     item['state'].toString().toLowerCase() ==
                                     statecontroller.text.toLowerCase(),
                                 orElse: () => {},
                               )
                             : null,
                       
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
                       
                           setState(() {
                       
                             selectedStateItem = value;
                       
                             statecontroller.text =
                                 value?['state']?.toString() ?? "";
                       
                           });
                       
                         },
                       ),
                     ),
                    SizedBox(height: screenHeight*0.02,),
                    
                     TextFormField(
                      controller: pincodecontroller,
                      maxLength: 6,
                      keyboardType: TextInputType.number,
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
                        if(address1controller.text.trim().isEmpty){
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
          
                        if(pincodecontroller.text.trim().length != 6){
                          Fluttertoast.showToast(msg: 'Enter valid Pincode');
                          return;
                        }
          
                        // ✅ GST VALIDATION
                        RegExp gstRegex = RegExp(
                          r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$'
                        );
          
                        if(gstcontroller.text.isNotEmpty &&
                          !gstRegex.hasMatch(gstcontroller.text.toUpperCase())){
                          Fluttertoast.showToast(msg: "Enter Valid GST Number");
                          return;
                        }
          
                        // ✅ API CALL
                        setState(() => isLoading = true);
          
                        var data = {
                          "action":"save_profile",
                          "name": name,
                          "mobile": mobilenocontroller.text.trim(),
                          "email": email,
                          "dob": dobcontroller.text.trim(),
                          "gender": gendercontroller.text.trim(),
                          "customer_id": customer_id,
                          "accesskey":"90336",
                          "city": citycontroller.text.trim(),
                          "state": statecontroller.text.trim(),
                          "address": address1controller.text.trim(),
                          "address2": address2controller.text.trim(),
                          "pin": pincodecontroller.text.trim(),
                          "landmark": landmarkcontroller.text.trim(),
                          "area": areacontroller.text.trim(),
                          "act_type": userResponse['act_type'],
                          "gstno": gstcontroller.text.trim(),
                          "token": accesstoken,
                          "fcm_id": fcmToken,
                        };
          
                        final response = await Profilepageapi().ProfileUpdate(data);
                        setState(() => isLoading = false);
          
                        if (response == null) return;
          
                        if(response['code'] == 200){
                           
                          Fluttertoast.showToast(msg: 'Profile updated successfully');
                         
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => Homepage()),
                            (route) => false,
                          );
          
                        } else {
                          Fluttertoast.showToast(msg: response?['message'] ?? 'Update failed');
                        }
                      },
                        child: const Text(
                          "Update",
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
        )
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
            // Header banner + avatar
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: sh * 0.15,
                  width: double.infinity,
                  color: Colors.white,
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    width: sw * 0.22,
                    height: sw * 0.22,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: sw * 0.14),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
              child: Column(
                children: [
                  // Form field skeletons
                  ...List.generate(10, (_) => Padding(
                    padding: EdgeInsets.only(bottom: sh * 0.02),
                    child: Container(
                      width: double.infinity,
                      height: sh * 0.065,
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
                        Expanded(
                          child: Container(
                            height: sh * 0.065,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        SizedBox(width: sw * 0.03),
                        Expanded(
                          child: Container(
                            height: sh * 0.065,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Update button
                  Container(
                    width: double.infinity,
                    height: sh * 0.065,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  SizedBox(height: sh * 0.05),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget genderButton(String label, String value) {
  final selected = gendercontroller.text.toLowerCase() == value;
  return Expanded(
    child: GestureDetector(
      onTap: (){
        setState(() {
          gendercontroller.text = value;
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
            label,
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
   Future<void> _selectDate() async {
     DateTime initial = DateTime.now();
    if (dobcontroller.text.isNotEmpty) {
      final parsed = DateTime.tryParse(dobcontroller.text);
      if (parsed != null) initial = parsed;
    }
    DateTime? _picked = await showDatePicker(
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      context: context,
      // initialDate: DateTime.now(),
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (_picked != null) {
      setState(() {
        dobcontroller.text = _picked.toString().split(" ")[0];
      });
    }
  }
}