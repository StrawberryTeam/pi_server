// Generated by CoffeeScript 1.10.0
(function() {
  'use strict';
  var indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  define(['text!/Pages/device/list.html', 'avalon', 'api', 'page', 'avalon.cookie', 'select2'], function(pageMain, avalon, api, page) {
    var vm;
    avalon.templateCache.device_list = pageMain;
    vm = avalon.define({
      $id: 'device_list',
      title: '设备资源列表',
      mod: avalon.vmodels.dashboard.mod,
      host: avalon.vmodels.dashboard.host,
      uid: avalon.vmodels.dashboard.uid,
      url: null,
      isLoading: false,
      loading: '/Assets/logic/common/loading.html',
      showImg: function(el) {
        var ref;
        if (el['imgs'] && el['imgs'][vm.uid]) {
          return vm.host + el['imgs'][vm.uid];
        }
        if (ref = el.platform, indexOf.call(NOTSHOWIMG_PLATFORM, ref) >= 0) {
          return '/images/default.png';
        } else {
          return el['img'];
        }
      },
      deviceId: 0,
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
      currentPage: 1,
      pageHtml: '',
      count: 24,
      searchQuery: '',
      order: 'sorts.',
      direction: -1,
      search: function() {
        if ('' !== vm.searchQuery) {
          return avalon.router.navigate('device:list?deviceId=' + vm.deviceId + '&query=' + vm.searchQuery);
        }
      },
      list: [],
      getResList: function() {
        vm.list = [];
        vm.pageHtml = '';
        vm.isLoading = true;
        return api.getApi('/videoset/get_resList', {
          'page': vm.currentPage,
          'count': vm.count,
          'title_query': vm.searchQuery,
          'order': vm.order + vm.deviceId,
          'direction': vm.direction,
          'deviceId': vm.deviceId,
          'type': 'dledAndDlOneAndCreate'
        }, function(result) {
          var totalPage;
          vm.isLoading = false;
          if (SUCCESS === result.code) {
            vm.list = result.list;
            totalPage = Math.ceil(result.total / parseInt(vm.count));
            return vm.pageHtml = page.getPage(vm.currentPage, totalPage, vm.url, 'device:list');
          } else if (ISEMPTY === result.code) {
            return vm.list = false;
          } else {
            return require(['logic/common/tips'], function(tips) {
              return tips.showTips(result.msg, 'error');
            });
          }
        });
      },
      dl: function(id) {
        return api.getApi('/videoset/set_todownload', {
          "id": id
        }, function(result) {
          if (SUCCESS === result.code) {
            require(['logic/common/tips'], function(tips) {
              return tips.showTips(result.msg, 'success', {
                'autoHide': 2000
              });
            });
            return vm.getCategory();
          } else {
            return require(['logic/common/tips'], function(tips) {
              return tips.showTips(result.msg, 'error');
            });
          }
        });
      },
      undl: function(id) {
        return api.getApi('/videoset/set_toundownload', {
          "id": id
        }, function(result) {
          if (SUCCESS === result.code) {
            require(['logic/common/tips'], function(tips) {
              return tips.showTips(result.msg, 'success', {
                'autoHide': 2000
              });
            });
            return vm.getCategory();
          } else {
            return require(['logic/common/tips'], function(tips) {
              return tips.showTips(result.msg, 'error');
            });
          }
        });
      },
      remove: function(id) {
        return alert('未完成');
      },
      hide: function(id) {
        return vm.doChangeHide(id, 'hide');
      },
      show: function(id) {
        return vm.doChangeHide(id, 'show');
      },
      doChangeHide: function(id, type) {
        return api.getApi('/videoset/change_hide', {
          'setId': id,
          'status': type,
          'deviceId': vm.deviceId
        }, function(result) {
          if (SUCCESS === result.code) {
            require(['logic/common/tips'], function(tips) {
              return tips.showTips('状态更新成功', 'success', {
                'autoHide': 2000
              });
            });
            return vm.getResList();
          } else {
            return require(['logic/common/tips'], function(tips) {
              return tips.showTips(result.msg, 'error');
            });
          }
        });
      },
      isDeviceIdInHides: function(el) {
        var ref;
        if (el.hides && (ref = String(vm.deviceId), indexOf.call(el.hides, ref) >= 0)) {
          return true;
        } else {
          return false;
        }
      },
      changeSort: function(id, sort) {
        if (isNaN(sort)) {
          return require(['logic/common/tips'], function(tips) {
            return tips.showTips('排序值必须为数字', 'error');
          });
        } else {
          return api.getApi('/videoset/change_sort', {
            'setId': id,
            'sort': sort,
            'deviceId': vm.deviceId
          }, function(result) {
            if (SUCCESS === result.code) {
              require(['logic/common/tips'], function(tips) {
                return tips.showTips('排序更新成功', 'success', {
                  'autoHide': 2000
                });
              });
              return vm.getResList();
            } else {
              return require(['logic/common/tips'], function(tips) {
                return tips.showTips(result.msg, 'error');
              });
            }
          });
        }
      },
      init: function(url) {
        avalon.log('task home page load complete');
        vm.url = url;
        if (vm.url.create_set_success) {
          require(['logic/common/tips'], function(tips) {
            return tips.showTips('影片集创建成功', 'success', {
              'autoHide': 2000
            });
          });
          avalon.router.navigate('device:list?deviceId=' + vm.url.deviceId, {
            replace: true,
            options: true
          });
        }
        vm.currentPage = vm.url.page ? vm.url.page : 1;
        vm.searchQuery = vm.url.query ? vm.url.query : '';
        vm.deviceId = vm.url.deviceId ? vm.url.deviceId : _clientInfo['uid'];
        vm.getDeviceList();
        return vm.getResList();
      }
    });
    return vm;
  });

}).call(this);

//# sourceMappingURL=list.js.map
