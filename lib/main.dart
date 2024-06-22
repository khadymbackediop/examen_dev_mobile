import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Point d'entrée de l'application
void main() {
  runApp(TodoApp());
}

// Classe principale de l'application qui configure le ChangeNotifierProvider et les routes
class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Initialise le TaskManager pour gérer l'état des tâches
      create: (context) => TaskManager(),
      child: MaterialApp(
        title: 'Task Manager', // Titre de l'application
        home: HomePage(), // Page d'accueil de l'application
        debugShowCheckedModeBanner: false, // Désactive le bandeau de débogage
        routes: {
          // Définition des routes de l'application
          FilteredTasksPage.routeName: (context) => FilteredTasksPage(),
          AddTaskPage.routeName: (context) => AddTaskPage(),
          UpdateTaskPage.routeName: (context) => UpdateTaskPage(),
        },
      ),
    );
  }
}

// Classe pour gérer l'état des tâches
class TaskManager with ChangeNotifier {
  // Liste des tâches initiales
  List<Task> _taskList = [
    Task(title: 'Task A', status: 'Pending'),
    Task(title: 'Task B', status: 'In Progress'),
    Task(title: 'Task C', status: 'Issue'),
    Task(title: 'Task D', status: 'Issue'),
    Task(title: 'Task E', status: 'Pending'),
    Task(title: 'Task F', status: 'Pending'),
    Task(title: 'Task G', status: 'Completed'),
  ];

  // Liste filtrée des tâches
  List<Task> _filteredTasks = [];

  // Getters pour accéder aux listes de tâches
  List<Task> get taskList => _taskList;
  List<Task> get filteredTasks => _filteredTasks;

  // Méthode pour ajouter une tâche
  void addTask(Task task) {
    _taskList.add(task);
    notifyListeners(); // Notifie les widgets écoutant ce modèle de changement d'état
  }

  // Méthode pour modifier une tâche
  void modifyTask(int index, Task task) {
    _taskList[index] = task;
    notifyListeners();
  }

  // Méthode pour filtrer les tâches par statut
  void filterTasks(List<String> filters) {
    _filteredTasks = _taskList.where((task) => filters.contains(task.status)).toList();
    notifyListeners();
  }
}

// Classe représentant une tâche
class Task {
  String title; // Titre de la tâche
  String status; // Statut de la tâche
  String description; // Description de la tâche

  // Constructeur de la tâche
  Task({required this.title, required this.status, this.description = ''});

  // Méthode pour obtenir la couleur en fonction du statut
  Color get color {
    switch (status) {
      case 'Pending':
        return Colors.grey;
      case 'In Progress':
        return Colors.green;
      case 'Completed':
        return Colors.lightBlue;
      case 'Issue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Méthode pour rafraîchir la couleur (peut être étendue pour des mises à jour supplémentaires)
  void refreshColor() {
    // Additional updates if required.
  }
}

// Page d'accueil affichant la liste des tâches
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Manager'), // Titre de l'application
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => FilterDialog(), // Affiche le dialogue de filtre
              );
            },
          ),
        ],
      ),
      body: Consumer<TaskManager>(
        builder: (context, taskManager, child) {
          return TaskListView(taskManager: taskManager); // Affiche la liste des tâches
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AddTaskPage.routeName).then((value) {
            Provider.of<TaskManager>(context, listen: false).notifyListeners();
          });
        },
        child: Icon(Icons.add), // Bouton pour ajouter une nouvelle tâche
      ),
    );
  }
}

// Widget pour afficher la liste des tâches
class TaskListView extends StatelessWidget {
  final TaskManager taskManager;

  TaskListView({required this.taskManager});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: taskManager.taskList.length,
      itemBuilder: (context, index) {
        return TaskTile(
          task: taskManager.taskList[index],
          index: index,
        );
      },
    );
  }
}

// Widget pour afficher une tâche individuelle
class TaskTile extends StatelessWidget {
  final Task task;
  final int index;

