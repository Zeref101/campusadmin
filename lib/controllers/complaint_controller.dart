import 'package:flutter/material.dart';
import 'package:flutter_application_1/contants/secrets.dart';
import 'package:flutter_application_1/controllers/appwrite_service.dart';
import 'package:flutter_application_1/models/complaint.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:appwrite/appwrite.dart';
import 'dart:io';

// import 'package:permission_handler/permission_handler.dart';

class ComplaintController extends GetxController {
  final AppwriteService appwriteService = Get.find<AppwriteService>();
  // final LocationController locationController = Get.find<LocationController>();
  // final UserProfileController userProfileController =
  // Get.find<UserProfileController>();
  final isLoading = false.obs;
  final complaints = <Complaint>[].obs;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final buildingController = TextEditingController();

  final selectedImages = <File>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchComplaints();
  }

  Future<void> fetchComplaints() async {
    try {
      isLoading.value = true;

      final result = await appwriteService.database.listDocuments(
        databaseId: Secrets.databaseId,
        collectionId: Secrets.complaintsCollectionId,
        queries: [Query.orderDesc('createdAt')],
      );
      complaints.assignAll(
        result.documents.map((doc) => Complaint.fromMap(doc.data)),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch complaints: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateComplaintStatus(
      String complaintId, String newStatus) async {
    try {
      isLoading.value = true;

      // Update the status field of the complaint document
      await appwriteService.database.updateDocument(
        databaseId: Secrets.databaseId,
        collectionId: Secrets.complaintsCollectionId,
        documentId: complaintId,
        data: {
          'status': newStatus,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      // Refresh the complaints list
      await fetchComplaints();

      Get.snackbar(
        'Success',
        'Complaint status updated to $newStatus',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update complaint status: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Future<void> pickImages() async {
  //   final ImagePicker picker = ImagePicker();
  //   final List<XFile> images = await picker.pickMultiImage();

  //   if (images.isNotEmpty) {
  //     selectedImages.addAll(images.map((image) => File(image.path)));
  //   }
  // }

  // Future<List<String>> uploadImages() async {
  //   List<String> photoUrls = [];

  //   for (File image in selectedImages) {
  //     final fileName =
  //         '${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}';

  //     final result = await appwriteService.storage.createFile(
  //       bucketId: Secrets.complaintsStorageBucketId,
  //       fileId: ID.unique(),
  //       file: InputFile.fromPath(path: image.path),
  //     );

  //     photoUrls.add(result.$id); // Store the file ID
  //   }

  //   return photoUrls;
  // }

  // Future<void> createComplaint() async {
  //   try {
  //     isLoading.value = true;
  //     update();

  //     final user = await appwriteService.account.get();
  //     final position = await LocationController.getCurrentLocation();
  //     // print(position!.latitude);
  //     // print(position.longitude);

  //     // if (position == null) {
  //     //   throw Exception('Location not available');
  //     // }
  //     if (position == null) {
  //       Get.snackbar(
  //         'Location Required',
  //         'Please enable location services and grant location permission to submit a complaint',
  //         backgroundColor: Colors.red,
  //         colorText: Colors.white,
  //         snackPosition: SnackPosition.BOTTOM,
  //         duration: Duration(seconds: 3),
  //         // buttonText: 'Settings',
  //         onTap: (_) {
  //           openAppSettings();
  //         },
  //       );
  //       return;
  //     }

  //     // Upload images first
  //     final photoUrls = await uploadImages();
  //     // final Location loc = Location(
  //     //     latitude: position.latitude,
  //     //     longitude: position.longitude,
  //     //     building: buildingController.text);
  //     final complaint = Complaint(
  //       id: ID.unique(),
  //       userId: user.$id,
  //       title: titleController.text,
  //       rollNo: userProfileController.loggedInUser!.rollNo,
  //       description: descriptionController.text,
  //       status: 'pending',
  //       photos: photoUrls,
  //       // location: Location(
  //       //   latitude: position.latitude,
  //       //   longitude: position.longitude,
  //       //   building: buildingController.text,
  //       // ),
  //       latitude: position.latitude,
  //       longitude: position.longitude,
  //       building: buildingController.text,
  //       createdAt: DateTime.now(),
  //       updatedAt: DateTime.now(),
  //     );

  //     await appwriteService.database.createDocument(
  //       databaseId: Secrets.databaseId,
  //       collectionId: Secrets.complaintsCollectionId,
  //       documentId: complaint.id,
  //       data: complaint.toMap(),
  //     );

  //     clearForm();
  //     update();
  //     // fetchComplaints();
  //     complaints.insert(0, complaint);
  //     update();

  //     Get.snackbar(
  //       'Success',
  //       'Complaint submitted successfully',
  //       backgroundColor: Colors.green,
  //       colorText: Colors.white,
  //       snackPosition: SnackPosition.BOTTOM,
  //     );
  //   } catch (e) {
  //     print(e.toString());
  //     Get.snackbar(
  //       'Error',
  //       "Failed to create complaint$e",
  //       backgroundColor: Colors.red,
  //       colorText: Colors.white,
  //       snackPosition: SnackPosition.BOTTOM,
  //     );
  //   } finally {
  //     isLoading.value = false;
  //     update();
  //   }
  // }

  // void clearForm() {
  //   titleController.clear();
  //   descriptionController.clear();
  //   buildingController.clear();
  //   selectedImages.clear();
  // }
}
