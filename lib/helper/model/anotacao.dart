import 'package:notas_diarias/helper/anotacaohelper.dart';

class Anotacao {
  int id;
  String titulo;
  String descricao;
  String data;

  Anotacao(this.titulo, this.descricao, this.data);

  Anotacao.fromMap(Map map) {
    this.id = map[AnotacaoHelper.colunaId];
    this.titulo = map[AnotacaoHelper.colunaTitulo];
    this.descricao = map[AnotacaoHelper.colunaDescricao];
    this.data = map[AnotacaoHelper.colunaData];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      "titulo": this.titulo,
      "descricao": this.descricao,
      "data": this.data,
    };

    if (id != null) {
      map["id"] = this.id;
    }
    return map;
  }
}
