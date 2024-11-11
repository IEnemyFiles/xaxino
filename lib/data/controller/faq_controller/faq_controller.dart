import 'dart:convert';
import 'package:get/get.dart';
import 'package:xaxino/core/utils/my_strings.dart';
import 'package:xaxino/data/model/faq_model/faq_response_model.dart';
import 'package:xaxino/data/model/global/response_model/response_model.dart';
import 'package:xaxino/data/repo/faq_repo/faq_repo.dart';
import 'package:xaxino/view/components/snack_bar/show_custom_snackbar.dart';


class FaqController extends GetxController{

  FaqRepo faqRepo;
  FaqController({required this.faqRepo});

  bool isLoading = true;
  bool isPress = false;
  int selectedIndex = -1;

  List<Faqs> faqList = [];

  void changeSelectedIndex(int index){
    if(selectedIndex == index){
      selectedIndex = -1;
      update();
      return;
    }
    selectedIndex = index;
    update();
  }

 

  void loadData()async{
    ResponseModel model=await faqRepo.loadFaq();
    if(model.statusCode==200){
      FaqResponseModel responseModel = FaqResponseModel.fromJson(jsonDecode(model.responseJson));
      List<Faqs>?tempFaqList = responseModel.data?.faqs;
      if(tempFaqList !=null && tempFaqList.isNotEmpty){
        faqList.addAll(tempFaqList);
      } else{
        CustomSnackBar.error(errorList: responseModel.message?.error??[MyStrings.somethingWentWrong]);
      }
    }else{
      CustomSnackBar.error(errorList: [model.message]);
    }
    isLoading = false;
    update();
  }


}