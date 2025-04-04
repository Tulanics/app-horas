import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:horas_v3/components/menu.dart';
import 'package:horas_v3/helpers/hour_helpers.dart';
import 'package:horas_v3/models/hour.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:uuid/uuid.dart';
import 'dart:html' as html;

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Hour> listHours = [];
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();

    setupFCM();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("### onMessage: ${message.data}");
      showNotification(message);
    });
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Menu(user: widget.user),
      appBar: AppBar(title: Text('Horas V3')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showFormModal();
        },
        child: Icon(Icons.add),
      ),
      body:
          (listHours.isEmpty)
              ? const Center(
                child: Text(
                  "Nada por aqui. \nVamos registrar um dia de trabalho?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              )
              : ListView(
                padding: EdgeInsets.only(left: 4, right: 4),
                children: List.generate(listHours.length, (index) {
                  Hour model = listHours[index];
                  return Dismissible(
                    key: ValueKey<Hour>(model),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 12),
                      color: Colors.red,
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      remove(model);
                    },
                    child: Card(
                      elevation: 2,
                      child: Column(
                        children: [
                          ListTile(
                            onLongPress: () {
                              showFormModal(model: model);
                            },
                            onTap: () {},
                            leading: Icon(Icons.list_alt_rounded, size: 56),
                            title: (Text(
                              "Data: ${model.date} horas: ${HourHelper.minutesToHours(model.minutes)}",
                            )),
                            subtitle: Text(model.description!),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
    );
  }

  showFormModal({Hour? model}) {
    String title = "Adicionar";
    String confirmationButton = "Salvar";
    String skipButton = "Cancelar";

    TextEditingController dateController = TextEditingController();
    final dataMaskFormatter = MaskTextInputFormatter(mask: '##/##/####');
    TextEditingController minutesController = TextEditingController();
    final minutesMaskFormatter = MaskTextInputFormatter(mask: '##:##');
    TextEditingController descriptionController = TextEditingController();

    if (model != null) {
      title = "Editando";
      dateController.text = model.date;
      minutesController.text = HourHelper.minutesToHours(model.minutes);
      if (model.description != null) {
        descriptionController.text = model.description!;
      }
    }

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.all(32),
          child: ListView(
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              TextFormField(
                controller: dateController,
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(
                  hintText: '01/01/2024',
                  labelText: "Data",
                ),
                inputFormatters: [dataMaskFormatter],
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: minutesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '00:00',
                  labelText: "Horas trabalhadas",
                ),
                inputFormatters: [minutesMaskFormatter],
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: "Lembrete do que você fez",
                  labelText: "Descrição",
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(skipButton),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      Hour hour = Hour(
                        id: const Uuid().v1(),
                        date: dateController.text,
                        minutes: HourHelper.hourToMinutes(
                          minutesController.text,
                        ),
                      );

                      if (descriptionController.text != "") {
                        hour.description = descriptionController.text;
                      }

                      if (model != null) {
                        hour.id = model.id;
                      }

                      firestore
                          .collection(widget.user.uid)
                          .doc(hour.id)
                          .set(hour.toMap());

                      refresh();

                      Navigator.pop(context);
                    },
                    child: Text(confirmationButton),
                  ),
                ],
              ),
              SizedBox(height: 180),
            ],
          ),
        );
      },
    );
  }

  void remove(Hour model) {
    firestore.collection(widget.user.uid).doc(model.id).delete();
    refresh();
  }

  Future<void> refresh() async {
    List<Hour> temp = [];

    QuerySnapshot<Map<String, dynamic>> snapshot =
        await firestore.collection(widget.user.uid).get();
    for (var doc in snapshot.docs) {
      temp.add(Hour.fromMap(doc.data()));
    }

    if (!mounted) return;

    setState(() {
      listHours = temp;
    });
  }
}

void setupFCM() async {
  final fcmToken = await FirebaseMessaging.instance.getToken();
  print("token: $fcmToken");

  NotificationSettings settings = await FirebaseMessaging.instance
      .requestPermission(
        alert: true,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
        badge: true,
        provisional: false,
        sound: true,
      );
  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print("User granted permission");
  } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
    print("User denied permission");
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print("User granted provisional permission");
  } else {
    print("User did not grant permission");
  }

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("Got a message whilst in the foreground!");
    print("message data: ${message.data}");

    if (message.notification != null) {
      print("Massage also contained a notification: ${message.notification}");
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print("### A new onMessageOpenedApp event was published!");
  });
}

void showNotification(RemoteMessage message) {
  html.window.alert("### ${message.notification?.title} - ${message.notification?.body}");
  // html.window.alert("### ${message.data}");
  // html.window.alert("### ${message.data['title']} - ${message.data['body']}");
  // html.window.alert("### ${message.data['click_action']}");  
}
