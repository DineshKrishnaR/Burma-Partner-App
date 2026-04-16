import 'package:burmapartner/Api/Api.dart';
import 'package:burmapartner/Dashboard/DashboardApi.dart';
import 'package:burmapartner/Dashboard/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:localstorage/localstorage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Common/colors.dart' as custom_color;

class Requestwithdrawal extends StatefulWidget {
  const Requestwithdrawal({super.key});

  @override
  State<Requestwithdrawal> createState() => _RequestwithdrawalState();
}

class _RequestwithdrawalState extends State<Requestwithdrawal>
    with SingleTickerProviderStateMixin {
  final LocalStorage storage = LocalStorage('app_store');
  late SharedPreferences pref;
  final TextEditingController amountController = TextEditingController();
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  bool isLoading = false;
  bool isSubmitting = false;
  var userResponse;
  var accesstoken;
  var customer_id;
  var wallet_amount;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    initPreferencess();
  }

  @override
  void dispose() {
    _animController.dispose();
    amountController.dispose();
    super.dispose();
  }

  initPreferencess() async {
    await storage.ready;
    pref = await SharedPreferences.getInstance();
    userResponse = await storage.getItem('userResponse');
    if (userResponse != null) {
      accesstoken = userResponse['api_token'];
      customer_id = userResponse['customer_id'].toString();
    }
    await WalletDetails();
    _animController.forward();
    setState(() {});
  }

  Future<void> WalletDetails() async {
    setState(() => isLoading = true);
    var data = {
      "action": "wallet_dtl",
      "accesskey": "90336",
      "token": accesstoken,
      "customer_id": customer_id,
      "act_type": userResponse['act_type'],
    };
    final response = await DashboardApi().WalletDetails(data);
    if (response != null) {
      wallet_amount = response;
      await storage.setItem('wallet_amount', response);
    }
    setState(() => isLoading = false);
  }

  String get _balanceText {
    if (isLoading) return '---';
    if (wallet_amount != null && wallet_amount['amount'] != null) {
      return wallet_amount['amount'].toString();
    }
    return '0.00';
  }

  void _submit() async {
    if (amountController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter an amount');
      return;
    }
    setState(() => isSubmitting = true);
    var data = {
      "action": "wallet_wd_requests",
      "accesskey": "90336",
      "customer_id": customer_id,
      "act_type": userResponse['act_type'],
      "token": accesstoken,
      "withdraw_amount": amountController.text.trim(),
    };
    final response = await Api().RequestWithdrawa(data);
    setState(() => isSubmitting = false);
    if (response == null) return;
    if (response['status'] == "success") {
      amountController.clear();
      Fluttertoast.showToast(msg: response['message']);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Homepage()));
    } else {
      Fluttertoast.showToast(msg: response['message'] ?? "Something went wrong");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return PopScope(
      canPop: false,
      onPopInvoked: (_) => Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => Homepage())),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FB),
        body: Stack(
          children: [
            // Gradient header background
            Container(
              height: size.height * 0.38,
              decoration: BoxDecoration(
                color: custom_color.app_color,
                // gradient: LinearGradient(
                //   colors: [custom_color.app_color, custom_color.button_color],
                //   begin: Alignment.topLeft,
                //   end: Alignment.bottomRight,
                // ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  // AppBar row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white),
                          onPressed: () => Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (_) => Homepage())),
                        ),
                        const Expanded(
                          child: Text(
                            'Request Withdrawal',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),

                  // Balance card
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: custom_color.app_color.withOpacity(0.18),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  custom_color.app_color.withOpacity(0.15),
                                  custom_color.button_color.withOpacity(0.1)
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Image.asset('assets/images/AppLogo.png',
                                width: 40, height: 40),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Available Balance',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 4),
                              isLoading
                                  ? SizedBox(
                                      width: 80,
                                      height: 20,
                                      child: LinearProgressIndicator(
                                        borderRadius: BorderRadius.circular(4),
                                        color: custom_color.app_color,
                                        backgroundColor:
                                            custom_color.app_color.withOpacity(0.1),
                                      ))
                                  : Text(
                                      'Rs : $_balanceText',
                                      style: TextStyle(
                                          color: custom_color.button_color,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5),
                                    ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Form card
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: custom_color.app_color.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(Icons.account_balance_wallet_rounded,
                                        color: custom_color.app_color, size: 20),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text('Withdrawal Details',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1A1A2E))),
                                ],
                              ),
                              const SizedBox(height: 20),
                              const Text('Enter Amount',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF555577))),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: amountController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1A2E)),
                                decoration: InputDecoration(
                                  hintText: '0',
                                  hintStyle: TextStyle(
                                      color: Colors.grey.shade300,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 14),
                                    child: Text('Rs',
                                        style: TextStyle(
                                            color: custom_color.app_color,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14)),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF4F6FB),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide.none),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                        color: custom_color.app_color, width: 2),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 18),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Quick amount chips
                              Wrap(
                                spacing: 8,
                                children: ['200', '500', '1000', '1500']
                                    .map((amt) => ActionChip(
                                          label: Text(amt,
                                              style: TextStyle(
                                                  color: custom_color.app_color,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600)),
                                          backgroundColor:
                                              custom_color.app_color.withOpacity(0.08),
                                          side: BorderSide(
                                              color: custom_color.app_color
                                                  .withOpacity(0.3)),
                                          onPressed: () => amountController.text =
                                              amt.replaceAll(',', ''),
                                        ))
                                    .toList(),
                              ),
                              const SizedBox(height: 28),
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16)),
                                  ),
                                  onPressed: isSubmitting ? null : _submit,
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: isSubmitting
                                            ? [Colors.grey, Colors.grey]
                                            : [
                                                custom_color.app_color,
                                                custom_color.button_color
                                              ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Center(
                                      child: isSubmitting
                                          ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2.5))
                                          : const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.send_rounded,
                                                    color: Colors.white, size: 18),
                                                SizedBox(width: 8),
                                                Text('Submit Request',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        letterSpacing: 0.5)),
                                              ],
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Center(
                              //   child: Text(
                              //     'Withdrawals are processed within 1-3 business days',
                              //     style: TextStyle(
                              //         color: Colors.grey.shade400,
                              //         fontSize: 11),
                              //     textAlign: TextAlign.center,
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}