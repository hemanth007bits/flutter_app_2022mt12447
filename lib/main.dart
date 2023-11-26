import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';


void main() async {
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  WidgetsFlutterBinding.ensureInitialized();
  const keyApplicationId = 'KBzMg0MdO7Vpu040EZ13olO9a8a5LEswQOBJ2pcv';
  const keyClientKey = 'YwiTzWvxD7yoL4B35uQ4rgbbk5CCuzPhcl2aC9F8';
  const keyParseServerUrl = 'https://parseapi.back4app.com';
  await Parse().initialize(
    keyApplicationId,
    keyParseServerUrl,
    clientKey: keyClientKey,
    debug: true,
    autoSendSessionId: true
  );

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.

  // var firstObject = ParseObject('FirstClass')
  //   ..set(
  //       'message', 'Hey ! First message from Flutter. Parse is now connected');
  // await firstObject.save();

  const B4aVehicle = ParseObject.extend('B4aVehicle');
const vehicle = new B4aVehicle();

vehicle.set('name', 'Corolla');
vehicle.set('price', 19499);
vehicle.set('color', 'black');

try {
  const savedObject = await vehicle.save(); 
  // The class is automatically created on
  // the back-end when saving the object!
  console.log(savedObject);
} catch (error) {
  console.error(error);
};



  print('done');

  //runApp(MyApp(settingsController: settingsController));
}