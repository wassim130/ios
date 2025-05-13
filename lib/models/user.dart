class UserModel {
  final String username, firstName, lastName, email, address, phoneNumber;
  String? profilePicture;
  final bool isEnterprise;
  bool twoFactorEnabled;
  final int lastPasswordChange;
  final bool isSuperUser;
  final bool isNew;

  UserModel({
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.address,
    required this.phoneNumber,
    required this.isEnterprise,
    required this.lastPasswordChange,
    this.profilePicture,
    this.twoFactorEnabled = false,
    this.isSuperUser = false,
    this.isNew = false
  });

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    username: map['username'] as String,
    firstName: map['first_name'] as String,
    lastName: map['last_name'] as String,
    email: map['email'] as String,
    address: map['address'] ?? "",
    phoneNumber: map['phone_number'] ?? "",
    isEnterprise: map['is_entreprise'] ?? false,
    lastPasswordChange: map['last_changed_password'],
    profilePicture: map['profile_picture'] as String?,
    twoFactorEnabled: map['twoFactorEnabled'] ?? false,
    isSuperUser: map['super_user'] ?? false,
    isNew:map['is_new_user'] ?? false,
  );

  Map<String, dynamic> toMap() => {
    'username': username,
    'first_name': firstName,
    'last_name': lastName,
    'email': email,
    'address': address,
    'phone_number': phoneNumber,
    'is_entreprise': isEnterprise,
    'profile_picture': profilePicture,
    'last_changed_password': lastPasswordChange,
    'twoFactorEnabled': twoFactorEnabled,
    'super_user': isSuperUser,
    'is_new_user': isNew,
  };

  @override
  String toString() =>
      'UserModel{firstName: $firstName, lastName: $lastName, email: $email, address: $address, phoneNumber: $phoneNumber, isEnterprise: $isEnterprise, twoFactorEnabled: $twoFactorEnabled}';
}
