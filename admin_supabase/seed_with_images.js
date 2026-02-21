/**
 * Загружает ВСЕ товары с ВАШИМИ картинками из assets/products/
 * Запуск: node seed_with_images.js
 */
const fs = require('fs');
const path = require('path');

const configPath = path.join(__dirname, 'config.js');
const configStr = fs.readFileSync(configPath, 'utf8');
const urlMatch = configStr.match(/url:\s*["']([^"']+)["']/);
const keyMatch = configStr.match(/anonKey:\s*["']([^"']+)["']/);
if (!urlMatch || !keyMatch) {
  console.error('Не найден config.js с url и anonKey');
  process.exit(1);
}
const supabaseUrl = urlMatch[1];
const supabaseKey = keyMatch[1];

const { createClient } = require('@supabase/supabase-js');
const supabase = createClient(supabaseUrl, supabaseKey);

const ASSETS_DIR = path.join(__dirname, '..', 'assets', 'products');

const PRODUCTS = [
  { title: 'Куртка Oversize', price: 12990, category: 'Одежда', description: 'Объёмная куртка из плотного хлопка. Унисекс, свободный крой.', sizes: ['S', 'M', 'L', 'XL'] },
  { title: 'Брюки широкие', price: 7490, category: 'Одежда', description: 'Широкие брюки из смесовой ткани. Высокая посадка.', sizes: ['44', '46', '48', '50'] },
  { title: 'Свитшот', price: 5990, category: 'Одежда', description: 'Оверсайз свитшот с капюшоном. Мягкий флис внутри.', sizes: ['S', 'M', 'L', 'XL'] },
  { title: 'Худи с капюшоном', price: 6490, category: 'Одежда', description: 'Уютное худи из мягкого хлопка.', sizes: ['S', 'M', 'L', 'XL'] },
  { title: 'Футболка оверсайз', price: 3990, category: 'Одежда', description: 'Базовая футболка свободного кроя.', sizes: ['S', 'M', 'L', 'XL'] },
  { title: 'Парка длинная', price: 18990, category: 'Одежда', description: 'Тёплая парка с мехом на капюшоне.', sizes: ['S', 'M', 'L', 'XL'] },
  { title: 'Джоггеры', price: 5490, category: 'Одежда', description: 'Джоггеры из мягкого трикотажа.', sizes: ['S', 'M', 'L', 'XL'] },
  { title: 'Платье минимал', price: 9990, category: 'Одежда', description: 'Минималистичное платье прямого кроя.', sizes: ['42', '44', '46', '48'] },
  { title: 'Рубашка свободного кроя', price: 7990, category: 'Одежда', description: 'Хлопковая рубашка oversize.', sizes: ['S', 'M', 'L', 'XL'] },
  { title: 'Толстовка с принтом', price: 5490, category: 'Одежда', description: 'Толстовка с логотипом бренда.', sizes: ['S', 'M', 'L', 'XL'] },
  { title: 'Кроссовки', price: 14990, category: 'Обувь', description: 'Минималистичные кроссовки. Кожа и сетка.', sizes: ['39', '40', '41', '42', '43'] },
  { title: 'Кеды классика', price: 8990, category: 'Обувь', description: 'Классические кеды на резиновой подошве.', sizes: ['39', '40', '41', '42', '43'] },
  { title: 'Ботинки челси', price: 16990, category: 'Обувь', description: 'Кожаные ботинки челси на резине.', sizes: ['39', '40', '41', '42', '43'] },
  { title: 'Слипоны', price: 6490, category: 'Обувь', description: 'Удобные слипоны из замши.', sizes: ['39', '40', '41', '42', '43'] },
  { title: 'Сандалии', price: 7990, category: 'Обувь', description: 'Минималистичные сандалии с ремешками.', sizes: ['38', '39', '40', '41', '42'] },
  { title: 'Лоферы', price: 12990, category: 'Обувь', description: 'Классические лоферы из кожи.', sizes: ['39', '40', '41', '42', '43'] },
  { title: 'Кроссовки беговые', price: 15990, category: 'Обувь', description: 'Лёгкие кроссовки для бега.', sizes: ['39', '40', '41', '42', '43'] },
  { title: 'Ботинки зимние', price: 19990, category: 'Обувь', description: 'Тёплые зимние ботинки на меху.', sizes: ['39', '40', '41', '42', '43'] },
  { title: 'Туфли дерби', price: 13990, category: 'Обувь', description: 'Классические туфли дерби.', sizes: ['39', '40', '41', '42', '43'] },
  { title: 'Шлепанцы', price: 3990, category: 'Обувь', description: 'Лёгкие шлепанцы с мягкой подошвой.', sizes: ['39', '40', '41', '42', '43'] },
  { title: 'Рюкзак городской', price: 8990, category: 'Аксессуары', description: 'Минималистичный рюкзак из прочной ткани.' },
  { title: 'Кепка с логотипом', price: 2990, category: 'Аксессуары', description: 'Хлопковая кепка с вышивкой.' },
  { title: 'Шарф шерстяной', price: 4490, category: 'Аксессуары', description: 'Тёплый шарф из смеси шерсти.' },
  { title: 'Ремень кожаный', price: 5990, category: 'Аксессуары', description: 'Классический кожаный ремень.' },
  { title: 'Часы минимал', price: 24990, category: 'Аксессуары', description: 'Минималистичные часы на кожаном ремешке.' },
  { title: 'Сумка шоппер', price: 11990, category: 'Аксессуары', description: 'Большая сумка-шоппер из экокожи.' },
  { title: 'Кошелёк', price: 4990, category: 'Аксессуары', description: 'Компактный кожаный кошелёк.' },
  { title: 'Солнечные очки', price: 6990, category: 'Аксессуары', description: 'Очки с UV-защитой в минималистичной оправе.' },
  { title: 'Носки набор 3 шт', price: 1490, category: 'Аксессуары', description: 'Набор из трёх пар базовых носков.' },
  { title: 'Шапка вязаная', price: 3490, category: 'Аксессуары', description: 'Вязаная шапка из мягкой пряжи.' },
  { title: 'Пальто весна', price: 22990, category: 'Новая коллекция', description: 'Лёгкое пальто на весну. Классический крой.', sizes: ['S', 'M', 'L', 'XL'] },
  { title: 'Кардиган оверсайз', price: 8990, category: 'Новая коллекция', description: 'Объёмный кардиган из кашемировой смеси.', sizes: ['S', 'M', 'L', 'XL'] },
  { title: 'Юбка миди', price: 6490, category: 'Новая коллекция', description: 'Юбка миди длины. Плотная ткань.', sizes: ['42', '44', '46', '48'] },
  { title: 'Жилет стёганый', price: 9990, category: 'Новая коллекция', description: 'Стёганый жилет без рукавов.', sizes: ['S', 'M', 'L', 'XL'] },
  { title: 'Бомбер', price: 11990, category: 'Новая коллекция', description: 'Куртка-бомбер на синтепоне.', sizes: ['S', 'M', 'L', 'XL'] },
  { title: 'Лонгслив базовый', price: 4490, category: 'Новая коллекция', description: 'Длинный рукав из мягкого хлопка.', sizes: ['S', 'M', 'L', 'XL'] },
  { title: 'Поло с вышивкой', price: 5990, category: 'Новая коллекция', description: 'Классическое поло с логотипом.', sizes: ['S', 'M', 'L', 'XL'] },
  { title: 'Шорты чинос', price: 5490, category: 'Новая коллекция', description: 'Шорты из ткани чинос.', sizes: ['44', '46', '48', '50'] },
  { title: 'Плащ дождевик', price: 14990, category: 'Новая коллекция', description: 'Лёгкий плащ с водоотталкивающей пропиткой.', sizes: ['S', 'M', 'L', 'XL'] },
  { title: 'Ветровка', price: 7990, category: 'Новая коллекция', description: 'Лёгкая ветровка на весну и осень.', sizes: ['S', 'M', 'L', 'XL'] }
];

