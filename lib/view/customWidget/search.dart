import 'package:flutter/material.dart';
import 'package:music_player/view/customWidget/extention/media_query.dart';
import '../../appString/appcolor.dart';
class CustomSearchWidget extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String>? onChanged;

  const CustomSearchWidget({
    required this.controller,
    required this.focusNode,
    this.onChanged
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 15,
      ),
      child: Container(
        width: double.infinity,
        height: context.hight*0.07,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, 3),
            )
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Icon(
                Icons.search,
                color: AppColor.primaryColor,
              ),
              SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  onChanged: onChanged,
                  decoration: InputDecoration(
                    hintText: "Search",
                    border: InputBorder.none,
                  ),
                ),
              ),
              Icon(Icons.filter_list),
            ],
          ),
        ),
      ),
    );
  }
}
