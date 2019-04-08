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
        url: 'https://pay.imbatv.cn/tool/good_type',
        // limit: 15,
        // limits: [15, 30, 45, 60],
        page: false,
        //,…… //其他参数
        cols: [
            [
                { field: 'id', title: 'ID', align: 'center' },
                { field: 'name', title: '品种', align: 'center',},
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




    //修改商品分类名称
    function modify(edit){
        var index = layui.layer.open({
            title : "修改商品分类名称",
            type : 2,
            content : "classifyAdd.html",
            success : function(layero, index){
                var body = layui.layer.getChildFrame('body', index);
                console.log(edit);
                if(edit){
                    body.find(".item1 input").val(edit.name);
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
    // $(".modify").click(function(){
    //     modify();
    // })
    $(window).one("resize",function(){
        $(".commondityAdd_btn").click(function(){
            var index = layui.layer.open({
                title : "增加商品分类",
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

        $(".classifyAdd_btn").click(function(){
            var index = layui.layer.open({
                title : "增加商品分类",
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
        if (layEvent === 'modify') {
            modify(data);
        } 
    });
})