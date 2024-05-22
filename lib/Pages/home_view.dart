import 'package:flutter/material.dart';
import 'package:mynotes_x/components/drawer.dart';
import 'package:mynotes_x/components/drawer_tile.dart';
import 'package:mynotes_x/services/auth/auth_exceptions.dart';
import 'package:mynotes_x/services/auth/auth_service.dart';
import 'package:mynotes_x/services/crud/notes_service.dart';
import 'package:mynotes_x/services/facebook_auth/facebook_auth_service.dart';
import 'package:mynotes_x/services/google_auth/google_auth_service.dart';
import 'package:mynotes_x/tabs/all_notes.dart';
import 'package:mynotes_x/tabs/bookmarked_notes.dart';
import 'package:mynotes_x/tabs/important_notes.dart';
import 'package:mynotes_x/utilities/constants.dart';
import 'package:mynotes_x/utilities/show_error_dialog.dart';

enum MenuActions { logout }

class HomePage extends StatefulWidget {
  final String? payload;
  const HomePage({
    super.key,
    this.payload,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = AuthService.firebase().currentUser;
  String get userEmail => user!.email!;
  late final NotesService _notesService;

  @override
  void initState() {
    _notesService = NotesService();

    super.initState();
  }

  @override
  void dispose() {
    _notesService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          foregroundColor: Colors.transparent,
          title: const Text(
            'N o t e s',
            textAlign: TextAlign.center,
          ),
          centerTitle: true,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.extended(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          extendedIconLabelSpacing: 10,
          onPressed: () {
            Navigator.of(context).pushNamed(createNotesRoute);
          },
          label: Text(
            'Create',
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
          icon: Icon(
            Icons.add,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        drawer: MyDrawer(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                DrawerHeader(
                  child: Icon(
                    Icons.note_alt,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                DrawerTile(
                  title: 'N o t e s',
                  leadingIcon: const Icon(Icons.home),
                  onTap: () => Navigator.of(context).pop(),
                ),
                DrawerTile(
                  title: 'S e t t i n g s',
                  leadingIcon: const Icon(Icons.settings),
                  onTap: () {},
                ),
                DrawerTile(
                  title: 'L o g o u t',
                  leadingIcon: const Icon(Icons.logout),
                  onTap: () async {
                    if (await showLogoutDialog(context)) {
                      try {
                        await AuthService.firebase().logOut();
                        await GAuthService.firebase().signOut();
                        await FAuthService.firebase().logOut();
                      } on UserNotLoggedInException catch (e) {
                        await showErrorDialog(
                          context: context,
                          messege: e.code,
                        );
                      } catch (e) {
                        await showErrorDialog(
                          context: context,
                          messege:
                              'Not from own class exceptions: ${e.toString()}',
                        );
                      }
                    }
                  },
                ),
                const SizedBox(
                  height: 30,
                ),
                Icon(
                  Icons.tag,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                const SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 118),
                  child: Divider(
                    thickness: 1,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        body: FutureBuilder(
          future: _notesService.getOrCreateUser(email: userEmail),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return StreamBuilder(
                  stream: _notesService.allNotes,
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.active:
                        return SafeArea(
                          child: Center(
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 15,
                                ),
                                TabBar(
                                  indicatorColor: Colors.transparent,
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  indicator: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50.0),
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.3),
                                        spreadRadius: 1.0,
                                        blurRadius: 15.0,
                                        offset: const Offset(5.0, 6.0),
                                      ),
                                      BoxShadow(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .inversePrimary
                                            .withOpacity(0.13),
                                        spreadRadius: 1.0,
                                        blurRadius: 15.0,
                                        offset: const Offset(-5.0, -4.0),
                                      ),
                                    ],
                                  ),
                                  labelStyle: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .inversePrimary,
                                    fontSize: 14,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0,
                                  ),
                                  dividerHeight: 0,
                                  unselectedLabelStyle: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .inversePrimary,
                                    fontSize: 13,
                                  ),
                                  tabAlignment: TabAlignment.fill,
                                  tabs: [
                                    Tab(
                                      child: Center(
                                        child: Text(
                                          'All',
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .inversePrimary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Tab(
                                      child: Center(
                                        child: Text(
                                          'Important',
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .inversePrimary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Tab(
                                      child: Center(
                                        child: Text(
                                          'Bookmarked',
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .inversePrimary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: TabBarView(
                                    children: [
                                      AllNotes(
                                        email: userEmail,
                                        payload: widget.payload,
                                      ),
                                      const ImportantNotes(),
                                      const BookmarkedNotes(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      default:
                        return Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        );
                    }
                  },
                );
              default:
                return Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                );
            }
          },
        ),
      ),
    );
  }
}

Future<bool> showLogoutDialog(BuildContext context) => showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          title: Text(
            'Logout',
            style:
                TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
          ),
          content: Text(
            'Are you sure you want to logout ?',
            style:
                TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
          ),
          actions: [
            MaterialButton(
              child: Text(
                'Logout',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
            MaterialButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
