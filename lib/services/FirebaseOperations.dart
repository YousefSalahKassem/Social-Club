 import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialclub/model/messageModel.dart';
import 'package:socialclub/screens/LandingPage/landing_utils.dart';
import 'package:socialclub/services/authentication.dart';

class FirebaseOperations with ChangeNotifier{
  late UploadTask imageUploadTask;
  late String initUserEmail,initUserImage,initUserName;
  String get userEmail=>initUserEmail;
  String get username=>initUserName;
  String get userImage=>userImage;

  Future uploadUserAvatar(BuildContext context)async{
     Reference imageRef=FirebaseStorage.instance.ref().child(
       'userProfileAvatar/${Provider.of<LandingUtils>(context,listen: false).getUserAvatar.path}/${TimeOfDay.now()}');
     imageUploadTask=imageRef.putFile(Provider.of<LandingUtils>(context,listen: false).getUserAvatar);
        await imageUploadTask.whenComplete(() {
       print('Image Uploaded!');
     });
        imageRef.getDownloadURL().then((url) {
          Provider.of<LandingUtils>(context,listen: false).userAvatarUrl=url.toString();
        });
        notifyListeners();
   }

  Future createUserCollection(BuildContext context,dynamic data)async{
     return FirebaseFirestore.instance.collection('users').doc(Provider.of<Authentication>(context,listen: false).getUserUid).set(data);
   }

  Future <dynamic>initUserData(BuildContext context)async{
    return FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get().then((doc) async {
      initUserEmail=doc['useremail'];
      initUserName=doc['username'];
      initUserImage=doc['userimage'];
      FirebaseAuth.instance.currentUser!.getIdToken().then((value) => print(value));
      notifyListeners();
    });



  }

  Future uploadPostData(String posId,dynamic data)async{
    return FirebaseFirestore.instance.collection('posts').doc(posId).set(data);
   }

  Future deleteUserData(String uid,dynamic collection)async{
    return FirebaseFirestore.instance.collection(collection).doc(uid).delete();
   }

  Future addAward(String postId,dynamic data)async{
    return FirebaseFirestore.instance.collection('posts').doc(postId).collection('awards').add(data);
  }

  Future updatePost(String postId,dynamic data)async{
    return FirebaseFirestore.instance.collection('posts').doc(postId).update(data);
  }

  Future followUsers(String followingUid,String followingDocUid,dynamic followingData,String followerUid,String followerDocUid,dynamic followerData)async{
    return FirebaseFirestore.instance.collection('users').doc(followingUid).collection('followers').doc(followingDocUid).set(followingData).whenComplete(()async {
     return FirebaseFirestore.instance.collection('users').doc(followerUid).collection('following').doc(followerDocUid).set(followerData);
    });
  }

  Future unFollowUsers(BuildContext context,String uid)async{
    return FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('following').doc(uid).delete().whenComplete((){
      return FirebaseFirestore.instance.collection('users').doc(uid).collection('followers').doc(FirebaseAuth.instance.currentUser!.uid).delete();
    });
  }

  Future unFollowAltUsers(BuildContext context,String uid)async{
    return FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('followers').doc(uid).delete().whenComplete((){
      return FirebaseFirestore.instance.collection('users').doc(uid).collection('following').doc(FirebaseAuth.instance.currentUser!.uid).delete();
    });
  }

  Future submitChatRoomData(String chatRoomName,dynamic data)async{
    return FirebaseFirestore.instance.collection('chatrooms').doc(chatRoomName).set(data);
  }

  Future privateChat(BuildContext context,dynamic data)async{
    return FirebaseFirestore.instance.collection('privatechats').doc().set(data);
  }
  
  Future searchPerson(BuildContext context,String searchField)async{
    return FirebaseFirestore.instance.collection('users').where('username',isEqualTo: searchField.substring(0,1).toUpperCase()).get();
  }

  Future editName(BuildContext context,String name)async{
    return FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update(
        {
          'username':name
        });
  }

}