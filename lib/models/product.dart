class Product {
  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.category,
    this.description,
    this.sizes,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String price;
  final String category;
  final String? description;
  final List<String>? sizes;

  /// URL фото из Firebase Storage (если товар из админки)
  final String? imageUrl;

  /// Путь к фото: URL или assets/products/{id}.jpg
  String get imagePath => imageUrl ?? 'assets/products/$id.jpg';

  /// true если фото загружено из интернета
  bool get hasNetworkImage => imageUrl != null && imageUrl!.isNotEmpty;

  static const String catClothing = 'Одежда';
  static const String catShoes = 'Обувь';
  static const String catAccessories = 'Аксессуары';
  static const String catNew = 'Новая коллекция';

  static const List<Product> _all = [
    // Одежда (10)
    Product(id: '1', title: 'Куртка Oversize', price: '12 990 ₽', category: catClothing,
      description: 'Объёмная куртка из плотного хлопка. Унисекс, свободный крой.', sizes: ['S', 'M', 'L', 'XL']),
    Product(id: '2', title: 'Брюки широкие', price: '7 490 ₽', category: catClothing,
      description: 'Широкие брюки из смесовой ткани. Высокая посадка.', sizes: ['44', '46', '48', '50']),
    Product(id: '3', title: 'Свитшот', price: '5 990 ₽', category: catClothing,
      description: 'Оверсайз свитшот с капюшоном. Мягкий флис внутри.', sizes: ['S', 'M', 'L', 'XL']),
    Product(id: '4', title: 'Худи с капюшоном', price: '6 490 ₽', category: catClothing,
      description: 'Уютное худи из мягкого хлопка.', sizes: ['S', 'M', 'L', 'XL']),
    Product(id: '5', title: 'Футболка оверсайз', price: '3 990 ₽', category: catClothing,
      description: 'Базовая футболка свободного кроя.', sizes: ['S', 'M', 'L', 'XL']),
    Product(id: '6', title: 'Парка длинная', price: '18 990 ₽', category: catClothing,
      description: 'Тёплая парка с мехом на капюшоне.', sizes: ['S', 'M', 'L', 'XL']),
    Product(id: '7', title: 'Джоггеры', price: '5 490 ₽', category: catClothing,
      description: 'Джоггеры из мягкого трикотажа.', sizes: ['S', 'M', 'L', 'XL']),
    Product(id: '8', title: 'Платье минимал', price: '9 990 ₽', category: catClothing,
      description: 'Минималистичное платье прямого кроя.', sizes: ['42', '44', '46', '48']),
    Product(id: '9', title: 'Рубашка свободного кроя', price: '7 990 ₽', category: catClothing,
      description: 'Хлопковая рубашка oversize.', sizes: ['S', 'M', 'L', 'XL']),
    Product(id: '10', title: 'Толстовка с принтом', price: '5 490 ₽', category: catClothing,
      description: 'Толстовка с логотипом бренда.', sizes: ['S', 'M', 'L', 'XL']),
    // Обувь (10)
    Product(id: '11', title: 'Кроссовки', price: '14 990 ₽', category: catShoes,
      description: 'Минималистичные кроссовки. Кожа и сетка.', sizes: ['39', '40', '41', '42', '43']),
    Product(id: '12', title: 'Кеды классика', price: '8 990 ₽', category: catShoes,
      description: 'Классические кеды на резиновой подошве.', sizes: ['39', '40', '41', '42', '43']),
    Product(id: '13', title: 'Ботинки челси', price: '16 990 ₽', category: catShoes,
      description: 'Кожаные ботинки челси на резине.', sizes: ['39', '40', '41', '42', '43']),
    Product(id: '14', title: 'Слипоны', price: '6 490 ₽', category: catShoes,
      description: 'Удобные слипоны из замши.', sizes: ['39', '40', '41', '42', '43']),
    Product(id: '15', title: 'Сандалии', price: '7 990 ₽', category: catShoes,
      description: 'Минималистичные сандалии с ремешками.', sizes: ['38', '39', '40', '41', '42']),
    Product(id: '16', title: 'Лоферы', price: '12 990 ₽', category: catShoes,
      description: 'Классические лоферы из кожи.', sizes: ['39', '40', '41', '42', '43']),
    Product(id: '17', title: 'Кроссовки беговые', price: '15 990 ₽', category: catShoes,
      description: 'Лёгкие кроссовки для бега.', sizes: ['39', '40', '41', '42', '43']),
    Product(id: '18', title: 'Ботинки зимние', price: '19 990 ₽', category: catShoes,
      description: 'Тёплые зимние ботинки на меху.', sizes: ['39', '40', '41', '42', '43']),
    Product(id: '19', title: 'Туфли дерби', price: '13 990 ₽', category: catShoes,
      description: 'Классические туфли дерби.', sizes: ['39', '40', '41', '42', '43']),
    Product(id: '20', title: 'Шлепанцы', price: '3 990 ₽', category: catShoes,
      description: 'Лёгкие шлепанцы с мягкой подошвой.', sizes: ['39', '40', '41', '42', '43']),
    // Аксессуары (10)
    Product(id: '21', title: 'Рюкзак городской', price: '8 990 ₽', category: catAccessories,
      description: 'Минималистичный рюкзак из прочной ткани.'),
    Product(id: '22', title: 'Кепка с логотипом', price: '2 990 ₽', category: catAccessories,
      description: 'Хлопковая кепка с вышивкой.'),
    Product(id: '23', title: 'Шарф шерстяной', price: '4 490 ₽', category: catAccessories,
      description: 'Тёплый шарф из смеси шерсти.'),
    Product(id: '24', title: 'Ремень кожаный', price: '5 990 ₽', category: catAccessories,
      description: 'Классический кожаный ремень.'),
    Product(id: '25', title: 'Часы минимал', price: '24 990 ₽', category: catAccessories,
      description: 'Минималистичные часы на кожаном ремешке.'),
    Product(id: '26', title: 'Сумка шоппер', price: '11 990 ₽', category: catAccessories,
      description: 'Большая сумка-шоппер из экокожи.'),
    Product(id: '27', title: 'Кошелёк', price: '4 990 ₽', category: catAccessories,
      description: 'Компактный кожаный кошелёк.'),
    Product(id: '28', title: 'Солнечные очки', price: '6 990 ₽', category: catAccessories,
      description: 'Очки с UV-защитой в минималистичной оправе.'),
    Product(id: '29', title: 'Носки набор 3 шт', price: '1 490 ₽', category: catAccessories,
      description: 'Набор из трёх пар базовых носков.'),
    Product(id: '30', title: 'Шапка вязаная', price: '3 490 ₽', category: catAccessories,
      description: 'Вязаная шапка из мягкой пряжи.'),
    // Новая коллекция (10)
    Product(id: '31', title: 'Пальто весна', price: '22 990 ₽', category: catNew,
      description: 'Лёгкое пальто на весну. Классический крой.', sizes: ['S', 'M', 'L', 'XL']),
    Product(id: '32', title: 'Кардиган оверсайз', price: '8 990 ₽', category: catNew,
      description: 'Объёмный кардиган из кашемировой смеси.', sizes: ['S', 'M', 'L', 'XL']),
    Product(id: '33', title: 'Юбка миди', price: '6 490 ₽', category: catNew,
      description: 'Юбка миди длины. Плотная ткань.', sizes: ['42', '44', '46', '48']),
    Product(id: '34', title: 'Жилет стёганый', price: '9 990 ₽', category: catNew,
      description: 'Стёганый жилет без рукавов.', sizes: ['S', 'M', 'L', 'XL']),
    Product(id: '35', title: 'Бомбер', price: '11 990 ₽', category: catNew,
      description: 'Куртка-бомбер на синтепоне.', sizes: ['S', 'M', 'L', 'XL']),
    Product(id: '36', title: 'Лонгслив базовый', price: '4 490 ₽', category: catNew,
      description: 'Длинный рукав из мягкого хлопка.', sizes: ['S', 'M', 'L', 'XL']),
    Product(id: '37', title: 'Поло с вышивкой', price: '5 990 ₽', category: catNew,
      description: 'Классическое поло с логотипом.', sizes: ['S', 'M', 'L', 'XL']),
    Product(id: '38', title: 'Шорты чинос', price: '5 490 ₽', category: catNew,
      description: 'Шорты из ткани чинос.', sizes: ['44', '46', '48', '50']),
    Product(id: '39', title: 'Плащ дождевик', price: '14 990 ₽', category: catNew,
      description: 'Лёгкий плащ с водоотталкивающей пропиткой.', sizes: ['S', 'M', 'L', 'XL']),
    Product(id: '40', title: 'Ветровка', price: '7 990 ₽', category: catNew,
      description: 'Лёгкая ветровка на весну и осень.', sizes: ['S', 'M', 'L', 'XL']),
  ];

  static List<Product> get all => _all;

  static List<Product> get featured => [
    _all[0],  // Куртка Oversize
    _all[1],  // Брюки широкие
    _all[2],  // Свитшот
    _all[10], // Кроссовки
  ];

  static List<Product> byCategory(String category) {
    return _all.where((p) => p.category == category).toList();
  }

  static Product? byId(String id) {
    try {
      return _all.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}

class CartItem {
  const CartItem({
    required this.productId,
    required this.title,
    required this.price,
    this.quantity = 1,
  });

  final String productId;
  final String title;
  final String price;
  final int quantity;

  String get priceTotal {
    final num = price.replaceAll(RegExp(r'[^\d]'), '');
    final total = (int.tryParse(num) ?? 0) * quantity;
    final str = total.toString();
    final buf = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write(' ');
      buf.write(str[i]);
    }
    return '${buf.toString()} ₽';
  }
}
