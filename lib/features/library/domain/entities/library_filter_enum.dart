// enum LibraryFilter {
//   all,
//   recent,
//   myBooking,

//   // Owner / Staff
//   newBooking,
//   cancelled,
//   confirmed,
//   rejected,
//   completed,

//   // Time based
//   ongoing,
//   upcoming,
//   past,

//   saved,
// }

// extension LibraryFilterExtension on LibraryFilter {
//   String get displayName {
//     switch (this) {
//       case LibraryFilter.all:
//         return 'All';

//       case LibraryFilter.recent:
//         return 'Recent';

//       case LibraryFilter.myBooking:
//         return 'My Bookings';

//       case LibraryFilter.newBooking:
//         return 'New Bookings';

//       case LibraryFilter.cancelled:
//         return 'Cancelled';
        
//       case LibraryFilter.confirmed:
//         return 'Confirmed';

//       case LibraryFilter.rejected:
//         return 'Rejected';

//       case LibraryFilter.completed:
//         return 'Completed';

//       case LibraryFilter.ongoing:
//         return 'Ongoing';

//       case LibraryFilter.upcoming:
//         return 'Upcoming';

//       case LibraryFilter.past:
//         return 'Past';

//       case LibraryFilter.saved:
//         return 'Saved';
//     }
//   }
// }


enum LibraryFilter {
  all,
  upcoming,
  ongoing,
  past,
  myBooking,
  newBooking,
  confirmed,
  cancelled,
  rejected,
  saved, // For saved posts
  recent;

  String get displayName {
    switch (this) {
      case LibraryFilter.all:
        return 'All';
      case LibraryFilter.upcoming:
        return 'Upcoming';
      case LibraryFilter.ongoing:
        return 'Ongoing';
      case LibraryFilter.past:
        return 'Past';
      case LibraryFilter.myBooking:
        return 'My Bookings';
      case LibraryFilter.newBooking:
        return 'New Bookings';
      case LibraryFilter.confirmed:
        return 'Confirmed';
      case LibraryFilter.cancelled:
        return 'Cancelled';
      case LibraryFilter.rejected:
        return 'Rejected';
      case LibraryFilter.saved:
        return 'Saved';
      case LibraryFilter.recent:
        return 'Recent';
    }
  }
}