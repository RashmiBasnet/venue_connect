// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_hive_model.dart';

class BookingHiveModelAdapter extends TypeAdapter<BookingHiveModel> {
  @override
  final int typeId = HiveTableConstant.bookingTypeId;

  @override
  BookingHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return BookingHiveModel(
      bookingId: fields[0] as String?,
      venueId: fields[1] as String,
      packageId: fields[2] as String?,
      bookedBy: fields[3] as String,
      eventDate: fields[4] as DateTime,
      startTime: fields[5] as String,
      endTime: fields[6] as String,
      guests: fields[7] as int,
      pricePerPlate: fields[8] as double,
      totalPrice: fields[9] as double,
      status: fields[10] as String,
      paymentStatus: fields[11] as String,
      contactName: fields[12] as String,
      contactPhone: fields[13] as String,
      contactEmail: fields[14] as String?,
      note: fields[15] as String?,
      extras: (fields[16] as List).cast<String>(),
      venueName: fields[17] as String?,
      venueArea: fields[18] as String?,
      venueCity: fields[19] as String?,
      venueCountry: fields[20] as String?,
      venueImage: fields[21] as String?,
      packageName: fields[22] as String?,
      createdAt: fields[23] as DateTime?,
      updatedAt: fields[24] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, BookingHiveModel obj) {
    writer
      ..writeByte(25)
      ..writeByte(0)
      ..write(obj.bookingId)
      ..writeByte(1)
      ..write(obj.venueId)
      ..writeByte(2)
      ..write(obj.packageId)
      ..writeByte(3)
      ..write(obj.bookedBy)
      ..writeByte(4)
      ..write(obj.eventDate)
      ..writeByte(5)
      ..write(obj.startTime)
      ..writeByte(6)
      ..write(obj.endTime)
      ..writeByte(7)
      ..write(obj.guests)
      ..writeByte(8)
      ..write(obj.pricePerPlate)
      ..writeByte(9)
      ..write(obj.totalPrice)
      ..writeByte(10)
      ..write(obj.status)
      ..writeByte(11)
      ..write(obj.paymentStatus)
      ..writeByte(12)
      ..write(obj.contactName)
      ..writeByte(13)
      ..write(obj.contactPhone)
      ..writeByte(14)
      ..write(obj.contactEmail)
      ..writeByte(15)
      ..write(obj.note)
      ..writeByte(16)
      ..write(obj.extras)
      ..writeByte(17)
      ..write(obj.venueName)
      ..writeByte(18)
      ..write(obj.venueArea)
      ..writeByte(19)
      ..write(obj.venueCity)
      ..writeByte(20)
      ..write(obj.venueCountry)
      ..writeByte(21)
      ..write(obj.venueImage)
      ..writeByte(22)
      ..write(obj.packageName)
      ..writeByte(23)
      ..write(obj.createdAt)
      ..writeByte(24)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookingHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
