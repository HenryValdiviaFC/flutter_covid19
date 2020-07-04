  import 'package:flutter/material.dart';
  import 'dart:async';
  import 'package:http/http.dart' as http;
  import 'package:provider/provider.dart';
  import 'package:flutter_covid19/models/country.dart';
  import 'package:flutter_covid19/models/statistics.dart';
  import 'package:flutter_covid19/data/moor_database.dart';
  import 'package:flutter_covid19/data/country_http.dart';
  import 'package:flutter_covid19/data/statistics_http.dart';

	void main() {
	  runApp(MyApp());
	}

	class MyApp extends StatelessWidget {
	  // This widget is the root of your application.
	  @override
	  Widget build(BuildContext context) {
		return MultiProvider(
      providers: [
        Provider(create: (_) => Database()),
        Provider(create: (_) => CountryHTTP()),
        Provider(create: (_) => StatisticsHTTP())
      ],
      child: MaterialApp(
		  title: 'Flutter Demo',
		  home: MyHomePage(),
		  debugShowCheckedModeBanner: false,
		)); 
    
	  }
	}

	class MyHomePage extends StatefulWidget {



	  @override
	  _MyHomePageState createState() => _MyHomePageState();
	}

	class _MyHomePageState extends State<MyHomePage> {

     List<Country> countries;
     Icon visibleIcon = Icon(Icons.search);
	   Widget searchBar= Text('Barra de búsqueda');
     Statistics stats;
     int _selectedIndex;

    @override
    void initState() {
      _selectedIndex = 0;
      super.initState();
    }	

  @override
  void didChangeDependencies() {
      _initList(this.context);
      _initStats();
    super.didChangeDependencies();
  }

	  @override
	  Widget build(BuildContext context) {
		return Scaffold(
		  appBar: AppBar(
			title: searchBar,
      actions: <Widget>[
        IconButton(
          icon: visibleIcon,
          onPressed: (){
            setState(() {
              if(this.visibleIcon.icon == Icons.search){
                this.visibleIcon = Icon(Icons.cancel);
                this.searchBar = TextField(
                    textInputAction: TextInputAction.search,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                    onSubmitted: (String text){
                      _search(text,context);
                    },
                  );
              }

              else{
                 this.visibleIcon = Icon(Icons.search);
                 this.searchBar = Text('Barra de búsqueda');
                 //Listamos los datos por defecto
                 _initList(context);
              }
            });
          },
        )
      ],
		  ),
		  body: _buildBody(context),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        onTap: (int index){
            setState(() {
              _selectedIndex = index;
            });
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
          icon: Icon(Icons.home),
          title: Text('Home'),
          ),
          BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          title: Text('Favourite'),
          ),
        ],
      ), 
		);
	  }

    Future _initList(BuildContext context) async{    
    final httpCountry = Provider.of<CountryHTTP>(context);
    print("List Init");
    countries = List();
    List<Country> temp = await httpCountry.allCountries(http.Client());
    print("After getList");
    setState(() {
      countries = temp;
      print('setState-list');  
    });
      print("Countries size init: "+countries.length.toString());
    }

    Future _search(String text,BuildContext context) async{
    final httpCountry = Provider.of<CountryHTTP>(context);
    print("Busqueda init");
    Country searchTemp = await httpCountry.findCountry(text); 
    setState(() {
      countries = List();
      countries.add(searchTemp);
    });
  }

    Future _initStats() async{
    final http = Provider.of<StatisticsHTTP>(context);
    print("init stats");
    stats = Statistics();
    Statistics statsTemp = await http.findStatistics(); 
    print("After getStats");
    setState(() {
      stats = statsTemp;
      print('setState-Statistics');
    });
  }
    
    Widget _buildBody(BuildContext context){
      
      final database = Provider.of<Database>(context);

      if(_selectedIndex == 0){
        return Column(
        children: [
              Container(
            margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: Row(
              children: <Widget>[
                _buildStatCard('Total Cases', stats.cases,Colors.red),
                _buildStatCard('Total Deaths', stats.deaths,Colors.blue),
                _buildStatCard('Total Recovered', stats.recovered,Colors.green),                          
              ],
            ),
          ),
          SizedBox(height: 8.0),
          Expanded(
              child: _CountryList(countries: countries,database: database)
            )
            
        ],
      );
    } 
      else{
        return StreamBuilder(
            stream: database.watchAllCountries,
            builder: (context, AsyncSnapshot <List<CountryDB>> snapshot){
              final countriesDB = snapshot.data ?? List();
              
              if(countriesDB.length == 0)
              return Center(
                child: Text('Sin favoritos'),
              );
              return _FavouriteList(favourites: countriesDB,database: database);           
            }
          );
      }

    }

    Widget _buildStatCard(String title,int number,Color color){
       

       return Container(
            height: MediaQuery.of(context).size.height / 4,
            width: MediaQuery.of(context).size.width / 3,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: color, 
            ),
            child: 
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: MediaQuery.of(context).size.width >=400?20.0:15.0
                  ),
                  textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: 10.0,),

                  Text(
                  number.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: MediaQuery.of(context).size.width >=400?20.0:15.0,
                    fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.center,
                  ),
              ],
            ),
          );
    }
	}

  class _CountryList extends StatelessWidget{
    final List<Country> countries;
    final Database database;

    _CountryList({Key key,this.countries,this.database}): super(key:key);

    @override
    Widget build(BuildContext context) {
      return ListView.builder(
         padding: const EdgeInsets.all(16.0),
         itemCount: countries.length,
         itemBuilder: (context, index) {
        return _buildRow(countries[index],context);
        },
      );
    }

    Widget _buildRow(Country country,BuildContext context){
         
         final countryDB = CountryDB(
            country: country.country,
            cases: country.cases,
            todayCases: country.todayCases,
            deaths: country.deaths,
            todayDeaths: country.todayDeaths,
            recovered: country.recovered,
            active: country.active,
            critical: country.critical,
            casesPerOneMillion: country.casesPerOneMillion,
            deathsPerOneMillion: country.deathsPerOneMillion,
            totalTests: country.totalTests,
            testsPerOneMillion: country.testsPerOneMillion
            );

         return StreamBuilder(
            stream: database.getCountry(countryDB.country),
            builder: (context, AsyncSnapshot <CountryDB> snapshot){      
              final snapshotDB = snapshot.data ?? null;
              return Card(
                elevation: 2.0,
                child: Padding(
                padding: EdgeInsets.only(bottom: 15.0,top: 15.0),
                child: ListTile(
                leading: Image.asset('assets/world.png'),
                title: Text(
                country.country
                ),
                subtitle:           
                Text('Cases: '+country.cases.toString()+" | "+"Today: "+country.todayCases.toString()+" | "+"Active: "+country.active.toString()+
                "\n"+"Deaths: "+country.deaths.toString()+" | "+"Today: "+country.todayDeaths.toString()+
                "\n"+"Recovered: "+country.recovered.toString()+" | "+" Critical: "+country.critical.toString()),
                trailing: 
                IconButton(
                icon: Icon(snapshotDB== null?Icons.favorite_border:Icons.favorite),
                onPressed: (){
                  database.addCountry(countryDB)
                  .then(
                    (value) => 
                      Scaffold.of(context).showSnackBar(
                        SnackBar(content: Text(country.country+' registrado como favorito'))
                        )
                    )
                  .catchError(
                    (e) =>
                      Scaffold.of(context).showSnackBar(
                        SnackBar(content: Text('Elemento ya se encuentra en la lista de favoritos'))
                        )
                    );
                },
                )
              ),
              ),
              );           
            }
          );
    }

  }
 

  class _FavouriteList extends StatelessWidget{
    
    final List<CountryDB> favourites;
    final Database database;

    _FavouriteList({Key key,this.favourites,this.database}): super(key:key);

    @override
    Widget build(BuildContext context) {
      return ListView.builder(
         padding: const EdgeInsets.all(16.0),
         itemCount: favourites.length,
         itemBuilder: (context, index) {
        return _buildRow(favourites[index],context);
        },
      );
    }

    Widget _buildRow(CountryDB country,BuildContext context){
        return Card(
        elevation: 2.0,
        child: Padding(
        padding: EdgeInsets.only(bottom: 15.0,top: 15.0),
        child: ListTile(
        leading: Image.asset('assets/world.png'),
        title: Text(
        country.country
        ),
        subtitle:           
        Text('Cases: '+country.cases.toString()+" | "+"Today: "+country.todayCases.toString()+" | "+"Active: "+country.active.toString()+
        "\n"+"Deaths: "+country.deaths.toString()+" | "+"Today: "+country.todayDeaths.toString()+
        "\n"+"Recovered: "+country.recovered.toString()+" | "+" Critical: "+country.critical.toString()),
        trailing: 
        IconButton(
        icon: Icon(Icons.delete),
        onPressed: (){
          print("Borrando de la BD");
          database.deleteCountry(country)
          .then(
            (value) => 
              Scaffold.of(context).showSnackBar(
                SnackBar(content: Text('Se elimina '+country.country+' de favoritos'))
              )
            )
          .catchError(
            (e) => 
              Scaffold.of(context).showSnackBar(
                SnackBar(content: Text('Error, nose pudo eliminar de la lista de favoritos'))
              )
            );
        },
        )
      ),
      ),
      );
    }

  }