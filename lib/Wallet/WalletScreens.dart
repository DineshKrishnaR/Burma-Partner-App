import 'package:burmapartner/Api/Api.dart';
import 'package:burmapartner/Dashboard/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Common/colors.dart' as custom_color;

class Walletscreens extends StatefulWidget {
  const Walletscreens({super.key});

  @override
  State<Walletscreens> createState() => _WalletscreensState();
}

class _WalletscreensState extends State<Walletscreens> {
  final LocalStorage storage = new LocalStorage('app_store');
   late SharedPreferences pref;
  

  bool isLoading = false;
  var userResponse;
  var accesstoken;
  var customer_id;
  var wallet_transactions;
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
      await getWalletTransactions();
      setState(() {});
  }

  Future<void> getWalletTransactions() async {
    setState(() => isLoading = true);
   var data = {
         "action": "wallet_txn",
         "accesskey":"90336",
         "customer_id":customer_id,
         "act_type":userResponse['act_type'],
         "token":accesstoken,
   };
    final response = await Api().getWalletTransactions(data);

    print(response);

    if(response != null){
      wallet_transactions = response['res'] ?? [];
   

    setState(() => isLoading = false);
  }else{
    wallet_transactions = [];
  }
    setState(() => isLoading = false);
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
          title: Text("Walleat",style: TextStyle(color: Colors.white),),
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
              : wallet_transactions == null || wallet_transactions.isEmpty
          ? Center(child: Text("No Transactions"))
          : SingleChildScrollView(
              child: Column(
                children: [
          
                  /// 🔥 WALLET BALANCE CARD
                  Container(
                    margin: EdgeInsets.all(15),
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.1),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.account_balance_wallet,
                            color: custom_color.app_color, size: 30),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Wallet Balance :",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(height: 5),
                            Text(
                              "Rs.${getBalance()}",
                              style: TextStyle(
                                fontSize: 20,
                                color: custom_color.app_color,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
          
                  /// 🔥 TITLE
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Recent Transaction",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
          
                  SizedBox(height: 10),
          
                  /// 🔥 TRANSACTION LIST
                  ListView.builder(
                    itemCount: wallet_transactions.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      var txn = wallet_transactions[index];
          
                      bool isDebit = txn['type'] == "debit";
          
                      return Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.08),
                              blurRadius: 10,
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
          
                            /// 🔥 TOP ROW
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor:
                                      custom_color.app_color.withOpacity(.1),
                                  child: Icon(
                                    isDebit
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                                    color: custom_color.app_color,
                                  ),
                                ),
                                SizedBox(width: 10),
          
                                Expanded(
                                  child: Text(
                                    txn['message'] ?? "",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                ),
          
                                Text(
                                  "Rs.${txn['amount']}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: custom_color.app_color,
                                  ),
                                ),
                              ],
                            ),
          
                            SizedBox(height: 10),
          
                            /// 🔥 BOTTOM ROW
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Reference : ${txn['refer_id'] ?? ''}",
                                  style: TextStyle(fontSize: 13),
                                ),
                                Text(
                                  formatDate(txn['date_created']),
                                  style: TextStyle(fontSize: 13),
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
        ),
      ));
  }
  String getBalance() {
  double balance = 0;

  for (var txn in wallet_transactions) {
    if (txn['type'] == "credit") {
      balance += double.parse(txn['amount']);
    } else {
      balance -= double.parse(txn['amount']);
    }
  }

  return balance.toStringAsFixed(1);
}
String formatDate(String date) {
  DateTime dt = DateTime.parse(date);
  return "${dt.year}-${dt.month}-${dt.day} ${dt.hour}:${dt.minute}";
}
}