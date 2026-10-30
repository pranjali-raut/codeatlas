
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyTeamPage extends StatelessWidget {
  const MyTeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    final leader = FirebaseAuth.instance.currentUser;
    final db = FirebaseFirestore.instance;

    if (leader == null) {
      return const Center(child: Text('Please log in again.'));
    }

    // Same membership field written by ManageTeamPage.
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: db
          .collection('users')
          .where('teamLeaderId', isEqualTo: leader.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Could not load team: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final members = (snapshot.data?.docs ?? [])
            .where((doc) =>
                doc.data()['role'] == 'Developer')
            .toList();

        return LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 600;

            return ListView(
              padding: EdgeInsets.all(compact ? 14 : 24),
              children: [
                const Text(
                  'My Team',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text('${members.length} team member(s)'),
                const SizedBox(height: 18),

                if (members.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(Icons.groups_outlined, size: 48),
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
                            'Open Manage Team, select developers, '
                            'and save your selection.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                ...members.map((memberDoc) {
                  final member = memberDoc.data();
                  final teamId = member['teamId'] as String?;

                  return _MemberCard(
                    db: db,
                    leaderId: leader.uid,
                    memberId: memberDoc.id,
                    memberName:
                        (member['name'] ?? 'Developer').toString(),
                    email: (member['email'] ?? '').toString(),
                    teamId: teamId,
                  );
                }),
              ],
            );
          },
        );
      },
    );
  }
}

class _MemberCard extends StatelessWidget {
  final FirebaseFirestore db;
  final String leaderId;
  final String memberId;
  final String memberName;
  final String email;
  final String? teamId;

  const _MemberCard({
    required this.db,
    required this.leaderId,
    required this.memberId,
    required this.memberName,
    required this.email,
    required this.teamId,
  });

  @override
  Widget build(BuildContext context) {
    if (teamId == null || teamId!.isEmpty) {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(memberName),
          subtitle: Text(email),
          trailing: const Text('No team ID'),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: db
          .collection('tasks')
          .where('teamId', isEqualTo: teamId)
          .snapshots(),
      builder: (context, taskSnapshot) {
        final tasks = taskSnapshot.data?.docs ?? [];

        final memberTasks = tasks.where((doc) {
          final task = doc.data();
          return (task['assignedTo'] ?? task['developerId']) == memberId;
        }).toList();

        final completed = memberTasks.where((doc) {
          return doc.data()['status'] == 'Completed';
        }).length;

        final inProgress = memberTasks.where((doc) {
          return doc.data()['status'] == 'In Progress';
        }).length;

        final assigned = memberTasks.where((doc) {
          return doc.data()['status'] == 'Assigned';
        }).length;

        final total = memberTasks.length;
        final progress = total == 0 ? 0.0 : completed / total;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            memberName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            email,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Remove member',
                      icon: const Icon(Icons.person_remove_alt_1),
                      onPressed: () => _removeMember(context),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                if (taskSnapshot.hasError)
                  const Text('Could not load task progress.')
                else if (!taskSnapshot.hasData)
                  const LinearProgressIndicator()
                else ...[
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    total == 0
                        ? 'No tasks assigned'
                        : '${(progress * 100).round()}% completed '
                            '($completed of $total tasks)',
                  ),
                  Text(
                    'In progress: $inProgress  •  Assigned: $assigned',
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _removeMember(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove team member?'),
        content: Text('Remove $memberName from your team?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final userRef = db.collection('users').doc(memberId);

      await db.runTransaction((transaction) async {
        final snapshot = await transaction.get(userRef);

        if (!snapshot.exists) {
          throw Exception('Developer no longer exists.');
        }

        final data = snapshot.data()!;

        if (data['teamLeaderId'] != leaderId ||
            data['teamId'] != teamId) {
          throw Exception('Team assignment has changed.');
        }

        transaction.update(userRef, {
          'teamLeaderId': null,
          'teamId': null,
        });
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$memberName removed from your team.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not remove member: $e')),
        );
      }
    }
  }
}
