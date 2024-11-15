import 'package:flutter/material.dart';
import 'package:xaxino/core/utils/my_color.dart';
import 'package:xaxino/view/components/text-form-field/custom_text_field.dart';
import 'package:xaxino/view/components/text/label_text_with_instructions.dart';
import 'package:xaxino/view/screens/kyc/widget/already_verifed.dart';
import 'package:xaxino/view/screens/kyc/widget/widget/file_item.dart';
import 'package:get/get.dart';
import 'package:xaxino/core/utils/dimensions.dart';
import 'package:xaxino/core/utils/my_strings.dart';
import 'package:xaxino/data/controller/kyc_controller/kyc_controller.dart';
import 'package:xaxino/data/model/kyc/kyc_response_model.dart' as kyc;
import 'package:xaxino/data/repo/kyc/kyc_repo.dart';
import 'package:xaxino/data/services/api_service.dart';
import 'package:xaxino/view/components/app-bar/custom_appbar.dart';
import 'package:xaxino/view/components/buttons/rounded_button.dart';
import 'package:xaxino/view/components/buttons/rounded_loading_button.dart';
import 'package:xaxino/view/components/checkbox/custom_check_box.dart';
import 'package:xaxino/view/components/custom_drop_down_button_with_text_field.dart';
import 'package:xaxino/view/components/custom_loader/custom_loader.dart';
import 'package:xaxino/view/components/custom_no_data_found_class.dart';
import 'package:xaxino/view/components/custom_radio_button.dart';

