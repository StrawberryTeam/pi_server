'use strict'

define ['text!/Pages/play/episode.html', 'avalon', 'api', 'page', 'avalon.cookie', 'select2'], (pageMain, avalon, api, page) ->
    avalon.templateCache.play_episode = pageMain;
    vm = avalon.define({
        $id: 'episode'
        title: ''
        mod: avalon.vmodels.play.mod
        host: avalon.vmodels.play.host
        service: avalon.vmodels.play.service
        uid: avalon.vmodels.play.uid
        url: null
        loading: '/Assets/logic/common/loading.html'
        # 当前页
        currentPage: 1
        # 当前集 所有在 num
        num: null
        # 每页10集显示
        count: 10

        set_bg: (el, platform) ->
# 已下载到本地
            if el['imgs'] and el['imgs'][vm.uid]
                return vm.host + el['imgs'][vm.uid]
            # 平台1 爱奇艺 图片不能直接显示
            if platform in NOTSHOWIMG_PLATFORM
                return '/images/default.png'
            else
# 其他平台可以直接显示
                return el['img']
        error: ''
        #  清空本页数据
        emptyList: (status = []) ->
            vm.error = status
            vm.videoList = []

        videoCss: 'video-min'
        # 开始播放
        play: (num = '') ->
            if num
                videoInfo = vm.videoList[num]
            else
                videoInfo = vm.currentVideoInfo
            avalon.log videoInfo
#            videoStream = vm.setting['host'] + videoInfo['plays'][_clientInfo['uid']]

            #android
            if PLATFORM_ANDROIDTV == _clientInfo['platform']

                #setId _id setInfo > json string
                android.videoPlay(videoInfo.setId.$oid, videoInfo._id, vm.getVideoNum(num))
                return false
#            else
#                $('#myModal').modal()
#                videoObj = $("#playMain")
#                vm.videoCss = 'video-playing'
#                videoObj.attr({
#                    controls: 'controls'
#                    src: videoStream
#                })
##                nheight = $(".modal").height()
##                $(".modal-body").css("height": nheight - 50)
#                setTimeout(() ->
#                    avalon.log ('play ' + videoStream)
#                    videoEle = document.getElementById("playMain")
#                    videoEle.play()
#                    # 全屏 ff 下需要2次触发 pywebview 使用 ff
##                    if videoEle.mozRequestFullScreen
##                        videoEle.mozRequestFullScreen()
##                    else
##                        videoEle.webkitRequestFullScreen(Element.ALLOW_KEYBOARD_INPUT)
##                    if (document.mozCancelFullScreen) {
##                        document.mozCancelFullScreen();
##                    } else {
##                    document.webkitCancelFullScreen();
##                    }
#                , 200)

#        # web 页面关闭播放
#        close: () ->
#            videoObj = $("#playMain")
#            videoObj.removeAttr('controls')
#            videoObj.removeAttr('src')

        # 合集信息
        setInfo: {}
        getInfo: () ->
            vm.setInfo = {}
            api.getApi('/videoset/get_info', {
                '_id': vm.setId
            }, (result)->
                if SUCCESS == result.code
                    vm.setInfo = result.item

                else
                    require ['logic/common/tips'], (tips) ->
                        tips.showTips(result.msg, 'error')
            )

        # 剧集的 集数值计算
        getVideoNum: (index) ->
            return (parseInt(index) + 1) + ((vm.currentPage * vm.count) - vm.count)



        # 本设备设置
        setting: {}
        total: 0
        # 影片集
        videoList: []
        #rePage
        rePageHtml: null
        rePage: () ->
            vm.num = null
            vm.currentPage--
            vm.getVideoList()
        # 下一页
        nextPageHtml: null
        nextPage: () ->
            vm.num = null
            vm.currentPage++
            vm.getVideoList()

        # 设置当前默认的视频
        setCurrentVideo: (index) ->
            # 默认给第一个
            vm.currentVideoInfo = vm.videoList[index]
            # 重新设置 title
            vm.title = vm.currentVideoInfo.name + ' - ' + _siteName
#            document.title = vm.title
            # to top with phone
#            $(window).scrollTop(0);

        currentVideoInfo: {}
        getVideoList: () ->
            vm.emptyList('loading')
            # 按 num 计算 currentPage
            if null != vm.num
                if vm.num <= 0
                    vm.num = 1
                vm.currentPage = Math.ceil(vm.num / 10)
            api.getApi('/videolist/get_list', {
                'page': vm.currentPage
                'count': vm.count
                'setId': vm.setId
                'order': '_id' # 每个账户可以进行 order 的设定，@todo 根据影片有没有看过来执行不同的 order
                'direction': 1
                'type': 'dl' # 仅已下载的单集
            }, (result)->
                if SUCCESS == result.code
                    vm.emptyList()
                    vm.videoList = result.list
                    vm.setting = result.setting

                    vm.setCurrentVideo(0)
                    vm.total = result.total
                    # max
                    pageTotal = vm.count * vm.currentPage
                    pageMax = pageTotal + vm.count
                    if pageMax > vm.total
                        pageMax = vm.total
                    # 下一页按钮
                    if pageTotal >= vm.total
                        vm.nextPageHtml = null
                    else
                        vm.nextPageHtml = pageTotal + 1 + ' - ' + pageMax + '集'
                    # 上一页按钮
                    if vm.currentPage == 1
                        vm.rePageHtml = null
                    else
                        vm.rePageHtml = parseInt(pageTotal - vm.count - vm.count) + ' - ' + (pageTotal - vm.count) + '集'


                    setTimeout(()->
                        $(".FocusPlay").focus()
                    , 200)
#                    $(document).ready(() ->
#                        $('.part_videolist').focus(() ->
#                            index = $(this).attr("index")
#                            alert index
#                            return true
#                        )
#                    )
                else if ISEMPTY == result.code
                    # 无数据了
                    vm.emptyList(false)
                    require ['logic/common/tips'], (tips) ->
                        tips.showTips('当前剧集所有影片正在下载中, 请稍后查看', 'success', {'redirectUrl': '/'})
                else
                    require ['logic/common/tips'], (tips) ->
                        tips.showTips(result.msg, 'error')
            )

        cycle: 'ALL'
        # 更新设置
        saveSetting: (cycle) ->
            api.getApi('/setting/editPlaySetting', {'cycle': cycle}, (result)->
                if SUCCESS == result.code
                    vm.cycle = cycle
                    if PLATFORM_ANDROIDTV == _clientInfo['platform']
                        # 通知 android
                        android.getsetting(JSON.stringify({"cycle": vm.cycle}))
            )

        # 获取当前设置
        getSetting: () ->
            api.getApi('/setting/getPlaySetting', {}, (result)->
                if SUCCESS == result.code
                    vm.cycle = result.item.cycle
                    if PLATFORM_ANDROIDTV == _clientInfo['platform']
                        # 通知 android
                        android.getsetting(JSON.stringify({"cycle": vm.cycle}))
            )

        init: (url) ->
            avalon.log('play view page load complete')
            vm.url = url
            vm.currentPage = if vm.url.page then vm.url.page else 1
            vm.num = if vm.url.num then vm.url.num else null #未指定 num 就按 page 计算
            vm.setId = vm.url.setid
            vm.getInfo()
            vm.getVideoList()
            vm.getSetting()


    })

    return vm

