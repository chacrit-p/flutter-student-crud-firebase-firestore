import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentListPage extends StatefulWidget {
  @override
  _StudentListPageState createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // เพิ่มนักเรียน
  Future<void> addStudent(String name, String id, String major) async {
    await _firestore.collection('students').add({
      'name': name,
      'id': id,
      'major': major,
    });
  }

  // ลบข้อมูลนักเรียน
  Future<void> deleteStudent(String docId) async {
    await _firestore.collection('students').doc(docId).delete();
  }

  // แก้ไขข้อมูลนักเรียน
  Future<void> updateStudent(String docId, String name, String id, String major) async {
    await _firestore.collection('students').doc(docId).update({
      'name': name,
      'id': id,
      'major': major,
    });
  }

  // Dialog สำหรับเพิ่มนักเรียนใหม่
  void _showAddStudentDialog() {
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _idController = TextEditingController();
    final TextEditingController _majorController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Student'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Name')),
            TextField(controller: _idController, decoration: InputDecoration(labelText: 'ID')),
            TextField(controller: _majorController, decoration: InputDecoration(labelText: 'Major')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              addStudent(_nameController.text, _idController.text, _majorController.text);
              Navigator.pop(context);
            },
            child: Text('Add'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Records'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('students').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var students = snapshot.data!.docs;
          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              var student = students[index];
              return ListTile(
                title: Text(student['name']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ID: ${student['id']}, Major: ${student['major']}'),
                    SizedBox(height: 5),
                    Text('Click to edit', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),  // เพิ่มข้อความ hint
                  ],
                ),
                onTap: () {
                  // กดเพื่อแก้ไขข้อมูล
                  showDialog(
                    context: context,
                    builder: (context) => EditStudentDialog(
                      studentId: student.id,
                      name: student['name'],
                      id: student['id'],
                      major: student['major'],
                      updateStudent: updateStudent,
                    ),
                  );
                },
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    // กดเพื่อลบข้อมูล
                    deleteStudent(student.id);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStudentDialog,  // แสดง dialog สำหรับเพิ่มนักเรียน
        child: Icon(Icons.add),
      ),
    );
  }
}

class EditStudentDialog extends StatelessWidget {
  final String studentId;
  final String name;
  final String id;
  final String major;
  final Future<void> Function(String, String, String, String) updateStudent;

  EditStudentDialog({
    required this.studentId,
    required this.name,
    required this.id,
    required this.major,
    required this.updateStudent,
  });

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _majorController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _nameController.text = name;
    _idController.text = id;
    _majorController.text = major;

    return AlertDialog(
      title: Text('Edit Student'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Name')),
          TextField(controller: _idController, decoration: InputDecoration(labelText: 'ID')),
          TextField(controller: _majorController, decoration: InputDecoration(labelText: 'Major')),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            updateStudent(studentId, _nameController.text, _idController.text, _majorController.text);
            Navigator.pop(context);
          },
          child: Text('Save'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
      ],
    );
  }
}
