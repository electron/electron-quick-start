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
        autoSort: false,
        url: 'https://pay.imbatv.cn/api/user/get_user_list?offline=1',
        limit: 15,
        loading: false,
        limits: [15, 30, 45, 60],
        page: true,
        // cellMinWidth:100,
        cols: [
            [
                { field: 'id', title: 'ID', align: 'center',  },
                { field: 'state', title: '状态', align: 'center' ,},
                { field: 'username', title: '会员号', align: "center"},
                { field: 'level', title: '会员等级', align: 'center' },
                { field: 'name', title: '姓名', align: 'center' },
                { field: 'phone', title: '手机号',  align: 'center' },
                { field: 'idcard', title: '身份证号/护照号',  align: "center" },
                { field: 'balance', title: '卡内余额', align: 'center', sort: true  },
                { field: 'lasttime', title: '最后上机', sort: true,align: 'center',
                    templet: function(d) {
                        return createTime(d.lasttime);
                    }
                 },
                { title: '操作',  templet: '#newsListBar', fixed: "right", align: "center" }
            ]
        ],
        done: function(res, curr, count) {
            // 隐藏列
            console.log(res);
            $(".layui-table-box").find("[data-field='state']").css("display", "none");
            $(".layui-table-box").find("[data-field='id']").css("display", "none");
        }
    });

    var $ = layui.$,
        active = {
            reload: function() {
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
                    }
                    ,page: {
                        curr: 1 //重新从第 1 页开始
                      }
                });
            }
        };

    $('.search_btn').on('click', function() {
        var type = $(this).data('type');
        active[type] ? active[type].call(this) : '';
    });

//监听排序事件 
table.on('sort(newsList)', function(obj){ 
  console.log(obj.field);
  console.log(obj.type); 
  console.log(this); 
  var type =toUpperCase(obj.type);
  table.reload('newsList', {
    initSort: obj, 
    where: {
      order_option: obj.field, //排序字段
      order: type //排序方式
    }
  });
});

    // 验证手机号
    function isPhoneNo(phone) {
        var pattern = /^1[34578]\d{9}$/;
        return pattern.test(phone);
    }

    function toUpperCase(str) { //小写字母转大写
        str = str.toUpperCase();
        return str;
    }

    //充值查询
    function Recharge(edit) {
        var uid = edit.id;
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
                    layui.layer.tips('点击此处返回离线会员列表', '.layui-layer-setwin .layui-layer-close', {
                        tips: 3
                    });
                }, 300)
            }
        })
        layui.layer.full(index);
        //改变窗口大小时，重置弹窗的宽高，防止超出可视区域（如F12调出debug的操作）
      
    }
    //消费查询
    function consumption(edit) {
        var uid = edit.id;
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
                    layui.layer.tips('点击此处返回离线会员列表', '.layui-layer-setwin .layui-layer-close', {
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
        var userid = obj.data.id;
        if (layEvent === 'recharge') { //充值记录
            Recharge(data);
        } else if (layEvent === 'consumption') { //消费记录
            consumption(data);
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