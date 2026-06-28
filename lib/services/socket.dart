import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();
  IO.Socket? socket;

  void connect(String token) {
    socket = IO.io(
      'http://10.0.2.2:3000', // Android emulator
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({
            'token': token,
          })
          .build(),
    );

    socket!.connect();

    socket!.onConnect((_) {
      print("Socket connected, ${socket!.id}");
    });

    socket!.onDisconnect((_) {
      print('Socket disconnected');
    });

    socket!.onConnectError((error) {
      print('Connect error: $error');
    });
  }

  void disconnect() {
    socket?.disconnect();
  }
}