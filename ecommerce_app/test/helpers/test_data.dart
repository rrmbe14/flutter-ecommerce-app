import 'package:ecommerce_app/models/product.dart';

Product fakeProduct({int id = 1, String title = 'Tee', double price = 19.99, String category = "men's clothing"}) {
  return Product(
    id: id,
    title: title,
    price: price,
    description: 'A nice product',
    category: category,
    image: 'https://example.com/$id.png',
    rating: const ProductRating(rate: 4.2, count: 100),
  );
}

List<Product> fakeProducts() => <Product>[
  fakeProduct(id: 1, title: 'Tee', price: 19.99, category: "men's clothing"),
  fakeProduct(id: 2, title: 'Necklace', price: 99, category: 'jewelery'),
  fakeProduct(id: 3, title: 'Backpack', price: 49.5, category: "men's clothing"),
];
