/**
 * Created by lizhe on 2016/11/28.
 */

require(['avalon','jquery', 'utils', 'jquery.timeago'], function(avalon,$, utils){

    /**
     *  根據樣式更新日期
     */
    avalon.filters.dateFormat = function(timestrap, format){
        return utils.dateFormat(format, timestrap)
    };

    /**
     * 人性化時間顯示
     * @param timestrap
     */
    avalon.filters.humDate = function(timestrap){
        return $.timeago(timestrap * 1000)
    };

    /**
     * 解析emoji表情
     * @param txt
     */
    avalon.filters.parseEmoji = function(txt){
        return twemoji.parse(txt,{size: 16,base:"/Assets/vendor/twemoji/"})
    };

    avalon.filters.sex = function(num){
        var sexArr = {
            1: '男', 2: '女'
        };
        return sexArr[num];
    }

    avalon.filters.tORf = function(value, type){
        if (!type)
            type = 1

        var tfArr
        if (type == 1){
            tfArr = {
                1: '是', 0: '否'
            }
        }
        if (type == 2){
            tfArr = {
                1: '允许', 0: '不允许'
            }
        }
        return tfArr[value];
    }

    avalon.filters.nl2br = function(data) {
        return data.replace(/\n/g, "<br>")
    }

    avalon.filters.platform = function(platform){
        var type = {
            1: '<img src="/images/iqiyi.png" style="height: 15px;" title="爱奇艺" />',
            2: '<img src="/images/fun.ico" style="height: 15px;" title="风行" />',
            3: '<img src="/images/le.png" style="height: 15px;" title="乐视" />',
            4: '<img src="/images/sohu.ico" style="height: 15px;" title="搜狐" />',
            5: '<img src="/images/qq.ico" style="height: 15px;" title="腾讯" />',
            6: '<img src="/images/youku.png" style="height: 15px;" title="优酷" />',
            9: '<img src="/images/youtube.png" style="height: 20px;" title="Youtube" />'
        }
        return type[platform];
    }
});
