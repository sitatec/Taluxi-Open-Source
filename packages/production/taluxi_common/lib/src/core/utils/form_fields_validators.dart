String namesValidator(value) {
  if (value.isEmpty) return "Ce champ est requis";
  if (value.length < 3) return "Ce champ requière au minimum 3 lettres";
  if (value.length > 30) return "Ce champ ne doit pas dépasser 30 lettres";
  if (value.contains(RegExp("[0-9]")))
    return "Ce champ ne doit pas contenir de nombres";
  return null;
}

String phoneNumberValidator(String value) {
  var parsedValue = int.tryParse(value);
  if (parsedValue == null || parsedValue.toString().length != 9)
    return "Numéro de téléphone invalide";
  return null;
}

String passWordValidator(String value) {
  if (value.isEmpty) return "Ce champ est requis";
  if (value.length < 6) return "Mot de pass trop court";
  if (value.length > 40) return "Mot de passe trop long";
  return null;
}

String emailFieldValidator(String value) {
  if (value.isEmpty) return "Ce champ est requis";
  Pattern pattern =
      r'^(([^<>()[\]\\.,%`~&ç;:\s@\"]+(\.[^<>()[\]\\.,%`~&ç;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,15}))$';
  if (RegExp(pattern).hasMatch(value)) return null;
  return "Adresse email invalide";
}
