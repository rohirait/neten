import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:netten/src/providers/auth_provider.dart';
import 'package:netten/src/providers/score_provider.dart';

import 'package:netten/src/models/score.dart';

import 'package:netten/theme.dart';
import 'package:netten/src/models/score_request.dart';

class GamesList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var user = ref.watch(myScoresProvider);
    return user.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => const Text('Oops'),
      data: (List<Score> scores) => Expanded(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(children: [
              ScoreRequestWidget(),
              Divider(),
              for (Score score in scores) ...[ScoreView(score: score, user: ref.watch(authenticationProvider).getUser()!,)]
            ]),
          ),
        ),
      ),
    );
  }
}

class ScoreView extends StatelessWidget {
  final Score score;
  final User user;
  const ScoreView({Key? key, required this.score, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Slidable(
      endActionPane:  ActionPane(
        motion: ScrollMotion(),
        children: [
          SlidableAction(
      borderRadius: BorderRadius.circular(15.0),
            onPressed: (context){
              showDialog(context: context, builder: (context){
                return AlertDialog(
                  title: const Text('Remove score'),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: const <Widget>[
                        Text('Are you sure you want to remove this score?'),
                        Text('This action is permanent!')
                      ],
                    ),
                  ),
                  actionsAlignment: MainAxisAlignment.spaceBetween,
                  actions: <Widget>[
                    ElevatedButton(onPressed: (){
                      Navigator.of(context).pop();
                    }, child: Text('Cancel', style: TextStyle(color: Colors.black))),
                    TextButton(
                      child:  Text('Delete score',style: TextStyle(color: Colors.black)),
                      onPressed: () {
                        deleteScore(user.uid, score.id!);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              });

            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.archive,
            label: 'Delete',
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(score.opponent, style: Theme.of(context).textTheme.bodyText1,
                        overflow: TextOverflow.ellipsis,),
                      Text(score.date, style: Theme.of(context).textTheme.bodyText2)
                    ]),
                  ),
                  Text(score.yourScore.toString() + " : " + score.opponentScore.toString(),
                      style: Theme.of(context).textTheme.bodyText1?.copyWith(fontSize: 39))
                ],
              ),
            )),
      ),
    );
  }
}



class ScoreRequestWidget extends ConsumerWidget{
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We can also use "ref" to listen to a provider inside the build method
    final scoreRequests = ref.watch(scoreRequestProvider);
    return scoreRequests.when(
      loading: () => SizedBox.shrink(),
      error: (error, stack) => SizedBox.shrink(),
      data: (List<ScoreRequest> data) =>
         Column(
          children: [
            for(ScoreRequest d in data) ...[ScoreRequestView(score: d, user: ref.watch(authenticationProvider).getUser()!,)]
          ]
        )

    );
  }
}

class ScoreRequestView extends StatelessWidget {
  final ScoreRequest score;
  final User user;

  const ScoreRequestView({Key? key, required this.score, required this.user }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(score.opponentName ?? score.opponentEmail, style: Theme.of(context).textTheme.bodyText1,
                          overflow: TextOverflow.ellipsis,),
                        Text(score.date, style: Theme.of(context).textTheme.bodyText2)
                      ]),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(score.yourScore.toString() + " : " + score.opponentScore.toString(),
                        style: Theme.of(context).textTheme.bodyText1?.copyWith(fontSize: 39)),
                    Row(
                      children: [
                        ElevatedButton(
                          child: Icon(Icons.add),
                          onPressed: (){
                            createScoreFromRequest(score, user);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: NetenColor.primaryColor
                          )
                        ),
                        SizedBox(width: 24),
                        ElevatedButton(child: Icon(Icons.clear), onPressed: () {
                          denyScoreRequest(score);
                        },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent
                            )),
                      ],
                    ),
                  ],
                )
              ],
            ),
          )),
    );
  }
}
