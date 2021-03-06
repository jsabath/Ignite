import 'package:flutter/material.dart';
import 'package:ignite/datamodels/prediction.dart';
import 'package:ignite/dataproviders/appdata.dart';
import 'package:ignite/globalvariable.dart';
import 'package:ignite/helpers/requesthelper.dart';
import 'package:ignite/widgets/BrandDivider.dart';
import 'package:ignite/widgets/PredictionTile.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  var pickupController = TextEditingController();
  var destinationController = TextEditingController();

  var focusDestination = FocusNode();

  bool focused = false;

  void setFocus() {
    if (!focused) {
      FocusScope.of(context).requestFocus(focusDestination);
      focused = true;
    }
  }

  // var focusPickup = FocusNode();

  // bool focused2 = false;

  // void setFocus2() {
  //   if (!focused2) {
  //     FocusScope.of(context).requestFocus(focusPickup);
  //     focused2 = true;
  //   }
  // }

  List<Prediction> destinationPredictionList = [];

  void searchPlace(String placeName) async {
    if (placeName.length > 1) {
      String url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapKey&sessiontoken=123254251&components=country:us';

      var response = await RequestHelper.getRequest(url);

      if (response == 'failed') {
        return;
      }
      if (response['status'] == 'OK') {
        var predictionJson = response['predictions'];
        var thisList = (predictionJson as List)
            .map((e) => Prediction.fromJson(e))
            .toList();

        setState(() {
          destinationPredictionList = thisList;
        });
      }
    }
  }

  // List<Prediction> pickupPredictionList = [];

  // void searchPlace2(String placeName) async {
  //   if (placeName.length > 1) {
  //     String url =
  //         'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapKey&sessiontoken=123254251&components=country:us';

  //     var response = await RequestHelper.getRequest(url);

  //     if (response == 'failed') {
  //       return;
  //     }
  //     if (response['status'] == 'OK') {
  //       var predictionJson = response['predictions'];
  //       var thisList = (predictionJson as List)
  //           .map((e) => Prediction.fromJson(e))
  //           .toList();

  //       setState(() {
  //         pickupPredictionList = thisList;
  //       });
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    setFocus();
    String address =
        Provider.of<AppData>(context).pickupAddress.placeName ?? '';
    // String address2 =
    //     Provider.of<AppData>(context).pickupAddress.placeFormattedAddress ?? '';
    pickupController.text = address;

    return Scaffold(
        body: Column(
      children: <Widget>[
        Container(
            height: 203,
            decoration: BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                spreadRadius: 0.5,
                offset: Offset(0.7, 0.7),
              ),
            ]),
            child: Padding(
              padding:
                  EdgeInsets.only(left: 24, top: 48, right: 24, bottom: 20),
              child: Column(
                children: <Widget>[
                  SizedBox(height: 5),
                  Stack(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          OMIcons.arrowBack,
                          color: Colors.green[800],
                        ),
                      ),
                      Center(
                          child: Text('Set Destination',
                              style: TextStyle(
                                  fontSize: 20, fontFamily: 'Brand-Bold'))),
                    ],
                  ),
                  SizedBox(height: 18),
                  Row(
                    children: <Widget>[
                      Image.asset('images/pickicon.png', height: 17, width: 17),
                      SizedBox(width: 18),
                      Expanded(
                          child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(2.0),
                                child: TextField(
                                    onChanged: (value) {
                                      searchPlace(value);
                                    },
                                    // focusNode: focusPickup,
                                    controller: pickupController,
                                    decoration: InputDecoration(
                                        hintText: 'Pickup Location',
                                        fillColor: Colors.grey[300],
                                        filled: true,
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.only(
                                            left: 10, top: 10, bottom: 1))),
                              ))),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Image.asset('images/desticon.png', height: 17, width: 17),
                      SizedBox(width: 18),
                      Expanded(
                          child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(2.0),
                                child: TextField(
                                    onChanged: (value) {
                                      searchPlace(value);
                                    },
                                    focusNode: focusDestination,
                                    controller: destinationController,
                                    decoration: InputDecoration(
                                        hintText: 'Where to?',
                                        fillColor: Colors.grey[300],
                                        filled: true,
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.only(
                                            left: 10, top: 10, bottom: 1))),
                              ))),
                    ],
                  ),
                ],
              ),
            )),
        // (pickupPredictionList.length > 0)
        //     ? Padding(
        //         padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        //         child: ListView.separated(
        //           padding: EdgeInsets.all(0),
        //           itemBuilder: (context, index) {
        //             return PredictionTile(
        //               prediction: pickupPredictionList[index],
        //             );
        //           },
        //           separatorBuilder: (BuildContext context, int index) =>
        //               BrandDivider(),
        //           itemCount: pickupPredictionList.length,
        //           shrinkWrap: true,
        //           physics: ClampingScrollPhysics(),
        //         ),
        //       )
        //     : Container(),
        (destinationPredictionList.length > 0)
            ? Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListView.separated(
                  padding: EdgeInsets.all(0),
                  itemBuilder: (context, index) {
                    return PredictionTile(
                      prediction: destinationPredictionList[index],
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) =>
                      BrandDivider(),
                  itemCount: destinationPredictionList.length,
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                ),
              )
            : Container(),
      ],
    ));
  }
}
