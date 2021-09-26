
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:socialclub/Constants/Constantcolors.dart';
import 'package:socialclub/screens/LandingPage/landing_services.dart';
import 'package:socialclub/services/FirebaseOperations.dart';
import 'package:socialclub/services/authentication.dart';

class UploadPost with ChangeNotifier{
  ConstantColors constantColors=ConstantColors();
  late File uploadPostImage;
  File get getUploadPostImage=>uploadPostImage;
  late String uploadPostImageUrl;
  String get getUploadPostImageUrl => uploadPostImageUrl;
  final picker=ImagePicker();
  late UploadTask imagePostUploadTask;
  TextEditingController captionController=TextEditingController();

  Future pickUploadPostImage(BuildContext context,ImageSource source)async{
    final uploadPostImageVal=await picker.getImage(source: source);
    uploadPostImageVal==null?
    print('Select image')
        : uploadPostImage=File(uploadPostImageVal.path);


    uploadPostImage != null ? showPostImage(context):print('Image upload error');
    notifyListeners();
  }

  selectPostImage(BuildContext context) {
    return showModalBottomSheet(context: context, builder: (context){
      return Container(
        height: MediaQuery.of(context).size.height*.1,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: constantColors.blueGreyColor,
          borderRadius: BorderRadius.circular(12),
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
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
              MaterialButton(color: constantColors.blueColor,onPressed: (){pickUploadPostImage(context, ImageSource.gallery);},child: Text('Gallery',style: TextStyle(color: constantColors.whiteColor,fontSize: 16,fontWeight: FontWeight.bold),),),
              MaterialButton(color: constantColors.blueColor,onPressed: (){pickUploadPostImage(context, ImageSource.camera);},child: Text('Camera',style: TextStyle(color: constantColors.whiteColor,fontSize: 16,fontWeight: FontWeight.bold),),),
            ],
            )
          ],
        ),
      );
    });
  }

  Future uploadPostImageToFirebase()async{
    Reference ImageReference=FirebaseStorage.instance.ref().child('posts/${uploadPostImage.path}/${TimeOfDay.now()}');
    imagePostUploadTask=ImageReference.putFile(uploadPostImage);
    await imagePostUploadTask.whenComplete(() {
    });
    ImageReference.getDownloadURL().then((value) {
      uploadPostImageUrl=value;
    });
    notifyListeners();
  }

  showPostImage(BuildContext context) {
    return showModalBottomSheet(context: context, builder: (context){
      return Container(
        height: MediaQuery.of(context).size.height*.4,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: constantColors.darkColor,
          borderRadius: BorderRadius.circular(12),
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
            Padding(
              padding: const EdgeInsets.only(top: 8.0,left: 8,right: 8),
              child: Container(
                height: 200,
                width: 400,
                child: Image.file(uploadPostImage,fit: BoxFit.contain,),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MaterialButton(onPressed: (){
                    selectPostImage(context);
                  },
                      child:Text('Reselect',style: TextStyle(
                        color: constantColors.whiteColor,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        decorationColor: constantColors.whiteColor,
                      ),)),
                  MaterialButton(onPressed: (){
                    uploadPostImageToFirebase().whenComplete(() {
                      editPostSheet(context);
                      Navigator.pop(context);
                    });
                  },color: constantColors.blueColor,
                      child:Text('Confirm Image',style: TextStyle(
                        color: constantColors.whiteColor,
                        fontWeight: FontWeight.bold,
                      ),)),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  editPostSheet(BuildContext context){
    return showModalBottomSheet(isScrollControlled: true,context: context, builder: (context){
      return Container(
        height: MediaQuery.of(context).size.height*.75,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: constantColors.blueGreyColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 150.0),
            child: Divider(
              thickness: 4,
              color: constantColors.whiteColor,
            ),
          ),
          Container(child: Row(
            children: [
              Container(
                child: Column(
                  children: [
                    IconButton(onPressed: (){}, icon: Icon(Icons.image_aspect_ratio,color: constantColors.greenColor,)),
                    IconButton(onPressed: (){}, icon: Icon(Icons.fit_screen,color: constantColors.yellowColor,))
                  ],
                ),
              ),
              Container(
                height: 200,
                width: 300,
                child: Image.file(uploadPostImage,fit: BoxFit.contain,),
              ),
            ],
          ),),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(height: 30,width: 30,child: Image.asset('icons/sunflower.png'),),
                Container(height: 110,width: 5,color: constantColors.blueColor,),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Container(height: 120,width: 330,
                    child: TextField(
                    maxLines: 5,
                    textCapitalization: TextCapitalization.words,
                    inputFormatters: [LengthLimitingTextInputFormatter(100)],
                    maxLengthEnforced: true,
                    maxLength: 100,
                    controller: captionController,
                    style: TextStyle(color: constantColors.whiteColor,fontWeight: FontWeight.bold,fontSize: 16),
                    decoration: InputDecoration(hintText: 'Add A Caption...',hintStyle: TextStyle(color: constantColors.greyColor,fontWeight: FontWeight.bold,fontSize: 13),),
                  ),),
                ),
              ],
            ),
          ),
          MaterialButton(child: Text('Share',style:TextStyle(color: constantColors.whiteColor,fontWeight: FontWeight.bold,fontSize: 16))
            ,onPressed: ()async{
              FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get().then((doc){
                Provider.of<FirebaseOperations>(context,listen: false).uploadPostData(captionController.text,
                    {
                      'postimage':uploadPostImageUrl,
                      'caption':captionController.text,
                      'username':doc['username'],
                      'userimage':doc['userimage'],
                      'useruid':FirebaseAuth.instance.currentUser!.uid,
                      'time':Timestamp.now(),
                      'useremail':FirebaseAuth.instance.currentUser!.email,
                    })
                    .whenComplete((){
                  return FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('posts').add(
                    {
                      'postimage':uploadPostImageUrl,
                      'caption':captionController.text,
                      'username':doc['username'],
                      'userimage':doc['userimage'],
                      'useruid':FirebaseAuth.instance.currentUser!.uid,
                      'time':Timestamp.now(),
                      'useremail':FirebaseAuth.instance.currentUser!.email,
                    }
                  ).whenComplete(() => Navigator.pop(context));
                });
                notifyListeners();
              });
            }
            ,color: constantColors.blueColor,),
        ],),
      );
    });
  }
}