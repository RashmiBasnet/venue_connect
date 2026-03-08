import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/app/app.dart';
import 'package:venue_connect/core/api/api_endpoints.dart';
import 'package:venue_connect/features/venue/presentation/pages/venue_detail_screen.dart';
import 'package:venue_connect/features/venue/domain/entities/venue_entity.dart';
import 'package:venue_connect/features/venue/presentation/state/venue_state.dart';
import 'package:venue_connect/features/venue/presentation/view_model/venue_viewmodel.dart';

class VenueScreen extends ConsumerStatefulWidget {
  const VenueScreen({super.key});

  @override
  ConsumerState<VenueScreen> createState() => _VenueScreenState();
}

class _VenueScreenState extends ConsumerState<VenueScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(venueViewmodelProvider.notifier).getAllVenues(),
    );
  }

  Future<void> _onRefresh() async {
    await ref.read(venueViewmodelProvider.notifier).getAllVenues();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(venueViewmodelProvider);

    return SafeArea(
      child: Stack(
        children: [
          Positioned(
            top: -135,
            right: -210,
            child: Transform.rotate(
              angle: -0.05,
              child: Image.asset(
                'assets/images/image-2.png',
                width: 580,
                height: 580,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 25),
                  const Text(
                    'Venues',
                    style: TextStyle(
                      fontFamily: 'Poppins Bold',
                      fontSize: 30,
                      color: kPrimaryDark,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 44),
                  _buildBody(state),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(VenueState state) {
    if (state.status == VenueStatus.loading && state.venues.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 80),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.status == VenueStatus.error && state.venues.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 80),
        child: Center(
          child: Text(
            state.errorMessage ?? 'Failed to load venues',
            style: const TextStyle(
              fontFamily: 'Poppins Medium',
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (state.venues.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 80),
        child: Center(
          child: Text(
            'No venues available',
            style: TextStyle(
              fontFamily: 'Poppins Medium',
              color: Colors.black54,
            ),
          ),
        ),
      );
    }

    return Column(
      children: state.venues
          .map(
            (venue) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _VenueListCard(
                venue: venue,
                onDetailsTap: () {
                  if (venue.venueId == null || venue.venueId!.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Venue ID is missing')),
                    );
                    return;
                  }

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          VenueDetailScreen(venueId: venue.venueId!),
                    ),
                  );
                },
              ),
            ),
          )
          .toList(),
    );
  }
}

class _VenueListCard extends StatelessWidget {
  final VenueEntity venue;
  final VoidCallback onDetailsTap;

  const _VenueListCard({required this.venue, required this.onDetailsTap});

  @override
  Widget build(BuildContext context) {
    final imageName = venue.images.isNotEmpty ? venue.images.first : null;
    final addressLine = _buildAddress(venue);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            height: 140,
            width: double.infinity,
            child: imageName == null
                ? Container(
                    color: const Color(0xFFECECEC),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.image_outlined,
                      color: Colors.grey,
                      size: 30,
                    ),
                  )
                : Image.network(
                    ApiEndpoints.venueImage(imageName),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFECECEC),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.broken_image_outlined,
                        color: Colors.grey,
                        size: 30,
                      ),
                    ),
                  ),
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -8),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 12, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        venue.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Poppins SemiBold',
                          fontSize: 19,
                          color: Color(0xFF3A2D2D),
                          height: 0.95,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        addressLine,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Poppins Regular',
                          fontSize: 12,
                          color: Color(0xFF5F5B5B),
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 5),
                SizedBox(
                  height: 39,
                  child: ElevatedButton(
                    onPressed: onDetailsTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB58460),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    child: const Text(
                      'Details',
                      style: TextStyle(
                        fontFamily: 'Poppins SemiBold',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _buildAddress(VenueEntity venue) {
    final parts = <String>[
      if ((venue.address.area ?? '').trim().isNotEmpty)
        venue.address.area!.trim(),
      venue.address.city,
      if ((venue.address.zipCode ?? '').trim().isNotEmpty)
        venue.address.zipCode!.trim(),
    ];

    if (parts.isEmpty) {
      return 'Address not available';
    }

    return parts.join(', ');
  }
}
