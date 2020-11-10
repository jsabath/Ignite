import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ignite/datamodels/account.dart';
import 'package:ignite/datamodels/address.dart';
import 'package:ignite/datamodels/directiondetails.dart';
import 'package:ignite/dataproviders/appdata.dart';
import '../globalvariable.dart';
import 'package:geolocator/geolocator.dart';
import './requesthelper.dart';
import 'package:provider/provider.dart';
import '../datamodels/account.dart';

class HelperMethods {
  static void getCurrentUserInfo() async {
    currentFirebaseUser = FirebaseAuth.instance.currentUser;
    String userid = currentFirebaseUser.uid;

    DatabaseReference userRef =
        FirebaseDatabase.instance.reference().child('users/$userid');
    userRef.once().then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        currentUserInfo = Account.fromSnapshot(snapshot);
        print('My name is ${currentUserInfo.fullName}');
      }
    });
  }

  static Future<String> findCoordinateAddress(
      Position position, context) async {
    String placeAddress = '';

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.mobile &&
        connectivityResult != ConnectivityResult.wifi) {
      return placeAddress;
    }

    String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=AIzaSyBPXBAC60Xg1sqGg04tS4yFH5qSajx5VyE';

    var response = await RequestHelper.getRequest(url);

    if (response != 'Failed') {
      placeAddress = response['results'][0]['formatted_address'];

      Address pickupAddress = new Address();

      pickupAddress.longitude = position.longitude;
      pickupAddress.latitude = position.latitude;
      pickupAddress.placeName = placeAddress;

      Provider.of<AppData>(context, listen: false)
          .updatePickupAddress(pickupAddress);
    }
    return placeAddress;
  }

  static Future<DirectionDetails> getDirectionDetails(
      LatLng startPosition, LatLng endPosition) async {
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${startPosition.latitude},${startPosition.longitude}&destination=${endPosition.latitude},${endPosition.longitude}&mode=driving&key=$mapKey';
    var response = await RequestHelper.getRequest(url);

    if (response == 'failed') {
      return null;
    }

    DirectionDetails directionDetails = DirectionDetails();

    directionDetails.durationText =
        response['routes'][0]['legs'][0]['duration']['text'];
    directionDetails.durationValue =
        response['routes'][0]['legs'][0]['duration']['value'];

    directionDetails.distanceText =
        response['routes'][0]['legs'][0]['distance']['text'];
    directionDetails.distanceValue =
        response['routes'][0]['legs'][0]['distance']['value'];

    directionDetails.encodedPoints =
        response['routes'][0]['overview_polyline']['points'];

    return directionDetails;
  }

  static int estimateFares(DirectionDetails details) {
    double baseFare = 12;
    double distanceFare = (details.distanceValue / 5128) * 1.5;
    double timeFare = (details.durationValue / 60) * 1;

    double totalFare = baseFare + distanceFare + timeFare;

    return totalFare.truncate();
  }
}
