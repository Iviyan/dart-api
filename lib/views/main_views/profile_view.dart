import 'package:api_client/models/user.dart';
import 'package:api_client/utils/api_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

RegExp nameRegExp = RegExp(r'^[a-zа-яё]{1,30}$', caseSensitive: false, multiLine: false);

class _ProfileViewState extends State<ProfileView> {

  TextEditingController name = TextEditingController();
  TextEditingController password = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey();

  User? user;

  @override
  void initState() {
    super.initState();

    initData();
  }

  Future<void> initData() async {
    final profile = await ApiUtils.getProfile();
    profile.fold(
      (res) { setState(() {
        user = res;
        name.text = res.name;
      }); },
      (err) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));  }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(
      child: Form(key: _formKey,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text("Id: ${user?.id.toString() ?? ""}"),
          Text("Login: ${user?.login.toString() ?? ""}"),
          Container(
            margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: TextFormField(
              controller: name,
              validator: (value) {
                if (value == null || value.isEmpty) return "Пустое поле";
                return null;
              },           
              decoration: InputDecoration(
                isDense: true,
                hintText: "Имя",
                border: const OutlineInputBorder(),
                suffixIcon: GestureDetector(onTap: () { name.clear(); }, child: const Icon(Icons.clear))
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: TextFormField(
              controller: password,        
              decoration: InputDecoration(
                isDense: true,
                hintText: "Пароль",
                //contentPadding: EdgeInsets.all(10),
                border: const OutlineInputBorder(),
                suffixIcon: GestureDetector(onTap: () { password.clear(); }, child: const Icon(Icons.clear, ))
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  var error = await ApiUtils.updateProfile(name: name.text, password: password.text.isEmpty ? null : password.text);
                  if (error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error))); 
                  }
                  else { 
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Данные обновлены")));
                    password.clear();
                  }                  
                },
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 84, 102, 78))),
                child: const SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: Center(
                      child: Text(
                    "Обновить",
                  )),
                )),
          )
        ]),
      ),
    ));
  }
}

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @protected
  @override
  State<StatefulWidget> createState() => _ProfileViewState();
}
