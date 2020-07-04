import 'dart:async';
import 'package:moor_ffi/moor_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:moor/moor.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
part 'moor_database.g.dart';

@DataClassName("CountryDB")
class Countries extends Table{
    
    TextColumn get country => text()();
    IntColumn get cases => integer().nullable()();
    IntColumn get todayCases => integer().nullable()();
    IntColumn get deaths => integer().nullable()();
    IntColumn get todayDeaths => integer().nullable()();
    IntColumn get recovered => integer().nullable()();
    IntColumn get active => integer().nullable()();
    IntColumn get critical => integer().nullable()();
    IntColumn get casesPerOneMillion => integer().nullable()();
    IntColumn get deathsPerOneMillion => integer().nullable()();
    IntColumn get totalTests => integer().nullable()();
    IntColumn get testsPerOneMillion => integer().nullable()();

    @override
    Set<Column> get primaryKey => {country};
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return VmDatabase(file);
  });
}

@UseMoor(tables: [Countries])
class Database extends _$Database{
  
  Database() : super(_openConnection());
  
   @override
  int get schemaVersion => 1;


  Stream<List<CountryDB>> get watchAllCountries => select(countries).watch();

  Future<int> addCountry(CountryDB country) {
    return into(countries).insert(country);
  }

  Future<int> deleteCountry(CountryDB country){
    return delete(countries).delete(country);
  }

  Future<List<CountryDB>> getCountriesByName(String name){
    return (select(countries)..where((tbl) => tbl.country.like('%'+name+'%'))).get();
  }

  Stream<CountryDB> getCountry(String name){
    return  (select(countries)..where((tbl) => tbl.country.equals(name))).watchSingle();
  }
}
