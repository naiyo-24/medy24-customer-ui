import 'dart:convert';

class UserModel {
  final String? customerId;
  final String? phoneNumber;
  final String? fullName;
  final String? email;
  final String? alternativePhoneNo;
  final List<dynamic>? savedAddresses;
  final String? profilePhoto;
  final String? status;
  final String? token;

  UserModel({
    this.customerId,
    this.phoneNumber,
    this.fullName,
    this.email,
    this.alternativePhoneNo,
    this.savedAddresses,
    this.profilePhoto,
    this.status,
    this.token,
  });

  UserModel copyWith({
    String? customerId,
    String? phoneNumber,
    String? fullName,
    String? email,
    String? alternativePhoneNo,
    List<dynamic>? savedAddresses,
    String? profilePhoto,
    String? status,
    String? token,
  }) {
    return UserModel(
      customerId: customerId ?? this.customerId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      alternativePhoneNo: alternativePhoneNo ?? this.alternativePhoneNo,
      savedAddresses: savedAddresses ?? this.savedAddresses,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      status: status ?? this.status,
      token: token ?? this.token,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customer_id': customerId,
      'phone_number': phoneNumber,
      'full_name': fullName,
      'email': email,
      'alternative_phone_no': alternativePhoneNo,
      'saved_addresses': savedAddresses,
      'profile_photo': profilePhoto,
      'status': status,
      'token': token,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      customerId: map['customer_id'] ?? map['customerId'],
      phoneNumber: map['phone_number'] ?? map['phoneNumber'],
      fullName: map['full_name'] ?? map['fullName'] ?? map['name'],
      email: map['email'],
      alternativePhoneNo:
          map['alternative_phone_no'] ?? map['alternativePhoneNo'],
      savedAddresses: map['saved_addresses'] ?? map['savedAddresses'],
      profilePhoto: map['profile_photo'] ?? map['profilePhoto'],
      status: map['status'],
      token: map['token'] ?? map['backend_token'],
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserModel(customerId: $customerId, phoneNumber: $phoneNumber, fullName: $fullName, email: $email, status: $status, token: $token)';
  }
}
