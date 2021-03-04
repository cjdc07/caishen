import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

String uuidFromObject(Object object) {
  if (object is Map<String, Object>) {
    final String typeName = object['__typename'] as String;
    final String id = object['id'].toString();

    if (typeName != null && id != null) {
      return <String>[typeName, id].join('/');
    }
  }

  return null;
}

final OptimisticCache cache = OptimisticCache(
  dataIdFromObject: uuidFromObject,
);

ValueNotifier<GraphQLClient> clientFor({
  @required String uri,
  String subscriptionUri,
}) {
  final HttpLink httpLink = HttpLink(uri: uri);

  final AuthLink authLink = AuthLink(getToken: () async {
    final String token = Hive.box('tokens').get('authToken');
    return token != null ? 'Bearer $token' : '';
  });

  final Link link = authLink.concat(httpLink);

  if (subscriptionUri != null) {
    final WebSocketLink webSocketLink = WebSocketLink(
      url: subscriptionUri,
      config: SocketClientConfig(
        autoReconnect: true,
        inactivityTimeout: Duration(seconds: 30),
      ),
    );

    link.concat(webSocketLink);
  }

  return ValueNotifier(
    GraphQLClient(cache: cache, link: link),
  );
}

class ClientProvider extends StatelessWidget {
  ClientProvider({
    @required this.child,
    @required String uri,
    String subscriptionUri,
  }) : client = clientFor(
          uri: uri,
          subscriptionUri: subscriptionUri,
        );

  final Widget child;
  final ValueNotifier<GraphQLClient> client;

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: child,
    );
  }
}
