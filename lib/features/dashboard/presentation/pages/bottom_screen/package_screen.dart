import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/core/api/api_endpoints.dart';
import 'package:venue_connect/features/package/domain/entities/package_entity.dart';
import 'package:venue_connect/features/package/presentation/pages/package_detail_screen.dart';
import 'package:venue_connect/features/package/presentation/state/package_state.dart';
import 'package:venue_connect/features/package/presentation/view_model/package_viewmodel.dart';

class PackageScreen extends ConsumerStatefulWidget {
  const PackageScreen({super.key});

  @override
  ConsumerState<PackageScreen> createState() => _PackageScreenState();
}

class _PackageScreenState extends ConsumerState<PackageScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _currentSearch = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetchPackages());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPackages() async {
    await ref
        .read(packageViewmodelProvider.notifier)
        .getAllPackages(
          page: 1,
          size: 10,
          search: _currentSearch.isEmpty ? null : _currentSearch,
        );
  }

  Future<void> _onRefresh() async {
    await _fetchPackages();
  }

  void _onSearch() {
    setState(() {
      _currentSearch = _searchController.text.trim();
    });
    _fetchPackages();
  }

  void _onClearSearch() {
    _searchController.clear();
    setState(() {
      _currentSearch = '';
    });
    _fetchPackages();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(packageViewmodelProvider);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
          children: [
            const Text(
              'Packages',
              textAlign: TextAlign.start,
              style: TextStyle(
                fontFamily: 'Poppins Bold',
                fontSize: 30,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Browse packages offered by venues.',
              textAlign: TextAlign.start,
              style: TextStyle(
                fontFamily: 'Poppins Regular',
                fontSize: 13,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 24),
            _PackageSearchBar(
              controller: _searchController,
              onSearch: _onSearch,
              onClear: _onClearSearch,
              hasSearchText: _searchController.text.trim().isNotEmpty,
            ),
            const SizedBox(height: 16),
            _PackageBody(
              state: state,
              onViewTap: (pkg) {
                if (pkg.packageId == null || pkg.packageId!.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Package ID is missing')),
                  );
                  return;
                }

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        PackageDetailScreen(packageId: pkg.packageId!),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PackageSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;
  final VoidCallback onClear;
  final bool hasSearchText;

  const _PackageSearchBar({
    required this.controller,
    required this.onSearch,
    required this.onClear,
    required this.hasSearchText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => onSearch(),
            decoration: InputDecoration(
              hintText: 'Search packages (name, description...)',
              hintStyle: const TextStyle(
                fontFamily: 'Poppins Regular',
                fontSize: 12,
              ),
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0x1A000000)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0x1A000000)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFFC4B6AB),
                  width: 2,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        if (hasSearchText)
          _ActionButton(
            label: 'Clear',
            onTap: onClear,
            background: Colors.white,
            foreground: const Color(0xFF475569),
            borderColor: const Color(0x1A000000),
          ),
        if (hasSearchText) const SizedBox(width: 8),
        _ActionButton(
          label: 'Search',
          onTap: onSearch,
          background: const Color(0xFF233041),
          foreground: Colors.white,
        ),
      ],
    );
  }
}

class _PackageBody extends StatelessWidget {
  final PackageState state;
  final void Function(PackageEntity package) onViewTap;

  const _PackageBody({required this.state, required this.onViewTap});

  @override
  Widget build(BuildContext context) {
    if (state.status == PackageStatus.loading && state.packages.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.status == PackageStatus.error && state.packages.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: Text(
          state.errorMessage ?? 'Failed to fetch packages',
          style: const TextStyle(
            fontFamily: 'Poppins Medium',
            fontSize: 13,
            color: Color(0xFFB91C1C),
          ),
        ),
      );
    }

    if (state.packages.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0x1A000000)),
        ),
        child: const Text(
          'No packages found.',
          style: TextStyle(
            fontFamily: 'Poppins Regular',
            fontSize: 13,
            color: Color(0xFF475569),
          ),
        ),
      );
    }

    return Column(
      children: state.packages
          .map(
            (pkg) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _PackageCard(pkg: pkg, onViewTap: () => onViewTap(pkg)),
            ),
          )
          .toList(),
    );
  }
}

class _PackageCard extends StatelessWidget {
  final PackageEntity pkg;
  final VoidCallback onViewTap;

  const _PackageCard({required this.pkg, required this.onViewTap});

  @override
  Widget build(BuildContext context) {
    final offeredBy = (pkg.venue?.name ?? '').trim().isEmpty
        ? 'Unknown venue'
        : pkg.venue!.name.trim();
    final imageName = pkg.images.isNotEmpty ? pkg.images.first : null;
    final imageUrl = imageName != null
        ? ApiEndpoints.venueImage(imageName)
        : '';

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x1A000000)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 168,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (imageName == null)
                  Container(
                    color: const Color(0xFFE5E7EB),
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_outlined, color: Colors.grey),
                  )
                else
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFE5E7EB),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.broken_image_outlined,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Color(0x4D000000),
                        Color(0x1A000000),
                        Color(0x00000000),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'NPR ${pkg.pricePerPlate.toStringAsFixed(0)} / plate',
                      style: const TextStyle(
                        fontFamily: 'Poppins SemiBold',
                        fontSize: 11,
                        color: Color(0xFF233041),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pkg.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Poppins SemiBold',
                              fontSize: 19,
                              color: Color(0xFF233041),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Offered by $offeredBy',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Poppins Regular',
                              fontSize: 12,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusBadge(isActive: pkg.isActive),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  (pkg.description == null || pkg.description!.trim().isEmpty)
                      ? 'No description available.'
                      : pkg.description!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins Regular',
                    fontSize: 13,
                    height: 1.5,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (pkg.inclusions.isNotEmpty)
                      _MetaChip(text: '${pkg.inclusions.length} inclusions'),
                    if (pkg.capacity != null)
                      _MetaChip(
                        text:
                            '${pkg.capacity!.minGuests}-${pkg.capacity!.maxGuests ?? pkg.capacity!.minGuests} guests',
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: _ActionButton(
                    label: 'View',
                    onTap: onViewTap,
                    background: Colors.white,
                    foreground: const Color(0xFF233041),
                    borderColor: const Color(0x1A000000),
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

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color background;
  final Color foreground;
  final Color? borderColor;

  const _ActionButton({
    required this.label,
    required this.onTap,
    required this.background,
    required this.foreground,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: borderColor != null
                ? Border.all(color: borderColor!)
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins SemiBold',
              fontSize: 12,
              color: foreground,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;

  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final bg = isActive ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2);
    final text = isActive ? const Color(0xFF15803D) : const Color(0xFFB91C1C);
    final border = isActive ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          fontFamily: 'Poppins SemiBold',
          fontSize: 10,
          color: text,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String text;

  const _MetaChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x1A000000)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Poppins SemiBold',
          fontSize: 11,
          color: Color(0xFF334155),
        ),
      ),
    );
  }
}
