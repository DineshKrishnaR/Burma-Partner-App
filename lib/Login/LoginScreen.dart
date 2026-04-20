
import 'dart:async';
import 'dart:math';
import 'package:burmapartner/Api/Api.dart';
import 'package:burmapartner/Common/DeviceInfo.dart';
import 'package:burmapartner/Common/FirebaseApi.dart';
import 'package:burmapartner/Common/Utils.dart';
import 'package:burmapartner/Dashboard/Dashboard.dart';
import 'package:burmapartner/Dashboard/HomePage.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:localstorage/localstorage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Common/colors.dart' as custom_color;

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {

  TextEditingController mobile = TextEditingController();
  final LocalStorage storage = new LocalStorage('app_store');
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController gstnoController = TextEditingController();
  TextEditingController address1Controller = TextEditingController();
  TextEditingController address2Controller = TextEditingController();
  TextEditingController areaController = TextEditingController();
  TextEditingController landmarkController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();
  TextEditingController referralController = TextEditingController();
  TextEditingController statecontroller = TextEditingController();
  TextEditingController retailerController = TextEditingController();

  String gender = "";

  List<TextEditingController> otpControllers =
    List.generate(5, (index) => TextEditingController());

List<FocusNode> focusNodes =
  List.generate(5, (index) => FocusNode());
  late SharedPreferences pref;
  int step = 1; // 1 mobile, 2 send otp, 3 verify otp
  bool isCustomer = true;
  var device_id;
  bool isLoading = false;
  var Otp;
  var user_logtype;
  var fcmToken;
  var deviceName;
  var deviceModel;
  var osVersion;
  Timer? _timer;
  bool _canResend = false;
  ValueNotifier<int> secondsNotifier = ValueNotifier<int>(30);
  
  bool _isButtonLocked = false;
  List StateList = [];
@override
  void initState() {
    super.initState();
    initPreferencess();

    // listenForCode();
    
  }
  @override
void dispose() {
  nameController.dispose();
  referralController.dispose();
  _timer?.cancel();
  for (var c in otpControllers) {
    c.dispose();
  }

  for (var f in focusNodes) {
    f.dispose();
  }
  secondsNotifier.dispose();

  mobile.dispose();
  super.dispose();
}

 initPreferencess() async {
    await storage.ready;
    pref = await SharedPreferences.getInstance();
    var device_info = await Device().initPlatformState();
    device_id = await storage.getItem('device_id');
     deviceName = storage.getItem('device_name') ?? "";
     deviceModel = storage.getItem('device_model') ?? "";
     osVersion = storage.getItem('os_version') ?? "";
      await FirebaseApi().initNotifications();  
      fcmToken = await storage.getItem('fcmToken');
      retailerController.text = "Retailer";
      print('FCM Token: $fcmToken');
      print('Device ID: $device_id');
      await gerStateList();
      setState(() {});
  }

 Future<void> gerStateList() async {
    setState(() => isLoading = true);
   var data = {
         "action": "get_state",
         "accesskey":"90336",
   };
    final response = await Api().getStateList(data);

    print(response);

    if(response != null){
      StateList = response['res'] ?? [];
      

    setState(() => isLoading = false);
  }
 }
//   void startResendTimer() {
//   _secondsRemaining = 30;
//   _canResend = false;

//   _timer?.cancel();

//   _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//      if (!mounted) return;
//     if (_secondsRemaining > 0) {
//       setState(() {
//         _secondsRemaining--;
//       });
//     } else {
//       timer.cancel();
//       setState(() {
//         _canResend = true;
//       });
//     }
//   });
// }
void startResendTimer() {
  secondsNotifier.value = 30;
  _canResend = false;

  _timer?.cancel();

  _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    if (!mounted) return;

    if (secondsNotifier.value > 0) {
      secondsNotifier.value--;
    } else {
      timer.cancel();

      setState(() {
        _canResend = true;
      });
    }
  });
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: custom_color.app_color,
     
      body: Container(
        decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1F3C88), // Blue
            Color(0xFF2E3AA7), // Mid Blue
            Color(0xFF5B2C83), // Purple
          ],
        ),
      ),
        child: SafeArea(
          
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Image.asset("assets/images/AppLogo.png", height: 120),
                   Align(
          alignment: Alignment.topCenter,
          child: Image.asset(
            "assets/images/AppLogo.png",
            height: 120,
          ),
        ),
                  const SizedBox(height: 30),
        
                  if(step==1) sendOtpStep(),
                  if(step==2) mobileStep(),
                  if(step==3) otpStep(),
                  if(step==4) registerStep(), 
        
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ================= STEP 1 =================
  Widget mobileStep(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        children: [

          const Text("Enter your mobile number",
              style: TextStyle(color: Colors.white,fontSize: 18)),

          const SizedBox(height: 25),

          // Container(
          //     height: 60,
          //     //  alignment: Alignment.center, 
          //     decoration: BoxDecoration(
          //       color: Colors.grey.shade200,
          //       borderRadius: BorderRadius.circular(40),
          //     ),
          //     child: TextField(
          //       controller: mobile,
          //       keyboardType: TextInputType.number,
          //       maxLength: 10,
          //       textAlignVertical: TextAlignVertical.center,
          //       inputFormatters: [
          //         FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
          //         LengthLimitingTextInputFormatter(10),
          //       ],
          //       decoration: const InputDecoration(
          //         counterText: "",
          //         hintText: 'Enter Your Mobile No...',
          //         border: InputBorder.none,
          //         contentPadding: EdgeInsets.symmetric(horizontal: 25),
          //       ),
          //     ),
          //   ),
         Container(
            height: 55,
            alignment: Alignment.center, 
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(40),
            ),
            child: TextField(
              controller: mobile,
              maxLength: 10,
              keyboardType: TextInputType.number,
               inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  LengthLimitingTextInputFormatter(10),
                ],
              // readOnly: true,
              decoration: const InputDecoration(
                counterText: "",
                hintText: 'Enter Your Mobile No...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 25),
              ),
            ),
          ),
          const SizedBox(height: 25),

         Container(
            // width: double.infinity,
            width: MediaQuery.of(context).size.width * 0.55,

            // height: 65,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              gradient: const LinearGradient(
                colors:[Color(0xFF1FA45B),Color(0xFF148A49)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0,12),
                )
              ],
            ),
            child: ElevatedButton(
              // onPressed:isLoading ? null : () async {
onPressed: (_isButtonLocked || isLoading)
    ? null
    : () async {
        setState(() {
          _isButtonLocked = true;
          isLoading = true;
        });

        try {
          if (mobile.text.isEmpty) {
            Fluttertoast.showToast(msg: 'Enter your mobile number');
            return;
          }

          if (mobile.text.length != 10) {
            Fluttertoast.showToast(msg: 'Enter valid 10 digit mobile number');
            return;
          }

          var data = {
            "action": "register",
            "mobile": mobile.text.toString(),
            "device_id": device_id,
            "apphashkey": "",
          };

          final response = await Api().Register(data);

          if (response == null) {
            Fluttertoast.showToast(msg: "Server error");
            return;
          }

          if (response['status'] == "success") {
            Fluttertoast.showToast(msg: "OTP sent for registration");
            user_logtype = 'register';
            startResendTimer(); 
            await RegisterSentOTP();

            setState(() => step = 3);

            Future.delayed(const Duration(milliseconds: 200), () {
              focusNodes[0].requestFocus();
            });
          } else {
            Fluttertoast.showToast(msg: response['message']);
          }

        } catch (e) {
          Fluttertoast.showToast(msg: "Something went wrong");
        } finally {
          setState(() {
            _isButtonLocked = false;
            isLoading = false;
          });
        }
      },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: isLoading
      ?  CircularProgressIndicator(color: Colors.white)
      :Text('Submit',
                  style: const TextStyle(fontSize:22,fontWeight: FontWeight.bold,color: Colors.white)),
            ),
          ),
          const SizedBox(height: 25),

          // const Text("Already have an Account ? Login",
          //     style: TextStyle(color: Colors.white,decoration: TextDecoration.underline)),
        Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    const Text(
      "Already have an Account ? ",
      style: TextStyle(
        color: Colors.white,
        // decoration: TextDecoration.underline,
      ),
    ),

    GestureDetector(
      onTap: () {
        mobile.clear();
        setState(() {
          step=1;
        });
       
      },
      child: const Text(
        "Login",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18
          // decoration: TextDecoration.underline,
        ),
      ),
    ),
  ],
)
        ],
      ),
    );
  }
void showInactiveDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Account Inactive"),
      content: Text(message.isNotEmpty
          ? message
          : "Your account is inactive. Please contact admin."),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("OK"),
        )
      ],
    ),
  );
}
Future<void> Login() async {
if (isLoading) return;
  if (mobile.text.isEmpty) {
    Fluttertoast.showToast(msg: "Enter mobile number");
    return;
  }

  if (!RegExp(r'^[0-9]+$').hasMatch(mobile.text)) {
    Fluttertoast.showToast(msg: "Only numbers allowed");
    return;
  }

  if (mobile.text.length != 10) {
    Fluttertoast.showToast(msg: "Enter valid 10-digit mobile number");
    return;
  }

  setState(() {
    isLoading = true;
  });

  var data = {
    "action": "login",
     "action_type": "login_send_otp",
    "mobile": mobile.text.toString(),
    "type": "DIST",
    "device_id":device_id,
    "apphashkey":"",
   
  };

  // final response = await Api().loginApi(data);
  // print(response);
final response = await Api()
        .loginApi(data)
        .timeout(const Duration(seconds: 15)); // ✅ timeout

    /// ✅ SERVER NULL
    if (response == null) {
      Fluttertoast.showToast(msg: "Server not responding");
      return;
    }
  setState(() {
    isLoading = false;
  });

  /// 🔥 HANDLE USING user_logtype

  if (response['status'] == "success") {

    Fluttertoast.showToast(msg: "OTP sent successfully");
    user_logtype = "login";
    // LoginsendOTP();
     startResendTimer(); 
    setState(() {
      step = 3; // open OTP
    });
     Future.delayed(const Duration(milliseconds: 200), () {
  focusNodes[0].requestFocus();
});
  } 
  else if (response['message'] == "Mobile number already registered as a Customer! Please select the correct login type.") {

    Fluttertoast.showToast(
        msg: response['message'] ??
            "Mobile number already registered as a Customer! Please select the correct login type");
      
  } else if (response['message'] == "Mobile No. not registered!") {

    Fluttertoast.showToast(
        msg: response['message'] ??
            "Mobile No. not registered!");
      
  } 
  else {
    Fluttertoast.showToast(
        msg: response['message'] ?? "Something went wrong");
       
  }
  
}
  
  /// ================= STEP 2 =================
  Widget sendOtpStep(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        children: [
 const Text("Enter your mobile number",
              style: TextStyle(color: Colors.white,fontSize: 18)),
              const SizedBox(height: 25),
          Container(
            height: 55,
            alignment: Alignment.center, 
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(40),
            ),
            child: TextField(
              controller: mobile,
              keyboardType: TextInputType.number,
               inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  LengthLimitingTextInputFormatter(10),
                ],
              // readOnly: true,
              decoration: const InputDecoration(
                hintText: 'Enter Your Mobile No...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 25),
              ),
            ),
          ),

          const SizedBox(height: 25),

          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [

          //     Checkbox(
          //       value: isCustomer,
          //       onChanged: (v){
          //         setState(()=>isCustomer=true);
          //       },
          //       activeColor: Colors.white,
          //       checkColor: custom_color.app_color,
          //     ),
          //      Text("Customer",style: TextStyle(color: Colors.white)),

          //     const SizedBox(width: 30),

          //     Checkbox(
          //       value: !isCustomer,
          //       onChanged: (v){
          //         setState(()=>isCustomer=false);
          //       },
          //       activeColor: Colors.white,
          //       checkColor: custom_color.app_color,
          //     ),
          //     const Text("Reseller",style: TextStyle(color: Colors.white)),
          //   ],
          // ),
          // const SizedBox(height: 35),

   Container(
      // width: double.infinity,
      width: MediaQuery.of(context).size.width * 0.55,

      // height: 65,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        gradient: const LinearGradient(
          colors:[Color(0xFF1FA45B),Color(0xFF148A49)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0,12),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null :(){
            //  setState(() {
            //   step = 3;
            // });
            Login();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: isLoading
    ? const CircularProgressIndicator(
        color: Colors.white,
        strokeWidth: 3,
      )
    :Text('Send OTP',
            style: const TextStyle(fontSize:22,fontWeight: FontWeight.bold,color: Colors.white)),
      ),
    ),
          const SizedBox(height: 25),

         Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Don't have an Account? ",
                  style: TextStyle(
                    color: Colors.white,
                    // decoration: TextDecoration.underline,
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    mobile.clear();
                    setState(() {
                      step=2;
                      
                    });
                  },
                  child: const Text(
                    "Create Account Here",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18
                      // decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            )
        ],
      ),
    );
  }

  /// ================= STEP 3 =================
  Widget otpStep(){
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//   if (focusNodes.isNotEmpty) {
//     focusNodes[0].requestFocus();
//   }
// });
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        children: [

          const Text("Verify OTP",
              style: TextStyle(color: Colors.white,fontSize: 28,fontWeight: FontWeight.bold)),

          const SizedBox(height: 25),

          Text("Please Enter OTP sent via\nSMS on +91 ${mobile.text}",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white,fontSize: 16)),

          const SizedBox(height: 30),

OtpFields(
  controllers: otpControllers,
  focusNodes: focusNodes,
),

          const SizedBox(height: 20),

         Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    const Text(
      "Don't receive OTP? ",
      style: TextStyle(color: Colors.white70),
    ),
    
    AnimatedSwitcher(
  duration: const Duration(milliseconds: 300),
  child: _canResend
      ? TextButton(
          key: const ValueKey("resend"),
          onPressed: isLoading
              ? null
              : () {
                  if (user_logtype == "register") {
                    RegisterSentOTP();
                  } else if (user_logtype == "login") {
                   Login();
                  }
                },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
          ),
          child: const Text(
            "Resend OTP",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              // decoration: TextDecoration.underline,
              fontSize: 16,
            ),
          ),
        )
      // : Text(
      //     "Resend in $_secondsRemaining sec",
      //     key: const ValueKey("timer"),
      //     style: const TextStyle(color: Colors.white70),
      //   ),
      :ValueListenableBuilder<int>(
         key: const ValueKey("timer"),
  valueListenable: secondsNotifier,
  builder: (context, seconds, child) {
    return Text(
      "Resend in $seconds sec",
      style: const TextStyle(color: Colors.white70),
    );
  },
)
)
  ],
),

          const SizedBox(height: 35),

          Container(
      // width: double.infinity,
      width: MediaQuery.of(context).size.width * 0.55,

      // height: 65,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        gradient: const LinearGradient(
          colors:[Color(0xFF1FA45B),Color(0xFF148A49)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0,12),
          )
        ],
      ),
      child: ElevatedButton(
        // onPressed: isLoading ? null :(){
        onPressed: (_isButtonLocked || isLoading)
    ? null
    : () async {
        _isButtonLocked = true;

          if (isLoading) return;
           String otp = otpControllers.map((e) => e.text).join();

          if (otp.length < 5) {
            Fluttertoast.showToast(msg: "Enter complete OTP");
            _isButtonLocked = false;
            return;
          }
          else{
          if(user_logtype=="login"){
             verifylogin(otp);
        
          }else{
             Reregisterverifylogin(otp);
          }
          }
           _isButtonLocked = false;
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: isLoading
      ? const CircularProgressIndicator(color: Colors.white)
      :Text('Submit',
            style: const TextStyle(fontSize:22,fontWeight: FontWeight.bold,color: Colors.white)),
      ),
    ),
        ],
      ),
    );
  }


