import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firestore_search/firestore_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:socialclub/Constants/Constantcolors.dart';
import 'package:socialclub/screens/AltPtofile/alt_profile.dart';
import 'package:socialclub/screens/Feed/feed_helpers.dart';
import 'package:socialclub/services/FirebaseOperations.dart';
import 'package:socialclub/utils/Uploadpost.dart';

class Feed extends StatefulWidget {
  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> {
ConstantColors constantColors=ConstantColors();
TextEditingController searchController =TextEditingController();
String search='';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Provider.of<FeedHelpers>(context,listen: false).feedBody(context),
        appBar: AppBar(
        leading:IconButton(onPressed: (){
           showModalBottomSheet(isScrollControlled: true,context: context, builder: (context){
            return Padding(
              padding:  EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: AnimatedContainer(
                duration: Duration(seconds: 1),
                curve: Curves.easeIn,
                height: MediaQuery.of(context).size.height*0.45,
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
                     padding: const EdgeInsets.symmetric(horizontal: 150.0),
                     child: Divider(
                       thickness: 4,
                       color: constantColors.whiteColor,
                     ),
                   ),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                     children: [
                       Container(
                         width: MediaQuery.of(context).size.width*.7,
                         child: TextField(controller: searchController,
                           onChanged: (value){
                             setState(() {
                               search=value;
                             });
                           },
                           textCapitalization: TextCapitalization.words,
                           style: TextStyle(
                               color: constantColors.whiteColor,
                               fontSize: 16,
                               fontWeight: FontWeight.bold
                           ),
                           decoration: InputDecoration(
                             hintText: 'Search',
                             hintStyle:TextStyle(
                                 color: constantColors.greyColor,
                                 fontSize: 16,
                                 fontWeight: FontWeight.bold
                             ),
                           ),
                         ),
                       ),
                       FloatingActionButton( backgroundColor: constantColors.blueColor,
                           child: Icon(FontAwesomeIcons.searchengin,color: constantColors.whiteColor),onPressed: ()async{

                           }),
                     ],
                   ),
                   SizedBox(
                     height: MediaQuery.of(context).size.height*.35,
                     width: MediaQuery.of(context).size.width,
                     child: StreamBuilder<QuerySnapshot>(
                         stream:(search==null||search.trim()=='')?
                             FirebaseFirestore.instance.collection('users').snapshots():
                         FirebaseFirestore.instance.collection('users').where('username',isGreaterThanOrEqualTo: search).where('username',isLessThan: search + 'z').snapshots()
                         ,builder: (context,snapshot){
                       if(snapshot.connectionState==ConnectionState.waiting){
                         return Center(child: CircularProgressIndicator(),);
                       }
                       else{
                         return new ListView(

                           children: snapshot.data!.docs.map((DocumentSnapshot document){

                            return Padding(
                               padding: const EdgeInsets.only(top: 8.0),
                               child: document['useruid']!=FirebaseAuth.instance.currentUser!.uid?ListTile(
                                 leading: CircleAvatar(
                                   backgroundColor: constantColors.transperant,
                                   radius: 25,
                                   backgroundImage: NetworkImage(document['userimage']),
                                 ),
                                 title: Text(document['username'],style: TextStyle(color: constantColors.whiteColor,fontSize: 16,fontWeight: FontWeight.bold),),
                                 subtitle: Text(document['useremail'],style: TextStyle(color: constantColors.greenColor,fontSize: 13,fontWeight: FontWeight.bold),),
                                 trailing: MaterialButton(color: constantColors.blueColor,onPressed: (){Navigator.pushReplacement(context, PageTransition(child: AltProfile(userUid: document['useruid']), type: PageTransitionType.leftToRight));},child: Text('View',style: TextStyle(color: constantColors.whiteColor,fontSize: 16,fontWeight: FontWeight.bold),),),
                               ):Container(height: 0,width: 0,),
                             );
                           }).toList(),
                         );
                       }
                     }),
                   ),
                 ],
                ),
              ),
            );
          });
        },
            icon: Icon(FontAwesomeIcons.searchengin,color: constantColors.lightBlueColor,)) ,
        backgroundColor: constantColors.blueGreyColor.withOpacity(0.6),
        centerTitle: true,
        actions: [
            IconButton(onPressed: (){Provider.of<UploadPost>(context,listen: false).selectPostImage(context);},
    icon: Icon(Icons.camera_enhance_rounded,color: constantColors.greenColor,))
         ], title: RichText(text: TextSpan(
                 text: 'Social',
                  style: TextStyle(
    fontFamily: 'Poppins',
    color: constantColors.whiteColor,
    fontWeight: FontWeight.bold,
    fontSize: 20,
    ),
                   children: <TextSpan>[
                    TextSpan(
    text: 'Feed',
    style: TextStyle(
    fontFamily: 'Poppins',
    color: constantColors.blueColor,
    fontWeight: FontWeight.bold,
    fontSize: 20,
    ),
    )
    ]
    )),    ));
  }
}
