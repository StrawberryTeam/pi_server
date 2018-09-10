// Generated by CoffeeScript 1.10.0
(function() {
  var autoplay, controls, hasImageView, hasVideojs, height, html, i, id, imageViewJsScript, isPlugin, len, preload, script, src, type, v, videoJsScript, width;

  html = '<p style="text-align: center;"><div id="h3"></div><ws data-type="videojs" data-id="a3" controls data-src="http://cms-test.cdn.xwg.cc/o_1bj74nv8jipsm98relm021m6ta.mp4" width="900px" height="400px"></ws></p><p style="text-align: center;"><small>VideoName</small></p><h1>标签</h1><p style="text-align: center;"><div id="h4"></div><ws data-type="videojs" data-src="http://cms-test.cdn.xwg.cc/o_1bj73sbd6d4afkr14udedtrd14.mp4" data-id="a4" controls width="900px" height="400px"></ws></p><p style="text-align: center;"><small>VideoName</small></p>';

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

  avalon.log(html);

}).call(this);

//# sourceMappingURL=plugin2html.js.map
