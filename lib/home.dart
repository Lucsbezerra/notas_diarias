import 'package:flutter/material.dart';
import 'package:notas_diarias/helper/anotacaohelper.dart';
import 'package:notas_diarias/helper/model/anotacao.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController _tituloController = TextEditingController();
  TextEditingController _descricaoController = TextEditingController();
  var _db = AnotacaoHelper();
  List<Anotacao> _anotacoes = <Anotacao>[];

  _exibirTelaCadastro({Anotacao anotacao}) {
    String palavra = "";

    if (anotacao == null) {
      _tituloController.text = "";
      _descricaoController.text = "";
      palavra = "Adicionar";
    } else {
      _tituloController.text = anotacao.titulo;
      _descricaoController.text = anotacao.descricao;
      palavra = "Editar";
    }

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("$palavra anotação"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _tituloController,
                  autofocus: true,
                  decoration: InputDecoration(
                      labelText: "Título", hintText: "Digite título..."),
                ),
                TextField(
                  controller: _descricaoController,
                  decoration: InputDecoration(
                      labelText: "Descrição",
                      hintText: "Digite a descrição..."),
                )
              ],
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancelar")),
              TextButton(
                  onPressed: () {
                    _salvarAtualizarAnotacao(anotacaoSelecionada: anotacao);
                  },
                  child: Text("Salvar")),
            ],
          );
        });
  }

  _recuperarAnotacoes() async {
    List anotacoesRecuperadas = await _db.recuperarAnotacoes();

    List<Anotacao> listaTemporaria = <Anotacao>[];
    for (var item in anotacoesRecuperadas) {
      Anotacao anotacao = Anotacao.fromMap(item);
      listaTemporaria.add(anotacao);
    }
    setState(() {
      _anotacoes = listaTemporaria;
    });
    listaTemporaria = null;
    //print("Lista anotacoes: " + anotacoesRecuperadas.toString());
  }

  _salvarAtualizarAnotacao({Anotacao anotacaoSelecionada}) async {
    String titulo = _tituloController.text;
    String descricao = _descricaoController.text;

    if (anotacaoSelecionada == null) {
      Anotacao anotacao =
          Anotacao(titulo, descricao, DateTime.now().toString());
      int resultado = await _db.salvarAnotacao(anotacao);
    } else {
      anotacaoSelecionada.titulo = titulo;
      anotacaoSelecionada.descricao = descricao;
      anotacaoSelecionada.data = DateTime.now().toString();
      int resultado = await _db.salvarAnotacao(anotacaoSelecionada);
    }

    _tituloController.clear();
    _descricaoController.clear();

    _recuperarAnotacoes();
  }

  _formatarData(String data) {
    initializeDateFormatting("pt_BR");

    var formatador = DateFormat.yMMMMd("pt_BR");

    DateTime dataConvertida = DateTime.parse(data);
    String dataFotmatada = formatador.format(dataConvertida);
    return dataFotmatada;
  }

  _removerAnotacao(int id) async {
    await _db.removerAnotacao(id);
    _recuperarAnotacoes();
  }

  @override
  void initState() {
    super.initState();
    _recuperarAnotacoes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Minhas anotações"),
        backgroundColor: Colors.lightGreen,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
              child: ListView.builder(
            itemCount: _anotacoes.length,
            itemBuilder: (context, index) {
              final item = _anotacoes[index];

              return Card(
                child: ListTile(
                  title: Text(item.titulo),
                  subtitle:
                      Text("${_formatarData(item.data)} - ${item.descricao}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          _exibirTelaCadastro(anotacao: item);
                        },
                        child: Padding(
                          padding: EdgeInsets.only(right: 16),
                          child: Icon(
                            Icons.edit,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _removerAnotacao(item.id);
                        },
                        child: Padding(
                          padding: EdgeInsets.only(right: 0),
                          child: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
        onPressed: () {
          _exibirTelaCadastro();
        },
      ),
    );
  }
}
