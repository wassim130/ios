class Project {
  final String title , name , description , link, image ;
  final List<String> technologies ;

  Project({
    required this.title,
    required this.name,
    required this.description,
    required this.link,
    required this.image,
    required this.technologies,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'name': name,
      'description': description,
      'link': link,
      'image': image,
      'technologies': technologies,
    };
  }
}