Widget registerStep(){
  // TextEditingController name = TextEditingController();
  // TextEditingController referral = TextEditingController();

double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
  String userType = "";
String maskMobile(String number){
  if(number.length < 10) return number;
  return "${number.substring(0,3)}****${number.substring(7,10)}";
}
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 25),
    child: Column(
      children: [

TextFormField(
  controller: retailerController,
  textAlign: TextAlign.left,
  textAlignVertical: TextAlignVertical.center,
  inputFormatters: [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
  ],
  readOnly: true,
  decoration: InputDecoration(
    hintText: "Retailer",
    // labelText: 'Retailer',
    isDense: true,
    filled: true,
    fillColor: Colors.grey.shade200,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 14,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(40),
      borderSide: BorderSide.none,
    ),
  ),
),
SizedBox(height: screenHeight*0.02,),
         TextFormField(
  controller: nameController,
  textAlign: TextAlign.left,
  textAlignVertical: TextAlignVertical.center,
  inputFormatters: [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
  ],
  decoration: InputDecoration(
    hintText: "Name *",
    isDense: true,
    filled: true,
    fillColor: Colors.grey.shade200,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 14,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(40),
      borderSide: BorderSide.none,
    ),
  ),
),
       SizedBox(height: screenHeight*0.02,),
          TextFormField(
  controller: mobile,
  textAlign: TextAlign.left,
  textAlignVertical: TextAlignVertical.center,
  inputFormatters: [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
  ],
  readOnly: true,
  decoration: InputDecoration(
    hintText: "Mobile No",
    isDense: true,
    filled: true,
    fillColor: Colors.grey.shade200,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 14,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(40),
      borderSide: BorderSide.none,
    ),
  ),
),
SizedBox(height: screenHeight*0.02,),
  TextFormField(
  controller: emailController,
  textAlign: TextAlign.left,
  textAlignVertical: TextAlignVertical.center,
  inputFormatters: [
    FilteringTextInputFormatter.deny(RegExp(r'\s')), // ❌ no spaces
  ],

  decoration: InputDecoration(
    hintText: "Email *",
    isDense: true,
    filled: true,
    fillColor: Colors.grey.shade200,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 14,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(40),
      borderSide: BorderSide.none,
    ),
  ),
),



