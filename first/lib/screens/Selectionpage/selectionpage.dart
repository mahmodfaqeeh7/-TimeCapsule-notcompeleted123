// ignore_for_file: division_optimization

import 'dart:io';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first/model/user_model.dart';
import 'package:first/screens/Welcomescreen/welcomescreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:cron/cron.dart';

class Mainpage extends StatefulWidget {
  const Mainpage({Key? key}) : super(key: key);

  @override
  _Mainpage createState() => _Mainpage();
}

class _Mainpage extends State<Mainpage> {
 int iconintger =0 ;
  final TextEditingController messagecontroller = new TextEditingController();

  final _formKey = GlobalKey<FormState>();

   IconData? record = Icons.mic ;
             void Changeicon ()
             {
               int iconstate  = iconintger%2 ;
               if(iconstate==0)
               {
                  record = Icons.pause ;
               }
               else{      record = Icons.mic ;
               }
               iconintger++;
             }


             // ignore: non_constant_identifier_names
             String? Emailbody;
             String? downlinks;

             int numberofimages  = 0 ;
             int? filesnames ;
             PlatformFile? Picked ;
             int namenumber = 0 ;
              int filenumber = 2 ;
              UploadTask? Taskup ;
              DateTime ti = DateTime.parse('2022-09-18 13:05:04Z');


           FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
            User? usera = FirebaseAuth.instance.currentUser;

 UserModel loggedInUser = UserModel();
 @override
 void initState() {
   super.initState();
   firebaseFirestore
       .collection("users")
       .doc(usera!.uid)
       .get()
       .then((value) {
     this.loggedInUser = UserModel.fromMap(value.data());
     setState(() {});
   });
 }



 final cron = Cron();

 List<XFile>? imageFileList = [];
 List<dynamic>? _documents = [];


  @override
  Widget build(BuildContext context) {


    final Massegeform =

    TextFormField(
        autofocus: false,
        controller: messagecontroller,
           keyboardType: TextInputType.multiline,
        validator: (value) {
          if (value!.isEmpty) {
            return ("Please Enter Your Massege");
          }
          },

        onSaved: (value) {
          messagecontroller.text = value!;
        },
        textInputAction: TextInputAction.done,

        decoration: InputDecoration(
          prefixIcon: Icon(Icons.message),
          contentPadding: EdgeInsets.fromLTRB(20, 50, 20, 50),
          hintText: "Enter Massege",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
          ),

        )

    );

    final FunButton = Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(30),
      color: Colors.deepPurple,
      child: MaterialButton(
          padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          minWidth: MediaQuery.of(context).size.width * 0.5,
          onPressed: () {
            Uploadfile();
          },
          child: Text(
            "Time Travel",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          )),
    );




    return Scaffold(

      appBar: AppBar(
        title: const Text("Welcome" , style: TextStyle(color: Colors.deepPurple),),
        centerTitle: true,
        backgroundColor: Colors.purple.shade50,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.deepPurple),
          onPressed: () {
            // passing this to our root
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        HomeScreen()
                ));
            },
        ),
      ),

      body:Container(
          child: SingleChildScrollView(

            child: Column(

              children: <Widget>[

                   SizedBox(height: 30),
                      Text(" NOTE : Fill the following data  and send it to \n                          the FUTURE now " ,
                    style: TextStyle( fontWeight: FontWeight.w600 , fontSize: 13.5 , color: Colors.deepPurple.shade800 ,),

                            ),
                  SizedBox(height: 30),

                  Container(

                    margin: EdgeInsets.only(left:20,right :20, ),
                    padding: const EdgeInsets.only(left:10,top:10,right :10, bottom: 10),
                    //color: Colors.black45,
                    decoration: BoxDecoration(
                      borderRadius: new BorderRadius.all(const Radius.circular(20.0)),
                      color: Colors.deepPurple.shade100,
                    ),

                    child: Massegeform,

                  ),
                  SizedBox(height: 30),

                  Container(


                    margin: EdgeInsets.only(left:20,right :20),
                    padding: const EdgeInsets.only(left:10,top:35,right :10, bottom: 35),
                  //  color: Colors.black45,
                    decoration: BoxDecoration(
                     borderRadius: new BorderRadius.all(const Radius.circular(20.0)),
                      color: Colors.deepPurple.shade100,
                    ),
                    child: Row(
                      children: <Widget>[
                        SizedBox(width: 50),

                        Column(

                          children : <Widget>[


                            IconButton( onPressed: (){
                                setState(() //<--whenever icon is pressed, force redraw the widget
                              {
                               Changeicon();


                              });
                              },
                            icon: Icon(record)
                            , iconSize: 40, color: Colors.black, ) , Text("Record"),
                          ],
                        ),
                        SizedBox(width: 140),
                        Column(

                            children : <Widget>[
                              IconButton( onPressed: (){
                                setState(() //<--whenever icon is pressed, force redraw the widget
                                {
                                  SelectFile();
                                  if(Picked != null)
                                    {
                                  filesnames = Picked?.size;

                                    }

                                });
                              },
                                icon: Icon(Icons.image)
                                , iconSize: 30, color: Colors.black, ) , Text("Media" ),

                      ],
                  ),



                ],

              ),

              ),

                SizedBox(height: 12),
                Center(
                  child: Column(
                    children: <Widget>[
                      Text("$numberofimages"),


                    ],



                  ),
                ),
                SizedBox(height: 20),

                FunButton,

                 // Text(Urldownload!),



              ],

            ),
           ),
        ),
    );
  }

 SelectFile() async {
   try {
     imageFileList!.clear();
     final List<XFile>? images = await ImagePicker().pickMultiImage()
     ;
     if (images == null) return;
     imageFileList!.addAll(images);
     numberofimages = imageFileList!.length;
   }

   catch (e) {

   }

 }



 Future Uploadfile() async {

    Emailbody = messagecontroller.text;

   if(imageFileList == null)return ;

   for(int i=0; i < imageFileList!.length; i++ ) {
     final filename = File(imageFileList![i].path!);
     final destanition = '${loggedInUser.uid}/asd${imageFileList![i].name!}';
     final ref = FirebaseStorage.instance.ref().child(destanition);
     Taskup = ref.putFile(filename);

     final snapshot = await Taskup!.whenComplete(() {});
     final Urldownload = await snapshot.ref.getDownloadURL();
      print('*************************************************** $Urldownload *********************************');
      downlinks =   "\n" + Urldownload!;
     namenumber++;
   }


   UserModel userModel = UserModel();

   userModel.messge = messagecontroller.text;
   String doc = loggedInUser.email! + messagecontroller.text;
   await firebaseFirestore
       .collection("users")
       .doc(doc)
       .set(userModel.toMap());

    Emailbody = messagecontroller.text + downlinks!;

   // await firebaseFirestore
    //   .collection("users")
      // .add({usera!.uid : messagecontroller.text});
    mailsend();
    Fluttertoast.showToast(msg: "message sent sucssefully :) ");

 }

 Future<void> mailsend()
  async
  {
    final difference = ti.difference(DateTime.now());
    print(difference.inMinutes);
    int timeweneed = difference.inMinutes;
    await Future.delayed(Duration(minutes: timeweneed) , ()async{

      String username = 'capsuletimetravel2022@gmail.com';
      String token = 'zxrtyyxrdxbgavwv';

      final smtpServer = gmail(username, token);
      final message = Message()
        ..from = Address(username , 'your app') ..recipients = ['${loggedInUser.email}'] ..subject = 'YOUR PAST IS HERE' ..text = Emailbody!;

      final sendReports =  await send(message, smtpServer);


    });




  }



}

