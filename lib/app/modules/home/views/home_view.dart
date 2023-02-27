import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:moffpass/app/data/models/menu_option.dart';
import 'package:moffpass/app/data/services/log_service.dart';
import 'package:moffpass/app/utils/styles.dart';
import 'package:moffpass/app/widgets/no_data.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'mOffPass',
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<MenuOptionModel>(
            onSelected: controller.handlePopMenuButton,
            itemBuilder: (BuildContext context) {
              return controller.menuOptions.map((MenuOptionModel value) {
                return PopupMenuItem<MenuOptionModel>(
                  value: value,
                  //onTap: value.onTap,
                  child: Row(
                    children: [
                      Icon(
                        value.iconData,
                        color: AppStyles.primaryColor,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(value.value),
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.bottomSheet(BottomSheet(
            onClosing: () {
              LogService.to.logger.i('Bottomsheet cloese');
              controller.resetNoOfRows();
            },
            builder: (context) {
              return SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  child: Obx(() => Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Center(
                            child: Text(
                              'Add new record',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                          ),
                          Row(
                            children: [
                              const Text(
                                'Title',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                  child: TextField(
                                controller: controller.titleValueTextController,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                decoration: const InputDecoration(
                                  hintText: 'Add title for this record',
                                ),
                              )),
                            ],
                          ),
                          // IconButton(
                          //     onPressed: () {
                          //       controller.addNewRow();
                          //     },
                          //     icon: const Icon(Icons.add)),
                          ...List.generate(controller.noOfRows.value, (index) {
                            return DataRow(
                              controller: controller,
                              index: index,
                            );
                          }),
                          OutlinedButton(
                              onPressed: () {
                                controller.addNewRow();
                              },
                              child: const Text('Add new label')),

                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                  onPressed: () {
                                    controller.resetNoOfRows();
                                    Get.back();
                                  },
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 17),
                                  )),
                              const SizedBox(
                                width: 20,
                              ),
                              TextButton(
                                  onPressed: () {
                                    controller.saveRecord(
                                        controller.getCategoryFromIndex(
                                            controller.tabController.index));
                                  },
                                  child: const Text(
                                    'Save',
                                    style: TextStyle(
                                        color: Colors.green, fontSize: 17),
                                  )),
                            ],
                          ),
                        ],
                      )),
                ),
              );
            },
          ));
        },
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Obx(
            () {
              return Column(
                children: [
                  TabBar(
                      controller: controller.tabController,
                      isScrollable: true,
                      labelColor: AppStyles.blackColor,
                      physics: const BouncingScrollPhysics(),
                      labelStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      tabs: controller.categoriesData.entries
                          .map((e) => FittedBox(
                                child: Tab(child: Text(e.key)),
                              ))
                          .toList()),
                  const SizedBox(
                    height: 10,
                  ),
                  Flexible(
                    fit: FlexFit.loose,
                    child: Obx(() => TabBarView(
                        controller: controller.tabController,
                        children: controller.categoriesData.entries.map((e) {
                          var val = e.value as List;
                          //LogService.to.logger.d(val);
                          return val.isEmpty
                              ? const NoDataWidget()
                              : ListView(
                                  children: val.map((e) {
                                    //LogService.to.logger.d(e);
                                    var map = {};
                                    e.forEach((key, value) {
                                      if (key == "id") return;
                                      map[key] = value;
                                    });
                                    int id = e["id"];
                                    return RecordCard(
                                        controller: controller,
                                        map: map,
                                        id: id);
                                  }).toList(),
                                );
                        }).toList())),
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

class RecordCard extends StatelessWidget {
  const RecordCard({
    Key? key,
    required this.controller,
    required this.map,
    required this.id,
  }) : super(key: key);

  final HomeController controller;
  final Map map;
  final int id;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        openEditBottomSheet(context, map, id);
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Stack(
          children: [
            Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: AppStyles.errorColor,
                  ),
                  onPressed: () {
                    //print(e["id"].runtimeType);
                    controller.openSureDialog(context, id);
                  },
                )),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Column(
                children: map.entries.map((e) {
                  var title = e.key == "title" ? "" : "${e.key} : ";
                  var value = e.value;

                  TextStyle titleStyle = const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w500);
                  TextStyle valueStyle = title.isEmpty
                      ? const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w600)
                      : const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w400);
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: titleStyle,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        value,
                        style: valueStyle,
                      )
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DataRow extends StatelessWidget {
  const DataRow({
    Key? key,
    required this.controller,
    required this.index,
  }) : super(key: key);

  final HomeController controller;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
            child: TextField(
          controller: controller.labelNamesTextController[index],
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'Label Name'),
        )),
        const SizedBox(
          width: 10,
        ),
        Expanded(
            child: TextField(
          controller: controller.labelValuesTextController[index],
          decoration: const InputDecoration(hintText: 'Label Value'),
        )),
        IconButton(
            onPressed: () {
              // String value = controller.generateUniqueValue();
              // controller.labelValuesTextController[index].text = value;
              controller.openPasswordGenerateDialog(index);
            },
            icon: const Icon(Icons.key)),
        IconButton(
            onPressed: () {
              controller.deleteRow(index);
            },
            icon: const Icon(
              Icons.delete,
              color: AppStyles.errorColor,
            ))
      ],
    );
  }
}

