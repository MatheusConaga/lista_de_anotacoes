import 'package:flutter/material.dart';
import 'package:notas_diarias/helper/anotacaoHelper.dart';
import 'package:notas_diarias/model/anotacao.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController _tituloController = TextEditingController();
  TextEditingController _descricaoController = TextEditingController();
  var _db = AnotacaoHelper();
  List<Anotacao> _anotacoes = [];

  _exibirTelaCadastro({ Anotacao? anotacao }) {

    String textoSalvarAtualizar = "";
    if( anotacao == null ){//salvando
      _tituloController.text = "";
      _descricaoController.text = "";
      textoSalvarAtualizar = "Adicionar";

    }else{ //atualizando

      _tituloController.text = anotacao.titulo;
      _descricaoController.text = anotacao.descricao;
      textoSalvarAtualizar = "Atualizar";

    }


    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("$textoSalvarAtualizar anotação"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _tituloController,
                  autofocus: true,
                  decoration: InputDecoration(
                      labelText: "Titulo", hintText: "Digite título..."),
                ),
                TextField(
                  controller: _descricaoController,
                  autofocus: true,
                  decoration: InputDecoration(
                      labelText: "Descrição", hintText: "Digite descrição..."),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancelar")),
              ElevatedButton(
                  onPressed: () {
                    _salvarAtualizarAnotacao(anotacaoSelect:anotacao);

                    Navigator.pop(context);
                  },
                  child: Text(textoSalvarAtualizar)),
            ],
          );
        });
  }

  _recuperarAnotacoes() async {
    List anotacoesRecuperadas = await _db.recuperarAnotacoes();

    List<Anotacao> listaTemporaria = [];
    for (var item in anotacoesRecuperadas) {
      Anotacao anotacao = Anotacao.fromMap(item);
      listaTemporaria.add(anotacao);
    }

    setState(() {
      _anotacoes = listaTemporaria;
    });

    // listaTemporaria.clear();
    print("Anotações recuperadas: ${_anotacoes.toString()}");

    // print("Lista anotacoes: " + anotacoesRecuperadas.toString());
  }

  _salvarAtualizarAnotacao({Anotacao? anotacaoSelect}) async {

    String titulo = _tituloController.text;
    String descricao = _descricaoController.text;

    if (anotacaoSelect == null){
      Anotacao anotacao = Anotacao(titulo, descricao, DateTime.now().toString());
      int resultado = await _db.salvarAnotacao(anotacao);
    } else{
      anotacaoSelect.titulo = titulo;
      anotacaoSelect.descricao = descricao;
      anotacaoSelect.data = DateTime.now().toString();
      int resultado = await _db.atualizarAnotacao(anotacaoSelect);
    }


    _tituloController.clear();
    _descricaoController.clear();
    _recuperarAnotacoes();
  }

  _formatarData(String data){
    initializeDateFormatting("pt_BR");

    // var formater = DateFormat("d/M/y");
    var formater = DateFormat.yMd("pt_BR");


    DateTime dataConvertida = DateTime.parse( data );
    String dataFormatada = formater.format(dataConvertida);

    return dataFormatada;
  }


  _confirmarExclusao( int id ){
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text("Deseja mesmo fazer a exclusão?"),
            actions: [
              ElevatedButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text("Cancelar"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red
                ),
                  onPressed: (){
                    _removerAnotacao(id);
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Apagar",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  )
              ),
            ],
          );
        }
    );

  }

  _removerAnotacao (int id) async{
    await _db.deletarAnotacao(id);
    _recuperarAnotacoes();

  }


  @override
  void initState() {
    super.initState();
    // print (_recuperarAnotacoes());
  // print("Anotações salvas: ${_anotacoes.length}");
    _recuperarAnotacoes();
  //   _salvarAnotacao();
    print("anotações: ${_anotacoes.toString()}");

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: Text(
          "Anotações",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
                itemCount: _anotacoes.length,
                itemBuilder: (context, index) {
                  final anotacao = _anotacoes[index];

                  return Card(
                    child: ListTile(
                      title: Text(anotacao.titulo),
                      subtitle:
                      Text("${_formatarData(anotacao.data)} - ${anotacao.descricao}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: (){
                              _exibirTelaCadastro(anotacao: anotacao);
                            },
                            child: Padding(padding: EdgeInsets.only(right: 20),
                                child: Icon(
                                  Icons.edit_square,
                                  color: Colors.green,
                                ),
                            ),
                          ),
                          GestureDetector(
                            onTap: (){
                              _confirmarExclusao(anotacao.id ?? 0);
                            },
                            child: Padding(padding: EdgeInsets.only(right: 0),
                              child: Icon(
                                Icons.delete_sharp,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          child: Icon(Icons.add),
          onPressed: _exibirTelaCadastro),
    );
  }
}
