// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mynotes_x/Pages/create_update_notes_view.dart';
import 'package:mynotes_x/Pages/settings.dart';
import 'package:mynotes_x/Pages/show_tags.dart';
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
import 'package:mynotes_x/utilities/dialogs/error_dialog.dart';
import 'package:mynotes_x/utilities/dialogs/logout_dialog.dart';
import 'dart:developer' as dev;

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
  DatabaseUser? databaseUser;
  List<DatabaseNotes> _notes = [];

  @override
  void initState() {
    _notesService = NotesService();
    super.initState();
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
            'N O T E S',
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
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CreateUpdateNewNote(user: databaseUser!),
              ),
            );
          },
          label: Text(
            'Create',
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
          icon: Icon(
            Icons.add_rounded,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        drawerEnableOpenDragGesture: false,
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
                  title: 'N O T E S',
                  leadingIcon: const Icon(Icons.home),
                  onTap: () => Navigator.of(context).pop(),
                ),
                DrawerTile(
                  title: 'S E T T I N G S',
                  leadingIcon: const Icon(Icons.settings),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => Settings(
                          userid: databaseUser!.userID,
                        ),
                      ),
                    );
                  },
                ),
                DrawerTile(
                  title: 'L O G O U T',
                  leadingIcon: const Icon(Icons.logout),
                  onTap: () async {
                    if (await showLogoutDialog(context: context)) {
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
                Center(
                  child: Column(
                    children: [
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
                DrawerTile(
                  title: 'T A G S',
                  leadingIcon: Icon(
                    Icons.local_offer_rounded,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => UserTags(user: databaseUser!),
                      ),
                    );
                  },
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
                if (snapshot.hasData) {
                  databaseUser = snapshot.data as DatabaseUser;
                  dev.log('passed future builder: ${databaseUser!.email}');
                  return StreamBuilder(
                    stream: _notesService.allNotes,
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.active:
                          dev.log('passed stream builder');
                          if (snapshot.hasData) {
                            dev.log('in stream builder snapshot has data');
                            _notes = snapshot.data as List<DatabaseNotes>;
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
                                        borderRadius:
                                            BorderRadius.circular(50.0),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.09),
                                            spreadRadius: 1.0,
                                            blurRadius: 5.0,
                                            offset: const Offset(-6.0, -6.0),
                                          ),
                                          BoxShadow(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .shadow
                                                .withOpacity(0.8),
                                            spreadRadius: 1.0,
                                            blurRadius: 5.0,
                                            offset: const Offset(6.0, 6.0),
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
                                            user: databaseUser!,
                                            notes: _notes,
                                          ),
                                          ImportantNotes(
                                            user: databaseUser!,
                                            notes: _notes,
                                          ),
                                          BookmarkedNotes(
                                            user: databaseUser!,
                                            notes: _notes,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return Center(
                              child: CircularProgressIndicator(
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary,
                              ),
                            );
                          }

                        default:
                          return Center(
                            child: CircularProgressIndicator(
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                            ),
                          );
                      }
                    },
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  );
                }

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

/* */