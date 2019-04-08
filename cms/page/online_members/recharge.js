layui.use(['form', 'util', 'layer', 'laydate', 'table', 'laytpl', 'util'], function() {
    var form = layui.form
    layer = parent.layer === undefined ? layui.layer : top.layer,
        laypage = layui.laypage,
        upload = layui.upload,
        layedit = layui.layedit,
        laydate = layui.laydate,
        table = layui.table;
    $ = layui.jquery;
    function getQueryString(name) {
        var reg = new RegExp('(^|&)' + name + '=([^&]*)(&|$)', 'i');
        var r = window.location.search.substr(1).match(reg);
        if (r != null) {
            return unescape(r[2]);
        }
        return null;
    }
    var uid =getQueryString("uid");
    $.ajax({
        url: "https://pay.imbatv.cn/api/user/get_log_pay",
        type: "POST",
        data: {
            uid: uid,
        },
        dataType: 'json',
        success: function(data) {
            console.log(data);
            var list;
            list = data.data.list;
            if (list) {
                list = data.data.list;
            }else{
                console.log(1);
            list =[
                {operator: "无", time: "无", extra_num: "无", money: "无", pay_type: "无", }
                ]
            }
            var tableIns = table.render({
                elem: '#newsList',
                url: "https://pay.imbatv.cn/api/user/get_log_pay",
                cellMinWidth: 95,
                page: true,
                height: "full-125",
                limit: 20,
                limits: [15, 30, 45, 60],
                id: "newsListTable",
                cols: [
                    [
                        { field: 'money', title: '金额', align: "center" },
                        { field: 'pay_type', title: '支付方式', align: 'center' },
                        { field: 'extra_num', title: '店长赠送', align: 'center', },
                         { field: 'time', title: '时间', align: 'center',templet: function(d) {
                            return createTime(d.time)
                            }
                        },
                        { field: 'operator', title: '操作人员', align: 'center' },  
            
                    ]
                ],
                done: function(res, curr, count) {
                    // 隐藏列
                    // $(".layui-table-box").find("[data-field='state']").css("display", "none");
                    // $(".layui-table-box").find("[data-field='uid']").css("display", "none");
                }

            });
        },
        error: function(err) {}
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