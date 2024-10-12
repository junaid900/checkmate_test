import 'dart:io';

import 'package:camera/camera.dart';
import 'package:checkmate/providers/user/profile_provider.dart';
import 'package:checkmate/ui/common/app_color_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../constraints/helpers/app_methods.dart';
import '../../../constraints/helpers/helper.dart';
import '../../../constraints/j_var.dart';
import '../../../constraints/jcolor.dart';
import '../../../modals/common/jfile.dart';
import '../../../providers/post/create_post_provider.dart';
import '../../common/app_input_field.dart';
import '../../common/placeholder_image.dart';
import '../../common/touchable_opacity.dart';
import '../view_profile_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController fname = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController username = TextEditingController();

  // TextEditingController phone = TextEditingController();
  TextEditingController dob = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController about = TextEditingController();
  bool isEmailEditable = false;
  bool isMyProfile = false;
  JFile selectedProfileImage = JFile(uid: "selected_profile");
  JFile selectedCoverImage = JFile(uid: "selected_cover");

  void getPageData() async {
    var profileProvider = context.read<ProfileProvider>();
    setState(() {
      fname.text = profileProvider.profile.fname ?? '';
      email.text = profileProvider.profile.email ?? '';
      username.text = profileProvider.profile.username ?? '';
      // phone.text = profileProvider.profile.phoneNumber ?? '';
      address.text = profileProvider.profile.address ?? '';
      about.text = profileProvider.profile.about ?? '';
      if(profileProvider.profile.googleId!.isNotEmpty || profileProvider.profile.appleId!.isNotEmpty){
        isEmailEditable = false;
      }
      selectedCoverImage.fileUrl = profileProvider.profile.coverImage ?? '';
      selectedProfileImage.fileUrl = profileProvider.profile.profileImage ?? '';
    });
  }

  submit() async {
    var profileProvider = context.read<ProfileProvider>();
    var payload = {
      "fnmae": fname.text,
      "email": email.text,
      "username": username.text,
      "address": address.text,
      "about": about.text,
      "id": profileProvider.profile.id,
    };
    showProgressDialog(context, "Please wait...");
    var response = await profileProvider.updateProfile(payload);
    hideProgressDialog(context);
    if (response) {
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getPageData();
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              children: [
                Stack(
                  children: [
                    SizedBox(
                      height: 250,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 30),
                        child: GestureDetector(
                          onTap: () {
                            pickFileSheet(type: "cover");
                          },
                          child: ClipRRect(
                            // borderRadius: BorderRadius.circular(20),
                            child: selectedCoverImage.isUploading
                                ? Center(
                                    child: SizedBox(
                                        width: 40,
                                        height: 40,
                                        child: CircularProgressIndicator()),
                                  )
                                : ImageWithPlaceholder(
                                    image: '${selectedCoverImage.fileUrl}',
                                    prefix:
                                        "${JVar.FILE_URL}${JVar.imagePaths.userProfileCover}/",
                                    width: getWidth(context),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: Container(
                        // margin: EdgeInsets.only(bottom: 10),
                        margin: EdgeInsets.only(left: 13),
                        height: 80,
                        width: 80,
                        child: GestureDetector(
                          onTap: () {
                            pickFileSheet(type: "profile");
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: selectedProfileImage.isUploading
                                ? Center(
                                    child: SizedBox(
                                        width: 40,
                                        height: 40,
                                        child: CircularProgressIndicator()),
                                  )
                                : ImageWithPlaceholder(
                                    image: '${selectedProfileImage.fileUrl}',
                                    prefix:
                                        '${JVar.FILE_URL}${JVar.imagePaths.userProfileImage}/',
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Full Name",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                      width: getWidth(context),
                      child: AppInputField(
                          controller: fname, hintText: "Full Name")),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "@username",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                      width: getWidth(context),
                      child: AppInputField(
                        controller: username,
                        hintText: "Username",
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Email",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                      width: getWidth(context),
                      child: IgnorePointer(
                        ignoring: !isEmailEditable,
                        child: AppInputField(
                          controller: email,
                          hintText: "Email",
                        ),
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  // Text(
                  //   "Phone",
                  //   style: TextStyle(
                  //       fontSize: 16, fontWeight: FontWeight.w600),
                  // ),
                  // SizedBox(
                  //     width: getWidth(context),
                  //     child: IgnorePointer(
                  //       child: AppInputField(
                  //         controller: phone,
                  //         hintText: "+12345678",
                  //       ),
                  //     )),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Address",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                      width: getWidth(context),
                      child: AppInputField(
                        controller: address,
                        hintText: "Eg. New York City",
                        maxLines: 3,
                        minLines: 3,
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "About",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                      width: getWidth(context),
                      child: AppInputField(
                        controller: about,
                        hintText: "Eg. Doctor by profession",
                        maxLines: 3,
                        minLines: 3,
                      )),
                  SizedBox(
                    height: 22,
                  ),
                  AppColorButton(
                    name: "Submit",
                    elevation: 0,
                    onPressed: (){
                      submit();
                    },
                  ),
                  SizedBox(height: 22,),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  pickFileSheet({type = "profile"}) async {
    showModalBottomSheet(
        context: context,
        builder: (__) {
          return Container(
            // padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 14.0),
                  child: Text(
                    "Choose File",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                ListTile(
                  onTap: () async {
                    Navigator.of(context).pop();
                    XFile? file = await pickImage(source: ImageSource.camera);
                    file = await cropImage(file,type);
                    if(file != null){
                      loadImage(file, type: type);
                    }
                  },
                  title: Text("Camera"),
                ),
                ListTile(
                  onTap: () async {
                    Navigator.of(context).pop();
                    XFile? file = await pickImage(source: ImageSource.gallery);
                    // loadImage(file, type: type);
                    file = await cropImage(file,type);
                    if(file != null){
                      loadImage(file, type: type);
                    }
                  },
                  title: Text("Gallery"),
                ),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          );
        });
  }

  loadImage(XFile? file, {type = 'profile'}) async {
    if (file != null) {
      print("uploading");
      var urlResponse = '';
      var profileProvider = context.read<ProfileProvider>();

      if (type == "profile") {
        selectedProfileImage.isUploading = true;
        selectedProfileImage.file = File(file.path);
        setState(() {
          selectedProfileImage = selectedProfileImage;
        });
        urlResponse = await CreatePostProvider().uploadFiles(
            "${JVar.imagePaths.userProfileImage}", File(file.path));
        print(urlResponse);
        if (urlResponse.isNotEmpty) {
          selectedProfileImage.isUploading = false;
          selectedProfileImage.fileUrl = urlResponse;
          setState(() {
            // this.profile!.profileImage = urlResponse;
            selectedProfileImage = selectedProfileImage;
          });
          profileProvider.updateProfile(
              {"id": profileProvider.profile.id, "profile_image": urlResponse});
        }
      } else if (type == "cover") {
        selectedCoverImage.isUploading = true;
        selectedCoverImage.file = File(file.path);
        setState(() {
          selectedCoverImage = selectedCoverImage;
        });
        urlResponse = await CreatePostProvider().uploadFiles(
            "${JVar.imagePaths.userProfileCover}", File(file.path));
        if (urlResponse.isNotEmpty) {
          selectedCoverImage.isUploading = false;
          selectedCoverImage.fileUrl = urlResponse;
          setState(() {
            // this.profile!.coverImage = urlResponse;
            selectedCoverImage = selectedCoverImage;
          });
          profileProvider.updateProfile(
              {"id": profileProvider.profile.id, "cover_image": urlResponse});
        }
      }

      return;
    }
    showToast("cannot pick file");
  }
}
