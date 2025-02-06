import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:todoapp/constant/api.dart';
import 'package:todoapp/models/todo.dart';

class ApiMethods {
  Future<List<Todo>> fetchData() async {
    List<Todo> myTodos = [];
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
        myTodos.add(t);
      });
      print(myTodos.length);
      return myTodos;
    } catch (e) {
      print("Error is $e");
    }
    return myTodos;
  }

  Future<void> post_todo({required title, required String desc}) async {
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
        fetchData();
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
      final Uri deleteUrl = Uri.parse(api + id + '/'); // Updated URL format
      http.Response response = await http.delete(deleteUrl);

      // Log the response status code and body for debugging
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 204) {
        fetchData();
      } else {
        print("Failed to delete todo. Status code: ${response.statusCode}");
        print("Error message: ${response.body}");
      }
    } catch (e) {
      print("Error deleting todo: $e");
    }
  }
}
