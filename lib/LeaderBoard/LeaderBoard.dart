import 'package:burmapartner/Api/Api.dart';
import 'package:burmapartner/Common/Utils.dart';
import 'package:burmapartner/Dashboard/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../Common/colors.dart' as custom_color;

class Leaderboard extends StatefulWidget {
  const Leaderboard({super.key});

  @override
  State<Leaderboard> createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  final LocalStorage storage = new LocalStorage('app_store');
 
  late SharedPreferences pref;
  
  ScrollController _scrollController = ScrollController();

  int limit = 10;
  int offset = 0;
  bool isMoreLoading = false;
  bool hasMoreData = true;
  var userResponse;
  var accesstoken;
  var customer_id;
  bool isLoading = false;
  List leaderboard_list = [];
  @override
  void initState() {
    super.initState();
    initPreferences();
    _scrollController.addListener(() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !isMoreLoading &&
        hasMoreData) {
      loadMoreData();
    }
  });
  }

  initPreferences() async {
    pref = await SharedPreferences.getInstance();
    await storage.ready;
    userResponse = await storage.getItem('userResponse');
    
    if (userResponse != null) {
      accesstoken = userResponse['api_token'];
      customer_id = userResponse['customer_id'].toString();

    }
    await getLeaderBoard();
  
    setState(() {});
  }

void loadMoreData() {
  offset += limit;
  getLeaderBoard(isLoadMore: true);
}

 Future<void> getLeaderBoard({bool isLoadMore = false}) async {
  if (isLoadMore) {
    setState(() => isMoreLoading = true);
  } else {
    setState(() => isLoading = true);
  }

  var data = {
    "action": "dist_leader_board",
    "accesskey": "90336",
    "token": accesstoken,
    "customer_id": customer_id,
    "act_type": userResponse['act_type'],
    "limit": limit.toString(),
    "offset": offset.toString()
  };

  final response = await Api().getLeaderBoard(data);

  if (response != null && response['res'] != null) {
    List newData = response['res'];

    if (newData.length < limit) {
      hasMoreData = false; // no more data
    }

    if (isLoadMore) {
      leaderboard_list.addAll(newData);
    } else {
      leaderboard_list = newData;
    }
  }

  setState(() {
    isLoading = false;
    isMoreLoading = false;
  });
}
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>Homepage()));
      },
      child: Scaffold(
            backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          backgroundColor: custom_color.app_color,
          elevation: 0,
          title: const Text("LeaderBoard", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            
            onPressed: () {
              
                Navigator.push(context, MaterialPageRoute(builder: (context)=>Homepage()));
              
            },
          ),
        ),
        body: SafeArea(
          child: isLoading
               ? _buildShimmer()
              : leaderboard_list.isEmpty
          ? const Center(child: Text("No Data Found"))
          : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: leaderboard_list.length + 1,
                itemBuilder: (context, index) {
                  if (index < leaderboard_list.length) {
                    var item = leaderboard_list[index];
                    return buildLeaderboardCard(item, index);
                  } else {
                    return isMoreLoading
                        ?  Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator(color: custom_color.app_color)),
                          )
                        : const SizedBox();
                  }
                },
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
      child: ListView.builder(
        padding: EdgeInsets.all(sw * 0.03),
        itemCount: 8,
        itemBuilder: (_, __) => Container(
          margin: EdgeInsets.symmetric(vertical: sh * 0.01),
          padding: EdgeInsets.all(sw * 0.04),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Trophy icon placeholder
              Container(
                width: sw * 0.08,
                height: sw * 0.08,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: sw * 0.04),
              // Rank column
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: sw * 0.1, height: sh * 0.014, color: Colors.white),
                  SizedBox(height: sh * 0.008),
                  Container(width: sw * 0.08, height: sh * 0.018, color: Colors.white),
                ],
              ),
              const Spacer(),
              // Name + district column
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(width: sw * 0.3, height: sh * 0.018, color: Colors.white),
                  SizedBox(height: sh * 0.008),
                  Container(width: sw * 0.22, height: sh * 0.014, color: Colors.white),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLeaderboardCard(dynamic item, int index) {
  int rank = item['rank'] ?? 0;

  IconData icon;
  Color iconColor;

  if (rank == 1) {
    icon = Icons.emoji_events;
    iconColor = Colors.orange;
  } else if (rank == 2) {
    icon = Icons.emoji_events;
    iconColor = Colors.grey;
  } else {
    icon = Icons.emoji_events;
    iconColor = Colors.brown;
  }

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 3),
        )
      ],
    ),
    child: Row(
      children: [
        // Crown Icon
        Icon(icon, color: iconColor, size: 32),

        const SizedBox(width: 16),

        // Rank
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Rank",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            Text(
              "${rank} ${getRankText(rank)}",
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),

        const Spacer(),

        // Name + District
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              item['name'] ?? "",
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              item['district'] ?? "",
              style: const TextStyle(
                  fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ],
    ),
  );
}
String getRankText(int rank) {
  if (rank == 1) return "st";
  if (rank == 2) return "nd";
  if (rank == 3) return "rd";
  return "th";
}
}