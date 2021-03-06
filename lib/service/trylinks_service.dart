import 'dart:async';
import 'dart:convert';

import 'dart:html';
import 'package:angular/angular.dart';
import 'package:http/browser_client.dart';

@Injectable()
class TryLinksService {
  final BrowserClient _http;
  static final _headers = {'Content-Type': 'application/json'};
  static final serverURL =
      const String.fromEnvironment('Service', defaultValue: 'http://localhost');
  static final serverAddr = serverURL + ':5000';
  static final String _signupUrl = serverAddr + '/api/user/signup';
  static final String _loginUrl = serverAddr + '/api/user/login';
  static final String _updateUserUrl = serverAddr + '/api/user/update';
  static final String _interactiveUrl = serverAddr + '/api/initInteractive';
  static final String _compileUrl = serverAddr + '/api/compile';
  static final String _fileReadUrl = serverAddr + '/api/file/read';
  static final String _fileWriteUrl = serverAddr + '/api/file/write';
  static final String _logoutUrl = serverAddr + '/api/logout';

  TryLinksService(this._http);

  String getUsername() => window.localStorage.containsKey('username')
      ? window.localStorage['username']
      : null;

  String getLastTutorial() => window.localStorage.containsKey('last_tutorial')
      ? window.localStorage['last_tutorial']
      : null;

  Future<bool> signup(String username, String email, String password) async {
    try {
      final response = await _http.post(_signupUrl,
          headers: _headers,
          body: JSON.encode({
            'username': username,
            'email': email,
            'password': password,
          }));
      return response.statusCode == 200;
    } catch (e) {
      print("Signup API failed with the following detail:\n");
      print(e.toString());
      return false;
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      final response = await _http.post(_loginUrl,
          headers: _headers,
          body: JSON.encode({
            'username': username,
            'password': password,
          }));
      if (response.statusCode == 200) {
        var result = JSON.decode(response.body);
        window.localStorage['username'] = username;
        window.localStorage['last_tutorial'] = result["data"]["last_tutorial"];
      }
      return response.statusCode == 200;
    } catch (e) {
      print("Login API failed with the following detail:\n");
      print(e.toString());
      return false;
    }
  }

  Future<bool> updateUser(
      {String email, String password, int lastTutorial}) async {
    try {
      final response = await _http.post(_updateUserUrl,
          headers: _headers,
          body: JSON.encode({
            'email': email,
            'password': password,
            'last_tutorial': lastTutorial,
          }));
      if (response.statusCode == 200) {
        var result = JSON.decode(response.body);
        window.localStorage['last_tutorial'] = result["data"]["last_tutorial"];
      }
      return response.statusCode == 200;
    } catch (e) {
      print("Update User API failed with the following detail:\n");
      print(e.toString());
      return false;
    }
  }

  Future<String> startInteractiveMode() async {
    try {
      final response = await _http.get(_interactiveUrl, headers: _headers);
      final socketPath = JSON.decode(response.body)['path'];
      return socketPath;
    } catch (e) {
      print("InteractiveUrl API failed with the following detail:\n");
      print(e.toString());
      return null;
    }
  }

  Future<String> compileAndDeploy() async {
    try {
      final response = await _http.get(_compileUrl, headers: _headers);
      final socketPath = JSON.decode(response.body)['path'];
      return socketPath;
    } catch (e) {
      print("InteractiveUrl API failed with the following detail:\n");
      print(e.toString());
      return null;
    }
  }

  Future<String> getTutorialSource(int id) async {
    try {
      final response = await _http.post(_fileReadUrl,
          headers: _headers, body: JSON.encode({'tutorial': id}));
      if (response.statusCode == 200) {
        var result = JSON.decode(response.body);
        return result["fileData"];
      } else {
        return null;
      }
    } catch (e) {
      print("File Read API failed");
      print(e.toString());
      return null;
    }
  }

  Future<bool> saveTutorialSource(int id, String source) async {
    try {
      final response = await _http.post(_fileWriteUrl,
          headers: _headers,
          body: JSON.encode({
            'tutorial': id,
            'fileData': source,
          }));
      return response.statusCode == 200;
    } catch (e) {
      print("File Read API failed");
      print(e.toString());
      return false;
    }
  }

  Future<bool> logout() async {
    window.localStorage.remove('username');
    window.localStorage.remove('last_tutorial');
    try {
      await _http.get(_logoutUrl, headers: _headers);
      return true;
    } catch (e) {
      print("Logout API failed with the following detail:\n");
      print(e.toString());
      return null;
    }
  }
}
