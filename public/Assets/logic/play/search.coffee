'use strict'

define ['text!/Pages/play/search.html', 'avalon', 'api', 'page', 'avalon.cookie', 'select2'], (pageMain, avalon, api, page) ->
    avalon.templateCache.play_search = pageMain;
    vm = avalon.define({
        $id: 'search'
        title: ''
        mod: avalon.vmodels.play.mod
        host: avalon.vmodels.play.host
        service: avalon.vmodels.play.service
        url: null
#        userArr: avalon.vmodels.straw.userArr
        loading: '/Assets/logic/common/loading.html'

        # 每列 11
        oneColumn: 11
        # 3列
        count: 0


        letterKeyboards: ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'ü', 'w', 'x', 'y', 'z', '删除', '数/英文']
        numberKeyboards: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '删除', '拼音']

        keyboards: []

        # 背景色块
        bg_colors: ['#9f5f9f', '#a67d3d', '#42426f', '#4c82b2', '#0f7a75', '#963b3a']

        # 随机出颜色
        rand_bg: (img, platform) ->
            if 1 == platform
                return 'url(' + vm.host + img + ')'
            else
                return 'url(' + img + ')'
        rand_bgcolor: () ->
            index = parseInt(Math.random() * 6) + 1;
            return vm.bg_colors[index - 1]

        set_bg: (img, platform) ->
            if platform in NOTSHOWIMG_PLATFORM
                return '/index/show_pic?p=' + img
            else
                return img

        # key
        key: ''
        # type key
        query: ''

        clearQuery: () ->
            vm.query = ''

        # 精确搜索
        searchQuery: (e) ->
            e.preventDefault()#阻止页面刷新
            if vm.query == ''
                return false
            vm.key = ''
            vm.keyType = 2
            vm.getList()

        type: 'all'
        changeType: (type) ->
            vm.type = type
            vm.getList()

        # 1 拼音 2 精确搜索
        keyType: 1
        clickKey: (key) ->
            vm.query = ''
            if '删除' == key
                vm.key = vm.key.substring(0, vm.key.length - 1)
                vm.getList()
            else if '数/英文' == key
                vm.key = ''
                vm.keyboards = vm.numberKeyboards
                vm.keyType = 2
                vm.focusKey()
            else if '拼音' == key
                vm.key = ''
                vm.keyboards = vm.letterKeyboards
                vm.keyType = 1
                vm.focusKey()
            else
                vm.key += key
                vm.getList()
            avalon.log vm.key

        error: ''
        #  清空本页数据
        emptyList: (status = []) ->
            vm.error = status
            vm.list1 = []
            vm.list2 = []
            vm.list3 = []
#            delete vm.list['first']
#            delete vm.list['second']
#            delete vm.list['third']
#            delete vm.list
            vm.info = {}

        # 所有播放列表
        list1: []
        list2: []
        list3: []
        info: {}
        getList: () ->
            if vm.key == '' && vm.query == ''
                vm.emptyList()
                return false
            if vm.query
                query = vm.query
            else
                query = vm.key.replace('ü', 'v') # ü => v
            vm.emptyList('loading')
            api.getApi('/search/get_list', {
                'count': vm.count
                'keyword': query
                'keytype': vm.keyType
                'type': vm.type
            }, (result)->
                if SUCCESS == result.code
                    vm.emptyList()
                    vm.list1 = result.list.splice(0, vm.oneColumn) || []
                    vm.list2 = result.list.splice(0, vm.oneColumn) || []
                    vm.list3 = result.list.splice(0, vm.oneColumn) || []

#                    avalon.log vm.list
                else if ISEMPTY == result.code
                    # 无数据了
                    vm.emptyList(false)
                else
                    require ['logic/common/tips'], (tips) ->
                        tips.showTips(result.msg, 'error')
            )

        # 选中第一个键盘上的key
        focusKey: () ->
            setTimeout(()->
                # 选中第一个
                $("#FocusMovie0").focus()
            , 200)

        init: (url) ->
            avalon.log('search page load complete')
            vm.url = url
            vm.key = ''
            vm.keyboards = vm.letterKeyboards
            vm.count = vm.oneColumn * 3
            vm.keyType = 1
            vm.type = 'all'
            vm.query = ''
            vm.emptyList(null)
            vm.focusKey()
            avalon.vmodels.play.title = ''
            document.title = avalon.vmodels.play.title


    })


    return vm