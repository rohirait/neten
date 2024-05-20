import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netten/src/providers/client_provider.dart';
import 'package:netten/src/providers/friends_provider.dart';
import 'package:netten/theme.dart';
import 'package:netten/util.dart';

import '../../models/client.dart';
import '../../models/friend.dart';

class SearchFriendScreen extends StatefulWidget {
  const SearchFriendScreen({Key? key}) : super(key: key);

  @override
  _SearchFriendScreenState createState() => _SearchFriendScreenState();

}

class _SearchFriendScreenState extends State<SearchFriendScreen> {
  TextEditingController _searchController = TextEditingController();
  Set<DocumentSnapshot> _searchResults = {};

  Future<void> _searchFriends(String searchText, Client? client) async {
    if (searchText.length >= 3) {
      searchText = searchText.toLowerCase();
      Set<String> uniqueUserIds = {}; // Set to store unique user IDs

      QuerySnapshot firstNameResults = await FirebaseFirestore.instance
          .collection('users')
          .where('firstName', isGreaterThanOrEqualTo: searchText)
          .where('firstName', isLessThan: searchText + 'z')
          .get();

      QuerySnapshot lastNameResults = await FirebaseFirestore.instance
          .collection('users')
          .where('lastName', isGreaterThanOrEqualTo: searchText)
          .where('lastName', isLessThan: searchText + 'z')
          .get();

      QuerySnapshot fullNameResults = await FirebaseFirestore.instance
          .collection('users')
          .where('fullName', isGreaterThanOrEqualTo: searchText)
          .where('fullName', isLessThan: searchText + 'z')
          .get();

      // Add unique user IDs to the set
      firstNameResults.docs.forEach((doc) => uniqueUserIds.add(doc.id));
      lastNameResults.docs.forEach((doc) => uniqueUserIds.add(doc.id));
      fullNameResults.docs.forEach((doc) => uniqueUserIds.add(doc.id));

      if(client != null && client.uid != null)
        uniqueUserIds.remove(client.uid);
      // Fetch unique user documents based on unique user IDs
      List<DocumentSnapshot> uniqueUserDocs = [];
      for (var userId in uniqueUserIds) {
        var userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
        if (userDoc.exists) {
          uniqueUserDocs.add(userDoc);
        }
      }

      setState(() {
        _searchResults = Set.from(uniqueUserDocs);
      });
    } else {
      setState(() {
        _searchResults.clear(); // Clear the search results if searchText length is less than 3
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NetenColor.backgroundColor,
      appBar: AppBar(
        backgroundColor: NetenColor.primaryColor,
        title: Text('Search Friends'),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          Client? client = ref.read(clientProvider).value;
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(labelText: 'Search Friend'),
                  onChanged: (value) {
                    _searchFriends(value, client);
                  },
                ),
                SizedBox(height: 20),
                _searchResults.isNotEmpty
                    ? Expanded(
                        child: ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            var user = _searchResults.elementAt(index).data() as Map<String, dynamic>;
                            return InkWell(
                              onTap: (){
                                showLoading(context);
                                List<Friend>? friends = ref.watch(friendsStreamProvider).value;
                                bool? add = friends?.any((friend) => friend.email == user['email']);
                                Navigator.of(context).pop();
                                if(add == true){
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(user['fullName'].toString().capitalizeFirstLetterOfWords()+' is already your friend!'),
                                      duration: Duration(seconds: 2), // You can customize the duration as needed
                                    ),
                                  );
                                } else if (add == false){
                                  addFriend(email: user['email']!, name: user['fullName'].toString().capitalizeFirstLetterOfWords(), user: client);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(user['fullName'].toString().capitalizeFirstLetterOfWords()+' added as a friend!'),
                                      duration: Duration(seconds: 2), // You can customize the duration as needed
                                    ),
                                  );
                                  List<DocumentSnapshot> resultList = _searchResults.toList();
                                  resultList.removeAt(index);
                                  setState(() {
                                    _searchResults = resultList.toSet();
                                  });
                                }
                              },
                              child: SizedBox(
                                width: double.infinity,
                                child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: Center(child: Text('${user['fullName'].toString().capitalizeFirstLetterOfWords()}' , style: Theme.of(context).textTheme.bodyLarge)),
                                    )),
                              ),
                            );
                          },
                        ),
                      )
                    : SizedBox(),
              ],
            ),
          );
        }
      ),
    );
  }
}
