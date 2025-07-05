import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathon/router.dart';
import 'package:hackathon/themeprovider.dart';
import 'package:provider/provider.dart';

class Anasayfa extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  const Anasayfa({super.key, required this.navigationShell});

  @override
  State<Anasayfa> createState() => _AnasayfaState();
}

class _AnasayfaState extends State<Anasayfa> {
  @override
  Widget build(BuildContext context) {
    late int currentindex = widget.navigationShell.currentIndex;

    final String currentPath = GoRouterState.of(context).uri.toString();

    // Eğer ..... sayfasındaysak, BottomNavigationBar'ı gösterme
    bool showBottomNavBar =
        currentPath != Paths.loadingpage &&
        currentPath != Paths.analizsayfasi &&
        currentPath != Paths.profilsayfasi &&
        currentPath != Paths.loginpage &&
        currentPath != Paths.hareketdetaysayfasi &&
        currentPath != Paths.gelirgidereklesayfasi &&
        currentPath != Paths.qrsayfasi &&
        currentPath != Paths.alarmpage &&
        currentPath != Paths.kameracekimsayfasi; //
    return Scaffold(
      extendBody: true,
      floatingActionButton:
          showBottomNavBar && !(currentPath == Paths.profilsayfasi)
          ? FloatingActionButton(
              onPressed: () {
                context.push(Paths.gelirgidereklesayfasi);
              },

              backgroundColor: Theme.of(
                context,
              ).floatingActionButtonTheme.backgroundColor,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: Colors.white, size: 32),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   leading: Padding(
      //     padding: EdgeInsets.only(left: 20),
      //     child: SizedBox(
      //       width: 200,
      //       child: TextField(
      //         onChanged: (value) {
      //           // Arama işlemleri burada yazılacak
      //         },
      //         decoration: InputDecoration(
      //           suffixIcon: IconButton(
      //             icon: Image.asset(
      //               'lib/icons/aramaiconu.png',
      //               width: 20,
      //               color: Renkler.kahverengi,
      //             ),
      //             onPressed: () {},
      //           ),
      //           hintText: 'Arama yap',
      //           border:
      //               OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
      //           filled: true,
      //           fillColor: Renkler.kuyubeyaz,
      //           contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      //         ),
      //       ),
      //     ),
      //   ),
      //   actions: const [
      //     Padding(
      //       padding: EdgeInsets.only(right: 10),
      //       child: Text('BelliBellu',
      //           style: TextStyle(fontSize: 20, color: Renkler.kahverengi)),
      //     ),
      //   ],
      // ),
      bottomNavigationBar: showBottomNavBar
          ? BottomAppBar(
              height: 100,
              shape: const CircularNotchedRectangle(),
              notchMargin: 10,
              elevation: 0, // elevation yerine custom shadow kullandık
              color: Theme.of(
                context,
              ).primaryColor, // Arka plan beyaz (#FFFFFF)
              child: SizedBox(
                height: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Ana Sayfa
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Image.asset(
                            'assets/homeicon.png',
                            color:
                                !Provider.of<AppTheme>(
                                  context,
                                  listen: false,
                                ).isdarkmode
                                ? AppColors.yesil
                                : AppColors.siyah,
                          ),
                          onPressed: () {
                            context.go(Paths.hareketler);
                          },
                        ),
                        Text(
                          'Ana Sayfa',
                          style: TextStyle(
                            color:
                                !Provider.of<AppTheme>(
                                  context,
                                  listen: false,
                                ).isdarkmode
                                ? AppColors.yesil
                                : AppColors.siyah,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Image.asset(
                            width: 27,
                            height: 27,
                            'assets/alarm.png',
                            color:
                                !Provider.of<AppTheme>(
                                  context,
                                  listen: false,
                                ).isdarkmode
                                ? AppColors.yesil
                                : AppColors.siyah,
                          ),
                          onPressed: () {
                            context.push(Paths.alarmpage);
                          },
                        ),
                        Text(
                          'Alarm',
                          style: TextStyle(
                            color:
                                !Provider.of<AppTheme>(
                                  context,
                                  listen: false,
                                ).isdarkmode
                                ? AppColors.yesil
                                : AppColors.siyah,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 50), // Ortadaki buton boşluğu
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Image.asset(
                            width: 27,
                            height: 27,
                            'assets/doviz.png',
                            color:
                                !Provider.of<AppTheme>(
                                  context,
                                  listen: false,
                                ).isdarkmode
                                ? AppColors.yesil
                                : AppColors.siyah,
                          ),
                          onPressed: () {
                            context.push(Paths.doviz);
                          },
                        ),
                        Text(
                          'Doviz',
                          style: TextStyle(
                            color:
                                !Provider.of<AppTheme>(
                                  context,
                                  listen: false,
                                ).isdarkmode
                                ? AppColors.yesil
                                : AppColors.siyah,
                          ),
                        ),
                      ],
                    ),
                    // Profil
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Image.asset(
                            'assets/profilicon.png',
                            color:
                                !Provider.of<AppTheme>(
                                  context,
                                  listen: false,
                                ).isdarkmode
                                ? AppColors.yesil
                                : AppColors.siyah,
                          ),
                          onPressed: () async {
                            context.push(Paths.profilsayfasi);
                          },
                        ),
                        Text(
                          'Profil',
                          style: TextStyle(
                            color:
                                !Provider.of<AppTheme>(
                                  context,
                                  listen: false,
                                ).isdarkmode
                                ? AppColors.yesil
                                : AppColors.siyah,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          : null, // Eğer BottomNavigationBar gösterilmeyecekse, null döndür
      body: widget.navigationShell,
      backgroundColor: Colors.white,
    );
  }
}
