## start

export ENV=poc  

/usr/local/Cellar/openresty/1.13.6.1/nginx/sbin/nginx -p `pwd`/ -c conf/nginx.conf

## stop

/usr/local/Cellar/openresty/1.13.6.1/nginx/sbin/nginx -p `pwd`/ -c conf/nginx.conf -s stop

## postman pre-request script

```
var accesskey = "5aa54a7ddf7db042c95a93a54db5e241ebc3b0c7b70abadafee7d8fe9bf3a7ab";
var secretkey = "be9033ff182b547efe7d7f6da64511507034a7273f8b47175431e3f09577c2dd";
var timestamp = new Date().toUTCString();
postman.setEnvironmentVariable("accesskey", accesskey);
postman.setEnvironmentVariable("timestamp", timestamp);
var kSecret = CryptoJS.lib.WordArray.create(decodeHex(secretkey))
var kDate = CryptoJS.HmacSHA256(timestamp,kSecret);
var sign = CryptoJS.HmacSHA256("rx_request",kDate).toString();
postman.setEnvironmentVariable("sign", sign.toString());


function decodeHex(str){
    var result = [];
    for (var n=0;n<str.length;n+=2){
        var num = parseInt(str.substr(n,2),16)
        result.push(num)
    }
    return new Int8Array(result);

}
```

## deploy

```
grep -q sse4_2 /proc/cpuinfo && echo "SSE 4.2 supported" || echo "SSE 4.2 not supported"
yum install yum-utils
yum-config-manager --add-repo https://openresty.org/package/centos/openresty.repo  
yum install openresty
cd /rc/
git clone http://gogs.in.dataengine.com/FAAS/colosseum-api-gateway.git  
cd colosseum-api-gateway
mkdir logs
ulimit -n 204800
export ENV=prod
openresty -p `pwd`/ -c conf/nginx.conf
```
