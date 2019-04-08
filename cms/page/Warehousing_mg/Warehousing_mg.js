layui.use(['form', 'util', 'layer', 'laydate', 'table', 'laytpl', 'util'], function() {
    var form = layui.form;
    var util = layui.util;
    layer = parent.layer === undefined ? layui.layer : top.layer,
        $ = layui.jquery,
        laydate = layui.laydate,
        laytpl = layui.laytpl,
        table = layui.table;


    var tableIns = table.render({
        elem: '#newsList',
        url: 'https://pay.imbatv.cn/api/peripheral/get_need_in_list',
        limit: 15,
        limits: [15, 30, 45, 60],
        page: true,
        //,…… //其他参数
        cols: [
            [
                // { field: 'id', title: 'ID', align: 'center' },
                { field: 'desc', title: '名称', align: 'center' },
                { field: 'time', title: '时间', align: 'center',
                    templet: function(d) {
                        return createTime(d.time);
                    }
                 },
                { title: '操作',  templet: '#newsListBar', fixed: "right", align: "center" }
            ]
        ],
        done: function(res, curr, count) {
            // 隐藏列
            console.log(res);
            var layEvent = res.event,
                data = res.data;
           
            $(".layui-table-box").find("[data-field='state']").css("display", "none");
            $(".layui-table-box").find("[data-field='id']").css("display", "none");
            $(".layui-table-box").find("[data-field='aaa']").addClass('aaa');
            $(".layui-table-box").find("[data-field='aaa']").append('<div class="xq"></div>');
            var html = '';
        }
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
        console.log(data);
        console.log(data.id);
        var order_id = obj.data.id;
        console.log(order_id);
        if (layEvent === 'sure') { 
            $.ajax({
                url: "https://pay.imbatv.cn/api/peripheral/in?id="+order_id,
                type: "POST",
                dataType: 'json',
                success: function(data) {
                    console.log(data);
                    if (data.code == 200) {
                        layer.msg(data.message, { time: 1000 }, function() {
                            //回调
                            window.location.reload();
                        })
                    } else {
                        layer.msg(data.message);
                    }

                },
                error: function(err) {
                    console.log(err);
                }
            });
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