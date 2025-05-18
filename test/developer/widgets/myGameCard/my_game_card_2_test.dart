import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/data/game_data.dart';
import 'package:learnvironment/developer/CreateGames/create_drag.dart';
import 'package:learnvironment/developer/widgets/my_game_card.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

class MockDataService extends Mock implements DataService {
  @override
  Future<GameData?> getGameData({required String gameId}) async {
    return GameData(
        gameTemplate: 'drag',
        gameDescription: "",
        gameBibliography: "",
        public: false,
        gameName: "",
        gameLogo: "",
        tags: ["Age: 8+"],
        tips: {
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ_ul1wSpSevyEz0TTsJheg5Qeo2hg8L0A3DA&s": "Brown",
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTDx7Z-4u20EXxhklpwJLCnWuXvRaUiLSjxqg&s": "Yellow",
          "https://img.freepik.com/fotos-gratis/fundo-de-gotas-de-agua_23-2148098971.jpg": "Blue",
          "https://media.istockphoto.com/id/1289562025/pt/vetorial/dark-green-background-with-small-touches-christmas-texture-with-vignette-on-the-sides-and.jpg?s=612x612&w=0&k=20&c=xmBy9D9shmOZSWSC4VqcVM7FJYgTAksKflseJVM3Wxo=": "Green",
        },
        correctAnswers: {
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ_ul1wSpSevyEz0TTsJheg5Qeo2hg8L0A3DA&s": "Brown",
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTDx7Z-4u20EXxhklpwJLCnWuXvRaUiLSjxqg&s": "Yellow",
          "https://img.freepik.com/fotos-gratis/fundo-de-gotas-de-agua_23-2148098971.jpg": "Blue",
          "https://media.istockphoto.com/id/1289562025/pt/vetorial/dark-green-background-with-small-touches-christmas-texture-with-vignette-on-the-sides-and.jpg?s=612x612&w=0&k=20&c=xmBy9D9shmOZSWSC4VqcVM7FJYgTAksKflseJVM3Wxo=": "Green",
        },
        documentName: 'drag-id'
    );
  }
}

void main() {
  testWidgets('tapping edit icon navigates to EditGame', (WidgetTester tester) async {
    Future<void> loadGame(String gameId) async {}

    final widget = MultiProvider(
      providers: [
        Provider<DataService>(create: (_) => MockDataService()),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: MyGameCard(
            imagePath: 'assets/placeholder.png',
            gameTitle: 'Test Game',
            tags: ['Tag1', 'Tag2'],
            gameId: 'g1',
            loadGame: loadGame,
            isPublic: true,
          ),
        )
      )
    );

    await tester.pumpWidget(widget);

    await tester.tap(find.byKey(Key("edit")));
    await tester.pumpAndSettle();

    expect(find.byType(CreateDragPage), findsOneWidget);
  });
}
