// ============================================================================
// DELIVERY MODEL - DATA STRUCTURES
// ============================================================================
// Data models for delivery-related entities
// ============================================================================

class Delivery {
  final int id;
  final String pickupAddress;
  final String deliveryAddress;
  final String status;
  final Courier? courier;
  final String createdAt;
  final double price;
  final String serviceType;

  const Delivery({
    required this.id,
    required this.pickupAddress,
    required this.deliveryAddress,
    required this.status,
    this.courier,
    required this.createdAt,
    required this.price,
    required this.serviceType,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id'] as int,
      pickupAddress: json['pickupAddress'] as String,
      deliveryAddress: json['deliveryAddress'] as String,
      status: json['status'] as String,
      courier: json['courier'] != null 
          ? Courier.fromJson(json['courier'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt'] as String,
      price: (json['price'] as num).toDouble(),
      serviceType: json['serviceType'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pickupAddress': pickupAddress,
      'deliveryAddress': deliveryAddress,
      'status': status,
      'courier': courier?.toJson(),
      'createdAt': createdAt,
      'price': price,
      'serviceType': serviceType,
    };
  }

  Delivery copyWith({
    int? id,
    String? pickupAddress,
    String? deliveryAddress,
    String? status,
    Courier? courier,
    String? createdAt,
    double? price,
    String? serviceType,
  }) {
    return Delivery(
      id: id ?? this.id,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      status: status ?? this.status,
      courier: courier ?? this.courier,
      createdAt: createdAt ?? this.createdAt,
      price: price ?? this.price,
      serviceType: serviceType ?? this.serviceType,
    );
  }
}

class Courier {
  final String fullName;
  final String? phoneNumber;
  final String? vehicleType;

  const Courier({
    required this.fullName,
    this.phoneNumber,
    this.vehicleType,
  });

  factory Courier.fromJson(Map<String, dynamic> json) {
    return Courier(
      fullName: json['full_name'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      vehicleType: json['vehicleType'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'phoneNumber': phoneNumber,
      'vehicleType': vehicleType,
    };
  }
}

class Location {
  final String name;
  final String address;
  final String type; // 'easybox' or 'address'
  final double? latitude;
  final double? longitude;

  const Location({
    required this.name,
    required this.address,
    required this.type,
    this.latitude,
    this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      name: json['name'] as String,
      address: json['address'] as String,
      type: json['type'] as String,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'type': type,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

enum DeliveryStatus {
  pending('Pending'),
  inTransit('In Transit'),
  delivered('Delivered'),
  cancelled('Cancelled');

  const DeliveryStatus(this.displayName);
  final String displayName;
}

enum ServiceType {
  city('City', 15.0),
  interCity('Inter-City', 35.0);

  const ServiceType(this.displayName, this.price);
  final String displayName;
  final double price;
}
