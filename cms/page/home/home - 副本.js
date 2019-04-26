layui.use(['form', 'util', 'layer', 'laydate', 'table', 'laytpl', 'util'], function() {
    var form = layui.form;
    var util = layui.util;
    layer = parent.layer === undefined ? layui.layer : top.layer,
        $ = layui.jquery,
        laydate = layui.laydate,
        laytpl = layui.laytpl,
        table = layui.table;
        userid = '';
    // 搜索
    $('.search_btn').on('click', function() {
        var searchVal = $(".searchVal").val();
        $.ajax({
                url: 'https://pay.imbatv.cn/api/user/find?parm='+searchVal,
                type: "POST",
                dataType: 'json',
                success: function(data) {
                    console.log(data);
                    if (data.code == 200) {
                        // layer.msg(data.message, { time: 1000 }, function() {
                        //     //回调
                        //     window.location.reload();
                        // })
                        $(".sp1").html("姓名："+data.data.name);
                        $(".sp2").html("身份证："+data.data.idcard);
                        $(".sp3").html("手机："+data.data.phone);
                        $(".sp4").html("会员号："+data.data.username);
                        $(".sp5").html("会员等级："+data.data.level);
                        $(".sp6").html("余额："+data.data.balance);
                        userid = data.data.uid;

                        const ipcRenderer = require('electron').ipcRenderer;
                        ipcRenderer.send('change-user', data.data.name);
                    } else {
                        layer.msg(data.message);
                        $(".sp1").html("姓名：");
                        $(".sp2").html("身份证：");
                        $(".sp3").html("手机：");
                        $(".sp4").html("会员号：");
                        $(".sp5").html("会员等级：");
                        $(".sp6").html("余额：");
                        userid = "";
                    }

                },
                error: function(err) {
                    console.log(err);
                }
            });
    });
 $('.op-cp').on('click', function() {
    if (userid == "") {
        layer.msg("请输入正确信息！！！");
    }else{
        layer.open({
            type: 2,
            title: '',
            shadeClose: true,
            shade: 0.8,
            area: ['1200px', '880px'],
            content: '../../page/alert_2/recharge.html?userid=' + userid, //iframe的url
        });
    }
 });
});
// 验证手机号
function isPhoneNo(phone) {
    var pattern = /^1[34578]\d{9}$/;
    return pattern.test(phone);
}

function createTime(v) {
    var date = new Date(v * 1000);
    var y = date.getFullYear();
    var m = date.getMonth() + 1;
    m = m < 10 ? '0' + m : m;
    var d = date.getDate();
    d = d < 10 ? ("0" + d) : d;
    var h = date.getHours();
    h = h < 10 ? ("0" + h) : h;
    var M = date.getMinutes();
    M = M < 10 ? ("0" + M) : M;
    var str = y + "-" + m + "-" + d + " " + h + ":" + M;
    return str;
}