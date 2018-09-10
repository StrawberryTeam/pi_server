<?php
namespace models;
use \strawframework\base\Model;
/**
 * 影片合集
 * Class VideoSetModel
 */
class VideoSet extends Model {

    public function __construct() {
        parent::__construct($table = 'video_set', $pre = NULL);
    }

    //自定义平台
    CONST CUSTOM_PLATFORM = 0;
    //完结
    CONST EPISODE_OVER    = 1;
    CONST EPISODE_NOTOVER = 0;
    CONST EPISODE_ONCE    = 2;

    public static $_COLUMNS = [
        'title'          => 'string', #剧集名
        'summary'        => 'string', #剧集内容介绍
        'link'           => 'string', #内容页地址
        'img'            => 'string', #剧集封面图 url
        'episode_over'   => 'int', #int 1 已完结 0 未完结 2 单次导入
        'area'           => 'string', #影片地区
        'lang'           => 'string', #影片语言
        'is_vip'         => 'int', # 1 需要 vip 账号才能观看 0 无账号可观看,
        'allplaynum'     => 'int', # 总播放量
        'allplaynum_txt' => 'string', # 总播放量文本化
        'now_episode'    => 'string', # 当前更新集数文本化 例 138集
        'episode'        => 'int', # 'int 已找到的总集数 保存完所有影片分片后，通过 modifyEpisode(data, _id) 方法更新总分片数为总集数'
        'platform'       => 'int', # 平台 id 0 自定义平台
        'category'       => 'array', #影片分类
        'dl'             => 'array', #在下载该影片的设备
        'dled'           => 'array', #已完成下载的设备
        'play_num'       => 'array', # 每个设备可供播放数量
        'title_py'       => 'string', #标题全拼
        'title_pyshow'   => 'array', #标题全拼 数组
        'title_sp'       => 'string', #标题首拼
        'imgs'           => 'array', #已完成封面图片下载的设备
        'non_py'         => 'bool', #True 不对该内容产生拼音
        'created_uid'    => 'string', # 创建者，自定义影片集
        'hides'          => 'array', # 隐藏显示的 设备
        'sorts'          => 'array', # 需要排序的设备 及排序值
    ];

    //所有声母
    private $initials = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'w', 'x', 'y', 'z'];

    //是否全部为声母
    public function isAllInitials($key) {

        $keyArr = str_split($key);
        //大于4位的 优先全拼
        if (count($keyArr) > 5) {
            return FALSE;
        }
        foreach ($keyArr as $value) {
            //含有非声母的 优先全拼
            if (!in_array($value, $this->initials)) {
                return FALSE;
            }
        }

        return TRUE;
    }

    public function getInfo($_id) {

        return $this->query(['_id' => $_id])->getOne();
//        $this->_field = '_id';
//        $this->_value = $_id;
//        return $this->_ALL_;
    }

    public function getList($page = NULL, $keyword = '', $platform = '', $order = '', $count = 12, $query = [], $cached = FALSE, $priority = NULL) {
        $map = [];

        if ($query) {
            $map = array_merge($map, $query);
        }
        //根据关键词查询
        if ($keyword) {
            if (NULL == $priority) {
                //直接查询
                $map['$or'] =
                    [
                        ['title' => ['$like' => "^" . $keyword]],
                        ['summary' => ['$like' => $keyword]],
                        ['tags' => $keyword]
                    ];
            } else if ('SP' == strtoupper($priority)) {
                //首拼查询
                $map['title_sp'] = ['$like' => "^" . $keyword];
            } else if ('PY' == strtoupper($priority)) {
                //全拼查询
                $map['title_py'] = ['$like' => "^" . $keyword];
            }
        }

        if ($platform) {
            $map['platform'] = convertTo(self::$_COLUMNS['platform'], $platform);
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

    //获取本设备 标记为下载视频
    public function getDlvideo($uid, $_id) {

        $map['_id'] = $_id;
        $map['dl'] = $uid;

        return $this->query($map)->getOne();
    }

    //加入下载中
    public function dlVideo($uid, $_id) {

        return $this->update(['dl' => $uid], ['_id' => $_id], ['set' => '$push']);
    }

    //从下载中移出
    public function unDlVideo($uid, $_id) {

        return $this->update(['dl' => $uid], ['_id' => $_id], ['set' => '$pull']);
    }

    //创建新影片集，自定义影片集
    public function newSet($data, $deviceId) {
        $data['platform'] = self::CUSTOM_PLATFORM;
        $data['episode_over'] = self::EPISODE_ONCE;
        $data['episode'] = 0; //创建时真实集数
        $data['is_vip'] = 0;
        $data['created_uid'] = $deviceId;
        $data['non_py'] = TRUE;
        $data['imgs'] = [conv2string($deviceId) => $data['img']];

        //移除非本数据库字段
        $data = Model::removeUnsafeField($data, array_keys(self::$_COLUMNS));

        //转换字段类型为可靠类型
        $data = convertArrTo($data, self::$_COLUMNS);

        //insert new
        return $this->insert($data);
    }


    //更新 影片集 影片数量
    public function updateVideoNum($setId, $num, $playNum, $deviceId) {

        return $this->update([
                                 'episode'               => $num, //增加集数
                                 'play_num.' . conv2string($deviceId) => $playNum, //增加本设备的播放数
                             ], ['_id' => $setId], ['set' => '$inc']);
    }

    // 更新设备 排序值
    public function updateSort($setId, $sort, $deviceId){

        return $this->update(['sorts.' . $deviceId => conv2int($sort)], ['_id' => $setId]);
    }

    public function changeHide($setId, $type, $deviceId){
        if ('hide' == $type){
            return $this->update(['hides' => $deviceId], ['_id' => $setId], ['set' => '$push']);
        }
        if ('show' == $type){
            return $this->update(['hides' => $deviceId], ['_id' => $setId], ['set' => '$pull']);
        }
    }
}
