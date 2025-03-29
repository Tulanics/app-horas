import 'package:flutter/material.dart';
import 'package:horas_v3/screens/register_screen.dart';
import 'package:horas_v3/services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(  
      body: Container(
        color: Colors.blue,
        padding: EdgeInsets.all(16),
        child:  Center( 
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16)
              ),
              child: Column(
                children: [
                  FlutterLogo(size: 76,),
                  SizedBox(height: 16,),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'E-mail'
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  obscureText: true,
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: "Senha"
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(onPressed: () {
                  authService.enterUser(
                    email: _emailController.text, 
                    password: _passwordController.text).then((String? erro){
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
                }, child: Text("Entrar"),),
                SizedBox(height: 16),
                ElevatedButton(onPressed: (){}, child: Text("Entrar com google"),),
                SizedBox(height: 16),
                TextButton(onPressed: () {
                  Navigator.push(context, 
                      MaterialPageRoute(
                        builder: (context) => RegisterScreen(),
                      )
                  );
                }, 
                  child: Text("Ainda não tem uma conta? Crie uma conta"))
                ],
              )
              )
            ]
          ),
        ),
      )
    );
  }
}