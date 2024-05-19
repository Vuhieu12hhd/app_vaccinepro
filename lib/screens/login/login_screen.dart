import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:injection_schedule/main.dart';
import 'package:injection_schedule/network/dio_exception.dart';
import 'package:injection_schedule/network/dio_restfu.dart';
import 'package:injection_schedule/screens/booking_screen/models/user.dart';
import 'package:injection_schedule/screens/sign_in/sign_in_screen.dart';
import 'package:injection_schedule/utils/tab_bar.dart';

import '../../secure_storage.dart';

class LoginPage extends StatefulWidget {
  static String routerName = 'LoginPage';

  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _loadFirst = false;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  void hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  double getWidthDevice(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  double getHeightDevice(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  bool checkLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  bool _seePass = false;

  @override
  void initState() {
    super.initState();
    hideKeyboard();
  }

  void validateAndSave() {
    final FormState form = _formKey.currentState!;
    if (form.validate()) {
      print('Form is valid');
    } else {
      print('Form is invalid');
    }
  }

  Future<int?> onPressLogin() async {
    String error = DioExceptions.DEFAULT;
    Response? response;
    try {
      response = await DioRestFull.instance.dio.post(DioRestFull().login,
          data: {
            'email': _usernameController.text,
            'password': _passwordController.text
          }).catchError((onError) {
        error = DioExceptions.messageError(onError);
        print(error);
      });
    } catch (error) {}
    if (response != null) {
      final user = User.fromMap(response.data['result']['user']);
      await Future.wait([
        MyApp.of(context)
            .localStorage
            .storeToken(response.data['result']['accessToken']),
        MyApp.of(context).localStorage.storeId(user.id ?? -1)
      ]);
      MyApp.of(context).myAccount = user;
      return user.id;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leadingWidth:
              35, // Điều chỉnh chiều rộng của phần leading để giảm khoảng cách
          titleSpacing: 5, // Điều chỉnh khoảng cách giữa biểu tượng và tiêu đề
          title: const Text(
            'VaccinePro', // Tiêu đề
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: false, // Đảm bảo tiêu đề không bị căn giữa
          backgroundColor: Color.fromARGB(255, 136, 238, 226), // Màu nền
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: ClipOval(
                child: Image.asset(
                  'lib/res/images/logo.png', // Đường dẫn đến tệp ảnh logo
                  height: 40, // Chiều cao của logo
                  width: 40, // Chiều rộng của logo
                  fit: BoxFit
                      .cover, // Đảm bảo logo không bị cắt xén và bao phủ toàn bộ vùng
                ),
              ),
            ),
          ],
        ),
        body: GestureDetector(
          onTap: () {
            hideKeyboard();
          },
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  Container(
                    width: getWidthDevice(context),
                    margin: const EdgeInsets.only(top: 220, left: 8, right: 8),
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 104, 104, 104)
                                .withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          )
                        ]),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 16,
                        ),
                        const Text('Login',
                            style: TextStyle(
                                fontSize: 28,
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(
                          height: 16,
                        ),
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            label: Text('Email*'),
                            icon: Icon(Icons.person),
                          ),
                          validator: (value) {
                            return value!.isEmpty
                                ? 'Bạn chưa nhập tài khoản'
                                : null;
                          },
                          onChanged: (content) {},
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                              label: const Text('password*'),
                              icon: const Icon(Icons.key),
                              suffixIcon: IconButton(
                                icon: Icon(_seePass
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () =>
                                    setState(() => _seePass = !_seePass),
                              )),
                          onChanged: (value) {},
                          validator: (value) {
                            return value!.isEmpty
                                ? '\u26A0 Bạn chưa nhập mật khẩu'
                                : null;
                          },
                          obscureText: !_seePass,
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r' ')),
                            LengthLimitingTextInputFormatter(16),
                          ],
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        SizedBox(
                          width: getWidthDevice(context) - 16,
                          child: ElevatedButton(
                            onPressed: () async {
                              validateAndSave();
                              if (_usernameController.text.isNotEmpty &&
                                  _passwordController.text.isNotEmpty) {
                                _ShowDialog();
                                onPressLogin().then((value) {
                                  Navigator.of(context).pop();
                                  if (value != null) {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const TabBarMain()));
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text(
                                          "Tài khoản hoặc mật khẩu không đúng !"),
                                    ));
                                  }
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Color.fromARGB(255, 52, 208, 190),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                            ),
                            child: const Text('Đăng nhập',
                                style: TextStyle(
                                    fontSize: 19,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text("Bạn chưa có tài khoản ?"),
                            TextButton(
                                onPressed: () => {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const SignInPage()))
                                    },
                                child: Text(
                                  "Đăng ký",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ))
                          ],
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _ShowDialog() {
    AlertDialog alert = AlertDialog(
      content: Row(children: [
        // const CircularProgressIndicator(
        //   backgroundColor: Colors.red,
        // ),
        Container(
            margin: const EdgeInsets.only(left: 7),
            child: const Text("Loading...")),
      ]),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
