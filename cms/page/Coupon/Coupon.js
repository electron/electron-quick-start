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
        url: 'https://pay.imbatv.cn/tool/coupon',
        limit: 15,
        limits: [15, 30, 45, 60],
        page: true,
        //,…… //其他参数
        cols: [
            [
                { field: 'id', title: 'ID', align: 'center',width:50, },
                { field: 'name', title: '优惠劵名称', align: 'center',width:300},
                { field: 'show_name', title: '小程序名称', align: 'center',width:300},
                { field: 'num', title: '上网时长/饮料数量', align: 'center'},
                { field: 'validity', title: '有效期', align: "center" },
                { field: 'discount', title: '优惠劵折扣', align: 'center' },
                { field: 'state', title: '状态', align: 'center' ,
                     templet: function(d) {
                        if (d.state == 1) {
                            return '开启'; 
                        }else{
                            return '关闭';  
                        }
                       
                    }
                },
                { title: '操作', width: 270, templet: '#newsListBar', fixed: "right", align: "center" }
            ]
        ],
        done: function(res, curr, count) {
            // 隐藏列
            // console.log(res);
            var layEvent = res.event,
                data = res.data;
        }
    });
    // 验证手机号
    function isPhoneNo(phone) {
        var pattern = /^1[34578]\d{9}$/;
        return pattern.test(phone);
    }
    //修改优惠劵信息
    function modify(edit){
        var index = layui.layer.open({
            title : "修改优惠劵信息",
            type : 2,
            content : "commondityAdd.html",
            success : function(layero, index){
                var body = layui.layer.getChildFrame('body', index);
                if(edit){
                    console.log(edit.state);
                    if (edit.good_ids == 0) {
                       body.find(".item4").attr("good_ids",0); 
                    }else{
                        body.find(".item4").attr("good_ids",edit.good_ids); 
                    }
                    body.find(".item1 input").val(edit.name);
                    body.find(".item2 input").val(edit.show_name);
                    body.find(".item3").attr("type",edit.type);
                    body.find(".item5 input").val(edit.validity);
                    body.find(".item6 input").val(edit.num);
                    body.find(".item7 input").val(edit.discount);
                    body.find(".item8 input").val(edit.state);
                    body.find(".item9 button.btn1").attr("lay-filter","demo2");
                    body.find(".item9 button.btn2").attr("data-id",edit.id);
                   
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
        // $(window).on("resize",function(){
        //     layui.layer.full(index);
        // })
    }
    $(window).one("resize",function(){
        $(".commondityAdd_btn").click(function(){
            var index = layui.layer.open({
                title : "增加优惠劵",
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