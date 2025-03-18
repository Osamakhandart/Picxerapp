# Picxer: Comprehensive Communication Platform

## Overview
Picxer is a dynamic communication platform designed to enhance connectivity through robust messaging, voice, and video call functionalities. With over 10,000 downloads, the app has been effectively serving users since its release, providing an intuitive interface for seamless interaction and sharing.

## App Information
- **Version**: 1.1.6
- **Updated on**: 26 Jan 2025
- **Requires Android**: 7.0 and up
- **Downloads**: 10,000+ downloads
- **Content Rating**: USK: All ages
- **Interactive Elements**: Users interact, Shares location
- **Release Date**: 6 Mar 2023
- **Offered by**: Google Commerce Ltd
- **Download Size**: ~164 MB (varies with device)

## Project Structure

Below is the directory structure of the project, highlighting the organization of various components:

```bash
Picxer/
├ ──lib
│   ├── .DS_Store
│   ├── Configs
│   │   ├── Dbkeys.dart
│   │   ├── Dbpaths.dart
│   │   ├── Enum.dart
│   │   ├── app_constants.dart
│   │   └── optional_constants.dart
│   ├── Models
│   │   ├── DataModel.dart
│   │   ├── E2EE
│   │   │   ├── e2ee.dart
│   │   │   ├── key.dart
│   │   │   └── x25519.dart
│   │   ├── call.dart
│   │   └── call_methods.dart
│   ├── Screens
│   │   ├── .DS_Store
│   │   ├── Broadcast
│   │   │   ├── AddContactsToBroadcast.dart
│   │   │   ├── BroadcastChatPage.dart
│   │   │   ├── BroadcastDetails.dart
│   │   │   └── EditBroadcastDetails.dart
│   │   ├── Groups
│   │   │   ├── AddContactsToGroup.dart
│   │   │   ├── EditGroupDetails.dart
│   │   │   ├── GroupChatPage.dart
│   │   │   ├── GroupDetails.dart
│   │   │   └── widget
│   │   │       └── groupChatBubble.dart
│   │   ├── SettingsOption
│   │   │   └── settingsOption.dart
│   │   ├── auth_screens
│   │   │   ├── authentication.dart
│   │   │   └── login.dart
│   │   ├── call_history
│   │   │   ├── callhistory.dart
│   │   │   └── utils
│   │   │       └── InfiniteListView.dart
│   │   ├── calling_screen
│   │   │   ├── audio_call.dart
│   │   │   ├── pickup_layout.dart
│   │   │   ├── pickup_screen.dart
│   │   │   └── video_call.dart
│   │   ├── chat_screen
│   │   │   ├── Widget
│   │   │   │   └── bubble.dart
│   │   │   ├── chat.dart
│   │   │   ├── pre_chat.dart
│   │   │   └── utils
│   │   │       ├── aes_encryption.dart
│   │   │       ├── audioPlayback.dart
│   │   │       ├── deleteChatMedia.dart
│   │   │       ├── downloadMedia.dart
│   │   │       ├── message.dart
│   │   │       ├── messagedata.dart
│   │   │       ├── photo_view.dart
│   │   │       └── uploadMediaWithProgress.dart
│   │   ├── contact_screens
│   │   │   ├── AddunsavedContact.dart
│   │   │   ├── ContactsSelect.dart
│   │   │   ├── SelectContactsToForward.dart
│   │   │   ├── SmartContactsPage.dart
│   │   │   └── contacts.dart
│   │   ├── homepage
│   │   │   ├── Setupdata.dart
│   │   │   ├── homepage.dart
│   │   │   └── initialize.dart
│   │   ├── notifications
│   │   │   ├── AllNotifications.dart
│   │   │   └── NotificationViewer.dart
│   │   ├── privacypolicy&TnC
│   │   │   └── PdfViewFromCachedUrl.dart
│   │   ├── profile_settings
│   │   │   ├── profileSettings.dart
│   │   │   └── profile_view.dart
│   │   ├── recent_chats
│   │   │   ├── RecentChatsWithoutLastMessage.dart
│   │   │   ├── RecentsChats.dart
│   │   │   └── widgets
│   │   │       ├── getBroadcastMessageTile.dart
│   │   │       ├── getGroupMessageTile.dart
│   │   │       ├── getLastMessageTime.dart
│   │   │       ├── getMediaMessage.dart
│   │   │       └── getPersonalMessageTile.dart
│   │   ├── search_chats
│   │   │   └── SearchRecentChat.dart
│   │   ├── security_screens
│   │   │   └── security.dart
│   │   ├── sharing_intent
│   │   │   └── SelectContactToShare.dart
│   │   ├── splash_screen
│   │   │   └── splash_screen.dart
│   │   └── status
│   │       ├── StatusView.dart
│   │       ├── components
│   │       │   ├── ImagePicker
│   │       │   │   └── image_picker.dart
│   │       │   ├── TextStatus
│   │       │   │   └── textStatus.dart
│   │       │   ├── VideoPicker
│   │       │   │   ├── VideoPicker.dart
│   │       │   │   └── VideoPreview.dart
│   │       │   ├── circleBorder.dart
│   │       │   ├── formatStatusTime.dart
│   │       │   └── showViewers.dart
│   │       ├── status.dart
│   │       └── status_camera_opener.dart
│   ├── Services
│   │   ├── .DS_Store
│   │   ├── Admob
│   │   │   └── admob.dart
│   │   ├── Providers
│   │   │   ├── BroadcastProvider.dart
│   │   │   ├── DownloadInfoProvider.dart
│   │   │   ├── FirebaseAPIProvider.dart
│   │   │   ├── GroupChatProvider.dart
│   │   │   ├── LazyLoadingChatProvider.dart
│   │   │   ├── Observer.dart
│   │   │   ├── SmartContactProviderWithLocalStoreData.dart
│   │   │   ├── StatusProvider.dart
│   │   │   ├── TimerProvider.dart
│   │   │   ├── call_history_provider.dart
│   │   │   ├── currentchat_peer.dart
│   │   │   ├── seen_provider.dart
│   │   │   ├── seen_state.dart
│   │   │   └── user_provider.dart
│   │   ├── helpers
│   │   │   ├── curves.dart
│   │   │   ├── decorations.dart
│   │   │   ├── donation.dart
│   │   │   ├── jh_MailPopup.dart
│   │   │   ├── jh_backgroundService.dart
│   │   │   ├── jh_cardsForRecentchats.dart
│   │   │   ├── jh_intent
│   │   │   │   ├── jh_firebaseInitialization.dart
│   │   │   │   ├── jh_intentConstent.dart
│   │   │   │   ├── jh_mediaPreview.dart
│   │   │   │   ├── jh_scaffoldExtention.dart
│   │   │   │   ├── jh_shareIntent.dart
│   │   │   │   ├── jh_sharingViewUi.dart
│   │   │   │   ├── jh_userDetailModel.dart
│   │   │   │   └── jh_userListing.dart
│   │   │   ├── jh_onBackToRecents.dart
│   │   │   ├── jh_photo_view_loader.dart
│   │   │   ├── jh_progressService.dart
│   │   │   ├── jh_searchProduct.dart
│   │   │   ├── jh_sendWelcomeMessage.dart
│   │   │   ├── jh_sendWithWifiUtils.dart
│   │   │   ├── jh_uploadInBackground.dart
│   │   │   ├── jh_wifiPermissions.dart
│   │   │   ├── jh_wifiTransfer.dart
│   │   │   ├── misc.dart
│   │   │   ├── print.dart
│   │   │   ├── size.dart
│   │   │   ├── transition.dart
│   │   │   ├── type_defs.dart
│   │   │   └── widgets
│   │   │       ├── alert_method.dart
│   │   │       ├── align.dart
│   │   │       ├── animated_interactive_viewer.dart
│   │   │       ├── interactive_table.dart
│   │   │       ├── lazy_load_builder.dart
│   │   │       ├── slivers.dart
│   │   │       └── widgets.dart
│   │   └── localization
│   │       ├── demo_localization.dart
│   │       ├── json_languages
│   │       │   ├── ar.json
│   │       │   ├── bg.json
│   │       │   ├── ca.json
│   │       │   ├── cs.json
│   │       │   ├── da.json
│   │       │   ├── de.json
│   │       │   ├── el.json
│   │       │   ├── en.json
│   │       │   ├── es.json
│   │       │   ├── et.json
│   │       │   ├── fi.json
│   │       │   ├── fr.json
│   │       │   ├── he.json
│   │       │   ├── hi.json
│   │       │   ├── hr.json
│   │       │   ├── hu.json
│   │       │   ├── id.json
│   │       │   ├── is.json
│   │       │   ├── it.json
│   │       │   ├── ja.json
│   │       │   ├── ko.json
│   │       │   ├── lt.json
│   │       │   ├── lv.json
│   │       │   ├── ms.json
│   │       │   ├── mt.json
│   │       │   ├── nl.json
│   │       │   ├── no.json
│   │       │   ├── pl.json
│   │       │   ├── pt.json
│   │       │   ├── ro.json
│   │       │   ├── ru.json
│   │       │   ├── sk.json
│   │       │   ├── sl.json
│   │       │   ├── sr.json
│   │       │   ├── sv.json
│   │       │   ├── th.json
│   │       │   ├── tr.json
│   │       │   ├── uk.json
│   │       │   ├── vi.json
│   │       │   └── zh.json
│   │       ├── language.dart
│   │       └── language_constants.dart
│   ├── Utils
│   │   ├── alias.dart
│   │   ├── batch_write_component.dart
│   │   ├── call_utilities.dart
│   │   ├── chat_controller.dart
│   │   ├── color_detector.dart
│   │   ├── compress.dart
│   │   ├── crc.dart
│   │   ├── custom_url_launcher.dart
│   │   ├── emoji_detect.dart
│   │   ├── error_codes.dart
│   │   ├── late_load.dart
│   │   ├── mime_type.dart
│   │   ├── open_settings.dart
│   │   ├── permissions.dart
│   │   ├── phonenumberVariantsGenerator.dart
│   │   ├── save.dart
│   │   ├── setStatusBarColor.dart
│   │   ├── theme_management.dart
│   │   ├── unawaited.dart
│   │   └── utils.dart
│   ├── firebase_options.dart
│   ├── generated
│   │   └── assets.dart
│   ├── main.dart
│   ├── share.dart
│   └── widgets
│       ├── .DS_Store
│       ├── AllinOneCameraGalleryImageVideoPicker
│       │   └── AllinOneCameraGalleryImageVideoPicker.dart
│       ├── AudioRecorder
│       │   ├── Audiorecord.dart
│       │   └── playButton.dart
│       ├── Audioplayer
│       │   └── audioplayer.dart
│       ├── CameraGalleryImagePicker
│       │   ├── camera_image_gallery_picker.dart
│       │   ├── image_pick.dart
│       │   └── multiMediaPicker.dart
│       ├── Common
│       │   └── cached_image.dart
│       ├── CountryPicker
│       │   ├── CountryCode.dart
│       │   ├── country.dart
│       │   └── country_picker.dart
│       ├── DocumentPicker
│       │   └── documentPicker.dart
│       ├── DownloadManager
│       │   ├── download_all_file_type.dart
│       │   └── save_image_videos_in_gallery.dart
│       ├── DynamicBottomSheet
│       │   └── dynamic_modal_bottomsheet.dart
│       ├── ImagePicker
│       │   └── image_picker.dart
│       ├── InfiniteList
│       │   └── InfiniteCOLLECTIONListViewWidget.dart
│       ├── MultiDocumentPicker
│       │   └── multiDocumentPicker.dart
│       ├── MultiImagePicker
│       │   └── multiImagePicker.dart
│       ├── MyElevatedButton
│       │   └── MyElevatedButton.dart
│       ├── Passcode
│       │   ├── circle.dart
│       │   ├── keyboard.dart
│       │   ├── passcode_screen.dart
│       │   └── shake_curve.dart
│       ├── PhoneField
│       │   ├── countries.dart
│       │   ├── intl_phone_field.dart
│       │   └── phone_number.dart
│       ├── PhotoEditor
│       │   ├── photoeditor.dart
│       │   └── widgets
│       │       ├── common_widget.dart
│       │       ├── crop_editor_helper.dart
│       │       └── image_picker
│       │           ├── _image_picker_io.dart
│       │           └── image_picker.dart
│       ├── SoundPlayer
│       │   ├── SoundPlayerPro.dart
│       │   └── soundPlayer.dart
│       ├── VideoEditor
│       │   └── video_editor.dart
│       ├── VideoPicker
│       │   ├── VideoPicker.dart
│       │   └── VideoPreview.dart
│       └── story_view
│           ├── controller
│           │   └── story_controller.dart
│           ├── utils.dart
│           └── widgets
│               ├── story_image.dart
│               ├── story_video.dart
│               └── story_view.dart
├── pubspec.lock
└── pubspec.yaml
## Features

- **Authentication**: Robust authentication system ensuring secure access.
- **Real-time Communication**: Seamless voice and video calls along with instant messaging.
- **Media Sharing**: Comprehensive media sharing capabilities including photos, videos, and location.
- **User Privacy**: Strong privacy policies ensuring user data protection.
