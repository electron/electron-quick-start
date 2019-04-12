layui.use(['form', 'util', 'layer', 'laydate', 'table', 'laytpl', 'util'], function() {
    var form = layui.form;
    var util = layui.util;
    var startT = '';
    var endT = '';
    var status = '';
    layer = parent.layer === undefined ? layui.layer : top.layer,
        $ = layui.jquery,
        laydate = layui.laydate,
        laytpl = layui.laytpl,
        table = layui.table;

    //日期范围
    laydate.render({
        elem: '#test6',
        range: true,
        done: function(dates) { //选择好日期的回调
            startT = dates.split(' - ')[0];
            endT = dates.split(' - ')[1];
            status = 1;
            $("#test7").val("");
            $("#test8").val("");
        }
    });
    $('.record').on('click', function() {
        // var type = $(this).data('type');
        console.log(startT);
        console.log(endT);
        // active[type] ? active[type].call(this) : '';
        report_form(startT, endT);
    });
    report_form(startT, endT);

    function report_form(startT, endT) {
        $.ajax({
            type: 'GET',
            cache: true,
            url: "https://pay.imbatv.cn/tool/log/report?startdate=" + startT + "&enddate=" + endT,
            dataType: 'json',
            success: function(res) {
                console.log(res);
                $(".item1").html(res.data[0]["总单机"]);
                $(".item2").html(res.data[0]["上座率"]);
                $(".item3").html(res.data[0]["上网均价"]);
                $(".item4").html(res.data[0]["上网收入"]);
                $(".item5").html(res.data[0]["上网占比"]);
                $(".item6").html(res.data[0]["饮料收入"]);
                $(".item7").html(res.data[0]["休闲食品收入"]);
                $(".item8").html(res.data[0]["会员充值收入"]);
                $(".item9").html(res.data[0]["总营业额"]);
                $(".item10").html(res.data[0]["人次"]);
                $(".item11").html(res.data[0]["饮料捕获率"]);
                $(".item12").html(res.data[0]["饮料收入"]);
                $(".item13").html(res.data[0]["翻机率"]);
                $(".item14").html(res.data[0]["会员充值收入"]);
                $(".item15").html(res.data[0]["总客单价"]);
                $(".item16").html(res.data[0]["人均上机时长"]);
                $(".item17").html(res.data[0]["新办会员"]);
                $(".item18").html(res.data[0]["PC机台数/可运营台数"]);
                $(".item19").html(res.data[0]["美团POS机支付金额"]);
                $(".item20").html(res.data[0]["美团小白盒支付金额"]);
                $(".item21").html(res.data[0]["现金支付金额"]);
                $(".item22").html(res.data[0]["微信小程序支付金额"]);
            },
            error: function(e) {
                console.log(e);
            }
        });

    }

    // 验证手机号
    function isPhoneNo(phone) {
        var pattern = /^1[34578]\d{9}$/;
        return pattern.test(phone);
    }

    //列表操作
    table.on('tool(newsList)', function(obj) {
        var layEvent = obj.event,
            data = obj.data;
        var list = data.detail;
        var order_id = obj.data.id;
        if (layEvent === 'record') { //
            modify(data);
        }
    });
})


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