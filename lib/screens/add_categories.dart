import 'package:flutter/material.dart';

import '../models/category.dart';

class CategoryScreen extends StatefulWidget {
  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<Category> categories = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Categories'),
      ),
      body: ListView.builder(
        itemCount: categories.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == categories.length) {
            // This is the "Add Category" button
            return ListTile(
              leading: Icon(Icons.add),
              title: Text('Add Category'),
              onTap: () {
                _showAddCategoryDialog();
              },
            );
          } else {
            // This is an existing category
            Category category = categories[index];
            return ListTile(
              title: Text(category.name),
              subtitle: Text('\$${category.amount}'),
            );
          }
        },
      ),
    );
  }

  void _showAddCategoryDialog() async {
    Category newCategory = Category(
      name: "",
      amount: 0,
    );
    newCategory = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Category Name',
                ),
                onChanged: (value) {
                  // Update the name of the new category as the user types
                  newCategory.name = value;
                },
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Amount',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  // Update the amount of the new category as the user types
                  newCategory.amount = double.tryParse(value) ?? 0;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Close the dialog without adding the new category
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Add the new category and close the dialog
                Navigator.of(context).pop(newCategory);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );

    // If the user added a new category, add it to the list
    if (newCategory != null) {
      setState(() {
        categories.add(newCategory);
      });
    }
  }
}