SizedBox(height: screenHeight*0.02,),
  TextFormField(
  controller: gstnoController,
  textAlign: TextAlign.left,
  textAlignVertical: TextAlignVertical.center,
  inputFormatters: [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
  ],
  decoration: InputDecoration(
    hintText: "GST No",
    isDense: true,
    filled: true,
    fillColor: Colors.grey.shade200,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 14,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(40),
      borderSide: BorderSide.none,
    ),
  ),
),
SizedBox(height: screenHeight*0.02,),
        /// GENDER
        const Align(
          alignment: Alignment.centerLeft,
          child: Text("Gender *",
              style: TextStyle(color: Colors.white,fontSize: 18)),
        ),

Row(
  children: [
    Checkbox(
      value: gender == "Male",
      onChanged: (value) {
         final currentText = nameController.text; 
        setState(() {
          if (gender == "Male") {
            gender = ""; // 🔥 deselect
          } else {
            gender = "Male"; // select
          }
        });
        nameController.text = currentText;
      },
      fillColor: MaterialStateProperty.all(Colors.white),
      // activeColor: Colors.green,
      checkColor: Colors.green,
    ),
    const Text("Male", style: TextStyle(color: Colors.white)),

    SizedBox(height: screenHeight*0.02,),

    Checkbox(
      value: gender == "Female",
      onChanged: (value) {
        setState(() {
          if (gender == "Female") {
            gender = ""; // 🔥 deselect
          } else {
            gender = "Female"; // select
          }
        });
      },
      fillColor: MaterialStateProperty.all(Colors.white),
      // activeColor: Colors.green,
      checkColor: Colors.green,
    ),
    const Text("Female", style: TextStyle(color: Colors.white)),
  ],
),

