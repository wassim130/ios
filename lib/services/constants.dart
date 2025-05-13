// final String baseURL = '10.0.2.2:8000';

final bool localHost = true;

final String baseURL =
    !localHost ? "backend-tests-1.onrender.com" : "10.0.2.2:8000";
final String httpURL = !localHost ? "https://$baseURL" : "http://$baseURL";
const int timeout = 5;
final String websocketAPI = 'ws/chat';
final String websocketGlobalAPI = 'ws/global';
final String authAPI = 'api/auth';
final String userAPI = 'api/user';
final String mdpAPI = 'api/mdp';
final String notificationAPI = 'api/notification';
