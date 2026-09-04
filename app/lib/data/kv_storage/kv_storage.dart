import 'package:mmkv_flutter/mmkv_flutter.dart';

class KvStorage {
  KvStorage._();

  static Future<KvStorage> init() async {
    await MMKV.initialize();
    return KvStorage._();
  }

  final MMKV _kv = MMKV();

  static const String _kPendingSessionId = 'pending_session_id';
  static const String _kUid = 'uid';
  static const String _kLastBackupAt = 'last_backup_at';

  String? get pendingSessionId => _kv.decodeString(_kPendingSessionId);

  set pendingSessionId(String? v) {
    if (v == null) {
      _kv.removeValue(_kPendingSessionId);
    } else {
      _kv.encodeString(_kPendingSessionId, v);
    }
  }

  String? get uid => _kv.decodeString(_kUid);

  set uid(String? v) {
    if (v == null) {
      _kv.removeValue(_kUid);
    } else {
      _kv.encodeString(_kUid, v);
    }
  }

  DateTime? get lastBackupAt {
    final ms = _kv.decodeInt(_kLastBackupAt);
    if (ms == null || ms == 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  set lastBackupAt(DateTime? v) {
    if (v == null) {
      _kv.removeValue(_kLastBackupAt);
    } else {
      _kv.encodeInt(_kLastBackupAt, v.millisecondsSinceEpoch);
    }
  }

  T? get<T>(String key) {
    switch (T) {
      case String:
        return _kv.decodeString(key) as T?;
      case int:
        return _kv.decodeInt(key) as T?;
      case double:
        return _kv.decodeDouble(key) as T?;
      case bool:
        return _kv.decodeBool(key) as T?;
      default:
        throw UnsupportedError('Unsupported type: $T');
    }
  }

  void set<T>(String key, T? value) {
    if (value == null) {
      _kv.removeValue(key);
      return;
    }
    switch (T) {
      case String:
        _kv.encodeString(key, value as String);
        break;
      case int:
        _kv.encodeInt(key, value as int);
        break;
      case double:
        _kv.encodeDouble(key, value as double);
        break;
      case bool:
        _kv.encodeBool(key, value as bool);
        break;
      default:
        throw UnsupportedError('Unsupported type: $T');
    }
  }
}
