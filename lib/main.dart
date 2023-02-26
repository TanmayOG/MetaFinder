import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta_data_location/map.dart';
import 'package:native_exif/native_exif.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.

        fontFamily: GoogleFonts.poppins().fontFamily,
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var path;

  ImagePicker imagePicker = ImagePicker();

  LatLng? location;

  String? error;

  Map<String, Object>? data = {};

  getData() async {
    try {
      final exif = await Exif.fromPath(path);
      final originalDate = await exif.getOriginalDate();
      log('originalDate: $originalDate');
      Map<String, Object>? attributes = await exif.getAttributes();

      // log('originalDate: $originalDate');
      log('attributes: $attributes');

      setState(() {
        data = attributes;
      });

      double lat = double.parse(attributes!['GPSLatitude'].toString());
      var long = double.parse(attributes['GPSLongitude'].toString());

      var time = attributes['DateTimeOriginal'];
      var model = attributes['Model'];

      setState(() {
        location = LatLng(lat, long);
      });
      String dateTime = originalDate.toString();
      var newTime = DateTime.parse(dateTime);
      var newDate = newTime.toString().split(' ')[0];
      var newTime1 = newTime.toString().split(' ')[1];
      var newTime2 = newTime1.split('.')[0];
      var newTime3 = newTime2.split(':');
      var newTime4 = int.parse(newTime3[0]);
      var newTime5 = newTime4 > 12 ? newTime4 - 12 : newTime4;
      var newTime6 = '$newTime5:${newTime3[1]}:${newTime3[2]}';
      var newTime7 = newTime4 > 12 ? '$newTime6 PM' : '$newTime6 AM';

      var newDate1 = '$newDate $newTime7';

      log('newDate: $newDate1');

      if (location != null) {
        setState(() {
          error = null;
        });
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return MapDetails(
              location: location!, time: newDate1, Model: model.toString());
        }));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No location found'),
        ));

        setState(() {
          error = 'Oops! No location found in this image.';
        });

        log('error: $error');
      }

      log('lat: $lat');
      log('long: $long');
      log('time: $time');

      // change the format of time to 12 hr format and date to dd/mm/yyyy
      // 2023:02:20 17:14:31 to 20/02/2023 05:14:31 PM

      log('model: $model');
    } catch (e) {
      setState(() {
        error = 'Oops! No location found in this image.';
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No location found'),
      ));
    }
    // originalDate: 2023-02-20 17:14:31.000

    //{ApertureValue: 297/100, GPSLatitude: 19.297297222222223, ISOSpeedRatings: 100, GPSLongitudeRef: E, GPSTimeStamp: 11:11:37, ImageLength: 1280, Make: Google, GPSDateStamp: 2023:02:20, GPSLongitude: 72.84970277777778, Orientation: 1, SubSecTimeDigitized: 105, DateTime: 2023:02:20 17:14:31, DateTimeOriginal: 2023:02:20 17:14:31, SubSecTimeOriginal: 105, WhiteBalance: 0, DateTimeDigitized: 2023:02:20 17:14:31, GPSLatitudeRef: N, FocalLength: 5000/1000, ExposureTime: 0.01, ImageWidth: 960, Model: sdk_gphone64_x86_64, Flash: 0, SubSecTime: 105, FNumber: 2.8}

    // fetch la
  }

  choseImage() async {
    var image = await imagePicker.getImage(source: ImageSource.gallery);
    setState(() {
      path = image!.path;
    });
    await getData();
    // await getMetaData(path!);

    // final Map<String, dynamic> metadata = await FlutterExifRotation.
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title:
                const Text('MetaFinder', style: TextStyle(color: Colors.white)),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.black,
          ),
          body: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                // const Padding(
                //   padding: EdgeInsets.all(20.0),
                //   child: Text(
                //     'Save time and improve data accuracy with our automated meta data finder.',
                //     textAlign: TextAlign.center,
                //   ),
                // ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 20),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    // color: Colors.black,
                    // textColor: Colors.white

                    onPressed: () {
                      choseImage();
                    },
                    child: const Text('Choose Image')),
                const SizedBox(
                  height: 20,
                ),
                const Text('Select Image From Gallery to get Meta Data'),
                const SizedBox(
                  height: 20,
                ),
                Text(error ?? ''),
                const SizedBox(
                  height: 50,
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 20.0),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      "Meta Data :",
                      // textAlign: TextAlign.center, // 2023:02:20 17:14:31)
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),

                Text(
                  data.toString() == {} ? '' : data.toString(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 20,
                ),
                // const Text(
                //   'Made by Tanmay',
                //   textAlign: TextAlign.center,
                // ),
              ]))),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(const Duration(seconds: 4), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return const HomePage();
      }));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Center(
            child: Text(
              'MetaFinder',
              style: TextStyle(
                fontSize: 30,
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 5,
            width: 80,
            child: LinearProgressIndicator(
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
