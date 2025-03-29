import 'package:flutter/material.dart';
import 'package:horas_v3/services/auth_service.dart';

class RegisterScreen extends StatelessWidget {
    RegisterScreen({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.blue,
        padding: EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                   color: Colors.white,
                   borderRadius: BorderRadius.circular(16)),
              
                  child: Column(
                  children: [
                    FlutterLogo(size:76),
                    SizedBox(height: 16,),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(hintText: "Name"),
                    ),
                    SizedBox(height: 16,),
                    TextField(
                      controller:_emailController,
                      decoration: InputDecoration(hintText: "E-mail"),
                    ),
                    SizedBox(height: 16,),
                    TextField(
                      obscureText: true,
                      controller: _passwordController,
                      decoration: InputDecoration(hintText: "Password"),
                    ),
                    SizedBox(height: 16,),
                    TextField(
                      obscureText: true,
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(hintText: "Confirm your password"),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(onPressed: () {
                      if(_passwordController.text == 
                        _confirmPasswordController.text) {
                        authService.registerUser(
                          email: _emailController.text,
                          password: _passwordController.text, 
                          name: _nameController.text).then((String? erro){
                            if(!context.mounted) return;
                            if(erro != null) {
                              final snackBar = SnackBar(
                                content: Text(erro), 
                                backgroundColor: Colors.red,
                              );                           
                                ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);                            
                            } else {                           
                                Navigator.pop(context);                         
                            }
                          });                       
                      } else {
                         const snackBar = SnackBar(
                            content: Text('passwords do not match'),
                            backgroundColor: Colors.red,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    }, child: Text('Register')
                    ),
                    SizedBox(height: 16)
                  ],
                )
              )
            ],
          ),
        ),
      )
    );
  }
}