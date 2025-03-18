/*von ChatGPT mit "please write a code in flutter and dart which will:
Open a pop-up window with an input-field. The user should be able to write an email-adress in this field which will then be provided as variable "userMail". Additionally, this email-adress (together with all email-adresses which the user has put in in the past) should be saved locally and they should be provided as input-suggestion when the user opens the pop-up window the next time.  The box should have an OK-Button and a Cancel-Button"*/
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmailInputDialog extends StatefulWidget {
  @override
  _EmailInputDialogState createState() => _EmailInputDialogState();
}

class _EmailInputDialogState extends State<EmailInputDialog> {
  final TextEditingController _emailController = TextEditingController();
  List<String> _previousEmails = [];

  @override
  void initState() {
    super.initState();
    _loadPreviousEmails();
  }

  Future<void> _loadPreviousEmails() async {
    final prefs = await SharedPreferences.getInstance();
    final previousEmails = prefs.getStringList('previousEmails') ?? [];
    setState(() {
      _previousEmails = previousEmails;
    });
  }

  Future<void> _saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final previousEmails =
        prefs.getStringList('previousEmails')?.cast<String>() ?? [];

    // Check if email is already present in previousEmails
    if (!previousEmails.contains(email)) {
      final newEmails = List.from(previousEmails)..add(email);
      await prefs.setStringList('previousEmails', newEmails.cast<String>());
      setState(() {
        _previousEmails = newEmails.cast<String>();
      });
    }
  }

  final _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(getTranslated(context, 'mailofcontact')),
      content: TextField(
        controller: _emailController,
        decoration: InputDecoration(
          hintText: 'Email',
          suffixIcon: _previousEmails.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.arrow_drop_down),
                  onPressed: () async {
                    final email = await showDialog<String>(
                      context: context,
                      builder: (context) {
                        return _EmailSuggestionsDialog(emails: _previousEmails);
                      },
                    );
                    if (email != null) {
                      _emailController.text = email;
                    }
                  },
                )
              : null,
        ),
        keyboardType: TextInputType.emailAddress,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(getTranslated(context, 'cancel')),
        ),
        TextButton(
          onPressed: () async {
            final email = _emailController.text.trim();
            if (_emailRegex.hasMatch(email)) {
              await _saveEmail(email);
              Navigator.of(context).pop(email);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(getTranslated(context, "correctmail")),
                  duration: Duration(seconds: 3),
                ),
              );
            }
          },
          child: Text('OK'),
        ),
      ],
    );
  }
}

class _EmailSuggestionsDialog extends StatelessWidget {
  final List<String> emails;

  const _EmailSuggestionsDialog({Key? key, required this.emails})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text('Email Suggestions'),
      children: [
        for (final email in emails)
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(context).pop(email);
            },
            child: Text(email),
          ),
      ],
    );
  }
}
