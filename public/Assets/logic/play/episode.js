// Generated by CoffeeScript 1.12.7
(function() {
  'use strict';
  var indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  define(['text!/Pages/play/episode.html', 'avalon', 'api', 'page', 'avalon.cookie', 'select2'], function(pageMain, avalon, api, page) {
    var vm;
    avalon.templateCache.play_episode = pageMain;
    vm = avalon.define({
      $id: 'episode',
      title: '',
      mod: avalon.vmodels.play.mod,
      host: avalon.vmodels.play.host,
      service: avalon.vmodels.play.service,
      uid: avalon.vmodels.play.uid,
      url: null,
      loading: '/Assets/logic/common/loading.html',
      currentPage: 1,
      num: null,
      count: 10,
      set_bg: function(el, platform) {
        if (el['imgs'] && el['imgs'][vm.uid]) {
          return vm.host + el['imgs'][vm.uid];
        }
        if (indexOf.call(NOTSHOWIMG_PLATFORM, platform) >= 0) {
          return '/images/default.png';
        } else {
          return el['img'];
        }
      },
      error: '',
      emptyList: function(status) {
        if (status == null) {
          status = [];
        }
        vm.error = status;
        return vm.videoList = [];
      },
      videoCss: 'video-min',
      play: function(num) {
        var videoInfo;
        if (num == null) {
          num = '';
        }
        if (num) {
          videoInfo = vm.videoList[num];
        } else {
          videoInfo = vm.currentVideoInfo;
        }
        avalon.log(videoInfo);
        if (PLATFORM_ANDROIDTV === _clientInfo['platform']) {
          android.videoPlay(videoInfo.setId.$oid, videoInfo._id, vm.getVideoNum(num));
          return false;
        }
      },
      setInfo: {},
      getInfo: function() {
        vm.setInfo = {};
        return api.getApi('/videoset/get_info', {
          '_id': vm.setId
        }, function(result) {
          if (SUCCESS === result.code) {
            return vm.setInfo = result.item;
          } else {
            return require(['logic/common/tips'], function(tips) {
              return tips.showTips(result.msg, 'error');
            });
          }
        });
      },
      getVideoNum: function(index) {
        return (parseInt(index) + 1) + ((vm.currentPage * vm.count) - vm.count);
      },
      setting: {},
      total: 0,
      videoList: [],
      rePageHtml: null,
      rePage: function() {
        vm.num = null;
        vm.currentPage--;
        return vm.getVideoList();
      },
      nextPageHtml: null,
      nextPage: function() {
        vm.num = null;
        vm.currentPage++;
        return vm.getVideoList();
      },
      setCurrentVideo: function(index) {
        vm.currentVideoInfo = vm.videoList[index];
        return vm.title = vm.currentVideoInfo.name + ' - ' + _siteName;
      },
      currentVideoInfo: {},
      getVideoList: function() {
        vm.emptyList('loading');
        if (null !== vm.num) {
          if (vm.num <= 0) {
            vm.num = 1;
          }
          vm.currentPage = Math.ceil(vm.num / 10);
        }
        return api.getApi('/videolist/get_list', {
          'page': vm.currentPage,
          'count': vm.count,
          'setId': vm.setId,
          'order': '_id',
          'direction': 1,
          'type': 'dl'
        }, function(result) {
          var pageMax, pageTotal;
          if (SUCCESS === result.code) {
            vm.emptyList();
            vm.videoList = result.list;
            vm.setting = result.setting;
            vm.setCurrentVideo(0);
            vm.total = result.total;
            pageTotal = vm.count * vm.currentPage;
            pageMax = pageTotal + vm.count;
            if (pageMax > vm.total) {
              pageMax = vm.total;
            }
            if (pageTotal >= vm.total) {
              vm.nextPageHtml = null;
            } else {
              vm.nextPageHtml = pageTotal + 1 + ' - ' + pageMax + '集';
            }
            if (vm.currentPage === 1) {
              vm.rePageHtml = null;
            } else {
              vm.rePageHtml = parseInt(pageTotal - vm.count - vm.count) + ' - ' + (pageTotal - vm.count) + '集';
            }
            return setTimeout(function() {
              return $(".FocusPlay").focus();
            }, 200);
          } else if (ISEMPTY === result.code) {
            vm.emptyList(false);
            return require(['logic/common/tips'], function(tips) {
              return tips.showTips('当前剧集所有影片正在下载中, 请稍后查看', 'success', {
                'redirectUrl': '/'
              });
            });
          } else {
            return require(['logic/common/tips'], function(tips) {
              return tips.showTips(result.msg, 'error');
            });
          }
        });
      },
      cycle: 'ALL',
      saveSetting: function(cycle) {
        return api.getApi('/setting/editPlaySetting', {
          'cycle': cycle
        }, function(result) {
          if (SUCCESS === result.code) {
            vm.cycle = cycle;
            if (PLATFORM_ANDROIDTV === _clientInfo['platform']) {
              return android.getsetting(JSON.stringify({
                "cycle": vm.cycle
              }));
            }
          }
        });
      },
      getSetting: function() {
        return api.getApi('/setting/getPlaySetting', {}, function(result) {
          if (SUCCESS === result.code) {
            vm.cycle = result.item.cycle;
            if (PLATFORM_ANDROIDTV === _clientInfo['platform']) {
              return android.getsetting(JSON.stringify({
                "cycle": vm.cycle
              }));
            }
          }
        });
      },
      init: function(url) {
        avalon.log('play view page load complete');
        vm.url = url;
        vm.currentPage = vm.url.page ? vm.url.page : 1;
        vm.num = vm.url.num ? vm.url.num : null;
        vm.setId = vm.url.setid;
        vm.getInfo();
        vm.getVideoList();
        return vm.getSetting();
      }
    });
    return vm;
  });

}).call(this);

//# sourceMappingURL=episode.js.map