import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/app/app.dart';
import 'package:venue_connect/core/api/api_endpoints.dart';
import 'package:venue_connect/core/services/storage/user_session_storage.dart';
import 'package:venue_connect/features/package/domain/entities/package_entity.dart';
import 'package:venue_connect/features/package/presentation/state/package_state.dart';
import 'package:venue_connect/features/package/presentation/view_model/package_viewmodel.dart';
import 'package:venue_connect/features/venue/domain/entities/venue_entity.dart';
import 'package:venue_connect/features/venue/presentation/state/venue_state.dart';
import 'package:venue_connect/features/venue/presentation/view_model/venue_viewmodel.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(venueViewmodelProvider.notifier).getAllVenues();
      await ref
          .read(packageViewmodelProvider.notifier)
          .getAllPackages(page: 1, size: 4);
    });
  }

  @override
  Widget build(BuildContext context) {
    final venueState = ref.watch(venueViewmodelProvider);
    final packageState = ref.watch(packageViewmodelProvider);
    final userSessionService = ref.watch(userSessionServiceProvider);
    final username = userSessionService
        .getCurrentUserFullName()!
        .split(" ")
        .first;

    final venues = venueState.venues.take(4).toList();
    final packages = packageState.packages
        .where((package) => package.isActive)
        .take(4)
        .toList();

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
          RefreshIndicator(
            onRefresh: () async {
              await ref.read(venueViewmodelProvider.notifier).getAllVenues();
              await ref
                  .read(packageViewmodelProvider.notifier)
                  .getAllPackages(page: 1, size: 4);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/logo_blue.png',
                          width: 110,
                          height: 110,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Hi, $username",
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: kPrimaryDark,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey),
                          SizedBox(width: 8),
                          Text(
                            'Search',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Packages',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: kPrimaryDark,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildPackageSection(packageState, packages),
                            const Text(
                              'Venues',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: kPrimaryDark,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildVenueSection(venueState, venues),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageSection(
    PackageState state,
    List<PackageEntity> packages,
  ) {
    if (state.status == PackageStatus.loading && state.packages.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.status == PackageStatus.error && state.packages.isEmpty) {
      return Text(
        state.errorMessage ?? 'Failed to load packages',
        style: const TextStyle(
          fontFamily: 'Poppins Regular',
          fontSize: 13,
          color: Color(0xFFB91C1C),
        ),
      );
    }

    if (packages.isEmpty) {
      return const Text(
        'No packages available',
        style: TextStyle(
          fontFamily: 'Poppins Regular',
          fontSize: 13,
          color: Colors.black54,
        ),
      );
    }

    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: packages.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final package = packages[index];
          return _HomePackageCard(package: package);
        },
      ),
    );
  }

  Widget _buildVenueSection(VenueState state, List<VenueEntity> venues) {
    if (state.status == VenueStatus.loading && state.venues.isEmpty) {
      return const SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.status == VenueStatus.error && state.venues.isEmpty) {
      return Text(
        state.errorMessage ?? 'Failed to load venues',
        style: const TextStyle(
          fontFamily: 'Poppins Regular',
          fontSize: 13,
          color: Color(0xFFB91C1C),
        ),
      );
    }

    if (venues.isEmpty) {
      return const Text(
        'No venues available',
        style: TextStyle(
          fontFamily: 'Poppins Regular',
          fontSize: 13,
          color: Colors.black54,
        ),
      );
    }

    return Column(
      children: venues
          .map(
            (venue) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _HomeVenueCard(venue: venue),
            ),
          )
          .toList(),
    );
  }
}

class _HomePackageCard extends StatelessWidget {
  final PackageEntity package;

  const _HomePackageCard({required this.package});

  @override
  Widget build(BuildContext context) {
    final imageName = package.images.isNotEmpty ? package.images.first : null;

    return Container(
      width: 190,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: SizedBox(
              height: 120,
              width: double.infinity,
              child: imageName == null
                  ? Container(
                      color: const Color(0xFFF1F5F9),
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_outlined),
                    )
                  : Image.network(
                      ApiEndpoints.venueImage(imageName),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFFF1F5F9),
                        alignment: Alignment.center,
                        child: const Icon(Icons.broken_image_outlined),
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  package.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins SemiBold',
                    fontSize: 14,
                    color: kPrimaryDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'NPR ${package.pricePerPlate.toStringAsFixed(0)}/plate',
                  style: const TextStyle(
                    fontFamily: 'Poppins Medium',
                    fontSize: 13,
                    color: Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeVenueCard extends StatelessWidget {
  final VenueEntity venue;

  const _HomeVenueCard({required this.venue});

  @override
  Widget build(BuildContext context) {
    final imageName = venue.images.isNotEmpty ? venue.images.first : null;
    final address = [
      if ((venue.address.area ?? '').trim().isNotEmpty)
        venue.address.area!.trim(),
      venue.address.city,
    ].join(', ');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(16),
            ),
            child: SizedBox(
              width: 110,
              height: 92,
              child: imageName == null
                  ? Container(
                      color: const Color(0xFFF1F5F9),
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_outlined),
                    )
                  : Image.network(
                      ApiEndpoints.venueImage(imageName),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFFF1F5F9),
                        alignment: Alignment.center,
                        child: const Icon(Icons.broken_image_outlined),
                      ),
                    ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    venue.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Poppins SemiBold',
                      fontSize: 14,
                      color: kPrimaryDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    address,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Poppins Regular',
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'NPR ${venue.pricePerPlate.toStringAsFixed(0)}/plate',
                    style: const TextStyle(
                      fontFamily: 'Poppins Medium',
                      fontSize: 12,
                      color: Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