async function main() {
  console.log('\n=== Загрузка товаров с вашими картинками ===\n');

  for (let i = 0; i < PRODUCTS.length; i++) {
    const num = i + 1;
    const imgPath = path.join(ASSETS_DIR, num + '.jpg');
    if (!fs.existsSync(imgPath)) {
      console.log('Пропуск ' + num + ' — нет файла ' + imgPath);
      continue;
    }
    const p = PRODUCTS[i];
    const storagePath = 'products/' + Date.now() + '_' + num + '.jpg';
    const fileBuffer = fs.readFileSync(imgPath);

    const { error: uploadErr } = await supabase.storage.from('products').upload(storagePath, fileBuffer, {
      contentType: 'image/jpeg',
      upsert: false
    });
    if (uploadErr) {
      console.error('Ошибка загрузки фото ' + num + ':', uploadErr.message);
      continue;
    }
    const { data: urlData } = supabase.storage.from('products').getPublicUrl(storagePath);
    const imageUrl = urlData.publicUrl;

    const { error: insertErr } = await supabase.from('products').insert({
      title: p.title,
      price: p.price,
      category: p.category,
      description: p.description || null,
      sizes: p.sizes || null,
      image_url: imageUrl,
      created_at: new Date().toISOString()
    });
    if (insertErr) {
      console.error('Ошибка добавления ' + p.title + ':', insertErr.message);
      continue;
    }
    console.log('✓ ' + num + '. ' + p.title);
  }
  console.log('\nГотово! Товары с вашими картинками добавлены в Supabase.\n');
}

main().catch(e => {
  console.error(e);
  process.exit(1);
});
