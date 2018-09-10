html = '<p style="text-align: center;"><div id="h3"></div><ws data-type="videojs" data-id="a3" controls data-src="http://cms-test.cdn.xwg.cc/o_1bj74nv8jipsm98relm021m6ta.mp4" width="900px" height="400px"></ws></p><p style="text-align: center;"><small>VideoName</small></p><h1>标签</h1><p style="text-align: center;"><div id="h4"></div><ws data-type="videojs" data-src="http://cms-test.cdn.xwg.cc/o_1bj73sbd6d4afkr14udedtrd14.mp4" data-id="a4" controls width="900px" height="400px"></ws></p><p style="text-align: center;"><small>VideoName</small></p>'
isPlugin = html.match(/<ws.*?>.*?<\/ws>/g);
hasVideojs = false
videoJsScript = '<!--#ws_videojs-->'
hasImageView = false
imageViewJsScript = '<!--#ws_imageview-->'

if isPlugin
    for v in isPlugin
        type = v.match(/data-type="(.*?)"/)[1]
        src = v.match(/data-src="(.*?)"/)[1] if v.match(/data-src="(.*?)"/)
        id = v.match(/data-id="(.*?)"/)[1] if v.match(/data-id="(.*?)"/)
        width = if v.match(/width="(.*?)"/) then v.match(/width="(.*?)"/)[1] else '100%'
        height = if v.match(/height="(.*?)"/) then v.match(/height="(.*?)"/)[1] else '500px'
        # 处理 videojs
        if 'videojs' == type
            hasVideojs = true
            controls = if v.indexOf('controls') then 'controls' else ''
            autoplay = if v.indexOf('autoplay') then 'autoplay' else ''
            preload = if v.indexOf('preload') then 'preload' else ''
            script = '<video id="'+id+'" class="video-js vjs-default-skin  vjs-big-play-centered" '+controls+' '+preload+' width="'+width+'" height="'+height+'" data-setup="{}"><source src="'+src+'" type="video/mp4"></video>'
            html = html.replace(v, script)

        # 处理 图片预览
        if 'imageview' == type
            hasImageView = true
            script = '<img src="'+src+'?imageView2/1/w/'+width+'/h/'+height+'" data-action="zoom" data-original="'+src+'" />'
            html = html.replace(v, script)

    # 加入 videojs script and css
    if true == hasVideojs
        # 去除已有
        html = html.replace(new RegExp(videoJsScript + '.*?' + videoJsScript, 'g'), '');
        html += videoJsScript + '<script src="'+_availableModules['straw']+'/Assets/vendor/videojs/videojs.js"></script><link href="'+_availableModules['straw']+'/Assets/vendor/videojs/video.css" rel="stylesheet"><script>setTimeout(function(){videojs.options.flash.swf = "'+_availableModules['straw']+'/Assets/vendor/videojs/video-js.swf";}, 500)</script>' + videoJsScript

    if true == hasImageView
        # 去除已有
        html = html.replace(new RegExp(imageViewJsScript + '.*?' + imageViewJsScript, 'g'), '');
        html += imageViewJsScript + '<script src="'+_availableModules['straw']+'/Assets/vendor/zoom/zoom.js"></script><link href="'+_availableModules['straw']+'/Assets/vendor/zoom/zoom.css" rel="stylesheet">' + imageViewJsScript

return html
avalon.log html