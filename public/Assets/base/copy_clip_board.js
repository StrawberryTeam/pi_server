define(['jquery'], function($){
    var copy_input = function (obj){
        obj.select();
        document.execCommand("Copy");
        return true;
    };
    return {copy_input:copy_input};
});


