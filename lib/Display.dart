import 'package:flutter/material.dart';
import 'package:word_vault/DictionaryApi.dart';
import 'package:word_vault/apisourcemodel.dart';

class Display extends StatefulWidget {
  const Display({super.key});

  @override
  State<Display> createState() => _Displaystate();
}

class _Displaystate extends State<Display> {
  bool inProgress = false;
  ResponseModel? responseModel;
  String texta = "Explore language effortlessly";

  @override
  Widget build(BuildContext context) {
    TextEditingController _textEditingController = TextEditingController();
    return Container(
      color: Color(0xff99b898),
      child: SafeArea(
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  _buildSearchWidget(),
                  if (inProgress)
                    const LinearProgressIndicator()
                  else if (responseModel != null)
                    Expanded(child: _buildResponseWidget())
                  else
                    _textwidget(),
                ],
              ),
            ),
            backgroundColor: Color(0xff99b898),
          )),
    );
  }

  _buildResponseWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          responseModel!.word!,
          style: TextStyle(
            color: Color(0xff333333),
            fontWeight: FontWeight.bold,
            fontSize: 60,
          ),
        ),
        Text(responseModel!.phonetic ?? ""),
        const SizedBox(height: 16),
        Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                return _buildMeaningWidget(responseModel!.meanings![index]);
              },
              itemCount: responseModel!.meanings!.length,
            ))
      ],
    );
  }

  _buildMeaningWidget(Meanings meanings) {
    String definitionList = "";
    meanings.definitions?.forEach(
          (element) {
        int index = meanings.definitions!.indexOf(element);
        definitionList += "\n${index + 1}. ${element.definition}\n";
      },
    );

    return Card(
      color: Color(0xffff847c),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              meanings.partOfSpeech!,
              style: TextStyle(
                color: Color(0xff2A363B),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 12),
            const Text(

              "Definitions : ",
              style: TextStyle(
                color: Color(0xff2A363B),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(definitionList),
            _buildSet("Synonyms", meanings.synonyms),
            _buildSet("Antonyms", meanings.antonyms),
          ],
        ),
      ),
    );
  }

  _buildSet(String title, List<String>? setList) {
    if (setList?.isNotEmpty ?? false) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title : ",
            style: const TextStyle(
              color: Color(0xff2A363B),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Text(setList!
              .toSet()
              .toString()
              .replaceAll("{", "")
              .replaceAll("}", "")),
          const SizedBox(height: 10),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  _textwidget() {
    return SizedBox(
      height: 100,
      child: Center(
        child: Text(
          texta,
          style: const TextStyle(fontSize: 25),
        ),
      ),
    );
  }

  _buildSearchWidget() {
    return SearchBar(
      backgroundColor: MaterialStateProperty.all(Color(0xfffecea8)) ,

      hintText: "Search word here",

      onSubmitted: (value) {
        _getMeaningFromApi(value);
      },
    );
  }

  _getMeaningFromApi(String word) async {
    setState(() {
      inProgress = true;
    });
    try {
      responseModel = await API.fetchMeaning(word);
      setState(() {});
    } catch (e) {
      responseModel = null;
      texta = "Meaning cannot be fetched";
    } finally {
      setState(() {
        inProgress = false;
      });
    }
  }
}
