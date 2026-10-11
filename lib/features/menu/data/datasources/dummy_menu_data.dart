import '../models/product_model.dart';

/// Demo menu served while the Pay at Table API is not wired up
/// (`USE_DUMMY_DATA=true`, the default). Same JSON as the categories,
/// products and modifiers endpoints, so it goes through the same parsing
/// and joining as real responses. Covers every modifier rule: required
/// single choice, defaults, exclusions, free units and option quantities.
abstract final class DummyMenuData {
  static CategoriesResponse categories() =>
      CategoriesResponse.fromJson({'data': _categories});

  static ProductsResponse products() =>
      ProductsResponse.fromJson({'data': _products});

  static ModifiersResponse modifiers() =>
      ModifiersResponse.fromJson({'data': _modifiers});

  static const String _unsplash = 'https://images.unsplash.com/photo-';

  // Deliberately out of `index` order.
  static const List<Map<String, Object?>> _categories = [
    {
      'id': 'cat_desserts',
      'name': 'Desserts',
      'name_localized': 'حلويات',
      'image': null,
      'index': 3,
    },
    {
      'id': 'cat_hot',
      'name': 'Hot Beverages',
      'name_localized': 'مشروبات ساخنة',
      'image': null,
      'index': 1,
    },
    {
      'id': 'cat_cold',
      'name': 'Cold Beverages',
      'name_localized': 'مشروبات باردة',
      'image': null,
      'index': 2,
    },
  ];

  static const List<Map<String, Object?>> _modifiers = [
    {
      'id': 'mod_size',
      'name': 'Size',
      'name_localized': 'الحجم',
      'options': [
        {
          'id': 'opt_small',
          'name': 'Small',
          'name_localized': 'صغير',
          'price': 0,
        },
        {
          'id': 'opt_medium',
          'name': 'Medium',
          'name_localized': 'وسط',
          'price': 3,
        },
        {
          'id': 'opt_large',
          'name': 'Large',
          'name_localized': 'كبير',
          'price': 5,
        },
      ],
    },
    {
      'id': 'mod_sugar',
      'name': 'Sugar',
      'name_localized': 'السكر',
      'options': [
        {
          'id': 'opt_no_sugar',
          'name': 'No sugar',
          'name_localized': 'بدون سكر',
          'price': 0,
        },
        {
          'id': 'opt_less_sugar',
          'name': 'Less sugar',
          'name_localized': 'سكر خفيف',
          'price': 0,
        },
        {
          'id': 'opt_normal_sugar',
          'name': 'Normal',
          'name_localized': 'سكر عادي',
          'price': 0,
        },
      ],
    },
    {
      'id': 'mod_milk',
      'name': 'Milk',
      'name_localized': 'الحليب',
      'options': [
        {
          'id': 'opt_full_milk',
          'name': 'Full cream',
          'name_localized': 'حليب كامل الدسم',
          'price': 0,
        },
        {
          'id': 'opt_oat_milk',
          'name': 'Oat milk',
          'name_localized': 'حليب الشوفان',
          'price': 3,
        },
        {
          'id': 'opt_almond_milk',
          'name': 'Almond milk',
          'name_localized': 'حليب اللوز',
          'price': 3,
        },
      ],
    },
    {
      'id': 'mod_extras',
      'name': 'Extras',
      'name_localized': 'إضافات',
      'options': [
        {
          'id': 'opt_cardamom',
          'name': 'Extra cardamom',
          'name_localized': 'هيل إضافي',
          'price': 2,
        },
        {
          'id': 'opt_saffron',
          'name': 'Saffron',
          'name_localized': 'زعفران',
          'price': 4,
        },
        {
          'id': 'opt_shot',
          'name': 'Extra espresso shot',
          'name_localized': 'جرعة إسبريسو إضافية',
          'price': 4,
        },
        {
          'id': 'opt_cream',
          'name': 'Whipped cream',
          'name_localized': 'كريمة مخفوقة',
          'price': 3,
        },
      ],
    },
    {
      'id': 'mod_syrup',
      'name': 'Syrup pumps',
      'name_localized': 'نكهات',
      'options': [
        {
          'id': 'opt_vanilla',
          'name': 'Vanilla',
          'name_localized': 'فانيليا',
          'price': 2,
        },
        {
          'id': 'opt_caramel',
          'name': 'Caramel',
          'name_localized': 'كراميل',
          'price': 2,
        },
        {
          'id': 'opt_hazelnut',
          'name': 'Hazelnut',
          'name_localized': 'بندق',
          'price': 2,
        },
      ],
    },
    {
      'id': 'mod_toppings',
      'name': 'Toppings',
      'name_localized': 'إضافات الحلى',
      'options': [
        {
          'id': 'opt_pistachio',
          'name': 'Extra pistachio',
          'name_localized': 'فستق إضافي',
          'price': 5,
        },
        {
          'id': 'opt_ice_cream',
          'name': 'Vanilla ice cream scoop',
          'name_localized': 'كرة آيس كريم فانيليا',
          'price': 6,
        },
        {
          'id': 'opt_syrup',
          'name': 'Extra syrup',
          'name_localized': 'قطر إضافي',
          'price': 0,
        },
      ],
    },
  ];

