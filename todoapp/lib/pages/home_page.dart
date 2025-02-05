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

  void delete_todo(String id) async {
    try {
      http.Response response = await http.delete(Uri.parse(api + "/" + id));
      fetchData();
      setState(() {
        myTodos = [];
      });
    } catch (e) {
      print(e);
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
                "done": done.toDouble(),
                "incomplete": (myTodos.length - done).toDouble(),
              },
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
          showModalBottomSheet(
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
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Title',
                            hintStyle: TextStyle(
                              color: Colors.white,
                            ),
                            filled: true,
                            fillColor: Color(0xff001133),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.90,
                        child: TextField(
                          maxLines: 5,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Description',
                            hintStyle: TextStyle(
                              color: Colors.white,
                            ),
                            filled: true,
                            fillColor: Color(0xff001133),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        width: 160,
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink,
                            textStyle: TextStyle(color: Colors.white),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {},
                          child: Text(
                            'Add',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 280,
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
