import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../utils/styles.dart';

class CategoryView extends GetView {
  const CategoryView(this.data, {Key? key}) : super(key: key);
  final List<Map<String, dynamic>> data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: data.isNotEmpty
          ? ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) => Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      title: Text('${index}'),
                      trailing: IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.delete,
                            color: AppStyles.errorColor,
                          )),
                      onTap: () {
                        Get.defaultDialog(title: '$index', middleText: '');
                      },
                    ),
                  ))
          : Text('No data to show'),
    );
  }
}
