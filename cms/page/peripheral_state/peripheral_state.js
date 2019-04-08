layui.use(['form', 'util', 'layer', 'laydate', 'table', 'laytpl', 'util'], function() {
    var form = layui.form;
    var util = layui.util;
    layer = parent.layer === undefined ? layui.layer : top.layer,
        $ = layui.jquery,
        laydate = layui.laydate,
        laytpl = layui.laytpl,
        table = layui.table;


    $.ajax({
        url: "https://pay.imbatv.cn/api/peripheral/get_list",
        type: "GET",

        dataType: 'json',
        success: function(data) {
            var html = '';
            for (var i = 0; i < data.detail.length; i++) {
                html += '<h1>' + data.detail[i].type_name + '总数:' + data.detail[i].total + '</h1>'
            }
            $(".top").html(html);
        },
        error: function(err) {
            console.log(err);
        }
    });


    var tableIns = table.render({
        elem: '#newsList',
        url: 'https://pay.imbatv.cn/api/peripheral/get_list',
        limit: 15,
        limits: [15, 30, 45, 60],
        page: true,
        //,…… //其他参数
        cols: [
            [
                { field: 'type_name', title: '种类', align: 'center' },
                { field: 'desc', title: '型号', align: "center" },
                { field: 'user', title: '使用中', align: 'center' },
                { field: 'count', title: '库存', align: 'center' }
            ]
        ],
        done: function(res, curr, count) {
            console.log(res)
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
        var list = data.detail;
        console.log(list);
        var html_1 = '';
        var html_2 = '';
        var sum = 0;
        for (var i = 0; i < list.length; i++) {
            html_1 += '<li>' + list[i].name + 'x' + list[i].num + '</li>'
        }
        for (var i = 0; i < list.length; i++) {
            var price = list[i].num * list[i].money;
            sum += price;
            console.log(sum);
        }
        $(".content .con").html(html_1);
        $(".content .price_1").html('价格：' + sum);
        var order_id = obj.data.id;
        if (layEvent === 'sure') { //充值记录
            $.ajax({
                url: "https://pay.imbatv.cn/api/goods/done_order",
                type: "POST",
                data: {
                    order_id: order_id
                },
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
        } else {
            layer.open({
                type: 2,
                title: '',
                shadeClose: true,
                shade: 0.8,
                closeBtn: 0,
                area: ['400px', '400px'],
                content: 'page/alert_4/details.html',
                success: function(layero, index) {
                    var body = layer.getChildFrame('body', index);
                    var iframeWin = window[layero.find('iframe')[0]['name']]; //得到iframe页的窗口对象，执行iframe页的方法：iframeWin.method();
                    var content1 = $('.content .con').html();
                    var content2 = $('.content .price_1').html();
                    console.log(content)
                    body.find('.content .con').html(content1);
                    body.find('.content .price_1').html(content2);
                    layer.iframeAuto(index);
                }
            });
        }
    });
})