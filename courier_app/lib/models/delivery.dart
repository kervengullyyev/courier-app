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
  final Recipient? recipient;
  final Sender? sender;
  final String createdAt;
  final double price;
  final String serviceType;
  final String pickupType; // 'easybox' or 'address'
  final String deliveryType; // 'easybox' or 'address'
  final String pickupLocation; // Selected location name
  final String deliveryLocation; // Selected delivery location name
  final String? packageDescription;

  const Delivery({
    required this.id,
    required this.pickupAddress,
    required this.deliveryAddress,
    required this.status,
    this.courier,
    this.recipient,
    this.sender,
    required this.createdAt,
    required this.price,
    required this.serviceType,
    required this.pickupType,
    required this.deliveryType,
    required this.pickupLocation,
    required this.deliveryLocation,
    this.packageDescription,
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
      recipient: json['recipient'] != null 
          ? Recipient.fromJson(json['recipient'] as Map<String, dynamic>)
          : null,
      sender: json['sender'] != null 
          ? Sender.fromJson(json['sender'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt'] as String,
      price: (json['price'] as num).toDouble(),
      serviceType: json['serviceType'] as String,
      pickupType: json['pickupType'] as String,
      deliveryType: json['deliveryType'] as String,
      pickupLocation: json['pickupLocation'] as String,
      deliveryLocation: json['deliveryLocation'] as String,
      packageDescription: json['packageDescription'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pickupAddress': pickupAddress,
      'deliveryAddress': deliveryAddress,
      'status': status,
      'courier': courier?.toJson(),
      'recipient': recipient?.toJson(),
      'sender': sender?.toJson(),
      'createdAt': createdAt,
      'price': price,
      'serviceType': serviceType,
      'pickupType': pickupType,
      'deliveryType': deliveryType,
      'pickupLocation': pickupLocation,
      'deliveryLocation': deliveryLocation,
      'packageDescription': packageDescription,
    };
  }

  Delivery copyWith({
    int? id,
    String? pickupAddress,
    String? deliveryAddress,
    String? status,
    Courier? courier,
    Recipient? recipient,
    Sender? sender,
    String? createdAt,
    double? price,
    String? serviceType,
    String? pickupType,
    String? deliveryType,
    String? pickupLocation,
    String? deliveryLocation,
    String? packageDescription,
  }) {
    return Delivery(
      id: id ?? this.id,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      status: status ?? this.status,
      courier: courier ?? this.courier,
      recipient: recipient ?? this.recipient,
      sender: sender ?? this.sender,
      createdAt: createdAt ?? this.createdAt,
      price: price ?? this.price,
      serviceType: serviceType ?? this.serviceType,
      pickupType: pickupType ?? this.pickupType,
      deliveryType: deliveryType ?? this.deliveryType,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      packageDescription: packageDescription ?? this.packageDescription,
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

class Recipient {
  final String fullName;
  final String phoneNumber;

  const Recipient({
    required this.fullName,
    required this.phoneNumber,
  });

  factory Recipient.fromJson(Map<String, dynamic> json) {
    return Recipient(
      fullName: json['fullName'] as String,
      phoneNumber: json['phoneNumber'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
    };
  }
}

class Sender {
  final String fullName;
  final String phoneNumber;

  const Sender({
    required this.fullName,
    required this.phoneNumber,
  });

  factory Sender.fromJson(Map<String, dynamic> json) {
    return Sender(
      fullName: json['fullName'] as String,
      phoneNumber: json['phoneNumber'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
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
