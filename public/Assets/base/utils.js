define(['jquery', 'avalon.cookie'], function($){

    /**
     * 跳转
     * @param url
     */
    var redirect = function(url){
        if (!url){
            url = '/';
        }

        // window.location.replace(url);
        window.location.href = url;
    };
    /**
     * 子域名信息
     */
    var getDomain = function(){
        //site namespace
        var cookies = avalon.cookie;
        return JSON.parse(cookies.get("_domainUrls"));
    };

    /**
     * 通过邮箱取 邮箱登录地址
     */
    var getEmailLoginUrl = function(email){
        //邮箱登录地址
        var trueEmail = email.split('@');
        return '//mail.' + trueEmail[1];
    };

    /**
     * 验证手机号码
     * @param mobile
     */
    var isMobile = function(mobile){
        return /^1\d{10}$/.test(mobile);
    };
    var cutStr   = function(str,len){
        var str_length = 0;
        var str_len = 0;
        var str_cut = new String();
        str_len = str.length;
        for(var i = 0;i<str_len;i++)
        {
            var a = str.charAt(i);
            str_length++;
            if(escape(a).length > 4)
            {
                //中文字符的长度经编码之后大于4
                str_length++;
            }
            str_cut = str_cut.concat(a);
            if(str_length>=len)
            {
                //str_cut = str_cut.concat("...");
                return str_cut;
            }
        }
        //如果给定字符串小于指定长度，则返回源字符串；
        if(str_length<len){
            return  str;
        }
    };
    var strLength = function(str)
    {
        var l = 0;
        str || (str='');

        return str.length;
    };

    var isZh = function(str)
    {
        var re = /[^\u4e00-\u9fa5]/;
        if(re.test(str)) return false;
        return true;
    };
    var dateFormat=function (format, timestamp) {
        var that = this;
        var jsdate, f;
        var txt_words = [
            'Sun', 'Mon', 'Tues', 'Wednes', 'Thurs', 'Fri', 'Satur',
            'January', 'February', 'March', 'April', 'May', 'June',
            'July', 'August', 'September', 'October', 'November', 'December'
        ];
        var formatChr = /\\?(.?)/gi;
        var formatChrCb = function(t, s) {
            return f[t] ? f[t]() : s;
        };
        var _pad = function(n, c) {
            n = String(n);
            while (n.length < c) {
                n = '0' + n;
            }
            return n;
        };
        f = {
            d: function() {
                return _pad(f.j(), 2);
            },
            D: function() {
                return f.l()
                    .slice(0, 3);
            },
            j: function() {
                return jsdate.getDate();
            },
            l: function() {
                return txt_words[f.w()] + 'day';
            },
            N: function() {
                return f.w() || 7;
            },
            S: function() {
                var j = f.j();
                var i = j % 10;
                if (i <= 3 && parseInt((j % 100) / 10, 10) == 1) {
                    i = 0;
                }
                return ['st', 'nd', 'rd'][i - 1] || 'th';
            },
            w: function() {
                return jsdate.getDay();
            },
            z: function() {
                var a = new Date(f.Y(), f.n() - 1, f.j());
                var b = new Date(f.Y(), 0, 1);
                return Math.round((a - b) / 864e5);
            },

            W: function() {
                var a = new Date(f.Y(), f.n() - 1, f.j() - f.N() + 3);
                var b = new Date(a.getFullYear(), 0, 4);
                return _pad(1 + Math.round((a - b) / 864e5 / 7), 2);
            },

            F: function() {
                return txt_words[6 + f.n()];
            },
            m: function() {
                return _pad(f.n(), 2);
            },
            M: function() {
                return f.F()
                    .slice(0, 3);
            },
            n: function() {
                return jsdate.getMonth() + 1;
            },
            t: function() {
                return (new Date(f.Y(), f.n(), 0))
                    .getDate();
            },


            L: function() {
                var j = f.Y();
                return j % 4 === 0 & j % 100 !== 0 | j % 400 === 0;
            },
            o: function() { // ISO-8601 year
                var n = f.n();
                var W = f.W();
                var Y = f.Y();
                return Y + (n === 12 && W < 9 ? 1 : n === 1 && W > 9 ? -1 : 0);
            },
            Y: function() {
                return jsdate.getFullYear();
            },
            y: function() {
                return f.Y()
                    .toString()
                    .slice(-2);
            },

            // Time
            a: function() {
                return jsdate.getHours() > 11 ? 'pm' : 'am';
            },
            A: function() {
                return f.a().toUpperCase();
            },
            B: function() {
                var H = jsdate.getUTCHours() * 36e2;
                // Hours
                var i = jsdate.getUTCMinutes() * 60;
                // Minutes
                var s = jsdate.getUTCSeconds(); // Seconds
                return _pad(Math.floor((H + i + s + 36e2) / 86.4) % 1e3, 3);
            },
            g: function() { // 12-Hours; 1..12
                return f.G() % 12 || 12;
            },
            G: function() { // 24-Hours; 0..23
                return jsdate.getHours();
            },
            h: function() { // 12-Hours w/leading 0; 01..12
                return _pad(f.g(), 2);
            },
            H: function() { // 24-Hours w/leading 0; 00..23
                return _pad(f.G(), 2);
            },
            i: function() { // Minutes w/leading 0; 00..59
                return _pad(jsdate.getMinutes(), 2);
            },
            s: function() { // Seconds w/leading 0; 00..59
                return _pad(jsdate.getSeconds(), 2);
            },
            u: function() { // Microseconds; 000000-999000
                return _pad(jsdate.getMilliseconds() * 1000, 6);
            },

            // Timezone
            e: function() {
                throw 'Not supported (see source code of date() for timezone on how to add support)';
            },
            I: function() { // DST observed?; 0 or 1
                var a = new Date(f.Y(), 0);
                // Jan 1
                var c = Date.UTC(f.Y(), 0);
                // Jan 1 UTC
                var b = new Date(f.Y(), 6);
                // Jul 1
                var d = Date.UTC(f.Y(), 6); // Jul 1 UTC
                return ((a - c) !== (b - d)) ? 1 : 0;
            },
            O: function() { // Difference to GMT in hour format; e.g. +0200
                var tzo = jsdate.getTimezoneOffset();
                var a = Math.abs(tzo);
                return (tzo > 0 ? '-' : '+') + _pad(Math.floor(a / 60) * 100 + a % 60, 4);
            },
            P: function() { // Difference to GMT w/colon; e.g. +02:00
                var O = f.O();
                return (O.substr(0, 3) + ':' + O.substr(3, 2));
            },
            T: function() {
                return 'UTC';
            },
            Z: function() { // Timezone offset in seconds (-43200...50400)
                return -jsdate.getTimezoneOffset() * 60;
            },

            // Full Date/Time
            c: function() { // ISO-8601 date.
                return 'Y-m-d\\TH:i:sP'.replace(formatChr, formatChrCb);
            },
            r: function() { // RFC 2822
                return 'D, d M Y H:i:s O'.replace(formatChr, formatChrCb);
            },
            U: function() { // Seconds since UNIX epoch
                return jsdate / 1000 | 0;
            }
        };
        this.date = function(format, timestamp) {
            that = this;
            jsdate = (timestamp === undefined ? new Date() : // Not provided
                    (timestamp instanceof Date) ? new Date(timestamp) : // JS Date()
                        new Date(timestamp * 1000) // UNIX timestamp (auto-convert to int)
            );
            return format.replace(formatChr, formatChrCb);
        };
        return this.date(format, timestamp);
    };

    //预览图片png,jpg,gif(不支持ie6)
    function imagePreview(file,width,height){
        if(file.type=='image/gif'){
            var preloader = new mOxie.FileReader();
            var image = $(new Image()).appendTo($('#pic_'+file.id));
            preloader.onload = function(e){
                image.prop('src',e.target.result);
                image.prop('width',width||96);
                image.prop('heigth',height||96);
            }
            preloader.onerror = function(e){
                this.destroy();
            }
            preloader.onloadend = function(e){
                this.destroy();
            }
            preloader.readAsDataURL(file.getSource());
        }else{
            var preloader = new mOxie.Image();
            preloader.onload = function() {
                this.embed('pic_'+file.id, {
                    width: width||96,
                    height: height||96,
                    crop:true,
                    swf_url: o.resolveUrl('/Assets/vendor/plupload/Moxie.swf')
                });
            };
            preloader.onembedded = function(){
                this.destroy();
            };
            preloader.onerror = function(){
                this.destroy();
            };
            preloader.load(file.getSource());
        }
    };

    /**
     *  字节 显示
     */
    var byte2size = function(byte){

        //alert(byte);
        if (byte < 1024){
            //字节
            return byte + 'B';
        }

        if (byte < (1024 * 1000)){
            //KB
            return (byte / 1024).toFixed(0) + 'KB';
        }

        if (byte < (1024 * 1000 * 1000)){
            //MB
            return (byte / (1024 * 1000)).toFixed(0) + 'MB';
        }

        if (byte < (1024 * 1000 * 1000 * 1000)){
            //GB
            return (byte / (1024 * 1000 * 1000)).toFixed(0) + 'GB';
        }
    };

    //winterspring 插件转换为 html
    var plugin2html = function (html){
        var autoplay, controls, hasImageView, hasVideojs, height, i, id, imageViewJsScript, isPlugin, len, preload, script, src, type, v, videoJsScript, width;

        isPlugin = html.match(/<ws.*?>.*?<\/ws>/g);

        hasVideojs = false;

        videoJsScript = '<!--#ws_videojs-->';

        hasImageView = false;

        imageViewJsScript = '<!--#ws_imageview-->';

        if (isPlugin) {
            for (i = 0, len = isPlugin.length; i < len; i++) {
                v = isPlugin[i];
                type = v.match(/data-type="(.*?)"/)[1];
                if (v.match(/data-src="(.*?)"/)) {
                    src = v.match(/data-src="(.*?)"/)[1];
                }
                if (v.match(/data-id="(.*?)"/)) {
                    id = v.match(/data-id="(.*?)"/)[1];
                }
                width = v.match(/width="(.*?)"/) ? v.match(/width="(.*?)"/)[1] : '100%';
                height = v.match(/height="(.*?)"/) ? v.match(/height="(.*?)"/)[1] : '500px';
                if ('videojs' === type) {
                    hasVideojs = true;
                    controls = v.indexOf('controls') ? 'controls' : '';
                    autoplay = v.indexOf('autoplay') ? 'autoplay' : '';
                    preload = v.indexOf('preload') ? 'preload' : '';
                    script = '<video id="' + id + '" class="video-js vjs-default-skin  vjs-big-play-centered" ' + controls + ' ' + preload + ' width="' + width + '" height="' + height + '" data-setup="{}"><source src="' + src + '" type="video/mp4"></video>';
                    html = html.replace(v, script);
                }
                if ('imageview' === type) {
                    hasImageView = true;
                    script = '<img src="' + src + '?imageView2/1/w/' + width + '/h/' + height + '" data-action="zoom" data-original="' + src + '" />';
                    html = html.replace(v, script);
                }
            }
            if (true === hasVideojs) {
                html = html.replace(new RegExp(videoJsScript + '.*?' + videoJsScript, 'g'), '');
                html += videoJsScript + '<script src="' + _availableModules['straw'] + '/Assets/vendor/videojs/videojs.js"></script><link href="' + _availableModules['straw'] + '/Assets/vendor/videojs/video.css" rel="stylesheet"><script>setTimeout(function(){videojs.options.flash.swf = "' + _availableModules['straw'] + '/Assets/vendor/videojs/video-js.swf";}, 500)</script>' + videoJsScript;
            }
            if (true === hasImageView) {
                html = html.replace(new RegExp(imageViewJsScript + '.*?' + imageViewJsScript, 'g'), '');
                html += imageViewJsScript + '<script src="' + _availableModules['straw'] + '/Assets/vendor/zoom/zoom.js"></script><link href="' + _availableModules['straw'] + '/Assets/vendor/zoom/zoom.css" rel="stylesheet">' + imageViewJsScript;
            }
        }

        return html;
    };

    //转换 doc [] => a
    var formatDocLink = function(html){

        // $textLink = '/\[(.*?)\]/is';
        // $realLink = '<a href="/#!/winterspring:book?name=$1" style="color: #ce4844;">[$1]</a>';
        // //preg_match_all('/\[(.*?)\]/is', $data, $out_data);
        // return preg_replace($textLink, $realLink, $data);

        html = html.replace(new RegExp(/\[\[(.*?)\]\]/, 'g'), '<a href="/#!/winterspring:book?name=$1" style="color: #ce4844;">[$1]</a>');

        return html;
    };

    return {
        plugin2html: plugin2html,
        redirect: redirect,
        byte2size: byte2size,
        getEmailLoginUrl: getEmailLoginUrl,
        getDomain: getDomain,
        isMobile: isMobile,
        strLength: strLength,
        cutStr: cutStr,
        dateFormat: dateFormat,
        isZh: isZh,
        imagePreview: imagePreview,
        formatDocLink: formatDocLink
    }
});
