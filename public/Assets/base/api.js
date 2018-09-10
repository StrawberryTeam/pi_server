/**
 * Created by xiaosi on 2015/10/7.
 */
define(['require','jquery','avalon'], function(require,$,avalon){
    /**
     * Api请求，默认POST方式
     * @param module 请求模块
     * @param url 请求URL
     * @param pdata 请求的数据
     * @param success 成功的返回
     * @param error 错误处理
     * @param dataType 返回的数据类型，默认为JSON
     */
    var getApi = function(url, pdata, success, error, dataType){
        // 增加参数
        var params = {
            //跳转页面
            'uid': avalon.cookie.get('uid') ? avalon.cookie.get('uid') : 0
        };

        // 模块对应的 url
        // var API_URL = _availableModules[module];
        var API_URL = _siteMain;

        // if (!API_URL)
        //     sysErr('API_URL can not found with module ' + module)

        pdata = $.extend({}, params, pdata);
        avalon.log('getApi start:', url, pdata);
        return $.ajax({
            type: 'POST',
            url:  API_URL + url,
            data: pdata,
            // xhrFields: {
            //     withCredentials: true
            // },
            // crossDomain: true,
            dataType: dataType || 'json',
            success: success || function(data, status, jqXHR){
                //avalon.log('ajax success:', url, data);
            },
            error: error || function(xhr, status, error){
                //avalon.log('ajax error:', status, error);
            }
        });
    };

    var getJsonp = function(module, url, success){
        var API_URL = _availableModules[module];
        // var API_URL = '/api/' + module;
        avalon.log('getJsonp start:', module, url);
        return $.ajax({
            url: API_URL + url,
            jsonp: 'callback',
            dataType: 'jsonp',
            success: success
            //error handling not working with jsonP
            //error: handleError
        });
    };
    return {
        getApi: getApi,
        getJsonp: getJsonp
    };
});
