String validateMobile(String value) {
  String patttern = r'(^[0-9]*$)';
  RegExp regExp = new RegExp(patttern);
  if (value.length == 0) {
    return "Mobile number is Required";
  } else if (value.length != 11) {
    return "Mobile number must 11 digits";
  } else if (!regExp.hasMatch(value)) {
    return "Mobile Number must be digits";
  }
  return null;
}

String validatePassword(String value) {
  String pattern = r'^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[*.!@$%^&(){}[]:;<>,.?/~_+-=|\]).{8,32}$';
//RegExp regExp = new RegExp(pattern);
  if (value.length == 0) {
    return "Password required";
  }

  return null;
}

String validateBid(String value) {
  String pattern = r'^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[*.!@$%^&(){}[]:;<>,.?/~_+-=|\]).{8,32}$';
//RegExp regExp = new RegExp(pattern);
  if (value.length == 0) {
    return "Offer required";
  }

  return null;
}

String ValidateSearch(String value) {
  String patttern = r'(^[a-zA-Z ]*$)';
  RegExp regExp = new RegExp(patttern);
  if (value.length == 0) {
    return "City is Required";
  }
  return null;
}

String validateStars(String value) {
  String pattern = r'^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[*.!@$%^&(){}[]:;<>,.?/~_+-=|\]).{8,32}$';
//RegExp regExp = new RegExp(pattern);
  if (value.length == 0) {
    return "select Stars";
  }

  return null;
}

String validateEmail(String value) {
  String pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regExp = new RegExp(pattern);
  if (value.isEmpty || !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?").hasMatch(value)) {
    return 'Please enter a valid email';
  }
}

//String _buildPasswordConfirmTextField() {
//    validator: (String value) {
//      if (_passwordTextController.text != value) {
//        return 'Passwords do not match.';
//      }
//    },
//}

String validateAge(String value) {
  if (value.length == 0) {
    return "Age is required";
  } else if (int.parse(value) < 17) {
    return " You are not eligible must be 18 or above";
  } else if (value.length > 2) {
    return "please enter correct age";
  }
  return null;
}

String validateName(String value) {
  String patttern = r'(^[a-zA-Z ]*$)';
  RegExp regExp = new RegExp(patttern);
  if (value.length == 0) {
    return "Name is Required";
  } else if (!regExp.hasMatch(value)) {
    return "Name must be a-z and A-Z";
  }
  return null;
}

String validateTitle(String value) {
  String patttern = r'(^[a-zA-Z0-9- ]*$)';
  RegExp regExp = new RegExp(patttern);
  if (value.length == 0) {
    return "Field is Required";
  } else if (!regExp.hasMatch(value)) {
    return "Invalid no special character";
  }

  return null;
}

String validatePrice(String value) {
  String pattern = r'(^[0-9]*$)';
  RegExp regExp = new RegExp(pattern);
  if (value.length == 0) {
    return "Field is Required";
  } else if (!regExp.hasMatch(value)) {
    return "Numbers only please";
  }
  return null;
}

String validateBuildYear(String value) {
  String pattern = r'(^[0-9]*$)';
  String patternyear = r'(^(19|[2-3][0-9])\d{2}$)';
  RegExp regExp = new RegExp(pattern);
  RegExp regExpYear = new RegExp(patternyear);
  DateTime year = DateTime.now();
  if (value.length == 0) {
    return "Field is Required";
  } else if (!regExp.hasMatch(value)) {
    return "Numbers only please";
  } else if (!regExpYear.hasMatch(value)) {
    return 'Invalid year';
  } else if (int.parse(value) > year.year) {
    return 'Invalid year';
  }
  return null;
}

String validateMainFeatures(String value) {
  String pattern = r'(^[0-9]*$)';
  RegExp regExp = new RegExp(pattern);
  DateTime year = DateTime.now();
  if (value.length == 0) {
    return "Field is Required";
  } else if (!regExp.hasMatch(value)) {
    return "Numbers only please";
  }
  return null;
}

String validatePropertySize(String value) {
  String pattern = r'(^[0-9]*$)';
  RegExp regExp = new RegExp(pattern);
  if (!regExp.hasMatch(value)) {
    return "Numbers only please";
  }

  return null;
}

String validateAvailDays(String value) {
  String pattern = r'(^[0-9]*$)';
  RegExp regExp = new RegExp(pattern);
  if (value.length == 0) {
    return "Field is Required";
  } else if (regExp.hasMatch(value)) {
    return "Invalid";
  }

  return null;
}

String validatePropertySizeMarla(String value) {
  String patttern = r'(^[a-zA-Z]+$)';
  String pattern2 = r'(^[0-9]+$)';
  String pattern3 = r'(^[@~`!@#$%^&*()_=+\\;:"\/?><,-]*$)';
  RegExp regExp = new RegExp(patttern);
  RegExp regExp2 = new RegExp(pattern2);
  RegExp regExp3 = new RegExp(pattern3);
  if (regExp.hasMatch(value)) {
    print("in alphabet");
    return "Alphabets";
  }

  if (regExp2.hasMatch(value)) {
    print("int return null");
    return null;
  }

  if (regExp3.hasMatch(value)) {
    print("Special");
    return "Special";
  }

  return 'double';
}

String validateWidthheight(String value) {
  String patttern = r'(^\+?[1-9]\d*$)';
  RegExp regExp = new RegExp(patttern);
  if (!regExp.hasMatch(value)) {
    print("numbers");
    return "Required";
  }
  return null;
}

String ValidateLocation(String value) {
  String patttern = r'(^[a-zA-Z ]*$)';
  RegExp regExp = new RegExp(patttern);
  if (value.length == 0) {
    return "Location is Required";
  }
  return null;
}

String ValidateCity(String value) {
  String patttern = r'(^[a-zA-Z ]*$)';
  RegExp regExp = new RegExp(patttern);
  if (value.length == 0) {
    return "City is Required";
  }
  return null;
}

String validatePhoneNumber(String value){
  String pattern = r'(^((\+92))\d{3}\d{7}$)';
  RegExp regExp = new RegExp(pattern);

  if(!regExp.hasMatch(value)){
    return 'Please provide valid phone number with country code +92';
  }
  return null;
}

String ValidateDescp(String value) {
  String patttern = r'(^[a-zA-Z ]*$)';
  RegExp regExp = new RegExp(patttern);
  if (value.length == 0) {
    return "Description is Required";
  }
  return null;
}

String ValidateComment(String value) {
  String patttern = r'(^[a-zA-Z ]*$)';
  RegExp regExp = new RegExp(patttern);
  if (value.length == 0) {
    return "Comment is Required";
  }
  return null;
}

