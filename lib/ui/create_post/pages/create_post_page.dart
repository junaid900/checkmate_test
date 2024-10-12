import 'dart:io';
import 'dart:math';
import 'package:checkmate/api/japi.dart';
import 'package:checkmate/api/japi_service.dart';
import 'package:checkmate/constraints/constants.dart';
import 'package:checkmate/constraints/enum_values.dart';
import 'package:checkmate/constraints/helpers/helper.dart';
import 'package:checkmate/constraints/j_var.dart';
import 'package:checkmate/constraints/jcolor.dart';
import 'package:checkmate/modals/city.dart';
import 'package:checkmate/modals/common/jfile.dart';
import 'package:checkmate/providers/common/city_provider.dart';
import 'package:checkmate/providers/common/states_provider.dart';
import 'package:checkmate/providers/post/create_post_provider.dart';
import 'package:checkmate/ui/common/app_input_field.dart';
import 'package:checkmate/ui/common/placeholder_image.dart';
import 'package:checkmate/ui/common/touchable_opacity.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../constraints/helpers/app_methods.dart';
import '../../../modals/states.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  int currentStepIndex = 0;
  List Images = [];
  TextEditingController name = TextEditingController();
  TextEditingController description = TextEditingController();
  States? selectedState;
  City? selectedCity;
  String? selectedAge;
  String? selectedGender;
  String? selectedRace;
  String? selectedEthnicity;
  JFile selectedProfileImage = JFile(uid: "selected_profile");
  List<JFile> selectedDocuments = [];
  double communicationRating = 3.0;
  double loyaltyRating = 3.0;
  double timeRating = 3.0;
  double behaviourRating = 3.0;

  getPageData() async {
    var stateProvider = context.read<StatesProvider>();
    stateProvider.load();
  }

  void getCities() {
    var cityProvider = context.read<CityProvider>();
    if (selectedState != null) cityProvider.loadStateCities(selectedState!.id);
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getPageData();
    });
    super.initState();
  }


  pickProfileImage() async {
    XFile? file = await pickImage();
    if (file != null) {
      selectedProfileImage.isUploading = true;
      selectedProfileImage.file = File(file.path);
      setState(() {
        selectedProfileImage = selectedProfileImage;
      });
      var urlResponse = await uploadAndGetUrl(
          "${JVar.imagePaths.postProfileImage}", {"file": File(file.path)});

      selectedProfileImage.isUploading = false;
      if (urlResponse.isNotEmpty) selectedProfileImage.fileUrl = urlResponse;
      setState(() {
        selectedProfileImage = selectedProfileImage;
      });
      return;
    }
    showToast("cannot pick file");
  }

  Future<String> uploadAndGetUrl(type, Map<String, File> mapData) async {
    return await CreatePostProvider().uploadFiles(type, mapData["file"]);
  }

  submit() async {
    if (!checkStep1Data()) {
      return;
    }
    if (!checkStep2Data()) {
      return;
    }
    var payload = {
      "name": name.text,
      "state_id": selectedState!.id.toString(),
      "city_id": selectedCity!.id.toString(),
      "age": selectedAge,
      "gender": selectedGender,
      "race": selectedRace,
      "ethnicity": selectedEthnicity,
      "profile_image": selectedProfileImage.fileUrl,
      'description': description.text,
      "communication_rating": communicationRating.toString(),
      'loyality_rating': loyaltyRating.toString(),
      'behaviour_rating': behaviourRating.toString(),
      'time_rating': timeRating.toString(),
    };
    showProgressDialog(context, "Posting...");
    var response = await JApiService().postRequest(JApi.CREATE_POST, payload);
    hideProgressDialog(context);
    print(response);
    if (response != null) {
      print(response);
      var post_id = response["post_id"];
      if (post_id != null) {
        showToast("uploading post...");
        context.read<CreatePostProvider>().uploadPostFiles(post_id);
        Navigator.pop(context);
      } else {
        showAlertDialog(context, "Warning!",
            "We have encountered some error while uploading post. and it is saved in draft",
            type: AlertType.WARNING, onPress: () async {
          await Future.delayed(Duration(milliseconds: 100));
          Navigator.pop(context);
        });
        // Navigator.pop(context);
      }
    }
  }

  bool checkStep1Data() {
    if (name.text.isEmpty) {
      showToast("please enter valid name");
      return false;
    }
    if (selectedState == null) {
      showToast("please enter valid state");
      return false;
    }
    if (selectedState!.id == null) {
      showToast("please enter valid state");
      return false;
    }
    if (selectedCity == null) {
      showToast("please enter valid city");
      return false;
    }
    if (selectedCity!.id == null) {
      showToast("please enter valid city");
      return false;
    }
    if (selectedAge == null) {
      showToast("please enter valid age");
      return false;
    }
    if (selectedAge!.isEmpty) {
      showToast("please enter valid age");
      return false;
    }
    if (selectedGender == null) {
      showToast("please enter valid gender");
      return false;
    }
    if (selectedGender!.isEmpty) {
      showToast("please enter valid gender");
      return false;
    }
    if (selectedProfileImage.isUploading) {
      showToast("please wait a moment until profile image uploading");
      return false;
    }
    if (selectedProfileImage.fileUrl == null) {
      showToast("please enter valid profile image");
      return false;
    }
    if (selectedProfileImage.fileUrl!.isEmpty) {
      showToast("please enter valid profile image");
      return false;
    }
    return true;
  }

  bool checkStep2Data() {
    if (description.text.isEmpty) {
      showToast("please enter valid description");
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              width: getWidth(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.arrow_back_ios)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Create Post",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Fill out following details to let people know.",
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: getWidth(context),
                    // height: getHeight(context),
                    child: Stepper(
                        currentStep: currentStepIndex,
                        onStepCancel: () {
                          if (currentStepIndex > 0) {
                            setState(() {
                              currentStepIndex -= 1;
                            });
                          }
                        },
                        onStepContinue: () {
                          if (currentStepIndex == 0) {
                            bool isStep1Ok = checkStep1Data();
                            if (!isStep1Ok) {
                              return;
                            }
                          }
                          if (currentStepIndex == 1) {
                            bool isStep2Ok = checkStep2Data();
                            if (!isStep2Ok) {
                              return;
                            }
                          }
                          if (currentStepIndex >= 3) {
                            submit();
                            return;
                          }
                          setState(() {
                            currentStepIndex += 1;
                          });
                        },
                        onStepTapped: (int index) {
                          setState(() {
                            currentStepIndex = index;
                          });
                        },
                        connectorThickness: 1,
                        connectorColor: MaterialStateColor.resolveWith(
                            (states) => JColor.primaryColor),
                        elevation: 0,
                        physics: ClampingScrollPhysics(),
                        type: StepperType.vertical,
                        steps: [
                          Step(
                              title: Text("Profile"),
                              content: Container(
                                child: Column(
                                  children: [
                                    AppInputField(
                                        controller: name, hintText: "Name"),
                                    SizedBox(
                                      height: 6,
                                    ),
                                    Consumer<StatesProvider>(
                                        builder: (key, provider, child) {
                                      return DropdownSearch<States>(
                                        selectedItem: selectedState,
                                        items: provider.states,
                                        popupProps: PopupProps.dialog(
                                          itemBuilder: (context, States item,
                                                  selected) =>
                                              Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                            color: selected
                                                ? JColor.white
                                                : Colors.transparent,
                                            child: Text("${item.name}"),
                                          ),
                                          showSearchBox: true,
                                          title: Container(
                                              width: getWidth(context),
                                              padding: EdgeInsets.fromLTRB(
                                                  10, 10, 10, 10),
                                              decoration: BoxDecoration(
                                                  color: JColor.primaryColor),
                                              child: Center(
                                                child: Text(
                                                  "Search State",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              )),
                                        ),
                                        onChanged: (val) {
                                          setState(() {
                                            selectedState = val;
                                          });
                                          getCities();
                                        },
                                        dropdownDecoratorProps:
                                            DropDownDecoratorProps(
                                          dropdownSearchDecoration:
                                              InputDecoration(
                                            labelText: !provider.isLoading
                                                ? "Select State"
                                                : "Loading....",
                                            labelStyle: TextStyle(
                                              color: JColor.greyTextColor,
                                              fontWeight: FontWeight.normal,
                                            ),
                                            contentPadding:
                                                EdgeInsets.fromLTRB(0, 0, 0, 0),
                                            border: UnderlineInputBorder(),
                                          ),
                                        ),
                                      );
                                    }),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Consumer<CityProvider>(
                                        builder: (widget, provider, child) {
                                      return DropdownSearch<City>(
                                        items: provider.list,
                                        selectedItem: selectedCity,
                                        popupProps: PopupProps.dialog(
                                          itemBuilder:
                                              (context, City item, selected) =>
                                                  Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                            color: selected
                                                ? JColor.lighterGrey
                                                : Colors.transparent,
                                            child: Text("${item.name}"),
                                          ),
                                          showSearchBox: true,
                                          title: Container(
                                              width: getWidth(context),
                                              padding: EdgeInsets.fromLTRB(
                                                  10, 10, 10, 10),
                                              decoration: BoxDecoration(
                                                  color: JColor.primaryColor),
                                              child: Center(
                                                child: Text(
                                                  "Search City",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              )),
                                        ),
                                        onChanged: (val) {
                                          selectedCity = val;
                                        },
                                        dropdownDecoratorProps:
                                            DropDownDecoratorProps(
                                          dropdownSearchDecoration:
                                              InputDecoration(
                                            labelText: !provider.isLoading
                                                ? "Select City"
                                                : "Loading....",
                                            labelStyle: TextStyle(
                                              color: JColor.greyTextColor,
                                              fontWeight: FontWeight.normal,
                                            ),
                                            contentPadding:
                                                EdgeInsets.fromLTRB(0, 0, 0, 0),
                                            border: UnderlineInputBorder(),
                                          ),
                                        ),
                                      );
                                    }),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    DropdownSearch(
                                      selectedItem: selectedAge,
                                      items: Constants.ageList,
                                      onChanged: (val) {
                                        selectedAge = val;
                                      },
                                      dropdownDecoratorProps:
                                          DropDownDecoratorProps(
                                        dropdownSearchDecoration:
                                            InputDecoration(
                                          labelText: "Select Age",
                                          labelStyle: TextStyle(
                                            color: JColor.greyTextColor,
                                            fontWeight: FontWeight.normal,
                                          ),
                                          contentPadding:
                                              EdgeInsets.fromLTRB(0, 0, 0, 0),
                                          border: UnderlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                    DropdownSearch(
                                      selectedItem: selectedGender,
                                      items: Constants.genderList,
                                      onChanged: (val) {
                                        selectedGender = val;
                                      },
                                      dropdownDecoratorProps:
                                          DropDownDecoratorProps(
                                        dropdownSearchDecoration:
                                            InputDecoration(
                                          labelText: "Select Gender",
                                          labelStyle: TextStyle(
                                            color: JColor.greyTextColor,
                                            fontWeight: FontWeight.normal,
                                          ),
                                          contentPadding:
                                              EdgeInsets.fromLTRB(0, 0, 0, 0),
                                          border: UnderlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                    DropdownSearch(
                                      selectedItem: selectedRace,
                                      items: Constants.raceList,
                                      onChanged: (val) {
                                        selectedRace = val;
                                      },
                                      dropdownDecoratorProps:
                                          DropDownDecoratorProps(
                                        dropdownSearchDecoration:
                                            InputDecoration(
                                          labelText: "Select Race",
                                          labelStyle: TextStyle(
                                            color: JColor.greyTextColor,
                                            fontWeight: FontWeight.normal,
                                          ),
                                          contentPadding:
                                              EdgeInsets.fromLTRB(0, 0, 0, 0),
                                          border: UnderlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    DropdownSearch(
                                      selectedItem: selectedEthnicity,
                                      items: Constants.ethnicityList,
                                      onChanged: (val) {
                                        selectedEthnicity = val;
                                      },
                                      dropdownDecoratorProps:
                                          DropDownDecoratorProps(
                                        dropdownSearchDecoration:
                                            InputDecoration(
                                          labelText: "Select Ethnicity",
                                          labelStyle: TextStyle(
                                            color: JColor.greyTextColor,
                                            fontWeight: FontWeight.normal,
                                          ),
                                          contentPadding:
                                              EdgeInsets.fromLTRB(0, 0, 0, 0),
                                          border: UnderlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        Column(
                                          children: [
                                            Text(
                                              "Profile Image",
                                              style: TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                            TouchableOpacity(
                                              onTap: () {
                                                pickProfileImage();
                                              },
                                              child: Container(
                                                height: 80,
                                                width: 80,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Card(
                                                  elevation: 1,
                                                  child: selectedProfileImage
                                                              .fileUrl !=
                                                          null
                                                      ? ImageWithPlaceholder(
                                                          image:
                                                              selectedProfileImage
                                                                  .fileUrl,
                                                          prefix:
                                                              "${JVar.FILE_URL}${JVar.imagePaths.postProfileImage}/",
                                                        )
                                                      : selectedProfileImage
                                                              .isUploading
                                                          ? Center(
                                                              child: SizedBox(
                                                                  width: 50,
                                                                  height: 50,
                                                                  child:
                                                                      CircularProgressIndicator()))
                                                          : Icon(Icons
                                                              .add_a_photo_sharp),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              )),
                          Step(
                              title: Text("Description"),
                              content: Column(
                                children: [
                                  Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                      color:
                                          JColor.greyTextColor.withOpacity(.14),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: TextField(
                                      maxLines: 4,
                                      controller: description,
                                      decoration: InputDecoration(
                                        hintText: "Enter Description",
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  )
                                ],
                              )),
                          Step(
                              title: Text("Document"),
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Consumer<CreatePostProvider>(
                                      builder: (key, provider, child) {
                                    return Container(
                                      height: 76,
                                      child: ListView(
                                        scrollDirection: Axis.horizontal,
                                        children: [
                                          TouchableOpacity(
                                            onTap: () {
                                              pickFileSheet();
                                            },
                                            child: Card(
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 20),
                                                child: Icon(Icons.add),
                                              ),
                                            ),
                                          ),
                                          ...provider.fileList.map((e) {
                                            if (e.fileType == JFileType.VIDEO) {
                                              return Stack(
                                                children: [
                                                  Container(
                                                    padding: EdgeInsets.symmetric(
                                                        horizontal: 6),
                                                    child: Card(
                                                      child: SizedBox(
                                                          width: 80,
                                                          height: 80,
                                                          child: Icon(
                                                              Icons.play_circle)),
                                                    ),
                                                  ),
                                                  TouchableOpacity(
                                                    onTap:(){
                                                      context.read<CreatePostProvider>().removeFileItem(e.uid);
                                                    },
                                                    child: Container(
                                                        padding:
                                                        EdgeInsets.all(2),
                                                        decoration: BoxDecoration(
                                                          color: JColor.grey.withOpacity(.6),
                                                          borderRadius: BorderRadius.circular(50),
                                                        ),
                                                        child: Icon(Icons.close, color: JColor.white,)
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }
                                            return e.file == null
                                                ? Center(
                                                    child: Text(
                                                      "Invalid File",
                                                      style: TextStyle(
                                                          fontSize: 10),
                                                    ),
                                                  )
                                                : Stack(
                                                  children: [
                                                    Container(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                                horizontal: 6),
                                                        child: Image.file(e.file!)),
                                                    TouchableOpacity(
                                                      onTap:(){
                                                        context.read<CreatePostProvider>().removeFileItem(e.uid);
                                                      },
                                                      child: Container(
                                                          padding:
                                                          EdgeInsets.all(2),
                                                        decoration: BoxDecoration(
                                                            color: JColor.grey.withOpacity(.6),
                                                            borderRadius: BorderRadius.circular(50),
                                                        ),
                                                        child: Icon(Icons.close, color: JColor.white,)
                                                      ),
                                                    ),
                                                  ],
                                                );
                                          }).toList()
                                        ],
                                      ),
                                    );
                                  })
                                ],
                              )),
                          Step(
                              title: Text("Review"),
                              content: Column(
                                children: [
                                  Text("Communication"),
                                  RatingBar.builder(
                                    initialRating: communicationRating,
                                    minRating: 1,
                                    direction: Axis.horizontal,
                                    allowHalfRating: true,
                                    itemCount: 5,
                                    itemPadding:
                                        EdgeInsets.symmetric(horizontal: 4.0),
                                    itemBuilder: (context, _) => Icon(
                                      Icons.star,
                                      color: JColor.accentColor,
                                    ),
                                    onRatingUpdate: (rating) {
                                      print(rating);
                                      setState(() {
                                        communicationRating = rating;
                                      });
                                    },
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Text("Loyalty"),
                                  RatingBar.builder(
                                    initialRating: loyaltyRating,
                                    minRating: 1,
                                    direction: Axis.horizontal,
                                    allowHalfRating: true,
                                    itemCount: 5,
                                    itemPadding:
                                        EdgeInsets.symmetric(horizontal: 4.0),
                                    itemBuilder: (context, _) => Icon(
                                      Icons.star,
                                      color: JColor.accentColor,
                                    ),
                                    onRatingUpdate: (rating) {
                                      print(rating);
                                      setState(() {
                                        loyaltyRating = rating;
                                      });
                                    },
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Text("Time"),
                                  RatingBar.builder(
                                    initialRating: timeRating,
                                    minRating: 1,
                                    direction: Axis.horizontal,
                                    allowHalfRating: true,
                                    itemCount: 5,
                                    itemPadding:
                                        EdgeInsets.symmetric(horizontal: 4.0),
                                    itemBuilder: (context, _) => Icon(
                                      Icons.star,
                                      color: JColor.accentColor,
                                    ),
                                    onRatingUpdate: (rating) {
                                      timeRating = rating;
                                    },
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Text("Behaviour"),
                                  RatingBar.builder(
                                    initialRating: behaviourRating,
                                    minRating: 1,
                                    direction: Axis.horizontal,
                                    allowHalfRating: true,
                                    itemCount: 5,
                                    itemPadding:
                                        EdgeInsets.symmetric(horizontal: 4.0),
                                    itemBuilder: (context, _) => Icon(
                                      Icons.star,
                                      color: JColor.accentColor,
                                    ),
                                    onRatingUpdate: (rating) {
                                      setState(() {
                                        behaviourRating = behaviourRating;
                                      });
                                    },
                                  )
                                ],
                              ))
                        ]),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  pickFileSheet() async {
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
                    final ImagePicker picker = ImagePicker();
                    final XFile? image =
                        await picker.pickImage(source: ImageSource.camera);
                    if (image != null) {
                      var createPostProvider =
                          context.read<CreatePostProvider>();
                      createPostProvider.fileList.add(JFile(
                          uid: generateRandomId(), file: File(image.path)));
                      createPostProvider.fileList = createPostProvider.fileList;
                    }
                  },
                  title: Text("Camera"),
                ),
                ListTile(
                  onTap: () async {
                    Navigator.of(context).pop();
                    var images = await pickMultiImages();
                    if (images != null) {
                      var createPostProvider =
                          context.read<CreatePostProvider>();
                      createPostProvider.fileList.addAll(images.map((e) =>
                          JFile(uid: generateRandomId(), file: File(e.path))));
                      createPostProvider.fileList = createPostProvider.fileList;
                    }
                  },
                  title: Text("Gallery"),
                ),
                ListTile(
                  onTap: () async {
                    Navigator.of(context).pop();
                    final ImagePicker picker = ImagePicker();
                    final XFile? video =
                        await picker.pickVideo(source: ImageSource.gallery);
                    if (video != null) {
                      var createPostProvider =
                          context.read<CreatePostProvider>();
                      createPostProvider.fileList.add(JFile(
                          uid: generateRandomId(),
                          file: File(video.path),
                          fileType: JFileType.VIDEO));
                      createPostProvider.fileList = createPostProvider.fileList;
                    }
                  },
                  title: Text("Video"),
                ),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          );
        });
  }
}
