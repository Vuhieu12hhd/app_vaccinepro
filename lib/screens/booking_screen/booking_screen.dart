import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injection_schedule/network/dio_exception.dart';
import 'package:injection_schedule/network/dio_restfu.dart';
import 'package:injection_schedule/screens/booking_screen/bloc/booking_bloc.dart';
import 'package:injection_schedule/screens/booking_screen/load_more_delegate.dart';
import 'package:injection_schedule/screens/booking_screen/models/vaccine_booking.dart';
import 'package:loadmore/loadmore.dart';
import 'package:qr_flutter/qr_flutter.dart';

class BookingScreen extends StatefulWidget {
  static const String routerName = 'BookingScreen';

  const BookingScreen({Key? key}) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingState();
}

class _BookingState extends State<BookingScreen> {
  int limit = 5;
  int page = 1;
  bool isLoading = false;
  List<VaccineBooking> vaccineBookings = <VaccineBooking>[];

  @override
  void initState() {
    super.initState();
    BlocProvider.of<BookingBloc>(context).add(BookingStarted());
    onRefresh(); // Bắt đầu bằng việc tải dữ liệu
  }

  Future<void> onRefresh() async {
    try {
      isLoading = true; // Đang tải dữ liệu
      setState(() {});

      page = 1;
      final response = await DioRestFull.instance.dio.get(
        DioRestFull().vaccinationSchedule,
        queryParameters: {'limit': limit, 'pageNum': page},
      );

      final items = response.data['result']['items'] as List;
      final bookings = items.map((e) => VaccineBooking.fromJson(e)).toList();
      vaccineBookings = bookings; // Cập nhật danh sách mới

      isLoading = false; // Dừng trạng thái tải
      setState(() {});
    } catch (error) {
      print('Error fetching data: $error');
      isLoading = false; // Dừng trạng thái tải
      setState(() {});
    }
  }

  Future<bool> onLoadMore() async {
    if (vaccineBookings.length < page * limit) {
      return false; // Không tải thêm nếu ít hơn giới hạn
    }

    try {
      page += 1; // Tăng số trang

      final response = await DioRestFull.instance.dio.get(
        DioRestFull().vaccinationSchedule,
        queryParameters: {'limit': limit, 'pageNum': page},
      );

      final items = response.data['result']['items'] as List;
      final bookings = items.map((e) => VaccineBooking.fromJson(e)).toList();
      vaccineBookings.addAll(bookings); // Thêm dữ liệu mới

      setState(() {});
      return bookings.length >= limit; // Tiếp tục tải nếu còn dữ liệu
    } catch (error) {
      print('Error loading more data: $error');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        titleSpacing: 5,
        title: const Text(
          'VaccinePro',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        backgroundColor: const Color.fromARGB(255, 136, 238, 226),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 30),
            onPressed: () {
              // Thêm hành động cho nút tìm kiếm ở đây
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.topRight,
              child: Container(
                width: MediaQuery.of(context).size.width / 2,
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
                    'LỊCH SỬ TIÊM',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: onRefresh,
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : vaccineBookings.isEmpty
                        ? const Center(child: Text('Không có dữ liệu'))
                        : LoadMore(
                            onLoadMore: onLoadMore,
                            delegate: LoadMoreDelegateCustom(),
                            child: BookingLoadedList(context),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget BookingLoadedList(BuildContext context) {
    final textTheme = Theme.of(context).textTheme.titleLarge;

    return ListView.separated(
      itemBuilder: (context, index) => Container(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Người tiêm: ${vaccineBookings[index].injectorInfo?.name ?? ""}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Cơ sở: ${vaccineBookings[index].injectorInfo?.address ?? ""}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Vaccine: ${vaccineBookings[index].vaccine?.name ?? ""}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: QrImageView(
                        padding: const EdgeInsets.all(0),
                        data: DioRestFull().getVaccineQrCode(
                          vaccineBookings[index].id ?? 1,
                        ),
                        size: 250,
                      ),
                    ),
                  ),
                );
              },
              child: QrImageView(
                data: DioRestFull().getVaccineQrCode(
                  vaccineBookings[index].id ?? 1,
                ),
                size: 100,
              ),
            ),
          ],
        ),
      ),
      separatorBuilder: (context, index) => const Divider(),
      itemCount: vaccineBookings.length,
    );
  }

  DateTime convert(String date) {
    return DateTime.parse(date);
  }
}
