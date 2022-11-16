import 'package:drawing_app/app/modules/home/views/custom_painter.dart';
import 'package:drawing_app/constants/sizeConstant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';

import '../controllers/home_controller.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    MySize().init(context);
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (controller) {
        return Obx(() {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Draw Your Thoughts'),
              actions: [
                IconButton(
                  onPressed: () {
                    controller.screenshotController
                        .capture(
                            delay: Duration(
                      milliseconds: 10,
                    ))
                        .then((value) {
                      ShowCapturedWidget(context, value!, controller);
                    });
                  },
                  icon: Icon(Icons.camera),
                ),
              ],
              centerTitle: true,
            ),
            body: Screenshot(
              controller: controller.screenshotController,
              child: drwaArea(context, controller),
            ),
            bottomNavigationBar: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: MySize.getHeight(8.0),
                  horizontal: MySize.getHeight(8.0)),
              child: Container(
                // height: MySize.getHeight(50),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.lightBlueAccent,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                              onPressed: () {
                                if (controller.selectedMode ==
                                    SelectedMode.StrokeWidth)
                                  controller.showBottomList.value =
                                      !controller.showBottomList.value;
                                controller.selectedMode =
                                    SelectedMode.StrokeWidth;
                              },
                              icon: Icon(Icons.radio_button_checked_sharp)),
                          IconButton(
                              onPressed: () {
                                if (controller.selectedMode ==
                                    SelectedMode.Opacity)
                                  controller.showBottomList.value =
                                      !controller.showBottomList.value;
                                controller.selectedMode = SelectedMode.Opacity;
                              },
                              icon: Icon(Icons.opacity)),
                          IconButton(
                              onPressed: () {
                                if (controller.selectedMode ==
                                    SelectedMode.Color)
                                  controller.showBottomList.value =
                                      !controller.showBottomList.value;
                                controller.selectedMode = SelectedMode.Color;
                              },
                              icon: Icon(Icons.palette)),
                          IconButton(onPressed: () {}, icon: Icon(Icons.clear)),
                        ],
                      ),
                      Visibility(
                        child: (controller.selectedMode == SelectedMode.Color)
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: controller.getColorList(context),
                              )
                            : Slider(
                                activeColor: Colors.indigo,
                                value: (controller.selectedMode ==
                                        SelectedMode.StrokeWidth)
                                    ? controller.strokeWidth.value
                                    : controller.opacity.value,
                                max: (controller.selectedMode ==
                                        SelectedMode.StrokeWidth)
                                    ? 50.0
                                    : 1.0,
                                min: 0.0,
                                onChanged: (val) {
                                  if (controller.selectedMode ==
                                      SelectedMode.StrokeWidth)
                                    controller.strokeWidth.value = val;
                                  else
                                    controller.opacity.value = val;
                                }),
                        visible: controller.showBottomList.value,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Future<dynamic> ShowCapturedWidget(BuildContext context,
      Uint8List capturedImage, HomeController controller) {
    return showDialog(
      useSafeArea: false,
      context: context,
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: Text("Screenshot of your Drawing"),
          actions: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: MySize.getHeight(10)),
              child: GestureDetector(
                onTap: () async {
                  final image = await controller.screenshotController
                      .captureFromWidget(Container(
                          color: Colors.white,
                          child: drwaArea(context, controller)));
                  if (capturedImage.isNotEmpty) {
                    await [Permission.storage].request();
                    final time = DateTime.now();
                    final name = "Screenshot${time}";
                    final result =
                        await ImageGallerySaver.saveImage(image, name: name);
                    print("Path===============${result['filePath']}");
                  }
                },
                child: Icon(Icons.download),
              ),
            ),
          ],
        ),
        body: Center(
            child: capturedImage != null
                ? Image.memory(capturedImage)
                : Container()),
      ),
    );
  }

  Widget drwaArea(BuildContext context, HomeController controller) {
    return GestureDetector(
      onPanUpdate: (details) {
        RenderBox? renderBox = context.findRenderObject() as RenderBox?;
        controller.points.add(DrawingPoints(
            a: 1,
            points: renderBox!.globalToLocal(details.globalPosition),
            paint: Paint()
              ..strokeCap = controller.strokeCap
              ..isAntiAlias = true
              ..color =
                  controller.selectedColor.withOpacity(controller.opacity.value)
              ..strokeWidth = controller.strokeWidth.value));
        setState(() {});
      },
      onPanStart: (details) {
        RenderBox? renderBox = context.findRenderObject() as RenderBox?;
        controller.points.add(DrawingPoints(
            a: 1,
            points: renderBox!.globalToLocal(details.globalPosition),
            paint: Paint()
              ..strokeCap = controller.strokeCap
              ..isAntiAlias = true
              ..color =
                  controller.selectedColor.withOpacity(controller.opacity.value)
              ..strokeWidth = controller.strokeWidth.value));
        setState(() {});
      },
      onPanEnd: (details) {
        setState(() {
          controller.points.add(
            DrawingPoints(
              a: 0,
            ),
          );
        });
      },
      child: CustomPaint(
        size: Size.infinite,
        painter: MyCustomPainter(pointsList: controller.points),
      ),
    );
  }
}
