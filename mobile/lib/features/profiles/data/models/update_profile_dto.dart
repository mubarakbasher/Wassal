class UpdateProfileDto {
  final String? name;
  final String? email;
  final String? networkName;
  final String? password;

  UpdateProfileDto({
    this.name,
    this.email,
    this.networkName,
    this.password,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (networkName != null) data['networkName'] = networkName;
    if (password != null) data['password'] = password;
    
    return data;
  }
}
