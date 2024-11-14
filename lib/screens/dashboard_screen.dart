//ignore_for_file: prefer_const_constructors
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/complaint_controller.dart';
import 'package:flutter_application_1/models/complaint.dart';
import 'package:flutter_application_1/screens/complaint_details_screen.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'map_screen.dart';

// class AppwriteService2 {
//   static const String endpoint = 'https://cloud.appwrite.io/v1';
//   static const String projectId = '672b6e4500011db2d891'; // Your Project ID

//   Future<void> getProjectInfo() async {
//     final response = await http.get(
//       Uri.parse('$endpoint/projects/$projectId'),
//       headers: {
//         'Content-Type': 'application/json',
//       },
//     );

//     if (response.statusCode == 200) {
//       // If the server returns a 200 OK response, parse the data
//       var data = jsonDecode(response.body);
//       print('Project Info: ${data}');
//     } else {
//       // If the server did not return a 200 OK response, throw an exception.
//       print('Failed to load project info: ${response.statusCode}');
//     }
//   }
// }

class DashBoardScreen extends StatefulWidget {
  DashBoardScreen({super.key});
  // final appwriteService = AppwriteService2();

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  // UserProfileController userProfileController =
  ComplaintController complaintController =
      Get.put(ComplaintController(), tag: 'complaint');

  final RxString selectedFilter = 'All'.obs;

  final List<String> filterOptions = [
    'All',
    'Pending',
    'In Progress',
    'Resolved'
  ];

  // LogoutController logoutController = Get.put(LogoutController());
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'In Progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Filter Complaints'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: filterOptions.map((option) {
              return RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: selectedFilter.value,
                onChanged: (value) {
                  selectedFilter.value = value!;
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  // @override
  // void initState() {
  //   super.initState();
  //   // Call the API when the screen is initialized
  //   widget.appwriteService.getProjectInfo();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog();
            },
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => Get.to(ComplaintFormScreen()),
      //   // backgroundColor: Colors.black,
      //   child: Icon(Icons.add),
      // ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: Text(
                'Campus Resolve',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            // ListTile(
            //   leading: Icon(Icons.report),
            //   title: Text('My Complaints'),
            //   onTap: () {
            //     Navigator.pop(context); // Close the drawer
            //     Get.to(() => MyComplaintsScreen());
            //   },
            // ),
            ListTile(
              leading: Icon(Icons.report),
              title: Text('Map View'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Get.to(() => MapScreen());
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => complaintController.fetchComplaints(),
        child: Obx(
          () {
            if (complaintController.isLoading.value) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (complaintController.complaints.isEmpty) {
              return Center(child: Text('No complaints yet!'));
            }
            List<Complaint> filteredComplaints = complaintController.complaints;
            if (selectedFilter.value != 'All') {
              filteredComplaints = filteredComplaints.where((complaint) {
                return complaint.status.toLowerCase() ==
                    selectedFilter.value.toLowerCase();
              }).toList();
            }

            if (filteredComplaints.isEmpty) {
              return Center(child: Text('No complaints found.'));
            }
            return ListView.builder(
              itemCount: filteredComplaints.length,
              itemBuilder: (context, index) {
                final complaint = filteredComplaints[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Row(
                          children: [
                            Text(
                              'Roll No: ${complaint.rollNo}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ListTile(
                        title: Text(
                          complaint.title,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(complaint.description),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 16),
                                Text(
                                  ' ${complaint.latitude.toStringAsFixed(6)}, ${complaint.longitude.toStringAsFixed(6)}',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            if (complaint.building != null &&
                                complaint.building!.isNotEmpty)
                              Text('Building: ${complaint.building}'),
                            SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(complaint.status),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    complaint.status.toUpperCase(),
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ),
                                Text(
                                  _formatDate(complaint.createdAt),
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: complaint.photos.isNotEmpty
                            ? Icon(Icons.photo_library)
                            : null,
                        onTap: () {
                          Get.to(() =>
                              ComplaintDetailsScreen(complaint: complaint));
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
