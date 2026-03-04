import 'package:equatable/equatable.dart';
import 'package:venue_connect/features/package/domain/entities/package_entity.dart';

enum PackageStatus { initial, loading, loaded, error }

class PackageState extends Equatable {
  final PackageStatus status;
  final List<PackageEntity> packages;
  final PackageEntity? selectedPackage;
  final String? errorMessage;

  const PackageState({
    this.status = PackageStatus.initial,
    this.packages = const <PackageEntity>[],
    this.selectedPackage,
    this.errorMessage,
  });

  PackageState copyWith({
    PackageStatus? status,
    List<PackageEntity>? packages,
    PackageEntity? selectedPackage,
    String? errorMessage,
  }) {
    return PackageState(
      status: status ?? this.status,
      packages: packages ?? this.packages,
      selectedPackage: selectedPackage ?? this.selectedPackage,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, packages, selectedPackage, errorMessage];
}
