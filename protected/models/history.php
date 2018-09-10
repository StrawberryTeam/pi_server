<?php
namespace models;
use \strawframework\base\Model;

/**
 * 播放记录
 * Class VideoSetModel
 */
class History extends Model{

    public function __construct() {
        parent::__construct($table = 'history', $pre = null);
    }

    CONST HISTORY_LIMIT = 24;

    public static $_COLUMNS = [
        'setId'      => 'string', //视频集 id
        'video_id'   => 'string', //播放的视频 id
        'video_name' => 'string', //视频名称 - 《视频集名称》
        'img'        => 'string', //视频封面
        'play_at'    => 'int', //播放时间
        'uid'        => 'string', //播放设备
    ];

    //新的播放记录
    public function newHistory($data){

        //移除非本数据库字段
        $data = Model::removeUnsafeField($data, array_keys(self::$_COLUMNS));

        //转换字段类型为可靠类型
        $data = convertArrTo($data, self::$_COLUMNS);
        $data['play_at'] = time();

        return $this->insert($data);
    }

    //查看最近播放记录
    public function getHistory($uid){

        return $this->query(['uid' => convertTo(self::$_COLUMNS['uid'], $uid)])->order(['play_at' => -1])->limit(self::HISTORY_LIMIT)->cache(true)->getAll();
    }
}
