import 'package:frontend/config/apiConfig.dart';
// import 'package:frontend/providers/friend_provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();
  IO.Socket? socket;

  // FriendProvider friendProvider
  void connect(String token) {
    socket = IO.io(
      ApiConfig.baseUrl,
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
      // friendProvider.setupFriendListeners();
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
    socket?.dispose();
    socket = null;
  }
}