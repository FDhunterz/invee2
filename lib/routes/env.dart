
String hostShop = 'http://192.168.100.15/prinvee/';
String clientSecret = '0zxvmtgG2PkVw0NfQ0HwxjKYHVbhoaFBZyDlmJEp';
String clientId = '2';
String grantType = 'password';
String appId = '859057';
String key = "aaf58bdb288796ca641a";
String secret = "c4ab4e43e9c599c3852d";
String cluster = "ap1";

url(String pathname) {
  String host = 'http://192.168.100.15/prinvee/';

  String path = pathname;
  String outp = host + path;

  return outp;
}

urlShop(String pathname) {
  String hostShop = 'http://192.168.100.15/prinvee/';

  String path = pathname;
  String outp = hostShop + path;

  return outp;
}
