import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

String apiKey = 'http://175.113.202.160:2028';

class SeatReservationPage extends StatefulWidget {
  @override
  _SeatReservationPageState createState() => _SeatReservationPageState();
}

class _SeatReservationPageState extends State<SeatReservationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late WebSocket _socket;

  final List<String> readingRooms = ['열람실1', '열람실2', '열람실3'];

  final Map<String, List<List<Map<String, dynamic>>>> seatStatusMap = {
    '열람실1': List.generate(
        4, (_) => List.generate(4, (_) => {'status': false, 'isLocal': false})),
    '열람실2': List.generate(
        4, (_) => List.generate(4, (_) => {'status': false, 'isLocal': false})),
    '열람실3': List.generate(
        4, (_) => List.generate(4, (_) => {'status': false, 'isLocal': false})),
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: readingRooms.length, vsync: this);
    _connectToWebSocket();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _socket.close();
    super.dispose();
  }

  /// WebSocket 연결
  void _connectToWebSocket() async {
    try {
      _socket = await WebSocket.connect('ws://$apiKey'); // WebSocket 주소
      print("Connected to WebSocket");

      // 메시지 수신
      _socket.listen((message) {
        final data = jsonDecode(message);

        if (data['type'] == 'seatStatusUpdate') {
          _updateSeatStatusFromServer(data['seatStatus']);
        }
      });
    } catch (e) {
      print("WebSocket connection error: $e");
    }
  }

  /// 서버에서 수신한 데이터로 좌석 상태 업데이트
  void _updateSeatStatusFromServer(Map<String, dynamic> newSeatStatus) {
    setState(() {
      for (var room in readingRooms) {
        if (newSeatStatus.containsKey(room)) {
          seatStatusMap[room] = List<List<Map<String, dynamic>>>.from(
            newSeatStatus[room].map(
                  (row) => List<Map<String, dynamic>>.from(
                row.map((seat) => {
                  'status': seat['status'],
                  'isLocal': false, // 서버에서 받은 상태는 로컬 클릭 아님
                }),
              ),
            ),
          );
        }
      }
    });
  }

  /// 좌석 상태 변경 및 서버로 전송
  void _toggleSeat(String room, int row, int col) {
    setState(() {
      seatStatusMap[room]![row][col] = {
        'status': !seatStatusMap[room]![row][col]['status'],
        'isLocal': true, // 로컬에서 클릭한 상태로 설정
      };
    });

    // 서버로 업데이트 전송
    final updateMessage = jsonEncode({
      'type': 'seatStatusChange',
      'room': room,
      'row': row,
      'col': col,
      'status': seatStatusMap[room]![row][col]['status'],
    });
    _socket.add(updateMessage);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(seatStatusMap[room]![row][col]['status']
            ? '$room - ${row + 1}열 ${col + 1}번 자리가 예약되었습니다.'
            : '$room - ${row + 1}열 ${col + 1}번 예약이 취소되었습니다.'),
      ),
    );
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
}

class SeatGrid extends StatelessWidget {
  final String roomName;
  final List<List<Map<String, dynamic>>> seatStatus;
  final void Function(int row, int col) onToggleSeat;

  const SeatGrid({
    required this.roomName,
    required this.seatStatus,
    required this.onToggleSeat,
  });

  @override
  Widget build(BuildContext context) {
    final seatSize = 80.0;
    final verticalSpacing = 16.0;
    final horizontalSpacing = 2.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(
        seatStatus.length,
            (rowIndex) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 43.0),
                child: Text(
                  '${rowIndex + 1}번 책상',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  seatStatus[rowIndex].length,
                      (colIndex) {
                    final seat = seatStatus[rowIndex][colIndex];
                    final color = seat['status']
                        ? (seat['isLocal'] ? Colors.yellow : Colors.redAccent)
                        : Colors.green;

                    return GestureDetector(
                      onTap: () => onToggleSeat(rowIndex, colIndex),
                      child: Container(
                        width: seatSize,
                        height: seatSize,
                        margin:
                        EdgeInsets.symmetric(horizontal: horizontalSpacing),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${colIndex + 1}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: seatSize * 0.3,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}
