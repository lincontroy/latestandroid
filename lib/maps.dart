import 'dart:async';
import 'profile.dart';
import 'dart:convert';
import 'model/lesson.dart';
import 'inapp.dart';
import 'login_screen.dart';
import 'model/driver.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gmaps/directions_model.dart';
import 'package:flutter_gmaps/directions_repository.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ReconnectingOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: CircularProgressIndicator(),
            ),
            SizedBox(height: 12),
            Text(
              'Finding mechanic...',
            ),
          ],
        ),
      );
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _initialCameraPosition = CameraPosition(
    target: LatLng(0.0662, 37.6468),
    zoom: 11.5,
  );
  //check if overlay is on
  PageController _pageController;
  int _currentIndex = 0;
  GoogleMapController _googleMapController;
  Marker _origin;
  Marker _destination;
  Directions _info;
  List lessons;
  List drivers;
  var isLoggedIn;
  var actor;

  void Logout() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();

    localStorage.remove('isLoggedIn');
    localStorage.remove('actor');

    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  getactor() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();

    actor = jsonDecode(localStorage.getString('actor'));

    return actor;
  }

  void initState() {
    super.initState();
    // lessons=getLessons();
    // drivers=getDriver();

    actor = getactor();

    if (actor == 1) {
      lessons = getDriver();
    } else {
      lessons = getLessons();
    }
    _pageController = PageController();
  }

  @override
  void dispose() {
    _googleMapController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("The actor is $actor");
    return LoaderOverlay(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Mechanic finder'),
          actions: [
            TextButton(
                onPressed: () {
                  setState(() {
                    context.loaderOverlay.show();
                  });

                  //generate random number 1 or zero

                  FutureBuilder(
                    future: Future.delayed(const Duration(seconds: 20), () {
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.INFO,
                        animType: AnimType.BOTTOMSLIDE,
                        title: 'Found mechanic',
                        desc: 'Proceed to make a request',
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
                    }),
                  );
                },
                child: const Text('Find mechanic')),
            if (_origin != null)
              TextButton(
                //this is responsible for getting the map alligned on the screen
                onPressed: () => _googleMapController.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: _origin.position,
                      zoom: 14.5,
                      tilt: 50.0,
                    ),
                  ),
                ),
                style: TextButton.styleFrom(
                  primary: Colors.green,
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
                child: const Text('ORIGIN'),
              ),
            if (_destination != null)
              TextButton(
                onPressed: () => _googleMapController.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: _destination.position,
                      zoom: 14.5,
                      tilt: 50.0,
                    ),
                  ),
                ),
                style: TextButton.styleFrom(
                  primary: Colors.blue,
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
                child: const Text('DEST'),
              )
          ],
        ),
        body: SizedBox.expand(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            children: <Widget>[
              Container(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    GoogleMap(
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      initialCameraPosition: _initialCameraPosition,
                      onMapCreated: (controller) =>
                          _googleMapController = controller,
                      markers: {
                        if (_origin != null) _origin,
                        if (_destination != null) _destination
                      },
                      polylines: {
                        if (_info != null)
                          Polyline(
                            polylineId: const PolylineId('overview_polyline'),
                            color: Colors.red,
                            width: 5,
                            points: _info.polylinePoints
                                .map((e) => LatLng(e.latitude, e.longitude))
                                .toList(),
                          ),
                      },
                      onLongPress: _addMarker,
                    ),
                    if (_info != null)
                      Positioned(
                        top: 20.0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6.0,
                            horizontal: 12.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.yellowAccent,
                            borderRadius: BorderRadius.circular(20.0),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                offset: Offset(0, 2),
                                blurRadius: 6.0,
                              )
                            ],
                          ),
                          child: Text(
                            '${_info.totalDistance}, ${_info.totalDuration}',
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                  child: ListView.builder(
                      itemCount: lessons.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          elevation: 8.0,
                          margin: new EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 6.0),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(64, 75, 96, 9)),
                            child: ListTile(
                                onTap: () {
                                  AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.INFO,
                                    animType: AnimType.BOTTOMSLIDE,
                                    title: "Accept the request",
                                    desc:
                                        'Accept the request or decline the request, Your driver is at Meru, nchiru, Please follow the maps to get his location',
                                    btnCancelOnPress: () {},
                                    btnOkOnPress: () {
                                      AwesomeDialog(
                                        context: context,
                                        dialogType: DialogType.SUCCES,
                                        animType: AnimType.BOTTOMSLIDE,
                                        title: lessons[index].title,
                                        desc: 'You have accepted this request',
                                        btnCancelOnPress: () {},
                                        btnOkOnPress: () {
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) {
                                                return MapScreen();
                                              },
                                            ),
                                            (route) => false,
                                          );
                                        },
                                      ).show();
                                      // Navigator.pushAndRemoveUntil(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder: (context) {
                                      //       return MapScreen();
                                      //     },
                                      //   ),
                                      //       (route) => false,
                                      // );
                                    },
                                  ).show();
                                },
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 10.0),
                                leading: Container(
                                  padding: EdgeInsets.only(right: 12.0),
                                  decoration: new BoxDecoration(
                                      border: new Border(
                                          right: new BorderSide(
                                              width: 1.0,
                                              color: Colors.white24))),
                                  child: Icon(Icons.autorenew,
                                      color: Colors.white),
                                ),
                                title: Text(
                                  lessons[index].title,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

                                subtitle: Row(
                                  children: <Widget>[
                                    Icon(Icons.linear_scale,
                                        color: Colors.yellowAccent),
                                    Text(lessons[index].level,
                                        style: TextStyle(color: Colors.white))
                                  ],
                                ),
                                trailing: Icon(Icons.keyboard_arrow_right,
                                    color: Colors.white, size: 30.0)),
                          ),
                        );
                      })),
              Container(
                  child: Center(child: Text('Perform Onboard diagnostics'))),
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: TextButton(
                        child: Text('Logout'),
                        onPressed: () {
                          //do clear the access_token and authstate
                          Logout();
                        },
                      ),
                    ),
                    SizedBox(
                      height: 100,
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: TextButton(
                        child: Text('Pay driver'),
                        onPressed: () {
                          //do clear the access_token and authstate
                          Navigator.push(
                            context,
                            new MaterialPageRoute(builder: (context) => Iap()),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavyBar(
          selectedIndex: _currentIndex,
          onItemSelected: (index) {
            setState(() => _currentIndex = index);
            _pageController.jumpToPage(index);
          },
          items: <BottomNavyBarItem>[
            BottomNavyBarItem(
              title: Text('Home'),
              icon: Icon(Icons.home),
            ),
            BottomNavyBarItem(title: Text('Requests'), icon: Icon(Icons.apps)),
            BottomNavyBarItem(title: Text('OBD'), icon: Icon(Icons.settings)),
            BottomNavyBarItem(title: Text('Profile'), icon: Icon(Icons.person)),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.black,
          onPressed: () => _googleMapController.animateCamera(
            _info != null
                ? CameraUpdate.newLatLngBounds(_info.bounds, 100.0)
                : CameraUpdate.newCameraPosition(_initialCameraPosition),
          ),
          child: const Icon(Icons.center_focus_strong),
        ),
      ),
    );
  }

  void _addMarker(LatLng pos) async {
    if (_origin == null || (_origin != null && _destination != null)) {
      // Origin is not set OR Origin/Destination are both set
      // Set origin
      setState(() {
        _origin = Marker(
          markerId: const MarkerId('origin'),
          infoWindow: const InfoWindow(title: 'Origin'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          position: pos,
        );
        // Reset destination
        _destination = null;

        // Reset info
        _info = null;
      });
    } else {
      // Origin is already set
      // Set destination
      setState(() {
        _destination = Marker(
          markerId: const MarkerId('destination'),
          infoWindow: const InfoWindow(title: 'Destination'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          position: pos,
        );
      });

      // Get directions
      final directions = await DirectionsRepository()
          .getDirections(origin: _origin.position, destination: pos);
      setState(() => _info = directions);
    }
  }
}
