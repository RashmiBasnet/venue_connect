import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:venue_connect/core/constants/hive_table_constant.dart';
import 'package:venue_connect/features/auth/data/models/user_hive_model.dart';
import 'package:venue_connect/features/booking/data/models/booking_hive_model.dart';
import 'package:venue_connect/features/package/data/models/package_hive_model.dart';
import 'package:venue_connect/features/venue/data/models/venue_hive_model.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  Future<void> init() async {
    // find path
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${HiveTableConstant.dbName}';
    Hive.init(path);
    _registerAdapter();
    await openBoxes();
  }

  // Register Adapter
  void _registerAdapter() {
    if (!Hive.isAdapterRegistered(HiveTableConstant.userTypeId)) {
      Hive.registerAdapter(UserHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstant.venueTypeId)) {
      Hive.registerAdapter(VenueHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstant.packageTypeId)) {
      Hive.registerAdapter(PackageHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstant.bookingTypeId)) {
      Hive.registerAdapter(BookingHiveModelAdapter());
    }
  }

  // Open Boxes
  Future<void> openBoxes() async {
    await Hive.openBox<UserHiveModel>(HiveTableConstant.userTable);
    await Hive.openBox<VenueHiveModel>(HiveTableConstant.venueTable);
    await Hive.openBox<PackageHiveModel>(HiveTableConstant.packageTable);
    await Hive.openBox<BookingHiveModel>(HiveTableConstant.bookingTable);
  }

  // Close Boxes
  Future<void> closeBoxes() async {
    await Hive.close();
  }

  // ===================== User Queries =====================
  Box<UserHiveModel> get _userBox =>
      Hive.box<UserHiveModel>(HiveTableConstant.userTable);
  Box<VenueHiveModel> get _venueBox =>
      Hive.box<VenueHiveModel>(HiveTableConstant.venueTable);
  Box<PackageHiveModel> get _packageBox =>
      Hive.box<PackageHiveModel>(HiveTableConstant.packageTable);
  Box<BookingHiveModel> get _bookingBox =>
      Hive.box<BookingHiveModel>(HiveTableConstant.bookingTable);

  // Register
  Future<UserHiveModel> registerUser(UserHiveModel model) async {
    await _userBox.put(model.userId, model);
    return model;
  }

  // Login
  Future<UserHiveModel?> loginUser(String email, String password) async {
    final users = _userBox.values.where(
      (user) => user.email == email && user.password == password,
    );
    if (users.isNotEmpty) {
      return users.first;
    }
    return null;
  }

  // Logout
  Future<void> logoutUser() async {}

  // Get Current User
  UserHiveModel? getCurrentUser(String userId) {
    return _userBox.get(userId);
  }

  // Check if Email Exists
  Future<bool> isEmailExists(String email) async {
    final users = _userBox.values.where((user) => user.email == email);
    return users.isNotEmpty;
  }

  // ===================== Venue Queries =====================
  Future<void> saveVenues(List<VenueHiveModel> venues, {int? amount}) async {
    final dataToCache = amount == null ? venues : venues.take(amount).toList();

    await _venueBox.clear();
    for (final venue in dataToCache) {
      final key = (venue.venueId ?? '').trim().isNotEmpty
          ? venue.venueId!
          : venue.name;
      await _venueBox.put(key, venue);
    }
  }

  Future<List<VenueHiveModel>> getAllVenues({int? amount}) async {
    final venues = _venueBox.values.toList();
    if (amount == null) return venues;
    return venues.take(amount).toList();
  }

  VenueHiveModel? getVenueById(String venueId) {
    return _venueBox.get(venueId);
  }

  // ===================== Package Queries =====================
  Future<void> savePackages(
    List<PackageHiveModel> packages, {
    int? amount,
  }) async {
    final dataToCache = amount == null
        ? packages
        : packages.take(amount).toList();

    await _packageBox.clear();
    for (final package in dataToCache) {
      final key = (package.packageId ?? '').trim().isNotEmpty
          ? package.packageId!
          : '${package.venueId}-${package.name}';
      await _packageBox.put(key, package);
    }
  }

  Future<List<PackageHiveModel>> getAllPackages({int? amount}) async {
    final packages = _packageBox.values.toList();
    if (amount == null) return packages;
    return packages.take(amount).toList();
  }

  PackageHiveModel? getPackageById(String packageId) {
    return _packageBox.get(packageId);
  }

  Future<List<PackageHiveModel>> getPackagesByVenueId(String venueId) async {
    return _packageBox.values.where((pkg) => pkg.venueId == venueId).toList();
  }

  // ===================== Booking Queries =====================
  Future<void> saveMyBookings(
    List<BookingHiveModel> bookings, {
    int? amount,
  }) async {
    final dataToCache = amount == null
        ? bookings
        : bookings.take(amount).toList();

    await _bookingBox.clear();
    for (final booking in dataToCache) {
      final key = (booking.bookingId ?? '').trim().isNotEmpty
          ? booking.bookingId!
          : '${booking.venueId}-${booking.eventDate.toIso8601String()}';
      await _bookingBox.put(key, booking);
    }
  }

  Future<void> saveMyBooking(BookingHiveModel booking) async {
    final key = (booking.bookingId ?? '').trim().isNotEmpty
        ? booking.bookingId!
        : '${booking.venueId}-${booking.eventDate.toIso8601String()}';
    await _bookingBox.put(key, booking);
  }

  Future<List<BookingHiveModel>> getMyBookings({int? amount}) async {
    final bookings = _bookingBox.values.toList()
      ..sort((a, b) {
        final aTime = a.createdAt ?? a.eventDate;
        final bTime = b.createdAt ?? b.eventDate;
        return bTime.compareTo(aTime);
      });

    if (amount == null) return bookings;
    return bookings.take(amount).toList();
  }

  BookingHiveModel? getMyBookingById(String bookingId) {
    return _bookingBox.get(bookingId);
  }
}