  TaskTile({required this.task, required this.index});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: task.color, // Affiche la couleur basée sur le statut
      ),
      title: Text(task.title), // Affiche le titre de la tâche
      onTap: () {
        Navigator.pushNamed(
          context,
          UpdateTaskPage.routeName,
          arguments: {'task': task, 'index': index}, // Passe la tâche et son index à la page de modification
        );
      },
    );
  }
}

// Page pour mettre à jour une tâche
class UpdateTaskPage extends StatefulWidget {
  static const routeName = '/update-task';

  @override
  _UpdateTaskPageState createState() => _UpdateTaskPageState();
}

class _UpdateTaskPageState extends State<UpdateTaskPage> {
  final _formKey = GlobalKey<FormState>();
  late Task _task;
  late int _index;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _task = args['task'];
    _index = args['index'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Task'), // Titre de la page
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Update Task',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _task.status,
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: <String>['Pending', 'In Progress', 'Completed', 'Issue']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _task.status = newValue!;
                  });
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _task.title,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                onSaved: (newValue) {
                  _task.title = newValue!;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _task.description,
                maxLines: 6,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                onSaved: (newValue) {
                  _task.description = newValue!;
                },
              ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      _task.refreshColor();
                      Provider.of<TaskManager>(context, listen: false).modifyTask(_index, _task);
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Update'), // Bouton pour mettre à jour la tâche
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Dialogue pour filtrer les tâches
class FilterDialog extends StatefulWidget {
  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  final List<String> _filters = ['Pending', 'In Progress', 'Completed', 'Issue'];
  final Map<String, bool> _selectedFilters = {
    'Pending': false,
    'In Progress': false,
    'Completed': false,
    'Issue': false,
  };

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Filter Tasks'), // Titre du dialogue
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: _filters.map((filter) {
          return CheckboxListTile(
            title: Text(filter),
            value: _selectedFilters[filter],
            onChanged: (value) {
              setState(() {
                _selectedFilters[filter] = value!;
              });
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'), // Bouton pour annuler
        ),
        ElevatedButton(
          onPressed: () {
            List<String> appliedFilters = _filters.where((filter) => _selectedFilters[filter]!).toList();
            Provider.of<TaskManager>(context, listen: false).filterTasks(appliedFilters);
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed(FilteredTasksPage.routeName);
          },
          child: Text('Apply'), // Bouton pour appliquer le filtre
        ),
      ],
    );
  }
}

// Page pour afficher les tâches filtrées
class FilteredTasksPage extends StatelessWidget {
  static const routeName = '/filtered-tasks';

  @override
  Widget build(BuildContext context) {
    final taskManager = Provider.of<TaskManager>(context);
    final filteredTasks = taskManager.filteredTasks;
    return Scaffold(
      appBar: AppBar(
        title: Text('Filtered Tasks'), // Titre de la page
      ),
      body: ListView.builder(
        itemCount: filteredTasks.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(filteredTasks[index].title), // Titre de la tâche filtrée
            leading: CircleAvatar(
              backgroundColor: filteredTasks[index].color, // Couleur de la tâche filtrée
            ),
          );
        },
      ),
    );
  }
}

// Page pour ajouter une nouvelle tâche
class AddTaskPage extends StatefulWidget {
  static const routeName = '/add-task';

  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _formKey = GlobalKey<FormState>();
  String _taskTitle = '';
  String _taskStatus = 'Pending';
  String _taskDescription = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Task'), // Titre de la page
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'New Task',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _taskStatus,
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: <String>['Pending', 'In Progress', 'Completed', 'Issue']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _taskStatus = newValue!;
                  });
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                onSaved: (newValue) {
                  _taskTitle = newValue!;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                onSaved: (newValue) {
                  _taskDescription = newValue!;
                },
              ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      final newTask = Task(
                        title: _taskTitle,
                        status: _taskStatus,
                        description: _taskDescription,
                      );
                      Provider.of<TaskManager>(context, listen: false).addTask(newTask);
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Add Task'), // Bouton pour ajouter la tâche
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
