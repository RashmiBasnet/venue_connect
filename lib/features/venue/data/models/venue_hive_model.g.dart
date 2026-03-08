// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'venue_hive_model.dart';

class VenueHiveModelAdapter extends TypeAdapter<VenueHiveModel> {
  @override
  final int typeId = HiveTableConstant.venueTypeId;

  @override
  VenueHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return VenueHiveModel(
      venueId: fields[0] as String?,
      name: fields[1] as String,
      description: fields[2] as String?,
      area: fields[3] as String?,
      city: fields[4] as String,
      country: fields[5] as String,
      zipCode: fields[6] as String?,
      images: (fields[7] as List).cast<String>(),
      pricePerPlate: fields[8] as double,
      minGuests: fields[9] as int,
      maxGuests: fields[10] as int,
      amenities: (fields[11] as List).cast<String>(),
      isActive: fields[12] as bool,
      createdAt: fields[13] as DateTime?,
      updatedAt: fields[14] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, VenueHiveModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.venueId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.area)
      ..writeByte(4)
      ..write(obj.city)
      ..writeByte(5)
      ..write(obj.country)
      ..writeByte(6)
      ..write(obj.zipCode)
      ..writeByte(7)
      ..write(obj.images)
      ..writeByte(8)
      ..write(obj.pricePerPlate)
      ..writeByte(9)
      ..write(obj.minGuests)
      ..writeByte(10)
      ..write(obj.maxGuests)
      ..writeByte(11)
      ..write(obj.amenities)
      ..writeByte(12)
      ..write(obj.isActive)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VenueHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
