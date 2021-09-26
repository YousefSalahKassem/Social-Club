import 'dart:io';

import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:socialclub/Constants/Constantcolors.dart';
import 'package:socialclub/screens/Stories/Stories_widget.dart';
import 'package:timeago/timeago.dart 'as timeago;


class StoriesHelper with ChangeNotifier{
 late UploadTask imageUploadTask;
final picker=ImagePicker();
 late File storyImage;
File get getStoryImage=>storyImage;
final StoryWidget storyWidget=StoryWidget();
late String storyImageUrl,storyHighLightIcon,storyTime,lastSeenTime;
String get getStoryImageUrl=>storyImageUrl;
String get getStoryHighLightIcon=>storyHighLightIcon;
String get getStoryTime=>storyTime;
String get getLastSeenTime=>lastSeenTime;
ConstantColors constantColors=ConstantColors();

Future selectStoryImage(BuildContext context,ImageSource source)async{
  final pickedStoryImage=await picker.getImage(source: source);
  pickedStoryImage==null?print('error'):storyImage=File(pickedStoryImage.path);
  // ignore: unnecessary_null_comparison
  storyImage != null?storyWidget.previewStoryImage(context, storyImage):print('error');
  notifyListeners();
}

Future uploadStoryImage(BuildContext context)async{
  Reference imageReference=FirebaseStorage.instance.ref().child('story/${storyImage.path}/${TimeOfDay.now()}');
  imageUploadTask=imageReference.putFile(storyImage);
  await imageUploadTask.whenComplete(() {
  });
  imageReference.getDownloadURL().then((value) {
    storyImageUrl=value;
  });
  notifyListeners();
}

Future convertHighLightedIcon(String fireStoreImageUrl)async{
  storyHighLightIcon=fireStoreImageUrl;
  notifyListeners();
}

Future addStoryToNewAlbum(BuildContext context,String userUid,String highLightName,String storyImage,CountDownController controller)async{
return FirebaseFirestore.instance.collection('users').doc(userUid).collection('highlights').doc(highLightName).set({
  'title':highLightName,
  'cover':storyHighLightIcon,
}).whenComplete(() {
   FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get().then((value) {
     FirebaseFirestore.instance.collection('stories').doc(FirebaseAuth.instance.currentUser!.uid).get().then((doc) {
       FirebaseFirestore.instance.collection('users').doc(userUid).collection('highlights').doc(highLightName).collection('story').doc().set(
           {
             'image':doc['image'],
             'username':value['username'],
             'userimage':value['userimage'],
           }
        );

   });
  });
   Navigator.pop(context);
   controller.resume();
}
);
}

 Future addStoryToExistingAlbum(BuildContext context,String userUid,String highCollectionId,String storyImage,CountDownController controller)async{
  FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get().then((value) {
    return FirebaseFirestore.instance.collection('users').doc(userUid).collection('highlights').doc(highCollectionId).collection('story').add(
        {
      'image':storyImage,
      'username':value['username'],
      'userimage':value['userimage']
    });

  });

 }


storyTimePosted(dynamic timeData){
  Timestamp timestamp=timeData;
  DateTime dateTime=timestamp.toDate();
  storyTime=timeago.format(dateTime);
  lastSeenTime=timeago.format(dateTime);

}

Future addSeenStamp(BuildContext context,String storyId,String personId,DocumentSnapshot documentSnapshot)async{
  if(documentSnapshot['useruid']!=FirebaseAuth.instance.currentUser!.uid){
   return FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get().then((value) {
      return FirebaseFirestore.instance.collection('stories').doc(storyId).collection('seen').doc(personId).set(
          {
            'time':Timestamp.now(),
            'username':value['username'],
            'userimage':value['userimage'],
            'useruid':value['useruid']
          });
    });

  }
}
}