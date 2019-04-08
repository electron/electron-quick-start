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
        url: 'https://pay.imbatv.cn/tool/machine',
        limit: 15,
        limits: [15, 30, 45, 60],
        page: true,
        //,…… //其他参数
        cols: [
            [
                { field: 'id', title: 'ID', align: 'center' },
                { field: 'machine_name', title: '机器号', align: 'center',},
                { field: 'ip', title: 'IP', align: 'center'},
                { field: 'type', title: '类型', align: "center" },
                { field: 'status', title: '硬件状态', align: "center" },
                { field: 'position', title: '位置', align: 'center' },
                { field: 'box_id', title: '房间名称', align: 'center' },
                { title: '操作', width: 270, templet: '#newsListBar', fixed: "right", align: "center" }
            ]
        ],
        done: function(res, curr, count) {
            // 隐藏列
            console.log(res);
            var layEvent = res.event,
                data = res.data;
           
            $(".layui-table-box").find("[data-field='state']").css("display", "none");
            // $(".layui-table-box").find("[data-field='id']").css("display", "none");
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




    //更改机器
    function modify(edit){
        var index = layui.layer.open({
            title : "更改机器",
            type : 2,
            content : "commondityAdd.html?m="+edit.type_id+"&n="+edit.status_id,
            success : function(layero, index){
                var body = layui.layer.getChildFrame('body', index);
                console.log(edit);
                if(edit){
                    body.find(".item1 input").val(edit.machine_name);
                    body.find(".item2 input").val(edit.ip);
                    body.find(".item5 input").val(edit.position);
                    body.find(".item3 input").val(edit.type);
                    body.find(".item4 input").val(edit.status);
                    body.find(".item6 input").val(edit.box_id);
                    body.find(".item7 button.btn1").attr("lay-filter","demo2");
                    body.find(".item7 button.btn2").attr("data-id",edit.id);
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
       
    }
    $(window).one("resize",function(){
        $(".commondityAdd_btn").click(function(){
            var index = layui.layer.open({
                title : "添加商品",
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
        if (layEvent === 'modify') { //修改
            modify(data);
        } 
    });
})