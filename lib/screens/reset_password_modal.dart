import 'package:flutter/material.dart';
import 'package:horas_v3/services/auth_service.dart';

class ResetPasswordModal extends StatefulWidget {
  const ResetPasswordModal({super.key});

  @override
  State<ResetPasswordModal> createState() => _ResetPasswordModalState();
}

class _ResetPasswordModalState extends State<ResetPasswordModal> {

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Recuperar Senha"),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(labelText: 'Endereço de e-mail'),
          validator: (value) {
            if(value!.isEmpty) {
              return 'Informe um endereço de email válido';
            }
            return null;
          },
        ),
      ),
      actions:<TextButton> [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          }, 
          child: Text('Cancelar')
          ),
        TextButton(onPressed: () {
          if(_formKey.currentState!.validate()){
            authService.passwordReset(email: _emailController.text).then((String? erro) {
              if(!context.mounted) return;

              Navigator.of(context).pop();

              if(erro != null) {
                final snackBar = SnackBar(
                  content: Text(erro),
                  backgroundColor: Colors.red,
                );

                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              } else {
                final snackBar = SnackBar(
                  content: Text('Um link de redefinição de senha foi enviado para o seu email: ${_emailController.text}'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 7),
                );

                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }

            }); 
          }
        }, child: Text('Recuperar Senha'))
      ]
    );
  }
}