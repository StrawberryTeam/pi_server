<?php
namespace models;
use \strawframework\base\Model;

/**
 * 任务
 * Class VideoSetModel
 */
class Task extends Model{

    public function __construct() {
        parent::__construct($table = 'task', $pre = null);
    }

    CONST HISTORY_LIMIT = 24;

    CONST TASK_READY = 1; //未执行的任务
    CONST TASK_FAILD = 2; //失败的任务
    CONST TASK_SUCCESS = 3; //成功的任务
    public static $_COLUMNS = [
        'videoIds' => 'string', //待操作的 视频
        'setId'    => 'objectid', //视频集 id
        'fromDevice' => 'string',
        'toDevice' => 'string', // to device uid
        'type'     => 'string', // copy 复制 zip 打包 addset 添加影片集 addvideo 添加影片
        'link' => 'string',  //添加影片 / 影片集任务
        'platform' => 'int', //影片集 / 影片 对应的平台
        'created_at' => 'int',
        'sort' => 'int', //排序方法
        'status' => 'int', //状态
        'transfer_status' => 'int', //传送状态
        'file_md5' => 'string', //传送文件的 md5
        'file_path' => 'string', //传送文件在中转服务端的位置
    ];

    //新任务
    public function newTask($data){

        //移除非本数据库字段
        $data = Model::removeUnsafeField($data, array_keys(self::$_COLUMNS));

        //转换字段类型为可靠类型
        $data = convertArrTo($data, self::$_COLUMNS);
        $data['created_at'] = time();
        $data['status'] = self::TASK_READY;

        return $this->insert($data);
    }

    //是否有相同的复制任务存在
    public function copyTaskExists($data){

        return $this->query([
                                "type"     => "copy",
                                "fromDevice" => $data['fromDevice'],
                                "toDevice" => $data['toDevice'],
                                "videoIds" => $data['videoIds'],
                                'status' => self::TASK_READY
                            ])->count() > 0 ? true : false;
    }

    //查看最近播放记录
    public function getTask($uid){

        return $this->query(['uid' => convertTo(self::$_COLUMNS['uid'], $uid)])->order(['play_at' => -1])->limit(self::HISTORY_LIMIT)->cache(true)->getAll();
    }

    //添加影片集任务是否有重复
    public function addSetExists($link){
        return $this->query(['link' => $link, 'status' => self::TASK_READY])->count() > 0 ? true : false;
    }
}
