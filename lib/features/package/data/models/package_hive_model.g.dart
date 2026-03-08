// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'package_hive_model.dart';

class PackageHiveModelAdapter extends TypeAdapter<PackageHiveModel> {
  @override
  final int typeId = HiveTableConstant.packageTypeId;

  @override
  PackageHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return PackageHiveModel(
      packageId: fields[0] as String?,
      venueId: fields[1] as String,
      name: fields[2] as String,
      description: fields[3] as String?,
      images: (fields[4] as List).cast<String>(),
      pricePerPlate: fields[5] as double,
      minGuests: fields[6] as int?,
      maxGuests: fields[7] as int?,
      inclusions: (fields[8] as List).cast<String>(),
      addOns: (fields[9] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      isActive: fields[10] as bool,
      createdAt: fields[11] as DateTime?,
      updatedAt: fields[12] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, PackageHiveModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.packageId)
      ..writeByte(1)
      ..write(obj.venueId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.images)
      ..writeByte(5)
      ..write(obj.pricePerPlate)
      ..writeByte(6)
      ..write(obj.minGuests)
      ..writeByte(7)
      ..write(obj.maxGuests)
      ..writeByte(8)
      ..write(obj.inclusions)
      ..writeByte(9)
      ..write(obj.addOns)
      ..writeByte(10)
      ..write(obj.isActive)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PackageHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
