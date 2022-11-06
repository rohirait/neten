import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
              for (Score score in scores) ...[ScoreView(score: score)]
            ]),
          ),
        ),
      ),
    );
  }
}

class ScoreView extends StatelessWidget {
  final Score score;

  const ScoreView({Key? key, required this.score}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
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
    );
  }
}



class ScoreRequestWidget extends ConsumerWidget{
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We can also use "ref" to listen to a provider inside the build method
    final counter = ref.watch(scoreRequestProvider);
    return counter.when(
      loading: () => SizedBox.shrink(),
      error: (error, stack) => SizedBox.shrink(),
      data: (List<ScoreRequest> data) =>
         Column(
          children: [
            for(ScoreRequest d in data) ...[ScoreRequestView(score: d, email: ref.watch(authenticationProvider).getUser()!.email!,)]
          ]
        )

    );
  }
}

class ScoreRequestView extends StatelessWidget {
  final ScoreRequest score;
  final String email;

  const ScoreRequestView({Key? key, required this.score, required this.email}) : super(key: key);

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
                            createScoreFromRequest(score, email);
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
