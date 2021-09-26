
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
import 'package:socialclub/screens/Profile/profile.dart';
import 'package:socialclub/services/FirebaseOperations.dart';
import 'package:timeago/timeago.dart' as timeago;
class PostOptions with ChangeNotifier{

  ConstantColors constantColors=ConstantColors();
  TextEditingController commentController=TextEditingController();
  TextEditingController editCommentController=TextEditingController();
  TextEditingController addCommentController=TextEditingController();
  late String imageTimePosted;
  String get getImageTimePosted=>imageTimePosted;

  Future addLike(BuildContext context,String postId,String subDocId)async{
    return  FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get().then((value) {
      FirebaseFirestore.instance.collection('posts').doc(postId).collection('likes').doc(subDocId).set(
        {
          'likes':FieldValue.increment(1),
          'username':value['username'],
          'useruid':FirebaseAuth.instance.currentUser!.uid,
          'userimage':value['userimage'],
          'useremail':FirebaseAuth.instance.currentUser!.email,
          'time':Timestamp.now()
        });});

  }

  Future addComment(String postId,String comment,BuildContext context)async{
    await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get().then((value) {
      FirebaseFirestore.instance.collection('posts').doc(postId).collection('comments').doc(comment).set(
          {
            'comment':comment,
            'username':value['username'],
            'useruid':FirebaseAuth.instance.currentUser!.uid,
            'userimage':value['userimage'],
            'useremail':FirebaseAuth.instance.currentUser!.email,
            'time':Timestamp.now()
          });
    });
  }

