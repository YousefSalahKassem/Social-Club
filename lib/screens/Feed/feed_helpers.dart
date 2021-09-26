import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:socialclub/Constants/Constantcolors.dart';
import 'package:socialclub/screens/AltPtofile/alt_profile.dart';
import 'package:socialclub/screens/HomePage/home_page.dart';
import 'package:socialclub/screens/Profile/ProfileHelpers.dart';
import 'package:socialclub/screens/Profile/profile.dart';
import 'package:socialclub/screens/Stories/Stories.dart';
import 'package:socialclub/utils/postOptions.dart';
  
class FeedHelpers with ChangeNotifier{
  ConstantColors constantColors=ConstantColors();
  Widget feedBody(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('stories').snapshots(),
                  builder: (context,snapshot){
                    if(snapshot.connectionState==ConnectionState.waiting){return Center(child: CircularProgressIndicator(),);}
                    else{
                      return ListView(
                        scrollDirection: Axis.horizontal,
                        children: snapshot.data!.docs.map((DocumentSnapshot document){
                          return InkWell(
                            onTap: (){
                              Navigator.pushReplacement(context, PageTransition(child: Stories(documentSnapshot: document), type: PageTransitionType.leftToRight));
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Container(
                                height: 30,
                                width: 50,
                                decoration: BoxDecoration(shape: BoxShape.circle,border: Border.all(color: constantColors.blueColor,width: 2)),
                                child: CircleAvatar(radius: 25,backgroundImage: NetworkImage(document['userimage']),)
                              ),
                            )
                          );
                        }).toList(),
                      );
                    }
                  }),
              height: MediaQuery.of(context).size.height*.06,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(color: constantColors.blueGreyColor,borderRadius: BorderRadius.circular(12)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Container(
              height: MediaQuery.of(context).size.height*.8,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: constantColors.blueGreyColor,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(18),topRight: Radius.circular(18)),
              ),
              child: StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('posts').orderBy('time',descending: true).snapshots()
                  , builder:(context,snapshot){
                if(snapshot.connectionState==ConnectionState.waiting){return Center(child: SizedBox(height: 500,width: 400,child: CircularProgressIndicator(),),);
                }
                else{return loadposts(context, snapshot);}
              } ),
            ),
          ),
        ],
      ),
    );
  }

  Widget loadposts(BuildContext context,AsyncSnapshot<QuerySnapshot>snapshot){
    return ListView(
      children: snapshot.data!.docs.map((DocumentSnapshot documentSnapshot) {
        Provider.of<PostOptions>(context,listen: false).showTimeAgo(documentSnapshot['time']);
        return Container(
          height: MediaQuery.of(context).size.height*.65,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0,left: 8),
                child: Row(children: [
                  InkWell(
                    onTap: (){
                      if(documentSnapshot['useruid']!=FirebaseAuth.instance.currentUser!.uid){
                        Navigator.pushReplacement(context, PageTransition(child: AltProfile(userUid: documentSnapshot['useruid']), type: PageTransitionType.leftToRight));
                      }
                      else
                        {
                          Navigator.pushReplacement(context, PageTransition(child: Profile(), type: PageTransitionType.leftToRight));

                        }
                    },
                    child: CircleAvatar(
                      backgroundColor: constantColors.blueGreyColor,
                      radius: 20,
                      backgroundImage: NetworkImage(documentSnapshot['userimage']),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Container(
                      width:MediaQuery.of(context).size.width*.6 ,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Directionality(
                              textDirection: TextDirection.rtl,
                              child: RichText(text: TextSpan(text: documentSnapshot['username'],
                                  style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: constantColors.blueColor,),
                                  children: <TextSpan>[
                                    TextSpan(text: ' ,${Provider.of<PostOptions>(context,listen: false).getImageTimePosted.toString()}',style: TextStyle(color: constantColors.lightColor.withOpacity(.8)))
                                  ])),
                            ),
                          ),
                          Container(
                            child: Text(documentSnapshot['caption'],style: TextStyle(color: constantColors.greenColor,fontWeight: FontWeight.bold,fontSize: 16),),
                          ),
                        ],
                      ),
                    ),
                  ),
                    Container(
                      width: MediaQuery.of(context).size.width*.2,
                      height: MediaQuery.of(context).size.height*.05,
                      child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection('posts').doc(documentSnapshot['caption']).collection('awards').snapshots(),
                          builder: (context,snapshot){
                            if(snapshot.connectionState==ConnectionState.waiting){
                              return Center(child: CircularProgressIndicator(),);
                            }
                            else{
                              return new ListView(
                                scrollDirection: Axis.horizontal,
                                children: snapshot.data!.docs.map((DocumentSnapshot documentSnapshot){
                                  return Container(
                                    height: 30,
                                    width: 30,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Image.network(documentSnapshot['award']),
                                    ),
                                  );
                                }).toList(),
                              );
                            }
                          }),
                    ),
                ],),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Container(
                  height: MediaQuery.of(context).size.height*.46,
                  width: MediaQuery.of(context).size.width,
                  child: FittedBox(

                    child: CachedNetworkImage(imageUrl: documentSnapshot['postimage'])
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0,left: 30),
                child:
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: 80,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [InkWell(
                          onLongPress: (){Provider.of<PostOptions>(context,listen: false).showLikes(context,documentSnapshot['caption']);},
                          onTap: (){Provider.of<PostOptions>(context,listen: false).addLike(context, documentSnapshot['caption'], FirebaseAuth.instance.currentUser!.uid);},
                          child: Icon(FontAwesomeIcons.heart,color: constantColors.redColor,size: 22,),
                        ),
                        StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('posts').doc(documentSnapshot['caption']).collection('likes').snapshots(),
                            builder: (context,snapshot){
                          if(snapshot.connectionState==ConnectionState.waiting){
                             return Center(child: CircularProgressIndicator(),);
                          }
                          else{
                            return Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(snapshot.data!.docs.length.toString(),style: TextStyle(color: constantColors.whiteColor,fontWeight: FontWeight.bold,fontSize: 18),),
                            );
                          }
                            })],

                      ),
                    ),
                    Container(
                      width: 80,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [InkWell(
                          onTap: (){Provider.of<PostOptions>(context,listen: false).showCommentSheet(context, documentSnapshot, documentSnapshot['caption']);},
                          child: Icon(FontAwesomeIcons.comment,color: constantColors.blueColor,size: 22,),
                        ),
                          StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('posts').doc(documentSnapshot['caption']).collection('comments').snapshots(),
                              builder: (context,snapshot){
                                if(snapshot.connectionState==ConnectionState.waiting){
                                  return Center(child: CircularProgressIndicator(),);
                                }
                                else{
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(snapshot.data!.docs.length.toString(),style: TextStyle(color: constantColors.whiteColor,fontWeight: FontWeight.bold,fontSize: 18),),
                                  );
                                }
                              })],
                      ),
                    ),
                    Container(
                      width: 80,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [InkWell(
                          onLongPress: (){Provider.of<PostOptions>(context,listen: false).showRewardsSheet(context,documentSnapshot['caption']);},
                          onTap: (){Provider.of<PostOptions>(context,listen: false).showRewards(context,documentSnapshot['caption']);},
                          child: Icon(FontAwesomeIcons.award,color: constantColors.yellowColor,size: 22,),
                        ),
                          StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('posts').doc(documentSnapshot['caption']).collection('awards').snapshots(),
                              builder: (context,snapshot){
                                if(snapshot.connectionState==ConnectionState.waiting){
                                  return Center(child: CircularProgressIndicator(),);
                                }
                                else{
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(snapshot.data!.docs.length.toString(),style: TextStyle(color: constantColors.whiteColor,fontWeight: FontWeight.bold,fontSize: 18),),
                                  );
                                }
                              })],

                      ),
                    ),
                    Spacer(),
                    FirebaseAuth.instance.currentUser!.uid==documentSnapshot['useruid'] ? IconButton(onPressed: (){Provider.of<PostOptions>(context,listen: false).showPostOptions(context,documentSnapshot['caption']);}, icon: Icon(EvaIcons.moreVertical,color: constantColors.whiteColor,))
                        :Container(width: 0, height: 0)
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

}