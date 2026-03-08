import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/core/api/api_endpoints.dart';
import 'package:venue_connect/features/package/domain/entities/package_entity.dart';
import 'package:venue_connect/features/package/domain/usecases/get_package_by_id_usecase.dart';

class PackageDetailScreen extends ConsumerStatefulWidget {
  final String packageId;

  const PackageDetailScreen({super.key, required this.packageId});

  @override
  ConsumerState<PackageDetailScreen> createState() =>
      _PackageDetailScreenState();
}

class _PackageDetailScreenState extends ConsumerState<PackageDetailScreen> {
  PackageEntity? _package;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadPackageDetail);
  }

  Future<void> _loadPackageDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final usecase = ref.read(getPackageByIdUsecaseProvider);
    final result = await usecase(
      GetPackageByIdUsecaseParams(packageId: widget.packageId),
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _errorMessage = failure.message;
        });
      },
      (pkg) {
        setState(() {
          _isLoading = false;
          _package = pkg;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Package Details',
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
                onPressed: _loadPackageDetail,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_package == null) {
      return const Center(
        child: Text(
          'Package not found',
          style: TextStyle(fontFamily: 'Poppins Medium'),
        ),
      );
    }

    final pkg = _package!;
    final offeredBy = (pkg.venue?.name ?? '').trim().isEmpty
        ? 'Unknown venue'
        : pkg.venue!.name.trim();
    final image = pkg.images.isNotEmpty ? pkg.images.first : null;

    return RefreshIndicator(
      onRefresh: _loadPackageDetail,
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pkg.name,
                  style: const TextStyle(
                    fontFamily: 'Poppins Bold',
                    fontSize: 26,
                    color: Color(0xFF233041),
                  ),
                ),
                const SizedBox(height: 10),
                _InfoTile(title: 'Offered By', value: offeredBy),
                const SizedBox(height: 10),
                _InfoTile(
                  title: 'Price Per Plate',
                  value: 'NPR ${pkg.pricePerPlate.toStringAsFixed(0)}',
                ),
                const SizedBox(height: 10),
                _InfoTile(
                  title: 'Status',
                  value: pkg.isActive ? 'Active' : 'Inactive',
                ),
                if (pkg.capacity != null) ...[
                  const SizedBox(height: 10),
                  _InfoTile(
                    title: 'Capacity',
                    value:
                        '${pkg.capacity!.minGuests}-${pkg.capacity!.maxGuests ?? pkg.capacity!.minGuests} guests',
                  ),
                ],
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
                  (pkg.description ?? '').trim().isEmpty
                      ? 'No description available.'
                      : pkg.description!,
                  style: const TextStyle(
                    fontFamily: 'Poppins Regular',
                    fontSize: 14,
                    height: 1.6,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Inclusions',
                  style: TextStyle(
                    fontFamily: 'Poppins SemiBold',
                    fontSize: 17,
                    color: Color(0xFF233041),
                  ),
                ),
                const SizedBox(height: 8),
                if (pkg.inclusions.isEmpty)
                  const Text(
                    'No inclusions listed.',
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
                    children: pkg.inclusions
                        .map((item) => _Chip(label: item))
                        .toList(),
                  ),
                if (pkg.addOns.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Add-ons',
                    style: TextStyle(
                      fontFamily: 'Poppins SemiBold',
                      fontSize: 17,
                      color: Color(0xFF233041),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: pkg.addOns
                        .map(
                          (addOn) => _InfoTile(
                            title: addOn.title,
                            value: 'NPR ${addOn.price.toStringAsFixed(0)}',
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
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
      margin: const EdgeInsets.only(bottom: 8),
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

class _Chip extends StatelessWidget {
  final String label;

  const _Chip({required this.label});

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
