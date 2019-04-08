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
        url: 'https://pay.imbatv.cn/tool/peripheral_num',
        limit: 15,
        limits: [15, 30, 45, 60],
        page: true,
        //,…… //其他参数
        cols: [
            [
                { field: 'id', title: 'ID', align: 'center',width:50, },
                { field: 'desc', title: '名称', align: 'center',width:400,},
                { field: 'type', title: '类型', align: 'center'},
                { field: 'count', title: '剩余数', align: "center" },
                { field: 'total', title: '总数量', align: 'center' },
                { title: '操作', width: 270, templet: '#newsListBar', fixed: "right", align: "center" }
            ]
        ],
        done: function(res, curr, count) {
            // 隐藏列
            console.log(res);
            var layEvent = res.event,
                data = res.data;
        }
    });
    // 验证手机号
    function isPhoneNo(phone) {
        var pattern = /^1[34578]\d{9}$/;
        return pattern.test(phone);
    }




    //更改外设
    function modify(edit){
        var index = layui.layer.open({
            title : "更改外设",
            type : 2,
            content : "commondityAdd.html",
            success : function(layero, index){
                var body = layui.layer.getChildFrame('body', index);
                console.log(edit);
                if(edit){
                    body.find(".item1 input").val(edit.desc);
                    body.find(".item2 input").val(edit.type);
                    body.find(".item3 input").val(edit.count);
                    body.find(".item4 input").val(edit.total);
                    body.find(".item6 button.btn1").attr("lay-filter","demo2");
                    body.find(".item6 button.btn2").attr("data-id",edit.id);
                    form.render();
                }
                setTimeout(function(){
                    layui.layer.tips('点击此处返回商品列表', '.layui-layer-setwin .layui-layer-close', {
                        tips: 3
                    });
                },2000)
            }
        })
        layui.layer.full(index);
        //改变窗口大小时，重置弹窗的宽高，防止超出可视区域（如F12调出debug的操作）
        $(window).on("resize",function(){
            layui.layer.full(index);
        })
    }
    $(window).one("resize",function(){
        $(".commondityAdd_btn").click(function(){
            var index = layui.layer.open({
                title : "增加外设",
                type : 2,
                content : "commondityAdd.html",
                success : function(layero, index){
                    setTimeout(function(){
                        layui.layer.tips('返回', '.layui-layer-setwin .layui-layer-close', {
                            tips: 3
                        });
                    },2000)
                }
            })          
            layui.layer.full(index);
        })

        $(".classifyAdd_btn").click(function(){
            var index = layui.layer.open({
                title : "增加外设",
                type : 2,
                content : "classifyAdd.html",
                success : function(layero, index){
                    setTimeout(function(){
                        layui.layer.tips('返回', '.layui-layer-setwin .layui-layer-close', {
                            tips: 3
                        });
                    },2000)
                }
            })          
            layui.layer.full(index);
        })
    }).resize();

    //列表操作
    table.on('tool(newsList)', function(obj) {
        var layEvent = obj.event,
            data = obj.data;
        var list = data.detail;
        var order_id = obj.data.id;
        if (layEvent === 'modify') { //充值记录
            modify(data);
        } 
    });
})