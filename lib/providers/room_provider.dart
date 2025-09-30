import 'dart:math';
import 'package:flutter/material.dart';
import '../services/room_connectivity_service.dart';
import '../services/room_discovery_service.dart';

class RoomProvider extends ChangeNotifier {
  String? _roomCode;
  bool _isHost = false;
  bool _inRoom = false;
  String _status = '';

  String? get roomCode => _roomCode;
  bool get isHost => _isHost;
  bool get inRoom => _inRoom;
  String get status => _status;

  // Generate a 6-character alphanumeric code
  String _generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random.secure();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  void createRoom() {
    _roomCode = _generateRoomCode();
    _isHost = true;
    _inRoom = true;
    _status = 'Starting as host...';
    notifyListeners();
    RoomConnectivityService().onStatusChanged = (s) {
      _status = s;
      notifyListeners();
    };
    RoomConnectivityService().startHosting(_roomCode!);
    // Start advertising for discovery
    RoomDiscoveryService().startDiscovery(_roomCode!, isHost: true);
    RoomDiscoveryService().discoveryStatusStream.listen((s) {
      _status = s;
      notifyListeners();
    });
  }

  void joinRoom(String code) {
    _roomCode = code.trim().toUpperCase();
    _isHost = false;
    _inRoom = true;
    _status = 'Joining room...';
    notifyListeners();
    RoomConnectivityService().onStatusChanged = (s) {
      _status = s;
      notifyListeners();
    };
    RoomConnectivityService().joinRoom(_roomCode!);
    // Start scanning for discovery
    RoomDiscoveryService().startDiscovery(_roomCode!, isHost: false);
    RoomDiscoveryService().discoveryStatusStream.listen((s) {
      _status = s;
      notifyListeners();
    });
  }

  void leaveRoom() {
    _roomCode = null;
    _isHost = false;
    _inRoom = false;
    _status = 'Left room';
    notifyListeners();
    RoomConnectivityService().leaveRoom();
    RoomDiscoveryService().stopDiscovery();
  }
}

