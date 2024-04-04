import 'package:paymob_integration/models/login_model.dart';
import 'package:paymob_integration/screens/products_screen.dart';
import 'package:paymob_integration/shared/components/constants.dart';
//import 'package:school_bus/shared/components/functions.dart';

import 'package:flutter/material.dart';
import 'package:paymob_integration/shared/components/components.dart';
import 'package:paymob_integration/shared/cache_helper.dart';
import 'package:dio/dio.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var formKey = GlobalKey<FormState>();
  bool isLoading = false;
  UserData? userData;
  bool isLoginSucceeded = false; //
  bool isLoginFailed = false;
  // ignore: non_constant_identifier_names
  String? ErrorMessage;
  void userLogin({
    required String email,
    required String password,
  }) async {
    setState(() {
      isLoading = true;
    });
    Response value;
    final dio = Dio();

    try {
      value = await dio.post('$baseUrl/api/Account/login', data: {
        'email': email.trim(),
        'password': password.trim(),
      });
      print(value.data);
      if (value.data["status"] == false) {
        showToast(text: value.data["message"], state: ToastStates.ERROR);
        setState(() {
          isLoginSucceeded = true;
          isLoginFailed = true;
          isLoading = false;
          ErrorMessage = value.data["message"];
          //  errController.text = ErrorMessage!;
          return;
        });
      } else {
        userData = UserData.fromJson(value.data["data"]);
        print("UserData: $userData");
        CacheHelper.saveData(key: "roles", value: userData?.roles);
        CacheHelper.saveData(key: "userId", value: userData?.userId);
        CacheHelper.saveData(key: "phoneNumber", value: userData?.phoneNumber);
        CacheHelper.saveData(key: "email", value: email);
        FocusScope.of(context).unfocus();
        CacheHelper.saveData(
          key: 'token',
          value: userData?.token,
        ).then((v) {
          print("SavedToken: ${CacheHelper.getData(key: "token")}");

          setState(() {
            isLoginSucceeded = true;
            isLoginFailed = false;
            isLoading = false;
            ErrorMessage = null;
            errController.text = value.data.toString();
          });
          navigateAndFinish(
            context,
            const ProductsScreen(),
          );
        });
      }
    } catch (error) {
      print(error.toString());
      showToast(text: error.toString(), state: ToastStates.ERROR);
      setState(() {
        isLoginSucceeded = true;
        isLoginFailed = true;
        isLoading = false;
        ErrorMessage = error.toString();
        errController.text = ErrorMessage!;
      });
    }
  }

  bool isPassword = true;
  IconData suffix = Icons.visibility_outlined;
  void changePasswordVisibility() {
    setState(() {
      isPassword = !isPassword;
      suffix = isPassword
          ? Icons.visibility_outlined
          : Icons.visibility_off_outlined;
    });

    //emit(ChangePasswordVisibilityState());
  }

  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var errController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: appBarComponent(context, ""),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'تسجيل دخول',
                    style: TextStyle(
                        fontSize: 24,
                        color: Colors.black87.withOpacity(0.7),
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  defaultFormField(
                    controller: emailController,
                    type: TextInputType.emailAddress,
                    validate: (value) {
                      if (value.isEmpty) {
                        return "من فضلك ادخل البريد الإلكتروني!";
                      }
                      if (!value.trim().contains("@")) {
                        return "البريد الإلكتروني غير مكتوب بشكل صحيح";
                      }
                      return null;
                    },
                    label: "البريد الإلكتروني",
                    prefix: Icons.email_outlined,
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  defaultFormField(
                    controller: passwordController,
                    type: TextInputType.visiblePassword,
                    suffix: suffix,
                    onSubmit: (value) {
                      if (formKey.currentState!.validate()) {
                        userLogin(
                          email: emailController.text,
                          password: passwordController.text,
                        );
                      }
                    },
                    isPassword: isPassword,
                    suffixPressed: () {
                      changePasswordVisibility();
                    },
                    validate: (value) {
                      if (value.isEmpty) {
                        return "كلمة المرور قصيرة جداً!";
                      }
                      return null;
                    },
                    label: "كلمة المرور",
                    prefix: Icons.lock_outline,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              defaultButton(
                                function: () {
                                  if (formKey.currentState!.validate()) {
                                    userLogin(
                                      email: emailController.text,
                                      password: passwordController.text,
                                    );
                                  }
                                },
                                borderRadius: 5,
                                background:
                                    Theme.of(context).colorScheme.primary,
                                text: "تسجيل دخول",
                                isUpperCase: false,
                              ),
                              Directionality(
                                textDirection: TextDirection.rtl,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "ليس لديك حساب؟",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        print('Ok');
                                        // navigateTo(context, RegisterScreen());
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.green.shade700,
                                      ),
                                      child: const Text(
                                        "إنشاء حساب جديد",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                    onTap: () {
                                      // navigateTo(context,const ForgotPasswordScreen());
                                    },
                                    child: const Text(
                                      "نسيت كلمة المرور؟",
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 219, 124, 0),
                                          fontSize: 16),
                                    )),
                              )
                            ]),
                  const SizedBox(
                    height: 15.0,
                  ),
                  ErrorMessage != null
                      ? TextFormField(
                          controller: errController,
                          maxLines: 5,
                        )
                      : Center(child: Container()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class IOSInitializationSettings {
  const IOSInitializationSettings({required bool requestSoundPermission});
}
