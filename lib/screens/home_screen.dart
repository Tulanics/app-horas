import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:horas_v3/components/menu.dart';
import 'package:horas_v3/helpers/hour_helpers.dart';
import 'package:horas_v3/models/hour.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:uuid/uuid.dart';

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
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Menu(user: widget.user),
      appBar: AppBar(
        title: Text('Horas V3'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showFormModal();
        },
        child: Icon(Icons.add),
      ),
      body: (listHours.isEmpty) ? const Center(
        child: Text("Nada por aqui. \nVamos registrar um dia de trabalho?", textAlign: TextAlign.center, style: TextStyle(fontSize: 18),),
      ) : ListView(
        padding: EdgeInsets.only(left: 4, right: 4),
        children: List.generate(listHours.length, (index) {
           Hour model = listHours[index];
           return Dismissible(key: ValueKey<Hour>(model), direction: DismissDirection.endToStart, 
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 12),
                color: Colors.red,
                child: Icon(Icons.delete, color: Colors.white)
              ),
               onDismissed: (direction) {
                remove(model);
               } ,
           child: Card(
            elevation: 2,
            child: Column(
              children: [
                ListTile(
                  onLongPress: () {

                  },
                  onTap: () {
                    
                  },
                  leading: Icon(Icons.list_alt_rounded, size: 56),
                  title: (Text("Data: ${model.date} horas: ${HourHelper.minutesToHours(model.minutes)}")),
                  subtitle: Text(model.description!),
                )
              ],
            ),
            ) 
          );
        }
        ),
      ),
    );
  }

  showFormModal({Hour? model}){
    String title  = "Adicionar";
    String confirmationButton = "Salvar";
    String skipButton = "Cancelar";

    TextEditingController dateController = TextEditingController();
    final dataMaskFormatter = MaskTextInputFormatter(mask: '##/##/####');
    TextEditingController minutesController = TextEditingController();
    final minutesMaskFormatter = MaskTextInputFormatter(mask: '##:##');
    TextEditingController descriptionController = TextEditingController();


    if(model != null) {
      title = "Editando";
      dateController.text = model.date;
      minutesController.text = HourHelper.minutesToHours(model.minutes);
      if(model.description != null) {
        descriptionController.text = model.description!;
      }
    }

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(24),
      ),
    ), builder: (context) {
      return Container(
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.all(32),
        child: ListView(
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall,),
            TextFormField(
              controller: dateController,
              keyboardType: TextInputType.datetime,
              decoration: InputDecoration(
                hintText: '01/01/2024',
                labelText: "DAta"
              ),
              inputFormatters: [dataMaskFormatter],
            ),
              SizedBox(height: 16,),
              TextFormField(
                controller: minutesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '00:00', labelText: "horas trabalhadas"
                ),
                inputFormatters: [minutesMaskFormatter],
              ),
              SizedBox(height: 16,),
              TextFormField(
                controller: descriptionController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: "Lembrete do que você fez", 
                  labelText: "Descrição"
                ),
              ),
              SizedBox(height: 16,),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () {
                    Navigator.pop(context);
                  }, child: Text(skipButton),),
                  SizedBox(width: 16,),
                  ElevatedButton(
                    onPressed: () {
                      Hour hour = Hour(
                        id: const Uuid().v1(), 
                        date: dateController.text,
                        minutes: HourHelper.hourToMinutes(minutesController.text
                        ));

                      if(descriptionController.text != "") {
                        hour.description = descriptionController.text;
                      }

                      if(model != null) {
                        hour.id = model.id;
                      }

                      firestore.collection(widget.user.uid).doc(hour.id).set(hour.toMap());

                      refresh();

                      Navigator.pop(context);  

                    }, 
                    child: Text(confirmationButton))
                ],
              ),
            SizedBox(height: 180,)
          ],
        )
        
      );
    },
    );
  }

  void remove(Hour model) {
    firestore.collection(widget.user.uid).doc(model.id).delete();
    refresh();
  }

  void refresh() {}
}


