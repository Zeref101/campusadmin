// complaint_details_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/contants/secrets.dart';
import 'package:flutter_application_1/controllers/complaint_controller.dart';
import 'package:flutter_application_1/models/complaint.dart';
import 'package:flutter_application_1/screens/dashboard_screen.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class ComplaintDetailsScreen extends StatelessWidget {
  final Complaint complaint;
  final complaintController = Get.find<ComplaintController>(tag: 'complaint');

  ComplaintDetailsScreen({Key? key, required this.complaint}) : super(key: key);

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complaint Details'),
        // backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Section
            Container(
              width: double.infinity,
              color: Colors.grey[200],
              padding: EdgeInsets.all(16),
              child: Text(
                complaint.title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            // Images Carousel
            if (complaint.photos.isNotEmpty)
              Container(
                height: 200,
                child: PageView.builder(
                  itemCount: complaint.photos.length,
                  itemBuilder: (context, index) {
                    final imageUrl = complaint.photos[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: CachedNetworkImage(
                        imageUrl:
                            'https://cloud.appwrite.io/v1/storage/buckets/${Secrets.complaintsStorageBucketId}/files/$imageUrl/view?project=${Secrets.projId}&project=${Secrets.projId}&mode=admin',
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                            const Center(child: Icon(Icons.broken_image)),
                      ),
                    );
                  },
                ),
              ),
            SizedBox(height: 16),
            // Details Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    complaint.description,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Status: ',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(complaint.status),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          complaint.status.toUpperCase(),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  if (complaint.building != null &&
                      complaint.building!.isNotEmpty)
                    Text(
                      'Building: ${complaint.building}',
                      style: TextStyle(fontSize: 16),
                    ),
                  SizedBox(height: 16),
                  // Map Section
                  Container(
                    height: 200,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter:
                            LatLng(complaint.latitude, complaint.longitude),
                        // center: VIT_LOCATION,
                        // zoom: 16.0,
                        maxZoom: 25.0,
                        minZoom: 14.0,
                        // interactiveFlags: InteractiveFlag.all,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.app',
                          // Additional tile options
                          tileProvider: NetworkTileProvider(),
                          maxZoom: 40,
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(
                                  complaint.latitude, complaint.longitude),
                              child: Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  // Submission Date
                  Text(
                    'Submitted on: ${_formatDate(complaint.createdAt)}',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Obx(
                    () {
                      if (complaintController.isLoading.value)
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      return Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            await complaintController.updateComplaintStatus(
                                complaint.id, "In Progress");
                            Get.offAll(DashBoardScreen());
                          },
                          child: Text('Mark as In Progress'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
