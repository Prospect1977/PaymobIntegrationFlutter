import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:paymob_integration/shared/styles/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget defaultButton({
  double width = double.infinity,
  Color background = defaultColor,
  Color foregroundColor = Colors.white,
  bool isUpperCase = false,
  double borderRadius = 3.0,
  double fontSize = 18,
  FontWeight fontWeight = FontWeight.normal,
  required VoidCallback? function,
  required String text,
}) =>
    Container(
      width: width,
      height: 50.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          borderRadius,
        ),
        color: background,
      ),
      child: MaterialButton(
        onPressed: function,
        child: Text(
          isUpperCase ? text.toUpperCase() : text,
          style: TextStyle(
            color: foregroundColor,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ),
      ),
    );
void navigateTo(context, widget) => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => widget,
      ),
    );
void navigateAndFinish(
  context,
  widget,
) =>
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => widget,
      ),
      (route) {
        return false;
      },
    );
Widget defaultFormField(
        {required TextEditingController controller,
        required TextInputType type, //TextInputType.number
        ValueChanged<String>? onSubmit,
        ValueChanged<String>? onChange,
        GestureTapCallback? onTap,
        bool isPassword = false,
        VoidCallback? function,
        required String label,
        IconData? prefix,
        IconData? suffix,
        VoidCallback? suffixPressed,
        bool isClickable = true,
        dynamic defaultValue,
        String? hintText,
        required FormFieldValidator validate,
        int? maximumLines}) =>
    TextFormField(
      maxLines: maximumLines ?? 1,
      controller: controller,
      keyboardType: type,
      obscureText: isPassword,
      enabled: isClickable,
      onFieldSubmitted: onSubmit,
      onChanged: onChange,
      initialValue: defaultValue,
      onTap: onTap,
      validator: validate,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: label,
        prefixIcon: prefix != null
            ? Icon(
                prefix,
              )
            : null,
        suffixIcon: suffix != null
            ? IconButton(
                onPressed: suffixPressed,
                icon: Icon(
                  suffix,
                ),
              )
            : null,
        border: const OutlineInputBorder(),
      ),
    );

void showToast({
  required String text,
  required ToastStates state,
}) =>
    Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 5,
      backgroundColor: chooseToastColor(state),
      textColor: Colors.white,
      fontSize: 16.0,
    );

// enum
// ignore: constant_identifier_names
enum ToastStates { SUCCESS, ERROR, WARNING, LIGHT }

Color chooseToastColor(ToastStates state) {
  Color color;

  switch (state) {
    case ToastStates.SUCCESS:
      color = Colors.green;
      break;
    case ToastStates.ERROR:
      color = Colors.red;
      break;
    case ToastStates.WARNING:
      color = Colors.amber;
      break;
    case ToastStates.LIGHT:
      color = Colors.black12;
      break;
  }

  return color;
}

var appBarActions = [
  PopupMenuButton(
      iconSize: 30,
      icon: const Icon(
        Icons.more_vert,
        size: 20,
        color: Colors.black87,
      ),
      onSelected: (SelectedValue) => {print(SelectedValue)},
      itemBuilder: (ctx) => [
            PopupMenuItem(
              child: const Text('خروج'),
              value: 2,
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove("token");
                await prefs.remove("roles");
                await prefs.remove("userId");

                //   navigateAndFinish(ctx, LoginScreen());
              },
            ),
          ]),
];

// ignore: must_be_immutable
class appBarComponent extends StatelessWidget implements PreferredSizeWidget {
  appBarComponent(context, this.title, {this.backButtonPage, key})
      : super(key: key);
  final String title;
  Widget? backButtonPage;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.only(top: 5, left: 8, right: 8),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: CircleAvatar(
                radius: 15,
                backgroundColor: Colors.black38,
                child: Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios_rounded),
                    iconSize: 15,
                    onPressed: backButtonPage == null
                        ? () {
                            Navigator.maybePop(context);
                          }
                        : () {
                            navigateAndFinish(context, backButtonPage);
                          },
                    color: Colors.white,
                  ),
                ),
              )),
          Expanded(
            child: Container(
              height: 30,
              // padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.black26,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 45, height: 45, child: appBarActions[0])
        ]),
      ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => throw UnimplementedError();
}
