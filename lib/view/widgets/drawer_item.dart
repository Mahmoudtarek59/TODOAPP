import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:semicolontodoapp/main.dart';
import 'package:semicolontodoapp/provider/auth.dart';


final FirebaseAuth _auth = FirebaseAuth.instance;
class DrawerItem extends StatefulWidget {
  @override
  _DrawerItemState createState() => _DrawerItemState();
}

class _DrawerItemState extends State<DrawerItem> {
  String _username='';
  String _email='';
  String _imageUrl;

  _getUserData()async{
    final data = await _auth.currentUser();
    _username =data.displayName;
    _email = data.email;
    _imageUrl = data.photoUrl;
    setState(() {

    });
  }


  @override
  void initState() {
     _getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        margin: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height:40),
//            Consumer<Auth>(builder: (context,auth,_)=>CircleAvatar(radius: 60,backgroundImage: NetworkImage(auth.imageUrl),),),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: CircleAvatar(radius: 60,backgroundImage: NetworkImage(_imageUrl),),
            ),
            SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text('${_username}',style: Theme.of(context).textTheme.headline,),
              ),
            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text('${_email}',style: Theme.of(context).textTheme.body1),
            ),
            SizedBox(height: 10,),
            Divider(),
            SizedBox(height: 10,),
            ListTile(
              title: Text('Home'),
              leading: Icon(Icons.home),
              onTap: ()=>Navigator.of(context).pop(),
            ),
            ListTile(
              title: Text('Logout'),
              leading: Icon(Icons.exit_to_app),
              onTap: (){
                Navigator.of(context).pop();
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>MyApp()), (route) => false);
                Provider.of<Auth>(context,listen: false).logout();
              },
            ),
          ],
        ),
      ),
    );
  }
}
