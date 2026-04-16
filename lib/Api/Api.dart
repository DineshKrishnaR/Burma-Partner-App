
import 'dart:convert';
import 'package:burmapartner/Common/UrlPath.dart';
import 'package:http/http.dart' as http;
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';


class Api {

  // ================= JWT CONFIG (FROM POSTMAN) =================

  static const String _jwtSecret =
      "HGgkggjhgvTye15253etV@%\$@kjh87jkgjkfk";

  static const String _issuer =
      "43A813328129D2F9C25E155BCB833";

  static const String _subject =
      "Muviereck Authentication";

  // ================= JWT GENERATOR =================

  String _generateJwtToken() {
    final jwt = JWT(
      {
        "iss": _issuer,
        "sub": _subject,
        "iat": DateTime.now().millisecondsSinceEpoch ~/ 1000,
      },
    );

    return jwt.sign(
      SecretKey(_jwtSecret),
      algorithm: JWTAlgorithm.HS256,
    );
  }

  // ================= HEADERS =================

  Map<String, String> _headers() {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer ${_generateJwtToken()}',
    };
  }

  // ================= LOGIN / REGISTER API =================

  Future<Map<String, dynamic>> loginApi(
      Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse(base_url + userLogin),
      headers: _headers(),
      body: body, // form-urlencoded
    );
print(response);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Login failed');
    }
  }

  Future<Map<String, dynamic>> Register(
      Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse(base_url + newregister),
      headers: _headers(),
      body: body, // form-urlencoded
    );
print(response);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Login failed');
    }
  }
   
  Future<Map<String, dynamic>> RegisterSentOTP(
      Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse(base_url + registersendotp),
      headers: _headers(),
      body: body, // form-urlencoded
    );
print(response);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Login failed');
    }
  }
   Future<Map<String, dynamic>> getStateList(
      Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse(base_url + getstatelist),
      headers: _headers(),
      body: body, // form-urlencoded
    );
print(response);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Login failed');
    }
  }

  Future<Map<String, dynamic>> UserRegister(
      Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse(base_url + userregister),
      headers: _headers(),
      body: body, // form-urlencoded
    );
print(response);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Login failed');
    }
  }

  Future<Map<String, dynamic>> LoginsendOTP(
      Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse(base_url + loginsendotp),
      headers: _headers(),
      body: body, // form-urlencoded
    );
print(response);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Login failed');
    }
  }




  Future<Map<String, dynamic>> getLeaderBoard(
      Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse(base_url + getleaderboard),
      headers: _headers(),
      body: body, // form-urlencoded
    );
print(response);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Login failed');
    }
  }


  Future<Map<String, dynamic>> getSalesReport(
      Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse(base_url + getsalesreport),
      headers: _headers(),
      body: body, // form-urlencoded
    );
print(response);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Login failed');
    }
  }


  Future<Map<String, dynamic>> getWalletTransactions(
      Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse(base_url + getwallettransactions),
      headers: _headers(),
      body: body, // form-urlencoded
    );
print(response);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Login failed');
    }
  }



  Future<Map<String, dynamic>> RequestWithdrawa(
      Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse(base_url + requestwithdrawa),
      headers: _headers(),
      body: body, // form-urlencoded
    );
print(response);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Login failed');
    }
  }
  // ================= GENERIC POST API =================

  Future<Map<String, dynamic>> postApi(
      String endpoint, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse(base_url + endpoint),
      headers: _headers(),
      body: body,
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'API Error');
    }
  }

  // ================= GENERIC GET API =================

  Future<Map<String, dynamic>> getApi(String endpoint) async {
    final response = await http.get(
      Uri.parse(base_url + endpoint),
      headers: _headers(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'API Error');
    }
  }
}
