import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

enum ConnectionStatus {
  disconnected,
  connected,
}

class WebSocketService {
  WebSocketChannel? _channel;
  ConnectionStatus _currentStatus = ConnectionStatus.disconnected;
  final _messageController = StreamController<dynamic>.broadcast();
  final _connectionStatusController =
      StreamController<ConnectionStatus>.broadcast();
  bool _isDisposed = false;

  Stream<dynamic> get incomingMessages => _messageController.stream;
  Stream<ConnectionStatus> get connectionStatus =>
      _connectionStatusController.stream;

  WebSocketService() {
    _initializeWebSocket();
  }

  Future<void> _initializeWebSocket() async {
    print("Initializing WebSocket...");

    _updateConnectionStatus(ConnectionStatus.disconnected);

    try {
      // Your WebSocket connection logic
      if (kIsWeb) {
        final wsUrl = Uri.parse('ws://192.168.1.17:80/ws');
        _channel = WebSocketChannel.connect(wsUrl);
      } else {
        _channel = IOWebSocketChannel.connect('ws://192.168.1.17:80/ws');
      }

      _channel!.stream.listen(
        (message) {
          print("Received message from WebSocket: $message");
          _updateConnectionStatus(ConnectionStatus.connected);
          _messageController.add(message);
        },
        onError: (error) {
          print("WebSocket error: $error");
          _handleConnectionError();
        },
        onDone: () {
          print("WebSocket connection closed.");
          _handleConnectionError(); // Handle reconnection here if needed
        },
      );
    } catch (e) {
      print("WebSocket initialization error: $e");
      _handleConnectionError();
    }
  }

  bool isConnected() {
    return _currentStatus == ConnectionStatus;
  }

  Future<void> redial() async {
    print("Trying to reconnect...");

    int attempts = 0;
    while (attempts < 5) {
      try {
        await Future.delayed(
            Duration(seconds: 2 << attempts)); // Exponential backoff
        await _initializeWebSocket();
        print("Reconnection successful.");
        _updateConnectionStatus(ConnectionStatus.disconnected);

        return; // Exit if successful
      } catch (e) {
        print("Reconnection attempt #${attempts + 1} failed: $e");
        attempts++;
      }
    }
    print("Max reconnection attempts reached.");
  }

  void _updateConnectionStatus(ConnectionStatus status) {
    if (_isDisposed || _connectionStatusController.isClosed) return;
    _currentStatus = status;
    _connectionStatusController.add(status);
  }

  void _handleConnectionError() {
    if (_isDisposed) return;
    print("Handling connection error...");
    if (_currentStatus == ConnectionStatus.connected) {
      _updateConnectionStatus(ConnectionStatus.disconnected);
    }
  }

  void sendMessage(String message) {
    if (_channel != null) {
      try {
        _channel!.sink.add(message);
      } catch (e) {
        print("Error sending message: $e");
      }
    }
  }

  void sendJsonData(Map<String, dynamic> jsonData) {
    final jsonString = jsonEncode(jsonData);
    sendMessage(jsonString);
  }

  void dispose() {
    print("Disposing WebSocket service...");
    _isDisposed = true; // Mark as disposed
    _updateConnectionStatus(ConnectionStatus.disconnected);

    if (_channel != null) {
      try {
        _channel!.sink.close();
      } catch (e) {
        print("Error closing WebSocket connection: $e");
      }
    }
  }
}
