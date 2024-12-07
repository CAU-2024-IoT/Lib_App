import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

String socketUrl = 'ws://192.168.1.208:2028'; // WebSocket 서버 주소

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

  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: readingRooms.length, vsync: this);
    _connectWebSocket();
  }

  /// WebSocket 연결 및 실시간 데이터 수신
  void _connectWebSocket() {
    socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
    });

    socket.on('connect', (_) {
      print('Connected to the WebSocket server');
    });

    // 서버에서 좌석 상태를 실시간으로 받기
    socket.on('seat_sensor_update', (data) {
      print('Received seat status from server: $data');
      _updateSeatStatusFromServer(data);
    });
  }

  /// 서버에서 수신한 데이터로 좌석 상태 업데이트
  void _updateSeatStatusFromServer(Map<String, dynamic> newSeatStatus) {
    setState(() {
      final seatStatus = newSeatStatus['seatStatus'];
      for (var room in readingRooms) {
        if (seatStatus.containsKey(room)) {
          seatStatusMap[room] = List<List<bool>>.from(
            seatStatus[room].map((row) => List<bool>.from(row)),
          );
        }
      }
    });
    print('좌석 상태가 갱신되었습니다.');
  }

  @override
  void dispose() {
    socket.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('자리 확인'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              socket.emit('requestSeatStatus', ''); // 서버에 좌석 상태 요청
            },
          ),
        ],
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
          );
        }).toList(),
      ),
    );
  }
}

class SeatGrid extends StatelessWidget {
  final String roomName;
  final List<List<bool>> seatStatus;

  const SeatGrid({
    required this.roomName,
    required this.seatStatus,
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
                    final color = seat ? Colors.redAccent : Colors.green;

                    return Container(
                      width: seatSize,
                      height: seatSize,
                      margin: EdgeInsets.symmetric(horizontal: horizontalSpacing),
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
