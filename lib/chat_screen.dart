import 'dart:async';

import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

import 'ChatMessage.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  void _sendMessage(){
    ChatMessage _message = ChatMessage(text: _controller.text, sender: "You");
    setState(() {
      _messages.insert(0, _message);
    });
    _controller.clear();

    final request = CompleteReq(prompt: _message.text, model: kTranslateModelV3, max_tokens: 200);
    _subscription = chatGPT!
        .builder("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", orgId: "")
    .onCompleteStream(request: request)
    .listen((response) {
      Vx.log(response!.choices[0].text);
      ChatMessage botMessage =
      ChatMessage(text: response!.choices[0].text, sender: "GPT");

      setState(() {
        _messages.insert(0, botMessage);
      });
    });
  }
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  ChatGPT? chatGPT;

  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Widget _buildTextComposer(){
    return Row(
      children: [
         Expanded(child: TextField(
          controller: _controller,
          onSubmitted: (value) => _sendMessage(),
          decoration: InputDecoration.collapsed(hintText: "type here"),
        ),
        ),
        IconButton(onPressed: () => _sendMessage(),
            icon: const Icon(Icons.send))
      ],
    ).px16();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // elevation: 10,
        // centerTitle: true,
        title: SafeArea(
          child: Row(
          children:<Widget>[
          Text(' CHAT GPT',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 26,
              // color: Colors.black.withOpacity(0.5), //either this or foreground
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              letterSpacing: 7,
            wordSpacing: 5,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2
              ..color = Colors.black,
          ) ,
        ),
            Text(' Integration',
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 10,
            wordSpacing: 100,
            height: 10,
            foreground: Paint()
                ..style = PaintingStyle.stroke
                ..color = Colors.blueGrey[300]!,

            ),
            ),
          ]
        )
    ),
      ),
      body: SafeArea(
        child: Column(
        children: [
          Flexible(child:ListView.builder(
            reverse: true,
            padding: Vx.m8,
            itemCount: _messages.length,
          itemBuilder:(context, index) {
          return _messages[index];
          },
      )),
          Container(decoration: BoxDecoration(
            color: context.cardColor,
          ),
          child: _buildTextComposer(),
          )
        ],
      )
    )
      ,);
  }
}