SizedBox(height: screenHeight*0.02,),
  TextFormField(
  controller: address1Controller,
  textAlign: TextAlign.left,
  textAlignVertical: TextAlignVertical.center,
  // inputFormatters: [
  //   FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
  // ],
  decoration: InputDecoration(
    hintText: "Address 1 *",
    isDense: true,
    filled: true,
    fillColor: Colors.grey.shade200,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 14,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(40),
      borderSide: BorderSide.none,
    ),
  ),
),
        // const SizedBox(height: 20),

SizedBox(height: screenHeight*0.02,),
  TextFormField(
  controller: address2Controller,
  textAlign: TextAlign.left,
  textAlignVertical: TextAlignVertical.center,
  // inputFormatters: [
  //   FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
  // ],
  decoration: InputDecoration(
    hintText: "Address2 *",
    isDense: true,
    filled: true,
    fillColor: Colors.grey.shade200,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 14,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(40),
      borderSide: BorderSide.none,
    ),
  ),
),

SizedBox(height: screenHeight*0.02,),
  TextFormField(
  controller: areaController,
  textAlign: TextAlign.left,
  textAlignVertical: TextAlignVertical.center,
  // inputFormatters: [
  //   FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
  // ],
  decoration: InputDecoration(
    hintText: "Area *",
    isDense: true,
    filled: true,
    fillColor: Colors.grey.shade200,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 14,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(40),
      borderSide: BorderSide.none,
    ),
  ),
),


SizedBox(height: screenHeight*0.02,),
  TextFormField(
  controller: landmarkController,
  textAlign: TextAlign.left,
  textAlignVertical: TextAlignVertical.center,
  inputFormatters: [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
  ],
  decoration: InputDecoration(
    hintText: "Landmark *",
    isDense: true,
    filled: true,
    fillColor: Colors.grey.shade200,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 14,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(40),
      borderSide: BorderSide.none,
    ),
  ),
),

