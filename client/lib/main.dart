import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

Future<List<Product>> fetchProducts() async {
  final response =
      await http.get(Uri.parse('http://localhost:8081/api/products'));

  if (response.statusCode == 200) {
    List<Product> products = (json.decode(response.body) as List)
        .map((data) => Product.fromJson(data))
        .toList();
    return products;
  } else {
    throw Exception('Failed to load products');
  }
}

class Product {
  final int productId;
  final String productName;
  final double price;
  final String? countryOfOrigin;
  final String category;
  final bool available;

  Product({
    required this.productId,
    required this.productName,
    required this.price,
    required this.category,
    required this.available,
    this.countryOfOrigin,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['product_id'],
      productName: json['product_name'],
      price: json['price'],
      countryOfOrigin: json['country_of_origin'],
      category: json['category'],
      available: json['available'],
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'REST client',
        theme: ThemeData(
            useMaterial3: false,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent)),
        debugShowCheckedModeBanner: false,
        home: const MyHomePage(
          title: 'Home page',
        ),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  Product? currentProduct;

  void showItemDetails(Product? product) {
    currentProduct = product;
    notifyListeners();
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return appState.currentProduct == null
        ? const ListOfProducts()
        : ProductDetails(product: appState.currentProduct!);
  }
}

class ListOfProducts extends StatefulWidget {
  const ListOfProducts({super.key});

  @override
  State<ListOfProducts> createState() => _ListOfProductsState();
}

class _ListOfProductsState extends State<ListOfProducts> {
  late Future<List<Product>> _futureProducts;

  @override
  void initState() {
    super.initState();
    _futureProducts = fetchProducts();
  }

  void _reloadData() {
    setState(() {
      _futureProducts = fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List of products'),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 10.0, 0),
            child: IconButton(
                onPressed: () {
                  _reloadData();
                },
                icon: const Icon(Icons.refresh_rounded)),
          )
        ],
      ),
      body: Center(
        child: FutureBuilder<List<Product>>(
            future: _futureProducts,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Product> products = snapshot.data!;
                return Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: ListView(
                    padding: const EdgeInsets.all(5.0),
                    children: [
                      for (Product product in products)
                        ProductTile(product: product)
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              return const CircularProgressIndicator();
            }),
      ),
    );
  }
}

class ProductTile extends StatelessWidget {
  const ProductTile({
    super.key,
    required this.product,
  });

  final Product product;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Card(
      child: ListTile(
        leading: const Icon(Icons.add_shopping_cart),
        title: Text(product.productName),
        onTap: () {
          appState.showItemDetails(product);
        },
      ),
    );
  }
}

class ProductDetails extends StatelessWidget {
  const ProductDetails({super.key, required this.product});
  final Product product;
  final TextStyle descriptionStyle = const TextStyle(
    fontSize: 20,
  );
  final double descriptionPadding = 8.0;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return WillPopScope(
      onWillPop: () async {
        appState.showItemDetails(null);
        return false;
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text('${product.productName} details'),
            actions: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 10.0, 0),
                child: IconButton(
                    onPressed: () {
                      appState.showItemDetails(null);
                    },
                    icon: const Icon(Icons.arrow_back_ios_new_rounded)),
              )
            ],
          ),
          body: Container(
            color: Theme.of(context).colorScheme.primaryContainer,
            padding: const EdgeInsets.all(10.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(descriptionPadding),
                      child: Text(
                        product.productName,
                        style: const TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(descriptionPadding),
                      child: Text(
                        'Price: ${product.price} \$',
                        style: descriptionStyle,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(descriptionPadding),
                      child: Text(
                        'Category: ${product.category}',
                        style: descriptionStyle,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(descriptionPadding),
                      child: Text(
                        'Country of origin: ${product.countryOfOrigin ?? ''}',
                        style: descriptionStyle,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(descriptionPadding),
                      child: Text(
                        'Available: ${product.available ? 'yes' : 'no'}',
                        style: descriptionStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
