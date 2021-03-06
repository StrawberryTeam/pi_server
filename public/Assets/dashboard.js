// Generated by CoffeeScript 1.10.0
(function() {
  'use strict';
  var indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  require(['config'], function(config) {
    return require(['domReady!', 'avalon', 'jquery', 'api', 'utils', 'select2', 'mmRouter', 'jquery.placeholder'], function(domReady, avalon, $, api, utils) {
      var dashboard;
      dashboard = avalon.define({
        $id: 'dashboard',
        module: 'loading',
        mod: null,
        service: null,
        query: null,
        url: null,
        needLogin: true,
        userArr: {},
        safeFun: {},
        isSafe: function(action) {
          var ref;
          if (ref = action.toUpperCase(), indexOf.call(dashboard.safeFun, ref) >= 0) {
            return true;
          } else {
            return false;
          }
        },
        top_nav: '/Pages/common/top_nav.html',
        render: function() {},
        setLoading: function() {
          return dashboard.module = 'loading';
        },
        host: _playSetting.host,
        host_name: _playSetting.name,
        getHost: function(uid) {
          var setting, settingObj;
          setting = sessionStorage.getItem('setting_' + uid);
          if (setting) {
            settingObj = JSON.parse(setting);
            dashboard.host = settingObj.host;
            return dashboard.host_name = settingObj.host_name;
          } else {
            return api.getApi('/setting/getPlaySetting', {
              "uid": uid
            }, function(result) {
              avalon.log(result);
              if (SUCCESS === result.code) {
                dashboard.host = result.item.host;
                dashboard.host_name = result.item.name;
                return sessionStorage.setItem('setting_' + uid, JSON.stringify({
                  host: dashboard.host,
                  host_name: dashboard.host_name
                }));
              }
            });
          }
        },
        uid: 0,
        loadModulePage: function() {
          var modName;
          dashboard.uid = avalon.cookie.get('uid');
          if (!dashboard.uid) {
            avalon.router.navigate('select:home');
          }
          if (!dashboard.service) {
            avalon.router.navigate('res:list');
            return false;
          }
          if (dashboard.mod === void 0) {
            avalon.router.navigate(dashboard.service + ':home');
          }
          if (dashboard.url.query) {
            dashboard.query = dashboard.url.query;
          }
          modName = dashboard.service + '/' + dashboard.mod;
          return require(['logic/' + modName], function(module) {
            document.title = module.title;
            dashboard.module = dashboard.service + '_' + dashboard.mod;
            avalon.scan();
            return module.init(dashboard.url);
          });
        },
        setCurrentPage: function() {
          var serviceMod;
          serviceMod = this.params.mod.trim().split(':');
          dashboard.service = serviceMod[0];
          dashboard.mod = serviceMod[1];
          dashboard.url = this.query;
          dashboard.setLoading();
          return dashboard.loadModulePage();
        },
        init: function() {
          dashboard.schoolTitle = 'Dashboard';
          avalon.router.get("/:mod", dashboard.setCurrentPage);
          return avalon.history.start({
            basepath: '/',
            interval: 20
          });
        }
      });
      dashboard.init();
      avalon.scan(document.body);
      return dashboard;
    });
  });

}).call(this);

//# sourceMappingURL=dashboard.js.map
