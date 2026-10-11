/// Network of a card number, detected from its leading digits. Display only:
/// the server validates and routes the payment.
enum CardBrand {
  mada,
  visa,
  mastercard,
  amex,
  unknown;

  static CardBrand of(String digits) {
    if (digits.isEmpty) return unknown;
    // mada BINs overlap Visa / Mastercard ranges, so check them first.
    if (digits.length >= 6 && _madaBins.contains(digits.substring(0, 6))) {
      return mada;
    }
    if (digits.startsWith('4')) return visa;
    if (digits.startsWith('34') || digits.startsWith('37')) return amex;
    if (digits.length >= 2) {
      final two = int.parse(digits.substring(0, 2));
      if (two >= 51 && two <= 55) return mastercard;
    }
    if (digits.length >= 4) {
      final four = int.parse(digits.substring(0, 4));
      if (four >= 2221 && four <= 2720) return mastercard;
    }
    return unknown;
  }

  /// Common Saudi mada BINs.
  static const Set<String> _madaBins = {
    '400861',
    '401757',
    '407197',
    '407395',
    '409201',
    '410621',
    '410685',
    '412565',
    '417633',
    '419593',
    '420132',
    '421141',
    '422817',
    '422818',
    '422819',
    '428331',
    '428671',
    '428672',
    '428673',
    '431361',
    '432328',
    '434107',
    '439954',
    '440533',
    '440647',
    '440795',
    '445564',
    '446393',
    '446404',
    '446672',
    '455036',
    '455708',
    '457865',
    '458456',
    '462220',
    '468540',
    '468541',
    '468542',
    '468543',
    '474491',
    '483010',
    '483011',
    '483012',
    '484783',
    '486094',
    '486095',
    '486096',
    '489317',
    '489318',
    '489319',
    '504300',
    '508160',
    '513213',
    '520058',
    '521076',
    '524130',
    '524514',
    '529415',
    '529741',
    '530060',
    '530906',
    '531095',
    '531196',
    '532013',
    '535825',
    '535989',
    '536023',
    '537767',
    '543085',
    '543357',
    '549760',
    '554180',
    '585265',
    '588845',
    '588848',
    '588850',
    '588982',
    '588983',
    '589005',
    '589206',
    '604906',
    '605141',
    '636120',
    '968201',
    '968202',
    '968203',
    '968204',
    '968205',
    '968206',
    '968207',
    '968208',
    '968209',
    '968210',
    '968211',
  };
}
