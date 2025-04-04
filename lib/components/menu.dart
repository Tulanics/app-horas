import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:horas_v3/services/auth_service.dart';

class Menu extends StatelessWidget {
  final User user;
   Menu({super.key, required this.user});

  final TextEditingController _passwordController = TextEditingController();

void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Para excluir sua conta, digite sua senha."),  
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Email: ${user.email}"),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Senha"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                AuthService().deleteAccount(password: _passwordController.text).then((String? erro) {
                  if (!context.mounted) return;
                  Navigator.of(context).pop(); // Fechar o modal antes de exibir o snackbar
                  final snackBar = SnackBar(
                    content: Text(erro ?? "Conta excluída com sucesso!"),
                    backgroundColor: erro != null ? Colors.red : Colors.green,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                });
              },
              child: const Text("Confirmar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
             currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.manage_history_rounded,
                size: 48,
              ),
            ),
            accountName: Text((user.displayName != null) ? user.displayName! : '',), 
            accountEmail: Text(user.email!),
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: const Text('Sair'),
            onTap: () {
              AuthService().logOut();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Excluir conta'),
            onTap: () => _showDeleteAccountDialog(context),
          ),
        ],
      ),
    );
  }
}


