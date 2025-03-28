import 'message.dart';
class ConversationModel {
  final int id;
  final String username,imageURL;
  MessagesModel? lastMessage;

  ConversationModel({required this.id,required this.username , required this.lastMessage ,required this.imageURL});
  
  factory ConversationModel.fromMap(Map<String,dynamic> map){
    return ConversationModel(
      id: map['id'],
      username: map['username'],
      lastMessage: map['last_message'],
      imageURL: map['image_url'],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'last_message': lastMessage,
      'image_url': imageURL,
    };
  }
  
}