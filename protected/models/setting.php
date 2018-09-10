<?php
namespace models;
use \strawframework\base\Model;
/**
 * 设置表
 * Class VideoSetModel
 */
class Setting extends Model{

    public function __construct() {
        parent::__construct($table = 'setting', $pre = null);
    }


    //web
    CONST PLATFORM_WEB = 0;
    //android tv
    CONST PLATFORM_ANDROIDTV = 1;
    //ios
    CONST PLATFORM_IOSAPP = 2;

    public static $_COLUMNS = [
        'name'  => 'string', //别名
        'uid'   => 'string', //设备 id
        'host'  => 'string', //下载链接 and 展示链接
        'cycle' => 'string', //播放循环方式
    ];

    //可用的循环方式
    public static $_CYCLES = [
        'ALL', //全部循环
        'SINGER', //单集循环
        //'RAND', //随机
        'ONCE', //一次播放
    ];

    //获取设备设置
    public function getSetting($uid){
        return $this->query(['uid' => convertTo(self::$_COLUMNS['uid'], $uid)])->getOne();
    }

    //获取所有设备
    public function getList(){

        return $this->query()->getAll();
    }

    //添加新设备 uid 不能重复
    public function newData($data){

        //移除非本数据库字段
        $data = Model::removeUnsafeField($data, array_keys(self::$_COLUMNS));

        //转换字段类型为可靠类型
        $data = convertArrTo($data, self::$_COLUMNS);
        return $this->insert($data);
    }

    public function modify($uid, $data){
        //移除非本数据库字段
        $data = Model::removeUnsafeField($data, array_keys(self::$_COLUMNS));

        //转换字段类型为可靠类型
        $data = convertArrTo($data, self::$_COLUMNS);

        //cycle 不符合要求
        if ($data['cycle'] && !in_array($data['cycle'], self::$_CYCLES))
            unset($data['cycle']);

        return $this->update($data, ['uid' => convertTo(self::$_COLUMNS['uid'], $uid)]);
    }

    //获取设置
    public function getInfo($uid, $field = []){

        return $this->query(['uid' => convertTo(self::$_COLUMNS['uid'], $uid)])->field($field)->getOne();
    }
}
