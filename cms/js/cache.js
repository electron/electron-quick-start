var cacheStr = window.sessionStorage.getItem("cache"),
    oneLoginStr = window.sessionStorage.getItem("oneLogin");
layui.use(['form','jquery',"layer"],function() {
    var form = layui.form,
        $ = layui.jquery,
        layer = parent.layer === undefined ? layui.layer : top.layer;

    //判断是否web端打开
    // if(!/http(s*):\/\//.test(location.href)){
    //     layer.alert("请先将项目部署到 localhost 下再进行访问【建议通过tomcat、webstorm、hb等方式运行，不建议通过iis方式运行】，否则部分数据将无法显示");
    // }else{    //判断是否处于锁屏状态【如果关闭以后则未关闭浏览器之前不再显示】
    //     if(window.sessionStorage.getItem("lockcms") != "true" && window.sessionStorage.getItem("showNotice") != "true"){
    //         showNotice();
    //     }
    // }

    //判断是否设置过头像，如果设置过则修改顶部、左侧和个人资料中的头像，否则使用默认头像
    if(window.sessionStorage.getItem('userFace') &&  $(".userAvatar").length > 0){
        $("#userFace").attr("src",window.sessionStorage.getItem('userFace'));
        $(".userAvatar").attr("src",$(".userAvatar").attr("src").split("images/")[0] + "images/" + window.sessionStorage.getItem('userFace').split("images/")[1]);
    }else{
        $("#userFace").attr("src","../../images/face.jpg");
    }


    function tipsShow(){
        window.sessionStorage.setItem("showNotice","true");
        if($(window).width() > 432){  //如果页面宽度不足以显示顶部“系统公告”按钮，则不提示
            layer.tips('系统公告躲在了这里', '#userInfo', {
                tips: 3,
                time : 1000
            });
        }
    }
    //锁屏
    function lockPage(){
        layer.open({
            title : false,
            type : 1,
            content : '<div class="admin-header-lock" id="lock-box">'+
                            '<div class="admin-header-lock-img"><img src="images/face.jpg" class="userAvatar"/></div>'+
                            '<div class="admin-header-lock-name" id="lockUserName">桂维维</div>'+
                            '<div class="input_btn">'+
                                '<input type="password" class="admin-header-lock-input layui-input" autocomplete="off" placeholder="请输入密码解锁.." name="lockPwd" id="lockPwd" />'+
                                '<button class="layui-btn" id="unlock">解锁</button>'+
                            '</div>'+
                            '<p>请输入“123456”，否则不会解锁成功哦！！！</p>'+
                        '</div>',
            closeBtn : 0,
            shade : 0.9,
            success : function(){
                //判断是否设置过头像，如果设置过则修改顶部、左侧和个人资料中的头像，否则使用默认头像
                if(window.sessionStorage.getItem('userFace') &&  $(".userAvatar").length > 0){
                    $(".userAvatar").attr("src",$(".userAvatar").attr("src").split("images/")[0] + "images/" + window.sessionStorage.getItem('userFace').split("images/")[1]);
                }
            }
        })
        $(".admin-header-lock-input").focus();
    }
    $(".lockcms").on("click",function(){
        window.sessionStorage.setItem("lockcms",true);
        lockPage();
    })
    // 判断是否显示锁屏
    if(window.sessionStorage.getItem("lockcms") == "true"){
        lockPage();
    }
    // 解锁
    $("body").on("click","#unlock",function(){
        if($(this).siblings(".admin-header-lock-input").val() == ''){
            layer.msg("请输入解锁密码！");
            $(this).siblings(".admin-header-lock-input").focus();
        }else{
            if($(this).siblings(".admin-header-lock-input").val() == "123456"){
                window.sessionStorage.setItem("lockcms",false);
                $(this).siblings(".admin-header-lock-input").val('');
                layer.closeAll("page");
            }else{
                layer.msg("密码错误，请重新输入！");
                $(this).siblings(".admin-header-lock-input").val('').focus();
            }
        }
    });
    $(document).on('keydown', function(event) {
        var event = event || window.event;
        if(event.keyCode == 13) {
            $("#unlock").click();
        }
    });

    //退出
    $(".signOut").click(function(){
        window.sessionStorage.removeItem("menu");
        menu = [];
        window.sessionStorage.removeItem("curmenu");
    })

    //功能设定
    $(".functionSetting").click(function(){
        layer.open({
            title: "功能设定",
            area: ["380px", "280px"],
            type: "1",
            content :  '<div class="functionSrtting_box">'+
                            '<form class="layui-form">'+
                                '<div class="layui-form-item">'+
                                    '<label class="layui-form-label">开启Tab缓存</label>'+
                                    '<div class="layui-input-block">'+
                                        '<input type="checkbox" name="cache" lay-skin="switch" lay-text="开|关">'+
                                        '<div class="layui-word-aux">开启后刷新页面不关闭打开的Tab页</div>'+
                                    '</div>'+
                                '</div>'+
                                '<div class="layui-form-item">'+
                                    '<label class="layui-form-label">Tab切换刷新</label>'+
                                    '<div class="layui-input-block">'+
                                        '<input type="checkbox" name="changeRefresh" lay-skin="switch" lay-text="开|关">'+
                                        '<div class="layui-word-aux">开启后切换窗口刷新当前页面</div>'+
                                    '</div>'+
                                '</div>'+
                                '<div class="layui-form-item">'+
                                    '<label class="layui-form-label">单一登陆</label>'+
                                    '<div class="layui-input-block">'+
                                        '<input type="checkbox" name="oneLogin" lay-filter="multipleLogin" lay-skin="switch" lay-text="是|否">'+
                                        '<div class="layui-word-aux">开启后不可同时多个地方登录</div>'+
                                    '</div>'+
                                '</div>'+
                                '<div class="layui-form-item skinBtn">'+
                                    '<a href="javascript:;" class="layui-btn layui-btn-sm layui-btn-normal" lay-submit="" lay-filter="settingSuccess">设定完成</a>'+
                                    '<a href="javascript:;" class="layui-btn layui-btn-sm layui-btn-primary" lay-submit="" lay-filter="noSetting">朕再想想</a>'+
                                '</div>'+
                            '</form>'+
                        '</div>',
            success : function(index, layero){
                //如果之前设置过，则设置它的值
                $(".functionSrtting_box input[name=cache]").prop("checked",cacheStr=="true" ? true : false);
                $(".functionSrtting_box input[name=changeRefresh]").prop("checked",changeRefreshStr=="true" ? true : false);
                $(".functionSrtting_box input[name=oneLogin]").prop("checked",oneLoginStr=="true" ? true : false);
                //设定
                form.on("submit(settingSuccess)",function(data){
                    window.sessionStorage.setItem("cache",data.field.cache=="on" ? "true" : "false");
                    window.sessionStorage.setItem("changeRefresh",data.field.changeRefresh=="on" ? "true" : "false");
                    window.sessionStorage.setItem("oneLogin",data.field.oneLogin=="on" ? "true" : "false");
                    window.sessionStorage.removeItem("menu");
                    window.sessionStorage.removeItem("curmenu");
                    location.reload();
                    return false;
                });
                //取消设定
                form.on("submit(noSetting)",function(){
                    layer.closeAll("page");
                });
                //单一登陆提示
                form.on('switch(multipleLogin)', function(data){
                    layer.tips('温馨提示：此功能需要开发配合，所以没有功能演示，敬请谅解', data.othis,{tips: 1})
                });
                form.render();  //表单渲染
            }
        })
    })

    //判断是否修改过系统基本设置，去显示底部版权信息
    if(window.sessionStorage.getItem("systemParameter")){
        systemParameter = JSON.parse(window.sessionStorage.getItem("systemParameter"));
        $(".footer p span").text(systemParameter.powerby);
    }

    //更换皮肤
    function skins(){
        var skin = window.sessionStorage.getItem("skin");
        if(skin){  //如果更换过皮肤
            if(window.sessionStorage.getItem("skinValue") != "自定义"){
                $("body").addClass(window.sessionStorage.getItem("skin"));
            }else{
                $(".layui-layout-admin .layui-header").css("background-color",skin.split(',')[0]);
                $(".layui-bg-black").css("background-color",skin.split(',')[1]);
                $(".hideMenu").css("background-color",skin.split(',')[2]);
            }
        }
    }
    skins();
    $(".changeSkin").click(function(){
        layer.open({
            title : "更换皮肤",
            area : ["310px","280px"],
            type : "1",
            content : '<div class="skins_box">'+
                            '<form class="layui-form">'+
                                '<div class="layui-form-item">'+
                                    '<input type="radio" name="skin" value="默认" title="默认" lay-filter="default" checked="">'+
                                    '<input type="radio" name="skin" value="橙色" title="橙色" lay-filter="orange">'+
                                    '<input type="radio" name="skin" value="蓝色" title="蓝色" lay-filter="blue">'+
                                    '<input type="radio" name="skin" value="自定义" title="自定义" lay-filter="custom">'+
                                    '<div class="skinCustom">'+
                                        '<input type="text" class="layui-input topColor" name="topSkin" placeholder="顶部颜色" />'+
                                        '<input type="text" class="layui-input leftColor" name="leftSkin" placeholder="左侧颜色" />'+
                                        '<input type="text" class="layui-input menuColor" name="btnSkin" placeholder="顶部菜单按钮" />'+
                                    '</div>'+
                                '</div>'+
                                '<div class="layui-form-item skinBtn">'+
                                    '<a href="javascript:;" class="layui-btn layui-btn-sm layui-btn-normal" lay-submit="" lay-filter="changeSkin">确定更换</a>'+
                                    '<a href="javascript:;" class="layui-btn layui-btn-sm layui-btn-primary" lay-submit="" lay-filter="noChangeSkin">朕再想想</a>'+
                                '</div>'+
                            '</form>'+
                        '</div>',
            success : function(index, layero){
                var skin = window.sessionStorage.getItem("skin");
                if(window.sessionStorage.getItem("skinValue")){
                    $(".skins_box input[value="+window.sessionStorage.getItem("skinValue")+"]").attr("checked","checked");
                };
                if($(".skins_box input[value=自定义]").attr("checked")){
                    $(".skinCustom").css("visibility","inherit");
                    $(".topColor").val(skin.split(',')[0]);
                    $(".leftColor").val(skin.split(',')[1]);
                    $(".menuColor").val(skin.split(',')[2]);
                };
                form.render();
                $(".skins_box").removeClass("layui-hide");
                $(".skins_box .layui-form-radio").on("click",function(){
                    var skinColor;
                    if($(this).find("div").text() == "橙色"){
                        skinColor = "orange";
                    }else if($(this).find("div").text() == "蓝色"){
                        skinColor = "blue";
                    }else if($(this).find("div").text() == "默认"){
                        skinColor = "";
                    }
                    if($(this).find("div").text() != "自定义"){
                        $(".topColor,.leftColor,.menuColor").val('');
                        $("body").removeAttr("class").addClass("main_body "+skinColor+"");
                        $(".skinCustom").removeAttr("style");
                        $(".layui-bg-black,.hideMenu,.layui-layout-admin .layui-header").removeAttr("style");
                    }else{
                        $(".skinCustom").css("visibility","inherit");
                    }
                })
                var skinStr,skinColor;
                $(".topColor").blur(function(){
                    $(".layui-layout-admin .layui-header").css("background-color",$(this).val()+" !important");
                })
                $(".leftColor").blur(function(){
                    $(".layui-bg-black").css("background-color",$(this).val()+" !important");
                })
                $(".menuColor").blur(function(){
                    $(".hideMenu").css("background-color",$(this).val()+" !important");
                })

                form.on("submit(changeSkin)",function(data){
                    if(data.field.skin != "自定义"){
                        if(data.field.skin == "橙色"){
                            skinColor = "orange";
                        }else if(data.field.skin == "蓝色"){
                            skinColor = "blue";
                        }else if(data.field.skin == "默认"){
                            skinColor = "";
                        }
                        window.sessionStorage.setItem("skin",skinColor);
                    }else{
                        skinStr = $(".topColor").val()+','+$(".leftColor").val()+','+$(".menuColor").val();
                        window.sessionStorage.setItem("skin",skinStr);
                        $("body").removeAttr("class").addClass("main_body");
                    }
                    window.sessionStorage.setItem("skinValue",data.field.skin);
                    layer.closeAll("page");
                });
                form.on("submit(noChangeSkin)",function(){
                    $("body").removeAttr("class").addClass("main_body "+window.sessionStorage.getItem("skin")+"");
                    $(".layui-bg-black,.hideMenu,.layui-layout-admin .layui-header").removeAttr("style");
                    skins();
                    layer.closeAll("page");
                });
            },
            cancel : function(){
                $("body").removeAttr("class").addClass("main_body "+window.sessionStorage.getItem("skin")+"");
                $(".layui-bg-black,.hideMenu,.layui-layout-admin .layui-header").removeAttr("style");
                skins();
            }
        })
    })

})