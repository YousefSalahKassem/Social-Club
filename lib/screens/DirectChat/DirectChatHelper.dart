
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:socialclub/Constants/Constantcolors.dart';
import 'package:socialclub/model/messageModel.dart';
import 'package:socialclub/services/FirebaseOperations.dart';
import 'package:timeago/timeago.dart'as timeago;


class DirectChatHelper with ChangeNotifier{
  ConstantColors constantColors=ConstantColors();
  String get getLastMessageTime=>lastMessageTime;
  late String lastMessageTime;

  showMessages(BuildContext context,AsyncSnapshot<DocumentSnapshot> documentSnapshot){
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('privatechats').orderBy('time',descending: true).snapshots()
        ,builder: (context,snapshot){
      if(snapshot.connectionState==ConnectionState.waiting)
        return Center(child: CircularProgressIndicator(),);
      else{
        return new ListView(
          reverse: true,
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            showLastMessage(context,document['time']);
            if((document['senderuid']==FirebaseAuth.instance.currentUser!.uid&&document['receiveruid']==documentSnapshot.data!['useruid'])||(document['senderuid']==documentSnapshot.data!['useruid']&&document['receiveruid']==FirebaseAuth.instance.currentUser!.uid))
            return Padding(
              padding: const EdgeInsets.only(left: 10.0,right: 10.0,top: 15,bottom: 10),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: document['message']!=null?MediaQuery.of(context).size.height*.13:MediaQuery.of(context).size.height*.23,
                child:
                InkWell(
                  onLongPress: (){
                    print(document.id);
                    deleteComment(context, document);
                  },
                  child: Stack(
                    alignment: FirebaseAuth.instance.currentUser!.uid==document['senderuid']?Alignment.centerRight:Alignment.centerLeft,
                    children: [
                      Container(
                        constraints: BoxConstraints(
                            maxHeight:  document['message']!=null?
                            MediaQuery.of(context).size.height*.15:MediaQuery.of(context).size.height*.4,
                            maxWidth:document['message']!=null? MediaQuery.of(context).size.width*.8:MediaQuery.of(context).size.height*.9
                        ),
                        decoration: BoxDecoration(
                            color: FirebaseAuth.instance.currentUser!.uid==document['senderuid']?constantColors.blueGreyColor.withOpacity(.8):constantColors.blueGreyColor,
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
                                    Text(FirebaseAuth.instance.currentUser!.uid==document['senderuid']?document['sendername']:documentSnapshot.data!['username'],style: TextStyle(color: constantColors.greenColor,fontSize: 12,fontWeight: FontWeight.bold),),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: document['message']!=null?Text(document['message'],style: TextStyle(color: constantColors.whiteColor,fontWeight: FontWeight.bold,fontSize: 14),)
                                    :Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Container(height: 100,width: 100,child: Image.network(document['sticker']),),
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
            else
            return Container(height: 0,width: 0,);
          }).toList(),
        );

      }
    });
  }

  showLastMessage(BuildContext context,dynamic timeData){
      Timestamp time=timeData;
      DateTime dateTime=time.toDate();
      lastMessageTime=timeago.format(dateTime);
      print(lastMessageTime);
    }

  sendStickers(BuildContext context,String stickerImageUrl,AsyncSnapshot<DocumentSnapshot>documentSnapshot)async{
    await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get().then((value) async {
      await FirebaseFirestore.instance.collection('privatechats').doc().set(
          {
            'senderuid':FirebaseAuth.instance.currentUser!.uid,
            'receiveruid':documentSnapshot.data!['useruid'],
            'receiverimage':documentSnapshot.data!['userimage'],
            'receivername':documentSnapshot.data!['username'],
            'message':null,
            'senderimage':value['userimage'],
            'sendername':value['username'],
            'sticker':stickerImageUrl,
            'time':Timestamp.now()
          });
    });
  }

  showStickers(BuildContext context,AsyncSnapshot<DocumentSnapshot>documentSnapshot ){
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
                          Navigator.pop(context);
                          sendStickers(context, documentsnapshot['image'],documentSnapshot);
                        },
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

  deleteComment(BuildContext context,DocumentSnapshot snapshot,){
    return showDialog(context: context,
        builder:(context) {
          return AlertDialog(
            backgroundColor: constantColors.blueGreyColor,
            title: Text('Delete This Message ?',style: TextStyle(color: constantColors.whiteColor,fontSize: 16,fontWeight: FontWeight.bold),),
            actions: [
              MaterialButton(onPressed: (){Navigator.pop(context);},child: Text('No',style: TextStyle(color: constantColors.whiteColor,fontSize: 16,fontWeight: FontWeight.bold),),),
              MaterialButton(onPressed: (){
                FirebaseFirestore.instance.collection('privatechats').doc(snapshot.id).delete().whenComplete(() => Navigator.pop(context));
              },child: Text('Yes',style: TextStyle(color: constantColors.whiteColor,decoration: TextDecoration.underline,decorationColor: constantColors.whiteColor,fontSize: 16,fontWeight: FontWeight.bold),),),
            ],
          );
        }
    );
  }

}