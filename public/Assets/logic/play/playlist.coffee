'use strict'

define ['text!/Pages/play/playlist.html', 'avalon', 'api', 'page', 'avalon.cookie', 'select2'], (pageMain, avalon, api, page) ->
    avalon.templateCache.play_playlist = pageMain;
    vm = avalon.define({
        $id: 'playlist'
        title: '播放列表 - ' + _siteName
        mod: avalon.vmodels.play.mod
        host: avalon.vmodels.play.host
        service: avalon.vmodels.play.service
        url: null
#        userArr: avalon.vmodels.straw.userArr
        loading: '/Assets/logic/common/loading.html'


        # 背景色块
        bg_colors: ['#9f5f9f', '#a67d3d', '#42426f']

        # 随机出颜色
        rand_bg: (el) ->
# 已下载到本地
            if el['imgs'] and el['imgs'][vm.uid]
                limg = vm.host + el['imgs'][vm.uid]
            else
# 平台1 爱奇艺 图片不能直接显示
                if el.platform in NOTSHOWIMG_PLATFORM
                    limg = '/images/default.png'
                else
# 其他平台可以直接显示
                    limg = el['img']
            return 'url(' + limg + ')'

        rand_bgcolor: () ->
            index = parseInt(Math.random() * 3) + 1;
            return vm.bg_colors[index - 1]


        error: ''
        #  清空本页数据
        emptyList: (status = []) ->
            vm.error = status

        # 所有播放列表
        list: []
        getList: () ->
#            if true == vm.onLoading
#                return false
#            vm.onLoading = true
            vm.list = []
            vm.emptyList('loading')
#            vm.currentPage++
            api.getApi('/playlist/get_list', {
            }, (result)->
                if SUCCESS == result.code
#                    if result.list.length > 0
#                        vm.cateList = vm.cateList.concat(result.list)
                    vm.emptyList()
                    vm.list = result.list

                    setTimeout(()->
                        # 选中第一个
                        $("#FocusMovie0").focus()
                    , 200)
                else if ISEMPTY == result.code
                    # 无数据了
                    vm.emptyList(false)
                else
                    require ['logic/common/tips'], (tips) ->
                        tips.showTips(result.msg, 'error')
            )
#            # 2秒后才允许操作
#            setTimeout(() ->
#                vm.onLoading = false
#            , 1000)


        init: (url) ->
            avalon.log('playlist home page load complete')
            vm.url = url
            vm.getList()

#            $(document).ready(() ->
#                $('.focusBtn').focus(() ->
##                    $(this).click()
#                    href = $(this).attr('href').replace('#!/', '')
#                    avalon.router.navigate(href)
#                    avalon.log(href)
#                    return true
#                )
#            )


    })


    return vm