SizedBox(height: screenHeight*0.02,),
  TextFormField(
  controller: cityController,
  textAlign: TextAlign.left,
  textAlignVertical: TextAlignVertical.center,
  // inputFormatters: [
  //   FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
  // ],
  decoration: InputDecoration(
    hintText: "City *",
    isDense: true,
    filled: true,
    fillColor: Colors.grey.shade200,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 14,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(40),
      borderSide: BorderSide.none,
    ),
  ),
),
SizedBox(height: screenHeight*0.02,),
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
                                  
                                  hintText: "State *",
                                  // fillColor: Colors.grey.shade100,
                                   isDense: true,
                                    filled: true,
                                    fillColor: Colors.grey.shade200,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 14,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(40),
                                      borderSide: BorderSide.none,
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
                          controller: pincodeController,
                          textAlign: TextAlign.left,
                          textAlignVertical: TextAlignVertical.center,
                          maxLength: 6,
                          keyboardType: TextInputType.number,
                          // inputFormatters: [
                          //   FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                          // ],
                          decoration: InputDecoration(
                            hintText: "Pincode *",
                            isDense: true,
                            filled: true,
                            counterText: "",
                            fillColor: Colors.grey.shade200,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                                SizedBox(height: screenHeight*0.02,),
                        TextFormField(
                          controller: referralController,
                          textAlign: TextAlign.left,
                          textAlignVertical: TextAlignVertical.center,
                          // inputFormatters: [
                          //   FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                          // ],
                          decoration: InputDecoration(
                            hintText: "Referral Code",
                            isDense: true,
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                            SizedBox(height: screenHeight*0.02,),

        /// SIGN UP BUTTON
        Container(
          // width: double.infinity,
          width: MediaQuery.of(context).size.width * 0.55,

          // height: 65,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            gradient: const LinearGradient(
              colors:[Color(0xFF1FA45B),Color(0xFF148A49)],
            ),
          ),
          child: ElevatedButton(
            onPressed: (_isButtonLocked || isLoading)
    ? null
    : () async {

        // ✅ VALIDATION FIRST (NO LOADING HERE)
        if (nameController.text.isEmpty) {
          Fluttertoast.showToast(msg: "Enter Name");
          return;
        }

        if (emailController.text.isEmpty) {
          Fluttertoast.showToast(msg: "Enter Email");
          return;
        }

        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
            .hasMatch(emailController.text)) {
          Fluttertoast.showToast(msg: "Enter valid email");
          return;
        }

        if (gender.isEmpty) {
          Fluttertoast.showToast(msg: "Select Gender");
          return;
        }

        if (address1Controller.text.isEmpty) {
          Fluttertoast.showToast(msg: "Enter Address 1");
          return;
        }

        if (address2Controller.text.isEmpty) {
          Fluttertoast.showToast(msg: "Enter Address 2");
          return;
        }

        if (areaController.text.isEmpty) {
          Fluttertoast.showToast(msg: "Enter Area");
          return;
        }

        if (landmarkController.text.isEmpty) {
          Fluttertoast.showToast(msg: "Enter Landmark");
          return;
        }

        if (cityController.text.isEmpty) {
          Fluttertoast.showToast(msg: "Enter City");
          return;
        }

        if (statecontroller.text.isEmpty) {
          Fluttertoast.showToast(msg: "Select State");
          return;
        }

        if (pincodeController.text.isEmpty) {
          Fluttertoast.showToast(msg: "Enter Pincode");
          return;
        }

        if (pincodeController.text.length < 6) {
          Fluttertoast.showToast(msg: "Enter valid Pincode");
          return;
        }

        // ✅ START LOADING AFTER VALIDATION
        setState(() {
          _isButtonLocked = true;
          isLoading = true;
        });

        try {
          var data = {
            "action": "register_submit",
            "action_type": "register_save",
            "mobile": mobile.text.toString(),
            "name": nameController.text.toString(),
            "email": emailController.text.toString(),
            "gender": gender,
            "address": address1Controller.text.toString(),
            "address2": address2Controller.text.toString(),
            "area": areaController.text.toString(),
            "landmark": landmarkController.text.toString(),
            "city": cityController.text.toString(),
            "state": statecontroller.text.toString(),
            "pin": pincodeController.text.toString(),
            "wtob": "DIST",
            "gstno": gstnoController.text.toString(),
            "reference_code": referralController.text.toString(),
            "device_name": deviceName,
            "device_model": deviceModel,
            "os_version": osVersion,
            "fcm_id": fcmToken,
          };

          final response = await Api().UserRegister(data);

          if (response == null) {
            Fluttertoast.showToast(msg: "Server error");
            return;
          }

          if (response['code'] == 200) {
            Fluttertoast.showToast(msg: response['message']);

            var user = {
              ...response['data']['user_data'],
              "api_token": response['data']['api_token'],
              "act_type": response['data']['user_type'],
            };

            await storage.setItem('userResponse', user);
            await pref.setBool('isLogin', true);

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => Homepage()),
              (route) => false,
            );
          } else {
            Fluttertoast.showToast(msg: response['message']);
          }

        } catch (e) {
          Fluttertoast.showToast(msg: "Something went wrong");
        } finally {
          setState(() {
            isLoading = false;
            _isButtonLocked = false;
          });
        }
      },
    //         onPressed: (_isButtonLocked || isLoading)
    // ? null:
    //  () async {

    //       setState(() {
    //       _isButtonLocked = true;
    //       isLoading = true;
    //     });

    //           if(nameController.text.isEmpty){
    //             Fluttertoast.showToast(msg: "Enter Name");
    //           }else if(emailController.text.isEmpty){
    //             Fluttertoast.showToast(msg: "Enter Email");
    //           }else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
    //               .hasMatch(emailController.text)) {
    //             Fluttertoast.showToast(msg: "Enter valid email");
    //             return;
    //           }
    //           else if(gender.isEmpty){
    //             Fluttertoast.showToast(msg: "Select Gender");
    //           }else if(address1Controller.text.isEmpty){
    //             Fluttertoast.showToast(msg: "Enter Address 1");
    //           }else if(address2Controller.text.isEmpty){
    //             Fluttertoast.showToast(msg: "Enter Address 2");
    //           }else if(areaController.text.isEmpty){
    //             Fluttertoast.showToast(msg: "Enter Area");
    //           }else if(landmarkController.text.isEmpty){
    //             Fluttertoast.showToast(msg: "Enter Landmark");
    //           }else if(cityController.text.isEmpty){
    //             Fluttertoast.showToast(msg: "Enter City");
    //           }else if(statecontroller.text.isEmpty){
    //             Fluttertoast.showToast(msg: "Enter State");
    //           }else if(pincodeController.text.isEmpty){
    //             Fluttertoast.showToast(msg: "Enter Pincode");
    //           }else if(pincodeController.text.toString().length < 6){
    //             Fluttertoast.showToast(msg: "Enter valid Pincode");
    //           }
    //           else{
    //             var data ={
    //                "action":"register_submit",
    //                "action_type":"register_save",
    //                "mobile": mobile.text.toString(),
    //                "name": nameController.text.toString(),
    //                "email":emailController.text.toString(),
    //                "gender": gender,
    //                "address":address1Controller.text.toString(),
    //                "address2":address2Controller.text.toString(),
    //                "area":areaController.text.toString(),
    //                "landmark":landmarkController.text.toString(),
    //                "city": cityController.text.toString(),
    //                "state":statecontroller.text.toString(),
    //                "pin":pincodeController.text.toString(),
    //                "wtob":"DIST",
    //                "gstno":gstnoController.text.toString(),
    //                "reference_code":referralController.text.toString(),
    //                "device_name":deviceName,
    //                 "device_model": deviceModel,
    //                "os_version": osVersion,
    //                "fcm_id": fcmToken,
                  
    //             };
    //             final response = await Api().UserRegister(data);
    //             if (response == null) { setState(() => isLoading = false); _isButtonLocked = false; return; }
    //             print(response);
    //             if (response['code'] == 200) {
    //             Fluttertoast.showToast(msg: response['message']);

    //             var userData = response['data']['user_data'];
    //             var token = response['data']['api_token'];
    //             var userType = response['data']['user_type'];

    //             /// ✅ CLEAN USER OBJECT
    //             var user = {
    //               ...userData,
    //               "api_token": token,
    //               "act_type": userType,
    //             };

    //             /// ✅ SAVE CLEAN DATA
    //             await storage.setItem('userResponse', user);
    //             await pref.setBool('isLogin', true);

    //             /// ✅ NAVIGATE (IMPORTANT)
    //             // Navigator.pushAndRemoveUntil(
    //             //   context,
    //             //   MaterialPageRoute(builder: (context) => Dashboard()),
    //             //   (route) => false,
    //             // );
    //              Navigator.pushAndRemoveUntil(
    //                 context,
    //                 MaterialPageRoute(builder: (context) => Dashboard()),
    //                 (route) => false,
    //               );
    //           }else{
    //             Fluttertoast.showToast(msg: response['message'].toString());
               
    //           }
    //            setState(() => isLoading = false);
    //            _isButtonLocked = false;
    //           }
    //         },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            child: isLoading
      ? const CircularProgressIndicator(color: Colors.white)
      : Text('SIGN UP',
                style: TextStyle(fontSize:22,fontWeight: FontWeight.bold,color: Colors.white)),
          ),
          
        ),
        SizedBox(height: screenHeight*0.04,),
      ],
    ),
  );
}

