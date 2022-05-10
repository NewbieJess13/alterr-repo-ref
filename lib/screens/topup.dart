import 'package:alterr/controllers/auth.dart';
import 'package:alterr/utils/platform_alert_dialog.dart';
import 'package:alterr/utils/platform_spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'package:alterr/services/api.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:io';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/services.dart';

class TopupScreen extends StatefulWidget {
  @override
  TopupScreenState createState() => TopupScreenState();
}

class TopupScreenState extends State<TopupScreen> {
  final TopupController controller = Get.put(TopupController());
  late StreamSubscription<dynamic> _subscription;

  @override
  void initState() {
    super.initState();
    initStore();
    controller.getBarias();
    controller.processing.value = false;
    controller.productsLoading.value = true;
    controller.loading.value = false;
  }

  void initStore() async {
    if (await InAppPurchase.instance.isAvailable() == true) {
      final Stream purchaseUpdated = InAppPurchase.instance.purchaseStream;
      _subscription = purchaseUpdated.listen((purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      }, onDone: () {
        _subscription.cancel();
      }, onError: (error) {
        // handle error here.
      });
      controller.loadProducts();
    } else {
      PlatformAlertDialog(
        title: 'Store unavailable',
        content: 'Store is currently unavailable. Please try again later.',
        actions: [
          PlatformAlertDialogAction(
            child: Text('OK'),
            isDefaultAction: true,
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          )
        ],
      ).show();
    }
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.error) {
        controller.loading.value = false;
        String reason = purchaseDetails.error?.details['NSUnderlyingError']
                ['userInfo']['NSUnderlyingError']['userInfo']
            ['NSLocalizedFailureReason'];
        if (reason != 'Payment sheet cancelled') {
          PlatformAlertDialog(
            title: 'Purchase failed',
            content: '${purchaseDetails.error?.message}',
            actions: [
              PlatformAlertDialogAction(
                child: Text('OK'),
                isDefaultAction: true,
                onPressed: () {
                  navigator?.pop();
                },
              )
            ],
          ).show();
        }
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        controller.validateReceipt(
            purchaseDetails.verificationData.localVerificationData);
      }
      if (purchaseDetails.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchaseDetails);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Material(
          child: Stack(
            children: [
              Scaffold(
                appBar: AppBar(
                  backgroundColor: Theme.of(context).primaryColor,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  toolbarHeight: 60,
                  title: Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        FeatherIcons.x,
                        size: 24,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipPath(
                      clipper: CurveClipper(),
                      child: Container(
                        color: Theme.of(context).primaryColor,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.yellow,
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 5),
                              child: Text('TOP UP',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.only(top: 10, left: 30, right: 30),
                              child: Text('Buy more barias',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom: 15, top: 5, left: 60, right: 60),
                              child:
                                  Text('Use barias to unlock premium content.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.75),
                                        fontSize: 17,
                                      )),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom: 50, top: 5, left: 60, right: 60),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Opacity(
                                      opacity:
                                          controller.bariasLoading.value == true
                                              ? 0
                                              : 1,
                                      child: Text(
                                          '${controller.barias.value.toString()} barias left',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            height: 1.35,
                                            fontSize: 20,
                                          )),
                                    ),
                                  ),
                                  Center(
                                    child: Container(
                                      height: 30,
                                      child: controller.bariasLoading.value ==
                                              true
                                          ? Shimmer.fromColors(
                                              period:
                                                  Duration(milliseconds: 800),
                                              baseColor: Colors.grey[400]!,
                                              highlightColor: Colors.grey[100]!,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withOpacity(0.4),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            3)),
                                                width: 180,
                                              ))
                                          : SizedBox.shrink(),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              Expanded(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height: 15,
                                  ),
                                  ListView.builder(
                                      itemCount: controller.products.length,
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        Color color = Colors.orangeAccent[200]!;
                                        if (index == 1) {
                                          color = Colors.blueAccent[200]!;
                                        } else if (index == 2) {
                                          color = Colors.greenAccent[400]!;
                                        }
                                        return Padding(
                                          padding: EdgeInsets.only(top: 15),
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 15),
                                            child: Ink(
                                              decoration: BoxDecoration(
                                                color: color,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: InkWell(
                                                customBorder:
                                                    RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                onTap: () => controller.topUp(
                                                    controller.products[index]),
                                                child: Container(
                                                  padding: EdgeInsets.all(15),
                                                  child: Row(
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            controller
                                                                .products[index]
                                                                .title
                                                                .replaceAll(
                                                                    '(Alterr)',
                                                                    ''),
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    top: 5),
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            50)),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical: 5,
                                                                    horizontal:
                                                                        10),
                                                            child: Text(
                                                              controller
                                                                  .products[
                                                                      index]
                                                                  .description,
                                                              style: TextStyle(
                                                                  fontSize: 14,
                                                                  height: 1.05,
                                                                  color: color),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      Spacer(),
                                                      Text(
                                                        '${controller.products[index].currencyCode} ${controller.products[index].rawPrice}0',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 18),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                ],
                              ))
                            ],
                          ),
                          controller.productsLoading.value == true
                              ? Positioned.fill(
                                  child: Container(
                                    color: Colors.white,
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          PlatformSpinner(
                                            width: 20,
                                            height: 20,
                                          ),
                                          controller.processing.value == true
                                              ? Container(
                                                  margin:
                                                      EdgeInsets.only(top: 15),
                                                  child: Text(
                                                    'Processing',
                                                    style:
                                                        TextStyle(fontSize: 18),
                                                  ),
                                                )
                                              : SizedBox.shrink()
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : SizedBox.shrink()
                        ],
                      ),
                    )
                  ],
                ),
              ),
              controller.loading.value == true
                  ? Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.35),
                        child: Center(
                          child: PlatformSpinner(
                            radius: 15,
                            width: 30,
                            height: 30,
                            strokeWidth: 3,
                            color: Colors.white,
                            brightness: Brightness.dark,
                          ),
                        ),
                      ),
                    )
                  : SizedBox.shrink()
            ],
          ),
        ));
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    int curveHeight = 25;
    Offset controlPoint = Offset(size.width / 2, size.height + curveHeight);
    Offset endPoint = Offset(size.width, size.height - curveHeight);

    Path path = Path()
      ..lineTo(0, size.height - curveHeight)
      ..quadraticBezierTo(
          controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy)
      ..lineTo(size.width, 0)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class TopupController extends GetxController {
  RxBool loading = false.obs;
  RxBool processing = false.obs;
  RxBool bariasLoading = false.obs;
  RxList products = [].obs;
  RxInt barias = 0.obs;
  String qonversionUserID = '';
  final AuthController authController = Get.put(AuthController());
  RxBool productsLoading = true.obs;

  Future<void> validateReceipt(String receipt) async {
    String? platform = Platform.isIOS
        ? 'ios'
        : Platform.isAndroid
            ? 'android'
            : null;
    if (platform != null) {
      Map<String, dynamic>? response = await ApiService().request(
          'topup/validate-receipt',
          {'platform': platform, 'receipt': receipt},
          'POST',
          withToken: true);
      if (response != null) {
        loading.value = false;
        getBarias();
      } else {
        loading.value = false;
      }
    }
  }

  Future<void> getBarias() async {
    bariasLoading.value = true;
    Map<String, dynamic> response =
        await ApiService().request('auth/barias', {}, 'GET', withToken: true);
    barias.value = response['barias'];
    bariasLoading.value = false;
  }

  Future<void> loadProducts() async {
    productsLoading.value = true;

    const Set<String> _kIds = <String>{
      'com.alterr.app.500.v1',
      'com.alterr.app.1500.v1',
      'com.alterr.app.3000.v1'
    };
    final ProductDetailsResponse response =
        await InAppPurchase.instance.queryProductDetails(_kIds);
    if (response.notFoundIDs.isNotEmpty) {
      return PlatformAlertDialog(
        title: 'Products not available',
        content: 'Some products are not available. Please try again later.',
        actions: [
          PlatformAlertDialogAction(
            child: Text('OK'),
            isDefaultAction: true,
            onPressed: () {
              navigator?.pop();
            },
          )
        ],
      ).show();
    }
    response.productDetails.sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
    products.value = response.productDetails;
    productsLoading.value = false;
  }

  Future<void> topUp(ProductDetails productDetails) async {
    loading.value = true;
    final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
        applicationUserName: authController.user?.id.toString());
    InAppPurchase.instance
        .buyConsumable(purchaseParam: purchaseParam)
        .onError((error, stackTrace) {
      return PlatformAlertDialog(
        title: 'Purchase failed',
        content: error.toString(),
        actions: [
          PlatformAlertDialogAction(
            child: Text('OK'),
            isDefaultAction: true,
            onPressed: () {
              loading.value = false;
              navigator?.pop();
            },
          )
        ],
      ).show();
    });
  }

  Future<void> success() async {
    await getBarias();
    loading.value = false;
  }
}
