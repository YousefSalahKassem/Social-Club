import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socialclub/Constants/Constantcolors.dart';
import 'package:socialclub/screens/HomePage/home_page.dart';
import 'package:socialclub/screens/LandingPage/landing_utils.dart';
import 'package:socialclub/services/FirebaseOperations.dart';
import 'package:socialclub/services/authentication.dart';

class LandingServices with ChangeNotifier{
  TextEditingController emailController=TextEditingController();
  TextEditingController passwordController=TextEditingController();
  TextEditingController userNameController=TextEditingController();
  ConstantColors constantColors=ConstantColors();
  late String id;

  getStringValue(String id) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    return myPrefs.getString(id);
  }




  signInSheet(BuildContext context) {
    return showModalBottomSheet(
      isScrollControlled: true,
        context: context,
        builder: (context) {
         return Padding(
           padding:  EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
           child: Container(
             height: MediaQuery.of(context).size.height*.6,
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
                 CircleAvatar(
                   backgroundImage: FileImage(Provider.of<LandingUtils>(context,listen: false).getUserAvatar),
                   backgroundColor: constantColors.redColor,
                   radius: 60,
                 ),
                 Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 10.0),
                   child: TextField(
                     controller:userNameController ,
                     decoration: InputDecoration(
                       hintText: 'Enter Name...',
                       hintStyle: TextStyle(
                         color: constantColors.whiteColor,
                         fontSize: 18,
                         fontWeight: FontWeight.bold,
                       ),
                     ),
                     style: TextStyle(
                       color: constantColors.whiteColor,
                       fontSize: 16,
                       fontWeight: FontWeight.bold,
                     ),
                   ),
                 ),
                 Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 10.0),
                   child: TextField(
                     controller:emailController ,
                     decoration: InputDecoration(
                       hintText: 'Enter Email...',
                       hintStyle: TextStyle(
                         color: constantColors.whiteColor,
                         fontSize: 18,
                         fontWeight: FontWeight.bold,
                       ),
                     ),
                     style: TextStyle(
                       color: constantColors.whiteColor,
                       fontSize: 16,
                       fontWeight: FontWeight.bold,
                     ),
                   ),
                 ),
                 Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 10.0),
                   child: TextField(
                     controller:passwordController ,
                     decoration: InputDecoration(
                       hintText: 'Enter password...',
                       hintStyle: TextStyle(
                         color: constantColors.whiteColor,
                         fontSize: 18,
                         fontWeight: FontWeight.bold,
                       ),
                     ),
                     style: TextStyle(
                       color: constantColors.whiteColor,
                       fontSize: 16,
                       fontWeight: FontWeight.bold,
                     ),
                   ),
                 ),
                 SizedBox(height: 15,),
                 FloatingActionButton(backgroundColor: constantColors.redColor,
                     child: Icon(FontAwesomeIcons.check,color: constantColors.whiteColor,),
                     onPressed: (){
                   if(emailController.text.isNotEmpty&&passwordController.text.isNotEmpty)
                   {
                     Provider.of<Authentication>(context,listen: false).createAccount(emailController.text, passwordController.text).whenComplete(() async {
                         Provider.of<FirebaseOperations>(context,listen: false).createUserCollection(context,{
                           'useruid':Provider.of<Authentication>(context,listen: false).getUserUid,
                           'useremail':emailController.text,
                           'username':userNameController.text,
                           'userimage':Provider.of<LandingUtils>(context,listen: false).getUserAvatarUrl,
                         });
                         Navigator.pushReplacement(
                             context,
                             PageTransition(
                                 child: HomePage(),
                                 type: PageTransitionType.leftToRight));
                     });
                   }
                 })
               ],
             ),
           ),
         );
        });
  }

  logInSheet(BuildContext context){
    return showModalBottomSheet(context: context, isScrollControlled: true,builder: (context){
      return Padding(
        padding:  EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(color: constantColors.blueGreyColor),
          height: MediaQuery.of(context).size.height*.3,
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: TextField(
                  controller:emailController ,
                  decoration: InputDecoration(
                    hintText: 'Enter Email...',
                    hintStyle: TextStyle(
                      color: constantColors.whiteColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextStyle(
                    color: constantColors.whiteColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: TextField(
                  controller:passwordController ,
                  decoration: InputDecoration(
                    hintText: 'Enter password...',
                    hintStyle: TextStyle(
                      color: constantColors.whiteColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextStyle(
                    color: constantColors.whiteColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 15,),
              FloatingActionButton(backgroundColor: constantColors.blueColor,
                  child: Icon(FontAwesomeIcons.check,color: constantColors.whiteColor,),
                  onPressed: (){
                    if(emailController.text.isNotEmpty&&passwordController.text.isNotEmpty)
                    { Provider.of<Authentication>(context, listen: false)
                        .logIntoAccount(emailController.text, passwordController.text)
                        .whenComplete(() => Provider.of<FirebaseOperations>(
                        context,
                        listen: false)
                        .initUserData(context))
                        .whenComplete(() {
                         FirebaseFirestore.instance.collection('users').where('useremail',isEqualTo: emailController.text).get().then((value) =>
                         FirebaseFirestore.instance.collection('users')).whenComplete(() =>Navigator.pushReplacement(
                             context,
                             PageTransition(
                                 child: HomePage(),
                                 type: PageTransitionType.leftToRight)));
                    });}
                  })
            ],
          ),
        ),
      );
    });
  }


  showUserAvatar(BuildContext context){
    return showModalBottomSheet(context: context, builder:(context){
      return Container(
        height: MediaQuery.of(context).size.height*.3,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: constantColors.blueGreyColor,
          borderRadius: BorderRadius.circular(15.0),
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
            CircleAvatar(
              radius: 80,
              backgroundColor: constantColors.transperant,
              backgroundImage: FileImage(
                Provider.of<LandingUtils>(context,listen: false).userAvatar
              ),
            ),
            SizedBox(height: 10,),
            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MaterialButton(onPressed: (){
                    Provider.of<LandingUtils>(context).pickUserAvatar(context, ImageSource.gallery);
                  },
                      child:Text('Reselect',style: TextStyle(
                    color: constantColors.whiteColor,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    decorationColor: constantColors.whiteColor,
                  ),)),
                  MaterialButton(onPressed: (){
                    Provider.of<FirebaseOperations>(context,listen: false).uploadUserAvatar(context).whenComplete((){
                      signInSheet(context);
                    });
                  },color: constantColors.blueColor,
                      child:Text('Confirm Image',style: TextStyle(
                        color: constantColors.whiteColor,
                        fontWeight: FontWeight.bold,
                      ),)),
                ],
              ),
            )
          ],
        ),
      );
    });
  }
}