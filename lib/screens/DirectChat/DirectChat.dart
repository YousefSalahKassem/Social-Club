import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:socialclub/Constants/Constantcolors.dart';
import 'package:socialclub/model/messageModel.dart';
import 'package:socialclub/screens/DirectChat/DirectChatHelper.dart';
import 'package:socialclub/screens/HomePage/home_page.dart';
import 'package:socialclub/services/FirebaseOperations.dart';

class DirectChat extends StatefulWidget {
  late final AsyncSnapshot<DocumentSnapshot> documentSnapshot;

  DirectChat({required this.documentSnapshot});

  @override
  _DirectChatState createState() => _DirectChatState();
}

class _DirectChatState extends State<DirectChat> {
  ConstantColors constantColors=ConstantColors();
  TextEditingController messagingController=TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){Navigator.pushReplacement(context, PageTransition(child: HomePage(), type: PageTransitionType.rightToLeft));}, icon: Icon(Icons.arrow_back_ios_rounded,color: constantColors.whiteColor,)),
        backgroundColor: constantColors.blueGreyColor.withOpacity(.6),
        title: Container(
          width: MediaQuery.of(context).size.width*.5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(backgroundImage: NetworkImage(widget.documentSnapshot.data!['userimage']),),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.documentSnapshot.data!['username'],style: TextStyle(color: constantColors.whiteColor,fontWeight: FontWeight.bold,fontSize: 14),),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedContainer(child: Provider.of<DirectChatHelper>(context,listen: false).showMessages(context,widget.documentSnapshot),duration: Duration(seconds: 1),curve: Curves.bounceIn,height: MediaQuery.of(context).size.height*.82,width: MediaQuery.of(context).size.width),
              Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Container(child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(onTap: (){
                      Provider.of<DirectChatHelper>(context,listen: false).showStickers(context,widget.documentSnapshot);
                    },child: CircleAvatar(radius: 18,backgroundColor: constantColors.transperant,backgroundImage: AssetImage('icons/sunflower.png'),),),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Container(width: MediaQuery.of(context).size.width*.75,
                        child: TextField(
                          controller: messagingController,
                          style: TextStyle(color: constantColors.whiteColor,fontSize: 16,fontWeight: FontWeight.bold),
                          decoration: InputDecoration(hintText: 'Say Hi...',hintStyle: TextStyle(color: constantColors.lightBlueColor,fontWeight: FontWeight.bold,fontSize: 14)),
                        ),),
                    ),
                    FloatingActionButton(backgroundColor: constantColors.blueColor,onPressed: (){
                      FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get().then((value) {
                        Provider.of<FirebaseOperations>(context,listen: false).privateChat(context, {
                          'senderuid':FirebaseAuth.instance.currentUser!.uid,
                          'receiveruid':widget.documentSnapshot.data!['useruid'],
                          'message':messagingController.text,
                          'sendername':value['username'],
                          'receivername':widget.documentSnapshot.data!['username'],
                          'senderimage':value['userimage'],
                          'receiverimage':widget.documentSnapshot.data!['userimage'],
                          'sticker':null,
                          'time':Timestamp.now()
                        }).whenComplete(() => messagingController.clear());
                      });
                      }
                    ,child: Icon(Icons.send_sharp,color: constantColors.whiteColor,),)
                  ],),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
