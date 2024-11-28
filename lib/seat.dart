import 'package:flutter/material.dart';

class SeatReservationPage extends StatefulWidget {
  @override
  _SeatReservationPageState createState() => _SeatReservationPageState();
}

class _SeatReservationPageState extends State<SeatReservationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> readingRooms = ['열람실1', '열람실2', '열람실3'];

  final Map<String, List<List<bool>>> seatStatusMap = {
    '열람실1': List.generate(4, (_) => List.generate(4, (_) => false)),
    '열람실2': List.generate(4, (_) => List.generate(4, (_) => false)),
    '열람실3': List.generate(4, (_) => List.generate(4, (_) => false)),
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: readingRooms.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('자리 확인 및 예약'),
        bottom: TabBar(
          controller: _tabController,
          tabs: readingRooms.map((room) => Tab(text: room)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: readingRooms.map((room) {
          return SeatGrid(
            roomName: room,
            seatStatus: seatStatusMap[room]!,
            onToggleSeat: (row, col) => _toggleSeat(room, row, col),
          );
        }).toList(),
      ),
    );
  }

  void _toggleSeat(String room, int row, int col) {
    setState(() {
      seatStatusMap[room]![row][col] = !seatStatusMap[room]![row][col];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(seatStatusMap[room]![row][col]
            ? '$room - ${row + 1}열 ${col + 1}번 자리가 예약되었습니다.'
            : '$room - ${row + 1}열 ${col + 1}번 예약이 취소되었습니다.'),
      ),
    );
    // TODO: API 호출로 예약/취소 상태 업데이트
  }
}

class SeatGrid extends StatelessWidget {
  final String roomName;
  final List<List<bool>> seatStatus;
  final void Function(int row, int col) onToggleSeat;

  const SeatGrid({
    required this.roomName,
    required this.seatStatus,
    required this.onToggleSeat,
  });

  @override
  Widget build(BuildContext context) {
    // 좌석 크기 및 간격 설정
    final seatSize = 80.0;
    final verticalSpacing = 16.0; // 위아래 간격
    final horizontalSpacing = 2.0; // 좌우 간격 (아주 살짝)

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(
        seatStatus.length,
            (rowIndex) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30,),
              // 행 번호 (작은 크기)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 43.0),
                child: Text(
                  '${rowIndex + 1}번 책상', // '1행', '2행' 형식으로 표시
                  style: TextStyle(
                    fontSize: 16, // 행 텍스트 크기 조정
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // 각 행에 해당하는 열 번호 표시
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  seatStatus[rowIndex].length,
                      (colIndex) => GestureDetector(
                    onTap: () => onToggleSeat(rowIndex, colIndex),
                    child: Container(
                      width: seatSize,
                      height: seatSize,
                      margin: EdgeInsets.symmetric(horizontal: horizontalSpacing), // 좌우 간격
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: seatStatus[rowIndex][colIndex]
                            ? Colors.redAccent
                            : Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${colIndex + 1}', // 열 번호 1, 2, 3, 4
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: seatSize * 0.3, // 좌석 크기에 맞는 폰트 크기
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20,),
            ],
          );
        },
      ),
    );
  }
}
