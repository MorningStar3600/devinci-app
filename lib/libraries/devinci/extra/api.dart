import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:devinci/extra/globals.dart' as globals;
import 'package:intl/intl.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class DevinciApi {
  void register() async {
    if (globals.user != null) {
      if (globals.notifConsent) {
        var lastNotifRegistration =
            globals.prefs.getString('lastNotifRegistration') ?? '';
        String currentDate;
        final now = DateTime.now();
        final formatter = DateFormat('dd/MM/yyyy');
        currentDate = formatter.format(now);
        if (currentDate != lastNotifRegistration) {
          //on peut envoyer notre registration

          await globals.user.getPresence();
          var hashes = <String>[];
          globals.user.presence.forEach((presence) {
            var bytes = utf8.encode(presence['title'] +
                presence['prof'] +
                presence['horaires']); // data being hashed
            var digest = sha256.convert(bytes);
            hashes.add(digest.toString());
          });
          print(hashes);
          var client = HttpClient();
          var uri = Uri.parse('https://api.devinci.araulin.tech/register');
          var req = await client.postUrl(uri);
          req.headers.set('content-type', 'application/json');
          var sub = await OneSignal.shared.getPermissionSubscriptionState();
          var sub2 = sub.subscriptionStatus;
          var id = sub2.userId;
          if (id != '') {
            var data = <String, dynamic>{'id': id, 'hashes': hashes};
            req.add(utf8.encode(json.encode(data)));
            var response = await req.close();
            var reply = await response.transform(utf8.decoder).join();
            print(reply);
            await globals.prefs.setString('lastNotifRegistration', currentDate);
            client.close();
          } else {
            print('no player id');
          }
        } else {
          print("can't send notif");
        }
      } else {
        print('no notif consent');
      }
    } else {
      print('user not existing');
    }
  }

  void call(String hash) async {
    if (globals.user != null) {
      if (globals.notifConsent) {
        var client = HttpClient();
        var uri = Uri.parse('https://api.devinci.araulin.tech/call');
        var req = await client.postUrl(uri);
        req.headers.set('content-type', 'application/json');
        var sub = await OneSignal.shared.getPermissionSubscriptionState();
        var sub2 = sub.subscriptionStatus;
        var id = sub2.userId;
        if (id != '') {
          var data = <String, dynamic>{'id': id, 'hash': hash};
          req.add(utf8.encode(json.encode(data)));
          var response = await req.close();
          var reply = await response.transform(utf8.decoder).join();
          print(reply);
          client.close();
        } else {
          print('no player id');
        }
      } else {
        print('no notif consent');
      }
    } else {
      print('user not existing');
    }
  }
}
