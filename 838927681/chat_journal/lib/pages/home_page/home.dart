import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../models/chat.dart';
import '../../models/event.dart';
import '../../models/icon_map.dart';

import '../../theme/colors.dart';
import '../../theme/fonts.dart';
import '../../theme/theme_cubit.dart';
import '../../widgets/questionnaire_bot.dart';
import '../chat_page/chat_page.dart';
import '../create_chat_page/create_chat_page.dart';
import 'home_page_cubit.dart';
import 'home_page_state.dart';

final _chats = <Chat>[
  Chat(
      name: 'Travel',
      iconIndex: 0,
      creationDate: DateTime.now().subtract(const Duration(days: 1)),
      events: []),
  Chat(
    name: 'Family',
    iconIndex: 1,
    creationDate: DateTime.now().subtract(const Duration(days: 2)),
    events: [
      Event(
          text: 'My Family',
          dateTime: DateTime.now().subtract(const Duration(hours: 24))),
      Event(text: 'My big big family', dateTime: DateTime.now()),
    ],
  ),
  Chat(
      name: 'Sport',
      iconIndex: 2,
      events: [],
      creationDate: DateTime.now().subtract(const Duration(days: 3))),
];

class HomePage extends StatefulWidget {
  final homePageCubit = HomePageCubit();

  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => widget.homePageCubit,
      child: Stack(
        children: [
          Column(
            children: [
              QuestionnaireBotButton(),
              Expanded(child: _journalList(widget.homePageCubit)),
            ],
          ),
          _floatingActionButton(widget.homePageCubit),
        ],
      ),
    );
  }

  Widget _journalList(HomePageCubit cubit) {
    return BlocBuilder<HomePageCubit, HomePageState>(
      builder: (context, state) {
        cubit.loadChats(_chats);
        return Column(
          children: [
            _divider(),
            Flexible(
              child: ListView.builder(
                itemCount: cubit.state.chats.length,
                padding: const EdgeInsets.all(0.0),
                itemBuilder: (context, i) {
                  final chat = cubit.state.chats[i];
                  return _chatElement(chat, i);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _chatElement(Chat chat, int i) {
    return GestureDetector(
      onTap: () async {
        final newChat = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(chat: chat),
          ),
        );
        setState(() {
          widget.homePageCubit.updateChats(newChat, i);
        });
      },
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return _chatMenu(chat, i);
          },
        );
      },
      child: Column(
        children: [
          ListTile(
            title: Text(
              chat.name,
              style: Fonts.mainPageChatTitle,
            ),
            subtitle: Text(
              chat.events.isNotEmpty
                  ? chat.events[chat.events.length - 1].text
                  : 'No events, Click to create one',
            ),
            leading: _chatIcon(chat),
          ),
          _divider(),
        ],
      ),
    );
  }

  Widget _chatIcon(Chat chat) {
    final color = BlocProvider.of<ThemeCubit>(context).isLight()
        ? Colors.blueGrey
        : ChatJournalColors.lightGray;
    return SizedBox(
      width: 50,
      height: 50,
      child: Ink(
        decoration: ShapeDecoration(
          color: color,
          shape: const CircleBorder(),
        ),
        child: Icon(
          ChatJournalIcons.icons[chat.iconIndex],
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _divider() {
    return const Divider(
      color: Colors.grey,
      thickness: 1,
    );
  }

  Widget _chatMenu(Chat chat, int i) {
    return Container(
      height: 250,
      child: Column(
        children: [
          _infoMenuElement(chat),
          _chatMenuElement(
            chat,
            'Pin/Unpin Page',
            Icons.pin_drop,
            Colors.green,
          ),
          _chatMenuElement(
            chat,
            'Archive Page',
            Icons.archive,
            ChatJournalColors.accentYellow,
          ),
          _editMenuElement(chat, i),
          _deleteMenuElement(chat),
        ],
      ),
    );
  }

  Widget _infoMenuElement(Chat chat) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) {
            return _infoModal(chat);
          },
        );
      },
      child: _chatMenuElement(
        chat,
        'Info',
        Icons.info,
        ChatJournalColors.green,
      ),
    );
  }

  Widget _infoModal(Chat chat) {
    return AlertDialog(
      title: Row(
        children: [
          _chatIcon(chat),
          const SizedBox(width: 10),
          Text(
            chat.name,
            style: Fonts.createChatTitle,
          ),
        ],
      ),
      content: Container(
        constraints: const BoxConstraints(maxHeight: 150),
        child: Column(
          children: [
            _chatInfo('Created', chat.creationDate),
            _chatInfo(
              'Latest Event',
              chat.events.isNotEmpty
                  ? chat.events.last.dateTime
                  : chat.creationDate,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('OK', style: Fonts.chatMenuFont),
        ),
      ],
    );
  }

  Widget _chatInfo(String text, DateTime date) {
    return ListTile(
        title: Text(
          text,
          style: Fonts.eventFont,
        ),
        subtitle: Text(
          DateFormat.yMd().add_jm().format(date),
        ));
  }

  Widget _editMenuElement(Chat chat, i) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CreateChatPage(
              isCreatingMode: false,
              chat: chat,
            ),
          ),
        );
        if (result != null) {
          setState(() {
            widget.homePageCubit.updateChats(result, i);
          });
        }
        Navigator.pop(context);
      },
      child: _chatMenuElement(
        chat,
        'Edit Page',
        Icons.edit,
        Colors.blue,
      ),
    );
  }

  Widget _deleteMenuElement(Chat chat) {
    return GestureDetector(
      onTap: () {
        setState(() {
          widget.homePageCubit.deleteChat(chat);
        });
        Navigator.pop(context);
      },
      child: _chatMenuElement(
        chat,
        'Delete Page',
        Icons.delete,
        ChatJournalColors.lightRed,
      ),
    );
  }

  Widget _chatMenuElement(
      Chat chat, String name, IconData iconData, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 15,
      ),
      child: Row(
        children: [
          Icon(
            iconData,
            color: color,
            size: 30,
          ),
          const SizedBox(width: 30),
          Text(
            name,
            style: Fonts.chatMenuFont,
          )
        ],
      ),
    );
  }

  Widget _floatingActionButton(HomePageCubit cubit) {
    return AnimatedPositioned(
      child: FloatingActionButton(
        //backgroundColor: Theme.of(context).floatingActionButtonTheme.backgroundColor,
        child: const Icon(
          Icons.add,
          size: 30,
        ),
        onPressed: () async {
          final newChat = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateChatPage(isCreatingMode: true),
              ));
          if (newChat != null) {
            setState(() {
              cubit.addChat(newChat);
            });
          }
        },
      ),
      duration: const Duration(milliseconds: 300),
      right: 20,
      bottom: 20,
    );
  }
}