import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
class PermissionProvider extends ChangeNotifier{
  final OnAudioQuery _audioQuery = OnAudioQuery();
  bool _hasPermission = false;
  String _value='';
  int _currentSongIndex = 0;
  int _currentStoredSongIndex = 0;
  int _currentStoredSongIndex1 = 0;

  int get    currentStoredSongIndex=>_currentStoredSongIndex;
  int get    currentStoredSongIndex1=>_currentStoredSongIndex1;

  int get currentSongIndex=>_currentSongIndex;
  OnAudioQuery get audioQuery=>_audioQuery;
  bool get hasPermission=>_hasPermission;
  OrderType _selectedOrderType = OrderType.ASC_OR_SMALLER;
  OrderType get selectedOrderType => _selectedOrderType;
  String get value=>_value;
  void onChanged(String val){
    _value=val;
    notifyListeners();
  }
  void toggleOrderType() {
    _selectedOrderType = _selectedOrderType == OrderType.ASC_OR_SMALLER
        ? OrderType.DESC_OR_GREATER
        : OrderType.ASC_OR_SMALLER;
    notifyListeners();
  }
  void updateCurrentSongIndex(int newIndex) {
    _currentSongIndex = newIndex;
    notifyListeners(); // Notify listeners about the change
  }
  void updateCurrentSongIndex1(int newIndex) {
    _currentSongIndex = newIndex;
    notifyListeners(); // Notify listeners about the change
  }
  Future<void> checkAndRequestPermissions({bool retry = false}) async {
    _hasPermission = await _audioQuery.checkAndRequest(retryRequest: retry);
    notifyListeners();
  }
  Future<void> getStoredCurrentSongIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
      _currentStoredSongIndex = prefs.getInt('currentSongIndex') ?? 0;
notifyListeners();
  }
  Future<void> getStoredCurrentSongIndex1() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _currentStoredSongIndex = prefs.getInt('currentSongIndex1') ?? 0;
    notifyListeners();
  }

}