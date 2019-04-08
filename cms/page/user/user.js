layui.use(['form','layer','laydate','table','laytpl'],function(){
    var form = layui.form,
        layer = parent.layer === undefined ? layui.layer : top.layer,
        $ = layui.jquery,
        laydate = layui.laydate,
        laytpl = layui.laytpl,
        table = layui.table;

    //添加验证规则
    form.verify({
        newPwd : function(value, item){
            if(value.length < 6){
                return "密码长度不能小于6位";
            }
        },
        confirmPwd : function(value, item){
            if(!new RegExp($("#oldPwd1").val()).test(value)){
                return "两次输入密码不一致，请重新输入！";
            }
        }
    })
    

    //控制表格编辑时文本的位置【跟随渲染时的位置】
    $("body").on("click",".layui-table-body.layui-table-main tbody tr td",function(){
        $(this).find(".layui-table-edit").addClass("layui-"+$(this).attr("align"));
    });
    // 获取登录用户信息
     $(".changePwd").click(function(){
        var oldPwd = document.getElementById("oldPwd").value;
        var newPwd = document.getElementById("newPwd").value;
         console.log(oldPwd);
         console.log(oldPwd);
        $.ajax({
            type: "POST",                  //提交方式
            dataType: "json",              //预期服务器返回的数据类型
            url: "https://pay.imbatv.cn/api/admin/change_password",          //目标url
            data: {
                old_password: oldPwd,
                new_password: newPwd
            }, //提交的数据
            //  xhrFields: {
            //     withCredentials: true
            // },
            success: function (result) {
                console.log(result);
                layer.alert(result.message);       //打印服务端返回的数据(调试用)
            },
            error : function(result) {
                alert("异常！");
                alert(result);
            }
        });
    })
})