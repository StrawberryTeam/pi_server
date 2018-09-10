'use strict'

define ['text!/Pages/select/home.html', 'avalon', 'api', 'page', 'avalon.cookie', 'select2'], (pageMain, avalon, api, page) ->
    avalon.templateCache.select_home = pageMain;
    vm = avalon.define({
        $id: 'select_home'
        title: ''
        mod: avalon.vmodels.dashboard.mod
        nuid: avalon.vmodels.dashboard.uid
        url: null
#        userArr: avalon.vmodels.straw.userArr
        loading: '/Assets/logic/common/loading.html'
        list: []
        getList: () ->
            api.getApi('/setting/get_list', {}, (result)->
                if SUCCESS == result.code
                    vm.list = result.list
                else if ISEMPTY == result.code
                    require ['logic/common/tips'], (tips) ->
                        tips.showTips('没有任何设备', 'error')
                else
                    require ['logic/common/tips'], (tips) ->
                        tips.showTips(result.msg, 'error')
            )

        # 更新或添加新设备
        submit: () ->
            if not vm.name or not vm.uid or not vm.host
                require ['logic/common/tips'], (tips) ->
                    tips.showTips('未填写完整', 'error')
            if 1 == vm.ac
                apiUrl = '/setting/newSetting'
            else
                apiUrl = '/setting/editSetting'
            api.getApi(apiUrl, {
                'name': vm.name
                'uid': vm.uid
                'host': vm.host
            }, (result)->
                if SUCCESS == result.code
                    require ['logic/common/tips'], (tips) ->
                        tips.showTips(result.msg, 'success', {'autoHide': 2000})
                    # 刷新页面
                    vm.getList()
                else
                    require ['logic/common/tips'], (tips) ->
                        tips.showTips(result.msg, 'error')
            )

        # 选择设备
        change: (uid) ->
            date = new Date()
            # 保存选择一年
            time = date.getTime() + 60 * 60 * 24 * 30 * 1000
            date.setTime(time)
            avalon.cookie.set('uid', uid, {'expires': date, 'Path': '/'})
#            window.location.href = '/dashboard#!res:list'
            avalon.router.navigate('res:list')
            window.location.reload(true)

        name: ''
        uid: ''
        host: ''
        btn_name: ''
        ac: 1
        # 更改
        edit: (index = null) ->
            if null == index
                vm.emptyEdit()
            else
                vm.name = vm.list[index]['name']
                vm.uid = vm.list[index]['uid']
                vm.host = vm.list[index]['host']
                vm.btn_name = '更新 ' + vm.name
                # 编辑
                vm.ac = 2

        # 清空填写
        emptyEdit: () ->
            vm.name = ''
            vm.uid = ''
            vm.host = ''
            vm.btn_name = '添加新设备'
            vm.ac = 1

        init: (url) ->
            avalon.log('select home page load complete')
            vm.url = url
            vm.emptyEdit()
            vm.getList()
            avalon.vmodels.play.title = ''
            document.title = avalon.vmodels.play.title

    })

    return vm