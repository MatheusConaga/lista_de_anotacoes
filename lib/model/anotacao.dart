class Anotacao {
  int? id;
  String titulo;
  String descricao;
  String data;

  // Construtor padrão
  Anotacao(this.titulo, this.descricao, this.data);

  // Construtor que cria uma Anotacao a partir de um mapa
  Anotacao.fromMap(Map<String, dynamic> map)
      : id = map["id"] as int?,
        titulo = map["titulo"] as String? ?? '', // Valor padrão para evitar nulo
        descricao = map["descricao"] as String? ?? '', // Valor padrão para evitar nulo
        data = map["data"] as String? ?? ''; // Valor padrão para evitar nulo

  // Método para converter Anotacao em mapa
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "titulo": titulo,
      "descricao": descricao,
      "data": data,
    };

    if (id != null) {
      map["id"] = id;
    }
    return map;
  }
}
