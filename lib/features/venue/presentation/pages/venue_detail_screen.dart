import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/core/api/api_endpoints.dart';
import 'package:venue_connect/features/booking/presentation/pages/create_booking_screen.dart';
import 'package:venue_connect/features/venue/domain/entities/venue_entity.dart';
import 'package:venue_connect/features/venue/domain/usecases/get_venue_by_id_usecase.dart';

class VenueDetailScreen extends ConsumerStatefulWidget {
  final String venueId;

  const VenueDetailScreen({super.key, required this.venueId});

  @override
  ConsumerState<VenueDetailScreen> createState() => _VenueDetailScreenState();
}

class _VenueDetailScreenState extends ConsumerState<VenueDetailScreen> {
  VenueEntity? _venue;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadVenueDetail);
  }

  Future<void> _loadVenueDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final usecase = ref.read(getVenueByIdUsecaseProvider);
    final result = await usecase(
      GetVenueByIdUsecaseParams(venueId: widget.venueId),
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _errorMessage = failure.message;
        });
      },
      (venue) {
        setState(() {
          _isLoading = false;
          _venue = venue;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Venue Details',
          style: TextStyle(fontFamily: 'Poppins SemiBold'),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins Medium',
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadVenueDetail,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_venue == null) {
      return const Center(
        child: Text(
          'Venue not found',
          style: TextStyle(fontFamily: 'Poppins Medium'),
        ),
      );
    }

    final venue = _venue!;
    final image = venue.images.isNotEmpty ? venue.images.first : null;

    return RefreshIndicator(
      onRefresh: _loadVenueDetail,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 240,
            child: image == null
                ? Container(
                    color: const Color(0xFFE5E7EB),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.image_outlined,
                      size: 40,
                      color: Colors.grey,
                    ),
                  )
                : Image.network(
                    ApiEndpoints.venueImage(image),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFE5E7EB),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.broken_image_outlined,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  venue.name,
                  style: const TextStyle(
                    fontFamily: 'Poppins Bold',
                    fontSize: 26,
                    color: Color(0xFF233041),
                  ),
                ),
                const SizedBox(height: 10),
                _InfoTile(title: 'Address', value: _addressText(venue)),
                const SizedBox(height: 10),
                _InfoTile(
                  title: 'Price Per Plate',
                  value: 'NPR ${venue.pricePerPlate.toStringAsFixed(0)}',
                ),
                const SizedBox(height: 10),
                _InfoTile(
                  title: 'Capacity',
                  value:
                      '${venue.capacity.minGuests}-${venue.capacity.maxGuests} guests',
                ),
                const SizedBox(height: 10),
                _InfoTile(
                  title: 'Status',
                  value: venue.isActive ? 'Active' : 'Inactive',
                ),
                const SizedBox(height: 16),
                const Text(
                  'Description',
                  style: TextStyle(
                    fontFamily: 'Poppins SemiBold',
                    fontSize: 17,
                    color: Color(0xFF233041),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  (venue.description ?? '').trim().isEmpty
                      ? 'No description available.'
                      : venue.description!,
                  style: const TextStyle(
                    fontFamily: 'Poppins Regular',
                    fontSize: 14,
                    height: 1.6,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Amenities',
                  style: TextStyle(
                    fontFamily: 'Poppins SemiBold',
                    fontSize: 17,
                    color: Color(0xFF233041),
                  ),
                ),
                const SizedBox(height: 8),
                if (venue.amenities.isEmpty)
                  const Text(
                    'No amenities listed.',
                    style: TextStyle(
                      fontFamily: 'Poppins Regular',
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: venue.amenities
                        .map((item) => _AmenityChip(label: item))
                        .toList(),
                  ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CreateBookingScreen(venue: venue),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF233041),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Book Now',
                      style: TextStyle(
                        fontFamily: 'Poppins SemiBold',
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _addressText(VenueEntity venue) {
    final parts = <String>[
      if ((venue.address.area ?? '').trim().isNotEmpty)
        venue.address.area!.trim(),
      venue.address.city,
      venue.address.country,
      if ((venue.address.zipCode ?? '').trim().isNotEmpty)
        venue.address.zipCode!.trim(),
    ];

    return parts.join(', ');
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String value;

  const _InfoTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x1A000000)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins Medium',
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Poppins SemiBold',
              fontSize: 14,
              color: Color(0xFF233041),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmenityChip extends StatelessWidget {
  final String label;

  const _AmenityChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x1A000000)),
        color: const Color(0xFFF8FAFC),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Poppins Medium',
          fontSize: 12,
          color: Color(0xFF334155),
        ),
      ),
    );
  }
}
