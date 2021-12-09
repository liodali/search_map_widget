import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:hive/hive.dart';

import '../models/address.dart';

enum TypeAdr { home, work }

extension on TypeAdr {
  static final names = ["home", "work"];

  String get name => names[index];
}

class HiveDB {
  static Box? _box;

  static Future<void> init() async {
    _box = await Hive.openBox("address");
  }

  static Box get adrDb => _box!;
}

mixin AdrLocalStorageMixin {
  final dbAdrHive = HiveDB.adrDb;
  static const String keyHomeAdr = "home";
  static const String keyWorkAdr = "work";
  static const String keySugAdr = "sug";

  @visibleForTesting
  Future<void> clearAll() async {
    await dbAdrHive.clear();
    await dbAdrHive.deleteFromDisk();
  }

  Future<void> addAdr(TypeAdr typeAdr, String geo, MyAddress adr) async {
    if (!dbAdrHive.containsKey(typeAdr.name)) {
      await dbAdrHive.put(typeAdr.name, adr);
    }
  }

  Future<void> addSugAddresses(MyAddress adr) async {
    List<MyAddress> listAdr = [];
    if (dbAdrHive.containsKey(keySugAdr)) {
      final data = dbAdrHive.get(keySugAdr);
      listAdr = List.castFrom(data.toList()) as List<MyAddress>;
      if (listAdr.length > 8) {
        listAdr.removeAt(0);
      }
    }
    listAdr.add(adr);
    dbAdrHive.put(keySugAdr, listAdr);
  }

  Future<List<MyAddress>> getSugAddresses() async {
    if (dbAdrHive.containsKey(keySugAdr)) {
      final data = dbAdrHive.get(keySugAdr);
      List<MyAddress> listAdr = List.castFrom(data.toList()) as List<MyAddress>;
      return listAdr.reversed.toList();
    }
    return [];
  }

  Future<MyAddress?> getHomeAdrByName() async {
    if (dbAdrHive.containsKey(keyHomeAdr)) {
      final data = await dbAdrHive.get(keyHomeAdr);
      MyAddress map = data.cast<MyAddress>() as MyAddress;
      return map;
    }
    return null;
  }

  Future<MyAddress?> getWorkAdrByName() async {
    if (dbAdrHive.containsKey(keyWorkAdr)) {
      final data = await dbAdrHive.get(keyWorkAdr);
      MyAddress map = data.cast<MyAddress>() as MyAddress;
      return map;
    }
    return null;
  }
}

class LocalLocationService with AdrLocalStorageMixin {
  Future createHomeAddress(GeoPoint p, Address adr) async {
    await addAdr(
      TypeAdr.home,
      p.toString(),
      MyAddress(
        address: adr,
        geoPoint: p,
      ),
    );
  }

  Future createWorkAddress(GeoPoint p, Address adr) async {
    await addAdr(
      TypeAdr.work,
      p.toString(),
      MyAddress(
        address: adr,
        geoPoint: p,
      ),
    );
  }

  Future addSugAddress(GeoPoint p, Address adr) async {
    await addSugAddresses(
      MyAddress(
        address: adr,
        geoPoint: p,
      ),
    );
  }

  Future<List<MyAddress>> getSugAddress() async => await getSugAddresses();
}
