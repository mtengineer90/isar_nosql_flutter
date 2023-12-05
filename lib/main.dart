// Import necessary packages and files
import 'package:flutter/material.dart';
import 'local_db/isar_service.dart';
import 'models/user.dart';

// Main function to run the Flutter application
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

// Main application widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp configuration
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'User App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

// Home page widget
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// Service instance for Isar database operations
IsarService isarService = IsarService();

// Text editing controllers for user input
late TextEditingController _controller;
late TextEditingController _controller2;

// State class for the home page
class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    // Initialize text editing controllers
    _controller = TextEditingController();
    _controller2 = TextEditingController();
    super.initState();
  }

  // Form key for form validation
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Scaffold widget for the app's structure
    return Scaffold(
      appBar: AppBar(
        title: const Text("User App"),
        centerTitle: true,
        actions: [
          // Add user button
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () {
                // Show modal for adding a new user
                showModel("add", User("", 0));
              },
              child: const Icon(
                Icons.add,
                size: 35,
              ),
            ),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: StreamBuilder<List<User>>(
              stream: isarService.listenUser(),
              builder: (context, snapshot) => snapshot.hasData
                  ? InkWell(
                onTap: () async {
                  // Filter and print user data
                  final a = await isarService.filterName();
                  print(a!.name);
                },
                child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            // User icon
                            Icon(
                              Icons.person_4_outlined,
                              size: 50,
                            ),
                            // User name
                            Text(snapshot.data![index].name!),
                            Row(
                              children: [
                                // Update user icon
                                InkWell(
                                  onTap: () {
                                    // Prepare data for updating user
                                    _controller.text =
                                    snapshot.data![index].name!;
                                    _controller2.text = snapshot
                                        .data![index].id
                                        .toString();
                                    showModel(
                                        "update",
                                        snapshot.data![index]);
                                  },
                                  child: Icon(
                                    Icons.autorenew_outlined,
                                    size: 30,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                // Delete user icon
                                InkWell(
                                  onTap: () async {
                                    // Delete user
                                    await isarService.deleteUser(
                                        snapshot.data![index].id);
                                  },
                                  child: Icon(
                                    Icons.delete,
                                    size: 30,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
                  : const Text("Data Not Found."),
            ),
          ),
        ],
      ),
    );
  }

  // Show modal for adding or updating user
  showModel(deger, User user) {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom:
              MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: 300,
            color: Colors.white,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Close modal button
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Icon(
                          Icons.close,
                          size: 40,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User name input
                        TextFormField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Name',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Empty!';
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        // User age input
                        TextFormField(
                          controller: _controller2,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Age',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Empty!';
                            }
                            return null;
                          },
                        ),
                        // Add or update user button
                        deger == "add"
                            ? Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16.0),
                          child: ElevatedButton(
                            onPressed: () async {
                              // Save new user and close modal
                              await isarService.saveUser(User(
                                  _controller.text,
                                  int.parse(_controller2.text)));
                              Navigator.of(context).pop();
                              _controller.text = "";
                              _controller2.text = "";
                            },
                            child: const Text('Submit'),
                          ),
                        )
                            : Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16.0),
                          child: ElevatedButton(
                            onPressed: () async {
                              // Update user and close modal
                              user.name = _controller.text;
                              user.age = int.parse(_controller2.text);
                              await isarService.UpdateUser(user);
                              Navigator.of(context).pop();
                              _controller.text = "";
                              _controller2.text = "";
                            },
                            child: const Text('Submit'),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}