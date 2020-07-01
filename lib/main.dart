  import 'package:flutter/material.dart';
  import 'dart:async';
  import 'dart:convert';
  import 'package:http/http.dart' as http;
  import 'package:flutter_covid19/models/country.dart';
  import 'package:flutter_covid19/models/statistics.dart';

  Future<List<Country>> allCountries(http.Client client) async{
      
      final response =
      await client.get(
        'https://coronavirus-19-api.herokuapp.com/countries'
        );

      print(response.statusCode);

      if(response.statusCode == 200){
          print(response.body);
          final parsed = json.decode(response.body).cast<Map<String, dynamic>>();
          List<Country> countries = parsed.map<Country>((json) => Country.fromJson(json)).toList();
          
          if(countries.length > 0)
           countries.removeAt(0);

          return countries;
      }

      else{
        throw Exception('Error: No se cargaron los paises');
      }
  }

  
  Future<Country> findCountry(String title) async {
  
  final response = await http.get(
    'https://coronavirus-19-api.herokuapp.com/countries/'+title   
    );

    print('Busqueda - '+response.statusCode.toString());

    if (response.statusCode == 200) {  
      print("Busqueda - Exito body");
      print(response.body);
      return Country.fromJson(json.decode(response.body));
    }
  
    else {
      throw Exception('Failed to search country');
    } 
 }

  Future<Statistics> findStatistics() async{
    final response = await http.get(
    'https://coronavirus-19-api.herokuapp.com/all'   
    );

    print('Statistics - '+response.statusCode.toString());

    if (response.statusCode == 200) {  
      print("Statistics - Exito body");
      print(response.body);
      return Statistics.fromJson(json.decode(response.body));
    }
  
    else {
      throw Exception('Failed to search country');
    } 

  }

	void main() {
	  runApp(MyApp());
	}

	class MyApp extends StatelessWidget {
	  // This widget is the root of your application.
	  @override
	  Widget build(BuildContext context) {
		return MaterialApp(
		  title: 'Flutter Demo',
		  home: MyHomePage(),
		  debugShowCheckedModeBanner: false,
		);
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


    @override
    void initState() {
      _initList();
      _initStats();
      super.initState();
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
                      _search(text);
                    },
                  );
              }

              else{
                 this.visibleIcon = Icon(Icons.search);
                 this.searchBar = Text('Barra de búsqueda');
                 //Listamos los datos por defecto
                 _initList();
              }
            });
          },
        )
      ],
		  ),
		  body: 
      
      Column(
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
              child: _CountryList(countries: countries)
            )
            
        ],
      ) 
		);
	  }

    Future _initList() async{
    print("List Init");
    countries = List();
    List<Country> temp = await allCountries(http.Client());
    print("After getList");
    setState(() {
      countries = temp;
      print('setState-list');  
    });
      print("Countries size init: "+countries.length.toString());
    }

    Future _search(String text) async{
    print("Busqueda init");
    Country searchTemp = await findCountry(text); 
    setState(() {
      countries = List();
      countries.add(searchTemp);
    });
  }

    Future _initStats() async{
    print("init stats");
    stats = Statistics();
    Statistics statsTemp = await findStatistics(); 
    print("After getStats");
    setState(() {
      stats = statsTemp;
      print('setState-Statistics');
    });
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
        
    _CountryList({Key key,this.countries}): super(key:key);

    @override
    Widget build(BuildContext context) {
      return ListView.builder(
         padding: const EdgeInsets.all(16.0),
         itemCount: countries.length,
         itemBuilder: (context, index) {
        return _buildRow(countries[index]);
        },
      );
    }

    Widget _buildRow(Country country){
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
        icon: Icon(Icons.add_circle),
        onPressed: (){},
        )
      ),
      ),
      );
    }

  }
 
