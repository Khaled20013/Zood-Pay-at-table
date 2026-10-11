import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Zood Pay-At-Table'**
  String get appTitle;

  /// Shown on the language toggle: the name of the language it switches TO.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get switchLanguageLabel;

  /// No description provided for @switchLanguageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Switch to Arabic'**
  String get switchLanguageTooltip;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t reach the restaurant. Check your connection and try again.'**
  String get errorNetwork;

  /// No description provided for @errorUnexpected.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong, please try again.'**
  String get errorUnexpected;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR code on your table'**
  String get welcomeTitle;

  /// No description provided for @welcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Point your camera at the code on the table stand. The link opens your table here in the app, ready to order and pay.'**
  String get welcomeBody;

  /// No description provided for @welcomeLinkHint.
  ///
  /// In en, this message translates to:
  /// **'Paste table link or code'**
  String get welcomeLinkHint;

  /// No description provided for @welcomeOpenTable.
  ///
  /// In en, this message translates to:
  /// **'Open table'**
  String get welcomeOpenTable;

  /// No description provided for @welcomeInvalidLink.
  ///
  /// In en, this message translates to:
  /// **'That doesn\'t look like a table link or code.'**
  String get welcomeInvalidLink;

  /// No description provided for @welcomeDemoTable.
  ///
  /// In en, this message translates to:
  /// **'Open demo table'**
  String get welcomeDemoTable;

  /// No description provided for @notFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'This link has expired'**
  String get notFoundTitle;

  /// No description provided for @notFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'The page you opened is no longer available. Scan the QR code on your table to start again.'**
  String get notFoundMessage;

  /// No description provided for @notFoundAction.
  ///
  /// In en, this message translates to:
  /// **'Go to start'**
  String get notFoundAction;

  /// No description provided for @scanNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find this table'**
  String get scanNotFoundTitle;

  /// No description provided for @backToScan.
  ///
  /// In en, this message translates to:
  /// **'Back to scan'**
  String get backToScan;

  /// No description provided for @findingTable.
  ///
  /// In en, this message translates to:
  /// **'Finding your table…'**
  String get findingTable;

  /// No description provided for @welcomeTo.
  ///
  /// In en, this message translates to:
  /// **'Welcome to'**
  String get welcomeTo;

  /// No description provided for @tableNumber.
  ///
  /// In en, this message translates to:
  /// **'Table {number}'**
  String tableNumber(String number);

  /// No description provided for @tableLabel.
  ///
  /// In en, this message translates to:
  /// **'TABLE'**
  String get tableLabel;

  /// No description provided for @sessionOpen.
  ///
  /// In en, this message translates to:
  /// **'Session open'**
  String get sessionOpen;

  /// No description provided for @openNow.
  ///
  /// In en, this message translates to:
  /// **'Open now'**
  String get openNow;

  /// No description provided for @dineIn.
  ///
  /// In en, this message translates to:
  /// **'Dine-in'**
  String get dineIn;

  /// No description provided for @scanCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Order & pay from your seat'**
  String get scanCardTitle;

  /// No description provided for @scanCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No waiting for the waiter or the bill.'**
  String get scanCardSubtitle;

  /// No description provided for @stepBrowseTitle.
  ///
  /// In en, this message translates to:
  /// **'Browse the menu'**
  String get stepBrowseTitle;

  /// No description provided for @stepBrowseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Live prices and add-ons from the restaurant'**
  String get stepBrowseSubtitle;

  /// No description provided for @stepKitchenTitle.
  ///
  /// In en, this message translates to:
  /// **'Send your order to the kitchen'**
  String get stepKitchenTitle;

  /// No description provided for @stepKitchenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Served straight to your table'**
  String get stepKitchenSubtitle;

  /// No description provided for @stepPayTitle.
  ///
  /// In en, this message translates to:
  /// **'Pay securely'**
  String get stepPayTitle;

  /// No description provided for @stepPaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'mada, Visa or Mastercard'**
  String get stepPaySubtitle;

  /// No description provided for @viewMenuAndOrder.
  ///
  /// In en, this message translates to:
  /// **'View menu & order'**
  String get viewMenuAndOrder;

  /// No description provided for @allCategory.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allCategory;

  /// No description provided for @itemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No items} =1{1 item} other{{count} items}}'**
  String itemCount(int count);

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search drinks, desserts…'**
  String get searchHint;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @itemAdded.
  ///
  /// In en, this message translates to:
  /// **'{name} added'**
  String itemAdded(String name);

  /// No description provided for @customize.
  ///
  /// In en, this message translates to:
  /// **'Customize'**
  String get customize;

  /// No description provided for @menuLoadFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Menu didn\'t load'**
  String get menuLoadFailedTitle;

  /// No description provided for @menuEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'The menu is being updated'**
  String get menuEmptyTitle;

  /// No description provided for @menuEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'No items are available to order right now. Please ask a staff member.'**
  String get menuEmptyMessage;

  /// No description provided for @noMatchesTitle.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get noMatchesTitle;

  /// No description provided for @noItemsInCategory.
  ///
  /// In en, this message translates to:
  /// **'Nothing in {category} right now.'**
  String noItemsInCategory(String category);

  /// No description provided for @noItemsMatchQuery.
  ///
  /// In en, this message translates to:
  /// **'Nothing on the menu matches “{query}”.'**
  String noItemsMatchQuery(String query);

  /// No description provided for @showFullMenu.
  ///
  /// In en, this message translates to:
  /// **'Show full menu'**
  String get showFullMenu;

  /// No description provided for @orderForTable.
  ///
  /// In en, this message translates to:
  /// **'Order for Table {number}'**
  String orderForTable(String number);

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'{count} kcal'**
  String calories(int count);

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add {name}'**
  String addProduct(String name);

  /// No description provided for @popular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// No description provided for @soldOut.
  ///
  /// In en, this message translates to:
  /// **'Sold out'**
  String get soldOut;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @specialInstructions.
  ///
  /// In en, this message translates to:
  /// **'Special instructions'**
  String get specialInstructions;

  /// No description provided for @specialInstructionsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Extra hot, no cinnamon'**
  String get specialInstructionsHint;

  /// No description provided for @addToOrder.
  ///
  /// In en, this message translates to:
  /// **'Add to order'**
  String get addToOrder;

  /// No description provided for @viewYourOrder.
  ///
  /// In en, this message translates to:
  /// **'View your order'**
  String get viewYourOrder;

  /// No description provided for @yourOrder.
  ///
  /// In en, this message translates to:
  /// **'Your order'**
  String get yourOrder;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @itemRemoved.
  ///
  /// In en, this message translates to:
  /// **'{name} removed'**
  String itemRemoved(String name);

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get addNote;

  /// No description provided for @noteFor.
  ///
  /// In en, this message translates to:
  /// **'Note for {name}'**
  String noteFor(String name);

  /// No description provided for @noteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. No ice, serve with the main course'**
  String get noteHint;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @cartEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your order is empty'**
  String get cartEmptyTitle;

  /// No description provided for @cartEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Tap + on any item to add it here.'**
  String get cartEmptyMessage;

  /// No description provided for @removeItem.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeItem;

  /// No description provided for @decreaseQuantity.
  ///
  /// In en, this message translates to:
  /// **'Decrease quantity'**
  String get decreaseQuantity;

  /// No description provided for @increaseQuantity.
  ///
  /// In en, this message translates to:
  /// **'Increase quantity'**
  String get increaseQuantity;

  /// No description provided for @reviewAndPay.
  ///
  /// In en, this message translates to:
  /// **'Review & pay'**
  String get reviewAndPay;

  /// No description provided for @checkoutEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add something from the menu to check out.'**
  String get checkoutEmptyMessage;

  /// No description provided for @browseMenu.
  ///
  /// In en, this message translates to:
  /// **'Browse menu'**
  String get browseMenu;

  /// No description provided for @itemsSection.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get itemsSection;

  /// No description provided for @summarySection.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summarySection;

  /// No description provided for @subtotalExclVat.
  ///
  /// In en, this message translates to:
  /// **'Subtotal (excl. VAT)'**
  String get subtotalExclVat;

  /// No description provided for @vatRate.
  ///
  /// In en, this message translates to:
  /// **'VAT {rate}%'**
  String vatRate(int rate);

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing…'**
  String get processing;

  /// No description provided for @paymentMethodMada.
  ///
  /// In en, this message translates to:
  /// **'mada'**
  String get paymentMethodMada;

  /// No description provided for @paymentMethodCard.
  ///
  /// In en, this message translates to:
  /// **'Credit / Debit Card'**
  String get paymentMethodCard;

  /// No description provided for @securePayment.
  ///
  /// In en, this message translates to:
  /// **'Secure payment'**
  String get securePayment;

  /// No description provided for @orderSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Order placed'**
  String get orderSentTitle;

  /// No description provided for @orderSentMessage.
  ///
  /// In en, this message translates to:
  /// **'Please wait until your order is ready.'**
  String get orderSentMessage;

  /// No description provided for @orderLabel.
  ///
  /// In en, this message translates to:
  /// **'ORDER'**
  String get orderLabel;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @method.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get method;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @orderSomethingElse.
  ///
  /// In en, this message translates to:
  /// **'Order something else'**
  String get orderSomethingElse;

  /// No description provided for @splashStepScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get splashStepScan;

  /// No description provided for @splashStepOrder.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get splashStepOrder;

  /// No description provided for @splashStepPay.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get splashStepPay;

  /// No description provided for @poweredByZoodPos.
  ///
  /// In en, this message translates to:
  /// **'Part of the ZoodPOS ecosystem'**
  String get poweredByZoodPos;

  /// No description provided for @landingHeadline.
  ///
  /// In en, this message translates to:
  /// **'Order & pay right from your table'**
  String get landingHeadline;

  /// No description provided for @landingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR code on your table to browse the live menu, send your order to the kitchen and settle the bill. No waiting, no account.'**
  String get landingSubtitle;

  /// No description provided for @landingHowItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get landingHowItWorks;

  /// No description provided for @landingStart.
  ///
  /// In en, this message translates to:
  /// **'Start ordering'**
  String get landingStart;

  /// No description provided for @landingChipKitchen.
  ///
  /// In en, this message translates to:
  /// **'Sent to kitchen'**
  String get landingChipKitchen;

  /// No description provided for @landingChipPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid by card'**
  String get landingChipPaid;

  /// No description provided for @landingIllustrationLabel.
  ///
  /// In en, this message translates to:
  /// **'A phone showing a table\'s menu, with the order sent to the kitchen and paid'**
  String get landingIllustrationLabel;

  /// No description provided for @stepScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan the table QR'**
  String get stepScanTitle;

  /// No description provided for @stepScanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your table opens instantly on your phone'**
  String get stepScanSubtitle;

  /// No description provided for @orderTrackerTitle.
  ///
  /// In en, this message translates to:
  /// **'Order status'**
  String get orderTrackerTitle;

  /// No description provided for @orderStepPaidTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment confirmed'**
  String get orderStepPaidTitle;

  /// No description provided for @orderStepKitchenTitle.
  ///
  /// In en, this message translates to:
  /// **'Preparing in the kitchen'**
  String get orderStepKitchenTitle;

  /// No description provided for @orderStepKitchenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The kitchen is preparing your order'**
  String get orderStepKitchenSubtitle;

  /// No description provided for @orderStepServeTitle.
  ///
  /// In en, this message translates to:
  /// **'Served to your table'**
  String get orderStepServeTitle;

  /// No description provided for @orderStepServeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A staff member brings it to Table {table}'**
  String orderStepServeSubtitle(String table);

  /// No description provided for @orderSuccessLabel.
  ///
  /// In en, this message translates to:
  /// **'Order {number} placed and paid'**
  String orderSuccessLabel(String number);

  /// No description provided for @errorQrNotFound.
  ///
  /// In en, this message translates to:
  /// **'QR code not found'**
  String get errorQrNotFound;

  /// No description provided for @errorTableUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Ordering is unavailable at this table'**
  String get errorTableUnavailable;

  /// No description provided for @errorCardDeclined.
  ///
  /// In en, this message translates to:
  /// **'Your card was declined.'**
  String get errorCardDeclined;

  /// No description provided for @errorOrderRejected.
  ///
  /// In en, this message translates to:
  /// **'Some items in your order are no longer available. Please review your order.'**
  String get errorOrderRejected;

  /// No description provided for @errorTooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts, please wait and try again.'**
  String get errorTooManyAttempts;

  /// No description provided for @askStaffForHelp.
  ///
  /// In en, this message translates to:
  /// **'Please ask a staff member for help.'**
  String get askStaffForHelp;

  /// No description provided for @vatAddedAtCheckout.
  ///
  /// In en, this message translates to:
  /// **'VAT added at checkout'**
  String get vatAddedAtCheckout;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @modifierChooseOne.
  ///
  /// In en, this message translates to:
  /// **'Choose 1'**
  String get modifierChooseOne;

  /// No description provided for @modifierChooseAny.
  ///
  /// In en, this message translates to:
  /// **'Choose any'**
  String get modifierChooseAny;

  /// No description provided for @modifierChooseUpTo.
  ///
  /// In en, this message translates to:
  /// **'Choose up to {count}'**
  String modifierChooseUpTo(int count);

  /// No description provided for @modifierChooseAtLeast.
  ///
  /// In en, this message translates to:
  /// **'Choose at least {count}'**
  String modifierChooseAtLeast(int count);

  /// No description provided for @modifierChooseExactly.
  ///
  /// In en, this message translates to:
  /// **'Choose {count}'**
  String modifierChooseExactly(int count);

  /// No description provided for @modifierChooseBetween.
  ///
  /// In en, this message translates to:
  /// **'Choose {min}–{max}'**
  String modifierChooseBetween(int min, int max);

  /// No description provided for @modifierFreeUnits.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{first one free} other{first {count} free}}'**
  String modifierFreeUnits(int count);

  /// No description provided for @chooseModifier.
  ///
  /// In en, this message translates to:
  /// **'Choose {name}'**
  String chooseModifier(String name);

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @vat.
  ///
  /// In en, this message translates to:
  /// **'VAT'**
  String get vat;

  /// No description provided for @orderNotesSection.
  ///
  /// In en, this message translates to:
  /// **'Order notes'**
  String get orderNotesSection;

  /// No description provided for @orderNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Anything the restaurant should know? (optional)'**
  String get orderNotesHint;

  /// No description provided for @cardSection.
  ///
  /// In en, this message translates to:
  /// **'Card details'**
  String get cardSection;

  /// No description provided for @cardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card number'**
  String get cardNumber;

  /// No description provided for @cardExpiry.
  ///
  /// In en, this message translates to:
  /// **'Expiry'**
  String get cardExpiry;

  /// No description provided for @cardCvc.
  ///
  /// In en, this message translates to:
  /// **'CVC'**
  String get cardCvc;

  /// No description provided for @cardHolderName.
  ///
  /// In en, this message translates to:
  /// **'Name on card'**
  String get cardHolderName;

  /// No description provided for @cardNumberInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid card number'**
  String get cardNumberInvalid;

  /// No description provided for @cardExpiryInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid expiry date'**
  String get cardExpiryInvalid;

  /// No description provided for @cardCvcInvalid.
  ///
  /// In en, this message translates to:
  /// **'3–4 digits'**
  String get cardCvcInvalid;

  /// No description provided for @cardHolderNameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter the name on the card'**
  String get cardHolderNameInvalid;

  /// No description provided for @cardSecureNotice.
  ///
  /// In en, this message translates to:
  /// **'Your card is sent securely to the payment gateway and is never stored on this device.'**
  String get cardSecureNotice;

  /// No description provided for @demoCardHint.
  ///
  /// In en, this message translates to:
  /// **'Demo mode: nothing is charged. Use 4000 0000 0000 0002 to try a declined card.'**
  String get demoCardHint;

  /// No description provided for @totalConfirmedByServer.
  ///
  /// In en, this message translates to:
  /// **'The final amount is confirmed when you pay.'**
  String get totalConfirmedByServer;

  /// No description provided for @payNow.
  ///
  /// In en, this message translates to:
  /// **'Pay now'**
  String get payNow;

  /// No description provided for @cardEndingIn.
  ///
  /// In en, this message translates to:
  /// **'Card •••• {last4}'**
  String cardEndingIn(String last4);

  /// No description provided for @reference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get reference;

  /// No description provided for @cardCvcBackHint.
  ///
  /// In en, this message translates to:
  /// **'The security code is the 3–4 digits on the back of your card'**
  String get cardCvcBackHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
