import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:horas_v3/screens/register_screen.dart';
import 'package:horas_v3/screens/reset_password_modal.dart';
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
                            } 
                          });                       
                }, child: Text("Entrar"),),
                SizedBox(height: 16),
                ElevatedButton(onPressed: (){
                  signInWithGoogle();
                }, child: Text("Entrar com google"),),
                SizedBox(height: 16),
                TextButton(onPressed: () {
                  Navigator.push(context, 
                      MaterialPageRoute(
                        builder: (context) => RegisterScreen(),
                      )
                  );
                }, 
                  child: Text("Ainda não tem uma conta? Crie uma conta")
                  ),
                  TextButton(
                    onPressed: () {
                      showDialog(context: context, builder: (BuildContext context) {
                        return ResetPasswordModal();
                      });
                    }, 
                    child: Text("Esqueceu sua senha?"),
                  )
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

// Future<UserCredential> singinWithGoogle() async {
//   final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
//   GoogleSignIn googleSignIn = GoogleSignIn(
//     clientId: "1098286143288-vqla2r70kqkh7usu7ibp5k28mhv9dvt2.apps.googleusercontent.com",
//     scopes: ['email'],
// );
//   final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
//   final credential = GoogleAuthProvider.credential(
//     accessToken: googleAuth.accessToken,
//     idToken: googleAuth.idToken
//   );
  
//   return await FirebaseAuth.instance.signInWithCredential(credential);
// }

Future<UserCredential> signInWithGoogle() async {
  // Configurar o Google Sign-In com o Client ID correto
  GoogleSignIn googleSignIn = GoogleSignIn(
    clientId: "117359615510-74ei24q5gutag6ojvt1k5ut2o94mq4bm.apps.googleusercontent.com",
    scopes: ['email'],
  );

  // Iniciar o fluxo de login
  final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
  if (googleUser == null) {
    throw Exception("Login cancelado pelo usuário");
  }

  // Obter autenticação do Google
  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  // Criar credenciais para o Firebase
  final AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  // Autenticar no Firebase com as credenciais do Google
  return await FirebaseAuth.instance.signInWithCredential(credential);
}