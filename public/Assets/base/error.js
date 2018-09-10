/**
 * Created by zacklee
 */
function errcode2txt(code){

    var errArr = {
        1001 : '邮箱格式不正确',
        1002 : ''
    };

    return errArr[code] ? errArr[code] : false;
}
