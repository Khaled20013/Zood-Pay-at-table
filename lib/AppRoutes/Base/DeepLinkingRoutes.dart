import 'package:go_router/go_router.dart';

class DeepLinkingRoutes {
  static List<RouteBase> routes() {
    List<RouteBase> lst = [];

    // lst.add(openClassDteailsScreen(settings: const RouteSettings()));
    // lst.add(openProfileTalentScreen(settings: const RouteSettings()));

    return lst;
  }

  // static openClassDteailsScreen({ClassModel? model, RouteSettings? settings}) {
  //   if (settings != null) {
  //     return GoRoute(
  //         name: "share/class",
  //         path: "share/class/:id",
  //         builder: (context, state) {
  //           String? id = state.pathParameters['id'];
  //           if (id != null) {
  //             // String id =
  //             //     GoRouterApp.queryParameters(context: context, state: state);

  //             return ClassDteailsScreen(
  //               calssID: int.parse(id),
  //             );
  //           } else {
  //             return const SizedBox.shrink();
  //           }
  //         });
  //   }
  // }

  // static openProfileTalentScreen({ClassModel? model, RouteSettings? settings}) {
  //   if (settings != null) {
  //     return GoRoute(
  //         name: "share/user",
  //         path: "share/user/:id",
  //         builder: (context, state) {
  //           String? id = state.pathParameters['id'];
  //           if (id != null) {
  //             // String id =
  //             //     GoRouterApp.queryParameters(context: context, state: state);

  //             return ProfileTalentScreen(
  //               userID: int.parse(id),
  //             );
  //           } else {
  //             return const SizedBox.shrink();
  //           }
  //         });
  //   }
  // }
}
