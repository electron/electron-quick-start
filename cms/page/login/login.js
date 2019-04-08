layui.use(['form','layer','jquery'],function(){
    var form = layui.form,
        layer = parent.layer === undefined ? layui.layer : top.layer
        $ = layui.jquery;

     $("#login").click(function(){
        var username = document.getElementById("username").value;
        var password = document.getElementById("password").value;
         console.log(username);
         console.log(password);
        $.ajax({
            type: "POST",                  //提交方式
            dataType: "json",              //预期服务器返回的数据类型
            url: "https://pay.imbatv.cn/api/login",          //目标url
            data: {
                username: username,
                password: password
            }, //提交的数据
            //  xhrFields: {
            //     withCredentials: true
            // },
            success: function (result) {
                console.log(result);       //打印服务端返回的数据(调试用)
                console.log($('#form').serialize());       //打印服务端返回的数据(调试用)
                if (result.status == "fail") {
                    layer.alert(result.detail);
                }else{
                    alert("fuck");
                     window.location.href = "https://www.imbatv.cn/special/gww_test/imbaCMS/index.html";
                };
            },
            error : function(result) {
                alert("error异常！");
            }
        });
    })
  
     

    //表单输入效果
    $(".loginBody .input-item").click(function(e){
        e.stopPropagation();
        $(this).addClass("layui-input-focus").find(".layui-input").focus();
    })
    $(".loginBody .layui-form-item .layui-input").focus(function(){
        $(this).parent().addClass("layui-input-focus");
    })
    $(".loginBody .layui-form-item .layui-input").blur(function(){
        $(this).parent().removeClass("layui-input-focus");
        if($(this).val() != ''){
            $(this).parent().addClass("layui-input-active");
        }else{
            $(this).parent().removeClass("layui-input-active");
        }
    })
})
