/// extract the value at the specified path "dot-seprated string" from the specified data
T? selectFrom<T>(dynamic data, String? path) {
  if (path == null) {
    return null;
  }

  try {
    var parts = [];
    var currentKeyName = "";

    for (var i = 0; i < path.length; i++) {
      if (path[i] != "\\" && path[i] != ".") {
        currentKeyName += path[i];
        continue;
      }

      var hasAcharSkip = false;
      if (path[i] == "\\") {
        hasAcharSkip = true;
        i++;
      }

      if (path[i] == ".") {
        if (hasAcharSkip) {
          currentKeyName += path[i];
          continue;
        }

        parts.add(currentKeyName);
        currentKeyName = "";
        continue;
      }
    }

    if (currentKeyName != "") {
      parts.add(currentKeyName);
    }

    dynamic val = data;

    for (var i = 0; i < parts.length; i++) {
      if (parts[i].startsWith("#")) {
        int index = int.parse(parts[i].substring(1));
        val = (val as List<dynamic>)[index];
      } else {
        val = (val as Map<String, dynamic>)[parts[i]];
      }

      if (val == null) {
        // log(name: "kcore", "selectFrom  not found path $path");

        return null;
      }
    }

    // log(name: "kcore", "selectFrom type $T path $path type ${val.runtimeType}");

    return val as T;
  } catch (e) {
    // log(name: "kcore", "selectFrom  not found path $path, Error:$e");

    return null;
  }
}

T? getByType<T>(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value.runtimeType == T) {
    return value;
  } else if (T == double) {
    if (value.runtimeType == int) {
      return value.toDouble();
    }
  }

  return null;
}

/// write value inside a key
/// if key does not exists, it will be created
Map<String, dynamic> setValue(
    Map<String, dynamic> target, String keyPath, dynamic value) {
  List<String> keys = _split(keyPath);

  Map<String, dynamic> origin = target;

  for (var i = 0; i < keys.length; i++) {
    String key = keys[i];
    bool end = (i == keys.length - 1);

    if (!target.containsKey(key)) {
      target[key] = end ? value : <String, dynamic>{};
      if (end) {
        break;
      }
    }

    if (end) {
      target[key] = value;
      break;
    }

    if (target[key] is! Map<String, dynamic>) {
      // to continue iterating, the key MUST be a map, not a value
      // change the key to a map, losing its value
      target[key] = <String, dynamic>{};
    }
    target = target[key];
  }

  return origin;
}

List<String> _split(String path) {
  return path.split(".");
}

/// add a select method to any map
extension MapPathSelector<K, V> on Map<K, V> {
  T? select<T>(String? path) {
    return selectFrom(this, path);
  }

  void setForPath(String path, dynamic value) {
    setValue(this as Map<String, dynamic>, path, value);
  }

  void add(K? key, dynamic value) {
    if (key != null && value != null) {
      this[key] = value;
    }
  }
}

/// add a select method to any list
extension ListPathSelector<V> on List<V> {
  T? select<T>(String? path) {
    return selectFrom(this, path);
  }
}
