import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:to_do/modules/archived_tasks/archived_tasks.dart';
import 'package:to_do/modules/done_tasks/done_tasks.dart';
import 'package:to_do/modules/new_tasks/new_taskes.dart';
import 'package:to_do/shared/cubit/states.dart';

//==========================================================================================================================================================

class AppCubit extends Cubit<AppStates> {

  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;
  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archiveTasks = [];

  bool isBottomSheet = false;
  IconData floatingActionButtonIcon = Icons.edit;

  Database? database;
  List<Widget> screens = [
    const NewTasks(),
    const DoneTasks(),
    const ArchivedTasks()
  ];

  List<String> title = ['New Tasks', 'Done Tasks', 'Archived Tasks'];

//==========================================================================================================================================================


  void changeIndex(int index) {
    currentIndex = index;
    emit(AppChangeBottomNavBarState());
  }

//==========================================================================================================================================================


  void createDatabase() {
    openDatabase('todo.db', version: 1, onCreate: (database, version) {
      // id int
      // title string
      // data string
      // time string
      // status string

      // print('database created');
      database
          .execute(
              'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)')
          .then((value) {
        // print('table created');
      }).catchError((error) {
        print('error when creating table ${error.toString()}');
      });
    }, onOpen: (database) {
      getDataFromDatabase(database);
      // print('database open');
    }).then((value) {
      database = value;
      emit(AppCreateDatabaseState());
    });
  }

//==========================================================================================================================================================


  insertDatabase({
    required String title,
    required String time,
    required String date,
  }) async {
    await database!.transaction((txn) {
      return txn
          .rawInsert(
              'INSERT INTO tasks(title, date, time, status) VALUES("$title", "$date", "$time", "new")')
          .then((value) {
        // print('$value inserted successfully');
        emit(AppInsertDatabaseState());
        getDataFromDatabase(database);
      }).catchError((error) {
        print('error when inserting new record $error.toString()');
      });
    });
  }

//==========================================================================================================================================================


  void getDataFromDatabase(Database? database) {
    newTasks = [];
    doneTasks = [];
    archiveTasks = [];
    emit(AppGetDatabaseLoadingState());
    database!.rawQuery('SELECT * FROM tasks').then((value) {
      for (var element in value) {
          if (element['status'] == 'new') {
            newTasks.add(element);
          } else if (element['status'] == 'done') {
            doneTasks.add(element);
          } else {
            archiveTasks.add(element);
          }
        }

      emit(AppGetDatabaseState());
    });
  }

//==========================================================================================================================================================


  void changeBottomSheetState({
    required bool isShow,
    required IconData icon,
  }) {
    isBottomSheet = isShow;
    floatingActionButtonIcon = icon;

    emit(AppChangeBottomSheetState());
  }

//==========================================================================================================================================================

  void updateData({
    required String status,
    required int id,
  }) {
    database!.rawUpdate(
        'UPDATE tasks SET status = ? WHERE id = ?', [status, id]).then((value) {
      getDataFromDatabase(database);
      emit(AppUpdateDatabaseState());
    });
  }

//==========================================================================================================================================================


  void deleteData({
    required int id,
  }) {
    database!.rawDelete(
        'DELETE FROM tasks WHERE id = ?', [id] ).then((value) {
      getDataFromDatabase(database);
      emit(AppDeleteDatabaseState());
    });
  }

//==========================================================================================================================================================
  
}


//==========================================================================================================================================================

