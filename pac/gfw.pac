/**
 *   PAC 文件的入口函数，通过该函数指定访问目标地址的连接方式。
 *
 *   @param   {string} url  将要访问的网址（如＂http://www.domain.com：8080/simple.htm＂）。
 *   @param   {string} host 由网址取得的主机名称（如当访问＂http://www.domain.com：8080/simple.htm＂时为＂www.domain.com＂）
 *   @returns {string}      返回一个包含一个或多个访问规则的字符串，多个规则用＂;＂分隔。一个访问规则的字符串可以为以下方式：
 *                            1. "DIRECT".           (表示直接连接)
 *                            2. "PROXY host:port".  (表示使用 HTTP 代理，eg: "PROXY domain.com:7070")
 *                            3. "SOCKS host:port".  (表示使用 SOCKS 代理，eg: "SOCKS localhost:7070")
 *                            4. "SOCKS5 host:port". (表示使用 SOCKS5 代理，eg: "SOCKS5 127.0.0.1:7070")
 */
function FindProxyForURL(url, host){
    
    var RESULT_SOCKS5 = "SOCKS5 localhost:3658";
    
    var proxy_list = [
        "google.com",
        "google.com.hk",
        "googleapis.com",
        "facebook.com",
        "twitter.com",
        "youtube.com",
        "gstatic.com",
        "ytimg.com",
        "python.com",
    ];
    
    for( index=0;index<proxy_list.length;index++ ) {
        if( dnsDomainIs(host, proxy_list[index]) ) {
            return RESULT_SOCKS5;
        }
    }
    
    return "DIRECT";
    
}

