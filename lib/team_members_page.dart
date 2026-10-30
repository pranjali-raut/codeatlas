
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TeamMembersPage extends StatelessWidget {
  const TeamMembersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final leader = FirebaseAuth.instance.currentUser;

    if (leader == null) {
      return const Center(child: Text('Please log in again.'));
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('teamLeaderId', isEqualTo: leader.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Could not load team members: ${snapshot.error}'),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final members = (snapshot.data?.docs ?? []).where((doc) {
          return (doc.data()['role'] ?? '').toString().toLowerCase() ==
              'developer';
        }).toList();

        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final columns = width >= 1000
                ? 3
                : width >= 650
                    ? 2
                    : 1;

            return SingleChildScrollView(
              padding: EdgeInsets.all(width < 600 ? 14 : 26),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Team Members',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${members.length} developer(s) in your team',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 22),

                      if (members.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.groups_outlined, size: 52),
                              SizedBox(height: 12),
                              Text(
                                'No team members yet',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Open Manage Team and select developers.',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: members.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            mainAxisExtent: 155,
                          ),
                          itemBuilder: (context, index) {
                            final data = members[index].data();
                            final name =
                                (data['name'] ?? 'Unnamed Developer')
                                    .toString();
                            final email = (data['email'] ?? '').toString();

                            return Card(
                              elevation: 1,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: const BorderSide(
                                  color: Color(0xFFEAE7F2),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 25,
                                      backgroundColor:
                                          const Color(0xFFE7C6FF),
                                      child: Text(
                                        name.isNotEmpty
                                            ? name[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF292743),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 7),
                                          Text(
                                            email,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          const Row(
                                            children: [
                                              Icon(
                                                Icons.circle,
                                                size: 9,
                                                color: Colors.green,
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                'Team member',
                                                style: TextStyle(fontSize: 11),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
