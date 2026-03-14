
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {

  final channel = WebSocketChannel.connect(
    Uri.parse('ws://YOUR_SERVER_IP:8000/live'),
  );

}
