import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:socialclub/Constants/Constantcolors.dart';
import 'package:socialclub/screens/Chatroom/chat_roomHelper.dart';

class ChatRoom extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
ConstantColors constantColors=ConstantColors();
@override
  void setState(VoidCallback fn) {
    super.setState(fn);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: constantColors.blueGreyColor.withOpacity(0.4),
        title: RichText(text: TextSpan(
            text: 'Chat',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: constantColors.whiteColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            children: <TextSpan>[
              TextSpan(
                text: 'Room',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: constantColors.blueColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              )
            ]
        )),
        actions: [
          IconButton(onPressed: (){}, icon: Icon(EvaIcons.moreVertical,color: constantColors.whiteColor,))
        ],
        leading:IconButton(onPressed: (){Provider.of<ChatRoomHelper>(context,listen: false).showCreateChatRoomSheet(context);}, icon: Icon(FontAwesomeIcons.plus,color: constantColors.lightBlueColor,))
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Provider.of<ChatRoomHelper>(context,listen: false).showChatRooms(context),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){Provider.of<ChatRoomHelper>(context,listen: false).showCreateChatRoomSheet(context);},
        backgroundColor: constantColors.blueGreyColor,
        child: Icon(FontAwesomeIcons.plus,color: constantColors.lightBlueColor,)
      ),
    );
  }
}