RegisterSentOTP()async{
    if (isLoading) return; 
  setState(() {
    isLoading = true;
  });
 var data = {
    "action": "register",
    "mobile": mobile.text.toString(),
    "device_id": device_id,
    "apphashkey":"",
  };

  final response = await Api().Register(data);
  print(response);
  if (response == null) { setState(() => isLoading = false); return; }
  print(response['otp']);
  if(response['code'] == 200){
    Fluttertoast.showToast(msg: "OTP sent successfully!");
    Otp = response['otp'].toString();
    startResendTimer(); 
    print(Otp);
    print(Otp);
    print(Otp);
  }
  
  setState(() {
    isLoading = false;
  });
}


verifylogin(otp) async {
  if (isLoading) return; 
  setState(() {
    isLoading = true;
  });

  var data = {
    "action": "login",
    "action_type" : "login_submit",
    "mobile": mobile.text.toString(),
    "otp": otp,
    "type": "DIST",
    "device_name": deviceName, // optional
    "device_model": deviceModel,
    "os_version": osVersion,
    "fcm_id": fcmToken ?? "",
  };

  final response = await Api().loginApi(data);
  print(response);

  setState(() {
    isLoading = false;
  });

  if (response == null) return;

  if (response['status'] == "success" && response['code'] == 200) {

  Fluttertoast.showToast(msg: response['message']);

  var userData = response['data']['user_data'];
  var token = response['data']['api_token'];

  /// ✅ CREATE CLEAN USER OBJECT
  var user = {
    ...userData,
    "api_token": token,
    "act_type": response['data']['user_type'], // if needed
  };
print(user);
  /// ✅ SAVE CLEAN DATA
  await storage.setItem('userResponse', user);
  await pref.setBool('isLogin', true);

  /// ✅ NAVIGATE
  // Navigator.pushAndRemoveUntil(
  //   context,
  //   MaterialPageRoute(builder: (context) => Dashboard()),
  //   (route) => false,
  // );
   Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => Homepage()),
    (route) => false,
  );
} else {
    Fluttertoast.showToast(
        msg: response['message'] ?? "Login failed");
  }
}

