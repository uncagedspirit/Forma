// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserPreferencesModelAdapter extends TypeAdapter<UserPreferencesModel> {
  @override
  final int typeId = 4;

  @override
  UserPreferencesModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserPreferencesModel(
      isPremium: fields[0] as bool,
      premiumReceiptData: fields[1] as String?,
      hasCompletedOnboarding: fields[2] as bool,
      themeIndex: fields[3] as int,
      name: fields[4] as String,
      joinDate: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, UserPreferencesModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.isPremium)
      ..writeByte(1)
      ..write(obj.premiumReceiptData)
      ..writeByte(2)
      ..write(obj.hasCompletedOnboarding)
      ..writeByte(3)
      ..write(obj.themeIndex)
      ..writeByte(4)
      ..write(obj.name)
      ..writeByte(5)
      ..write(obj.joinDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPreferencesModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
