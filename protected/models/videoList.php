<?php
namespace models;
use \strawframework\base\Model;

/**
 * 影片合集
 * Class VideoSetModel
 */
class VideoList extends Model {

    public function __construct() {
        parent::__construct($table = 'video_list', $pre = NULL);
    }


    public static $_COLUMNS = [
        'setId'       => 'objectid', #ideo_set 剧集 _id,
        'name'        => 'string', #影片名称
        'summary'     => 'string', #影片介绍
        'link'        => 'string', #影片播放地址
        'img'         => 'string', #影片封面图
        'created_at'  => 'int', #影片发布时间
        'duration'    => 'string', #'影片时间 例 01:10 没有不写该字段'
        'name_sp'     => 'string', #影片名首拼
        'name_py'     => 'string', #影片名全拼
        'name_pyshow' => 'array',#影片名数组
        'plays'       => 'array', #每个设备该影片的播放地址
        'imgs'        => 'array', #每个设备该影片的封面图
        'non_py'      => 'bool', #True 不对该内容产生拼音
    ];

    public function getList($setId = NULL, $page = NULL, $keyword = '', $order = '', $count = 30, $query = [], $cached = FALSE, $priority = NULL) {

        $map = [];
        if ($query) {
            $map = array_merge($map, $query);
        }
        if ($setId) {
            $map['setId'] = new \MongoDB\BSON\ObjectId($setId);
        }
        //根据关键词查询
        if ($keyword) {
            if (NULL == $priority) {
                //直接查询
                $map['$or'] =
                    [
                        ['name' => ['$like' => "^" . $keyword]],
                        ['summary' => ['$like' => $keyword]],
                        ['tags' => $keyword]
                    ];
            } else if ('SP' == strtoupper($priority)) {
                //首拼查询
                $map['name_sp'] = ['$like' => "^" . $keyword];
            } else if ('PY' == strtoupper($priority)) {
                //全拼查询
                $map['name_py'] = ['$like' => "^" . $keyword];
            }
        }
        //当前条件总量
        $total = $this->query($map)->count();
        //page偏移量
        $offset = $page * $count - $count;
        //要求不缓存内容
        //if (FALSE == $cached) {
        //} else {
        //    $list = $this->query($map)->order($order)->offset($offset)->limit($count)->cache(TRUE)->getAll();
        //}
        $list = $this->query($map)->order($order)->offset($offset)->limit($count)->getAll();
        // total 为最数据
        // list 为结果集数组
        return [
            'list'  => $list,
            'total' => $total
        ];
    }

    //获取视频信息
    public function getInfo($_id) {

        return $this->query(['_id' => $_id])->getOne();
    }

    //获取本视频的下一个视频
    public function getNext($_id, $setId, $uid) {

        //相同 setId 在本设备中 的下一个视频
        $list = $this->query([
                                 'setId'         => $setId,
                                 '_id'           => ['$gt' => new \MongoDB\BSON\ObjectId($_id)],
                                 'plays.' . $uid => ['$exists' => TRUE]
                             ])->order(['_id' => 1])->limit(1)->getAll();

        //echo $this->getLastSql();die;
        return current($list);
    }

    //获取上一个视频
    public function getPre($_id, $setId, $uid) {

        $list = $this->query([
                                 'setId'         => $setId,
                                 '_id'           => ['$lt' => new \MongoDB\BSON\ObjectId($_id)],
                                 'plays.' . $uid => ['$exists' => TRUE]
                             ])->order(['_id' => -1])->limit(1)->getAll();

        //echo $this->getLastSql();die;
        return current($list);
    }

    public function getFirstId($setId, $uid) {

        $list = $this->query([
                                 'setId'         => $setId,
                                 'plays.' . $uid => ['$exists' => TRUE]
                             ])->order(['_id' => 1])->limit(1)->getAll();

        return current($list);
    }

    //添加新的播放记录数字
    public function newView($_id) {

    }

    //通过 ids 获取所有视频信息
    public function getVideosViaIds($ids){

        if (!is_array($ids))
            $ids = explode(',', $ids);

        foreach ($ids as $key => $id) {
            if (!is_object($id))
                $ids[$key] = conv2objectid($id);
        }
        $map = ['_id' => ['$in' => $ids]];
        $list = $this->query($map)->getAll();
        $total = $this->query($map)->count();
        return $list ? ['list' => $list, 'total' => $total] : false;
    }


    /**
     * 添加新视频
     * @param      $data
     * @param bool $bulk 是否批量插入
     *
     * @return mixed
     */
    public function addVideo($data){

        foreach ($data as $key => $value) {
            //移除非本数据库字段
            $value = Model::removeUnsafeField($value, array_keys(self::$_COLUMNS));

            //转换字段类型为可靠类型
            $data[$key] = convertArrTo($value, self::$_COLUMNS);
        }

        return $this->insert($data, ['bulk' => true]);
    }

    /**
     * 复制影片
     * @param array|string $videos 复制的影片 ids
     * @param object|string $setId 复制到影片集 id
     * @return int 复制成功的数量
     */
    public function cpVideos($videos, $setId){

        if (!is_object($setId))
            $setId = conv2objectid($setId);

        $list = $this->getVideosViaIds($videos);
        foreach ($list['list'] as $key => $value){
            //不允许在本影片集中复制
            if ($value['setId'] == $setId)
                ex('不能将影片复制至同一影片集中', '', Controller::FAIL);
            $list['list'][$key]['setId'] = $setId;
        }

        $addStatus = $this->addVideo($list['list']);

        if (false !== $addStatus){
            return $list['total'];
        }
        return $addStatus;
    }


    /**
     * 本设备可播放影片数量
     * @param array|string $ids video ids
     * @param string $deviceId 设备id
     * @return int 可播放数量
     */
    public function getPlayNumsViaIds($ids, $deviceId){
        if (!is_array($ids))
            $ids = explode(',', $ids);

        foreach ($ids as $key => $id) {
            if (!is_object($id))
                $ids[$key] = conv2objectid($id);
        }
        $map = [
            '_id' => ['$in' => $ids],
            'plays.' . conv2string($deviceId) => ['$exists' => true] //播放地址存在的
        ];
        return $this->query($map)->count();
    }
}
