import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel{
  late String senderId,receiverId,senderName,receiverName,messageBody;
  late Timestamp time;
  MessageModel({required this.senderId,required this.receiverId,required this.senderName,
    required this.receiverName,required this.messageBody,required this.time});

  static MessageModel? fromMap(Map<String,dynamic> map){
    if(map==null) return null;

    return MessageModel(
        senderId:map['senderId'],
        receiverId: map['receiverId'],
        senderName: map['senderName'],
        receiverName: map['receiverName'],
        messageBody: map['messageBody'],
        time: map['time']
    );
  }

  Map<String,dynamic> toJson(){
    return{
    'senderId':senderId,
    'receiverId':receiverId,
    'senderName': senderName,
    'receiverName':receiverName,
    'messageBody': messageBody,
    'time':time,
    };
  }
}