// lib/screens/map_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/complaint_controller.dart';
import 'package:flutter_application_1/models/complaint.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatelessWidget {
  final ComplaintController complaintController =
      Get.find<ComplaintController>(tag: 'complaint');

  // VIT Vellore coordinates
  static const LatLng VIT_LOCATION = LatLng(12.844, 80.1559);

  MapScreen({super.key});

  // Custom marker colors based on status
  Color _getMarkerColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'In Progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.red;
    }
  }

  // Open location in external map app
  Future<void> _openInMaps(double lat, double lng) async {
    final url = 'https://www.openstreetmap.org/?mlat=$lat&mlon=$lng&zoom=18';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.inAppWebView);
    } else {
      Get.snackbar(
        'Error',
        'Could not open map',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Campus Complaints'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => complaintController.fetchComplaints(),
          ),
        ],
      ),
      body: Obx(() {
        if (complaintController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Convert complaints to markers
        final List<WeightedLatLng> heatmapPoints =
            complaintController.complaints
                .map(
                  (complaint) => WeightedLatLng(
                    LatLng((complaint.latitude), (complaint.longitude)),
                    1.0, // Base intensity for each complaint
                  ),
                )
                .toList();
        final List<Marker> markers =
            complaintController.complaints.map((complaint) {
          // Convert string coordinates to doubles
          final double lat = double.tryParse(complaint.latitude.toString()) ??
              VIT_LOCATION.latitude;
          final double lng = double.tryParse(complaint.longitude.toString()) ??
              VIT_LOCATION.longitude;
          print(complaint.status);
          return Marker(
            point: LatLng(lat, lng),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () => _showComplaintDetails(context, complaint),
              child: Container(
                child: Icon(
                  Icons.location_pin,
                  color: _getMarkerColor(complaint.status),
                  size: 40,
                ),
              ),
            ),
          );
        }).toList();

        return Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: VIT_LOCATION,
                // center: VIT_LOCATION,
                // zoom: 16.0,
                maxZoom: 25.0,
                minZoom: 14.0,
                // interactiveFlags: InteractiveFlag.all,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                  // Additional tile options
                  tileProvider: NetworkTileProvider(),
                  maxZoom: 40,
                ),
                HeatMapLayer(
                  heatMapDataSource:
                      InMemoryHeatMapDataSource(data: heatmapPoints),
                  // heatmapDataPoints: heatmapPoints,
                  heatMapOptions: HeatMapOptions(
                    radius: 60, // Adjust the radius of influence
                    // blur: 10, // Adjust the blur amount
                    gradient: HeatMapOptions.defaultGradient,
                    minOpacity: 0.1,
                  ),
                  // reset: _rebuildStream.stream,
                ),
                MarkerLayer(markers: markers),
              ],
            ),
            // Legend
            Positioned(
              right: 16,
              bottom: 16,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Status:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    _buildLegendItem('Pending', Colors.orange),
                    _buildLegendItem('In Progress', Colors.blue),
                    _buildLegendItem('Resolved', Colors.green),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.location_pin, color: color, size: 20),
        SizedBox(width: 4),
        Text(label),
      ],
    );
  }

  void _showComplaintDetails(BuildContext context, Complaint complaint) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              complaint.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(complaint.description),
            SizedBox(height: 8),
            if (complaint.building != null && complaint.building!.isNotEmpty)
              Text('Building: ${complaint.building}'),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getMarkerColor(complaint.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    complaint.status.toUpperCase(),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton.icon(
                  icon: Icon(Icons.directions),
                  label: Text('Open in Maps'),
                  onPressed: () async {
                    final lat = complaint.latitude;
                    final lng = complaint.longitude;
                    // if (lat != null && lng != null) {
                    await _openInMaps(lat, lng);
                    // }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
