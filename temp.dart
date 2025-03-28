import 'dart:convert';

class FreelancerModel {
  int id;
  String username;
  String name;
  String imagePath;
  String aboutWorkExp;
  String aboutMeSumm;
  String location;
  String website;
  String portfolio;
  String email;
  String resumeLink;
  String contactEmail;
  int stats_clients;
  int stat_rati;
  List<TechnologyToolsModel> tools;
  List<TechnologyModel> technologies;

  FreelancerModel({
    required this.id,
    required this.username,
    required this.name,
    required this.imagePath,
    required this.aboutWorkExp,
    required this.aboutMeSumm,
    required this.location,
    required this.website,
    required this.portfolio,
    required this.email,
    required this.resumeLink,
    required this.contactEmail,
    required this.stats_clients,
    required this.stat_rati,
    required this.tools,
    required this.technologies,
  });

  FreelancerModel copyWith({
    int? id,
    String? username,
    String? name,
    String? imagePath,
    String? aboutWorkExp,
    String? aboutMeSumm,
    String? location,
    String? website,
    String? portfolio,
    String? email,
    String? resumeLink,
    String? contactEmail,
    int? stats_clients,
    int? stat_rati,
  }) {
    return FreelancerModel(
      id: id ?? this.id,
      username: username ?? this.username,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      aboutWorkExp: aboutWorkExp ?? this.aboutWorkExp,
      aboutMeSumm: aboutMeSumm ?? this.aboutMeSumm,
      location: location ?? this.location,
      website: website ?? this.website,
      portfolio: portfolio ?? this.portfolio,
      email: email ?? this.email,
      resumeLink: resumeLink ?? this.resumeLink,
      contactEmail: contactEmail ?? this.contactEmail,
      stats_clients: stats_clients ?? this.stats_clients,
      stat_rati: stat_rati ?? this.stat_rati,
      tools: tools ?? this.tools,
      technologies: technologies ?? this.technologies,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'imagePath': imagePath,
      'aboutWorkExp': aboutWorkExp,
      'aboutMeSumm': aboutMeSumm,
      'location': location,
      'website': website,
      'portfolio': portfolio,
      'email': email,
      'resumeLink': resumeLink,
      'contactEmail': contactEmail,
      'stats_clients': stats_clients,
      'stat_rati': stat_rati,
    };
  }

  factory FreelancerModel.fromMap(Map<String, dynamic> map) {
    return FreelancerModel(
      id: map['id'],
      username: map['username'],
      name: map['name'],
      imagePath: map['imagePath'],
      aboutWorkExp: map['aboutWorkExp'],
      aboutMeSumm: map['aboutMeSumm'],
      location: map['location'],
      website: map['website'],
      portfolio: map['portfolio'],
      email: map['email'],
      resumeLink: map['resumeLink'],
      contactEmail: map['contactEmail'],
      stats_clients: map['stats_clients'],
      stat_rati: map['stat_rati'],
      tools: map['tools'] != null
          // ? List<TechnologyToolsModel>.from(
              // map['tools']?.map((x) => TechnologyToolsModel.fromMap(x)))
          ?
          map['tools']!.map((item) => TechnologyToolsModel.fromMap(item))
          : [],
      technologies: map['technologies'] != null
          ? map['technologies']!.map((x) => TechnologyModel.fromMap(x))
          : [],
    );
  }

  String toJson() => json.encode(toMap());

  factory FreelancerModel.fromJson(String source) =>
      FreelancerModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'FreelancerModel(id: $id, username: $username, name: $name, imagePath: $imagePath, aboutWorkExp: $aboutWorkExp, aboutMeSumm: $aboutMeSumm, location: $location, website: $website, portfolio: $portfolio, email: $email, resumeLink: $resumeLink, contactEmail: $contactEmail, stats_clients: $stats_clients, stat_rati: $stat_rati)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FreelancerModel &&
        other.id == id &&
        other.username == username &&
        other.name == name &&
        other.imagePath == imagePath &&
        other.aboutWorkExp == aboutWorkExp &&
        other.aboutMeSumm == aboutMeSumm &&
        other.location == location &&
        other.website == website &&
        other.portfolio == portfolio &&
        other.email == email &&
        other.resumeLink == resumeLink &&
        other.contactEmail == contactEmail &&
        other.stats_clients == stats_clients &&
        other.stat_rati == stat_rati;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        username.hashCode ^
        name.hashCode ^
        imagePath.hashCode ^
        aboutWorkExp.hashCode ^
        aboutMeSumm.hashCode ^
        location.hashCode ^
        website.hashCode ^
        portfolio.hashCode ^
        email.hashCode ^
        resumeLink.hashCode ^
        contactEmail.hashCode ^
        stats_clients.hashCode ^
        stat_rati.hashCode;
  }
}

class TechnologyModel {
  int id;
  String name;
  String technologies;

  TechnologyModel({
    required this.id,
    required this.name,
    required this.technologies,
  });

  TechnologyModel copyWith({
    int? id,
    String? name,
    String? technologies,
  }) {
    return TechnologyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      technologies: technologies ?? this.technologies,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'technologies': technologies,
    };
  }

  factory TechnologyModel.fromMap(Map<String, dynamic> map) {
    return TechnologyModel(
      id: map['id'],
      name: map['name'],
      technologies: map['technologies'],
    );
  }

  String toJson() => json.encode(toMap());

  factory TechnologyModel.fromJson(String source) =>
      TechnologyModel.fromMap(json.decode(source));

  @override
  String toString() =>
      'TechnologyModel(id: $id, name: $name, technologies: $technologies)';
}

class TechnologyToolsModel {
  int id;
  String name;

  TechnologyToolsModel({
    required this.id,
    required this.name,
  });

  TechnologyToolsModel copyWith({
    int? id,
    String? name,
  }) {
    return TechnologyToolsModel(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory TechnologyToolsModel.fromMap(Map<String, dynamic> map) {
    return TechnologyToolsModel(
      id: map['id'],
      name: map['name'],
    );
  }

  String toJson() => json.encode(toMap());

  factory TechnologyToolsModel.fromJson(String source) =>
      TechnologyToolsModel.fromMap(json.decode(source));

  @override
  String toString() => 'TechnologyToolsModel(id: $id, name: $name)';
}
