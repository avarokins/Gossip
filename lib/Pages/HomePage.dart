import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:telegramchatapp/Pages/ChattingPage.dart';
import 'package:telegramchatapp/main.dart';
import 'package:telegramchatapp/models/user.dart';
import 'package:telegramchatapp/Pages/AccountSettingsPage.dart';
import 'package:telegramchatapp/Widgets/ProgressWidget.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';


class HomeScreen extends StatefulWidget {

  final String currentUserId;

  HomeScreen({Key key, @required this.currentUserId}) : super(key: key);

  @override
  State createState() => HomeScreenState(currentUserId: currentUserId);
}

class HomeScreenState extends State<HomeScreen> {

  TextEditingController searchTextEditingController = TextEditingController();
  Future<QuerySnapshot> searchResultsFuture;
  final String currentUserId;

  HomeScreenState({Key key, @required this.currentUserId});


  homePageHeader() {
    return AppBar(

      automaticallyImplyLeading: false,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.settings, size: 25, color: Colors.white,),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Settings()));
          },
    ),
    ],
      backgroundColor: Colors.deepOrangeAccent,
      title: Container(
        margin: new EdgeInsets.only(bottom: 5),
        child: TextFormField(
          style: TextStyle(fontSize: 20, color: Colors.white),
          controller: searchTextEditingController,
          decoration: InputDecoration(
            hintText: " Search here...",
            hintStyle: TextStyle(color: Colors.white70),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            filled: true,
            prefixIcon: Icon(Icons.supervised_user_circle, color: Colors.white, size: 30,),
            suffixIcon: IconButton(
              icon: Icon(Icons.clear, color: Colors.white,),
              onPressed: emptyTextFormField,
            )
          ),
          onFieldSubmitted: searching,
        ),
      ),
    );
    }

    emptyTextFormField() {
      searchTextEditingController.clear();
    }

    searching( String username ) {
      Future<QuerySnapshot> allFoundUsers = Firestore.instance.collection("users")
          .where('nickname', isGreaterThanOrEqualTo: username).getDocuments();

      searchResultsFuture = allFoundUsers;
    }


  @override
  Widget build(BuildContext context) {
    return Scaffold (
      appBar: homePageHeader(),
      body: (searchResultsFuture == null) ? noResultsScreen() : foundScreen(),

    );
  }

  noResultsScreen() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Icon(Icons.group, color: Colors.deepOrange, size: 180,),
            Text(
              "Search results",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.deepOrange, fontSize: 40, fontWeight: FontWeight.w300),
            )
          ],
        ),
      ),
    );
  }

  foundScreen() {
    return FutureBuilder(
      future: searchResultsFuture,
      builder: (context,dataSnapshot) {
        if (dataSnapshot.hasData) {
          List<UserResult> searchUserResult = [];
          dataSnapshot.data.documents.forEach((document){
            User user = User.fromDocument(document);
            UserResult userResult = UserResult(user);

            if (currentUserId != document["id"]) {
              searchUserResult.add(userResult);
            }
          });
          return ListView(children: searchUserResult,);

        } else {
          return circularProgress();
        }
      }
    );
  }

}



class UserResult extends StatelessWidget {

  final User user;
  UserResult(this.user);

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.all(1),
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: () => sendToChatPage(context),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.black,
                  backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                  radius: 27,
                ),
                title: Text(
                  user.nickname,
                  style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w400),
                ),
                subtitle: Text(
                  "joined " + DateFormat("dd MMMM, yyyy - hh:mm:ss")
                      .format(DateTime.fromMillisecondsSinceEpoch(int.parse(user.createdAt))),
                  style: TextStyle(color: Colors.grey, fontSize: 15, fontStyle: FontStyle.italic),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }


  sendToChatPage ( BuildContext context ) {
    Navigator.push(context, MaterialPageRoute(builder: (context) =>
        Chat(receiverId: user.id,
            receiverAvatar: user.photoUrl,
            receiverName: user.nickname )));
  }

}























