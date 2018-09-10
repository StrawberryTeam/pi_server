define(['avalon', 'api', 'jquery'], function(avalon, api, $){

    /**
     *  分页类
     *  currentPage 当前页
     *  totalPage 总页
     *  return pager HTML
     */
    var getPage = function(currentPage, totalPage, urlPath, mod){
        var pathString
        //首先去除 page
        delete urlPath.page
        if ($.isEmptyObject(urlPath)){
            pathString = '?'
        }else{
            pathArr = []
            for (var url in urlPath){
                if (urlPath.hasOwnProperty(url)){
                    pathArr.push(url + '=' + urlPath[url])
                }
            }
            pathString = '?' + pathArr.join('&') + '&'
            delete pathArr
        }
        if (mod)
            pathString = '/' + mod + pathString
            // pathString = '/' + pathString
        var res = '';
        //偏移
        var adjacents = 4;
        //上一页
        var repage = '';
        //下一页
        var nxpage = '';
        //第一页
        var first = '';
        //最后一页
        var last = '';
        //上一页 下一页
        var returnPage = parseInt(currentPage) - 1;
        var nextPage = parseInt(currentPage) + 1;
        repage = '<li class="visible-xs-inline"><a href="#!'+ pathString +'page='+ returnPage + '"><span class="glyphicon glyphicon-menu-left"></span> </a></li>';
        nxpage = '<li class="visible-xs-inline"><a href="#!'+ pathString +'page='+ nextPage +'"> <span class="glyphicon glyphicon-menu-right"></span></a></li>';
        //不显示上一页 or 下一页的情况 第一页或最后一页
        if (currentPage <= 1){
            repage = '';
        }
        if (currentPage >= totalPage){
            nxpage = '';
        }

        //很多页则隐藏
        if (currentPage > (parseInt(adjacents) + 1)) {
            first = '<li><a href="#!'+ pathString +'page=1">1 ...</a></li>';
        }else{
            first = ''
        }

        if (currentPage < (parseInt(totalPage) - parseInt(adjacents))){
            last = '<li><a href="#!'+ pathString +'page='+ totalPage +'">... '+ totalPage +'</a></li>';
        }else{
            last = ''
        }

        // res += first;
        res += repage;
        //所有页码
        for (var i = 1; i <= totalPage; i++) {
            if (i == currentPage) {
                res += '<li class="hidden-xs active"><a href="javascript:;">'+ i +'</a></li>';
            }else if (currentPage > (i + parseInt(adjacents)) || currentPage < (i - parseInt(adjacents))){
            }else{
                res += '<li class="hidden-xs"><a href="#!'+ pathString +'page='+ i +'">'+ i +'</a></li>';
            }
        }
        res += nxpage;
        // res += last;
        return res;
    };


    var getSimplePage = function(currentPage, urlPath, mod){
        var pathString
        //首先去除 page
        delete urlPath.page
        if ($.isEmptyObject(urlPath)){
            pathString = '?'
        }else{
            pathArr = []
            for (var url in urlPath){
                if (urlPath.hasOwnProperty(url)){
                    pathArr.push(url + '=' + urlPath[url])
                }
            }
            pathString = '?' + pathArr.join('&') + '&'
            delete pathArr
        }
        if (mod)
            pathString = '/' + mod + pathString
        // pathString = '/' + pathString
        var res = '';
        //上一页
        var repage = '';
        //下一页
        var nxpage = '';
        //上一页 下一页
        var returnPage = parseInt(currentPage) - 1;
        var nextPage = parseInt(currentPage) + 1;
        repage = '#!'+ pathString +'page='+ returnPage;
        nxpage = '#!'+ pathString +'page='+ nextPage;
        return {'repage': repage, 'nxpage': nxpage}
    };
    return {
        getPage: getPage,
        getSimplePage: getSimplePage
    };
});