Reregisterverifylogin(otp) async {
  if (isLoading) return; 
  setState(() {
    isLoading = true;
  });

  var data = {
    "action": "register_submit",
    "action_type": "register_otp_verify",
    "mobile": mobile.text.toString(),
    "otp": otp,
  };

  final response = await Api().loginApi(data);
  print(response);

  setState(() {
    isLoading = false;
  });

  if (response == null) return;

  if (response['status'] == "success" && response['code'] == 200) {
     if(Helper().isvalidElement(response['user_reregister']) && response['user_reregister'] == 1){
       Navigator.push(context, MaterialPageRoute(builder: (context)=>Loginscreen()));
     }else{
        Fluttertoast.showToast(msg: response['message']);
           setState(() {
               step = 4;
             });
     }
  
  } else {
    Fluttertoast.showToast(
        msg: response['message'] ?? "Login failed");
  }
}
}


class OtpFields extends StatefulWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;

  const OtpFields({
    super.key,
    required this.controllers,
    required this.focusNodes,
  });

  @override
  State<OtpFields> createState() => _OtpFieldsState();
}

class _OtpFieldsState extends State<OtpFields> {
  final TextEditingController _hiddenController = TextEditingController();
  final FocusNode _hiddenFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // sync hidden controller changes to individual controllers
    _hiddenController.addListener(_onHiddenChanged);
    // forward external focusNode requests to hidden field
    for (final fn in widget.focusNodes) {
      fn.addListener(() {
        if (fn.hasFocus) {
          fn.unfocus();
          _hiddenFocus.requestFocus();
        }
      });
    }
  }

  void _onHiddenChanged() {
    final text = _hiddenController.text;
    for (int i = 0; i < widget.controllers.length; i++) {
      widget.controllers[i].text = i < text.length ? text[i] : '';
    }
    setState(() {});
  }

  @override
  void dispose() {
    _hiddenController.removeListener(_onHiddenChanged);
    _hiddenController.dispose();
    _hiddenFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = _hiddenController.text;
    return GestureDetector(
      onTap: () => _hiddenFocus.requestFocus(),
      child: Stack(
        children: [
          // hidden real input
          SizedBox(
            width: 0,
            height: 0,
            child: TextField(
              controller: _hiddenController,
              focusNode: _hiddenFocus,
              keyboardType: TextInputType.number,
              maxLength: widget.controllers.length,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(border: InputBorder.none, counterText: ''),
              autofocus: false,
            ),
          ),
          // visible boxes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(widget.controllers.length, (index) {
              final isFocused = _hiddenFocus.hasFocus && text.length == index;
              return Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isFocused ? Colors.green : Colors.grey.shade300,
                    width: isFocused ? 2 : 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  index < text.length ? text[index] : '',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}