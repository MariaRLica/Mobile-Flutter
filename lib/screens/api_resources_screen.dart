import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiResourcesScreen extends StatefulWidget {
  const ApiResourcesScreen({Key? key}) : super(key: key);

  @override
  State<ApiResourcesScreen> createState() => _ApiResourcesScreenState();
}

class _ApiResourcesScreenState extends State<ApiResourcesScreen> {
  late Future<List<dynamic>> _futureList;

  @override
  void initState() {
    super.initState();
    _futureList = fetchResources();
  }

  Future<List<dynamic>> fetchResources() async {
    final uri = Uri.parse('https://jsonplaceholder.typicode.com/posts');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final decoded = json.decode(res.body);
      if (decoded is List) return decoded;
      if (decoded is Map &&
          decoded.containsKey('data') &&
          decoded['data'] is List) return decoded['data'];
      return [decoded];
    } else {
      throw Exception('Falha ao carregar: ${res.statusCode}');
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _futureList = fetchResources();
    });
    await _futureList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recursos da API',
          style: TextStyle(color: Color(0xfff2eded)), // cor do texto
        ),
        backgroundColor: Colors.deepPurple, // cor de fundo
        iconTheme: const IconThemeData(color: Color(0xff4d1682)),
      ), // cor dos ícones,
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<dynamic>>(
          future: _futureList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Erro: ${snapshot.error}'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                          onPressed: _refresh,
                          child: const Text('Tentar novamente')),
                    ],
                  ),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('Nenhum recurso encontrado'));
            }
            final list = snapshot.data!;
            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = list[index];
                final title =
                    (item['title'] ?? item['name'] ?? 'Sem título').toString();
                final body =
                    (item['body'] ?? item['description'] ?? '').toString();
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(title,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(body,
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    leading: CircleAvatar(
                        child: Text((item['id'] ?? (index + 1)).toString())),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16))),
                          builder: (context) {
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge),
                                  const SizedBox(height: 12),
                                  Text(
                                      body.isNotEmpty ? body : item.toString()),
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text('Fechar'),
                                    ),
                                  )
                                ],
                              ),
                            );
                          });
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
