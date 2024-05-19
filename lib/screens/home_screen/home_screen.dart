import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injection_schedule/network/dio_exception.dart';
import 'package:injection_schedule/network/dio_restfu.dart';
import 'package:injection_schedule/screens/booking_screen/models/vaccine_booking.dart';
import 'package:injection_schedule/screens/home_screen/bloc/home_bloc.dart';
import 'package:injection_schedule/screens/home_screen/models/Booking_model.dart';
import 'package:injection_schedule/utils/helpers.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  static const String routerName = 'HomeScreen';

  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  bool isHo = false;
  bool isSot = false;

  final vaccines = <Vaccine>[];
  Vaccine? vaccine = null;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<HomeBloc>(context).add(HomeVacxin());
    onGetVaccines();
  }

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  Future<void> onGetVaccines() async {
    final response = await DioRestFull.instance.dio.get(DioRestFull().vaccines);
    final items = response.data['result']['items'] as List;
    vaccines.addAll(items.map((json) => Vaccine.fromJson(json)).toList());
    setState(() {});
  }

  void onChangeHo() {
    setState(() {
      isHo = !isHo;
    });
  }

  void onChangeSot() {
    isSot = !isSot;
    setState(() {});
  }

  String? _selectedOption = 'Option 1';
  List<String> _options = ['Option 1', 'Option 2', 'Option 3'];

  String? _selectedAddress;
  late BookingModel booking;
  bool loadFirst = false;

  DateTime? selectedDate;
  DateTime? dob;
  final name = TextEditingController();
  bool isMale = true;
  List<String> _optionsAddress = [
    'CS1 - Hà Nội',
    'CS2 - Huế',
    'CS3 - Đà Nắng',
    'CS4 - Hồ Chí Minh',
  ];
  void datLich() async {
    if (selectedDate == null || vaccine == null || _selectedAddress == null) {
      return;
    }
    String error = DioExceptions.DEFAULT;
    Response? response;
    print('selectedDate${getFormattedDateTime(selectedDate.toString())}}');
    print('_selectedAddress${_selectedAddress.toString()}');
    try {
      response = await DioRestFull.instance.dio
          .post(DioRestFull().vaccinationSchedule, data: {
        "date": getFormattedDateTime(selectedDate.toString()),
        "vaccine_id": vaccine?.id,
        //"address": _selectedAddress,
        "healthSurveyAnswers": [
          {"healthSurveyTemplateId": 1, "choice": isHo ? 1 : 0},
          {"healthSurveyTemplateId": 2, "choice": isSot ? 1 : 0}
        ],
        "injector_info": {
          'name': name.text,
          'dob': getFormattedDateTime(dob.toString()),
          'gender': isMale ? 'MALE' : 'FEMALE',
          'address': _selectedAddress,
        }
        // 'idKh': SercureStorageApp().GetValueData('id'),
        // 'thoiGian':
        //     '${getFormattedDateTime(selectedDate.toString())}T13:49:24.981Z',
        // 'diaDiem': _selectedAddress,
        // 'idVacXin': booking.id
      }).catchError((onError) {
        error = DioExceptions.messageError(onError);
        print(error);
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Lỗi đặt lịch"),
      ));
    }
    if (response != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Đặt thành công!"),
      ));
      // var data = response.data;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectDob(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: dob ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != dob) {
      setState(() {
        dob = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu), // Biểu tượng menu
          onPressed: () {
            Scaffold.of(context).openDrawer(); // Mở Drawer
          },
        ),
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
      body: Padding(
        padding: const EdgeInsets.only(
            left: 10), // Đảm bảo không có padding bên phải

        child: Center(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch, // Đảm bảo kéo dài hết chiều ngang
            children: [
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.topRight, // Đảm bảo sát lề phải
                child: Container(
                  width: screenWidth / 2, // Một nửa màn hình
                  height: 45,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 51, 240, 218), // Màu nền
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15), // Bo góc trên bên trái
                      bottomLeft: Radius.circular(15), // Bo góc dưới bên trái
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'ĐĂNG KÝ TIÊM',
                      style: TextStyle(
                        fontSize: 20, // Kích thước phù hợp với container
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  const Text(
                    'Họ tên:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold, // Đặt chữ in đậm
                    ),
                  ),
                  SizedBox(width: 17),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                        controller: name,
                        decoration:
                            InputDecoration(hintText: 'nhập họ tên...')),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    'Ngày sinh:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold, // Đặt chữ in đậm
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    dob != null ? _formatDate(dob!) : 'No date selected',
                    style: dob != null
                        ? const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)
                        : const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.normal),
                  ),
                  IconButton(
                      onPressed: () => _selectDob(context),
                      icon: const Icon(Icons.arrow_drop_down_outlined)),
                ],
              ),
              Row(
                children: [
                  const Text(
                    'Giới tính:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold, // Đặt chữ in đậm
                    ),
                  ),
                  SizedBox(width: 17),
                  Checkbox(
                      value: isMale,
                      onChanged: (value) => setState(() {
                            isMale = true;
                          })),
                  Text('Nam'),
                  SizedBox(width: 12),
                  Checkbox(
                      value: !isMale,
                      onChanged: (value) => setState(() {
                            isMale = false;
                          })),
                  Text('Nữ'),
                  SizedBox(width: 12),
                ],
              ),
              const SizedBox(height: 15),
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                const Text(
                  'Chọn vaccine:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold, // Đặt chữ in đậm
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                DropdownButton(
                  value: vaccine,
                  items: vaccines.map((Vaccine option) {
                    return DropdownMenuItem<Vaccine>(
                      value: option,
                      child: Text(option.name ?? 'No vaccine selected'),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      vaccine = newValue!;
                    });
                  },
                )
              ]),
              const SizedBox(
                height: 15,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        'Ngày tiêm:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold, // Đặt chữ in đậm
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        selectedDate != null
                            ? _formatDate(selectedDate!)
                            : 'No date selected',
                        style: selectedDate != null
                            ? const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)
                            : const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.normal),
                      ),
                      IconButton(
                          onPressed: () => _selectDate(context),
                          icon: const Icon(Icons.arrow_drop_down_outlined)),
                    ],
                  ),
                  const SizedBox(height: 13),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    const Text(
                      'Cơ sở tiêm:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold, // Đặt chữ in đậm
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    DropdownButton<String>(
                      value: _selectedAddress,
                      items: _optionsAddress.map((String option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedAddress = newValue!;
                        });
                      },
                    ),
                  ]),
                  const SizedBox(height: 15),
                  const Text(
                    'Khảo sát tình trạng sức khỏe',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold, // Đặt chữ in đậm
                    ),
                  ),
                  _buildCheckBoxText(isHo, 'Bạn đang bị ho, sốt', onChangeHo),
                  _buildCheckBoxText(isSot, 'Bạn gặp vấn đề khác', onChangeSot),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: datLich,
                    child: const Text(
                      'Đặt lịch tiêm chủng',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white, // Đổi màu chữ thành trắng
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 26, 75, 108),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckBoxText(
      bool value, String text, void Function() onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Checkbox(value: value, onChanged: (val) => onChanged()),
        SizedBox(width: 12),
        Text(text)
      ],
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd-MM-yy').format(date);
  }
}
