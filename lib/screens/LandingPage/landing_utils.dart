import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:socialclub/Constants/Constantcolors.dart';
import 'package:socialclub/screens/LandingPage/landing_services.dart';
import 'package:socialclub/services/FirebaseOperations.dart';

class LandingUtils with ChangeNotifier{
  ConstantColors constantColors=ConstantColors();
  final picker=ImagePicker();
  late File userAvatar;
  File get getUserAvatar=>userAvatar;
  late String userAvatarUrl;
  String get getUserAvatarUrl=>userAvatarUrl;

  Future pickUserAvatar(BuildContext context,ImageSource source)async{
    final pickedUserAvatar=await picker.getImage(source: source);
    pickedUserAvatar==null? print('Select image') : userAvatar=File(pickedUserAvatar.path);
    print(userAvatar.path);


    userAvatar != null ? Provider.of<LandingServices>(context,listen: false).showUserAvatar(context):print('Image upload error');
    notifyListeners();
  }

  Future selectAvatarOptionsSheet(BuildContext context)async{
    return showModalBottomSheet(context: context, builder: (context){
      return Container(
        height: MediaQuery.of(context).size.height*.1,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: constantColors.blueGreyColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child:Column(
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
                MaterialButton(onPressed: (){
                  pickUserAvatar(context, ImageSource.gallery).whenComplete((){
                    Navigator.pop(context);
                    Provider.of<LandingServices>(context,listen: false).showUserAvatar(context);

                  });
                },
                  child:Text('Gallery',
                    style: TextStyle(color: constantColors.whiteColor,
                        fontWeight: FontWeight.bold,fontSize: 18),)
                  ,color: constantColors.blueColor,),
                MaterialButton(onPressed: (){
                  pickUserAvatar(context, ImageSource.camera).whenComplete((){
                    Navigator.pop(context);
                    Provider.of<LandingServices>(context,listen: false).showUserAvatar(context);

                  });
                },
                  child:Text('Camera',
                    style: TextStyle(color: constantColors.whiteColor,
                        fontWeight: FontWeight.bold,fontSize: 18),)
                  ,color: constantColors.blueColor,),

              ],
            ),
          ],
        ) ,
      );
    });
  }
}