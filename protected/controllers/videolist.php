<?php
namespace controllers;
use \strawframework\base\Controller;
/**
 * User: Zack Lee
 * Date: 2017/11/3
 * Time: 14:07
 */
class Videolist extends Controller{

    public function __construct(){
        //加载模板
        parent::__construct($isView=false);
    }

    //获取总分类
    public function get_list(){

        $page = $_REQUEST['page'] ?: 1;
        $keyword = $_REQUEST['keyword'] ?: '';
        $setId = $_REQUEST['setId'];
        $count = $_REQUEST['count'];

        $uid = $_REQUEST['deviceId'];

        //优先取 deviceId 指定 uid
        if (!$uid)
            $uid = $_REQUEST['uid'];

        $type = $_REQUEST['type'] ?: 'all';

        if (!$setId)
            $this->_error('没有 setId');

        //排序方法 默认按时间
        $order = trim($_REQUEST['order']) ?: '_id';
        //排序方向 默认按发布顺序
        $direction = in_array($_REQUEST['direction'], [1, -1]) ? intval($_REQUEST['direction']) : 1;

        $typeMap = [];
        switch ($type) {
            // 未下载 不在下载中的 资源
            case 'all':
                break;
            // 已完成下载的
            case 'dl':
                $typeMap = [('plays.' . $uid) => ['$exists' => True]];
                break;
        }

        $list = $this->videoListModel->getList($setId, $page, $keyword, [$order => $direction], $count, $typeMap);

        if ($list['total'] == 0){
            $this->_error('', self::ISEMPTY);
        }else{
            if ($uid){
                //设备设置情况
                $setting = $this->settingModel->getSetting($uid);
                $list['setting'] = $setting;
            }
            $this->_success('', $list);
        }
    }

    //获取视频播放信息
    public function get_info(){
        $uid = $_REQUEST['uid'];

        $videoId = $_REQUEST['videoId'];

        if (!$uid || !$videoId)
            $this->_error('参数错误');

        $item = $this->videoListModel->getInfo($videoId, $uid);

        $plays = (array)$item['plays'];
        if (!$plays[$uid])
            $this->_error('', self::ISEMPTY);

        //设备设置情况
        $setting = $this->settingModel->getSetting($uid);

        $nextItem = $this->videoListModel->getNext($videoId, $item['setId'], $uid);
        $preItem = $this->videoListModel->getPre($videoId, $item['setId'], $uid);
        $firstItem = $this->videoListModel->getFirstId($item['setId'], $uid); //第一集的
        $this->_success('', [
            'setting' => $setting,
            'item' => $item,
            'nextItem' => $nextItem ?: (object)[],
            'preItem' => $preItem ?: (object)[],
            'firstItem' => $firstItem ?: (object)[],
        ]);
    }
}