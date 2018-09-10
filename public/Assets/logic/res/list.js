// Generated by CoffeeScript 1.12.7
(function() {
  'use strict';
  var indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  define(['text!/Pages/res/list.html', 'avalon', 'api', 'page', 'avalon.cookie', 'select2'], function(pageMain, avalon, api, page) {
    var vm;
    avalon.templateCache.res_list = pageMain;
    vm = avalon.define({
      $id: 'res_list',
      title: '视频集',
      mod: avalon.vmodels.dashboard.mod,
      host: avalon.vmodels.dashboard.host,
      uid: avalon.vmodels.dashboard.uid,
      url: null,
      isLoading: false,
      loading: '/Assets/logic/common/loading.html',
      currentPage: 1,
      pageHtml: '',
      count: 12,
      searchQuery: '',
      order: 'allplaynum',
      direction: -1,
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
      show_query: false,
      search: function() {
        if ('' !== vm.searchQuery) {
          vm.show_query = true;
          return avalon.router.navigate('res:list?type=' + vm.type + '&platform=' + vm.platform + '&query=' + vm.searchQuery);
        } else {
          return vm.show_query = false;
        }
      },
      isInMyUid: function(data) {
        var ref;
        if (!data) {
          return false;
        }
        if (ref = String(_clientInfo['uid']), indexOf.call(data, ref) >= 0) {
          return true;
        } else {
          return false;
        }
      },
      platform: 0,
      type: 'res',
      cateList: [],
      getCategory: function() {
        vm.cateList = [];
        vm.pageHtml = '';
        vm.isLoading = true;
        return api.getApi('/videoset/get_resList', {
          'page': vm.currentPage,
          'count': vm.count,
          'query': vm.searchQuery,
          'order': vm.order,
          'direction': vm.direction,
          'type': vm.type,
          'platform': vm.platform
        }, function(result) {
          var totalPage;
          vm.isLoading = false;
          if (SUCCESS === result.code) {
            avalon.log(result.list.dled);
            vm.cateList = result.list;
            totalPage = Math.ceil(result.total / parseInt(vm.count));
            return vm.pageHtml = page.getPage(vm.currentPage, totalPage, vm.url, 'res:list');
          } else if (ISEMPTY === result.code) {
            return vm.cateList = false;
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
      init: function(url) {
        avalon.log('task home page load complete');
        vm.url = url;
        vm.currentPage = vm.url.page ? vm.url.page : 1;
        if (vm.url.query) {
          vm.searchQuery = vm.url.query;
        } else {
          vm.searchQuery = '';
          vm.show_query = false;
        }
        vm.platform = vm.url.platform ? vm.url.platform : 0;
        vm.type = vm.url.type ? vm.url.type : 'res';
        return vm.getCategory();
      }
    });
    return vm;
  });

}).call(this);

//# sourceMappingURL=list.js.map