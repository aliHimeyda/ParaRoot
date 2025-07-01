import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';

class Alarmmodel with ChangeNotifier {
  late List<Alarm> alarms = [];
}

class Alarm {
  final DateTime zaman;
  final String aciklama;
  late bool isActive = false;
  Alarm({required this.zaman, required this.aciklama});
}

class Bildirim extends StatelessWidget {
  const Bildirim({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class Alarmpage extends StatefulWidget {
  const Alarmpage({super.key});

  @override
  State<Alarmpage> createState() => _AlarmpageState();
}

class _AlarmpageState extends State<Alarmpage> {
  bool isGelir = true;
  final TextEditingController _turController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Alarmlar', style: Theme.of(context).textTheme.bodyLarge),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: ListView(
        children: [
          buildAlarmTile(
            '07:00',
            'Günlük | Alarm 8 saat 43 dakika içerisinde',
            true,
            context,
          ),
          buildAlarmTile('08:40', 'Bir kez', false, context),
          buildAlarmTile('09:00', 'Bir kez', false, context),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAlarmDialog(context);
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget buildAlarmTile(
    String time,
    String subtitle,
    bool isActive,
    BuildContext context,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
      title: Text(
        time,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      trailing: Switch(
        value: isActive,
        onChanged: (bool value) {},
        activeColor: Theme.of(context).primaryColor,
        inactiveThumbColor: Theme.of(context).primaryColor,
        focusColor: Theme.of(context).primaryColor,
        inactiveTrackColor: Theme.of(context).scaffoldBackgroundColor,
      ),
    );
  }

  void showAlarmDialog(BuildContext context) {
    DateTime selectedDateTime = DateTime.now();
    TextEditingController labelController = TextEditingController();
    String repeatOption = 'Günlük';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border.all(color: Theme.of(context).primaryColor),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap:
                            () => setState(() {
                              isGelir = true;
                              _turController.text = '';
                            }),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isGelir ? Colors.green : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Gelir',
                            style: TextStyle(
                              color:
                                  isGelir
                                      ? Colors.white
                                      : Theme.of(
                                        context,
                                      ).textTheme.bodyMedium!.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap:
                            () => setState(() {
                              isGelir = false;
                              _turController.text = '';
                            }),
                        child: Container(
                          decoration: BoxDecoration(
                            color: !isGelir ? Colors.red : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Gider',
                            style: TextStyle(
                              color:
                                  !isGelir
                                      ? Colors.white
                                      : Theme.of(
                                        context,
                                      ).textTheme.bodyMedium!.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 10),
              Text(
                "Saat Seç",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: 10),

              // Saat Seçici (Scroll ile)
              TimePickerSpinner(
                is24HourMode: false, // AM/PM destekli
                normalTextStyle: TextStyle(fontSize: 18, color: Colors.white54),
                highlightedTextStyle: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                ),
                spacing: 40,
                itemHeight: 50,
                isForce2Digits: true,
                onTimeChange: (time) {
                  selectedDateTime = time;
                },
              ),

              SizedBox(height: 20),

              // Açıklama metni
              TextField(
                controller: labelController,
                decoration: InputDecoration(
                  labelText: 'Açıklama',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),

              SizedBox(height: 20),

              // Tekrar seçici
              DropdownButtonFormField<String>(
                dropdownColor: Colors.grey[850],
                value: repeatOption,
                onChanged: (String? value) {
                  if (value != null) {
                    repeatOption = value;
                  }
                },
                items:
                    <String>[
                      'Günlük',
                      'Her Pazar',
                      'Aylık (30\'u)',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                decoration: InputDecoration(
                  labelText: 'Tekrar',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),

              SizedBox(height: 20),

              // Butonlar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("İptal"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      print(
                        "Oluşturuldu: ${selectedDateTime.hour}:${selectedDateTime.minute}, ${labelController.text}, $repeatOption",
                      );
                      Navigator.pop(context);
                    },
                    child: Text("Oluştur"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
