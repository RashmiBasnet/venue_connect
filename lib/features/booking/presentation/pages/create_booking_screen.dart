import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/core/utils/snackbar_utils.dart';
import 'package:venue_connect/features/booking/domain/entities/create_booking_entity.dart';
import 'package:venue_connect/features/booking/presentation/state/booking_state.dart';
import 'package:venue_connect/features/booking/presentation/view_model/booking_viewmodel.dart';
import 'package:venue_connect/features/package/domain/entities/package_entity.dart';
import 'package:venue_connect/features/package/domain/usecases/get_packages_by_venue_id_usecase.dart';
import 'package:venue_connect/features/venue/domain/entities/venue_entity.dart';

class CreateBookingScreen extends ConsumerStatefulWidget {
  final VenueEntity venue;

  const CreateBookingScreen({super.key, required this.venue});

  @override
  ConsumerState<CreateBookingScreen> createState() =>
      _CreateBookingScreenState();
}

class _CreateBookingScreenState extends ConsumerState<CreateBookingScreen> {
  final _formKey = GlobalKey<FormState>();

  final _contactNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime? _eventDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  String? _selectedPackageId;
  int _guests = 1;

  bool _isSubmitting = false;
  bool _isLoadingPackages = true;
  String? _packageError;

  List<PackageEntity> _activePackages = const <PackageEntity>[];

  @override
  void initState() {
    super.initState();
    _guests = widget.venue.capacity.minGuests;
    Future.microtask(_loadPackages);
  }

