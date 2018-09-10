<?php
namespace controllers;
use \strawframework\base\Controller;
/**
 * 自定义播放列表
 * User: Zack Lee
 * Date: 2017/11/3
 * Time: 14:07
 */
class Playlist extends Controller{

    public function __construct(){
        //加载模板
        parent::__construct($isView=false);
    }


    //获取 播放列表
    public function get_list(){
        $uid = $_REQUEST['uid'];

        if (!$uid)
            $this->_error('uid not found');

    }
}