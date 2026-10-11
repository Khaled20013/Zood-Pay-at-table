import 'package:zood_pay_at_table/features/menu/domain/entities/product.dart';
import 'package:zood_pay_at_table/features/table_session/domain/entities/table_session.dart';

const demoQrId = '40de86d3987ef0a98768ad61';

const tableSession = TableSession(
  qrId: demoQrId,
  businessReference: '100245',
  branchId: 'br_olaya',
  branchName: 'Olaya',
  tableId: 'tbl_t5',
  tableName: 'T5',
  currency: 'SAR',
);

const small = ModifierOption(id: 'opt_small', name: 'Small', price: 0);
const large = ModifierOption(id: 'opt_large', name: 'Large', price: 5);

/// Required single choice, defaults to Small.
const sizeModifier = ProductModifier(
  modifierId: 'mod_size',
  name: 'Size',
  options: [small, large],
  minimumOptions: 1,
  maximumOptions: 1,
  defaultOptionIds: ['opt_small'],
);

const vanilla = ModifierOption(id: 'opt_vanilla', name: 'Vanilla', price: 2);
const caramel = ModifierOption(id: 'opt_caramel', name: 'Caramel', price: 3);

/// Optional, up to 3 units, options can repeat, first unit free.
const syrupModifier = ProductModifier(
  modifierId: 'mod_syrup',
  name: 'Syrup',
  options: [vanilla, caramel],
  maximumOptions: 3,
  freeOptions: 1,
  uniqueOptions: false,
);

const noSugar = ModifierOption(id: 'opt_no_sugar', name: 'No sugar', price: 0);
const lessSugar = ModifierOption(
  id: 'opt_less_sugar',
  name: 'Less sugar',
  price: 0,
);

/// Required with no default: blocks quick add.
const sugarModifier = ProductModifier(
  modifierId: 'mod_sugar',
  name: 'Sugar',
  options: [noSugar, lessSugar],
  minimumOptions: 1,
  maximumOptions: 1,
);

const karakTea = Product(
  id: 'prd_karak_tea',
  name: 'Karak Tea',
  description: 'Spiced milk tea',
  price: 8.0,
  category: 'Hot Beverages',
  categoryId: 'cat_hot',
  modifiers: [sizeModifier, syrupModifier],
);

const mintLemonade = Product(
  id: 'prd_mint_lemonade',
  name: 'Mint Lemonade',
  description: 'Fresh lemons and mint',
  price: 14.0,
  category: 'Cold Beverages',
  categoryId: 'cat_cold',
  modifiers: [sugarModifier],
);

const icedSpanishLatte = Product(
  id: 'prd_iced_spanish_latte',
  name: 'Iced Spanish Latte',
  description: 'Espresso, milk, condensed milk',
  price: 18.0,
  category: 'Cold Beverages',
  categoryId: 'cat_cold',
);

const soldOutCake = Product(
  id: 'prd_sold_out',
  name: 'Sold Out Cake',
  description: 'Not today',
  price: 20,
  category: 'Desserts',
  isAvailable: false,
);
