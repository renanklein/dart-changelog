part of githelp;

/// Repo baut schlussendlich immer etwas
/// in dieser Art zusammen:
///     http://$baseUrl/$account/$repository/commit/%H
///     http://github.com/MikeMitterer/dart-wsk-material/commit/f98429bc61b9c87261b56283bb8034debdaca919
abstract class Repo {
    String get repository;

    String get account;

    String get baseUrl;

    bool get isValid;

    factory Repo() {
        final Logger _logger = new Logger("githelp.factory.Repo");

        final ProcessResult result = Process.runSync('git', ["config", "--get", "remote.origin.url"]);
        if (result == null || result.stdout.isEmpty || result.exitCode != 0) {
            _logger.fine("Get remote.origin.url faild. ${result.stderr}, using DummyRepo instead!");
            return new _DummyRepo();
        }
        if ((result.stdout as String).contains("github")) {
            return new RepoGitHub(result.stdout as String);
        }

        return new _DummyRepo();
    }

}

class _DummyRepo implements Repo {
    final Logger _logger = new Logger("githelp._DummyRepo");

    String get repository => "";

    String get account => "";

    String get baseUrl => "";

    bool get isValid => false;

    _DummyRepo();
}

class RepoGitHub implements Repo {
    final Logger _logger = new Logger("githelp.RepoGitHub");

    final String _originUrl;

    RepoGitHub(this._originUrl) {
        Validate.notBlank(_originUrl);
    }

    bool get isValid => true;


    String get baseUrl {
        String baseurl = _originUrl.replaceFirst(new RegExp(r"[^@]*@"), "").trim();
        baseurl = baseurl.replaceFirst(new RegExp(r":.*"), "").trim();
        _logger.finer("BaseUrl: $baseurl");
        return baseurl;
    }


    String get account {
        String accountname = _originUrl.replaceFirst(new RegExp(r"[^:]*:"), "").trim();
        accountname = accountname.replaceFirst(new RegExp(r"/.*"), "").trim();
        _logger.finer("AccountName: $accountname");
        return accountname;
    }


    String get repository {
        final String repository = _originUrl.replaceFirst(new RegExp(r"[^/]*/"), "").trim();
        _logger.finer("Repository: $repository");
        return repository;
    }
}