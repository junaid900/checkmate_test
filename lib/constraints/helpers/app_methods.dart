import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart' as GetX;
import 'package:image_picker/image_picker.dart';
import '../../utils/route/route_names.dart';

goToLogin() {
  GetX.Get.offAllNamed(JRoutes.welcomeAuth);
}


Future<List<XFile>?> pickMultiImages() async {
  var pickedImages = await ImagePicker().pickMultiImage(
    maxWidth: 1800,
    maxHeight: 1800,
  );
  if (pickedImages.isNotEmpty) {
    return pickedImages;
  }
  return null;
}

Future<XFile?> pickImage({source = ImageSource.gallery}) async {
  var pickedFile = await ImagePicker().pickImage(
    source: source,
    maxWidth: 1800,
    maxHeight: 1800,
  );
  if (pickedFile != null) {
    return pickedFile;
  }
  return null;
}

String calculateAvgRating({
  required double communicationRating,
  required double behaviourRating,
  required double timeRating,
  required double loyaltyRating,
}) {
  try {
    double totalRating =
        communicationRating + behaviourRating + timeRating + loyaltyRating;
    print(totalRating);
    return (totalRating / 4).toStringAsFixed(1);
  } catch (e) {
    print(e);
    return "0.0";
  }
}

String postFormatDateString(String? dateString) {
  // Parse the input date string to a DateTime object
  try{
    if(dateString == null){
      return '';
    }
    DateTime dateTime = DateTime.parse(dateString);

    // Define the desired format
    DateFormat formatter = DateFormat('hh:mm a, dd MMM yyyy');

    // Format the DateTime object to the desired format
    return formatter.format(dateTime);
  }catch(e){
    return '';
  }

}