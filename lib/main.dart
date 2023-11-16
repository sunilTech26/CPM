import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const keyApplicationId = 'xxxxxxxxxxxx';
  const keyClientKey = 'xxxxxxxxxxxxxxxxxx';
  const keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(keyApplicationId, keyParseServerUrl,
      clientKey: keyClientKey, autoSendSessionId: true);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter CRUD with Back4App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  List<ParseObject> _tasks = [];

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  _fetchTasks() async {
    final ParseResponse result = await ParseObject('Task').getAll();
    if (result.success && result.results != null) {
      setState(() {
        _tasks = List<ParseObject>.from(result.results!);
      });
    }
  }

  _addTask() async {
    final task = ParseObject('Task')
      ..set('title', _titleController.text)
      ..set('description', _descriptionController.text);

    final ParseResponse result = await task.save();

    if (result.success) {
      _titleController.clear();
      _descriptionController.clear();
      _fetchTasks();
    } else {
      print(result.error!.message);
    }
  }

  _updateTask(ParseObject task) async {
    _titleController.text = task.get('title');
    _descriptionController.text = task.get('description');

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Task'),
          content: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Task Title'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Task Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                task
                  ..set('title', _titleController.text)
                  ..set('description', _descriptionController.text);

                final ParseResponse result = await task.save();

                if (result.success) {
                  _titleController.clear();
                  _descriptionController.clear();
                  Navigator.of(context).pop();
                  _fetchTasks();
                } else {
                  print(result.error!.message);
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  _deleteTask(ParseObject task) async {
    final ParseResponse result = await task.delete();

    if (result.success) {
      _fetchTasks();
    } else {
      print(result.error!.message);
    }
  }

 _clearAllTasks() async {
  final ParseResponse result = await ParseObject('Task').getAll();

  if (result.success && result.results != null) {
    for (ParseObject task in result.results!) {
      final ParseResponse deleteResult = await task.delete();
      if (!deleteResult.success) {
        print(deleteResult.error!.message);
      }
    }
    setState(() {
      _tasks.clear();
    });
  } else {
    print(result.error!.message);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter CRUD with Back4App'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Task Title'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Task Description'),
                ),
                ElevatedButton(
                  onPressed: _addTask,
                  child: Text('Add Task'),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _clearAllTasks,
            child: Text('Delete All'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return ListTile(
                  title: Text(task.get('title')),
                  subtitle: Text(task.get('description')),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _updateTask(task),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteTask(task),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
