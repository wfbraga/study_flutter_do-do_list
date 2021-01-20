import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
//import 'dart:async';
import 'dart:convert';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List _listTarefas = [];

  Map<String, dynamic> _ultimaTarefaRemovida = Map();



  TextEditingController _controllerTarefa = TextEditingController();

  _salvarTarefa(){
    String tarefaDigitada = _controllerTarefa.text;

    Map<String, dynamic> tarefa = Map();

    tarefa["titulo"] = tarefaDigitada;
    tarefa["status"] = false;

    setState(() {
      _listTarefas.add(tarefa);
    });

    _salvarArquivo();
    _controllerTarefa.text = "";
  }

  Future<File> _getFile() async {
    final diretorio = await getApplicationDocumentsDirectory();
    return File("${diretorio.path}/tarefas.json");
  }

  _salvarArquivo() async {
    
    var arquivo = await _getFile();

    String dados = json.encode(_listTarefas);

    arquivo.writeAsString(dados);
  }

  _lerArquivo() async {
    try{

      final arquivo = await _getFile();

      return arquivo.readAsString();

    }catch(e){
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _lerArquivo().then((dados){
      setState(() {
        _listTarefas = jsonDecode(dados);
      });
    });
  }

  Widget _criarItemLista(context, index){
    final item = _listTarefas[index]['titulo'];
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      direction: DismissDirection.endToStart,
        onDismissed: (direction){

          _ultimaTarefaRemovida = _listTarefas[index];
          _listTarefas.removeAt(index);
          //_salvarArquivo();

          final snackbar = SnackBar(
            //backgroundColor: Colors.greenAccent,
              duration: Duration(seconds: 5),
              content: Text('Tarefa Removida'),
            action: SnackBarAction(
              label: "Desfazer",
              onPressed: (){

                setState(() {
                  _listTarefas.insert(index, _ultimaTarefaRemovida);
                });
                _salvarArquivo();
                },
            )
          );

          // ignore: deprecated_member_use
          Scaffold.of(context).showSnackBar(snackbar);

        },
        background: Container(
          color: Colors.red,
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.delete, color: Colors.white)
            ],
          ),

        ),
        child: CheckboxListTile(
            title: Text(_listTarefas[index]['titulo']),
            value: _listTarefas[index]['status'],
            onChanged: (valorAlterado){
              setState(() {
                _listTarefas[index]['status'] = valorAlterado;
              });
              _salvarArquivo();
              print('valor: ' + valorAlterado.toString());
            }
        ),
    );
  }

  @override
  Widget build(BuildContext context) {

    print("tiens: " + _listTarefas.toString());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text('Lista de tarefas'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        child: Icon(Icons.add),
        onPressed: (){

          showDialog(
              context: context,
            builder: (context){
                return AlertDialog(
                  title: Text('Adicionar Tarefa'),
                  content: TextField(
                    controller: _controllerTarefa,
                    decoration: InputDecoration(
                      labelText: "Digite sua tarefa"
                    ),
                    onChanged: (text){

                    },
                  ),
                  actions: <Widget>[
                    FlatButton(onPressed: (){
                      _salvarTarefa();

                      Navigator.pop(context);
                    },
                        child: Text('Salvar')
                    ),

                    FlatButton(onPressed: (){
                      Navigator.pop(context);
                    },
                        child: Text('Cancelar')
                    ),

                  ],
                );
            }

          );
        },
      ),

      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
                itemCount: _listTarefas.length,
                  itemBuilder: _criarItemLista,
              )
          )
        ],
      ),
    );
  }
}
