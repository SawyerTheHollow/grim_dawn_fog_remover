import 'dart:async';
import 'dart:io';
import 'package:grim_dawn_fog_remover/style.dart';
import 'package:path/path.dart' as path;

import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String? windowsUsername = Platform.environment['USERNAME'];
  final ValueNotifier<String> selectedTargetCharacter = ValueNotifier('');
  final ValueNotifier<String> selectedDonorCharacter = ValueNotifier('');
  final ValueNotifier<double> successIndicator = ValueNotifier(0);
  late final Directory savesDirectory = Directory('C:/Users/$windowsUsername/Documents/My Games/Grim Dawn/save/main');

  showTemporarySuccessIndicator(){
    successIndicator.value = 1;
    Timer(Duration(seconds: 1), (){
      successIndicator.value = 0;
    });
  }

  Future<List<DropdownMenuItem<String>>> getCharNamesItems() async {
    final List<DropdownMenuItem<String>> charNamesItems = List.empty(
      growable: true,
    );
    await for (var entity in savesDirectory.list(
      recursive: false,
      followLinks: false,
    )) {
      charNamesItems.add(
        DropdownMenuItem(
          value: path.basename(entity.path).substring(1),
          child: Text(path.basename(entity.path).substring(1)),
        ),
      );
    }
    selectedTargetCharacter.value = charNamesItems.first.value!;
    selectedDonorCharacter.value = charNamesItems.first.value!;
    return charNamesItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: customDark,
      body: FutureBuilder(
        future: getCharNamesItems(),
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (asyncSnapshot.hasData) {
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('Персонаж, которому нужно раскрыть карту',
                          style: customStyleBold),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 50),
                            child: ValueListenableBuilder(
                              valueListenable: selectedTargetCharacter,
                              builder: (context, value, child) {
                                return DropdownButton(
                                  style: customStyleNormal,
                                  dropdownColor: customDark,
                                  underline: Divider(color: customGreen, height: 0,),
                                  iconEnabledColor: customGreen,
                                  value: selectedTargetCharacter.value,
                                  isExpanded: true,
                                  menuWidth: 300,
                                  items: asyncSnapshot.data!,
                                  onChanged: (item) {
                                    selectedTargetCharacter.value = item!;
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text('Персонаж, с которого будет скопирована карта',
                          style: customStyleBold,),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 50),
                            child: ValueListenableBuilder(
                              valueListenable: selectedDonorCharacter,
                              builder: (context, value, child) {
                                return DropdownButton(
                                  style: customStyleNormal,
                                  dropdownColor: customDark,
                                  underline: Divider(color: customGreen, height: 0,),
                                  iconEnabledColor: customGreen,
                                  value: selectedDonorCharacter.value,
                                  isExpanded: true,
                                  menuWidth: 300,
                                  items: asyncSnapshot.data!,
                                  onChanged: (item) {
                                    selectedDonorCharacter.value = item!;
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height:15),
                Container(padding: EdgeInsets.symmetric(horizontal: 50), width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: customGreen, minimumSize: Size(0, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                  onPressed: () async {
                  var fogFile = File('C:/Users/$windowsUsername/Documents/My Games/Grim Dawn/save/main/_${selectedDonorCharacter.value}/levels_world001.map/Ultimate/map.fow');
                  var normalDir = Directory('C:/Users/$windowsUsername/Documents/My Games/Grim Dawn/save/main/_${selectedTargetCharacter.value}/levels_world001.map/Normal/');
                  var eliteDir = Directory('C:/Users/$windowsUsername/Documents/My Games/Grim Dawn/save/main/_${selectedTargetCharacter.value}/levels_world001.map/Elite/');
                  var ultimateDir = Directory('C:/Users/$windowsUsername/Documents/My Games/Grim Dawn/save/main/_${selectedTargetCharacter.value}/levels_world001.map/Ultimate/');
                  if(!await normalDir.exists()){
                    await normalDir.create();
                  }
                  if(!await eliteDir.exists()){
                    await eliteDir.create();
                  }
                  if(!await ultimateDir.exists()){
                    await ultimateDir.create();
                  }
                  await fogFile.copy('${normalDir.path}/map.fow');
                  await fogFile.copy('${eliteDir.path}/map.fow');
                  await fogFile.copy('${ultimateDir.path}/map.fow').then((result){
                    showTemporarySuccessIndicator();
                  });
                }, child: Text("Сделать дело", style: TextStyle(color: customDark, fontWeight: FontWeight.bold),),)),
                SizedBox(height: 15,),
                 ValueListenableBuilder(
          valueListenable: successIndicator,
          builder: (context, indicatorValue, child) {
            return AnimatedOpacity(
              curve: Curves.decelerate,
            opacity: indicatorValue,
            duration: Duration(milliseconds: 300),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Дело сделано!', style: TextStyle(color: customGreen, fontWeight: FontWeight.bold, fontSize: 50)),
                  SizedBox(width: 15,),
                  Icon(Icons.thumb_up_alt_outlined, size: 50, color: customGreen,)
                ],
              )
            );
          }
                   ),
              ],
            );
          } else {
            return Center(
              child: Text(
                'Error on loading character list or character list is empty',
              ),
            );
          }
        },
      ),
    );
  }
}