  @override
  void dispose() {
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    _contactEmailController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  PackageEntity? get _selectedPackage {
    if (_selectedPackageId == null || _selectedPackageId!.isEmpty) return null;

    for (final pkg in _activePackages) {
      if (pkg.packageId == _selectedPackageId) return pkg;
    }
    return null;
  }

  int get _minGuests {
    return _selectedPackage?.capacity?.minGuests ??
        widget.venue.capacity.minGuests;
  }

  int get _maxGuests {
    return _selectedPackage?.capacity?.maxGuests ??
        widget.venue.capacity.maxGuests;
  }

  double get _pricePerPlate {
    return _selectedPackage?.pricePerPlate ?? widget.venue.pricePerPlate;
  }

  double get _estimatedTotal => _pricePerPlate * _guests;

  Future<void> _loadPackages() async {
    setState(() {
      _isLoadingPackages = true;
      _packageError = null;
    });

    final usecase = ref.read(getPackagesByVenueIdUsecaseProvider);
    final result = await usecase(
      GetPackagesByVenueIdUsecaseParams(venueId: widget.venue.venueId ?? ''),
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isLoadingPackages = false;
          _packageError = failure.message;
          _activePackages = const <PackageEntity>[];
        });
      },
      (packages) {
        setState(() {
          _isLoadingPackages = false;
          _activePackages = packages.where((p) => p.isActive).toList();
        });
      },
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2),
    );

    if (picked != null) {
      setState(() {
        _eventDate = picked;
      });
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? const TimeOfDay(hour: 10, minute: 0),
    );

    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? const TimeOfDay(hour: 13, minute: 0),
    );

    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select date';
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'Select time';
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  void _onPackageChanged(String? packageId) {
    setState(() {
      _selectedPackageId = packageId == null || packageId.isEmpty
          ? null
          : packageId;
      if (_guests < _minGuests) _guests = _minGuests;
      if (_guests > _maxGuests) _guests = _maxGuests;
    });
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    if (_eventDate == null) {
      _showWarning('Please select event date');
      return;
    }
    if (_startTime == null) {
      _showWarning('Please select start time');
      return;
    }
    if (_endTime == null) {
      _showWarning('Please select end time');
      return;
    }

    if (_toMinutes(_endTime!) <= _toMinutes(_startTime!)) {
      _showWarning('End time must be after start time');
      return;
    }

    if (_guests < _minGuests) {
      _showWarning('Guests must be at least $_minGuests');
      return;
    }

    if (_guests > _maxGuests) {
      _showWarning('Guests must be at most $_maxGuests');
      return;
    }

    if ((widget.venue.venueId ?? '').trim().isEmpty) {
      _showWarning('Venue ID is missing');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final request = CreateBookingEntity(
      venueId: widget.venue.venueId!,
      packageId: _selectedPackageId,
      eventDate: _formatDate(_eventDate),
      startTime: _formatTime(_startTime),
      endTime: _formatTime(_endTime),
      guests: _guests,
      contactName: _contactNameController.text.trim(),
      contactPhone: _contactPhoneController.text.trim(),
      contactEmail: _contactEmailController.text.trim().isEmpty
          ? null
          : _contactEmailController.text.trim(),
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      extras: const <String>[],
    );

    await ref.read(bookingViewmodelProvider.notifier).createBooking(request);

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    final bookingState = ref.read(bookingViewmodelProvider);

    if (bookingState.status == BookingStateStatus.error) {
      _showError(bookingState.errorMessage ?? 'Booking failed');
      return;
    }

    _showSuccess('Booking created successfully');
    Navigator.of(context).pop();
  }

  void _showWarning(String message) =>
      SnackbarUtils.showWarning(context, message);

  void _showError(String message) => SnackbarUtils.showError(context, message);

  void _showSuccess(String message) =>
      SnackbarUtils.showSuccess(context, message);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Book Venue',
          style: TextStyle(fontFamily: 'Poppins SemiBold'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Book ${widget.venue.name}',
                style: const TextStyle(
                  fontFamily: 'Poppins SemiBold',
                  fontSize: 20,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Fill in the details below to place your booking request.',
                style: TextStyle(
                  fontFamily: 'Poppins Regular',
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 20),
              const _FieldLabel('Package (optional)'),
              const SizedBox(height: 8),
              if (_isLoadingPackages)
                const LinearProgressIndicator(minHeight: 2)
              else
                DropdownButtonFormField<String>(
                  key: ValueKey(_selectedPackageId ?? ''),
                  initialValue: _selectedPackageId ?? '',
                  isExpanded: true,
                  decoration: _inputDecoration(),
                  items: [
                    const DropdownMenuItem<String>(
                      value: '',
                      child: Text('No package (use venue price)'),
                    ),
                    ..._activePackages
                        .where((p) => p.packageId != null)
                        .map(
                          (p) => DropdownMenuItem<String>(
                            value: p.packageId,
                            child: Text(
                              '${p.name} — Rs. ${p.pricePerPlate.toStringAsFixed(0)}/plate',
                            ),
                          ),
                        ),
                  ],
                  onChanged: _onPackageChanged,
                ),
              if (_packageError != null && _packageError!.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    _packageError!,
                    style: const TextStyle(
                      fontFamily: 'Poppins Regular',
                      fontSize: 12,
                      color: Colors.red,
                    ),
                  ),
                ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _PickerField(
                      label: 'Event Date',
                      value: _formatDate(_eventDate),
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _PickerField(
                      label: 'Start Time',
                      value: _formatTime(_startTime),
                      onTap: _pickStartTime,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _PickerField(
                      label: 'End Time',
                      value: _formatTime(_endTime),
                      onTap: _pickEndTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const _FieldLabel('Guests'),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: _guests.toString(),
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(),
                onChanged: (value) {
                  final parsed = int.tryParse(value);
                  if (parsed != null) {
                    _guests = parsed;
                    setState(() {});
                  }
                },
                validator: (value) {
                  final parsed = int.tryParse((value ?? '').trim());
                  if (parsed == null || parsed < 1) {
                    return 'Guests must be at least 1';
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Allowed: $_minGuests — $_maxGuests',
                  style: const TextStyle(
                    fontFamily: 'Poppins Regular',
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const _FieldLabel('Contact Name'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contactNameController,
                decoration: _inputDecoration(hint: 'Full name'),
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Contact name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              const _FieldLabel('Contact Phone'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contactPhoneController,
                decoration: _inputDecoration(hint: '98xxxxxxxx'),
                validator: (value) {
                  final v = (value ?? '').trim();
                  if (v.length < 6) return 'Contact phone is required';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              const _FieldLabel('Contact Email (optional)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contactEmailController,
                decoration: _inputDecoration(hint: 'you@example.com'),
                validator: (value) {
                  final v = (value ?? '').trim();
                  if (v.isEmpty) return null;
                  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                  if (!emailRegex.hasMatch(v)) return 'Invalid email';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              const _FieldLabel('Note (optional)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                minLines: 3,
                maxLines: 4,
                decoration: _inputDecoration(
                  hint: 'Any extra info for the venue...',
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: [
                    _PreviewRow(
                      label: 'Price per plate',
                      value: 'Rs. ${_pricePerPlate.toStringAsFixed(0)}',
                    ),
                    const SizedBox(height: 8),
                    _PreviewRow(
                      label: 'Estimated total',
                      value: 'Rs. ${_estimatedTotal.toStringAsFixed(0)}',
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Final price is confirmed by server rules.',
                      style: TextStyle(
                        fontFamily: 'Poppins Regular',
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF233041),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isSubmitting ? 'Creating booking...' : 'Confirm Booking',
                    style: const TextStyle(
                      fontFamily: 'Poppins SemiBold',
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontFamily: 'Poppins Regular', fontSize: 13),
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF9CA3AF), width: 1.5),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Poppins Medium',
        fontSize: 13,
        color: Color(0xFF1F2937),
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _PickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins Medium',
            fontSize: 13,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD1D5DB)),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Poppins Regular',
                fontSize: 13,
                color: Color(0xFF111827),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PreviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _PreviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins Regular',
            fontSize: 13,
            color: Color(0xFF6B7280),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Poppins SemiBold',
            fontSize: 13,
            color: Color(0xFF111827),
          ),
        ),
      ],
    );
  }
}
