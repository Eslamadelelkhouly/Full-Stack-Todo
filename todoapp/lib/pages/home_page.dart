import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pie_chart/pie_chart.dart';
import 'package:todoapp/constant/api.dart';
import 'package:todoapp/models/todo.dart';
import 'package:todoapp/utils/method.dart';
import 'package:todoapp/widgets/app_bar.dart';
import 'package:todoapp/widgets/container_todo.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int done = 0;
  bool isLoading = true;
  List<Todo> MyTodos = [];
  ApiMethods apiMethods = ApiMethods();

  @override
  void initState() {
    apiMethods.fetchData().then(
      (value) {
        setState(() {
          MyTodos = value;
          isLoading = false;
        });
      },
    );
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
                "Incomplete": (MyTodos.length - done).toDouble(),
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
                    children: MyTodos.map((e) {
                      return ContainerTodo(
                        onPressed: () {},
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
                    controller: titleController,
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
                    controller: descController,
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
                      Navigator.pop(context);
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
