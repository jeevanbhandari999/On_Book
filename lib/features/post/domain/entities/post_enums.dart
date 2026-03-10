// enums roomtype
import 'package:flutter/material.dart';

enum RoomType { single, double, twin, suite, deluxe, family, apartment }

extension RoomTypeExtension on RoomType {
  String get displayName {
    switch (this) {
      case RoomType.single:
        return 'Single Room';
      case RoomType.double:
        return 'Double Room';
      case RoomType.twin:
        return 'Twin Room';
      case RoomType.suite:
        return 'Suite';
      case RoomType.deluxe:
        return 'Deluxe Room';
      case RoomType.family:
        return 'Family Room';
      case RoomType.apartment:
        return 'Entire Apartment';
    }
  }
}

enum PostStatus { available, booked, sold, underMaintenance }

extension PostStatusExtension on PostStatus {
  String get label {
    switch (this) {
      case PostStatus.available:
        return 'Available';
      case PostStatus.booked:
        return 'Booked';
      case PostStatus.sold:
        return 'Sold';
      case PostStatus.underMaintenance:
        return 'Under Maintenance';
    }
  }

  bool get isAvailable => this == PostStatus.available;
}

enum AmenityType { wifi, parking, airConditioning, tv, kitchen, swimmingPool }

// extension AmenityTypeExtension on AmenityType {
//   String get label {
//     switch (this) {
//       case AmenityType.wifi:
//         return 'Free Wi-Fi';
//       case AmenityType.parking:
//         return 'Parking';
//       case AmenityType.airConditioning:
//         return 'Air Conditioning';
//       case AmenityType.tv:
//         return 'Television';
//       case AmenityType.kitchen:
//         return 'Kitchen';
//       case AmenityType.swimmingPool:
//         return 'Swimming Pool';
//     }
//   }
// }

extension AmenityTypeExtension on AmenityType {
  String get label {
    switch (this) {
      case AmenityType.wifi:
        return 'Free Wi-Fi';
      case AmenityType.parking:
        return 'Parking';
      case AmenityType.airConditioning:
        return 'Air Conditioning';
      case AmenityType.tv:
        return 'Television';
      case AmenityType.kitchen:
        return 'Kitchen';
      case AmenityType.swimmingPool:
        return 'Swimming Pool';
    }
  }

  IconData get icon {
    switch (this) {
      case AmenityType.wifi:
        return Icons.wifi;
      case AmenityType.parking:
        return Icons.local_parking;
      case AmenityType.airConditioning:
        return Icons.ac_unit;
      case AmenityType.tv:
        return Icons.tv;
      case AmenityType.kitchen:
        return Icons.kitchen;
      case AmenityType.swimmingPool:
        return Icons.pool;
    }
  }
}

enum PostTag {
  nearBeach,
  cityCenter,
  mountainView,
  budgetFriendly,
  luxury,
  familyFriendly,
}

// extension PostTagExtension on PostTag {
//   String get label {
//     switch (this) {
//       case PostTag.nearBeach:
//         return 'Near Beach';
//       case PostTag.cityCenter:
//         return 'City Center';
//       case PostTag.mountainView:
//         return 'Mountain View';
//       case PostTag.budgetFriendly:
//         return 'Budget Friendly';
//       case PostTag.luxury:
//         return 'Luxury';
//       case PostTag.familyFriendly:
//         return 'Family Friendly';
//     }
//   }
// }

extension PostTagExtension on PostTag {
  String get label {
    switch (this) {
      case PostTag.nearBeach:
        return 'Near Beach';
      case PostTag.cityCenter:
        return 'City Center';
      case PostTag.mountainView:
        return 'Mountain View';
      case PostTag.budgetFriendly:
        return 'Budget Friendly';
      case PostTag.luxury:
        return 'Luxury';
      case PostTag.familyFriendly:
        return 'Family Friendly';
    }
  }

  IconData get icon {
    switch (this) {
      case PostTag.nearBeach:
        return Icons.beach_access;
      case PostTag.cityCenter:
        return Icons.location_city;
      case PostTag.mountainView:
        return Icons.terrain;
      case PostTag.budgetFriendly:
        return Icons.attach_money;
      case PostTag.luxury:
        return Icons.star;
      case PostTag.familyFriendly:
        return Icons.family_restroom;
    }
  }
}

// Generic enum helpers
String enumToString(Object e) => e.toString().split('.').last;

T? enumFromString<T>(List<T> values, String? value) {
  if (value == null) return null;
  return values.firstWhere(
    (v) => value == v.toString().split('.').last,
    orElse: () => values.first,
  );
}

/// Converts a list of strings to a list of enum values of type T
List<T>? enumListFromStrings<T extends Enum>(
  List<String>? values,
  List<T> enumValues,
) {
  if (values == null || values.isEmpty) {
    return [];
  }
  return values
      .map((a) => enumFromString(enumValues, a))
      .where((e) => e != null)
      .cast<T>()
      .toList();
}
