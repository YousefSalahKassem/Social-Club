import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:socialclub/Constants/Constantcolors.dart';
import 'package:socialclub/screens/AltPtofile/alt_profile.dart';
import 'package:socialclub/screens/Messaging/GroupMessage.dart';
import 'package:socialclub/screens/Profile/profile.dart';
import 'package:timeago/timeago.dart'as timeago;
import 'package:socialclub/services/FirebaseOperations.dart';

class ChatRoomHelper with ChangeNotifier{
  String get getChatRoomAvatar=>ChatRoomAvatarUrl;
  String get getChatRoomId=>ChatRoomId;
  late String ChatRoomAvatarUrl,ChatRoomId;
  String get getLastMessageTime=>lastMessageTime;
  late String lastMessageTime;
  ConstantColors constantColors=ConstantColors();
  final TextEditingController chatRoomController=TextEditingController();
  final TextEditingController passwordController=TextEditingController();


  showCreateChatRoomSheet(BuildContext context,){
    return showModalBottomSheet(isScrollControlled: true,context: context, builder: (context){
      return Padding(
        padding:  EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          height: MediaQuery.of(context).size.height*.32,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: constantColors.blueGreyColor,
            borderRadius: BorderRadius.only(topRight: Radius.circular(12),topLeft: Radius.circular(12)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 150.0),
                child: Divider(
                  thickness: 4,
                  color: constantColors.whiteColor,
                ),
              ),
              Text('Select ChatRoom Avatar',style: TextStyle(color: constantColors.greenColor,fontWeight: FontWeight.bold,fontSize: 16),),
              Container(
                height: MediaQuery.of(context).size.height*.1,
                width: MediaQuery.of(context).size.width,
                child: StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('chatroomicons').snapshots()
                    ,builder: (context,snapshot){
                  if(snapshot.connectionState==ConnectionState.waiting){
                    return Center(child: CircularProgressIndicator(),);
                  }
                  else{
                    return new ListView(
                      scrollDirection: Axis.horizontal,
                      children: snapshot.data!.docs.map((DocumentSnapshot document) {
                        return InkWell(
                          onTap: (){
                            ChatRoomAvatarUrl=document['image'];
                            IconSelectedNotification(context, document['image']);
                            Timer(Duration(seconds: 1), (){Navigator.pop(context);});
                            notifyListeners();
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Container(
                              height: 10,
                              width: 40,
                              child: CachedNetworkImage(imageUrl: document['image']),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }
                    }),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(children: [
                    Container(
                      width: MediaQuery.of(context).size.width*.7,
                      child: TextField(
                        textCapitalization: TextCapitalization.words,
                        controller: chatRoomController,
                        style: TextStyle(
                            color: constantColors.whiteColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter ChatRoom ID',
                          hintStyle:TextStyle(
                              color: constantColors.greyColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width*.7,
                      child: TextField(
                        textCapitalization: TextCapitalization.words,
                        controller: passwordController,
                        style: TextStyle(
                            color: constantColors.whiteColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter Password',
                          hintStyle:TextStyle(
                              color: constantColors.greyColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ),
                  ],),
                  FloatingActionButton(onPressed: ()async{
                    FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get().then((value) {
                      Provider.of<FirebaseOperations>(context,listen: false).submitChatRoomData(chatRoomController.text,
                          {
                            'roomavatar':getChatRoomAvatar,
                            'time':Timestamp.now(),
                            'password':passwordController.text,
                            'roomname':chatRoomController.text,
                            'username':value['username'],
                            'userimage':value['userimage'],
                            'useremail':value['useremail'],
                            'useruid':value['useruid'],
                          }, ).whenComplete(() => Navigator.pop(context));
                    });
                  },
                    backgroundColor: constantColors.blueColor,
                    child: Icon(FontAwesomeIcons.plus,color: constantColors.whiteColor,),),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  showChatRooms(BuildContext context){
    return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance.collection('chatrooms').snapshots()
    ,builder: (context,snapshot){
      if(snapshot.connectionState==ConnectionState.waiting){
        return Center(child: CircularProgressIndicator(),);
      }
      else{
        return new ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document ) {
            return ListTile(
              onTap: (){
                Navigator.pushReplacement(context, PageTransition(child: GroupMessaging(chatRoomId: document), type: PageTransitionType.leftToRight));
              },
              onLongPress: (){showChatRoomDetails(context, document);},
              leading: CircleAvatar(
                backgroundColor: constantColors.transperant,
                backgroundImage: NetworkImage(document['roomavatar']),
              ),
              title: Text(document['roomname'],style: TextStyle(color: constantColors.whiteColor,fontSize: 16,fontWeight: FontWeight.bold),),
              subtitle: StreamBuilder<QuerySnapshot>(
               stream: FirebaseFirestore.instance.collection('chatrooms').doc(document.id).collection('messages').orderBy('time',descending: true).snapshots()
              ,builder: (context,snapshot){
                 if(snapshot.connectionState==ConnectionState.waiting){return Center(child: CircularProgressIndicator(),);}
                 else if(snapshot.data!.docs.first['username']!=null&&snapshot.data!.docs.first['message']!=null){
                   return Text('${snapshot.data!.docs.first['username']} :   ${snapshot.data!.docs.first['message']}',style: TextStyle(color: constantColors.greenColor,fontSize: 13,fontWeight: FontWeight.bold),maxLines: 1,);
                 }
                 else if(snapshot.data!.docs.first['username']!=null&&snapshot.data!.docs.first['sticker']!=null){
                   return Text('${snapshot.data!.docs.first['username']} :   Sticker',style: TextStyle(color: constantColors.greenColor,fontSize: 13,fontWeight: FontWeight.bold),maxLines: 1,);
                 }
                 else{
                   return Container(
                     width: 0,
                     height: 0,
                   );
                 }
              }),
              trailing: Container(
                width: 80,
                child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('chatrooms').doc(document.id).collection('messages').orderBy('time',descending: true).snapshots()
                    ,builder: (context,snapshot){
                  if(snapshot.connectionState==ConnectionState.waiting){return Center(child: CircularProgressIndicator(),);}
                  else{
                    showLastMessageTime(snapshot.data!.docs.first['time']);
                    return Text(getLastMessageTime,style: TextStyle(color: constantColors.whiteColor,fontSize: 11,fontWeight: FontWeight.bold),maxLines: 1,);
                  }
                }),
              ),
            );
          }).toList(),
        );
      }
    });
  }

  IconSelectedNotification(BuildContext context,String name){
    return showModalBottomSheet(context: context, builder: (context){
      return Container(
        height: MediaQuery.of(context).size.height*.1,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(color: constantColors.darkColor,borderRadius: BorderRadius.circular(12)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 150.0),
                child: Divider(
                  thickness: 4,
                  color: constantColors.whiteColor,
                ),
              ),
              Row(
                children: [
                  Text('Selected Icon:',style: TextStyle(color: constantColors.whiteColor,fontWeight: FontWeight.bold,fontSize: 16),),
                  SizedBox(width: 20,),
                  Image.network(name,height: 20,width: 20,),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  showChatRoomDetails(BuildContext context,DocumentSnapshot documentSnapshot){
    return showModalBottomSheet(context: context, builder: (context){
      return Container(
        height: MediaQuery.of(context).size.height*.27,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: constantColors.blueGreyColor,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(12),topRight: Radius.circular(12))
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 150.0),
              child: Divider(
                thickness: 4,
                color: constantColors.whiteColor,
              ),
            ),
            Container(decoration: BoxDecoration(border: Border.all(color: constantColors.blueColor),borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Members',style: TextStyle(color: constantColors.whiteColor,fontWeight: FontWeight.bold,fontSize: 16),),
                )),
            Container(
              height: MediaQuery.of(context).size.height*.08,
              width: MediaQuery.of(context).size.width,
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('chatrooms').doc(documentSnapshot.id).collection('members').snapshots(),builder: (context,snapshot){
                    if(snapshot.connectionState==ConnectionState.waiting){return Center(child: CircularProgressIndicator(),);}
                    else{
                      return new ListView(
                        scrollDirection: Axis.horizontal,
                        children: snapshot.data!.docs.map((DocumentSnapshot documentSnapshot){
                          return InkWell(onTap: (){
                            if(FirebaseAuth.instance.currentUser!.uid==documentSnapshot['useruid'])
                              {
                                Navigator.pushReplacement(context, PageTransition(child: Profile(), type: PageTransitionType.leftToRight));
                              }
                            else{
                              Navigator.pushReplacement(context, PageTransition(child: AltProfile(userUid: documentSnapshot['useruid']), type: PageTransitionType.leftToRight));
                            }
                          },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: CircleAvatar(radius: 25,backgroundColor: constantColors.transperant,backgroundImage: NetworkImage(documentSnapshot['userimage']),),
                            ),);
                        }).toList(),
                      );
                    }
              }),
            ),
            Container(decoration: BoxDecoration(border: Border.all(color: constantColors.yellowColor),borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Admin',style: TextStyle(color: constantColors.whiteColor,fontWeight: FontWeight.bold,fontSize: 16),),
                )),
            Container(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0,top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: (){if(FirebaseAuth.instance.currentUser!.uid==documentSnapshot['useruid'])
                      {
                        Navigator.pushReplacement(context, PageTransition(child: Profile(), type: PageTransitionType.leftToRight));
                      }
                      else{
                        Navigator.pushReplacement(context, PageTransition(child: AltProfile(userUid: documentSnapshot['useruid']), type: PageTransitionType.leftToRight));
                      }},
                      child: CircleAvatar(
                        backgroundColor: constantColors.transperant,
                        backgroundImage: NetworkImage(documentSnapshot['userimage']),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(documentSnapshot['username'],style: TextStyle(color: constantColors.whiteColor,fontSize: 16,fontWeight: FontWeight.bold),),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      );
    });
  }

  showLastMessageTime(dynamic timeDate){
    Timestamp time=timeDate;
    DateTime dateTime=time.toDate();
    lastMessageTime=timeago.format(dateTime);
    print(lastMessageTime);
  }
}