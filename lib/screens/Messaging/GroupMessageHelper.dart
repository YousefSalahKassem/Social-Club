import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:socialclub/Constants/Constantcolors.dart';
import 'package:socialclub/screens/HomePage/home_page.dart';
import 'package:timeago/timeago.dart'as timeago;

class GroupMessageHelper with ChangeNotifier{
  ConstantColors constantColors=ConstantColors();
  bool hasMemberJoined=false;
  bool get getHasMemberJoined=>hasMemberJoined;
  TextEditingController passwordController =TextEditingController();
  TextEditingController editRoomNameController =TextEditingController();

  String get getLastMessageTime=>lastMessageTime;
  late String lastMessageTime;

  SendMessages(BuildContext context,DocumentSnapshot documentSnapshot,TextEditingController message){
    return FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get().then((value) {
      FirebaseFirestore.instance.collection('chatrooms').doc(documentSnapshot.id).collection('messages').add(
          {
            'sticker':null,
            'message':message.text,
            'time':Timestamp.now(),
            'useruid':value['useruid'],
            'username':value['username'],
            'userimage':value['userimage'],
          });
    }).whenComplete(() => message.clear());

  }

  showMessages(BuildContext context,DocumentSnapshot documentSnapshot,String adminUserUid){
    return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance.collection('chatrooms').doc(documentSnapshot.id).collection('messages').orderBy('time',descending: true).snapshots()
    ,builder: (context,snapshot){
      if(snapshot.connectionState==ConnectionState.waiting)
        return Center(child: CircularProgressIndicator(),);
      else{
        return new ListView(
          reverse: true,
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            showLastMessage(context,document['time']);
            return Padding(
              padding: const EdgeInsets.only(left: 10.0,right: 10.0,top: 15,bottom: 10),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: document['message']!=null?MediaQuery.of(context).size.height*.13:MediaQuery.of(context).size.height*.23,
                child:
                InkWell(
                  onLongPress: (){
                    print(document.id);
                    if(FirebaseAuth.instance.currentUser!.uid==document['useruid']){
                    deleteComment(context, document,documentSnapshot.id);}
                  },
                  child: Stack(
                    alignment: FirebaseAuth.instance.currentUser!.uid==document['useruid']?Alignment.centerRight:Alignment.centerLeft,
                    children: [
                      Container(
                        constraints: BoxConstraints(
                          maxHeight:  document['message']!=null?
                           MediaQuery.of(context).size.height*.15:MediaQuery.of(context).size.height*.4,
                          maxWidth:document['message']!=null? MediaQuery.of(context).size.width*.8:MediaQuery.of(context).size.height*.9
                        ),
                        decoration: BoxDecoration(
                          color: FirebaseAuth.instance.currentUser!.uid==document['useruid']?constantColors.blueGreyColor.withOpacity(.8):constantColors.blueGreyColor,
                          borderRadius: BorderRadius.circular(8)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment:CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 100,
                                child: Row(
                                  children: [
                                    Text(document['username'],style: TextStyle(color: constantColors.greenColor,fontSize: 12,fontWeight: FontWeight.bold),),
                                    FirebaseAuth.instance.currentUser!.uid==adminUserUid?Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Icon(FontAwesomeIcons.chessKing,color: constantColors.yellowColor,size: 12,),
                                    ):Container(width: 0,height: 0,)
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: document['message']!=null?Text(document['message'],style: TextStyle(color: constantColors.whiteColor,fontWeight: FontWeight.bold,fontSize: 14),)
                                    :Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Container(height: 100,width: 100,child: CachedNetworkImage(imageUrl: document['sticker']),),
                                    ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 3.0),
                                child: Container(width: 80,child: Text(getLastMessageTime,style: TextStyle(color: constantColors.greyColor,fontSize: 10),maxLines: 1,),),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }
    });
  }

  Future checkIfJoined(BuildContext context,String chatRoomName,String chatRoomAdminUid)async{
    return FirebaseFirestore.instance.collection('chatrooms').doc(chatRoomName).collection('members').doc(FirebaseAuth.instance.currentUser!.uid).get().then((value) {
      hasMemberJoined=false;
      if(value.data()!['joined']!=null){
        hasMemberJoined=value.data()!['joined'];
        notifyListeners();
      }
      if(FirebaseAuth.instance.currentUser!.uid==chatRoomAdminUid){
        hasMemberJoined=true;
        notifyListeners();
      }
    });
  }

  askToJoin(BuildContext context,String roomName,String chatRoomPassword){
    return showDialog(context: context, builder: (context){
      return Container(
        color: constantColors.darkColor,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: new AlertDialog(
            backgroundColor: constantColors.blueGreyColor,
            title: Text('Join $roomName',style: TextStyle(color: constantColors.whiteColor,fontSize: 16,fontWeight: FontWeight.bold),),
            content:Container(
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

            actions: [
              MaterialButton(onPressed: (){Navigator.pushReplacement(context, PageTransition(child: HomePage(), type: PageTransitionType.rightToLeft));},child:Text('No',style: TextStyle(color: constantColors.whiteColor,fontSize: 14,decoration: TextDecoration.underline,decorationColor: constantColors.whiteColor,fontWeight: FontWeight.bold),),),
              MaterialButton(onPressed: ()async{
                        if(chatRoomPassword==passwordController.text){
                          FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get().then((value) {
                            FirebaseFirestore.instance.collection('chatrooms').doc(roomName).collection('members').doc(FirebaseAuth.instance.currentUser!.uid).set(
                                {
                                  'joined':true,
                                  'username':value['username'],
                                  'userimage':value['userimage'],
                                  'useruid':value['useruid'],
                                  'time':Timestamp.now(),
                                }).whenComplete(() => Navigator.pop(context));
                          });
                        }
              },child:Text('Yes',style: TextStyle(color: constantColors.whiteColor,fontSize: 14,decoration: TextDecoration.underline,decorationColor: constantColors.whiteColor,fontWeight: FontWeight.bold),),),

            ],
          ),
        ),
      );
    });
  }

  showStickers(BuildContext context,String chatRoomId){
    return showModalBottomSheet(context: context, builder: (context){
      return AnimatedContainer(
        duration: Duration(seconds: 1),
        curve: Curves.easeIn,
        height: MediaQuery.of(context).size.height*0.5,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(12),
            topLeft: Radius.circular(12),
          ),
          color: constantColors.blueGreyColor,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 105.0),
              child: Divider(
                thickness: 4,
                color: constantColors.whiteColor,
              ),
            ),
            SizedBox(
            height: MediaQuery.of(context).size.height*.1,
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: constantColors.blueColor)
                    ),
                    height: 30,
                    width: 30,
                    child: Image.asset('icons/sunflower.png'),
                  ),
                ),
                Container(
                  height: 50,
                  width: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: constantColors.whiteColor),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                    child: Text('Stickers',style: TextStyle(color: constantColors.blueColor,fontSize: 16,fontWeight: FontWeight.bold),),
                  ),
                ),
                Container(height: 0,width: 30,)
              ],
            ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height*.35,
              width: MediaQuery.of(context).size.width,
              child: StreamBuilder<QuerySnapshot>(
                  stream:FirebaseFirestore.instance.collection('chatroomicons').snapshots()
                  ,builder: (context,snapshot){
                    if(snapshot.connectionState==ConnectionState.waiting){
                      return Center(child: CircularProgressIndicator(),);
                    }
                    else{
                      return new GridView(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                      children: snapshot.data!.docs.map((DocumentSnapshot documentsnapshot){
                        return InkWell(
                          onTap: (){
                            print(documentsnapshot['image']);
                            print(chatRoomId);
                            sendStickers(context, documentsnapshot['image'], chatRoomId);},
                          child: Container(
                            height: 50,
                            width: 50,
                            child: CachedNetworkImage(imageUrl: documentsnapshot['image']),
                          ),
                        );
                      }).toList(),);
                    }
              }),
            ),
          ],
        ),
      );
    });
  }

  sendStickers(BuildContext context,String stickerImageUrl,String chatroomId)async{
   await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get().then((value) async {
      await FirebaseFirestore.instance.collection('chatrooms').doc(chatroomId).collection('messages').add(
          {
            'sticker':stickerImageUrl,
            'message':null,
            'username':value['username'],
            'userimage':value['userimage'],
            'useruid':value['useruid'],
            'time':Timestamp.now()
          });

    });
  }

  showLastMessage(BuildContext context,dynamic timeData){
    Timestamp time=timeData;
    DateTime dateTime=time.toDate();
    lastMessageTime=timeago.format(dateTime);
    print(lastMessageTime);
  }

  showSettings(BuildContext context,String chatRoomName,DocumentSnapshot documentSnapshot){
    return showModalBottomSheet(context: context, builder: (context){
      return AnimatedContainer(
        duration: Duration(seconds: 1),
        curve: Curves.easeIn,
        height: MediaQuery.of(context).size.height*0.25,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(12),
            topLeft: Radius.circular(12),
          ),
          color: constantColors.blueGreyColor,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 105.0),
              child: Divider(
                thickness: 4,
                color: constantColors.whiteColor,
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height*.05,
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Container(
                      height: 30,
                      width: 30,
                    ),
                  ),
                  Container(
                    height: 35,
                    width: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: constantColors.whiteColor),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Text('Settings',style: TextStyle(color: constantColors.blueColor,fontSize: 16,fontWeight: FontWeight.bold),),
                    ),
                  ),
                  Container(height: 0,width: 30,)
                ],
              ),
            ),
            InkWell(
              onTap: (){
                Navigator.pop(context);
              Provider.of<GroupMessageHelper>(context,listen: false).deleteTheRoom(context, chatRoomName);
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0,right: 8.0,top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Delete Room',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: constantColors.whiteColor),),
                    Icon(FontAwesomeIcons.trashAlt,color: constantColors.redColor,),
                  ],
                ),
              ),
            ),
            Divider(color: constantColors.greyColor,),
            InkWell(
              onTap: (){
                Navigator.pop(context);
                deleteUser(context, chatRoomName);
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0,right: 8.0,top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Delete User',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: constantColors.whiteColor),),
                    Icon(FontAwesomeIcons.userAstronaut,color: constantColors.yellowColor,),
                  ],
                ),
              ),
            ),
            Divider(color: constantColors.greyColor,),
          ],
        ),
      );
    });
  }

  leaveTheRoom(BuildContext context,String chatRoomName,String adminUid){
    return showDialog(context: context, builder:(context){
      return AlertDialog(
        backgroundColor: constantColors.blueGreyColor,
        title: Text('Leave $chatRoomName ?',style: TextStyle(color: constantColors.whiteColor,fontSize: 16,fontWeight: FontWeight.bold),),
        actions: [
          MaterialButton(onPressed: (){Navigator.pop(context);},child: Text('No',style: TextStyle(color: constantColors.whiteColor,fontSize: 16,fontWeight: FontWeight.bold),),),
          MaterialButton(onPressed: (){
            if(FirebaseAuth.instance.currentUser!.uid==adminUid){
              FirebaseFirestore.instance.collection('chatrooms').doc(chatRoomName).delete().whenComplete(() => Navigator.pushReplacement(context, PageTransition(child: HomePage(), type: PageTransitionType.leftToRight)));
            }
            else{
              FirebaseFirestore.instance.collection('chatrooms').doc(chatRoomName).collection('members').doc(FirebaseAuth.instance.currentUser!.uid).delete().whenComplete(() => Navigator.pushReplacement(context, PageTransition(child: HomePage(), type: PageTransitionType.leftToRight)));
            }
          },child: Text('Yes',style: TextStyle(color: constantColors.whiteColor,decoration: TextDecoration.underline,decorationColor: constantColors.whiteColor,fontSize: 16,fontWeight: FontWeight.bold),),),
        ],
      );
    });
  }

  deleteTheRoom(BuildContext context,String chatRoomName){
    return showDialog(context: context,
      builder:(context) {
     return AlertDialog(
        backgroundColor: constantColors.blueGreyColor,
        title: Text('Delete $chatRoomName Room ?',style: TextStyle(color: constantColors.whiteColor,fontSize: 16,fontWeight: FontWeight.bold),),
        actions: [
          MaterialButton(onPressed: (){Navigator.pop(context);},child: Text('No',style: TextStyle(color: constantColors.whiteColor,fontSize: 16,fontWeight: FontWeight.bold),),),
          MaterialButton(onPressed: (){
              FirebaseFirestore.instance.collection('chatrooms').doc(chatRoomName).delete().whenComplete(() => Navigator.pushReplacement(context, PageTransition(child: HomePage(), type: PageTransitionType.leftToRight)));
          },child: Text('Yes',style: TextStyle(color: constantColors.whiteColor,decoration: TextDecoration.underline,decorationColor: constantColors.whiteColor,fontSize: 16,fontWeight: FontWeight.bold),),),
        ],
      );
    }
    );

  }

  deleteUser(BuildContext context ,String chatRoomName){
    return showModalBottomSheet(context: context, builder:(context){
      return AnimatedContainer(
        duration: Duration(seconds: 1),
        curve: Curves.easeIn,
        height: MediaQuery.of(context).size.height*0.5,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(12),
            topLeft: Radius.circular(12),
          ),
          color: constantColors.blueGreyColor,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 105.0),
              child: Divider(
                thickness: 4,
                color: constantColors.whiteColor,
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height*.05,
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Container(
                      height: 30,
                      width: 30,
                    ),
                  ),
                  Container(
                    height: 35,
                    width: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: constantColors.whiteColor),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Text('Members',style: TextStyle(color: constantColors.blueColor,fontSize: 16,fontWeight: FontWeight.bold),),
                    ),
                  ),
                  Container(height: 0,width: 30,)
                ],
              ),
            ),
            SizedBox(height: 15,),
            Container(
              height: MediaQuery.of(context).size.height*.4,
              width: MediaQuery.of(context).size.width,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('chatrooms').doc(chatRoomName).collection('members').snapshots(),
                  builder: (context,snapshot){
                  if(snapshot.connectionState==ConnectionState.waiting){return Center(child: CircularProgressIndicator(),);}
                  else{
                    return new ListView(
                      scrollDirection: Axis.vertical,
                      children: snapshot.data!.docs.map((DocumentSnapshot documentSnapshot) {
                        return ListTile(
                          leading: CircleAvatar(radius: 25,backgroundColor: constantColors.transperant,backgroundImage: NetworkImage(documentSnapshot['userimage']),),
                          title: Text(documentSnapshot['username'],style: TextStyle(color: constantColors.whiteColor,fontSize: 16,fontWeight: FontWeight.bold),),
                          trailing: documentSnapshot['useruid']==FirebaseAuth.instance.currentUser!.uid?Padding(
                            padding: const EdgeInsets.only(right: 13.0),
                            child: Icon(FontAwesomeIcons.chessKing,color: constantColors.yellowColor),
                          ):IconButton(onPressed: (){
                            showDialog(context: context,
                                builder:(context) {
                                  return AlertDialog(
                                    backgroundColor: constantColors.blueGreyColor,
                                    title: Text('Delete ${documentSnapshot['username']} ?',style: TextStyle(color: constantColors.whiteColor,fontSize: 16,fontWeight: FontWeight.bold),),
                                    actions: [
                                      MaterialButton(onPressed: (){Navigator.pop(context);},child: Text('No',style: TextStyle(color: constantColors.whiteColor,fontSize: 16,fontWeight: FontWeight.bold),),),
                                      MaterialButton(color: constantColors.redColor,onPressed: (){
                                        FirebaseFirestore.instance.collection('chatrooms').doc(chatRoomName).collection('members').doc(documentSnapshot['useruid']).delete().whenComplete(() => Navigator.pop(context));
                                      },child: Text('Yes',style: TextStyle(color: constantColors.whiteColor,decoration: TextDecoration.underline,decorationColor: constantColors.whiteColor,fontSize: 16,fontWeight: FontWeight.bold),),),
                                    ],
                                  );
                                }
                            );
                          }, icon: Icon(FontAwesomeIcons.trashAlt,color: constantColors.redColor,)),
                        );
                      }).toList(),
                    );
                  }
                  }),
            )

          ],
        ),
      );
    });
  }

  deleteComment(BuildContext context,DocumentSnapshot snapshot,String roomName){
    return showDialog(context: context,
        builder:(context) {
          return AlertDialog(
            backgroundColor: constantColors.blueGreyColor,
            title: Text('Delete This Comment ?',style: TextStyle(color: constantColors.whiteColor,fontSize: 16,fontWeight: FontWeight.bold),),
            actions: [
              MaterialButton(onPressed: (){Navigator.pop(context);},child: Text('No',style: TextStyle(color: constantColors.whiteColor,fontSize: 16,fontWeight: FontWeight.bold),),),
              MaterialButton(onPressed: (){
                FirebaseFirestore.instance.collection('chatrooms').doc(roomName).collection('messages').doc(snapshot.id).delete().whenComplete(() => Navigator.pop(context));
              },child: Text('Yes',style: TextStyle(color: constantColors.whiteColor,decoration: TextDecoration.underline,decorationColor: constantColors.whiteColor,fontSize: 16,fontWeight: FontWeight.bold),),),
            ],
          );
        }
    );
  }

}