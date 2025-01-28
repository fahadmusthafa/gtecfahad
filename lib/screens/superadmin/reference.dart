// Widget _buildUserList(List<dynamic>? users, bool isLoading, String listType) {
//   if (isLoading) {
//     return const Center(child: CircularProgressIndicator());
//   }
  
//   // Handle both null and empty cases
//   if (users == null || users.isEmpty) {
//     return _buildEmptyState(listType);
//   }
  
//   final filteredUsers = _filterUsers(users);
//   if (filteredUsers.isEmpty) {
//     return _buildEmptyState(listType);
//   }
//   final filteredUsers = _filterUsers(users);
//     return ListView.builder(
//       padding: const EdgeInsets.all(12),
//       itemCount: filteredUsers.length,
//       itemBuilder: (context, index) {
//         final user = filteredUsers[index];
//         final bool isApproved = approvedUsers.contains(user.userId);

//         return Card(
//           elevation: 1,
//           margin: const EdgeInsets.only(bottom: 8),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(12),
//             child: Row(
//               children: [
//                 CircleAvatar(
//                   radius: 20,
//                   backgroundColor: primaryBlue,
//                   child: Text(
//                     user.name[0].toUpperCase(),
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(
//                         user.name,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 14,
//                         ),
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         user.email,
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                       const SizedBox(height: 2),
//                       Row(
//                         children: [
//                           if (user.phoneNumber != null) ...[
//                             Icon(
//                               Icons.phone,
//                               size: 12,
//                               color: Colors.grey[600],
//                             ),
//                             const SizedBox(width: 4),
//                             Text(
//                               user.phoneNumber,
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.grey[600],
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                           ],
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 6,
//                               vertical: 2,
//                             ),
//                             decoration: BoxDecoration(
//                               color: primaryBlue.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                             child: Text(
//                               user.role.toUpperCase(),
//                               style: TextStyle(
//                                 fontSize: 10,
//                                 color: primaryBlue,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 if (listType == 'unapproved')
//                   Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       TextButton(
//                         onPressed: () => _handleApproval(
//                           user.userId,
//                           user.role,
//                           'approve',
//                         ),
//                         style: TextButton.styleFrom(
//                           foregroundColor: Colors.green,
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 16,
//                             vertical: 12,
//                           ),
//                           minimumSize: const Size(80, 40),
//                           textStyle: const TextStyle(fontSize: 14),
//                         ),
//                         child: const Text('Approve'),
//                       ),
//                       TextButton(
//                         onPressed: () => _handleApproval(
//                           user.userId,
//                           user.role,
//                           'reject',
//                         ),
//                         style: TextButton.styleFrom(
//                           foregroundColor: Colors.red,
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 16,
//                             vertical: 12,
//                           ),
//                           minimumSize: const Size(80, 40),
//                           textStyle: const TextStyle(fontSize: 14),
//                         ),
//                         child: const Text('Reject'),
//                       ),
//                     ],
//                   ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
  
 
// }