layui.use(['form', 'util', 'layer', 'laydate', 'table', 'laytpl', 'util'], function() {
    var form = layui.form;
    var util = layui.util;
    var startT ='';
    var endT ='';
    var status ='';
    layer = parent.layer === undefined ? layui.layer : top.layer,
        $ = layui.jquery,
        laydate = layui.laydate,
        laytpl = layui.laytpl,
        table = layui.table;

    //日期范围
    laydate.render({
        elem: '#test6',
        range: true,
        done: function(dates){ //选择好日期的回调
             startT = dates.split(' - ')[0];
             endT = dates.split(' - ')[1];
             status = 1;
             $("#test7").val("");
             $("#test8").val("");
        }
    });
    laydate.render({
        elem: '#test7',
        range: true,
        done: function(dates){ //选择好日期的回调
             startT = dates.split(' - ')[0];
             endT = dates.split(' - ')[1];
             status = 2 ;
             $("#test6").val("");
             $("#test8").val("");
        }
    });
    laydate.render({
        elem: '#test8',
        range: true,
        done: function(dates){ //选择好日期的回调
             startT = dates.split(' - ')[0];
             endT = dates.split(' - ')[1];
             status = 3 ;
             $("#test6").val("");
             $("#test7").val("");
        }
    });
    var tableIns = table.render({
        elem: '#newsList1',
        url: 'https://pay.imbatv.cn/tool/log/pay?startdate=2017-01-01',
        limit: 15,
        limits: [15, 30, 45, 60],
        page: true,
        //,…… //其他参数
        cols: [
            [
                { field: 'vip_num', title: '会员号', align: 'center', },
                { field: 'level', title: '会员等级', align: 'center', },
                { field: 'name', title: '姓名', align: "center" },
                { field: 'phone', title: '手机号', align: 'center' },
                { field: 'idcard', title: '身份证号/护照号', align: 'center' },
                { field: 'starttime', title: '开始时间', align: 'center',
                     templet: function(d) {
                        return createTime(d.starttime);
                    }
                 },
                { field: 'endtime', title: '结束时间', align: 'center',
                     templet: function(d) {
                        return createTime(d.endtime);
                    }
                },
                { field: 'number', title: '上机时长', align: 'center' },
                { field: 'money', title: '本次消费', align: 'center' },
            ]
        ],
        done: function(res, curr, count) {
            // 隐藏列
            console.log(res);
            var layEvent = res.event,
                data = res.data;
        }
    });
    var tableIns = table.render({
        elem: '#newsList2',
        url: 'https://pay.imbatv.cn/tool/log/pay?startdate=2017-01-01',
        limit: 15,
        limits: [15, 30, 45, 60],
        page: true,
        //,…… //其他参数
        cols: [
            [
                { field: 'vip_num', title: '会员号', align: 'center', },
                { field: 'level', title: '会员等级', align: 'center', },
                { field: 'name', title: '姓名', align: "center" },
                { field: 'good_name', title: '消費商品', align: "center" },
                { field: 'phone', title: '手机号', align: 'center' },
                { field: 'idcard', title: '身份证号/护照号', align: 'center' },
                { field: 'number', title: '數量', align: 'center' },
                { field: 'price', title: '單價', align: 'center' },
                { field: 'money', title: '本次消费', align: 'center' },
            ]
        ],
        done: function(res, curr, count) {
            // 隐藏列
            console.log(res);
            var layEvent = res.event,
                data = res.data;

        }
    });
    var tableIns = table.render({
        elem: '#newsList3',
        url: 'https://pay.imbatv.cn/tool/log/pay?startdate=2017-01-01',
        limit: 15,
        limits: [15, 30, 45, 60],
        page: true,
        //,…… //其他参数
        cols: [
            [
                { field: 'vip_num', title: '会员号', align: 'center', },
                { field: 'level', title: '会员等级', align: 'center', },
                { field: 'name', title: '姓名', align: "center" },
                { field: 'phone', title: '手机号', align: 'center' },
                { field: 'idcard', title: '身份证号/护照号', align: 'center' },
                { field: 'money', title: '充值金額', align: 'center' },
                { field: 'extra_num', title: '店長贈送', align: 'center' },
                { field: 'pay_type', title: '充值方式', align: 'center' },
                
            ]
        ],
        done: function(res, curr, count) {
            // 隐藏列
            console.log(res);
            console.log(curr);
            console.log(count);
            var layEvent = res.event,
                data = res.data;
        }
    });

        // 搜索
    var $ = layui.$,
        active = {
            reload: function() {
                 console.log(startT);
                 if (status == 1) {//上幾款查詢 
                    $(".spc1").show();
                    $(".spc2").hide();
                    $(".spc3").hide();
                    table.reload('newsList1', {
                    url: 'https://pay.imbatv.cn/tool/log/play',
                    where: {
                        startdate: startT,
                        enddate: endT,
                    },
                    page: {
                        curr: 1 //重新从第 1 页开始
                    }
                    });
                 }else if(status == 2){//銷售查詢 
                    $(".spc1").hide();
                    $(".spc2").show();
                    $(".spc3").hide();
                    table.reload('newsList2', { 
                    url: 'https://pay.imbatv.cn/tool/log/sale',
                    where: {
                        startdate: startT,
                        enddate: endT,
                    },
                    page: {
                        curr: 1 //重新从第 1 页开始
                    }
                    });
                  }else if(status == 3){ //充值查詢 
                    $(".spc1").hide();
                    $(".spc2").hide();
                    $(".spc3").show();
                    table.reload('newsList3', {
                    url: 'https://pay.imbatv.cn/tool/log/pay',
                    where: {
                        startdate: startT,
                        enddate: endT,
                    },
                    page: {
                        curr: 1 //重新从第 1 页开始
                    }
                    });
                 }
                
            }
        };

    $('.record').on('click', function() {
        var type = $(this).data('type');
        active[type] ? active[type].call(this) : '';
    });



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