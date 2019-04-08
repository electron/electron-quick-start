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
        url: 'https://pay.imbatv.cn/api/user/get_live_user',
        limit: 15,
        limits: [15, 30, 45, 60],
        page: true,
        // cellMinWidth:80,
        //,…… //其他参数
        cols: [
            [
                // {type: "checkbox", fixed:"left", width:50},
                { field: 'uid', title: 'ID', align: 'center'},
                { field: 'state', title: '状态', align: 'center'},
                { field: 'username', title: '会员号', align: "center",},
                // { field: 'level', title: '会员等级', align: 'center' },
                { field: 'name', title: '姓名', align: 'center' ,width:80},
                { field: 'phone', title: '手机号',  align: 'center',},
                // { field: 'idcard', title: '身份证号/护照号',  align: "center",width:'180' },
                { field: 'balance', title: '余额', align: 'center',},
                { field: 'machine_name', title: '机器号', align: 'center'},
                { field: 'box', title: '包厢号', align: 'center' },
                { field: 'remain_seconds', title: '剩余时间', align: 'center',
                    templet: function(d) {
                        return formatDuring(d.remain_seconds);
                    } 
                 },
                { field: 'cost', title: '当前消费', align: 'center',width:100 },
                // {
                //     field: 'opentime',
                //     title: '开卡时间',
                //     width: 100,
                //     align: 'center',
                //     templet: function(d) {
                //         return createTime(d.opentime);
                //     }
                // },
                {
                    field: 'online_seconds',
                    width: 100,
                    title: '上机时长',
                    align: 'center',
                    width:120,
                    templet: function(row) {
                        return formatDuring(row.online_seconds);
                    }
                },
                // { field: 'balance', title: '外设状态', align: 'center' },

                { title: '操作', width: 270, templet: '#newsListBar', fixed: "right", align: "center" ,width:220}
            ]
        ],
        done: function(res, curr, count) {
            console.log(res);
            // 隐藏列
            $(".layui-table-box").find("[data-field='state']").css("display", "none");
            $(".layui-table-box").find("[data-field='uid']").css("display", "none");
        }
    });

    var $ = layui.$, active = {
        reload: function(){
            var searchVal = $(".searchVal").val();
            if (isPhoneNo(searchVal)) {
                username = '';
                phone = searchVal;
                name = '';
                idcard = '';
            } else {
                username = searchVal;
                phone = '';
                name = '';
                idcard = '';
            }
            table.reload('newsList', {
                where: {
                    username: username,
                    phone: phone,
                    name: name,
                    idcard: idcard
                } ,page: {
                    curr: 1 //重新从第 1 页开始
                }
            });
        }
    };

    $('.search_btn').on('click', function(){
    var type = $(this).data('type');
    active[type] ? active[type].call(this) : '';
    });

    // 验证手机号
    function isPhoneNo(phone) {
        var pattern = /^1[34578]\d{9}$/;
        return pattern.test(phone);
    }

    //充值查询
    function Recharge(edit) {
        var uid = edit.uid;
        var index = layui.layer.open({
            title: "充值记录查询",
            type: 2,
            content: "recharge.html?uid=" + uid,
            success: function(layero, index) {
                var body = layui.layer.getChildFrame('body', index);
                if (edit) {
                    body.find(".newsName").val(edit.newsName);
                    body.find(".abstract").val(edit.abstract);
                    body.find(".thumbImg").attr("src", edit.newsImg);
                    body.find("#news_content").val(edit.content);
                    body.find(".newsStatus select").val(edit.newsStatus);
                    body.find(".openness input[name='openness'][title='" + edit.newsLook + "']").prop("checked", "checked");
                    body.find(".newsTop input[name='newsTop']").prop("checked", edit.newsTop);
                    form.render();
                }
                setTimeout(function() {
                    layui.layer.tips('点击此处返回在线会员列表', '.layui-layer-setwin .layui-layer-close', {
                        tips: 3
                    });
                }, 300)
            }
        })
        layui.layer.full(index);
    }
    //消费查询
    function consumption(edit) {
        var uid = edit.uid;
        var index = layui.layer.open({
            title: "消费记录查询",
            type: 2,
            content: "consumption.html?uid=" + uid,
            success: function(layero, index) {
                var body = layui.layer.getChildFrame('body', index);
                if (edit) {
                    body.find(".newsName").val(edit.newsName);
                    body.find(".abstract").val(edit.abstract);
                    body.find(".thumbImg").attr("src", edit.newsImg);
                    body.find("#news_content").val(edit.content);
                    body.find(".newsStatus select").val(edit.newsStatus);
                    body.find(".openness input[name='openness'][title='" + edit.newsLook + "']").prop("checked", "checked");
                    body.find(".newsTop input[name='newsTop']").prop("checked", edit.newsTop);
                    form.render();
                }
                setTimeout(function() {
                    layui.layer.tips('点击此处返回在线会员列表', '.layui-layer-setwin .layui-layer-close', {
                        tips: 3
                    });
                }, 500)
            }
        })
        layui.layer.full(index);
        //改变窗口大小时，重置弹窗的宽高，防止超出可视区域（如F12调出debug的操作）
    }



    //列表操作
    table.on('tool(newsList)', function(obj) {
        console.log(obj);
        var layEvent = obj.event,
            data = obj.data;
        var userid = obj.data.uid;
        if (layEvent === 'recharge') { //充值记录
            Recharge(data);
        } else if (layEvent === 'consumption') { //消费记录
            consumption(data);
        } else if (layEvent === 'down-cp') { //下机
            // alert(1);
            // var user_id = obj.data.uid;
            // alert(user_id);
            // $.ajax({
            //     url: "https://pay.imbatv.cn/api/machine/down",
            //     type: "post",
            //     data: {
            //         user_id: user_id,
            //         op: 'down',
            //     },
            //     dataType: 'json',
            //     success: function(data) {
            //         location.reload();
            //     },
            //     error: function(err) {}
            // });

            layer.open({
                type: 2,
                title: '',
                shadeClose: true,
                shade: 0.8,
                area: ['800px', '500px'],
                content: 'page/alert_6/give.html?userid=' + userid, //iframe的url
                success: function(layero, index) {
                    var body = layer.getChildFrame('body', index);
                    var iframeWin = window[layero.find('iframe')[0]['name']]; //得到iframe页的窗口对象，执行iframe页的方法：iframeWin.method();
                    body.find('.cz').attr('userid', userid);
                },
                end: function() {
                    var searchVal = $(".searchVal").val();
                    if (searchVal != '') {
                        if (isPhoneNo(searchVal)) {
                            username = '';
                            phone = searchVal;
                            name = '';
                            idcard = '';
                        } else {
                            username = searchVal;
                            phone = '';
                            name = '';
                            idcard = '';
                        }
                        tableIns.reload({
                            url: 'https://pay.imbatv.cn/api/user/get_user_list',
                            where: {
                                username: username,
                                phone: phone,
                                name: name,
                                idcard: idcard
                            },
                            page: {
                                curr: 1 //重新从第 1 页开始
                            }
                        });
                    } else {
                        tableIns.reload({});
                    }
                }
            });
        } else if (layEvent === 'information') { //绑定信息
            layer.open({
                type: 2,
                title: '',
                shadeClose: true,
                shade: 0.8,
                area: ['600px', '300px'],
                content: 'page/alert_3/recharge.html?userid=' + userid, //iframe的url
            });
        }
    });

})

function formatDuring(mss) {
    var days = parseInt(mss / (60 * 60 * 24));
    var hours = parseInt((mss % (60 * 60 * 24)) / (60 * 60));
    var minutes = parseInt((mss % (60 * 60)) / (60));
    var seconds = (mss % (1000 * 60)) / 1000;
    if (days == 0) {
        return hours + " 小时 " + minutes + " 分钟 ";
    } else if (days == 0 && hours == 0) {
        return minutes + " 分钟 ";
    } else {
        return days + " 天 " + hours + " 小时 " + minutes + " 分钟 ";
    }

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