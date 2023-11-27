import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';


void main() async {
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  WidgetsFlutterBinding.ensureInitialized();
  const keyApplicationId = 'KBzMg0MdO7Vpu040EZ13olO9a8a5LEswQOBJ2pcv';
  const keyClientKey = 'YwiTzWvxD7yoL4B35uQ4rgbbk5CCuzPhcl2aC9F8';
  const keyParseServerUrl = 'https://parseapi.back4app.com';
  await Parse().initialize(
    keyApplicationId,
    keyParseServerUrl,
    clientKey: keyClientKey,
    debug: true,
    autoSendSessionId: true
  );

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.

  // var firstObject = ParseObject('FirstClass')
  //   ..set(
  //       'message', 'Hey ! First message from Flutter. Parse is now connected');
  // await firstObject.save();

//   const B4aVehicle = ParseObject.extend('B4aVehicle');
// const vehicle = new B4aVehicle();

// vehicle.set('name', 'Corolla');
// vehicle.set('price', 19499);
// vehicle.set('color', 'black');

// try {
//   const savedObject = await vehicle.save(); 
//   // The class is automatically created on
//   // the back-end when saving the object!
//   console.log(savedObject);
// } catch (error) {
//   console.error(error);
// };



  print('done');

  runApp(const DataTableWidget());
}

class DataTableWidget extends StatelessWidget {
  const DataTableWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: DataTableExample(),
    );
  }
}

class DataTableExample extends StatefulWidget {
  const DataTableExample({super.key});

  @override
  State<DataTableExample> createState() => _DataTableExampleState();
}

class _DataTableExampleState extends State<DataTableExample> {
  static const int numItems = 20;
  List<bool> selected = List<bool>.generate(numItems, (int index) => false);
  int _sortColumnIndex = 2; // Index of the "Created On" column
  bool _sortAscending = true; // Sorting order (true for ascending, false for descending)
  
  
  
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Task List'),
    ),
    body: FutureBuilder<List<ParseObject>>(
      future: getTasks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Show a loading indicator while data is being fetched.
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No data available'); // Handle the case when no data is available.
        } else {
          List<ParseObject> tasks = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              children: [
                DataTable(
                  sortColumnIndex: _sortColumnIndex,
                  sortAscending: _sortAscending,
                  columns: <DataColumn>[
                    const DataColumn(
                      label: Text('Task'),
                    ),
                    const DataColumn(
                      label: Text('Description'),
                    ),
                    DataColumn(
                        label: const Text('Created On'),
                        onSort: (columnIndex, ascending) {
                          // Triggered when the "Created On" column header is clicked
                          setState(() {
                            _sortColumnIndex = columnIndex;
                            _sortAscending = ascending;
                            if (columnIndex == 2) {
                              // Sort based on the "Created On" column
                              tasks.sort((a, b) {
                                DateTime dateA = DateTime.parse(a['createdAt']);
                                DateTime dateB = DateTime.parse(b['createdAt']);
                                return _sortAscending
                                    ? dateA.compareTo(dateB)
                                    : dateB.compareTo(dateA);
                              });
                            }
                          });
                        },
                      ),
                    const DataColumn(
                      label: Text('Status'),
                    ),
                  ],
                  rows: List<DataRow>.generate(
                    tasks.length,
                    (int index) => DataRow(
                      color: MaterialStateProperty.resolveWith<Color?>(
                        (Set<MaterialState> states) {
                          // Your color logic here
                        },
                      ),
                      cells: <DataCell>[
                        DataCell(Text(tasks[index]['title'].toString())),
                        DataCell(Text(tasks[index]['description'].toString())),
                        DataCell(Text(tasks[index]['createdAt'].toString())),
                        DataCell(Text(tasks[index]['status'].toString())),
                      ],
                      selected: selected[index],
                      onSelectChanged: (bool? value) {
                        setState(() {
                          selected[index] = value!;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16.0), // Add some spacing between the DataTable and the FloatingActionButton
                FloatingActionButton(
                  onPressed: () {
                    _showAddTaskDialog(context);
                  },
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          );
        }
      },
    ),
  );
}

void _showAddTaskDialog(BuildContext context) {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Add Task'),
        content: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Task Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Task Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Call the saveTask function with the input values
              await saveTask(
                titleController.text,
                descriptionController.text,
              );
              setState(() {});
              // ignore: use_build_context_synchronously
              Navigator.pop(context); // Close the dialog
            },
            child: const Text('Add'),
          ),
        ],
      );
    },
  );
}




  //CREATE TASK
  Future<void> saveTask(String title, String description) async {
    final todo = ParseObject('Task')..set('title', title)..set('description', description)..set('status',false);
    await todo.save();
  }

  //GET TASKS
  Future<List<ParseObject>> getTasks() async {
    QueryBuilder<ParseObject> queryTodo =
        QueryBuilder<ParseObject>(ParseObject('Task'));
    final ParseResponse apiResponse = await queryTodo.query();

    if (apiResponse.success && apiResponse.results != null) {
      return apiResponse.results as List<ParseObject>;
    } else {
      return [];
    }
  }


//UPDATE TASK
  Future<void> updateTask(String id, bool done) async {
    var todo = ParseObject('Task')
      ..objectId = id
      ..set('status', done);
    await todo.save();
  }


//DELETE TASK
  Future<void> deleteTask(String id) async {
    var todo = ParseObject('Task')..objectId = id;
    await todo.delete();
  }
}
