const ipcRenderer = require('electron').ipcRenderer;
layui.use(['form', 'layer', 'laydate', 'table', 'laytpl'], function() {
    var form = layui.form,
        layer = parent.layer === undefined ? layui.layer : top.layer,
        $ = layui.jquery,
        laydate = layui.laydate,
        laytpl = layui.laytpl,
        table = layui.table;
        san = 0;
        mid = "";
        show = 0;
        type= 2;
    // 获取userid
    function getQueryString(name) {
        var reg = new RegExp('(^|&)' + name + '=([^&]*)(&|$)', 'i');
        var r = window.location.search.substr(1).match(reg);
        if (r != null) {
            return unescape(r[2]);
        }
        return null;
    }
    var user_id = getQueryString("userid");

    // 获取所有信息
    function getAllCheckinInfo(mid) {
        var box, p1, p2, p3, p4;
        box = $(".classify ul li.cur").html(); // 包厢号
        p1 = $(".select1 .layui-this").html();
        p2 = $(".select2 .layui-this").html();
        p3 = $(".select3 .layui-this").html();
        p4 = $(".select4 .layui-this").html();
        
        ipcRenderer.send('checkin',1,mid,box,p1,p2,p3,p4);
    }

    // 获取第一层
    function con1(mold){
        $.ajax({
            url: "https://pay.imbatv.cn/api/checkin/single_info_front?user_id=" + user_id,
            type: "get",
            dataType: 'json',
            success: function(data) {
                var html ='';
                // 判断散客or包厢
                if (mold == 0) {
                  var data = data.data.machine_type;
                }else{
                  var data = data.data.box_type; 
                }
                for(var v in data){  
                  html += '<li data-type = "'+v+'" >' + data[v] + '</li>';
                }  
                $('.tab ul').html(html);
                $(".tab ul li:first(child)").addClass("cur").siblings().removeClass("cur");
                // 点击类型切换
                $(".tab ul li").click(function() {
                    $(this).addClass('cur').siblings().removeClass('cur');
                    var dataType = $(this).attr('data-type');
                    con2(dataType);
                });
            },
            error: function(err) {}
        });
    }
   // 获取第二层
   function con2(dataType){
        $.ajax({
            url: "https://pay.imbatv.cn/api/checkin/single_info_front?user_id=" + user_id,
            type: "get",
            dataType: 'json',
            success: function(data) {
                console.log(data);
                var html ='';
                var data =  data.data.box_list[dataType];
                // 点击类型切换的时候座位号
                var check = data[0];
                con3(check);
                for (var i = 0; i < data.length; i++) {
                      html += '<li>' + data[i] + '</li>';
                }      
                $('.classify ul').html(html);   
                $('.classify ul li:first(child)').addClass('cur').siblings().removeClass('cur');
                 // 点击房间名称切换
                $(".classify ul li").click(function() {
                    $(this).addClass('cur').siblings().removeClass('cur');
                    var machine = $(this).html();
                    con3(machine);
                });
            },
            error: function(err) {}
        });
    }
    // 获取第三层
   function con3(machine){
        $.ajax({
            url: "https://pay.imbatv.cn/api/checkin/single_info_front?user_id=" + user_id,
            type: "get",
            dataType: 'json',
            success: function(data) {
                var html ='';
                var data = data.data.machines[machine]; 
                for (var i = 0; i < data.length; i++) {
                      html += '<li mac="' + data[i].mac + '" ip="' + data[i].ip + '" machine_id="' + data[i].id + '">' + data[i].machine_name + '</li>';
                }      
                $('.classify_cn ul').html(html);
                $('.classify_cn ul li').click(function() {
                    mid = $(this).html();
                    $(this).addClass('cur').siblings().removeClass('cur');
                    getAllCheckinInfo(mid);
                });   
            },
            error: function(err) {}
        });
    }
  // 默认执行的方法
    con1(0);
    con2(1);
    con3("散座");
  // 点击散客切换
    $(".top ul li.san").click(function() {
        san = 0;
        $(this).addClass('cur').siblings().removeClass('cur');
        con1(san);
        con2(1);
        $('.pay').hide();
        show = 0;
        type = 2;
    });
    // 点击包厢切换
    $(".top ul li.box").click(function() {
        san = 1;
        $(this).addClass('cur').siblings().removeClass('cur');
        con1(san);
        con2(2);
        $('.pay').show();
        show = 1;
        type = 2;
    });
    // 外设
    $.ajax({
        url: "https://pay.imbatv.cn/api/checkin/single_info?user_id=" + user_id,
        type: "GET",
        dataType: 'json',
        success: function(data) {
            var html1 = "";
            var html2 = "";
            var html3 = "";
            var html4 = "";
            html1 += '<option value="">直接选择或搜索选择</option>'
            for (var i = 0; i < data.data.peripheral_list[1].length; i++) {
                if (data.data.peripheral_list[1][i].last_use) {
                    html1 += '<option selected="selected" value="' + (data.data.peripheral_list[1][i].id) + '">' + data.data.peripheral_list[1][i].desc + '</option>'
                } else {
                    html1 += '<option value="' + (data.data.peripheral_list[1][i].id) + '">' + data.data.peripheral_list[1][i].desc + '</option>'
                }

            }

            html2 += '<option value="">直接选择或搜索选择</option>'
            for (var i = 0; i < data.data.peripheral_list[2].length; i++) {
                if (data.data.peripheral_list[2][i].last_use) {
                    html2 += '<option selected="selected" value="' + (data.data.peripheral_list[2][i].id) + '">' + data.data.peripheral_list[2][i].desc + '</option>'
                } else {
                    html2 += '<option value="' + (data.data.peripheral_list[2][i].id) + '">' + data.data.peripheral_list[2][i].desc + '</option>'
                }
            }

            html3 += '<option value="">直接选择或搜索选择</option>'
            for (var i = 0; i < data.data.peripheral_list[3].length; i++) {
                if (data.data.peripheral_list[3][i].last_use) {
                    html3 += '<option selected="selected" value="' + (data.data.peripheral_list[3][i].id) + '">' + data.data.peripheral_list[3][i].desc + '</option>'
                } else {
                    html3 += '<option value="' + (data.data.peripheral_list[3][i].id) + '">' + data.data.peripheral_list[3][i].desc + '</option>'
                }
            }

            html4 += '<option value="">直接选择或搜索选择</option>'
            for (var i = 0; i < data.data.peripheral_list[4].length; i++) {
                if (data.data.peripheral_list[4][i].last_use) {
                    html4 += '<option selected="selected" value="' + (data.data.peripheral_list[4][i].id) + '">' + data.data.peripheral_list[4][i].desc + '</option>'
                } else {
                    html4 += '<option value="' + (data.data.peripheral_list[4][i].id) + '">' + data.data.peripheral_list[4][i].desc + '</option>'
                }
            }

            $(".sec1").html(html1);
            $(".sec2").html(html2);
            $(".sec3").html(html3);
            $(".sec4").html(html4);
            form.render('select');
            getAllCheckinInfo('000')
        },
        error: function(err) {
            console.log(err);
        }
    });
    // 获取付款方式
    form.on('radio', function(data) {
        if (data.value == 2) {
            type = 2;
        } else if (data.value == 3) {
            type = 3;
        }
    });
    // 点击确定
    $(".content1 .mpx_4 .layui-btn").click(function() {
        var box_id = $(".content1 .classify ul li.cur").html();
        var machine_id = $(".content1 .classify_cn ul li.cur").attr("machine_id");
        var san_or_box = $(".top ul li.cur").attr("san_or_box");
        // 获取外设
        var sec1_id = $(".content1 .select1 .layui-this").attr("lay-value");
        var sec2_id = $(".content1 .select2 .layui-this").attr("lay-value");
        var sec3_id = $(".content1 .select3 .layui-this").attr("lay-value");
        var sec4_id = $(".content1 .select4 .layui-this").attr("lay-value");
        var pjson = [{ "type": 1, "id": sec1_id }, { "type": 2, "id": sec2_id }, { "type": 3, "id": sec3_id }, { "type": 4, "id": sec4_id }];
        pjson = JSON.stringify(pjson);
        // 判断散客or包厢
        if (show == 0) {
            if (machine_id == undefined) {
                layer.msg("请选选择机器号", { time: 3000, icon: 5 });
            } else {
                $.ajax({
                    url: "https://pay.imbatv.cn/api/checkin/single?san_or_box=" + san_or_box,
                    type: "POST",
                    data: {
                        user_id: user_id,
                        machine_id: machine_id,
                        pjson: pjson
                    },
                    dataType: 'json',
                    success: function(data) {
                        if (data.code == 200) {
                            open_and_send_electron();
                            layer.msg(data.message, { time: 2000, icon: 6 }, function() {
                                window.location.href = '../../page/home/home.html';
                            });
                        } else {
                            layer.msg(data.message, { time: 2000, icon: 5 });
                        }

                    },
                    error: function(err) {
                        console.log(err);
                    }
                });
            }
        }else{
                // 包厢确定
                if (type == 3) {
                    var uid = $('.content1 .item3 .td1').attr('uid');
                    if (uid == undefined) {
                        layer.msg("请先进行会员查询", { time: 2000, icon: 5 });
                    } else {
                        // 获取包厢号
                        console.log(pjson);
                        $.ajax({
                            url: "https://pay.imbatv.cn/api/checkin/single?san_or_box=" + san_or_box,
                            type: "POST",
                            data: {
                                user_id: user_id,
                                box_id: box_id,
                                pjson: pjson,
                                whopay: uid,
                                pay_type: type,
                                machine_id: machine_id
                            },
                            dataType: 'json',
                            success: function(data) {
                                if (data.code == 200) {
                                    open_and_send_electron();
                                    layer.msg(data.message, { time: 2000, icon: 6 }, function() {
                                        window.location.href = '../../page/home/home.html';
                                    });
                                } else {
                                    layer.msg(data.message, { time: 2000, icon: 5 });
                                }

                            },
                            error: function(err) {
                                console.log(err);
                            }
                        });
                    }
                } else {
                    $.ajax({
                            url: "https://pay.imbatv.cn/api/checkin/single?san_or_box=" + san_or_box,
                            type: "POST",
                            data: {
                                user_id: user_id,
                                box_id: box_id,
                                pjson: pjson,
                                pay_type: type,
                                machine_id: machine_id
                            },
                            dataType: 'json',
                            success: function(data) {
                                if (data.code == 200) {
                                    open_and_send_electron();
                                    layer.msg(data.message, { time: 2000, icon: 6 }, function() {
                                        window.location.href = '../../page/home/home.html';
                                    });
                                } else {
                                    layer.msg(data.message, { time: 2000, icon: 5 });
                                }

                            },
                            error: function(err) {
                                console.log(err);
                            }
                        });
                    }
                }
    });

    

    $(".card_reading").on("click", function() {
        var val = $(this).siblings(".pay .layui-input-inline").children().val();
        // 判断是否为空
        if (!val) {
            layer.msg('请填写手机号或者会员号');
        } else {
            if (isPhoneNo(val)) {
                userid = '';
                phone = val;
            } else {
                userid = val;
                phone = '';
            }
            $.ajax({
                url: "https://pay.imbatv.cn/api/user",
                type: "POST",
                data: {
                    user_id: userid,
                    phone: phone
                },
                dataType: 'json',
                success: function(data) {
                    if (data.code == 200) {
                        console.log(data);
                        $(".td1").html('会员卡号:' + data.data.username);
                        $(".td1").attr('uid', data.data.uid);
                        $(".td2").html('姓名:' + data.data.name);
                    } else {
                        layer.msg(data.message);
                    }

                },
                error: function(err) {
                    console.log(err);
                }
            });
        }
    })

  
    // 选择外设监听
    form.on('select()', function(data) {
        getAllCheckinInfo(mid);
    })
    $(".qx").click(function() {
        ipcRenderer.send('checkin',0, 0, 0, 0, 0, 0, 0);   
        window.location.href = '../../page/home/home.html';
    });

    function open_and_send_electron(){

        var mac = $(".cn .classify_cn ul li.cur").attr("mac");
        var ip = $(".cn .classify_cn ul li.cur").attr("ip");
        console.log(mac);
        ipcRenderer.send('open-machine',ip,mac);  
        ipcRenderer.send('checkin',0, 0, 0, 0, 0, 0, 0);
    }
    // 取消
})
// 验证手机号
function isPhoneNo(phone) {
    var pattern = /^1[34578]\d{9}$/;
    return pattern.test(phone);
}