class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(KycRepo(apiClient: Get.find()));
    Get.put(KycController(repo: Get.find()));
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<KycController>().beforeInitLoadKycData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<KycController>(
      builder: (controller) => GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: MyColor.gradientBackground,
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: const CustomAppBar(
              title: MyStrings.kycVerification,
            ),
            body: SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: controller.isLoading
                    ? const Padding(padding: EdgeInsets.all(Dimensions.space15), child: CustomLoader())
                    : controller.isAlreadyVerified
                        ? const AlreadyVerifiedWidget()
                        : controller.isAlreadyPending
                            ? const AlreadyVerifiedWidget(
                                isPending: true,
                              )
                            : controller.isNoDataFound
                                ? const NoDataOrInternetScreen()
                                : Center(
                                    child: SingleChildScrollView(
                                      padding: const EdgeInsets.all(Dimensions.space10),
                                      child: Container(
                                        padding: const EdgeInsets.all(Dimensions.space15),
                                        child: Form(
                                          key: formKey,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              ListView.builder(
                                                  shrinkWrap: true,
                                                  physics: const NeverScrollableScrollPhysics(),
                                                  scrollDirection: Axis.vertical,
                                                  itemCount: controller.formList.length,
                                                  itemBuilder: (ctx, index) {
                                                    kyc.KycFormModel? model = controller.formList[index];
                                                    return Padding(
                                                      padding: const EdgeInsets.all(3),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          model.type == 'text' || model.type == 'number' || model.type == 'email' || model.type == 'url'
                                                              ? Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    CustomTextField(
                                                                        disableBorderColor: MyColor.colorWhite,
                                                                        borderColor: MyColor.colorWhite,
                                                                        instructions: model.instruction,
                                                                        isRequired: model.isRequired == 'optional' ? false : true,
                                                                        hintText: ("${MyStrings.enter} ${model.name ?? ''}").toString().capitalizeFirst,
                                                                        needOutlineBorder: true,
                                                                        labelText: model.name ?? '',
                                                                        textInputType: model.type == 'number'
                                                                            ? TextInputType.number
                                                                            : model.type == 'email'
                                                                                ? TextInputType.emailAddress
                                                                                : model.type == 'url'
                                                                                    ? TextInputType.url
                                                                                    : TextInputType.text,
                                                                        validator: (value) {
                                                                          if (model.isRequired != 'optional' && value.toString().isEmpty) {
                                                                            return '${model.name.toString().capitalizeFirst} ${MyStrings.isRequired}';
                                                                          } else {
                                                                            return null;
                                                                          }
                                                                        },
                                                                        onChanged: (value) {
                                                                          controller.changeSelectedValue(value, index);
                                                                        }),
                                                                    const SizedBox(height: Dimensions.space10),
                                                                  ],
                                                                )
                                                              : model.type == 'textarea'
                                                                  ? Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        CustomTextField(
                                                                            borderColor: MyColor.colorWhite,
                                                                            instructions: model.instruction,
                                                                            isRequired: model.isRequired == 'optional' ? false : true,
                                                                            needOutlineBorder: true,
                                                                            maxLines: 5,
                                                                            disableBorderColor: MyColor.colorWhite,
                                                                            labelText: model.name ?? '',
                                                                            hintText: ("${MyStrings.enter} ${model.name ?? ''}").toString().capitalizeFirst,
                                                                            inputAction: TextInputAction.newline,
                                                                            textInputType: TextInputType.multiline,
                                                                            validator: (value) {
                                                                              if (model.isRequired != 'optional' && value.toString().isEmpty) {
                                                                                return '${model.name.toString().capitalizeFirst} ${MyStrings.isRequired}';
                                                                              } else {
                                                                                return null;
                                                                              }
                                                                            },
                                                                            onChanged: (value) {
                                                                              controller.changeSelectedValue(value, index);
                                                                            }),
                                                                        const SizedBox(height: Dimensions.space10),
                                                                      ],
                                                                    )
                                                                  : model.type == 'select'
                                                                      ? Column(
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            LabelTextInstruction(
                                                                              text: model.name ?? '',
                                                                              isRequired: model.isRequired == 'optional' ? false : true,
                                                                              instructions: model.instruction,
                                                                            ),
                                                                            const SizedBox(
                                                                              height: Dimensions.textToTextSpace,
                                                                            ),
                                                                            CustomDropDownWithTextField(
                                                                                list: model.options ?? [],
                                                                                onChanged: (value) {
                                                                                  controller.changeSelectedValue(value, index);
                                                                                },
                                                                                selectedValue: model.selectedValue),
                                                                            const SizedBox(height: Dimensions.space10)
                                                                          ],
                                                                        )
                                                                      : model.type == 'radio'
                                                                          ? Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                LabelTextInstruction(
                                                                                  text: model.name ?? '',
                                                                                  isRequired: model.isRequired == 'optional' ? false : true,
                                                                                  instructions: model.instruction,
                                                                                ),
                                                                                CustomRadioButton(
                                                                                  title: model.name,
                                                                                  selectedIndex: controller.formList[index].options?.indexOf(model.selectedValue ?? '') ?? 0,
                                                                                  list: model.options ?? [],
                                                                                  onChanged: (selectedIndex) {
                                                                                    controller.changeSelectedRadioBtnValue(index, selectedIndex);
                                                                                  },
                                                                                ),
                                                                              ],
                                                                            )
                                                                          : model.type == 'checkbox'
                                                                              ? Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    LabelTextInstruction(
                                                                                      text: model.name ?? '',
                                                                                      isRequired: model.isRequired == 'optional' ? false : true,
                                                                                      instructions: model.instruction,
                                                                                    ),
                                                                                    CustomCheckBox(
                                                                                      selectedValue: controller.formList[index].cbSelected,
                                                                                      list: model.options ?? [],
                                                                                      onChanged: (value) {
                                                                                        controller.changeSelectedCheckBoxValue(index, value);
                                                                                      },
                                                                                    ),
                                                                                  ],
                                                                                )
                                                                              : model.type == 'file'
                                                                                  ? Column(
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      children: [
                                                                                        LabelTextInstruction(
                                                                                          text: model.name ?? '',
                                                                                          isRequired: model.isRequired == 'optional' ? false : true,
                                                                                          instructions: model.instruction,
                                                                                        ),
                                                                                        Padding(
                                                                                          padding: const EdgeInsets.symmetric(vertical: Dimensions.textToTextSpace),
                                                                                          child: ConfirmKycFileItem(index: index),
                                                                                        ),
                                                                                      ],
                                                                                    )
                                                                                  : model.type == 'datetime'
                                                                                      ? Column(
                                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                                          children: [
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.symmetric(vertical: Dimensions.textToTextSpace),
                                                                                              child: CustomTextField(
                                                                                                  instructions: model.instruction,
                                                                                                  isRequired: model.isRequired == 'optional' ? false : true,
                                                                                                  hintText: ("${MyStrings.enter} ${model.name ?? ''}").toString().capitalizeFirst,
                                                                                                  needOutlineBorder: true,
                                                                                                  labelText: model.name ?? '',
                                                                                                  controller: controller.formList[index].textEditingController,
                                                                                                  // initialValue: controller.formList[index].selectedValue == "" ? (model.name ?? '').toString().capitalizeFirst : controller.formList[index].selectedValue,
                                                                                                  textInputType: TextInputType.datetime,
                                                                                                  readOnly: true,
                                                                                                  validator: (value) {
                                                                                                    print(model.isRequired);
                                                                                                    if (model.isRequired != 'optional' && value.toString().isEmpty) {
                                                                                                      return '${model.name.toString().capitalizeFirst} ${MyStrings.isRequired}';
                                                                                                    } else {
                                                                                                      return null;
                                                                                                    }
                                                                                                  },
                                                                                                  onTap: () {
                                                                                                    controller.changeSelectedDateTimeValue(index, context);
                                                                                                  },
                                                                                                  onChanged: (value) {
                                                                                                    print(value);
                                                                                                    controller.changeSelectedValue(value, index);
                                                                                                  }),
                                                                                            ),
                                                                                          ],
                                                                                        )
                                                                                      : model.type == 'date'
                                                                                          ? Column(
                                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                                              children: [
                                                                                                Padding(
                                                                                                  padding: const EdgeInsets.symmetric(vertical: Dimensions.textToTextSpace),
                                                                                                  child: CustomTextField(
                                                                                                      instructions: model.instruction,
                                                                                                      isRequired: model.isRequired == 'optional' ? false : true,
                                                                                                      hintText: ("${MyStrings.enter} ${model.name ?? ''}").toString().capitalizeFirst,
                                                                                                      needOutlineBorder: true,
                                                                                                      labelText: model.name ?? '',
                                                                                                      controller: controller.formList[index].textEditingController,
                                                                                                      // initialValue: controller.formList[index].selectedValue == "" ? (model.name ?? '').toString().capitalizeFirst : controller.formList[index].selectedValue,
                                                                                                      textInputType: TextInputType.datetime,
                                                                                                      readOnly: true,
                                                                                                      validator: (value) {
                                                                                                        print(model.isRequired);
                                                                                                        if (model.isRequired != 'optional' && value.toString().isEmpty) {
                                                                                                          return '${model.name.toString().capitalizeFirst} ${MyStrings.isRequired}';
                                                                                                        } else {
                                                                                                          return null;
                                                                                                        }
                                                                                                      },
                                                                                                      onTap: () {
                                                                                                        controller.changeSelectedDateOnlyValue(index, context);
                                                                                                      },
                                                                                                      onChanged: (value) {
                                                                                                        print(value);
                                                                                                        controller.changeSelectedValue(value, index);
                                                                                                      }),
                                                                                                ),
                                                                                              ],
                                                                                            )
                                                                                          : model.type == 'time'
                                                                                              ? Column(
                                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                  children: [
                                                                                                    Padding(
                                                                                                      padding: const EdgeInsets.symmetric(vertical: Dimensions.textToTextSpace),
                                                                                                      child: CustomTextField(
                                                                                                          instructions: model.instruction,
                                                                                                          isRequired: model.isRequired == 'optional' ? false : true,
                                                                                                          hintText: ("${MyStrings.enter} ${model.name ?? ''}").toString().capitalizeFirst,
                                                                                                          needOutlineBorder: true,
                                                                                                          labelText: model.name ?? '',
                                                                                                          controller: controller.formList[index].textEditingController,
                                                                                                          // initialValue: controller.formList[index].selectedValue == "" ? (model.name ?? '').toString().capitalizeFirst : controller.formList[index].selectedValue,
                                                                                                          textInputType: TextInputType.datetime,
                                                                                                          readOnly: true,
                                                                                                          validator: (value) {
                                                                                                            print(model.isRequired);
                                                                                                            if (model.isRequired != 'optional' && value.toString().isEmpty) {
                                                                                                              return '${model.name.toString().capitalizeFirst} ${MyStrings.isRequired}';
                                                                                                            } else {
                                                                                                              return null;
                                                                                                            }
                                                                                                          },
                                                                                                          onTap: () {
                                                                                                            controller.changeSelectedTimeOnlyValue(index, context);
                                                                                                          },
                                                                                                          onChanged: (value) {
                                                                                                            print(value);
                                                                                                            controller.changeSelectedValue(value, index);
                                                                                                          }),
                                                                                                    ),
                                                                                                  ],
                                                                                                )
                                                                                              : const SizedBox(),
                                                        ],
                                                      ),
                                                    );
                                                  }),
                                              const SizedBox(height: Dimensions.space25),
                                              Center(
                                                child: controller.submitLoading
                                                    ? const RoundedLoadingBtn()
                                                    : RoundedButton(
                                                        hasCornerRadious: true,
                                                        isColorChange: true,
                                                        textColor: MyColor.colorBlack,
                                                        verticalPadding: Dimensions.space15,
                                                        cornerRadius: Dimensions.space8,
                                                        color: MyColor.primaryButtonColor,
                                                        text: MyStrings.submit,
                                                        press: () {
                                                          if (formKey.currentState!.validate()) {
                                                            controller.submitKycData();
                                                          } else {}
                                                        },
                                                      ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )),
          ),
        ),
      ),
    );
  }
}