  showRewards(BuildContext context,String postId){
    return showModalBottomSheet(context: context, builder: (context){
      return Container(
        height: MediaQuery.of(context).size.height*.2,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: constantColors.blueGreyColor,
          borderRadius: BorderRadius.only(topRight: Radius.circular(12),topLeft: Radius.circular(12)),
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
            Container(
              width: 100,
              decoration: BoxDecoration(
                border: Border.all(color: constantColors.whiteColor),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Center(
                child: Text('Rewards',style: TextStyle(color: constantColors.blueColor,fontSize: 16,fontWeight: FontWeight.bold),),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Container(
                height: MediaQuery.of(context).size.height*.1,
                width: MediaQuery.of(context).size.width,
                child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('awards').snapshots(),
                    builder: (context,snapshot){
                      if(snapshot.connectionState==ConnectionState.waiting){
                        return Center(child: CircularProgressIndicator(),);
                      }
                      else{
                        return new ListView(
                          scrollDirection: Axis.horizontal,
                          children: snapshot.data!.docs.map((DocumentSnapshot snapshot) {
                            return InkWell(
                              onTap: ()async{
                                FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get().then((value) async {
                                  await Provider.of<FirebaseOperations>(context,listen: false).addAward(postId,
                                      {
                                        'username':value['username'],
                                        'userimage':value['userimage'],
                                        'useruid':FirebaseAuth.instance.currentUser!.uid,
                                        'time':Timestamp.now(),
                                        'award':snapshot['image']
                                      });
                                });

                              },
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  child: CachedNetworkImage(imageUrl: snapshot['image']),
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
        ),
      );
    });
  }

  showLikes(BuildContext context,String postId){
    return showModalBottomSheet(context: context, builder: (context){
      return Container(
        height: MediaQuery.of(context).size.height*.5,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(color: constantColors.blueGreyColor,borderRadius: BorderRadius.only(topLeft: Radius.circular(12),topRight: Radius.circular(12))),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 150.0),
              child: Divider(
                thickness: 4,
                color: constantColors.whiteColor,
              ),
            ),
            Container(
              width: 100,
              decoration: BoxDecoration(
                border: Border.all(color: constantColors.whiteColor),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Center(
                child: Text('Likes',style: TextStyle(color: constantColors.blueColor,fontSize: 16,fontWeight: FontWeight.bold),),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height*.2,
              width: 400,
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('posts').doc(postId).collection('likes').snapshots(),
                  builder: (context,snapshot){
                    if(snapshot.connectionState==ConnectionState.waiting){
                      return Center(child: CircularProgressIndicator(),);
                    }
                    else{
                      return new ListView(
                        children: snapshot.data!.docs.map((DocumentSnapshot snapshot) {
                          return ListTile(
                            leading: InkWell(
                              onTap: (){
                                if(snapshot['useruid']==FirebaseAuth.instance.currentUser!.uid){Navigator.pushReplacement(context, PageTransition(child: Profile(), type: PageTransitionType.leftToRight));
                                }
                                else
                                Navigator.pushReplacement(context, PageTransition(child: AltProfile(userUid: snapshot['useruid']), type: PageTransitionType.leftToRight));
                              },
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(snapshot['userimage']),
                            ),
                            ),
                            title: Text(snapshot['username'],style: TextStyle(color: constantColors.blueColor,fontWeight: FontWeight.bold,fontSize: 16),),
                            subtitle: Text(snapshot['useremail'],style: TextStyle(color: constantColors.whiteColor,fontWeight: FontWeight.bold,fontSize: 12),),
                            trailing: FirebaseAuth.instance.currentUser!.uid==snapshot['useruid']?Container(width: 0,height: 0,):MaterialButton(onPressed: () {  },color: constantColors.blueColor,
                              child: Text('Follow',style: TextStyle(color: constantColors.whiteColor,fontWeight: FontWeight.bold,fontSize: 16),),),
                          );
                        }).toList(),
                      );
                    }
                  }),
            ),
          ],
        ),
      );
    });
  }
  
  Future addLikeOnComment(BuildContext context,DocumentSnapshot documentSnapshot,String postId)async{
    return FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get().then((value){
      FirebaseFirestore.instance.collection('posts').doc(postId).collection('comments').doc(documentSnapshot.id).collection('likeoncomment').doc(FirebaseAuth.instance.currentUser!.uid).set({
        'username':value['username'],
        'useruid':FirebaseAuth.instance.currentUser!.uid,
        'userimage':value['userimage'],
        'useremail':value['useremail'],
        'time':Timestamp.now(),
        'likes':FieldValue.increment(1),

      });
    });
  }

  showLikesOnComment(BuildContext context,String postId,DocumentSnapshot documentSnapshot){
    return showModalBottomSheet(context: context, builder: (context){
      return Container(
        height: MediaQuery.of(context).size.height*.5,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(color: constantColors.blueGreyColor,borderRadius: BorderRadius.only(topLeft: Radius.circular(12),topRight: Radius.circular(12))),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 150.0),
              child: Divider(
                thickness: 4,
                color: constantColors.whiteColor,
              ),
            ),
            Container(
              width: 100,
              decoration: BoxDecoration(
                border: Border.all(color: constantColors.whiteColor),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Center(
                child: Text('Likes',style: TextStyle(color: constantColors.blueColor,fontSize: 16,fontWeight: FontWeight.bold),),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height*.2,
              width: 400,
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('posts').doc(postId).collection('comments').doc(documentSnapshot.id).collection('likeoncomment').snapshots(),
                  builder: (context,snapshot){
                    if(snapshot.connectionState==ConnectionState.waiting){
                      return Center(child: CircularProgressIndicator(),);
                    }
                    else{
                      return new ListView(
                        children: snapshot.data!.docs.map((DocumentSnapshot snapshot) {
                          return ListTile(
                            leading: InkWell(
                              onTap: (){
                                if(snapshot['useruid']==FirebaseAuth.instance.currentUser!.uid){Navigator.pushReplacement(context, PageTransition(child: Profile(), type: PageTransitionType.leftToRight));
                                }
                                else
                                  Navigator.pushReplacement(context, PageTransition(child: AltProfile(userUid: snapshot['useruid']), type: PageTransitionType.leftToRight));
                              },
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(snapshot['userimage']),
                              ),
                            ),
                            title: Text(snapshot['username'],style: TextStyle(color: constantColors.blueColor,fontWeight: FontWeight.bold,fontSize: 16),),
                            subtitle: Text(snapshot['useremail'],style: TextStyle(color: constantColors.whiteColor,fontWeight: FontWeight.bold,fontSize: 12),),
                            trailing: FirebaseAuth.instance.currentUser!.uid==snapshot['useruid']?Container(width: 0,height: 0,):MaterialButton(onPressed: () {  },color: constantColors.blueColor,
                              child: Text('Follow',style: TextStyle(color: constantColors.whiteColor,fontWeight: FontWeight.bold,fontSize: 16),),),
                          );
                        }).toList(),
                      );
                    }
                  }),
            ),
          ],
        ),
      );
    });
  }

  Future addCommentInComment (BuildContext context,String postId,DocumentSnapshot documentSnapshot)async{
    return FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get().then((value){
      FirebaseFirestore.instance.collection('posts').doc(postId).collection('comments').doc(documentSnapshot.id).collection('commentoncomment').doc().set({
        'username':value['username'],
        'useruid':FirebaseAuth.instance.currentUser!.uid,
        'userimage':value['userimage'],
        'useremail':value['useremail'],
        'time':Timestamp.now(),
        'comment':addCommentController.text,
      });
    });
  }

  showCommentInComment(BuildContext context,DocumentSnapshot documentSnapshot,String postId,String name,String image){
    return showModalBottomSheet(isScrollControlled: true,context: context, builder: (context){
      return Padding(
        padding:  EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          height: MediaQuery.of(context).size.height*.65,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 850.0),
                child: Divider(
                  thickness: 1,
                  color: constantColors.whiteColor,
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height*.15,
                width: MediaQuery.of(context).size.width,
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          CircleAvatar(radius: 15,backgroundColor: constantColors.transperant,backgroundImage: NetworkImage(image),),
                          SizedBox(width:10 ,),
                          Text(name,style: TextStyle(color: constantColors.whiteColor,fontWeight: FontWeight.bold,fontSize: 18),),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(onPressed: (){},
                            icon: Icon(Icons.arrow_forward_ios_outlined,color: constantColors.blueColor,size: 12,)),
                        Container(width: MediaQuery.of(context).size.width*.7,child: Text(documentSnapshot['comment'],style: TextStyle(color: constantColors.whiteColor,fontWeight: FontWeight.bold,fontSize: 18),)),
                      ],
                    ),
                    Center(
                      child: SizedBox(
                        height: 8,
                        width: 350,
                        child: Divider(
                          color: constantColors.greyColor,
                        ),
                      ),
                    )
                  ],
                ) ,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height*.4,
                child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('posts').doc(postId).collection('comments').doc(documentSnapshot.id).collection('commentoncomment').orderBy('time').snapshots(),
                    builder: (context,snapshot){
                      if(snapshot.connectionState==ConnectionState.waiting)
                      {
                        return Center(child: CircularProgressIndicator(),);
                      }
                      else{
                        return new ListView(
                          children: snapshot.data!.docs.map((DocumentSnapshot documentSnapshot){
                            return Container(
                              height: MediaQuery.of(context).size.height*.15,
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: InkWell(
                                          onTap: (){
                                            if(documentSnapshot['useruid']==FirebaseAuth.instance.currentUser!.uid){Navigator.pushReplacement(context, PageTransition(child: Profile(), type: PageTransitionType.leftToRight));
                                            }
                                            else
                                              Navigator.pushReplacement(context, PageTransition(child: AltProfile(userUid: documentSnapshot['useruid']), type: PageTransitionType.leftToRight));
                                          },
                                          child: CircleAvatar(
                                            backgroundColor: constantColors.darkColor,
                                            radius: 15,
                                            backgroundImage: NetworkImage(documentSnapshot['userimage']),
                                          ) ,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: Container(
                                          child: Text(documentSnapshot['username'],style: TextStyle(color: constantColors.whiteColor,fontWeight: FontWeight.bold,fontSize: 18),),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Row(
                                      children: [
                                        IconButton(onPressed: (){},
                                            icon: Icon(Icons.arrow_forward_ios_outlined,color: constantColors.blueColor,size: 12,)),
                                        Container(
                                          width: MediaQuery.of(context).size.width*.7,
                                          child: Text(documentSnapshot['comment'],style: TextStyle(color: constantColors.whiteColor,fontSize: 15),),
                                        ),
                                        documentSnapshot['useruid']==FirebaseAuth.instance.currentUser!.uid?IconButton(onPressed: (){}, icon: Icon(FontAwesomeIcons.trashAlt,color: constantColors.redColor,size: 16,)):Container(height: 0,width: 0,)

                                      ],
                                    ),
                                  ),
                                  Divider(color: constantColors.darkColor.withOpacity(.2),),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      }
                    }),
              ),
              Container(
                width: 400,
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: 300,
                      height: 20,
                      child: TextField(
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: 'Add Comment',
                          hintStyle: TextStyle(
                              color: constantColors.greyColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        controller: addCommentController,
                        style: TextStyle(color: constantColors.whiteColor,fontWeight: FontWeight.bold,fontSize: 16),
                      ),
                    ),
                    FloatingActionButton(onPressed: (){
                  addCommentInComment(context, postId, documentSnapshot).whenComplete(() {
                    addCommentController.clear();
                  });

                    },
                      child: Icon(FontAwesomeIcons.comment,color: constantColors.whiteColor,),
                      backgroundColor: constantColors.blueColor,)
                  ],
                ),
              )
            ],
          ),
          decoration: BoxDecoration(
            color:constantColors.blueGreyColor,
            borderRadius: BorderRadius.only(topRight: Radius.circular(12),topLeft: Radius.circular(12)),
          ),
        ),
      );
    });
  }

  showCommentSheet(BuildContext context,DocumentSnapshot documentSnapshot,String postId){
    return showModalBottomSheet(isScrollControlled: true,context: context, builder: (context){
      return Padding(
        padding:  EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          height: MediaQuery.of(context).size.height*.65,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 150.0),
                child: Divider(
                  thickness: 4,
                  color: constantColors.whiteColor,
                ),
              ),
              Container(
                width: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: constantColors.whiteColor),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(
                  child: Text('Comments',style: TextStyle(color: constantColors.blueColor,fontSize: 16,fontWeight: FontWeight.bold),),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height*.52,
                child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('posts').doc(postId).collection('comments').orderBy('time').snapshots(),
                    builder: (context,snapshot){
                      if(snapshot.connectionState==ConnectionState.waiting)
                      {
                        return Center(child: CircularProgressIndicator(),);
                      }
                      else{
                        return new ListView(
                          children: snapshot.data!.docs.map((DocumentSnapshot documentSnapshot){
                            return Container(
                              height: MediaQuery.of(context).size.height*.15,
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: InkWell(
                                          onTap: (){
                                            if(documentSnapshot['useruid']==FirebaseAuth.instance.currentUser!.uid){Navigator.pushReplacement(context, PageTransition(child: Profile(), type: PageTransitionType.leftToRight));
                                            }
                                            else
                                            Navigator.pushReplacement(context, PageTransition(child: AltProfile(userUid: documentSnapshot['useruid']), type: PageTransitionType.leftToRight));
                                          },
                                          child: CircleAvatar(
                                            backgroundColor: constantColors.darkColor,
                                            radius: 15,
                                            backgroundImage: NetworkImage(documentSnapshot['userimage']),
                                          ) ,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: Container(
                                          child: Text(documentSnapshot['username'],style: TextStyle(color: constantColors.whiteColor,fontWeight: FontWeight.bold,fontSize: 18),),
                                        ),
                                      ),
                                      Container(
                                        child: Row(
                                          children: [
                                            InkWell(
                                              onLongPress: (){
                                                Navigator.pop(context);
                                                showLikesOnComment(context, postId, documentSnapshot);
                                              },
                                              child: IconButton(onPressed: (){
                                                addLikeOnComment(context, documentSnapshot, postId);
                                              }, icon: Icon(FontAwesomeIcons.arrowUp,color: constantColors.blueColor,size: 12,)),
                                            ),
                                            StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('posts').doc(postId).collection('comments').doc(documentSnapshot.id).collection('likeoncomment').snapshots(),
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
                                                }),
                                            IconButton(onPressed: (){
                                              Navigator.pop(context);
                                              showCommentInComment(context, documentSnapshot, postId,documentSnapshot['username'],documentSnapshot['userimage']);
                                            }, icon: Icon(FontAwesomeIcons.reply,color: constantColors.yellowColor,size: 12,)),
                                            StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('posts').doc(postId).collection('comments').doc(documentSnapshot.id).collection('commentoncomment').snapshots(),
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
                                                }),

                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Row(
                                      children: [
                                        IconButton(onPressed: (){},
                                            icon: Icon(Icons.arrow_forward_ios_outlined,color: constantColors.blueColor,size: 12,)),
                                        Container(
                                          width: MediaQuery.of(context).size.width*.7,
                                          child: Text(documentSnapshot['comment'],style: TextStyle(color: constantColors.whiteColor,fontSize: 15),),
                                        ),
                                        documentSnapshot['useruid']==FirebaseAuth.instance.currentUser!.uid?IconButton(onPressed: (){}, icon: Icon(FontAwesomeIcons.trashAlt,color: constantColors.redColor,size: 16,)):Container(height: 0,width: 0,)

                                      ],
                                    ),
                                  ),
                                  Divider(color: constantColors.darkColor.withOpacity(.2),),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      }
                    }),
              ),
              Container(
                width: 400,
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: 300,
                      height: 20,
                      child: TextField(
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: 'Add Comment',
                          hintStyle: TextStyle(
                              color: constantColors.greyColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        controller: commentController,
                        style: TextStyle(color: constantColors.whiteColor,fontWeight: FontWeight.bold,fontSize: 16),
                      ),
                    ),
                    FloatingActionButton(onPressed: (){
                      addComment(documentSnapshot['caption'], commentController.text, context).whenComplete((){
                        commentController.clear();
                        notifyListeners();
                      });

                    },
                      child: Icon(FontAwesomeIcons.comment,color: constantColors.whiteColor,),
                      backgroundColor: constantColors.blueColor,)
                  ],
                ),
              )
            ],
          ),
          decoration: BoxDecoration(
            color:constantColors.blueGreyColor,
            borderRadius: BorderRadius.only(topRight: Radius.circular(12),topLeft: Radius.circular(12)),
          ),
        ),
      );
    });
  }

  showRewardsSheet(BuildContext context,String postId){
    return showModalBottomSheet(isScrollControlled: true,context: context, builder: (context){
      return Container(
        height: MediaQuery.of(context).size.height*.5,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 150.0),
              child: Divider(
                thickness: 4,
                color: constantColors.whiteColor,
              ),
            ),
            Container(
              width: 200,
              decoration: BoxDecoration(
                border: Border.all(color: constantColors.whiteColor),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Center(
                child: Text('Awards Socialites',style: TextStyle(color: constantColors.blueColor,fontSize: 16,fontWeight: FontWeight.bold),),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height*.4,
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('posts').doc(postId).collection('awards').orderBy('time').snapshots(),
                  builder: (context,snapshot){
                    if(snapshot.connectionState==ConnectionState.waiting)
                    {
                      return Center(child: CircularProgressIndicator(),);
                    }
                    else{
                      return new ListView(
                        children: snapshot.data!.docs.map((DocumentSnapshot documentSnapshot){
                          return ListTile(
                            leading: InkWell(onTap: (){
                              if(documentSnapshot['useruid']==FirebaseAuth.instance.currentUser!.uid){Navigator.pushReplacement(context, PageTransition(child: Profile(), type: PageTransitionType.leftToRight));
                              }
                              else
                              Navigator.pushReplacement(context, PageTransition(child: AltProfile(userUid: documentSnapshot['useruid']), type: PageTransitionType.leftToRight));
                            },
                              child: CircleAvatar(backgroundImage: NetworkImage(documentSnapshot['userimage']),radius: 15,backgroundColor: constantColors.darkColor,),),
                            title: Text(documentSnapshot['username'],style: TextStyle(color: constantColors.blueColor,fontSize: 16,fontWeight: FontWeight.bold),),
                            trailing: FirebaseAuth.instance.currentUser!.uid==documentSnapshot['useruid']?Container(width: 0,height: 0,):MaterialButton(onPressed: () {  },color: constantColors.blueColor,
                              child: Text('Follow',style: TextStyle(color: constantColors.whiteColor,fontWeight: FontWeight.bold,fontSize: 16),),),
                          );
                        }).toList(),
                      );
                    }
                  }),
            ),

          ],
        ),
        decoration: BoxDecoration(
          color: constantColors.blueGreyColor,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(12),topRight: Radius.circular(12))
        ),
      );
    });
  }

  showTimeAgo(dynamic timedata){
    Timestamp time=timedata;
    DateTime dateTime=time.toDate();
    imageTimePosted=timeago.format(dateTime);
    print(imageTimePosted);
  }

  showPostOptions(BuildContext context,String postId){
    return showModalBottomSheet(isScrollControlled: true ,context: context, builder: (context){
      return Padding(
        padding:  EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          height: MediaQuery.of(context).size.height*.2,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: constantColors.blueGreyColor,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(12),topRight: Radius.circular(12)),
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
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MaterialButton(color: constantColors.blueColor,onPressed: (){
                      showModalBottomSheet(context: context, builder: (context){
                        return Container(
                          child: Center(
                            child:Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                              Container(
                                width: 300,
                                height: 50,
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Add New Caption',
                                    hintStyle: TextStyle(color: constantColors.greyColor,fontSize: 16,fontWeight: FontWeight.bold),
                                  ),
                                    style: TextStyle(color: constantColors.whiteColor,fontSize: 16,fontWeight: FontWeight.bold),
                                    controller:editCommentController ,
                                ),
                              ),
                              FloatingActionButton(child: Icon(FontAwesomeIcons.fileUpload,color: constantColors.whiteColor,),backgroundColor: constantColors.redColor,onPressed: (){Provider.of<FirebaseOperations>(context,listen: false).updatePost(postId,{
                                'caption':editCommentController.text
                              }).whenComplete(() => Navigator.pop(context));}),
                            ],),
                          ),
                        );
                      });
                    },child: Text('Edit Caption',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: constantColors.whiteColor),),),
                    MaterialButton(color: constantColors.redColor,onPressed: (){
                    showDialog(context: context, builder: (context){
                     return AlertDialog(
                       backgroundColor: constantColors.blueGreyColor,
                       title: Text('Delete this Post ?',style: TextStyle(color: constantColors.whiteColor,fontWeight: FontWeight.bold,fontSize: 16),),
                       actions: [
                         MaterialButton(onPressed: (){Navigator.pop(context);},child: Text('No',style: TextStyle(decoration: TextDecoration.underline,decorationColor: constantColors.whiteColor,fontSize: 16,fontWeight: FontWeight.bold,color: constantColors.whiteColor),),),
                         MaterialButton(color: constantColors.redColor,onPressed: (){Provider.of<FirebaseOperations>(context,listen: false).deleteUserData(postId,'posts').whenComplete(() => Navigator.pop(context));},child: Text('Yes',style: TextStyle(decoration: TextDecoration.underline,decorationColor: constantColors.whiteColor,fontSize: 16,fontWeight: FontWeight.bold,color: constantColors.whiteColor),),),

                       ],
                     );
                    });

                      },child: Text('Delete Post',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: constantColors.whiteColor),),),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

}