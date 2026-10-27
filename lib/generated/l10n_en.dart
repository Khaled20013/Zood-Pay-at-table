// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Zood Pay-At-Table';

  @override
  String get switchLanguageLabel => 'العربية';

  @override
  String get switchLanguageTooltip => 'Switch to Arabic';

  @override
  String get tryAgain => 'Try again';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get close => 'Close';

  @override
  String get undo => 'Undo';

  @override
  String get errorNetwork =>
      'We couldn\'t reach the restaurant. Check your connection and try again.';

  @override
  String get errorUnexpected => 'Something went wrong, please try again.';

  @override
  String get welcomeTitle => 'Scan the QR code on your table';

  @override
  String get welcomeBody =>
      'Point your camera at the code on the table stand. The link opens your table here in the app, ready to order and pay.';

  @override
  String get welcomeLinkHint => 'Paste table link or code';

  @override
  String get welcomeOpenTable => 'Open table';

  @override
  String get welcomeInvalidLink =>
      'That doesn\'t look like a table link or code.';

  @override
  String get notFoundTitle => 'This link has expired';

  @override
  String get notFoundMessage =>
      'The page you opened is no longer available. Scan the QR code on your table to start again.';

  @override
  String get notFoundAction => 'Go to start';

  @override
  String get scanNotFoundTitle => 'We couldn\'t find this table';

  @override
  String get backToScan => 'Back to scan';

  @override
  String get useAnotherTableLink => 'Use another table link';

  @override
  String get findingTable => 'Finding your table…';

  @override
  String get welcomeTo => 'Welcome to';

  @override
  String tableNumber(String number) {
    return 'Table $number';
  }

  @override
  String get tableLabel => 'TABLE';

  @override
  String get sessionOpen => 'Session open';

  @override
  String get openNow => 'Open now';

  @override
  String get dineIn => 'Dine-in';

  @override
  String get scanCardTitle => 'Order & pay from your seat';

  @override
  String get scanCardSubtitle => 'No waiting for the waiter or the bill.';

  @override
  String get stepBrowseTitle => 'Browse the menu';

  @override
  String get stepBrowseSubtitle =>
      'Live prices and add-ons from the restaurant';

  @override
  String get stepKitchenTitle => 'Send your order to the kitchen';

  @override
  String get stepKitchenSubtitle => 'Served straight to your table';

  @override
  String get stepPayTitle => 'Pay securely';

  @override
  String get stepPaySubtitle => 'mada, Visa or Mastercard';

  @override
  String get viewMenuAndOrder => 'View menu & order';

  @override
  String get allCategory => 'All';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'No items',
    );
    return '$_temp0';
  }

  @override
  String get searchHint => 'Search drinks, desserts…';

  @override
  String get clearSearch => 'Clear search';

  @override
  String itemAdded(String name) {
    return '$name added';
  }

  @override
  String get menuLoadFailedTitle => 'Menu didn\'t load';

  @override
  String get menuEmptyTitle => 'The menu is being updated';

  @override
  String get menuEmptyMessage =>
      'No items are available to order right now. Please ask a staff member.';

  @override
  String get noMatchesTitle => 'No matches';

  @override
  String noItemsInCategory(String category) {
    return 'Nothing in $category right now.';
  }

  @override
  String noItemsMatchQuery(String query) {
    return 'Nothing on the menu matches “$query”.';
  }

  @override
  String get showFullMenu => 'Show full menu';

  @override
  String orderForTable(String number) {
    return 'Order for Table $number';
  }

  @override
  String calories(int count) {
    return '$count kcal';
  }

  @override
  String addProduct(String name) {
    return 'Add $name';
  }

  @override
  String get popular => 'Popular';

  @override
  String get soldOut => 'Sold out';

  @override
  String get optional => 'Optional';

  @override
  String get specialInstructions => 'Special instructions';

  @override
  String get specialInstructionsHint => 'e.g. Extra hot, no cinnamon';

  @override
  String get addToOrder => 'Add to order';

  @override
  String get viewYourOrder => 'View your order';

  @override
  String get yourOrder => 'Your order';

  @override
  String get clearAll => 'Clear all';

  @override
  String itemRemoved(String name) {
    return '$name removed';
  }

  @override
  String get addNote => 'Add note';

  @override
  String noteFor(String name) {
    return 'Note for $name';
  }

  @override
  String get noteHint => 'e.g. No ice, serve with the main course';

  @override
  String get checkout => 'Checkout';

  @override
  String get cartEmptyTitle => 'Your order is empty';

  @override
  String get cartEmptyMessage => 'Tap + on any item to add it here.';

  @override
  String get removeItem => 'Remove';

  @override
  String get decreaseQuantity => 'Decrease quantity';

  @override
  String get increaseQuantity => 'Increase quantity';

  @override
  String get reviewAndPay => 'Review & pay';

  @override
  String get checkoutEmptyMessage =>
      'Add something from the menu to check out.';

  @override
  String get browseMenu => 'Browse menu';

  @override
  String get itemsSection => 'Items';

  @override
  String get summarySection => 'Summary';

  @override
  String get subtotalExclVat => 'Subtotal (excl. VAT)';

  @override
  String vatRate(int rate) {
    return 'VAT $rate%';
  }

  @override
  String get total => 'Total';

  @override
  String get processing => 'Processing…';

  @override
  String get paymentMethodMada => 'mada';

  @override
  String get paymentMethodCard => 'Credit / Debit Card';

  @override
  String get securePayment => 'Secure payment';

  @override
  String get orderSentTitle => 'Order placed';

  @override
  String get orderSentMessage => 'Please wait until your order is ready.';

  @override
  String get orderLabel => 'ORDER';

  @override
  String get paid => 'Paid';

  @override
  String get method => 'Method';

  @override
  String get time => 'Time';

  @override
  String get orderSomethingElse => 'Order something else';

  @override
  String get splashStepScan => 'Scan';

  @override
  String get splashStepOrder => 'Order';

  @override
  String get splashStepPay => 'Pay';

  @override
  String get poweredByZoodPos => 'Part of the ZoodPOS ecosystem';

  @override
  String get landingHeadline => 'Order & pay right from your table';

  @override
  String get landingSubtitle =>
      'Scan the QR code on your table to browse the live menu, send your order to the kitchen and settle the bill. No waiting, no account.';

  @override
  String get landingHowItWorks => 'How it works';

  @override
  String get landingStart => 'Start ordering';

  @override
  String get landingChipKitchen => 'Sent to kitchen';

  @override
  String get landingChipPaid => 'Paid by card';

  @override
  String get landingIllustrationLabel =>
      'A phone showing a table\'s menu, with the order sent to the kitchen and paid';

  @override
  String get stepScanTitle => 'Scan the table QR';

  @override
  String get stepScanSubtitle => 'Your table opens instantly on your phone';

  @override
  String get orderTrackerTitle => 'Order status';

  @override
  String get orderStepPaidTitle => 'Payment confirmed';

  @override
  String get orderStepKitchenTitle => 'Preparing in the kitchen';

  @override
  String get orderStepKitchenSubtitle => 'The kitchen is preparing your order';

  @override
  String get orderStepServeTitle => 'Served to your table';

  @override
  String orderStepServeSubtitle(String table) {
    return 'A staff member brings it to Table $table';
  }

  @override
  String orderSuccessLabel(String number) {
    return 'Order $number placed and paid';
  }

  @override
  String get errorQrNotFound => 'QR code not found';

  @override
  String get errorTableUnavailable => 'Ordering is unavailable at this table';

  @override
  String get errorCardDeclined => 'Your card was declined.';

  @override
  String get errorOrderRejected =>
      'Some items in your order are no longer available. Please review your order.';

  @override
  String get errorTooManyAttempts =>
      'Too many attempts, please wait and try again.';

  @override
  String get askStaffForHelp => 'Please ask a staff member for help.';

  @override
  String get vatAddedAtCheckout => 'VAT added at checkout';

  @override
  String get required => 'Required';

  @override
  String get done => 'Done';

  @override
  String get modifierChooseOne => 'Choose 1';

  @override
  String get modifierChooseAny => 'Choose any';

  @override
  String modifierChooseUpTo(int count) {
    return 'Choose up to $count';
  }

  @override
  String modifierChooseAtLeast(int count) {
    return 'Choose at least $count';
  }

  @override
  String modifierChooseExactly(int count) {
    return 'Choose $count';
  }

  @override
  String modifierChooseBetween(int min, int max) {
    return 'Choose $min–$max';
  }

  @override
  String modifierFreeUnits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'first $count free',
      one: 'first one free',
    );
    return '$_temp0';
  }

  @override
  String chooseModifier(String name) {
    return 'Choose $name';
  }

  @override
  String get subtotal => 'Subtotal';

  @override
  String get vat => 'VAT';

  @override
  String get orderNotesSection => 'Order notes';

  @override
  String get orderNotesHint =>
      'Anything the restaurant should know? (optional)';

  @override
  String get cardSection => 'Card details';

  @override
  String get cardNumber => 'Card number';

  @override
  String get cardExpiry => 'Expiry';

  @override
  String get cardCvc => 'CVC';

  @override
  String get cardHolderName => 'Name on card';

  @override
  String get cardNumberInvalid => 'Enter a valid card number';

  @override
  String get cardExpiryInvalid => 'Enter a valid expiry date';

  @override
  String get cardCvcInvalid => '3–4 digits';

  @override
  String get cardHolderNameInvalid => 'Enter the name on the card';

  @override
  String get cardSecureNotice =>
      'Your card is sent securely to the payment gateway and is never stored on this device.';

  @override
  String get demoCardHint =>
      'Demo mode: nothing is charged. Use 4000 0000 0000 0002 to try a declined card.';

  @override
  String get totalConfirmedByServer =>
      'The final amount is confirmed when you pay.';

  @override
  String get payNow => 'Pay now';

  @override
  String cardEndingIn(String last4) {
    return 'Card •••• $last4';
  }

  @override
  String get reference => 'Reference';

  @override
  String get cardCvcBackHint =>
      'The security code is the 3–4 digits on the back of your card';

  @override
  String get serviceUnavailableTitle => 'Table ordering isn\'t available yet';

  @override
  String get errorServiceUnavailable =>
      'This service is still being set up. Please try again later or ask a staff member.';

  @override
  String get networkErrorTitle => 'No connection';

  @override
  String get shareReceipt => 'Share receipt';

  @override
  String get copyReceipt => 'Copy receipt';

  @override
  String get receiptCopied => 'Receipt copied';

  @override
  String receiptShareText(
    String branch,
    String table,
    String number,
    String total,
  ) {
    return '$branch · Table $table\nOrder #$number\nTotal: $total';
  }

  @override
  String get scanQrCode => 'Scan QR code';

  @override
  String get scanAnotherTable => 'Scan another table';

  @override
  String get scanAgain => 'Scan again';

  @override
  String get scanHint => 'Point the camera at the QR code on your table';

  @override
  String get scanInvalidCode =>
      'This isn\'t a Zood table code. Try another one.';

  @override
  String get scanCameraDeniedTitle => 'Camera access is off';

  @override
  String get scanCameraDeniedMessage =>
      'Allow camera access in your settings, or enter the table link instead.';

  @override
  String get scanCameraUnavailableTitle => 'The camera can\'t be used';

  @override
  String get scanCameraUnavailableMessage => 'Enter the table link instead.';

  @override
  String get scanEnterLink => 'Enter the link instead';

  @override
  String get scanTorch => 'Flash';
}
