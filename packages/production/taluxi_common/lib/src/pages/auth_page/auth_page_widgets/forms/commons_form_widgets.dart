import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/utils/form_fields_validators.dart';

class CustomTextField extends StatelessWidget {
  final String title;
  final bool isPassword;
  final String Function(String) validator;
  final void Function(String) onChange;
  final TextInputType fieldType;
  final int maxLength;
  final String helperText;
  final Widget prefixIcon;
  final Widget suffixIcon;
  const CustomTextField(
      {@required this.title,
      this.fieldType,
      this.validator,
      this.maxLength,
      this.helperText,
      this.prefixIcon,
      this.onChange,
      this.suffixIcon,
      this.isPassword = false});

  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
              onChanged: onChange,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              maxLength: maxLength,
              keyboardType: fieldType,
              validator: validator,
              onEditingComplete: () => node.nextFocus(),
              obscureText: isPassword,
              decoration: InputDecoration(
                suffixIcon: suffixIcon,
                labelText: title,
                prefixIcon: prefixIcon,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                helperText: helperText,
              ))
        ],
      ),
    );
  }
}

class PasswordField extends StatefulWidget {
  final void Function(String) onChanged;
  const PasswordField({Key key, this.onChanged}) : super(key: key);

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool isHiddenPassword = true;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      onChange: widget.onChanged,
      suffixIcon: IconButton(
        icon: Icon(
          isHiddenPassword ? Icons.visibility : Icons.visibility_off,
        ),
        onPressed: () => setState(() => isHiddenPassword = !isHiddenPassword),
      ),
      maxLength: 40,
      prefixIcon: Icon(Icons.lock),
      title: "Mot de passe",
      isPassword: isHiddenPassword,
      validator: passWordValidator,
    );
  }
}

class FormValidatorButton extends StatelessWidget {
  final String title;
  final void Function() onClick;
  const FormValidatorButton({Key key, this.onClick, this.title = "Valider"})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onClick(),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.grey.shade200,
              offset: Offset(2, 4),
              blurRadius: 5,
              spreadRadius: 2,
            )
          ],
          gradient: mainLinearGradient,
        ),
        child: Text(
          title,
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }
}

// const passWordField = CustomTextField(
//   maxLength: 40,
//   prefixIcon: Icon(Icons.lock),
//   title: "Mot de passe",
//   isPassword: true,
//   validator: passWordValidator,
// );
