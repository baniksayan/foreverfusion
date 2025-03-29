import 'package:forever_fusion/controllers/db_service.dart';
import 'package:forever_fusion/models/categories_model.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CategoryContainer extends StatefulWidget {
  const CategoryContainer({super.key});

  @override
  State<CategoryContainer> createState() => _CategoryContainerState();
}

class _CategoryContainerState extends State<CategoryContainer> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110, // Prevents overflow by limiting height
      child: StreamBuilder(
          stream: DbService().readCategories(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<CategoriesModel> categories =
              CategoriesModel.fromJsonList(snapshot.data!.docs)
              as List<CategoriesModel>;
              if (categories.isEmpty) {
                return const SizedBox();
              } else {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories
                        .map((cat) => CategoryButton(
                        imagepath: cat.image, name: cat.name))
                        .toList(),
                  ),
                );
              }
            } else {
              return Shimmer.fromColors(
                baseColor: Colors.grey.shade200,
                highlightColor: Colors.white,
                child: Container(height: 90, width: double.infinity),
              );
            }
          }),
    );
  }
}

class CategoryButton extends StatefulWidget {
  final String imagepath, name;
  const CategoryButton(
      {super.key, required this.imagepath, required this.name});

  @override
  State<CategoryButton> createState() => _CategoryButtonState();
}

class _CategoryButtonState extends State<CategoryButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, "/specific", arguments: {
        "name": widget.name,
      }),
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(4),
        height: 95,
        width: 95,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(widget.imagepath, height: 50),
            const SizedBox(height: 8),
            Text(
              "${widget.name.substring(0, 1).toUpperCase()}${widget.name.substring(1)}",
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
