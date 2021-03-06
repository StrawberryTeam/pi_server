// Generated by CoffeeScript 1.10.0
(function() {
  'use strict';
  var indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  define(['text!/Pages/device/video.html', 'avalon', 'api', 'page', 'avalon.cookie', 'select2'], function(pageMain, avalon, api, page) {
    var vm;
    avalon.templateCache.device_video = pageMain;
    vm = avalon.define({
      $id: 'device_video',
      title: '影片列表',
      mod: avalon.vmodels.dashboard.mod,
      host: avalon.vmodels.dashboard.host,
      uid: avalon.vmodels.dashboard.uid,
      url: null,
      loading: '/Assets/logic/common/loading.html',
      showImg: function(el) {
        var ref;
        if (el['imgs'] && el['imgs'][vm.uid]) {
          return vm.host + el['imgs'][vm.uid];
        }
        if (ref = vm.item['platform'], indexOf.call(NOTSHOWIMG_PLATFORM, ref) >= 0) {
          return '/images/default.png';
        } else {
          return el['img'];
        }
      },
      deviceId: null,
      deviceList: [],
      getDeviceList: function() {
        return api.getApi('/setting/get_list', {}, function(result) {
          if (SUCCESS === result.code) {
            return vm.deviceList = result.list;
          } else if (ISEMPTY === result.code) {
            return require(['logic/common/tips'], function(tips) {
              return tips.showTips('没有任何设备', 'error');
            });
          } else {
            return require(['logic/common/tips'], function(tips) {
              return tips.showTips(result.msg, 'error');
            });
          }
        });
      },
      selectedVideo: [],
      selectAll: false,
      checkAll: function() {
        var c, i, len, ref, results;
        if (this.checked) {
          ref = vm.cateList;
          results = [];
          for (i = 0, len = ref.length; i < len; i++) {
            c = ref[i];
            results.push(vm.selectedVideo.ensure(c._id));
          }
          return results;
        } else {
          return vm.selectedVideo.clear();
        }
      },
      setId: null,
      platform: null,
      currentPage: 1,
      pageHtml: '',
      count: 30,
      searchQuery: '',
      order: '_id',
      direction: 1,
      setting: {},
      search: function() {
        if ('' !== vm.searchQuery) {
          return avalon.router.navigate('res:video?setid=' + vm.setId + '&query=' + vm.searchQuery);
        }
      },
      cateList: [],
      total: 0,
      getList: function() {
        vm.cateList = [];
        vm.setting = {};
        vm.pageHtml = '';
        vm.selectedVideo = [];
        vm.selectAll = false;
        return api.getApi('/videolist/get_list', {
          'setId': vm.setId,
          'page': vm.currentPage,
          'count': vm.count,
          'order': vm.order,
          'direction': vm.direction,
          'keyword': vm.searchQuery,
          'deviceId': vm.deviceId,
          'type': 'dl'
        }, function(result) {
          var totalPage;
          if (SUCCESS === result.code) {
            vm.cateList = result.list;
            vm.total = result.total;
            vm.setting = result.setting;
            totalPage = Math.ceil(result.total / parseInt(vm.count));
            return vm.pageHtml = page.getPage(vm.currentPage, totalPage, vm.url, 'device:video');
          } else if (ISEMPTY === result.code) {
            return vm.cateList = false;
          } else {
            return require(['logic/common/tips'], function(tips) {
              return tips.showTips(result.msg, 'error');
            });
          }
        });
      },
      item: {},
      getSetInfo: function() {
        return api.getApi('/videoset/get_info', {
          '_id': vm.setId
        }, function(result) {
          if (SUCCESS === result.code) {
            return vm.item = result.item;
          } else {
            return require(['logic/common/tips'], function(tips) {
              return tips.showTips(result.msg, 'error');
            });
          }
        });
      },
      cp2other: function(deviceId) {
        if (vm.selectedVideo.length <= 0) {
          return require(['logic/common/tips'], function(tips) {
            return tips.showTips('请选择一些项目', 'error');
          });
        } else if (deviceId === vm.deviceId) {
          return require(['logic/common/tips'], function(tips) {
            return tips.showTips('不能复制至当前设备', 'error');
          });
        } else {
          return vm.doTask(deviceId, 'copy');
        }
      },
      zipFiles: function() {
        if (vm.selectedVideo.length <= 0) {
          return require(['logic/common/tips'], function(tips) {
            return tips.showTips('请选择一些项目', 'error');
          });
        } else {
          return vm.doTask(0, 'zip');
        }
      },
      doTask: function(toDevice, type) {
        return api.getApi('/task/create', {
          "videoIds": JSON.stringify(vm.selectedVideo),
          "set_id": vm.item._id,
          "toDevice": toDevice,
          "fromDevice": vm.deviceId,
          "type": type
        }, function(result) {
          if (SUCCESS === result.code) {
            return require(['logic/common/tips'], function(tips) {
              return tips.showTips(result.msg, 'success', {
                'autoHide': 2000
              });
            });
          } else {
            return require(['logic/common/tips'], function(tips) {
              return tips.showTips(result.msg, 'error');
            });
          }
        });
      },
      addToSet: function() {
        if (vm.selectedVideo.length <= 0) {
          return require(['logic/common/tips'], function(tips) {
            return tips.showTips('请选择一些项目', 'error');
          });
        } else {
          return require(['logic/device/select_set'], function(detail) {
            detail.init(vm.url, 1, {
              'mod': 'logic/device/video',
              'fun': 'getList'
            }, {
              "deviceId": vm.deviceId,
              'selectedVideo': vm.selectedVideo
            });
            return require(['logic/common/window'], function(window) {
              return window.showWindow('/Pages/device/select_set.html');
            });
          });
        }
      },
      init: function(url) {
        avalon.log('task home page load complete');
        vm.url = url;
        vm.setId = vm.url.setid;
        vm.currentPage = vm.url.page ? vm.url.page : 1;
        vm.searchQuery = vm.url.query ? vm.url.query : '';
        vm.deviceId = vm.url.deviceId ? vm.url.deviceId : 1;
        vm.getDeviceList();
        vm.getList();
        vm.getSetInfo();
        return $('#opt').affix({
          offset: {
            top: 10,
            bottom: function() {
              return (this.bottom = $('.footer').outerHeight(true));
            }
          }
        });
      }
    });
    vm.$watch("selectedVideo.length", function(after) {
      return vm.selectAll = after === vm.cateList.length;
    });
    return vm;
  });

}).call(this);

//# sourceMappingURL=video.js.map
