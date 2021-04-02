import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:mockito/mockito.dart';

import 'mock_data_snapshot.dart';
import 'mock_firebase_database.dart';

class MockDatabaseReference extends Mock implements DatabaseReference {
  var _nodePath = '/';
  // ignore: prefer_final_fields
  static var _persitedData = <String, dynamic>{};
  var _volatileData = <String, dynamic>{};
  MockDatabaseReference();
  MockDatabaseReference._(nodePath, [this._volatileData]) {
    _nodePath += nodePath;
  }
  // TODO implement real [onchange] (may yield each change).
  Stream<Event> get onValue async* {
    final data = await once();
    yield MockEvent._(data.value);
  }

  Map<String, dynamic> get _data {
    if (MockFirebaseDatabase.persistData) {
      return _persitedData;
    }
    return _volatileData;
  }

  set _data(data) {
    if (MockFirebaseDatabase.persistData) {
      _persitedData = data;
    } else
      return _volatileData = data;
  }

  @override
  String get path => _nodePath;

  @override
  DatabaseReference child(String path) {
    if (!path.endsWith('/')) path += '/';
    path = (_nodePath + path).replaceAll(RegExp(r'^/+'), '');
    return MockDatabaseReference._(
      path,
      MockFirebaseDatabase.persistData ? _volatileData : <String, dynamic>{},
    );
  }

  @override
  // ignore: missing_return
  Future<void> set(dynamic value, {dynamic priority}) {
    if (_nodePath == '/') {
      _data = value;
      return null;
    }
    var nodePathWithoutSlashesAtEndAndStart =
        _nodePath.substring(1, _nodePath.length - 1);
    var nodesList = nodePathWithoutSlashesAtEndAndStart.split('/');
    var tempData = <String, dynamic>{};
    Map<String, dynamic> lastNodeInCurrentData;
    var nodeIndexReference = _Int(0);
    if (_data[nodesList.first] == null) {
      lastNodeInCurrentData = _data;
    } else {
      lastNodeInCurrentData = _getNextNodeData(
          data: _data, nodesList: nodesList, nodeIndex: nodeIndexReference);
    }
    var nodeIndex = nodeIndexReference.value;
    var noNewNodeToAdd = nodesList.length <= nodeIndex;
    if (noNewNodeToAdd) {
      lastNodeInCurrentData[nodesList.last] = value;
      return null;
    }
    var firstNodeInNewData = nodesList[nodeIndex++];
    if (nodeIndex < nodesList.length) {
      tempData = _buildNewNodesTree(
        nodeIndex: nodeIndex,
        nodesList: nodesList,
        data: tempData,
        value: value,
      );
      lastNodeInCurrentData.addAll({firstNodeInNewData: tempData});
    } else {
      if (value is Map) value = value;
      lastNodeInCurrentData.addAll({firstNodeInNewData: value});
    }
  }

  Map<String, dynamic> _buildNewNodesTree({
    @required dynamic data,
    @required List<String> nodesList,
    @required int nodeIndex,
    @required value,
  }) {
    var nextNodeIndex = nodeIndex + 1;
    if (nodeIndex + 1 < nodesList.length) {
      data[nodesList[nodeIndex]] = {nodesList[nextNodeIndex]: Object()};
      _buildNewNodesTree(
          data: data[nodesList[nodeIndex]],
          nodesList: nodesList,
          nodeIndex: nextNodeIndex,
          value: value);
    } else
      data[nodesList[nodeIndex]] = value;
    return data;
  }

  _getNextNodeData({
    @required dynamic data,
    @required List<String> nodesList,
    @required _Int nodeIndex,
  }) {
    if (nodesList.length <= nodeIndex.value ||
        !(data[nodesList[nodeIndex.value]] is Map)) {
      nodeIndex.increment();
      return data;
    }
    return _getNextNodeData(
      data: data[nodesList[nodeIndex.value]],
      nodesList: nodesList,
      nodeIndex: nodeIndex.increment(),
    );
  }

  @override
  Future<DataSnapshot> once() {
    var tempData = _data;
    // remove start and end slashes.
    var nodePath = _nodePath.substring(1, _nodePath.length - 1);
    var nodeList = nodePath.split('/');
    if (nodeList.length > 1) {
      for (var i = 0; i < nodeList.length; i++) {
        nodePath = nodeList[i];
        var nonExistentNodeFound = tempData[nodePath] == null;
        if (nonExistentNodeFound || (i + 1) == nodeList.length) {
          break;
        }
        if (tempData[nodePath] is Map) {
          tempData = tempData[nodePath];
        }
      }
    }
    return Future.value(MockDataSnapshot(tempData[nodePath]));
  }
}

class _Int {
  int value;
  _Int(this.value);
  _Int increment() {
    ++value;
    return this;
  }
}

class MockEvent extends Mock implements Event {
  MockEvent._(data) : snapshot = MockDataSnapshot(data);

  final DataSnapshot snapshot;
}

// Map<String, dynamic> _makeSupportGenericValue(Map<String, dynamic> data) {
//   var _dataWithGenericValue = {'__generic_mock_data_value__': Object()};
//   _dataWithGenericValue.addAll(data);
//   _dataWithGenericValue.forEach((key, value) {
//     if (value is Map) {
//       _dataWithGenericValue[key] = _makeSupportGenericValue(value);
//     }
//   });
//   return _dataWithGenericValue;
// }
