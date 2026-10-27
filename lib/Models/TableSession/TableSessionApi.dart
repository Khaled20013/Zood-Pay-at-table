import '../../Constants.dart';
import '../../Helper/ApiServices/Apis/ApiBase.dart';
import '../../Helper/ApiServices/Base/ApiEndpoints.dart';
import '../../Helper/ApiServices/Base/ApiRequest.dart';
import '../../Helper/ApiServices/Base/DemoDataPolicy.dart';
import '../../Helper/ApiServices/Base/KApiResponse.dart';
import '../../Helper/Configs/kcore.dart';
import '../../Helper/Errors/AppException.dart';
import '../../Helper/path_selector_base.dart';
import '../CoreBaseModel.dart';
import 'DummyTableSessionData.dart';
import 'TableSessionModel.dart';

class TableSessionApi extends CoreBaseModel {
  /// `GET /public/pay-at-table/qr/{qr_id}`. On success `data` is a
  /// [TableSessionModel]; otherwise `error` says why the table can't open.
  static Future<KApiResponse> getDetails({required String qrId}) async {
    final id = qrId.trim();
    if (!TableSessionModel.qrIdPattern.hasMatch(id)) {
      return KApiResponse.failure(const QrNotFoundException());
    }

    final request = ApiRequest()
      ..url = "${config.url}/${ApiEndpoints.qr(id)}"
      ..header = ApiBase().getHeader()
      ..type = RequestType.get
      ..cashKey = "pat_qr_$id";

    final response = await DemoDataPolicy.run(
      request: request,
      dummy: () => DummyTableSessionData.qrFor(id),
      onStatus: (status, message) => switch (status) {
        404 => QrNotFoundException(message),
        410 => TableUnavailableException(message),
        _ => null,
      },
    );
    if (response.error != null) return response;

    final data = response.responseMap?.select<Map<String, dynamic>>("data");
    if (data == null) return response..error = const UnexpectedException();
    if (!TableSessionModel.isActiveJson(data)) {
      return response..error = const TableUnavailableException();
    }
    response.data = TableSessionModel.fromJson(data, languageCode: lang);
    return response;
  }
}
