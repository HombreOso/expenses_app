import 'package:flutter/material.dart';

import '../models/category.dart';

class CategoriesList extends StatelessWidget {
  final List<Category> categories;
  final Function deleteCat;

  CategoriesList(this.categories, this.deleteCat);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 450,
      child: categories.isEmpty
          ? Column(
              children: <Widget>[
                Text(
                  'No categories added yet!',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                    height: 200,
                    child: Image.asset(
                      'assets/images/waiting.png',
                      fit: BoxFit.cover,
                    )),
              ],
            )
          : ListView.builder(
              itemBuilder: (ctx, index) {
                return Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 5,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      child: Padding(
                        padding: EdgeInsets.all(6),
                        child: FittedBox(
                          child: Text(
                              '\$${categories[index].amount.toStringAsFixed(0)}'),
                        ),
                      ),
                    ),
                    title: Text(
                      categories[index].name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      color: Theme.of(context).colorScheme.error,
                      onPressed: () => deleteCat(
                        categories[index].name,
                        categories[index].uid,
                      ),
                    ),
                  ),
                );
              },
              itemCount: categories.length,
            ),
    );
  }
}