  static const List<Map<String, Object?>> _products = [
    {
      'id': 'prd_karak_tea',
      'name': 'Karak Tea',
      'name_localized': 'شاي كرك',
      'description':
          'Strong black tea slow-brewed with evaporated milk, cardamom and saffron.',
      'description_localized':
          'شاي أسود مركّز يُطهى على مهل مع الحليب المبخّر والهيل والزعفران.',
      'image': '${_unsplash}1571934811356-5cc061b6821f?w=600&q=70',
      'price': 7,
      'category_id': 'cat_hot',
      'modifiers': [
        {
          'modifier_id': 'mod_size',
          'minimum_options': 1,
          'maximum_options': 1,
          'free_options': 0,
          'unique_options': true,
          'default_options_ids': ['opt_small'],
          'excluded_options_ids': [],
          'index': 0,
        },
        {
          'modifier_id': 'mod_sugar',
          'minimum_options': 1,
          'maximum_options': 1,
          'free_options': 0,
          'unique_options': true,
          'default_options_ids': ['opt_normal_sugar'],
          'excluded_options_ids': [],
          'index': 1,
        },
        {
          'modifier_id': 'mod_extras',
          'minimum_options': 0,
          'maximum_options': 2,
          'free_options': 0,
          'unique_options': true,
          'default_options_ids': [],
          'excluded_options_ids': ['opt_shot', 'opt_cream'],
          'index': 2,
        },
      ],
    },
    {
      'id': 'prd_saudi_coffee_pot',
      'name': 'Saudi Coffee Pot',
      'name_localized': 'دلّة قهوة سعودية',
      'description':
          'A dallah of light-roast Khawlani coffee with cardamom and cloves. Serves 2–3.',
      'description_localized':
          'دلّة من البن الخولاني المحمّص تحميصًا خفيفًا مع الهيل والقرنفل. تكفي شخصين إلى ثلاثة.',
      'image': '${_unsplash}1610632380989-680fe40816c6?w=600&q=70',
      'price': 22,
      'category_id': 'cat_hot',
      'modifiers': [
        {
          'modifier_id': 'mod_extras',
          'minimum_options': 0,
          'maximum_options': 0,
          'free_options': 1,
          'unique_options': true,
          'default_options_ids': [],
          'excluded_options_ids': ['opt_shot', 'opt_cream'],
          'index': 0,
        },
      ],
    },
    {
      'id': 'prd_iced_spanish_latte',
      'name': 'Iced Spanish Latte',
      'name_localized': 'سبانش لاتيه مثلّج',
      'description':
          'Double espresso over ice with fresh milk and sweetened condensed milk.',
      'description_localized':
          'جرعتان من الإسبريسو على الثلج مع الحليب الطازج والحليب المكثّف المحلّى.',
      'image': '${_unsplash}1461023058943-07fcbe16d735?w=600&q=70',
      'price': 16,
      'category_id': 'cat_cold',
      'modifiers': [
        {
          'modifier_id': 'mod_size',
          'minimum_options': 1,
          'maximum_options': 1,
          'free_options': 0,
          'unique_options': true,
          'default_options_ids': ['opt_medium'],
          'excluded_options_ids': [],
          'index': 0,
        },
        {
          'modifier_id': 'mod_milk',
          'minimum_options': 1,
          'maximum_options': 1,
          'free_options': 0,
          'unique_options': true,
          'default_options_ids': ['opt_full_milk'],
          'excluded_options_ids': [],
          'index': 1,
        },
        {
          'modifier_id': 'mod_syrup',
          'minimum_options': 0,
          'maximum_options': 3,
          'free_options': 1,
          'unique_options': false,
          'default_options_ids': [],
          'excluded_options_ids': [],
          'index': 2,
        },
        {
          'modifier_id': 'mod_extras',
          'minimum_options': 0,
          'maximum_options': 0,
          'free_options': 0,
          'unique_options': true,
          'default_options_ids': [],
          'excluded_options_ids': ['opt_cardamom', 'opt_saffron'],
          'index': 3,
        },
      ],
    },
    {
      'id': 'prd_mint_lemonade',
      'name': 'Fresh Mint Lemonade',
      'name_localized': 'ليموناضة بالنعناع الطازج',
      'description':
          'Freshly squeezed lemons blended with mint leaves and ice.',
      'description_localized':
          'ليمون معصور طازجًا يُخلط مع أوراق النعناع والثلج.',
      'image': '${_unsplash}1513558161293-cdaf765ed2fd?w=600&q=70',
      'price': 14,
      'category_id': 'cat_cold',
      'modifiers': [
        {
          'modifier_id': 'mod_sugar',
          'minimum_options': 1,
          'maximum_options': 1,
          'free_options': 0,
          'unique_options': true,
          'default_options_ids': [],
          'excluded_options_ids': [],
          'index': 0,
        },
      ],
    },
    {
      'id': 'prd_kunafa',
      'name': 'Kunafa with Cream',
      'name_localized': 'كنافة بالقشطة',
      'description':
          'Crispy kataifi pastry filled with ashta cream, finished with pistachio and syrup.',
      'description_localized':
          'عجينة كنافة مقرمشة محشوّة بالقشطة، تُزيَّن بالفستق وتُسقى بالقطر.',
      'image': '${_unsplash}1598110750624-207050c4f28c?w=600&q=70',
      'price': 25,
      'category_id': 'cat_desserts',
      'modifiers': [
        {
          'modifier_id': 'mod_toppings',
          'minimum_options': 0,
          'maximum_options': 0,
          'free_options': 0,
          'unique_options': true,
          'default_options_ids': [],
          'excluded_options_ids': [],
          'index': 0,
        },
      ],
    },
    {
      'id': 'prd_date_cake',
      'name': 'Sticky Date Cake',
      'name_localized': 'كيكة التمر بالتوفي',
      'description':
          'Warm Sukkari date sponge with toffee sauce. Baked fresh every morning.',
      'description_localized':
          'كيكة إسفنجية دافئة بتمر السكري مع صلصة التوفي، تُخبز طازجة كل صباح.',
      'image': '${_unsplash}1606313564200-e75d5e30476c?w=600&q=70',
      'price': 21,
      'category_id': 'cat_desserts',
      'modifiers': [],
    },
    {
      'id': 'prd_water',
      'name': 'Mineral Water',
      'name_localized': 'مياه معدنية',
      'description': '330 ml bottle.',
      'description_localized': 'عبوة ٣٣٠ مل.',
      'image': null,
      'price': 2,
      'category_id': null,
      'modifiers': [],
    },
  ];
}
