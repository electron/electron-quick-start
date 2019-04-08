layui.use(['form', 'layer', 'laydate', 'table', 'laytpl'], function() {
    var form = layui.form,
        layer = parent.layer === undefined ? layui.layer : top.layer,
        $ = layui.jquery,
        laydate = layui.laydate,
        laytpl = layui.laytpl,
        table = layui.table;
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
    $.ajax({
        url: "https://pay.imbatv.cn/api/checkin/single_info?user_id=" + user_id,
        type: "get",
        dataType: 'json',
        success: function(data) {
            console.log(data);
            var html_1 = '';
            var html_2_1 = '';
            var html_2_2 = '';
            var html_2_3 = '';
            var html_2_4 = '';
            var html_2_5 = '';
            var html_2_6 = '';
            var html_2_7 = '';
            var html_2_8 = '';
            var html_3_1 = '';
            var html_3_2 = '';
            var html_3_3 = '';
            var html_3_4 = '';
            var html_3_5 = '';
            var html_3_6 = '';
            var html_3_7 = '';
            var html_3_8 = '';
            var html_3_9 = '';
            var html_3_10 = '';
            var html_3_11 = '';
            var html_3_12 = '';
            var html_3_13 = '';
            var html_3_14 = '';
            var html_3_15 = '';
            var html_3_16 = '';
            var html_3_17 = '';
            var html_3_18 = '';
            var html_3_19 = '';
            var html_3_20 = '';
            var html_3_21 = '';
            var html_3_22 = '';
            var html_4_1 = '';
            var html_4_2 = '';
            var html_4_3 = '';
            var html_5_1 = '';
            var html_5_2 = '';
            var html_6_1 = '';
            var html_7_1 = '';
            var html_8_1 = '';
            var html_9_1 = '';
            var html_10_1 = '';
            var html_11_1 = '';
            var html_12_1 = '';
            for (var i = 0; i < data.data.machines.length; i++) {
                if (data.data.machines[i].type == 1) {
                    html_1 += '<li machine_id="' + data.data.machines[i].id + '">' + data.data.machines[i].machine_name + '</li>';
                }
            }
            for (var i = 0; i < data.data.machines.length; i++) {
                if (data.data.machines[i].type == 2) {
                    if (data.data.machines[i].box_id == '5人包厢1') {
                        html_2_1 += '<li machine_id="' + data.data.machines[i].id + '">' + data.data.machines[i].machine_name + '</li>';
                    } else if (data.data.machines[i].box_id == '5人包厢2') {
                        html_2_2 += '<li machine_id="' + data.data.machines[i].id + '">' + data.data.machines[i].machine_name + '</li>';
                    } else if (data.data.machines[i].box_id == '5人包厢3') {
                        html_2_3 += '<li machine_id="' + data.data.machines[i].id + '">' + data.data.machines[i].machine_name + '</li>';
                    } else if (data.data.machines[i].box_id == '5人包厢4') {
                        html_2_4 += '<li machine_id="' + data.data.machines[i].id + '">' + data.data.machines[i].machine_name + '</li>';
                    } else if (data.data.machines[i].box_id == '5人包厢5') {
                        html_2_5 += '<li machine_id="' + data.data.machines[i].id + '">' + data.data.machines[i].machine_name + '</li>';
                    } else if (data.data.machines[i].box_id == '5人包厢6') {
                        html_2_6 += '<li machine_id="' + data.data.machines[i].id + '">' + data.data.machines[i].machine_name + '</li>';
                    } else if (data.data.machines[i].box_id == '5人包厢7') {
                        html_2_7 += '<li machine_id="' + data.data.machines[i].id + '">' + data.data.machines[i].machine_name + '</li>';
                    } else if (data.data.machines[i].box_id == '5人包厢8') {
                        html_2_8 += '<li machine_id="' + data.data.machines[i].id + '">' + data.data.machines[i].machine_name + '</li>';
                    }
                }
            }
            for (var i = 0; i < data.data.machines.length; i++) {
                if (data.data.machines[i].type == 3) {
                    if (data.data.machines[i].box_id == '5人包厢9') {
                        html_3_1 += '<li machine_id="' + data.data.machines[i].id + '">' + data.data.machines[i].machine_name + '</li>';
                    } else if (data.data.machines[i].box_id == '5人包厢10') {
                        html_3_2 += '<li machine_id="' + data.data.machines[i].id + '">' + data.data.machines[i].machine_name + '</li>';
                    } else if (data.data.machines[i].box_id == '5人包厢11') {
                        html_3_3 += '<li machine_id="' + data.data.machines[i].id + '">' + data.data.machines[i].machine_name + '</li>';
                    } else if (data.data.machines[i].box_id == '5人包厢12') {
                        html_3_4 += '<li machine_id="' + data.data.machines[i].id + '">' + data.data.machines[i].machine_name + '</li>';
                    } else if (data.data.machines[i].box_id == '5人包厢13') {
                        html_3_5 += '<li machine_id="' + data.data.machines[i].id + '">' + data.data.machines[i].machine_name + '</li>';
                    } else if (data.data.machines[i].box_id == '5人包厢14') {
                        html_3_6 += '<li machine_id="' + data.data.machines[i].id + '">' + data.data.machines[i].machine_name + '</li>';
                    } else if (data.data.machines[i].box_id == '5人包厢15') {
                        html_3_7 += '<li machine_id="' + data.data.machines[i].id + '">' + data.data.machines[i].machine_name + '</li>';
                    } else if (data.data.machines[i].box_id == '5人包厢16') {
                        html_3_8 += '<li machine_id="' + data.data.machines[i].id + '">' + data.data.machines[i].machine_name + '</li>';
                    } else if (data.data.machines[i].box_id == '5人包厢17') {
                        html_3_9 += '<li machine_id="' + data.data.machines[i].id + '">' + data.data.machines[i].machine_name + '</li>';
                    } else if (data.data.machines[i].box_id == '5人包厢18') {
                        html_3_10 += '<li machine_id="' + data.data.machines[i].id + '">' + data.data.machines[i].machine_name + '</li>';
                    } else if (data.data.machines[i].box_id == '5人包厢19') {
                        html_3_11 += '<li machine_id="' + data.data.machines[i].id + '">' + data.data.machines[i].machine_name + '</li>';
                    } else if (data.data.machines[i].box_id == '5人包厢20') {
                        html_3_12 += '<li machine_id="' + data.data.machines[i].id + '">' + data.data.machines[i].machine_name + '</li>';
                    } else if (data.data.machines[i].box_id == '5人包厢21') {
                        html_3_13 += '<li machine_id="' + data.data.machines[i].id + '">' + data.data.machines[i].machine_name + '</li>';
                    } else if (data.data.machines[i].box_id == '5人包厢22') {
                        html_3_14 += '<li machine_id="' + data.data.machines[i].id + '">' + data.data.machines[i].machine_name + '</li>';
                    } else if (data.data.machines[i].box_id == '5人包厢23') {
                        html_3_15 += '<li machine_id="' + data.data.machines[i].id + '">' + data.data.machines[i].machine_name + '</li>';
                    } else if (data.data.machines[i].box_id == '5人包厢24') {
                        html_3_16 += '<li machine_id="' + data.data.machines[i].id + '">' + data.data.machines[i].machine_name + '</li>';
                    } else if (data.data.machines[i].box_id == '5人包厢25') {
                        html_3_17 += '<li machine_id="' + data.data.machines[i].id + '">' + data.data.machines[i].machine_name + '</li>';
                    } else if (data.data.machines[i].box_id == '5人包厢26') {
                        html_3_18 += '<li machine_id="' + data.data.machines[i].id + '">' + data.data.machines[i].machine_name + '</li>';
                    } else if (data.data.machines[i].box_id == '5人包厢27') {
                        html_3_19 += '<li machine_id="' + data.data.machines[i].id + '">' + data.data.machines[i].machine_name + '</li>';
                    } else if (data.data.machines[i].box_id == '5人包厢28') {
                        html_3_20 += '<li machine_id="' + data.data.machines[i].id + '">' + data.data.machines[i].machine_name + '</li>';
                    } else if (data.data.machines[i].box_id == '5人包厢29') {
                        html_3_21 += '<li machine_id="' + data.data.machines[i].id + '">' + data.data.machines[i].machine_name + '</li>';
                    } else if (data.data.machines[i].box_id == '5人包厢30') {
                        html_3_22 += '<li machine_id="' + data.data.machines[i].id + '">' + data.data.machines[i].machine_name + '</li>';
                    }
                }
            }
            for (var i = 0; i < data.data.machines.length; i++) {
                if (data.data.machines[i].type == 4) {
                    if (data.data.machines[i].box_id == '6人包厢1') {
                        html_4_1 += '<li machine_id="' + data.data.machines[i].id + '">' + data.data.machines[i].machine_name + '</li>';
                    } else if (data.data.machines[i].box_id == '6人包厢2') {
                        html_4_2 += '<li machine_id="' + data.data.machines[i].id + '">' + data.data.machines[i].machine_name + '</li>';
                    } else if (data.data.machines[i].box_id == '6人包厢3') {
                        html_4_3 += '<li machine_id="' + data.data.machines[i].id + '">' + data.data.machines[i].machine_name + '</li>';
                    }
                }
            }
            for (var i = 0; i < data.data.machines.length; i++) {
                if (data.data.machines[i].type == 5) {
                    if (data.data.machines[i].box_id == '10人包厢1') {
                        html_5_1 += '<li machine_id="' + data.data.machines[i].id + '">' + data.data.machines[i].machine_name + '</li>';
                    } else if (data.data.machines[i].box_id == '10人包厢2') {
                        html_5_2 += '<li machine_id="' + data.data.machines[i].id + '">' + data.data.machines[i].machine_name + '</li>';
                    }
                }
            }
            for (var i = 0; i < data.data.machines.length; i++) {
                if (data.data.machines[i].type == 6) {
                    if (data.data.machines[i].box_id == '20人包厢') {
                        html_6_1 += '<li machine_id="' + data.data.machines[i].id + '">' + data.data.machines[i].machine_name + '</li>';
                    }
                }
            }
            for (var i = 0; i < data.data.box_list.length; i++) {
                if (data.data.box_list[i].type == 2) {

                    html_7_1 += '<li>' + data.data.box_list[i].box_id + '</li>';


                }
            }
            for (var i = 0; i < data.data.box_list.length; i++) {
                if (data.data.box_list[i].type == 3) {

                    html_8_1 += '<li>' + data.data.box_list[i].box_id + '</li>';


                }
            }
            for (var i = 0; i < data.data.box_list.length; i++) {
                if (data.data.box_list[i].type == 4) {
                    html_9_1 += '<li>' + data.data.box_list[i].box_id + '</li>';

                }
            }
            for (var i = 0; i < data.data.box_list.length; i++) {
                if (data.data.box_list[i].type == 5) {

                    html_10_1 += '<li>' + data.data.box_list[i].box_id + '</li>';


                }
            }
            for (var i = 0; i < data.data.box_list.length; i++) {
                if (data.data.box_list[i].type == 6) {

                    html_11_1 += '<li>' + data.data.box_list[i].box_id + '</li>';

                }
            }
            $('.content2 .cn2 ul').html(html_7_1);
            $('.content2 .cn3 ul').html(html_8_1);
            $('.content2 .cn4 ul').html(html_9_1);
            $('.content2 .cn5 ul').html(html_10_1);
            $('.content2 .cn6 ul').html(html_11_1);
            $('.content2 .cn2 ul li:first(child)').addClass("cur");
            $('.content2 .cn3 ul li:first(child)').addClass("cur");
            $('.content2 .cn4 ul li:first(child)').addClass("cur");
            $('.content2 .cn5 ul li:first(child)').addClass("cur");
            $('.content2 .cn6 ul li:first(child)').addClass("cur");
            $(".content2 .classify ul li").click(function() {
                $(this).addClass('cur').siblings().removeClass('cur').parent().parent().siblings().children().eq($(this).index()).show().siblings().hide();
                $(this).parent().parent().parent().siblings('.cn').children().children().children().removeClass('cur');
            });
            $('.cn1 .classify_cn ul').html(html_1);
            $('.cn2 .classify_cn ul.n1').html(html_2_1);
            $('.cn2 .classify_cn ul.n2').html(html_2_2);
            $('.cn2 .classify_cn ul.n3').html(html_2_3);
            $('.cn2 .classify_cn ul.n4').html(html_2_4);
            $('.cn2 .classify_cn ul.n5').html(html_2_5);
            $('.cn2 .classify_cn ul.n6').html(html_2_6);
            $('.cn2 .classify_cn ul.n7').html(html_2_7);
            $('.cn2 .classify_cn ul.n8').html(html_2_8);
            $('.cn3 .classify_cn ul.n1').html(html_3_1);
            $('.cn3 .classify_cn ul.n2').html(html_3_2);
            $('.cn3 .classify_cn ul.n3').html(html_3_3);
            $('.cn3 .classify_cn ul.n4').html(html_3_4);
            $('.cn3 .classify_cn ul.n5').html(html_3_5);
            $('.cn3 .classify_cn ul.n6').html(html_3_6);
            $('.cn3 .classify_cn ul.n7').html(html_3_7);
            $('.cn3 .classify_cn ul.n8').html(html_3_8);
            $('.cn3 .classify_cn ul.n9').html(html_3_9);
            $('.cn3 .classify_cn ul.n10').html(html_3_10);
            $('.cn3 .classify_cn ul.n11').html(html_3_11);
            $('.cn3 .classify_cn ul.n12').html(html_3_12);
            $('.cn3 .classify_cn ul.n13').html(html_3_13);
            $('.cn3 .classify_cn ul.n14').html(html_3_14);
            $('.cn3 .classify_cn ul.n15').html(html_3_15);
            $('.cn3 .classify_cn ul.n16').html(html_3_16);
            $('.cn3 .classify_cn ul.n17').html(html_3_17);
            $('.cn3 .classify_cn ul.n18').html(html_3_18);
            $('.cn3 .classify_cn ul.n19').html(html_3_19);
            $('.cn3 .classify_cn ul.n20').html(html_3_20);
            $('.cn3 .classify_cn ul.n21').html(html_3_21);
            $('.cn3 .classify_cn ul.n22').html(html_3_22);
            $('.cn4 .classify_cn ul.n1').html(html_4_1);
            $('.cn4 .classify_cn ul.n2').html(html_4_2);
            $('.cn4 .classify_cn ul.n3').html(html_4_3);
            $('.cn5 .classify_cn ul.n1').html(html_5_1);
            $('.cn5 .classify_cn ul.n2').html(html_5_2);
            $('.cn6 .classify_cn ul.n1').html(html_6_1);
            $(".cn .classify_cn ul li").click(function() {
                $(this).addClass('cur').siblings().removeClass('cur').parent().parent().parent().siblings().children('.classify_cn').children('').children('').removeClass('cur');
            });
        },
        error: function(err) {}
    });
    $(".top ul li").click(function() {
        $(this).addClass('cur').siblings().removeClass('cur').parent().parent().siblings('.content').children().eq($(this).index()).show().siblings().hide();
    });
    $(".classify ul li").click(function() {
        $(this).addClass('cur').siblings().removeClass('cur').parent().parent().siblings().children().eq($(this).index()).show().siblings().hide();
    });
    $(".tab ul li").click(function() {
        $(this).addClass('cur').siblings().removeClass('cur').parent().parent().siblings('.con').children().eq($(this).index()).show().siblings().hide();
    });


    var user_id = getQueryString("userid");
    // 外设
    $.ajax({
        url: "https://pay.imbatv.cn/api/checkin/single_info?user_id=" + user_id,
        type: "GET",
        dataType: 'json',
        success: function(data) {
            console.log(data);
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
        },
        error: function(err) {
            console.log(err);
        }
    });

    // 点击确定
    // 散客确定
    $(".content1 .mpx_4 .layui-btn").click(function() {
        // 获取机器号
        var machine_id = $(".content1 .classify_cn ul li.cur").attr("machine_id");
        var san_or_box = $(".top ul li.cur").attr("san_or_box");
        if (machine_id == undefined) {
            layer.msg("请选选择机器号", { time: 3000, icon: 5 });
        } else {
            // 获取外设
            var sec1_id = $(".content1 .select1 .layui-this").attr("lay-value");
            var sec2_id = $(".content1 .select2 .layui-this").attr("lay-value");
            var sec3_id = $(".content1 .select3 .layui-this").attr("lay-value");
            var sec4_id = $(".content1 .select4 .layui-this").attr("lay-value");
            var pjson = [{ "type": 1, "id": sec1_id }, { "type": 2, "id": sec2_id }, { "type": 3, "id": sec3_id }, { "type": 4, "id": sec4_id }];
            pjson = JSON.stringify(pjson);
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
                        layer.msg(data.message, { time: 2000, icon: 6 }, function() {
                            parent.location.reload();
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
    });

    // 获取付款方式
    var type = 2;
    form.on('radio', function(data) {
        if (data.value == 2) {
            type = 2;
        } else if (data.value == 3) {
            type = 3;
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

    // 包厢确定
    $(".content2 .mpx_4 .layui-btn").click(function() {
        var box_id = $(".content2 .classify ul li.cur").html();
        var san_or_box = $(".top ul li.cur").attr("san_or_box");
        // 获取外设
        var sec1_id = $(".content2 .select1 .layui-this").attr("lay-value");
        var sec2_id = $(".content2 .select2 .layui-this").attr("lay-value");
        var sec3_id = $(".content2 .select3 .layui-this").attr("lay-value");
        var sec4_id = $(".content2 .select4 .layui-this").attr("lay-value");
        var machine_id = $(".content2 .classify_cn ul li.cur").attr("machine_id");
        if (machine_id == undefined) {
            layer.msg("请选选择机器号", { time: 3000, icon: 5 });
        } else {
           console.log(machine_id);
            var pjson = [{ "type": 1, "id": sec1_id }, { "type": 2, "id": sec2_id }, { "type": 3, "id": sec3_id }, { "type": 4, "id": sec4_id }];
        pjson = JSON.stringify(pjson);
        if (type == 3) {
            var uid = $('.content2 .item3 .td1').attr('uid');
            if (uid == undefined) {
                layer.msg("请先进行会员查询");
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
                            layer.msg(data.message, { time: 2000, icon: 6 }, function() {
                                parent.location.reload();
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
                        layer.msg(data.message, { time: 2000, icon: 6 }, function() {
                            parent.location.reload();
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
})
// 验证手机号
function isPhoneNo(phone) {
    var pattern = /^1[34578]\d{9}$/;
    return pattern.test(phone);
}