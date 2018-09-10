<?php
namespace controllers;
use \strawframework\base\Controller;
/**
 * User: Zack Lee
 * Date: 2017/11/3
 * Time: 14:07
 */
class Setting extends Controller{

    public function __construct(){
        //加载模板
        parent::__construct($isView=false);
    }

    //获取总分类
    public function get_list(){


        $list = $this->settingModel->getList();

        if (!$list)
            $this->_error('', self::ISEMPTY);
        else
            $this->_success('', ['list' => $list]);
    }

    //添加新设备
    public function newSetting(){

        $name = $_REQUEST['name'];
        $uid = $_REQUEST['uid'];
        $host = $_REQUEST['host'];

        if (!$name || !$uid || !$host)
            $this->_error('参数不完整');


        $item = $this->settingModel->getSetting($uid);

        if ($item)
            $this->_error('该 uid 已存在，uid 不能重复');

        $this->settingModel->newData([
                                         'name' => $name,
                                         'uid'  => $uid,
                                         'host' => $host
                                     ]);
        $this->_success();
    }

    //编辑设备
    public function editSetting(){

        $name = $_REQUEST['name'];
        $uid = $_REQUEST['uid'];
        $host = $_REQUEST['host'];

        if (!$name || !$uid || !$host)
            $this->_error('参数不完整');

        $this->settingModel->modify($uid, [
            'name' => $name,
            'uid'  => $uid,
            'host' => $host
        ]);
        $this->_success();
    }

    //更新播放设置
    public function editPlaySetting(){
        $uid = $_REQUEST['uid'];
        //使用什么样的循环方式
        $cycle = $_REQUEST['cycle'];

        if (!$uid || !$cycle)
            return false;

        $this->settingModel->modify($uid, [
            'cycle' => strtoupper($cycle)
        ]);
        $this->_success();
    }

    //获取本设备的播放设置
    public function getPlaySetting(){
        $uid = $_REQUEST['uid'];

        if (!$uid)
            return false;

        $item = $this->settingModel->getInfo($uid, ['cycle', 'host', 'name']);

        $this->_success('', ['item' => $item]);
    }

    //新的播放记录
    public function newView(){
        $uid = $_REQUEST['uid'];
        //videolist > _id 播放的视频 id
        $videoId = $_REQUEST['video_id'];


        //先记录为 全部播放
    }
}