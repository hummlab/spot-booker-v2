/// Shared models, utilities, and data structures for Spot Booker applications
library shared;

// Data Providers
export 'src/data_providers/data_providers.dart';

// Utils
export 'src/utils/converters.dart';
export 'src/utils/refs.dart';

// Models
export 'src/models/app_user.dart';
export 'src/models/desk.dart';
export 'src/models/reservation.dart';
export 'src/models/locks/desk_day_lock.dart';
export 'src/models/locks/user_day_lock.dart';