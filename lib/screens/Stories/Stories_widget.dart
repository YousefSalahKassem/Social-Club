import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:socialclub/Constants/Constantcolors.dart';
import 'package:socialclub/screens/AltPtofile/alt_profile.dart';
import 'package:socialclub/screens/HomePage/home_page.dart';
import 'package:socialclub/screens/Stories/StoriesHelper.dart';

class StoryWidget{
  final ConstantColors constantColors=ConstantColors();
  final TextEditingController storyController=TextEditingController();

  addStory(BuildContext context){
    return showModalBottomSheet(context: context, builder: (context){
      return Container(
        height: MediaQuery.of(context).size.height*.1,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: constantColors.darkColor,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MaterialButton(color: constantColors.blueColor,onPressed: (){Provider.of<StoriesHelper>(context,listen: false).selectStoryImage(context, ImageSource.gallery).whenComplete(() {});},child: Text('Gallery',style: TextStyle(color: constantColors.whiteColor,fontWeight: FontWeight.bold,fontSize: 16),),),
                MaterialButton(color: constantColors.redColor,onPressed: (){Provider.of<StoriesHelper>(context,listen: false).selectStoryImage(context, ImageSource.camera).whenComplete(() {});},child: Text('Camera',style: TextStyle(color: constantColors.whiteColor,fontWeight: FontWeight.bold,fontSize: 16),),),
              ],
            ),
          ],
        ),
      );
    });
  }

  previewStoryImage(BuildContext context,File storyImage){
    return showModalBottomSheet(isScrollControlled: true,context: context, builder: (context){
      return Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: constantColors.darkColor,
        ),
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Image.file(storyImage),
            ),
            Positioned(top: 700,child: Container(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(onPressed: (){addStory(context);},heroTag: 'Reselect Image',backgroundColor: constantColors.redColor,child: Icon(FontAwesomeIcons.backspace,color: constantColors.whiteColor,),),
                  FloatingActionButton(onPressed: (){Provider.of<StoriesHelper>(context,listen: false).uploadStoryImage(context).whenComplete(()async{
                   try{
                   if(Provider.of<StoriesHelper>(context,listen: false).getStoryImage!=null){
                     await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get().then((value)async {
                       await FirebaseFirestore.instance.collection('stories').doc(FirebaseAuth.instance.currentUser!.uid).set({
                         'image':Provider.of<StoriesHelper>(context,listen: false).getStoryImageUrl,
                         'username':value['username'],
                         'useremail':value['useremail'],
                         'userimage':value['userimage'],
                         'useruid':value['useruid'],
                         'time':Timestamp.now(),
                       }).whenComplete(() {Navigator.pushReplacement(context, PageTransition(child: HomePage(), type: PageTransitionType.leftToRight));});
                     });
                   }
                   else{
                     return showModalBottomSheet(context: context, builder: (context){
                       return Container(
                       decoration: BoxDecoration(color: constantColors.darkColor),
                         child: Center(
                           child: MaterialButton(
                             onPressed: ()async{
                                  await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get().then((value)async {
                                  await FirebaseFirestore.instance.collection('stories').doc(FirebaseAuth.instance.currentUser!.uid).set({
                                  'image':Provider.of<StoriesHelper>(context,listen: false).getStoryImageUrl,
                                  'username':value['username'],
                                  'useremail':value['useremail'],
                                  'userimage':value['userimage'],
                                  'useruid':value['useruid'],
                                  'time':Timestamp.now(),
                                  }).whenComplete(() {Navigator.pushReplacement(context, PageTransition(child: HomePage(), type: PageTransitionType.leftToRight));});
                                        }
                                        );
                                  },

                             child: Text('Upload Story',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: constantColors.whiteColor),),
                           ),
                         ),
                       );
                     });
                   }
                   }catch(e){print(e.toString());}
                  });},heroTag: 'Confirm Image',backgroundColor: constantColors.blueColor,child: Icon(FontAwesomeIcons.check,color: constantColors.whiteColor,),),
                ],
              ),
            ))
          ],
        ),
      );
    });
  }

  addToHighLights(BuildContext context,String storyImage,CountDownController _controller){
    _controller.pause();
    return showModalBottomSheet(isScrollControlled: true,context: context, builder: (context){
      return Padding(
        padding:  EdgeInsets.only(bottom:MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          height: MediaQuery.of(context).size.height*.38,
          color: constantColors.blueGreyColor,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 150.0),
                child: Divider(
                  thickness: 4,
                  color: constantColors.whiteColor,
                ),
              ),
              Text('Add To Existing Album',style: TextStyle(color: constantColors.yellowColor,fontSize: 14,fontWeight: FontWeight.bold),),
              Container(
                height: MediaQuery.of(context).size.height*.1,
                width: MediaQuery.of(context).size.width,
                child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('highlights').snapshots(),
                    builder: (context,snapshot){
                      if(snapshot.connectionState==ConnectionState.waiting){return Center(child: CircularProgressIndicator(),);}
                      else{return new ListView(scrollDirection: Axis.horizontal,children: snapshot.data!.docs.map((DocumentSnapshot document) {
                        return InkWell(
                          onTap: (){Provider.of<StoriesHelper>(context,listen: false).addStoryToExistingAlbum(context, FirebaseAuth.instance.currentUser!.uid, document.id, storyImage, _controller);},
                          child: Container(
                            child: Padding(
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
                            ),

                          ),
                        );
                      } ).toList(),);}
                    }),
              ),
              Text('Create New Album',style: TextStyle(color: constantColors.greenColor,fontSize: 14,fontWeight: FontWeight.bold),),
              Container(height: MediaQuery.of(context).size.height*.1,width: MediaQuery.of(context).size.width
                ,child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('chatroomicons').snapshots()
                ,builder: (context,snapshot){
                  if(snapshot.connectionState==ConnectionState.waiting){return Center(child: CircularProgressIndicator(),);}
                  else{ return ListView(
                    scrollDirection: Axis.horizontal,
                    children: snapshot.data!.docs.map((DocumentSnapshot document) {
                      return InkWell(onTap: (){
                        Provider.of<StoriesHelper>(context,listen: false).convertHighLightedIcon(document['image']);
                        IconSelectedNotification(context, document['image']);
                      },child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Container(height: 50,width: 50,child: CircleAvatar(radius: 25,backgroundColor: constantColors.transperant,backgroundImage: NetworkImage(document['image']),),),
                      ),);
                    }).toList(),
                  );}
                }),),
              Container(
                height: MediaQuery.of(context).size.height*.1,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width*.8,
                      child: TextField(
                        textCapitalization: TextCapitalization.sentences,
                        controller: storyController,
                        style: TextStyle(
                          color: constantColors.whiteColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Add Album Title',
                          hintStyle: TextStyle(
                                    color: constantColors.greyColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                        ),
                      ),
                    ),
                    FloatingActionButton(onPressed: (){
                      if(storyController.text.isNotEmpty){
                        Provider.of<StoriesHelper>(context,listen: false).addStoryToNewAlbum(context, FirebaseAuth.instance.currentUser!.uid, storyController.text, storyImage,_controller);
                      }
                      else{showModalBottomSheet(context: context, builder: (context){
                        return Container(height: 100,width: 400,child: Center(child: Text('Add Album Title'),),);
                      });}
                    },child: Icon(FontAwesomeIcons.check,color: constantColors.whiteColor,),backgroundColor: constantColors.blueColor,),
                  ],
                ),
              ),

            ],
          ),
        ),
      );
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

  showViewers(BuildContext context,String storyId,String personId){
    return showModalBottomSheet(context: context, builder: (context){
      return Container(
        height: MediaQuery.of(context).size.height*.4,
        color: constantColors.blueGreyColor,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 150.0),
              child: Divider(
                thickness: 4,
                color: constantColors.whiteColor,
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height*.35,
              width: MediaQuery.of(context).size.width,
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('stories').doc(storyId).collection('seen').snapshots(),
                  builder: (context,snapshot){
                    if(snapshot.connectionState==ConnectionState.waiting){
                      return Center(child: CircularProgressIndicator(),);
                    }
                    else{
                      return ListView(
                        children: snapshot.data!.docs.map((DocumentSnapshot document) {
                          Provider.of<StoriesHelper>(context,listen: false).storyTimePosted(document['time']);
                          return ListTile(
                            leading: CircleAvatar(backgroundColor: constantColors.transperant,radius: 25,backgroundImage: NetworkImage(document['userimage']),),
                            title: Text(document['username'],style: TextStyle(color: constantColors.whiteColor,fontSize: 16,fontWeight: FontWeight.bold),),
                            subtitle: Text(Provider.of<StoriesHelper>(context,listen: false).getLastSeenTime.toString(),style: TextStyle(color: constantColors.lightBlueColor,fontSize: 12,fontWeight: FontWeight.bold),),
                            trailing: IconButton(onPressed: (){
                              Navigator.pushReplacement(context, PageTransition(child: AltProfile(userUid: document['useruid']), type: PageTransitionType.leftToRight));
                            }, icon: Icon(FontAwesomeIcons.arrowCircleRight,color: constantColors.yellowColor,)),
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

  previewAllHighlights(BuildContext context,String title){
    return showModalBottomSheet(isScrollControlled: true,context: context, builder: (context){
      return Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('highlights').doc(title).collection('story').snapshots(),
            builder: (context,snapshot){
              if(snapshot.connectionState==ConnectionState.waiting){return Center(child: CircularProgressIndicator(),);}
              else{
                return PageView(
                  children: snapshot.data!.docs.map((DocumentSnapshot document) {
                    return Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: CachedNetworkImage(imageUrl: document['image']),
                    );
                  }).toList(),
                );
              }
            }),
      );
    });
  }

}