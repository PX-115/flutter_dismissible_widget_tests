import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';

class Home extends StatefulWidget {
  const Home({ Key key }) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List _listaItens = [];
  TextEditingController _controllerAdditem = TextEditingController();

  Future<File> _acessarArquivo() async {
    final diretorio = await getApplicationDocumentsDirectory();
    return File('${diretorio.path}/data.json');
  }

  _salvarItem (){
    String _textoDigitado = _controllerAdditem.text;

    Map<String, dynamic> item = Map();
    item['titulo'] = _textoDigitado;

    setState(() {
      _listaItens.add(item);     
    });

    _salvarArquivo();

    _controllerAdditem.text = '';
  }

  _salvarArquivo() async {
    var arquivo = await _acessarArquivo();

    String data = json.encode(_listaItens);
    arquivo.writeAsString(data);
  }

  _lerArquivo() async {
    try{
      final arquivo = await _acessarArquivo();
      return arquivo.readAsString();
    } catch (error){
      return null;
    }
  }

  @override
    void initState() {
      super.initState();
      _lerArquivo().then((data){
        setState(() {
          _listaItens = json.decode(data);          
        });
      });
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dismissible Widget'),
        backgroundColor: Colors.green,
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, size: 30),
        onPressed: (){
          showDialog(
            context: context, 
            builder: (context){
              return AlertDialog(
                title: Text('Adicionar item'),
                content: TextField(
                  controller: _controllerAdditem,
                  decoration: InputDecoration(
                    labelText: 'Adicionar item'
                  ),
                  onChanged: (campoTextoAddItem){

                  },
                ),

                actions: <Widget>[
                  TextButton(
                    child: Text('Cancelar'),
                    onPressed: () => Navigator.pop(context),
                  ),

                  TextButton(
                    child: Text('Salvar'),
                    onPressed: (){
                      _salvarItem();
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            }
          );
        },
      ),

      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _listaItens.length,
              itemBuilder: (context, index){
                return Dismissible(
                  child: ListTile(
                    title: Text(_listaItens[index]['titulo']),
                  ),

                  background: Container(
                    color: Colors.blue,
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.edit,
                          color: Colors.white,
                        ),
                      ],
                    )
                  ),

                  secondaryBackground: Container(
                    color: Colors.red,
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Icon(Icons.delete_forever,
                          color: Colors.white,
                        )
                      ],
                    )
                  ),

                  key: ValueKey('titulo'),

                  confirmDismiss: (DismissDirection endToStart) async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context){
                        return AlertDialog(
                          title: Text('Confirmação'),
                          content: Text('Deseja realmente excluir este item?'),
                          actions: <Widget>[
                            TextButton(
                              child: Text('Não'),
                              onPressed: () => Navigator.pop(context),
                            ),

                            TextButton(
                              child: Text('Sim'),
                              onPressed: (){
                                setState(() {
                                  _listaItens.removeAt(index);                      
                                });

                                Navigator.pop(context);
                              },
                            )
                          ],
                        );
                      }
                    );
                  },

                );
              }
              
            ),
          ),
        ],
      ),

    );
  }
}