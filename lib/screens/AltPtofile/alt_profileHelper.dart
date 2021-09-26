import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:socialclub/Constants/Constantcolors.dart';
import 'package:socialclub/screens/DirectChat/DirectChat.dart';
import 'package:socialclub/screens/HomePage/home_page.dart';
import 'package:socialclub/screens/Profile/profile.dart';
import 'package:socialclub/screens/Stories/Stories_widget.dart';
import 'package:socialclub/screens/postDetails/postDetails.dart';
import 'package:socialclub/services/FirebaseOperations.dart';
import 'package:socialclub/utils/postOptions.dart';

import 'alt_profile.dart';

class AltProfileHelper with ChangeNotifier {

  final StoryWidget storyWidget=StoryWidget();
  ConstantColors constantColors=ConstantColors();

  get element => _element;

  var _element;


  Widget headprofile(BuildContext context,AsyncSnapshot<DocumentSnapshot> snapshot,String userUid){
    return SizedBox(
      height: MediaQuery.of(context).size.height*.42,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top:16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  height: 250,
                  width: 190,
                  child: Column(
                    children: [
                      InkWell(
                        onTap: (){},
                        child: CircleAvatar(
                          backgroundColor: constantColors.transperant,
                          radius: 60,
                          backgroundImage: NetworkImage(snapshot.data!['userimage']==null?FirebaseAuth.instance.currentUser!.photoURL:snapshot.data!['userimage']),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top:1.0),
                        child: Text(snapshot.data!['username']==null?FirebaseAuth.instance.currentUser!.displayName:snapshot.data!['username'],style: TextStyle(color: constantColors.whiteColor,fontSize: 15,fontWeight: FontWeight.bold,),maxLines: 2,),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top:10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(EvaIcons.email,color: constantColors.greenColor,size: 20,),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(snapshot.data!['useremail']==null?FirebaseAuth.instance.currentUser!.email:snapshot.data!['useremail'],style: TextStyle(color: constantColors.whiteColor,fontSize: 10,fontWeight: FontWeight.bold,),maxLines: 2,overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 200,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom:120.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            InkWell(
                              onTap: () async {
                                final db = FirebaseFirestore.instance;
                                var result=await db.collection('users').get();
                                result.docs.forEach((res) {
                                  _element=res.id;
                                }
                                );
                                checkFollowersSheet(context, snapshot,element);
                                print(element);
                              },
                              child: Container(
                                decoration: BoxDecoration(color: constantColors.darkColor,borderRadius: BorderRadius.circular(15),),
                                height: 70,
                                width: 80,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('users').doc(snapshot.data!['useruid']).collection('followers').snapshots()
                                        ,builder: (context,snapshot){
                                          if(snapshot.connectionState==ConnectionState.waiting){return Center(child: CircularProgressIndicator(),);}
                                          else{return Text(snapshot.data!.docs.length.toString(),style: TextStyle(color: constantColors.whiteColor,fontWeight: FontWeight.bold,fontSize: 28),);
                                          }
                                        }),
                                    Text('Followers',style: TextStyle(color: constantColors.whiteColor,fontWeight: FontWeight.bold,fontSize: 12),),

                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 10,),
                            InkWell(
                              onTap: (){checkFollowingSheet(context, snapshot, userUid);},
                              child: Container(
                                decoration: BoxDecoration(color: constantColors.darkColor,borderRadius: BorderRadius.circular(15),),
                                height: 70,
                                width: 80,
                                child: Column(
                                  children: [
                                    StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('users').doc(snapshot.data!['useruid']).collection('following').snapshots()
                                        ,builder: (context,snapshot){
                                            if(snapshot.connectionState==ConnectionState.waiting){return Center(child: CircularProgressIndicator(),);}
                                            else{return Text(snapshot.data!.docs.length.toString(),style: TextStyle(color: constantColors.whiteColor,fontWeight: FontWeight.bold,fontSize: 28),);
                                        }
                                        }),
                                    Text('Following',style: TextStyle(color: constantColors.whiteColor,fontWeight: FontWeight.bold,fontSize: 12),),

                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

          ),
          Container(
            height: MediaQuery.of(context).size.height*.07,
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MaterialButton(onPressed: (){

                  FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get().then((doc) {
                    Provider.of<FirebaseOperations>(context, listen: false)
                        .followUsers(
                        userUid,
                        FirebaseAuth.instance.currentUser!.uid,
                        {
                          'username': doc['username'],
                          'userimage': doc['userimage'],
                          'useremail': doc['useremail'],
                          'useruid': doc['useruid'],
                          'time': Timestamp.now()
                        },
                        FirebaseAuth.instance.currentUser!.uid,
                        userUid,
                        {
                          'username': snapshot.data!['username'],
                          'useremail': snapshot.data!['useremail'],
                          'useruid': snapshot.data!['useruid'],
                          'userimage': snapshot.data!['userimage'],
                          'time': Timestamp.now()
                        })
                        .whenComplete(() => followedNotification(
                        context, snapshot.data!['username']));
                  });
                  },child:Text('Follow',style: TextStyle(color: constantColors.whiteColor,fontWeight: FontWeight.bold,fontSize: 16),) ,color: constantColors.blueColor,),
                MaterialButton(onPressed: (){Navigator.pushReplacement(context, PageTransition(child: DirectChat(documentSnapshot: snapshot), type: PageTransitionType.leftToRight));},child:Text('Message',style: TextStyle(color: constantColors.whiteColor,fontWeight: FontWeight.bold,fontSize: 16),) ,color: constantColors.blueColor,)

              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget divider(){
    return Center(
      child: SizedBox(
        height: 8,
        width: 350,
        child: Divider(
          color: constantColors.greyColor,
        ),
      ),
    );
  }

  Widget middleprofile(BuildContext context,dynamic snapshot,String userUid){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(FontAwesomeIcons.userAstronaut,color: constantColors.yellowColor,size: 16,),
                Padding(
                  padding: const EdgeInsets.only(left: 2.0),
                  child: Text('Highlights',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14,color: constantColors.whiteColor),),
                )
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height:MediaQuery.of(context).size.height*.1 ,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: constantColors.darkColor.withOpacity(.4),
              borderRadius: BorderRadius.circular(15),
            ),
            child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').doc(userUid).collection('highlights').snapshots(),
                builder: (context,snapshot){
                  if(snapshot.connectionState==ConnectionState.waiting){return Center(child: CircularProgressIndicator(),);}
                  else{
                    return new ListView(
                      scrollDirection: Axis.horizontal,
                      children: snapshot.data!.docs.map((DocumentSnapshot document) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: constantColors.transperant,
                                  backgroundImage: NetworkImage(document['cover']),
                                ),
                                Text(document['title'],style: TextStyle(color: constantColors.greenColor,fontWeight: FontWeight.bold,fontSize: 12),),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }
                }),

          ),
        ),
      ],
    );
  }

  Widget footerProfile(BuildContext context,dynamic snapshot){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: StreamBuilder<QuerySnapshot>(
          stream:FirebaseFirestore.instance.
          collection('posts').
          where('useruid',isEqualTo: snapshot.data['useruid']).snapshots(),
          builder: (context, snapshot){
            if(snapshot.connectionState == ConnectionState.waiting){
              return Center(
                child: CircularProgressIndicator(),
              );
            }else{
              return new GridView(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  children: snapshot.data!.docs.map((DocumentSnapshot snapshot){
                    return InkWell(

                      onTap: (){
                        Navigator.pushReplacement(context, PageTransition(child: PostDetails(documentSnapshot: snapshot), type: PageTransitionType.leftToRight));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          height: MediaQuery.of(context).size.height * .5,
                          width: MediaQuery.of(context).size.width,
                          child: FittedBox(
                            child: CachedNetworkImage(imageUrl: snapshot['postimage']),
                          ),
                        ),
                      ),
                    );
                  }).toList());
            }
          },
        ),
        height: MediaQuery.of(context).size.height*.4,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: constantColors.darkColor.withOpacity(.4),
            borderRadius: BorderRadius.circular(5)
        ),
      ),
    );
  }

  followedNotification(BuildContext context,String name){
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
              Text('Followed $name',style: TextStyle(color: constantColors.whiteColor,fontWeight: FontWeight.bold,fontSize: 16),),
            ],
          ),
        ),
      );
    });
  }

  checkFollowersSheet(BuildContext context,dynamic snapshot,String userid){
    return showModalBottomSheet(context: context, builder:(context){
      return Container(
        height: MediaQuery.of(context).size.height*.4,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(color: constantColors.blueGreyColor,borderRadius: BorderRadius.circular(12)),
        child:StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('users').doc(snapshot.data!['useruid']).collection('followers').snapshots()
            ,builder: (context,snapshot){
              if(snapshot.connectionState==ConnectionState.waiting){return Center(child: CircularProgressIndicator(),);}
              else{
                return new ListView(
                  children: snapshot.data!.docs.map((DocumentSnapshot documentSnapshot)  {
                    return Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: ListTile(
                          onTap: (){
                            if(documentSnapshot['useruid']==FirebaseAuth.instance.currentUser!.uid){Navigator.pushReplacement(context, PageTransition(child: Profile(), type: PageTransitionType.leftToRight));}
                            else Navigator.pushReplacement(context, PageTransition(child: AltProfile(userUid: documentSnapshot['useruid']), type: PageTransitionType.leftToRight));},
                          leading: CircleAvatar(backgroundColor: constantColors.darkColor,backgroundImage: NetworkImage(documentSnapshot['userimage']),),
                          title: Text(documentSnapshot['username'],style: TextStyle(color: constantColors.whiteColor,fontWeight: FontWeight.bold,fontSize: 18),),
                          subtitle: Text(documentSnapshot['useremail'],style: TextStyle(color: constantColors.yellowColor,fontWeight: FontWeight.bold,fontSize: 14),),
                          trailing: documentSnapshot['useruid']==FirebaseAuth.instance.currentUser!.uid?Container(height: 0,width: 0,):MaterialButton(onPressed: (){Navigator.pushReplacement(context, PageTransition(child: AltProfile(userUid: documentSnapshot['useruid']), type: PageTransitionType.leftToRight));},child: Text('View',style: TextStyle(color: constantColors.whiteColor,fontSize: 16,fontWeight: FontWeight.bold),),color: constantColors.blueColor,)
                        )
                    );
                  }).toList(),
                );
              }
            }),
      );
    } );
  }

  checkFollowingSheet(BuildContext context,dynamic snapshot,String useruid){
    return showModalBottomSheet(context: context, builder:(context){
      return Container(
        height: MediaQuery.of(context).size.height*.4,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(color: constantColors.blueGreyColor,borderRadius: BorderRadius.circular(12)),
        child:StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('users').doc(useruid).collection('following').snapshots()
            ,builder: (context,snapshot){
              if(snapshot.connectionState==ConnectionState.waiting){return Center(child: CircularProgressIndicator(),);}
              else{
                return new ListView(
                  children: snapshot.data!.docs.map((DocumentSnapshot documentSnapshot){
                    return Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: ListTile(
                          onTap: (){
                            if(documentSnapshot['useruid']==FirebaseAuth.instance.currentUser!.uid){Navigator.pushReplacement(context, PageTransition(child: Profile(), type: PageTransitionType.leftToRight));}
                            else Navigator.pushReplacement(context, PageTransition(child: AltProfile(userUid: documentSnapshot['useruid']), type: PageTransitionType.leftToRight));},
                          leading: CircleAvatar(backgroundColor: constantColors.darkColor,backgroundImage: NetworkImage(documentSnapshot['userimage']),),
                          title: Text(documentSnapshot['username'],style: TextStyle(color: constantColors.whiteColor,fontWeight: FontWeight.bold,fontSize: 18),),
                          subtitle: Text(documentSnapshot['useremail'],style: TextStyle(color: constantColors.yellowColor,fontWeight: FontWeight.bold,fontSize: 14),),
                          trailing:  documentSnapshot['useruid']==FirebaseAuth.instance.currentUser!.uid?Container(height: 0,width: 0,):MaterialButton(onPressed: (){Navigator.pushReplacement(context, PageTransition(child: AltProfile(userUid: documentSnapshot['useruid']), type: PageTransitionType.leftToRight));},child: Text('View',style: TextStyle(color: constantColors.whiteColor,fontSize: 16,fontWeight: FontWeight.bold),),color: constantColors.blueColor,),
                        )
                    );
                  }).toList(),
                );
              }
            }),
      );
    } );
  }

  showPostDetails(BuildContext context,DocumentSnapshot snapshot){
    return showModalBottomSheet(context: context, builder: (context){
      return Container(
        height: MediaQuery.of(context).size.height*.6,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(color: constantColors.darkColor,borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            SizedBox(height: 10,),
            Container(
              height: MediaQuery.of(context).size.height*.4,
              width: MediaQuery.of(context).size.width,
              child: FittedBox(
                child: CachedNetworkImage(imageUrl: snapshot['postimage']),
              ),
            ),
            SizedBox(height: 10,),
            Text(snapshot['caption'],style: TextStyle(color: constantColors.whiteColor,fontWeight: FontWeight.bold,fontSize: 16),),
            SizedBox(height: 10,),
            Container(
              child:  Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [InkWell(
                        onLongPress: (){Provider.of<PostOptions>(context,listen: false).showLikes(context,snapshot['caption']);},
                        onTap: (){Provider.of<PostOptions>(context,listen: false).addLike(context, snapshot['caption'], FirebaseAuth.instance.currentUser!.uid);},
                        child: Icon(FontAwesomeIcons.heart,color: constantColors.redColor,size: 22,),
                      ),
                        StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('posts').doc(snapshot['caption']).collection('likes').snapshots(),
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [InkWell(
                        onTap: (){Provider.of<PostOptions>(context,listen: false).showCommentSheet(context, snapshot, snapshot['caption']);},
                        child: Icon(FontAwesomeIcons.comment,color: constantColors.blueColor,size: 22,),
                      ),
                        StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('posts').doc(snapshot['caption']).collection('comments').snapshots(),
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [InkWell(
                        onLongPress: (){Provider.of<PostOptions>(context,listen: false).showRewardsSheet(context,snapshot['caption']);},
                        onTap: (){Provider.of<PostOptions>(context,listen: false).showRewards(context,snapshot['caption']);},
                        child: Icon(FontAwesomeIcons.award,color: constantColors.yellowColor,size: 22,),
                      ),
                        StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('posts').doc(snapshot['caption']).collection('awards').snapshots(),
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
                  FirebaseAuth.instance.currentUser!.uid==snapshot['useruid'] ? IconButton(onPressed: (){Provider.of<PostOptions>(context,listen: false).showPostOptions(context,snapshot['caption']);}, icon: Icon(EvaIcons.moreVertical,color: constantColors.whiteColor,))
                      :Container(width: 0, height: 0)
                ],
              ),)
          ],
        ),
      );
    });
  }

}