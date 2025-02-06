import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pie_chart/pie_chart.dart';
import 'package:todoapp/constant/api.dart';
import 'package:todoapp/models/todo.dart';
import 'package:todoapp/widgets/app_bar.dart';
import 'package:todoapp/widgets/container_todo.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int done = 0;
  List<Todo> myTodos = [];
  bool isLoading = true;
  void fetchData() async {
    try {
      http.Response response = await http.get(Uri.parse(api));
      var data = json.decode(response.body);
      data.forEach((todo) {
        Todo t = Todo(
          id: todo['id'],
          title: todo['title'],
          desc: todo['desc'],
          date: todo['date'],
          isDone: todo['isDone'],
        );
        if (todo['isDone']) {
          done += 1;
        }
        myTodos.add(t);
      });
      print(myTodos.length);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error is $e");
    }
  }

  void post_todo({required title, required String desc}) async {
    try {
      final Uri url = Uri.parse(api); // Ensure correct endpoint

      final http.Response response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "title": title.isEmpty ? "Untitled" : title,
          "desc": desc.isEmpty ? "No description" : desc,
          "isDone": false,
        }),
      );

      if (response.statusCode == 201) {
        setState(() {
          fetchData();
        });
      } else {
        print(
            "Something went wrong: ${response.statusCode}, Response: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void delete_todo(String id) async {
    try {
      print("Deleting todo with ID: $id");
      final Uri deleteUrl =
          Uri.parse(api+id+'/'); // Updated URL format
      http.Response response = await http.delete(deleteUrl);

      // Log the response status code and body for debugging
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 204) {
        // 204 No Content is the success status for DELETE
        setState(() {
          myTodos.removeWhere((todo) => todo.id.toString() == id);
        });
      } else {
        print("Failed to delete todo. Status code: ${response.statusCode}");
        print("Error message: ${response.body}");
      }
    } catch (e) {
      print("Error deleting todo: $e");
    }
  }

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      backgroundColor: Color(0xff001133),
      body: SingleChildScrollView(
        child: Column(
          children: [
            PieChart(
              dataMap: {
                "Done": done.toDouble(),
                "Incomplete": (myTodos.length - done).toDouble(),
              },
              legendOptions: LegendOptions(
                legendTextStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            isLoading
                ? CircularProgressIndicator()
                : Column(
                    children: myTodos.map((e) {
                      return ContainerTodo(
                        onPressed: () => delete_todo(e.id.toString()),
                        id: e.id,
                        title: e.title,
                        desc: e.desc,
                        isDone: e.isDone,
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        child: Icon(
          Icons.add,
          color: Colors.pink,
        ),
        onPressed: () {
          CustomBottomSheet(context);
        },
      ),
    );
  }

  Future<dynamic> CustomBottomSheet(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    TextEditingController descController = TextEditingController();

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.80,
          color: Colors.white,
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Add Todo',
                    style: TextStyle(
                      color: Colors.pink,
                      fontSize: 20,
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.90,
                  child: TextField(
                    controller: titleController, // ✅ Use controller
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Title',
                      hintStyle: TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Color(0xff001133),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Container(
                  width: MediaQuery.of(context).size.width * 0.90,
                  child: TextField(
                    controller: descController, // ✅ Use controller
                    maxLines: 5,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Description',
                      hintStyle: TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Color(0xff001133),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Container(
                  width: 160,
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      String title = titleController.text.trim();
                      String desc = descController.text.trim();

                      post_todo(title: title, desc: desc);
                      Navigator.pop(context); // ✅ Close BottomSheet
                    },
                    child: Text(
                      'Add',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 280),
              ],
            ),
          ),
        );
      },
    );
  }
}
