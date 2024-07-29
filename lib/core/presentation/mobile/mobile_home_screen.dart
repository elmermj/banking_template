import 'package:banking_template/core/presentation/mobile/mobile_home_controller.dart';
import 'package:banking_template/main.dart';
import 'package:banking_template/widgets/bank_card_widget.dart';
import 'package:banking_template/widgets/custom_pie_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MobileHomeScreen extends GetView<MobileHomeAnimationController> {
  MobileHomeScreen({super.key});

  @override
  final controller = Get.put(MobileHomeAnimationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          ListView(
            shrinkWrap: true,
            children: [
              Container(
                padding: const EdgeInsets.only(top: kBottomNavigationBarHeight),
                width: Get.width,
                height: Get.height * 0.7,
                child: PageView.builder(
                  itemCount: controller.rotationY.length,
                  controller: controller.pageController,
                  onPageChanged: (index) {
                    controller.selectCard(index);
                  },
                  pageSnapping: false,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder:(context, index) {
                    return Align(
                      alignment: const AlignmentDirectional(0, 1),
                      child: Obx(
                        () => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.001)
                                ..rotateY(controller.rotationY[index].value)
                                ..scale(controller.scale[index].value),
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onPanStart: (details) {
                                  controller.startSwipe(details.globalPosition.dx);
                                },
                                onPanUpdate: (details) {
                                  controller.updateSwipe(details.globalPosition.dx, controller.rotationY.length);
                                },
                                onPanEnd: (details) {
                                  controller.resetAnimation(details.globalPosition.dx - controller.initialPosition.value);
                                },
                                child: BankCardWidget(
                                  isLast: index == controller.rotationY.length -1,
                                  cardNum: controller.cardList[index]['cardNum'],
                                  cardProvider: controller.cardList[index]['cardProvider'],
                                  cardExpDate: controller.cardList[index]['cardExpDate'],
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(36.0),
                              child: InkWell(
                                onTap: ()=>controller.initLoading(),
                                child: Center(
                                  child: index != controller.rotationY.length -1?Text("Balance IDR ${NumberFormat("#,##0.00").format(controller.balance.value)}"):const SizedBox()
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Card(
                margin: const EdgeInsets.only(left: 12.0, top: 12.0, right: 12.0, bottom: kBottomNavigationBarHeight + 20),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                shadowColor: Colors.grey[200],
                elevation: 10,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  child: AnimatedContainer(
                    width: Get.width,
                    decoration: BoxDecoration(
                      color: Colors.grey[50]
                    ),
                    padding: const EdgeInsets.only(bottom: kBottomNavigationBarHeight),
                    duration: const Duration(milliseconds: 200),
                    child: Obx(
                      () {
                        double balance = controller.touchedIndex.value==null? 0:double.parse(controller.dummyDataService.cards[controller.touchedIndex.value!]['cardBalance']!);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 24, bottom: 8),
                              child: Text(
                                "Balance Chart",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ),
                            TapRegion(
                              onTapOutside: (_) async => await controller.updateTouchedIndex(null),
                              child: Container(
                                margin: const EdgeInsets.all(16),
                                height: Get.width * 0.5,
                                width: Get.width * 0.5,
                                child: CustomPieChart(
                                  data: controller.dummyDataService.cards.map((e) => double.parse(e['cardBalance']!)).toList(),
                                  touchedIndex: controller.touchedIndex.value,
                                  onSegmentTapped: controller.updateTouchedIndex,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              )
            ],
          ),
          Align(
            alignment: AlignmentDirectional(0, ((Get.height-12)/Get.height) * -1),
            child: buildMainCard(),
          ),
          Align(
            alignment: const AlignmentDirectional(0, 1),
            child: buildBottomMenu()
          ),
        ],
      ),
    );
  }

  Obx buildBottomMenu() {
    return Obx(
      () {
        double textSize = controller.isMenuExpanded.value ? Get.textTheme.bodySmall!.fontSize! : 0;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: controller.isLoading.value? Colors.transparent :Colors.black,
            borderRadius: BorderRadius.circular(20),
          ),
          margin: const EdgeInsets.only(bottom: 20),
          width: controller.isLoading.value? 40: controller.isMenuExpanded.value ? Get.width * 0.9 : Get.width / 4,
          height: 40,
          child: controller.isLoading.value
        ? FadeTransition(
            opacity: controller.menuOpacityAnimation, 
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.black, 
                backgroundColor: Colors.transparent,
                strokeCap: StrokeCap.round,
                strokeWidth: 4,
              )
            )
          )
        : controller.isMenuExpanded.value
        ? TapRegion(
            onTapOutside: (event) => controller.closeMenu(),
            child: FadeTransition(
              opacity: controller.menuOpacityAnimation,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: textSize),
                duration: const Duration(milliseconds: 200),
                builder: (context, size, child) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {},
                          child: Center(
                            child: Text(
                              'History',
                              style: TextStyle(color: Colors.white, fontSize: size),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {},
                          child: Center(
                            child: Text(
                              'Settings',
                              style: TextStyle(color: Colors.white, fontSize: size),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {},
                          child: Center(
                            child: Text(
                              'About',
                              style: TextStyle(color: Colors.white, fontSize: size),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {},
                          child: Center(
                            child: Text(
                              'Exit',
                              style: TextStyle(color: Colors.white, fontSize: size),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          )
        : InkWell(
            onTap: () => controller.expandMenu(), //expand menu
            child: const Center(
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }

  GestureDetector buildMainCard() {
    return GestureDetector(
      onTap: () {
        logYellow("TAPPED");
        controller.expandShrinkMainCard();
      },
      child: Obx(
        () => AnimatedContainer(
          margin: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(24),
          ),
          width: Get.width,
          height: controller.isMainCardExpanded.value ? 152 : 72,
          duration: Duration(milliseconds: controller.isMainCardExpanded.value ? 200:300),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: controller.isMainCardExpanded.value ? 1.0 : 0.0),
            duration: const Duration(milliseconds: 200),
            builder: (context, value, child) {
              return Stack(
                children: [
                  Align(
                    alignment: const AlignmentDirectional(0, 0),
                    child: Opacity(
                      opacity: 1.0 - value,
                      child: Text(
                        "Hello, User",
                        style: Get.textTheme.bodySmall!.copyWith(color: Colors.white, fontSize: 24),
                      ),
                    ),
                  ),
                  ClipRect(
                    child: Align(
                      alignment: const AlignmentDirectional(0, 0),
                      child: FadeTransition(
                        opacity: controller.mainCardOpacityAnimation,
                        child: Container(
                          width: Get.width,
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Your total balance",
                                style: Get.textTheme.bodySmall!.copyWith(color: Colors.white, fontSize: 16),
                              ),                                  
                              Text(
                                "IDR 2.546.129.966.49",
                                style: Get.textTheme.bodySmall!.copyWith(color: Colors.white, fontSize: 24),
                              ),
                              Container(
                                padding: const EdgeInsets.only(top: 8),
                                height: 48,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: (){},
                                        child: const Icon(Icons.download, color: Colors.white),
                                      ),
                                    ),
                                    Expanded(
                                      child: InkWell(
                                        onTap: (){},
                                        child: const Icon(Icons.upload, color: Colors.white),
                                      ),
                                    ),
                                    Expanded(
                                      child: InkWell(
                                        onTap: (){},
                                        child: const Icon(Icons.qr_code, color: Colors.white),
                                      ),
                                    ),
                                    Expanded(
                                      child: InkWell(
                                        onTap: (){},
                                        child: const Icon(Icons.update, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

