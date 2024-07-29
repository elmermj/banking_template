import 'package:banking_template/dummy_data.dart';
import 'package:banking_template/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MobileHomeAnimationController extends GetxController with GetTickerProviderStateMixin {
  
  DummyDataService dummyDataService = Get.find<DummyDataService>();

  List<RxDouble> rotationY = [];

  List<RxDouble> scale = [];

  List<Map<String,dynamic>> cardList = [];

  RxBool isMenuExpanded = false.obs;
  RxBool isMainCardExpanded = false.obs;
  RxBool isLoading = false.obs;

  RxDouble initialPosition = 0.0.obs;
  RxDouble delta = 0.0.obs;
  RxInt selectedIndex = 0.obs;
  Rxn<int> touchedIndex = Rxn<int>();

  late AnimationController animationController;
  late AnimationController menuAnimationController;
  late AnimationController cardAnimationController;
  late AnimationController chartValueAnimationController;
  late Animation<double> rotationAnimation;
  late Animation<double> scaleAnimation;
  late Animation<double> mainCardOpacityAnimation;
  late Animation<double> menuOpacityAnimation;
  late Animation<double> chartValueOpacityAnimation;

  PageController pageController = PageController(viewportFraction: 0.75, keepPage: false);

  RxDouble balance = 0.0.obs;

  @override
  void onInit() {
    initAnimationControllers();
    cardList.addAll(dummyDataService.cards);
    generateCardAnimatedvalue();
    super.onInit();
  }

  generateCardAnimatedvalue(){
    for (int i = 0; i < cardList.length; i++) {
      rotationY.add(0.0.obs);
      i==0?scale.add(1.0.obs):scale.add(0.8.obs);
    }
    logYellow("BEFORE CARD LENGTH ::: ${cardList.length}");
    cardList.add({});
    rotationY.add(0.0.obs);
    scale.add(0.8.obs);
    balance.value = double.parse(cardList[0]['cardBalance']);
    logYellow("AFTER CARD LENGTH ::: ${cardList.length}");
  }

  initAnimationControllers() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 200,
      ),
    );
    menuAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 300,
      ),
    );
    cardAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 100,
      ),
    );
    chartValueAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 100,
      ),
    );
    rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.0,
    ).animate(cardAnimationController);
    scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1,
    ).animate(cardAnimationController);
    mainCardOpacityAnimation = CurvedAnimation(
      parent: menuAnimationController,
      curve: Curves.easeIn,
    );
    menuOpacityAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeIn,
    );
    chartValueOpacityAnimation = CurvedAnimation(
      parent: chartValueAnimationController ,
      curve: Curves.easeIn,
    );
  }

  void startSwipe(double position) {
    initialPosition.value = position;
  }

  void updateSwipe(double currentPosition, int length) {
    delta.value = currentPosition - initialPosition.value;
    rotationY[selectedIndex.value].value = (delta.value / Get.width) *2;
    if(rotationY[selectedIndex.value].value <= -0.5){
      resetAnimation(delta.value);
      selectedIndex.value = (selectedIndex.value ++) % length;
      pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      update();
    }
    if(rotationY[selectedIndex.value].value >= 0.5){
      resetAnimation(delta.value);
      selectedIndex.value = (selectedIndex.value --) % length;
      pageController.previousPage(duration: const Duration(
        milliseconds: 300,
      ), curve: Curves.easeInOut);
      update();
    }
  }

  void resetAnimation(double delta) {
    if(rotationY[selectedIndex.value].value >= 0.5 || rotationY[selectedIndex.value].value <= -0.5){
      rotationAnimation = Tween<double>(
        begin: rotationY[selectedIndex.value].value,
        end: 0.0,
      ).animate(cardAnimationController)
        ..addListener(() {
          rotationY[selectedIndex.value].value = rotationAnimation.value;
          update();
        });

      scaleAnimation = Tween<double>(
        begin: scale[selectedIndex.value].value,
        end: 0.8,
      ).animate(cardAnimationController)
        ..addListener(() {
          scale[selectedIndex.value].value = scaleAnimation.value;
          update();
        });

      cardAnimationController.forward(from: 0);
    } else {
      rotationAnimation = Tween<double>(
        begin: rotationY[selectedIndex.value].value,
        end: 0.0,
      ).animate(cardAnimationController)
        ..addListener(() {
          rotationY[selectedIndex.value].value = rotationAnimation.value;
          update();
        });
      cardAnimationController.forward(from: 0);
    }
  }

  void selectCard(int index) {
    if (index != selectedIndex.value) {
      rotationY[index].value = 0.0;
      scale[index].value = 0.8;
      rotationAnimation = Tween<double>(
        begin: rotationY[selectedIndex.value].value,
        end: 0.0,
      ).animate(cardAnimationController)
        ..addListener(() {
          rotationY[selectedIndex.value].value = rotationAnimation.value;
          update();
        });

      scaleAnimation = Tween<double>(
        begin: scale[selectedIndex.value].value,
        end: 1,
      ).animate(cardAnimationController)
        ..addListener(() {
          scale[selectedIndex.value].value = scaleAnimation.value;
          update();
        });

      cardAnimationController.forward(from: 0.0);
      selectedIndex.value = index;
      balance.value = index == cardList.length-1 ? 0 : double.parse(cardList[index]['cardBalance']);
    }
  }

  void expandMenu() {
    animationController.forward();
    isMenuExpanded.value = true;
  }

  void closeMenu() {
    animationController.reverse();
    isMenuExpanded.value = false;
  }

  void expandShrinkMainCard () {
    if(isMainCardExpanded.value){
      menuAnimationController.reverse();
      isMainCardExpanded.value = false;
    }else{
      menuAnimationController.forward();
      isMainCardExpanded.value = true;
    }
  }

  void initLoading(){
    isLoading.value = true;
    animationController.forward();
    Future.delayed(const Duration(seconds: 3), () {
      animationController.reverse();
      isLoading.value = false;
    });
  }

  Future<void> updateTouchedIndex(int? index) async {
    logYellow("touchedIndex value before ::: ${touchedIndex.value}");
    if(chartValueOpacityAnimation.value == 1){
      await chartValueAnimationController.reverse().then((_) async {
        touchedIndex.value = index;
        logYellow("touchedIndex value after ::: ${touchedIndex.value}");
        await chartValueAnimationController.forward();
      });
    } else {
      touchedIndex.value = index;
      logYellow("touchedIndex value after ::: ${touchedIndex.value}");
      await chartValueAnimationController.forward();
    }
  }

}
