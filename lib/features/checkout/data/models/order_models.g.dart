// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$OrderRequestModelToJson(OrderRequestModel instance) =>
    <String, dynamic>{
      'qr_id': instance.qrId,
      'client_order_id': instance.clientOrderId,
      'customer_notes': instance.customerNotes,
      'products': instance.products.map((e) => e.toJson()).toList(),
      'card': instance.card.toJson(),
    };

Map<String, dynamic> _$OrderProductModelToJson(OrderProductModel instance) =>
    <String, dynamic>{
      'product_id': instance.productId,
      'quantity': instance.quantity,
      'notes': instance.notes,
      'options': instance.options.map((e) => e.toJson()).toList(),
    };

Map<String, dynamic> _$OrderOptionModelToJson(OrderOptionModel instance) =>
    <String, dynamic>{
      'modifier_option_id': instance.modifierOptionId,
      'quantity': instance.quantity,
    };

Map<String, dynamic> _$CardModelToJson(CardModel instance) => <String, dynamic>{
  'holder_name': instance.holderName,
  'number': instance.number,
  'expiry_month': instance.expiryMonth,
  'expiry_year': instance.expiryYear,
  'cvc': instance.cvc,
};

OrderResponse _$OrderResponseFromJson(Map<String, dynamic> json) =>
    OrderResponse(
      data: OrderModel.fromJson(json['data'] as Map<String, dynamic>),
      message: json['message'] as String?,
    );

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
  id: jsonString(json['id']),
  number: jsonString(json['number']),
  reference: json['reference'] as String? ?? '',
  subtotalPrice: (json['subtotal_price'] as num?)?.toDouble() ?? 0,
  totalTaxes: (json['total_taxes'] as num?)?.toDouble() ?? 0,
  totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0,
  branch: json['branch'] == null
      ? null
      : LocalizedNameModel.fromJson(json['branch'] as Map<String, dynamic>),
  table: json['table'] == null
      ? null
      : LocalizedNameModel.fromJson(json['table'] as Map<String, dynamic>),
  paidAt: json['paid_at'] == null
      ? null
      : DateTime.parse(json['paid_at'] as String),
);
