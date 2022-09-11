import 'package:flutter/material.dart';
import 'package:profile/profile.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:searchable_listview/searchable_listview.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {

  List <String> requests=[
    "James bidden requested mechanic",
    "wahiga mwaure requested mechanic",
    "King kaka requested mechanic",
  ];
  List <String> status=[
    "Successfully completed",
    "Successfull completed",
    "Canceled by mechanic",
  ];


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Center(
            child: Column(

              children: [
                Profile(
                  imageUrl: "https://images.unsplash.com/photo-1598618356794-eb1720430eb4?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=870&q=80",
                  name: "Lincoln Munene",
                  website: "shamimmiah.com",
                  designation: "Mechanic | Total Kenya",
                  email: "lincolnmunene@gmail.com",
                  phone_number: "0704800563",
                ),

                SizedBox(height: 10),
                FlatButton(
                  child: Text('Request this mechanic'),
                  color: Colors.blueAccent,
                  onPressed: (){
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.SUCCES,
                      animType: AnimType.BOTTOMSLIDE,
                      title: 'Request sent',
                      desc: 'This mechanic has received your request',
                      btnCancelOnPress: () {},
                      btnOkOnPress: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return AdminPage();
                            },
                          ),
                              (route) => false,
                        );
                      },
                    ).show();
                  },
                ),
                SizedBox(height: 10),

                RatingBar.builder(
                initialRating: 3,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  print(rating);
                },
              ),

                SizedBox(height: 10),

                Text(
                  'Previous requests'
                ),
                ListView.builder(
                    itemBuilder: (BuildContext , index){
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(backgroundImage: NetworkImage('https://images.unsplash.com/photo-1598618356794-eb1720430eb4?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=870&q=80')),
                          title: Text(requests[index]),
                          subtitle: Text(status[index]),
                        ),
                      );
                    },
                itemCount: requests.length,
                  padding: EdgeInsets.all(5),
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,

                )






              ],
            )



          )),
    );
  }
}

class Actor {
}
