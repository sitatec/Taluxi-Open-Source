import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/core_widgts.dart';
import 'package:user_manager/user_manager.dart';

import '../../../../core/utils/form_fields_validators.dart';
import 'commons_form_widgets.dart';

class SignUpForm extends StatefulWidget {
  final void Function() onLoginRequest;
  SignUpForm({@required this.onLoginRequest});

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  var email = '';
  var password = '';
  var firstName = '';
  var lastName = '';
  bool waitDialogIsShown = false;
  AuthenticationProvider authProvider;
  Timer facebookSignInSuggestionTimer;

  @override
  void initState() {
    super.initState();
    facebookSignInSuggestionTimer =
        Timer(Duration(milliseconds: 1100), _showFacebookSignInSuggestion);
  }

  @override
  void dispose() {
    facebookSignInSuggestionTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    authProvider = Provider.of<AuthenticationProvider>(context, listen: true);
    if (authProvider.authState == AuthState.registering) {
      Future.delayed(Duration.zero, () async {
        waitDialogIsShown = true;
        showWaitDialog('Inscription en cours', context);
      });
    }

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: height * .14),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30), color: Colors.white),
            padding: const EdgeInsets.all(4),
            child: const Text(
              "Inscription ",
              textScaleFactor: 1.7,
            ),
          ),
          SizedBox(height: 30),
          _form(),
          SizedBox(
            height: 15,
          ),
          FormValidatorButton(
            onClick: () async {
              if (_formKey.currentState.validate())
                await authProvider
                    .registerUser(
                      email: email,
                      password: password,
                      firstName: firstName,
                      lastName: lastName,
                    )
                    .then((_) => Navigator.of(context)
                        .popUntil((route) => route.isFirst))
                    .catchError(_onSignUpError);
            },
          ),
          _formLoginLink(),
        ],
      ),
    );
  }

  void _onSignUpError(dynamic error) async {
    if (waitDialogIsShown) {
      Navigator.of(context).pop();
      waitDialogIsShown = false;
    }
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Echec de la connexion'),
          content: Text(error.message),
          actions: [
            Center(
              child: RaisedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Fermer'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _form() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          CustomTextField(
            onChange: (value) => lastName = value,
            prefixIcon: Icon(Icons.person),
            maxLength: 30,
            title: "Nom",
            validator: namesValidator,
          ),
          CustomTextField(
            onChange: (value) => firstName = value,
            prefixIcon: Icon(Icons.person_outline),
            maxLength: 30,
            title: "Prénom",
            validator: namesValidator,
          ),
          CustomTextField(
            onChange: (value) => email = value,
            title: "Email",
            prefixIcon: Icon(Icons.email_rounded),
            fieldType: TextInputType.emailAddress,
            validator: emailFieldValidator,
          ),
          SizedBox(
            height: 16,
          ),
          PasswordField(
            onChanged: (value) => password = value,
          ),
        ],
      ),
    );
  }

  Future<void> _showFacebookSignInSuggestion() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text("Recommendation"),
          content: Text(
              "Cher utilisateur, si vous avez un compte Facebook il n'est pas nécessaire de créer un compte Taluxi, vous pouvez vous connecter à Taluxi à l'aide de votre compte Facebook. C'est plus facile et plus rapide,\nMerci de votre compréhension."),
          actions: [
            Center(
              child: RaisedButton(
                onPressed: () async {
                  await authProvider
                      .signInWithFacebook()
                      .then((_) => Navigator.of(context)
                          .popUntil((route) => route.isFirst))
                      .catchError(_onSignUpError);
                },
                child: Text("Me connecter à l'aide de Facebook"),
              ),
            ),
            Center(
              child: RaisedButton(
                child: Text("Créer un nouveau compte"),
                onPressed: () => Navigator.pop(context),
              ),
            )
          ],
        );
      },
    );
  }

  Widget _formLoginLink() {
    return Container(
      margin: EdgeInsets.only(top: 35),
      padding: EdgeInsets.symmetric(vertical: 7),
      alignment: Alignment.bottomCenter,
      child: InkWell(
        onTap: widget.onLoginRequest,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 27,
            ),
            Text(
              'Déjà inscrit ?  ',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            Text(
              'Cliquez ici pour vous connecter',
              style: TextStyle(
                  color: Color(0xfff79c4f),
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
