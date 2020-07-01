class Statistics{
  int cases;
  int deaths;
  int recovered;

  Statistics({this.cases = 0,this.deaths = 0,this.recovered = 0});

  factory Statistics.fromJson(Map<String, dynamic> json){
        return Statistics(
          cases: json['cases'],
          deaths: json['deaths'],
          recovered: json['recovered'],
        );
  }

  @override
  String toString() => 'Statistics: {cases: '+cases.toString()+', deaths: '+deaths.toString()+', recovered: '+recovered.toString()+'}';
}