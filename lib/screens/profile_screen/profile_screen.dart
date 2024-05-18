import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injection_schedule/screens/login/login_screen.dart';
import 'package:injection_schedule/secure_storage.dart';
import 'package:injection_schedule/utils/helpers.dart';

import '../../main.dart';
import 'bloc/profile_bloc.dart';

class ProfileScreen extends StatefulWidget {
  static const String routerName = 'ProfileScreen';

  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileState();
}

class _ProfileState extends State<ProfileScreen> {
  @override
  void initState() {
    BlocProvider.of<ProfileBloc>(context).add(ProfileStarted());
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        leadingWidth: 35,
        titleSpacing: 5,
        title: const Text(
          'VaccinePro',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        backgroundColor: Color.fromARGB(255, 136, 238, 226),
        actions: [
          IconButton(
            onPressed: () async {
              MyApp.of(context).clearAll();
              Navigator.of(context).popAndPushNamed(LoginPage.routerName);
            },
            icon: Icon(Icons.login),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          // Thêm container với tiêu đề "ĐĂNG KÝ TIÊM"
          Align(
            alignment: Alignment.topRight,
            child: Container(
              width: screenWidth / 2, // Một nửa màn hình
              height: 45,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 51, 240, 218),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                ),
              ),
              child: Center(
                child: Text(
                  'TRANG THÔNG TIN',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Thêm nội dung đã có
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 40, left: 3, right: 3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // Căn giữa hình ảnh
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              // Tạo viền cho hình ảnh
                              color: Colors.black, // Màu viền
                              width: 2, // Độ dày của viền
                            ),
                            borderRadius: BorderRadius.circular(10), // Bo góc
                          ),
                          child: Image.asset(
                            'lib/res/images/personicon.png',
                            width: 190,
                            height: 200,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20), // Khoảng cách giữa các mục

                    Text(
                      'THÔNG TIN KHÁCH HÀNG',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Họ tên: ${MyApp.of(context).myAccount?.name ?? ""}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Giới tính: Nam ', //${MyApp.of(context).myAccount?.gender ?? ""},
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Số điện thoại: ${MyApp.of(context).myAccount?.phoneNumber ?? ""}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Địa chỉ: ${MyApp.of(context).myAccount?.address ?? ""}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Email: ${MyApp.of(context).myAccount?.email ?? ""}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
