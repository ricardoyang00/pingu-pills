import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:app/widgets/system_notification.dart';

class Medicament {
  final int id;
  String name;
  int quantity;
  DateTime expiryDate;
  String notes;
  final int? brandId;

  Medicament({
    required this.id,
    required this.name,
    required this.quantity,
    required this.expiryDate,
    required this.notes,
    this.brandId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'expiryDate': expiryDate.millisecondsSinceEpoch,
      'notes': notes,
      'brandId': brandId,
    };
  }

  factory Medicament.fromMap(Map<String, dynamic> map) {
    return Medicament(
      id: map['id'],
      name: map['name'],
      quantity: map['quantity'],
      expiryDate: DateTime.fromMillisecondsSinceEpoch(map['expiryDate']),
      notes: map['notes'],
      brandId: map['brandId'],
    );
  }

  bool checkExpired() {
    DateTime currentDate = DateTime.now();
    int differenceInDays = expiryDate.difference(currentDate).inDays;
    return differenceInDays < 0;
  }
}

class MedicamentStock {
  static final MedicamentStock _instance = MedicamentStock._internal();
  late Database _database;

  factory MedicamentStock() => _instance;

  MedicamentStock._internal();

  Future<void> initDatabase() async {
    WidgetsFlutterBinding.ensureInitialized();
    final String path = join(await getDatabasesPath(), 'medicaments_database.db');
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
            '''
          CREATE TABLE medicaments(
            id INTEGER PRIMARY KEY,
            name TEXT,
            quantity INTEGER,
            expiryDate INTEGER,
            notes TEXT,
            brandId INTEGER
          )
          '''
        );
      },
    );
  }

  Future<int> insertMedicament(Medicament medicament) async {
    try {
      final int id = await _database.insert('medicaments', medicament.toMap());
      print('Inserted medicament ${medicament.name}');
      return id;
    } catch (e) {
      print('Error inserting medicament: $e');
      return -1;
    }
  }

  Future<Medicament?> getMedicamentById(int id) async {
    try {
      List<Map<String, dynamic>> maps = await _database.query(
        'medicaments',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return Medicament.fromMap(maps.first);
      } else {
        print('Medicament not found with ID: $id');
        return null;
      }
    } catch (e) {
      print('Error fetching medicament: $e');
      return null;
    }
  }

  Future<List<Medicament>> getMedicaments() async {
    try {
      final List<Map<String, dynamic>> maps = await _database.query('medicaments');
      print('Getting medicaments list');
      return List.generate(maps.length, (i) {
        return Medicament.fromMap(maps[i]);
      });
    } catch (e) {
      print('Error fetching medicaments: $e');
      return [];
    }
  }

  Future<int> deleteMedicament(int id) async {
    try {
      int rowsDeleted = await _database.delete(
        'medicaments',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (rowsDeleted > 0) {
        print('Deleted medicament with ID: $id');
      } else {
        print('No medicament found with ID: $id');
      }

      return rowsDeleted;
    } catch (e) {
      print('Error deleting medicament: $e');
      return -1;
    }
  }

  Future<void> updateMedicament(Medicament updatedMedicament) async {
    try {
      await _database.update(
        'medicaments',
        updatedMedicament.toMap(),
        where: 'id = ?',
        whereArgs: [updatedMedicament.id],
      );
      print('Updated medicament ${updatedMedicament.name}');
      verifyStockRunningLow(updatedMedicament);
    } catch (e) {
      print('Error updating medicament: $e');
    }
  }

  Future<void> changeMedicamentQuantity(Medicament medicament, int newQuantity) async {
    if (newQuantity < 0) {
      print('Quantity cannot be negative integer');
      return;
    }
    try {
      List<Medicament> currentMedicament = (await getMedicamentById(medicament.id)) as List<Medicament>;

      if (currentMedicament != null) {
        currentMedicament.first.quantity = newQuantity;
        print('Updated quantity for medicament ${medicament.name} to $newQuantity');
        verifyStockRunningLow(currentMedicament.first);
      } else {
        print('Medicament not found in the database');
      }
    } catch (e) {
      print('Error changing medicament quantity: $e');
    }
  }
}
