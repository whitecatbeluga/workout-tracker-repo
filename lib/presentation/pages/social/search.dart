import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/data/repositories_impl/social_repository_impl.dart';
import 'package:workout_tracker_repo/routes/social/social.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String searchQuery = '';

  Future<void> loadRecentProfiles() async {
    final results = await SocialRepositoryImpl(
      FirebaseFirestore.instance,
    ).fetchRecents();

    setState(() {
      recentResults = results;
    });
  }

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }
    final results = await SocialRepositoryImpl(
      FirebaseFirestore.instance,
    ).searchUsers(query);
    setState(() {
      searchResults = results;
    });
  }

  TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _handleClearAll() async {
    await SocialRepositoryImpl(FirebaseFirestore.instance).clearAllRecents();
    setState(() {
      recentResults = [];
    });
  }

  List<Map<String, dynamic>> searchResults = []; // filled by search
  List<Map<String, dynamic>> recentResults = []; // filled by fetchRecents()

  @override
  void initState() {
    super.initState();
    loadRecentProfiles();
  }

  @override
  Widget build(BuildContext context) {
    final showRecent = searchQuery.isEmpty;
    final data = showRecent ? recentResults : searchResults;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Padding(
          padding: EdgeInsets.only(right: 20),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Search...',
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Colors.grey),
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: (query) {
                setState(() {
                  searchQuery = query;
                });

                if (query.isNotEmpty && query[0] != query[0].toUpperCase()) {
                  String newText = query[0].toUpperCase() + query.substring(1);
                  controller.value = controller.value.copyWith(
                    text: newText,
                    selection: TextSelection.collapsed(offset: newText.length),
                  );
                  return;
                }

                if (query.isEmpty) {
                  loadRecentProfiles();
                } else {
                  searchUsers(query);
                }
              },
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 20, right: 15, top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF323232),
                    ),
                  ),
                  TextButton(
                    onPressed: _handleClearAll,
                    child: Text(
                      'Clear All',
                      style: TextStyle(
                        color: Color(0xFF48A6A7),
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: data.isEmpty
                    ? Center(
                        child: Text(
                          showRecent ? 'No recent profiles' : 'No results',
                        ),
                      )
                    : ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final user = data[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                                  (user['account_picture'] != null &&
                                      (user['account_picture'] as String)
                                          .isNotEmpty)
                                  ? NetworkImage(
                                      user['account_picture'] as String,
                                    )
                                  : null,
                              child:
                                  (user['account_picture'] == null ||
                                      (user['account_picture'] as String)
                                          .isEmpty)
                                  ? Text(
                                      (user['first_name'] != null &&
                                              (user['first_name'] as String)
                                                  .isNotEmpty)
                                          ? (user['first_name'] as String)[0]
                                                .toUpperCase()
                                          : '?',
                                    )
                                  : null,
                            ),

                            title: Text(
                              '${user['first_name']} ${user['last_name']}',
                            ),
                            subtitle: Text(user['email']),
                            onTap: () async {
                              final currentUser = _auth.currentUser;
                              if (currentUser != null && !showRecent) {
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(currentUser.uid)
                                    .collection('recents')
                                    .doc(user['id'])
                                    .set({"searched_at": Timestamp.now()});
                              }
                              Navigator.pushNamed(
                                context,
                                SocialRoutes.visitProfile,
                                arguments: {
                                  'id': user['id'],
                                  'firstName': user['first_name'],
                                  'lastName': user['last_name'],
                                  'userName': user['user_name'],
                                  'email': user['email'],
                                },
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