void openEditBottomSheet(BuildContext context, Map data, int id) {
  var controller = HomeController.to;
  controller.addNLengthRows(data.length - 1);
  controller.titleValueTextController.text = data['title'];
  int i = 0;
  data.forEach((key, value) {
    if (key == 'title') return;
    controller.labelNamesTextController[i].text = key;
    controller.labelValuesTextController[i].text = value;
    i++;
  });
  showBottomSheet(
    context: context,
    builder: (context) {
      return BottomSheet(
          onClosing: () {},
          builder: ((context) {
            return SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                child: Obx(() => Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Center(
                          child: Text(
                            'Edit record',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Row(
                          children: [
                            const Text(
                              'Title',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            Expanded(
                                child: TextField(
                              controller: controller.titleValueTextController,
                              decoration: const InputDecoration(
                                  hintText: 'Add title for this record'),
                            )),
                          ],
                        ),
                        // IconButton(
                        //     onPressed: () {
                        //       controller.addNewRow();
                        //     },
                        //     icon: const Icon(Icons.add)),
                        ...List.generate(controller.noOfRows.value, (index) {
                          return DataRow(
                            controller: controller,
                            index: index,
                          );
                        }),
                        OutlinedButton(
                            onPressed: () {
                              controller.addNewRow();
                            },
                            child: const Text('Add new label')),

                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                                onPressed: () {
                                  controller.resetNoOfRows();
                                  Get.back();
                                },
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 17),
                                )),
                            const SizedBox(
                              width: 20,
                            ),
                            TextButton(
                                onPressed: () {
                                  controller.updateRecord(
                                      controller.getCategoryFromIndex(
                                        controller.tabController.index,
                                      ),
                                      id);
                                },
                                child: const Text(
                                  'Update',
                                  style: TextStyle(
                                      color: Colors.green, fontSize: 17),
                                )),
                          ],
                        ),
                      ],
                    )),
              ),
            );
          }));
    },
  );
}

// class TabPair {
//   final Tab tab;
//   final Widget view;
//   TabPair({required this.tab, required this.view});
// }

// List<TabPair> TabPairs = [
//   TabPair(
//     tab: Tab(
//       text: 'Intro',
//     ),
//     view: Center(
//       child: Text(
//         'Intro here',
//         style: TextStyle(
//           fontSize: 25,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     ),
//   ),
//   TabPair(
//     tab: Tab(
//       text: 'Ingredients',
//     ),
//     view: Center(
//       // replace with your own widget here
//       child: Text(
//         'Ingredients here',
//         style: TextStyle(
//           fontSize: 25,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     ),
//   ),
//   TabPair(
//     tab: Tab(
//       text: 'Steps',
//     ),
//     view: Center(
//       child: Text(
//         'Steps here',
//         style: TextStyle(
//           fontSize: 25,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     ),
//   )
// ];

// class TabBarAndTabViews extends StatefulWidget {
//   @override
//   _TabBarAndTabViewsState createState() => _TabBarAndTabViewsState();
// }

// class _TabBarAndTabViewsState extends State<TabBarAndTabViews>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   @override
//   void initState() {
//     _tabController = TabController(length: TabPairs.length, vsync: this);
//     super.initState();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _tabController.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Column(
//         children: [
//           // give the tab bar a height [can change height to preferred height]
//           Container(
//             height: 45,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(
//                 25.0,
//               ),
//             ),
//             child: Padding(
//               padding: EdgeInsets.all(6),
//               child: TabBar(
//                   controller: _tabController,
//                   // give the indicator a decoration (color and border radius)
//                   indicator: BoxDecoration(
//                     borderRadius: BorderRadius.circular(
//                       25.0,
//                     ),
//                     color: Color(0xFFFF8527),
//                   ),
//                   labelColor: Colors.white,
//                   unselectedLabelColor: Colors.black,
//                   tabs: TabPairs.map((tabPair) => tabPair.tab).toList()),
//             ),
//           ),
//           Expanded(
//             child: TabBarView(
//                 controller: _tabController,
//                 children: TabPairs.map((tabPair) => tabPair.view).toList()),
//           ),
//         ],
//       ),
//     );
//   }
// }
