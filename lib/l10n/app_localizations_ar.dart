// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'زود - الدفع على الطاولة';

  @override
  String get switchLanguageLabel => 'English';

  @override
  String get switchLanguageTooltip => 'التبديل إلى الإنجليزية';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get close => 'إغلاق';

  @override
  String get undo => 'تراجع';

  @override
  String get errorNetwork =>
      'تعذّر الاتصال بالمطعم. تحقّق من اتصالك بالإنترنت ثم حاول مرة أخرى.';

  @override
  String get errorUnexpected => 'حدث خطأ ما، يُرجى المحاولة مرة أخرى.';

  @override
  String get welcomeTitle => 'امسح رمز QR الموجود على طاولتك';

  @override
  String get welcomeBody =>
      'وجّه كاميرا هاتفك نحو الرمز الموجود على حامل الطاولة، وسيفتح الرابط طاولتك هنا في التطبيق جاهزةً للطلب والدفع.';

  @override
  String get welcomeLinkHint => 'الصق رابط الطاولة أو رمزها';

  @override
  String get welcomeOpenTable => 'افتح الطاولة';

  @override
  String get welcomeInvalidLink =>
      'يبدو أن هذا ليس رابط طاولة أو رمزًا صحيحًا.';

  @override
  String get welcomeDemoTable => 'افتح الطاولة التجريبية';

  @override
  String get notFoundTitle => 'انتهت صلاحية هذا الرابط';

  @override
  String get notFoundMessage =>
      'الصفحة التي فتحتها لم تعد متاحة. امسح رمز QR الموجود على طاولتك للبدء من جديد.';

  @override
  String get notFoundAction => 'العودة إلى البداية';

  @override
  String get scanNotFoundTitle => 'تعذّر العثور على هذه الطاولة';

  @override
  String get backToScan => 'العودة إلى المسح';

  @override
  String get findingTable => 'جارٍ البحث عن طاولتك…';

  @override
  String get welcomeTo => 'مرحبًا بك في';

  @override
  String tableNumber(String number) {
    return 'طاولة $number';
  }

  @override
  String get tableLabel => 'طاولة';

  @override
  String get sessionOpen => 'الجلسة مفتوحة';

  @override
  String get openNow => 'مفتوح الآن';

  @override
  String get dineIn => 'تناول في المطعم';

  @override
  String get scanCardTitle => 'اطلب وادفع من مقعدك';

  @override
  String get scanCardSubtitle => 'دون انتظار النادل أو الفاتورة.';

  @override
  String get stepBrowseTitle => 'تصفّح قائمة الطعام';

  @override
  String get stepBrowseSubtitle => 'أسعار محدّثة وإضافات مباشرة من المطعم';

  @override
  String get stepKitchenTitle => 'أرسل طلبك إلى المطبخ';

  @override
  String get stepKitchenSubtitle => 'يُقدَّم إليك مباشرةً على طاولتك';

  @override
  String get stepPayTitle => 'ادفع بأمان';

  @override
  String get stepPaySubtitle => 'مدى أو فيزا أو ماستركارد';

  @override
  String get viewMenuAndOrder => 'اعرض القائمة واطلب';

  @override
  String get allCategory => 'الكل';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count صنف',
      many: '$count صنفًا',
      few: '$count أصناف',
      two: 'صنفان',
      one: 'صنف واحد',
      zero: 'لا توجد أصناف',
    );
    return '$_temp0';
  }

  @override
  String get searchHint => 'ابحث عن المشروبات والحلويات…';

  @override
  String get clearSearch => 'مسح البحث';

  @override
  String itemAdded(String name) {
    return 'تمت إضافة $name';
  }

  @override
  String get customize => 'تخصيص';

  @override
  String get menuLoadFailedTitle => 'تعذّر تحميل القائمة';

  @override
  String get menuEmptyTitle => 'جارٍ تحديث القائمة';

  @override
  String get menuEmptyMessage =>
      'لا توجد أصناف متاحة للطلب حاليًا. يُرجى التواصل مع أحد الموظفين.';

  @override
  String get noMatchesTitle => 'لا توجد نتائج';

  @override
  String noItemsInCategory(String category) {
    return 'لا توجد أصناف في $category حاليًا.';
  }

  @override
  String noItemsMatchQuery(String query) {
    return 'لا يوجد في القائمة ما يطابق «$query».';
  }

  @override
  String get showFullMenu => 'اعرض القائمة كاملة';

  @override
  String orderForTable(String number) {
    return 'طلب الطاولة $number';
  }

  @override
  String calories(int count) {
    return '$count سعرة';
  }

  @override
  String addProduct(String name) {
    return 'أضف $name';
  }

  @override
  String get popular => 'الأكثر طلبًا';

  @override
  String get soldOut => 'نفدت الكمية';

  @override
  String get optional => 'اختياري';

  @override
  String get specialInstructions => 'تعليمات خاصة';

  @override
  String get specialInstructionsHint => 'مثال: ساخن جدًا، بدون قرفة';

  @override
  String get addToOrder => 'أضف إلى الطلب';

  @override
  String get viewYourOrder => 'اعرض طلبك';

  @override
  String get yourOrder => 'طلبك';

  @override
  String get clearAll => 'مسح الكل';

  @override
  String itemRemoved(String name) {
    return 'تمت إزالة $name';
  }

  @override
  String get addNote => 'أضف ملاحظة';

  @override
  String noteFor(String name) {
    return 'ملاحظة على $name';
  }

  @override
  String get noteHint => 'مثال: بدون ثلج، يُقدَّم مع الطبق الرئيسي';

  @override
  String get checkout => 'إتمام الطلب';

  @override
  String get cartEmptyTitle => 'طلبك فارغ';

  @override
  String get cartEmptyMessage => 'اضغط على + بجوار أي صنف لإضافته هنا.';

  @override
  String get removeItem => 'إزالة';

  @override
  String get decreaseQuantity => 'إنقاص الكمية';

  @override
  String get increaseQuantity => 'زيادة الكمية';

  @override
  String get reviewAndPay => 'المراجعة والدفع';

  @override
  String get checkoutEmptyMessage => 'أضف صنفًا من القائمة لإتمام الطلب.';

  @override
  String get browseMenu => 'تصفّح القائمة';

  @override
  String get itemsSection => 'الأصناف';

  @override
  String get summarySection => 'الملخّص';

  @override
  String get subtotalExclVat => 'المجموع الفرعي (غير شامل الضريبة)';

  @override
  String vatRate(int rate) {
    return 'ضريبة القيمة المضافة $rate%';
  }

  @override
  String get total => 'الإجمالي';

  @override
  String get processing => 'جارٍ المعالجة…';

  @override
  String get paymentMethodMada => 'مدى';

  @override
  String get paymentMethodCard => 'بطاقة ائتمان / خصم';

  @override
  String get securePayment => 'دفع آمن';

  @override
  String get orderSentTitle => 'تم استلام طلبك';

  @override
  String get orderSentMessage => 'يُرجى الانتظار حتى يصبح طلبك جاهزًا.';

  @override
  String get orderLabel => 'رقم الطلب';

  @override
  String get paid => 'المبلغ المدفوع';

  @override
  String get method => 'طريقة الدفع';

  @override
  String get time => 'الوقت';

  @override
  String get orderSomethingElse => 'اطلب شيئًا آخر';

  @override
  String get splashStepScan => 'امسح';

  @override
  String get splashStepOrder => 'اطلب';

  @override
  String get splashStepPay => 'ادفع';

  @override
  String get poweredByZoodPos => 'جزء من منظومة ZoodPOS';

  @override
  String get landingHeadline => 'اطلب وادفع من طاولتك مباشرةً';

  @override
  String get landingSubtitle =>
      'امسح رمز QR على طاولتك لتتصفّح القائمة المحدّثة، وترسل طلبك إلى المطبخ، وتدفع الفاتورة. بلا انتظار وبلا حساب.';

  @override
  String get landingHowItWorks => 'كيف يعمل؟';

  @override
  String get landingStart => 'ابدأ الطلب';

  @override
  String get landingChipKitchen => 'أُرسل إلى المطبخ';

  @override
  String get landingChipPaid => 'تم الدفع بالبطاقة';

  @override
  String get landingIllustrationLabel =>
      'هاتف يعرض قائمة الطاولة، مع إرسال الطلب إلى المطبخ ودفع الفاتورة';

  @override
  String get stepScanTitle => 'امسح رمز الطاولة';

  @override
  String get stepScanSubtitle => 'تُفتح طاولتك فورًا على هاتفك';

  @override
  String get orderTrackerTitle => 'حالة الطلب';

  @override
  String get orderStepPaidTitle => 'تم تأكيد الدفع';

  @override
  String get orderStepKitchenTitle => 'قيد التحضير في المطبخ';

  @override
  String get orderStepKitchenSubtitle => 'يقوم المطبخ بتحضير طلبك';

  @override
  String get orderStepServeTitle => 'يُقدَّم إلى طاولتك';

  @override
  String orderStepServeSubtitle(String table) {
    return 'سيحضره أحد الموظفين إلى الطاولة $table';
  }

  @override
  String orderSuccessLabel(String number) {
    return 'تم استلام الطلب رقم $number ودفعه';
  }

  @override
  String get errorQrNotFound => 'رمز QR غير موجود';

  @override
  String get errorTableUnavailable => 'الطلب غير متاح على هذه الطاولة';

  @override
  String get errorCardDeclined => 'تم رفض بطاقتك.';

  @override
  String get errorOrderRejected =>
      'بعض أصناف طلبك لم تعد متاحة. يُرجى مراجعة الطلب.';

  @override
  String get errorTooManyAttempts =>
      'محاولات كثيرة، يُرجى الانتظار ثم المحاولة مرة أخرى.';

  @override
  String get askStaffForHelp => 'يُرجى طلب المساعدة من أحد الموظفين.';

  @override
  String get vatAddedAtCheckout => 'تُضاف الضريبة عند الدفع';

  @override
  String get required => 'إلزامي';

  @override
  String get done => 'تم';

  @override
  String get modifierChooseOne => 'اختر واحدًا';

  @override
  String get modifierChooseAny => 'اختر ما تشاء';

  @override
  String modifierChooseUpTo(int count) {
    return 'اختر حتى $count';
  }

  @override
  String modifierChooseAtLeast(int count) {
    return 'اختر $count على الأقل';
  }

  @override
  String modifierChooseExactly(int count) {
    return 'اختر $count';
  }

  @override
  String modifierChooseBetween(int min, int max) {
    return 'اختر من $min إلى $max';
  }

  @override
  String modifierFreeUnits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'أول $count مجانًا',
      one: 'الأول مجانًا',
    );
    return '$_temp0';
  }

  @override
  String chooseModifier(String name) {
    return 'اختر $name';
  }

  @override
  String get subtotal => 'المجموع الفرعي';

  @override
  String get vat => 'ضريبة القيمة المضافة';

  @override
  String get orderNotesSection => 'ملاحظات الطلب';

  @override
  String get orderNotesHint => 'هل هناك ما يجب أن يعرفه المطعم؟ (اختياري)';

  @override
  String get cardSection => 'بيانات البطاقة';

  @override
  String get cardNumber => 'رقم البطاقة';

  @override
  String get cardExpiry => 'تاريخ الانتهاء';

  @override
  String get cardCvc => 'رمز التحقق CVC';

  @override
  String get cardHolderName => 'الاسم على البطاقة';

  @override
  String get cardNumberInvalid => 'أدخل رقم بطاقة صحيحًا';

  @override
  String get cardExpiryInvalid => 'أدخل تاريخ انتهاء صحيحًا';

  @override
  String get cardCvcInvalid => '3 أو 4 أرقام';

  @override
  String get cardHolderNameInvalid => 'أدخل الاسم المكتوب على البطاقة';

  @override
  String get cardSecureNotice =>
      'تُرسل بيانات بطاقتك بأمان إلى بوابة الدفع ولا تُحفظ على هذا الجهاز.';

  @override
  String get demoCardHint =>
      'وضع تجريبي: لن يُخصم أي مبلغ. استخدم 4000 0000 0000 0002 لتجربة بطاقة مرفوضة.';

  @override
  String get totalConfirmedByServer => 'يتم تأكيد المبلغ النهائي عند الدفع.';

  @override
  String get payNow => 'ادفع الآن';

  @override
  String cardEndingIn(String last4) {
    return 'بطاقة •••• $last4';
  }

  @override
  String get reference => 'المرجع';

  @override
  String get cardCvcBackHint =>
      'رمز التحقق هو آخر 3 أو 4 أرقام على ظهر البطاقة';
}
