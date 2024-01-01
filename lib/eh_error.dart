class EHError {
  static void requireCookie(){
    throw 'COOKIE_REQUIRED';
  }
  static void mysterySetCookie(){
    throw 'SET_COOKIE_WAS_MYSTERY';
  }
  static void mysteryCookie(){
    throw 'COOKIE_HAS_MYSTERY';
  }
  static void requireLogin(){
    throw 'LOGIN_REQUIRED';
  }
}