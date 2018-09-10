/**
 * avalon 长度限制过滤器
 * @type {{get: Function}}
 */
define(['avalon'], function(avalon){
    avalon.config({
        debug: false
    });
    avalon.duplexHooks.limit = {
        get: function(str, data){
            var limit = parseFloat(data.element.getAttribute('data-duplex-limit'));
            if(str.length > limit){
                return data.element.value = str.slice(0, limit);
            }else{
                return str;
            }
        }
    };
    //avalon.log(avalon);
    return avalon;
});

