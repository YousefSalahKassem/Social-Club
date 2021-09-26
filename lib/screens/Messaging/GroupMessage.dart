import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:socialclub/Constants/Constantcolors.dart';
import 'package:socialclub/screens/Chatroom/chat_roomHelper.dart';
import 'package:socialclub/screens/HomePage/home_page.dart';
import 'package:socialclub/screens/Messaging/GroupMessageHelper.dart';

class GroupMessaging extends StatefulWidget {
late final DocumentSnapshot chatRoomId;

GroupMessaging({required this.chatRoomId});

  @override
  _GroupMessagingState createState() => _GroupMessagingState();
}

class _GroupMessagingState extends State<GroupMessaging> {
ConstantColors constantColors=ConstantColors();
TextEditingController messagingController=TextEditingController();

@override
  void initState() {
  Provider.of<GroupMessageHelper>(context,listen: false).checkIfJoined(context, widget.chatRoomId.id, widget.chatRoomId['useruid']).whenComplete(() {
    if(Provider.of<GroupMessageHelper>(context,listen: false).getHasMemberJoined==false){
      Timer(Duration(milliseconds: 10), ()=>Provider.of<GroupMessageHelper>(context,listen: false).askToJoin(context, widget.chatRoomId.id, widget.chatRoomId['password']));
    }
  });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: constantColors.darkColor,
      appBar: AppBar(
        leading: IconButton(onPressed: (){Navigator.pushReplacement(context, PageTransition(child: HomePage(), type: PageTransitionType.rightToLeft));}, icon: Icon(Icons.arrow_back_ios_rounded,color: constantColors.whiteColor,)),
        backgroundColor: constantColors.blueGreyColor.withOpacity(.6),
        title: InkWell(
          onTap: (){Provider.of<ChatRoomHelper>(context,listen: false).showChatRoomDetails(context, widget.chatRoomId);},
          child: Container(
            width: MediaQuery.of(context).size.width*.5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(backgroundImage: NetworkImage(widget.chatRoomId['roomavatar']),),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.chatRoomId['roomname'],style: TextStyle(color: constantColors.whiteColor,fontWeight: FontWeight.bold,fontSize: 14),),
                      StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('chatrooms').doc(widget.chatRoomId.id).collection('members').snapshots()
                      ,builder:(context,snapshot){
                        if(snapshot.connectionState==ConnectionState.waiting){
                          return Center(child: CircularProgressIndicator(),);
                        }
                        else{
                          return Text('${snapshot.data!.docs.length.toString()} Members',style: TextStyle(color: constantColors.greenColor.withOpacity(.5),fontWeight: FontWeight.bold,fontSize: 12),);

                          } }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [IconButton(onPressed: (){Provider.of<GroupMessageHelper>(context,listen: false).leaveTheRoom(context, widget.chatRoomId.id, widget.chatRoomId['useruid']);}, icon: Icon(EvaIcons.logInOutline,color: constantColors.redColor,)),
        FirebaseAuth.instance.currentUser!.uid==widget.chatRoomId['useruid']?
            IconButton(onPressed: (){Provider.of<GroupMessageHelper>(context,listen: false).showSettings(context, widget.chatRoomId.id,widget.chatRoomId);}, icon: Icon(EvaIcons.moreVertical,color: constantColors.whiteColor,)):Container(height: 0,width: 0,)
        ],
      ),
      body:SingleChildScrollView(
        child: Container(child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          AnimatedContainer(child: Provider.of<GroupMessageHelper>(context,listen: false).showMessages(context, widget.chatRoomId, widget.chatRoomId['useruid']),duration: Duration(seconds: 1),curve: Curves.bounceIn,height: MediaQuery.of(context).size.height*.82,width: MediaQuery.of(context).size.width),
          Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(onTap: (){
                          Provider.of<GroupMessageHelper>(context,listen: false).showStickers(context,widget.chatRoomId['roomname']);
                },child: CircleAvatar(radius: 18,backgroundColor: constantColors.transperant,backgroundImage: AssetImage('icons/sunflower.png'),),),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Container(width: MediaQuery.of(context).size.width*.75,
              child: TextField(
                controller: messagingController,
                style: TextStyle(color: constantColors.whiteColor,fontSize: 16,fontWeight: FontWeight.bold),
                decoration: InputDecoration(hintText: 'Say Hi Guys...',hintStyle: TextStyle(color: constantColors.lightBlueColor,fontWeight: FontWeight.bold,fontSize: 14)),
              ),),
            ),
            FloatingActionButton(backgroundColor: constantColors.blueColor,onPressed: (){Provider.of<GroupMessageHelper>(context,listen: false).SendMessages(context, widget.chatRoomId, messagingController);},child: Icon(Icons.send_sharp,color: constantColors.whiteColor,),)
            ],),),
          ),
        ],),),
      ) ,
    );
  }

}
