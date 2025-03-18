import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiberchat/Configs/Dbkeys.dart';
import 'package:fiberchat/Configs/Dbpaths.dart';
import 'package:fiberchat/Configs/Enum.dart';
import 'package:fiberchat/Models/DataModel.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:fiberchat/Utils/chat_controller.dart';
import 'package:fiberchat/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:fiberchat/Screens/chat_screen/utils/aes_encryption.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fiberchat/Models/E2EE/e2ee.dart' as e2ee;

FlutterSecureStorage storage = new FlutterSecureStorage();

void checkAndSendWelcomeMessage(
    String currentuserphone,
    Map<String, String> newContactsInContactbookWhoHavePicxer,
    DataModel? model,
    BuildContext context) async {
  if (newContactsInContactbookWhoHavePicxer.length > 0) {
    print("CodeAv: currentuserphone: " + currentuserphone);

    //Liste welche der Kontakte des Adressbuchs Picxer haben:
    print("CodeAv: newContactsInContactbookWhoHavePicxer: " +
        newContactsInContactbookWhoHavePicxer.length.toString());

    //Liste wem der user schon WelcomeMessage geschickt hat:
    List<String> peerPhoneNoAlreadySentWelcomeMessageString = [];
    try {
      await FirebaseFirestore.instance
          .collection(DbPaths.collectionusers)
          .doc(currentuserphone)
          .get()
          .then((DocumentSnapshot docSnapshot) {
        if (docSnapshot.exists) {
          Map<String, dynamic>? data =
              docSnapshot.data() as Map<String, dynamic>?;
          if (data != null) {
            List<dynamic> peerPhoneNoAlreadySentWelcomeMessage =
                data['welcomeMessageSentTo'];
            peerPhoneNoAlreadySentWelcomeMessage.forEach((phoneNo) {
              if (phoneNo is String) {
                peerPhoneNoAlreadySentWelcomeMessageString.add(phoneNo);
                print("CodeAv: peerPhoneNoAlreadySentWelcomeMessageString: " +
                    peerPhoneNoAlreadySentWelcomeMessageString.length
                        .toString() +
                    peerPhoneNoAlreadySentWelcomeMessageString.toString());
              }
            });
          }
        }
      });
    } catch (e) {}

    //Liste mit wem der User schon chattet:
    List<String> peerPhoneNoAlreadyChatting = [];
    Map<String, String> usersToSendWelcomeMessageTo = {};
    await FirebaseFirestore.instance
        .collection(DbPaths.collectionusers)
        .doc(currentuserphone)
        .collection("chatsWith")
        .doc("chatsWith")
        .get()
        .then(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        data.forEach((key, value) {
          if (value != ChatStatus.blocked.index) {
            peerPhoneNoAlreadyChatting.add(key);
          }
        });
        //Liste an wen versendet werden muss:
        newContactsInContactbookWhoHavePicxer
            .forEach((peerphone, peerPublicKey) {
          if (!peerPhoneNoAlreadyChatting.contains(peerphone) &&
              !peerPhoneNoAlreadySentWelcomeMessageString.contains(peerphone)) {
            print("CodeAv: Adding peer: " + peerphone);
            usersToSendWelcomeMessageTo[peerphone] = peerPublicKey;
          }
        });

        if (usersToSendWelcomeMessageTo.length > 0) {
          try {
            List<String> usersToSendWelcomeMessageToAsString = [];
            usersToSendWelcomeMessageTo.forEach((phone, publicKey) {
              usersToSendWelcomeMessageToAsString.add(phone);
            });
            FirebaseFirestore.instance
                .collection(DbPaths.collectionusers)
                .doc(currentuserphone)
                .update({
              "welcomeMessageSentTo":
                  FieldValue.arrayUnion(usersToSendWelcomeMessageToAsString)
            });
          } catch (e) {
            Fiberchat.toast(
                'Failed to update Welcome message array in firebase. Error:$e');
            print(
                'Failed to update Welcome message array in firebase. Error:$e');
          }

          usersToSendWelcomeMessageTo.forEach((peerphone, peerPublicKey) {
            print("CodeAv: I send a welcomemessage to: " + peerphone);
            sendWelcomeMessage(
                currentuserphone, peerphone, peerPublicKey, model, context);
          });
        }

        print("CodeAv: peerPhoneNoAlreadyChatting: " +
            peerPhoneNoAlreadyChatting.length.toString() +
            peerPhoneNoAlreadyChatting.toString());

        print("CodeAv: usersToSendWelcomeMessageTo" +
            usersToSendWelcomeMessageTo.length.toString() +
            usersToSendWelcomeMessageTo.toString());
      },
      onError: (e) => print("Error getting document: $e"),
    );
  }
}

void sendWelcomeMessage(String currentuserphone, String peerNo,
    String peerPublicKey, DataModel? model, BuildContext context) async {
  try {
    if (model == null) {
      print("error: Datamodel is null in jh_sendWelcome..");
    } else {
      String? chatId = Fiberchat.getChatId(currentuserphone, peerNo);
      await FirebaseFirestore.instance
          .collection(DbPaths.collectionmessages)
          .doc(chatId)
          .set({
        currentuserphone: true,
        currentuserphone + '-lastOnline': DateTime.now().millisecondsSinceEpoch
      }, SetOptions(merge: true));

      await ChatController.request(currentuserphone, peerNo, chatId);

      String? privateKey = await storage.read(key: Dbkeys.privateKey);
      String? sharedSecret = (await e2ee.X25519().calculateSharedSecret(
              e2ee.Key.fromBase64(privateKey!, false),
              e2ee.Key.fromBase64(peerPublicKey, true)))
          .toBase64();
      print("sharedSecret was successfull: " +
          sharedSecret +
          "  publicKey: " +
          peerPublicKey);

      final encrypted = AESEncryptData.encryptAES(
          getTranslated(context, 'welcomemessage'), sharedSecret);

      int timestamp = DateTime.now().millisecondsSinceEpoch;

      if (encrypted is String) {
        Future messaging = FirebaseFirestore.instance
            .collection(DbPaths.collectionmessages)
            .doc(chatId)
            .collection(chatId)
            .doc('$timestamp')
            .set({
          Dbkeys.isMuted: false,
          Dbkeys.from: currentuserphone,
          Dbkeys.to: peerNo,
          Dbkeys.timestamp: timestamp,
          Dbkeys.content: encrypted,
          Dbkeys.messageType: MessageType.text.index,
          Dbkeys.hasSenderDeleted: false,
          Dbkeys.hasRecipientDeleted: false,
          Dbkeys.sendername: model.currentUser![Dbkeys.nickname],
          Dbkeys.isReply: false,
          Dbkeys.replyToMsgDoc: null,
          Dbkeys.isForward: false,
          Dbkeys.latestEncrypted: true,
        }, SetOptions(merge: true));
        print("CodeAv: Sende Nachricht an: " +
            peerNo +
            "; " +
            timestamp.toString() +
            "; " +
            messaging.toString());
        model.addMessage(peerNo, timestamp, messaging);
      }
    }
  } catch (e) {
    Fiberchat.toast('Failed to send Welcome message. Error:$e');
    print('Failed to send Welcome message. Error:$e');
  }
}
