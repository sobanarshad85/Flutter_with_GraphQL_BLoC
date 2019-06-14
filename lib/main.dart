import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() {
  runApp(MaterialApp(title: "GQL App", home: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final HttpLink httpLink =
        HttpLink(uri: "https://countries.trevorblades.com/");
    final ValueNotifier<GraphQLClient> client = ValueNotifier<GraphQLClient>(
      GraphQLClient(
        link: httpLink as Link,
        cache: OptimisticCache(
          dataIdFromObject: typenameDataIdFromObject,
        ),
      ),
    );
    return GraphQLProvider(
      child: HomePage(),
      client: client,
    );
  }
}

class HomePage extends StatelessWidget {
  final String query = r"""
                    query GetContinent($code : String!){
                      continent(code:$code){
                          name
                          countries{
                            code,
                            name,
                            native,
                            phone,
                            currency,
                            languages{
                              code,
                              name,
                              native,
                              rtl
                            },
                            emoji,
                            emojiU
                          }
  
                      }
                    }
                  """;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("GraphlQL Client"),
      ),
      body: Query(
        options: QueryOptions(
            document: query, variables: <String, dynamic>{"code": "AS"}),
        builder: (
          QueryResult result, {
          VoidCallback refetch,
        }) {
          if (result.loading) {
            return Center(child: CircularProgressIndicator());
          }
          if (result.data == null) {
            return Text("No Data Found !");
          }
          return ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              return Column(
                children: <Widget>[
                  Text(result.data['continent']['countries'][index]['name']),
                  Text(result.data['continent']['name']),
                  Text('Spoken Languages'),
                  getTextWidgets(result.data, index),
                  // Text(result.data['continent']['countries']['languages']['name']),
                  SizedBox(
                    height: 30.0,
                  )
                ],
              );
            },
            itemCount: result.data['continent']['countries'].length,
          );
        },
      ),
    );
  }

  // return test;

  Widget getTextWidgets(data, index) {
    final counter = data['continent']['countries'][index]['languages'].length;
    List<Widget> list = new List<Widget>();
    for (var i = 0; i < counter; i++) {
      list.add(new Text(
          '${i + 1}:  ${data['continent']['countries'][index]['languages'][i]['native']}'));
      list.add(new Text(
          'Name:  ${data['continent']['countries'][index]['languages'][i]['name']}'));
    }
    return new Column(children: list);
  }
}
