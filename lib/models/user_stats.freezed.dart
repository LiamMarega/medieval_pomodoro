// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserStats {
  String get deviceId;
  String get deviceType;
  String get deviceModel;
  int get totalFocusMinutes;
  int get totalSessions;
  DateTime get lastSessionDate;
  DateTime get createdAt;
  DateTime get updatedAt;

  /// Create a copy of UserStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UserStatsCopyWith<UserStats> get copyWith =>
      _$UserStatsCopyWithImpl<UserStats>(this as UserStats, _$identity);

  /// Serializes this UserStats to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UserStats &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.deviceType, deviceType) ||
                other.deviceType == deviceType) &&
            (identical(other.deviceModel, deviceModel) ||
                other.deviceModel == deviceModel) &&
            (identical(other.totalFocusMinutes, totalFocusMinutes) ||
                other.totalFocusMinutes == totalFocusMinutes) &&
            (identical(other.totalSessions, totalSessions) ||
                other.totalSessions == totalSessions) &&
            (identical(other.lastSessionDate, lastSessionDate) ||
                other.lastSessionDate == lastSessionDate) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      deviceId,
      deviceType,
      deviceModel,
      totalFocusMinutes,
      totalSessions,
      lastSessionDate,
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'UserStats(deviceId: $deviceId, deviceType: $deviceType, deviceModel: $deviceModel, totalFocusMinutes: $totalFocusMinutes, totalSessions: $totalSessions, lastSessionDate: $lastSessionDate, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $UserStatsCopyWith<$Res> {
  factory $UserStatsCopyWith(UserStats value, $Res Function(UserStats) _then) =
      _$UserStatsCopyWithImpl;
  @useResult
  $Res call(
      {String deviceId,
      String deviceType,
      String deviceModel,
      int totalFocusMinutes,
      int totalSessions,
      DateTime lastSessionDate,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$UserStatsCopyWithImpl<$Res> implements $UserStatsCopyWith<$Res> {
  _$UserStatsCopyWithImpl(this._self, this._then);

  final UserStats _self;
  final $Res Function(UserStats) _then;

  /// Create a copy of UserStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deviceId = null,
    Object? deviceType = null,
    Object? deviceModel = null,
    Object? totalFocusMinutes = null,
    Object? totalSessions = null,
    Object? lastSessionDate = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_self.copyWith(
      deviceId: null == deviceId
          ? _self.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      deviceType: null == deviceType
          ? _self.deviceType
          : deviceType // ignore: cast_nullable_to_non_nullable
              as String,
      deviceModel: null == deviceModel
          ? _self.deviceModel
          : deviceModel // ignore: cast_nullable_to_non_nullable
              as String,
      totalFocusMinutes: null == totalFocusMinutes
          ? _self.totalFocusMinutes
          : totalFocusMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      totalSessions: null == totalSessions
          ? _self.totalSessions
          : totalSessions // ignore: cast_nullable_to_non_nullable
              as int,
      lastSessionDate: null == lastSessionDate
          ? _self.lastSessionDate
          : lastSessionDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// Adds pattern-matching-related methods to [UserStats].
extension UserStatsPatterns on UserStats {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_UserStats value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _UserStats() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_UserStats value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserStats():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_UserStats value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserStats() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String deviceId,
            String deviceType,
            String deviceModel,
            int totalFocusMinutes,
            int totalSessions,
            DateTime lastSessionDate,
            DateTime createdAt,
            DateTime updatedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _UserStats() when $default != null:
        return $default(
            _that.deviceId,
            _that.deviceType,
            _that.deviceModel,
            _that.totalFocusMinutes,
            _that.totalSessions,
            _that.lastSessionDate,
            _that.createdAt,
            _that.updatedAt);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String deviceId,
            String deviceType,
            String deviceModel,
            int totalFocusMinutes,
            int totalSessions,
            DateTime lastSessionDate,
            DateTime createdAt,
            DateTime updatedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserStats():
        return $default(
            _that.deviceId,
            _that.deviceType,
            _that.deviceModel,
            _that.totalFocusMinutes,
            _that.totalSessions,
            _that.lastSessionDate,
            _that.createdAt,
            _that.updatedAt);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String deviceId,
            String deviceType,
            String deviceModel,
            int totalFocusMinutes,
            int totalSessions,
            DateTime lastSessionDate,
            DateTime createdAt,
            DateTime updatedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserStats() when $default != null:
        return $default(
            _that.deviceId,
            _that.deviceType,
            _that.deviceModel,
            _that.totalFocusMinutes,
            _that.totalSessions,
            _that.lastSessionDate,
            _that.createdAt,
            _that.updatedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _UserStats implements UserStats {
  const _UserStats(
      {required this.deviceId,
      required this.deviceType,
      required this.deviceModel,
      required this.totalFocusMinutes,
      required this.totalSessions,
      required this.lastSessionDate,
      required this.createdAt,
      required this.updatedAt});
  factory _UserStats.fromJson(Map<String, dynamic> json) =>
      _$UserStatsFromJson(json);

  @override
  final String deviceId;
  @override
  final String deviceType;
  @override
  final String deviceModel;
  @override
  final int totalFocusMinutes;
  @override
  final int totalSessions;
  @override
  final DateTime lastSessionDate;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  /// Create a copy of UserStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UserStatsCopyWith<_UserStats> get copyWith =>
      __$UserStatsCopyWithImpl<_UserStats>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$UserStatsToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _UserStats &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.deviceType, deviceType) ||
                other.deviceType == deviceType) &&
            (identical(other.deviceModel, deviceModel) ||
                other.deviceModel == deviceModel) &&
            (identical(other.totalFocusMinutes, totalFocusMinutes) ||
                other.totalFocusMinutes == totalFocusMinutes) &&
            (identical(other.totalSessions, totalSessions) ||
                other.totalSessions == totalSessions) &&
            (identical(other.lastSessionDate, lastSessionDate) ||
                other.lastSessionDate == lastSessionDate) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      deviceId,
      deviceType,
      deviceModel,
      totalFocusMinutes,
      totalSessions,
      lastSessionDate,
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'UserStats(deviceId: $deviceId, deviceType: $deviceType, deviceModel: $deviceModel, totalFocusMinutes: $totalFocusMinutes, totalSessions: $totalSessions, lastSessionDate: $lastSessionDate, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$UserStatsCopyWith<$Res>
    implements $UserStatsCopyWith<$Res> {
  factory _$UserStatsCopyWith(
          _UserStats value, $Res Function(_UserStats) _then) =
      __$UserStatsCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String deviceId,
      String deviceType,
      String deviceModel,
      int totalFocusMinutes,
      int totalSessions,
      DateTime lastSessionDate,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$UserStatsCopyWithImpl<$Res> implements _$UserStatsCopyWith<$Res> {
  __$UserStatsCopyWithImpl(this._self, this._then);

  final _UserStats _self;
  final $Res Function(_UserStats) _then;

  /// Create a copy of UserStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? deviceId = null,
    Object? deviceType = null,
    Object? deviceModel = null,
    Object? totalFocusMinutes = null,
    Object? totalSessions = null,
    Object? lastSessionDate = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_UserStats(
      deviceId: null == deviceId
          ? _self.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      deviceType: null == deviceType
          ? _self.deviceType
          : deviceType // ignore: cast_nullable_to_non_nullable
              as String,
      deviceModel: null == deviceModel
          ? _self.deviceModel
          : deviceModel // ignore: cast_nullable_to_non_nullable
              as String,
      totalFocusMinutes: null == totalFocusMinutes
          ? _self.totalFocusMinutes
          : totalFocusMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      totalSessions: null == totalSessions
          ? _self.totalSessions
          : totalSessions // ignore: cast_nullable_to_non_nullable
              as int,
      lastSessionDate: null == lastSessionDate
          ? _self.lastSessionDate
          : lastSessionDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
mixin _$FocusSession {
  String get sessionId;
  DateTime get startTime;
  DateTime? get endTime;
  int get durationMinutes;
  bool get completed;

  /// Create a copy of FocusSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $FocusSessionCopyWith<FocusSession> get copyWith =>
      _$FocusSessionCopyWithImpl<FocusSession>(
          this as FocusSession, _$identity);

  /// Serializes this FocusSession to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is FocusSession &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.completed, completed) ||
                other.completed == completed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, sessionId, startTime, endTime, durationMinutes, completed);

  @override
  String toString() {
    return 'FocusSession(sessionId: $sessionId, startTime: $startTime, endTime: $endTime, durationMinutes: $durationMinutes, completed: $completed)';
  }
}

/// @nodoc
abstract mixin class $FocusSessionCopyWith<$Res> {
  factory $FocusSessionCopyWith(
          FocusSession value, $Res Function(FocusSession) _then) =
      _$FocusSessionCopyWithImpl;
  @useResult
  $Res call(
      {String sessionId,
      DateTime startTime,
      DateTime? endTime,
      int durationMinutes,
      bool completed});
}

/// @nodoc
class _$FocusSessionCopyWithImpl<$Res> implements $FocusSessionCopyWith<$Res> {
  _$FocusSessionCopyWithImpl(this._self, this._then);

  final FocusSession _self;
  final $Res Function(FocusSession) _then;

  /// Create a copy of FocusSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? durationMinutes = null,
    Object? completed = null,
  }) {
    return _then(_self.copyWith(
      sessionId: null == sessionId
          ? _self.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _self.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: freezed == endTime
          ? _self.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      durationMinutes: null == durationMinutes
          ? _self.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      completed: null == completed
          ? _self.completed
          : completed // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [FocusSession].
extension FocusSessionPatterns on FocusSession {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_FocusSession value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _FocusSession() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_FocusSession value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FocusSession():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_FocusSession value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FocusSession() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String sessionId, DateTime startTime, DateTime? endTime,
            int durationMinutes, bool completed)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _FocusSession() when $default != null:
        return $default(_that.sessionId, _that.startTime, _that.endTime,
            _that.durationMinutes, _that.completed);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String sessionId, DateTime startTime, DateTime? endTime,
            int durationMinutes, bool completed)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FocusSession():
        return $default(_that.sessionId, _that.startTime, _that.endTime,
            _that.durationMinutes, _that.completed);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String sessionId, DateTime startTime, DateTime? endTime,
            int durationMinutes, bool completed)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FocusSession() when $default != null:
        return $default(_that.sessionId, _that.startTime, _that.endTime,
            _that.durationMinutes, _that.completed);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _FocusSession implements FocusSession {
  const _FocusSession(
      {required this.sessionId,
      required this.startTime,
      required this.endTime,
      required this.durationMinutes,
      required this.completed});
  factory _FocusSession.fromJson(Map<String, dynamic> json) =>
      _$FocusSessionFromJson(json);

  @override
  final String sessionId;
  @override
  final DateTime startTime;
  @override
  final DateTime? endTime;
  @override
  final int durationMinutes;
  @override
  final bool completed;

  /// Create a copy of FocusSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$FocusSessionCopyWith<_FocusSession> get copyWith =>
      __$FocusSessionCopyWithImpl<_FocusSession>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$FocusSessionToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _FocusSession &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.completed, completed) ||
                other.completed == completed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, sessionId, startTime, endTime, durationMinutes, completed);

  @override
  String toString() {
    return 'FocusSession(sessionId: $sessionId, startTime: $startTime, endTime: $endTime, durationMinutes: $durationMinutes, completed: $completed)';
  }
}

/// @nodoc
abstract mixin class _$FocusSessionCopyWith<$Res>
    implements $FocusSessionCopyWith<$Res> {
  factory _$FocusSessionCopyWith(
          _FocusSession value, $Res Function(_FocusSession) _then) =
      __$FocusSessionCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String sessionId,
      DateTime startTime,
      DateTime? endTime,
      int durationMinutes,
      bool completed});
}

/// @nodoc
class __$FocusSessionCopyWithImpl<$Res>
    implements _$FocusSessionCopyWith<$Res> {
  __$FocusSessionCopyWithImpl(this._self, this._then);

  final _FocusSession _self;
  final $Res Function(_FocusSession) _then;

  /// Create a copy of FocusSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? sessionId = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? durationMinutes = null,
    Object? completed = null,
  }) {
    return _then(_FocusSession(
      sessionId: null == sessionId
          ? _self.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _self.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: freezed == endTime
          ? _self.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      durationMinutes: null == durationMinutes
          ? _self.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      completed: null == completed
          ? _self.completed
          : completed // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
