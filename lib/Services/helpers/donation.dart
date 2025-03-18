import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class DonationPopup {
   static const   String backPressCountKey = 'backPressCount'; // Key for storing backPressCount
  final int backPressThreshold = 3; 
  static Future<void> showDonationPopup(
      BuildContext context, {
        bool alwaysShow = false,
      }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Retrieve the last shown dates for both intervals
    final DateTime? lastShownTwoWeeksDate = prefs.getString('lastDonationPopupTwoWeeksDate') != null
        ? DateTime.parse(prefs.getString('lastDonationPopupTwoWeeksDate')!)
        : null;

    final DateTime? lastShownTwoMonthsDate = prefs.getString('lastDonationPopupTwoMonthsDate') != null
        ? DateTime.parse(prefs.getString('lastDonationPopupTwoMonthsDate')!)
        : null;

    final DateTime now = DateTime.now();

    // Check if the popup should be shown for 2 weeks or 2 months
    bool shouldShowTwoWeeks = lastShownTwoWeeksDate == null || now.difference(lastShownTwoWeeksDate).inDays >= 14;
    bool shouldShowTwoMonths = lastShownTwoMonthsDate == null || now.difference(lastShownTwoMonthsDate).inDays >= 60;

    // If alwaysShow is true or any condition is met, display the popup
    if (alwaysShow || shouldShowTwoWeeks || shouldShowTwoMonths) {
      // Show the dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Column(
              children: [
                // Circular image
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/images/jhon_profile.jpg'), // Add your profile image here
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      getTranslated(context, 'donation_title'),
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(width: 10),
                    CircleAvatar(
                      radius: 15,
                      backgroundImage: AssetImage('assets/images/coffee.jpg'), // Add your coffee image here
                    ),
                  ],
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  getTranslated(context, 'donation_text'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  // Open the donation link
                  _openDonationLink();
                  Navigator.of(context).pop();
                },
                child: Text("Donate"),
              ),
            ],
          );
        },
      );

      // Save the current date for the respective intervals
      if (!alwaysShow) {
        if (shouldShowTwoWeeks) {
          prefs.setString('lastDonationPopupTwoWeeksDate', now.toIso8601String());
        }
        if (shouldShowTwoMonths) {
          prefs.setString('lastDonationPopupTwoMonthsDate', now.toIso8601String());
        }
      }
    }
  }

  static void _openDonationLink() {
    const url = 'https://www.picxer.org/donate.php';
    // Launch the URL in a browser
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
   
  static Future<int> getBackPressCount() async {
       
    final SharedPreferences prefs = await SharedPreferences.getInstance();
  
    return prefs.getInt(backPressCountKey) ?? 0;
  }

  static Future<void> incrementBackPressCount() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentCount = await getBackPressCount();
    await prefs.setInt(backPressCountKey, currentCount + 1);
  }

  static Future<void> resetBackPressCount() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(backPressCountKey, 0);
  }
}
