layui.use(['form', 'layer', 'laydate', 'table', 'laytpl', 'element'], function() {
    var form = layui.form,
        layer = parent.layer === undefined ? layui.layer : top.layer,
        $ = layui.jquery,
        laydate = layui.laydate,
        laytpl = layui.laytpl,
        table = layui.table;
    var arr1 = [];
    var arr2 = [];
    var arr3 = [];
    var arr4 = [];
    var num = "";
    // var max;
    var discount = "";
    var user_coupon_id = "";
    var AllMoney = 0;
    var user_coupon_id = "";
    element = layui.element;
    $.ajax({
        url: "https://pay.imbatv.cn/api/goods",
        type: "GET",
        dataType: 'json',
        success: function(data) {
            // console.log(data);
            var data = data.data;
            var html = '';
            var html_spc = '';
            var html0 = '';
            var html1 = '';
            var html2 = '';
            var num = data.type.length;
            for (var i = 0; i < data.type.length; i++) {
                html += '<li data-index=' + (i + 1) + '>' + data.type[i].name + '</li>';
                html_spc += '<div class="layui-tab-item layui-tab-item' + (i + 1) + '"></div>'
            }
            for (var k1 = 0; k1 < data.good_list[1].length; k1++) {
                html1 += '<button class="layui-btn layui-btn-primary" data-index=' + k1 + '>' + data.good_list[1][k1].name + '</button>';
            }
            $(".cp_fl").html(html);
            $(".tree").html(html_spc);
            $(".layui-tab-item1").html(html1);
            $(".cp_fl li:first").addClass("layui-this");
            $(".layui-tab-item:first").addClass("layui-show");
            $(".cp_fl li").click(function() {
                var sequence = parseInt($(this).attr("data-index"));
                var sequence_num = sequence + 1;
                var list = data.good_list[sequence];
                var html_cc = "";
                for (var k1 = 0; k1 < list.length; k1++) {
                    html_cc += '<button class="layui-btn layui-btn-primary" data-index=' + k1 + '>' + list[k1].name + '</button>';
                }
                $(".layui-tab-item" + sequence + "").html(html_cc);
                $(".layui-tab-content button").click(function() {
                    var sequence = parseInt($('.layui-this').attr("data-index"));
                    var index = $(this).attr("data-index");
                    onNodeClick(data.good_list[sequence], index);
                })
            })
            $(".layui-tab-content button").click(function() {
                var sequence = parseInt($('.layui-this').attr("data-index"));
                var index = $(this).attr("data-index");
                onNodeClick(data.good_list[sequence], index);
            })
        },
        error: function(err) {
            console.log(err);
        }
    });
    // 结算
    $("#settlement").click(function() {
        // 判断是否是会员
        var username = $(".td1").html();
        var uid = $(".td1").attr('uid');
        var number = parseInt($(".totalQuantity").html());
        var totalMoney = $('.totalMoney').html();
        // 判断商品列表是否为空
        if (number == 0) {
            layer.alert("请选择商品!!!");
        } else {
            var tabLen = document.getElementById("tableid");
            var jsonT = "[";
            for (var i = 1; i < tabLen.rows.length; i++) {
                var quantity = tabLen.rows[i].cells[3].innerHTML.replace(/[^0-9]/ig, "");
                quantity = quantity.substring(1);

                jsonT += '{"id":' + tabLen.rows[i].cells[0].innerHTML + ',"name":"' + tabLen.rows[i].cells[1].innerHTML + '","price":' + tabLen.rows[i].cells[2].innerHTML + ',"quantity":' + quantity + ',"type":' + tabLen.rows[i].cells[4].innerHTML + '},'
            }
            jsonT = jsonT.substr(0, jsonT.length - 1);
            jsonT += "]";
            console.log(jsonT);
            $.ajax({
                url: "https://pay.imbatv.cn/api/goods/calculate_discount",
                type: "POST",
                data: {
                    user_id: uid,
                    cartList: jsonT,
                    user_coupon_id: user_coupon_id
                },
                dataType: 'json',
                success: function(data) {
                    if (data.code == 200) {
                        console.log(data);
                        $(".mask_box").show();
                        $(".bot").css("padding-top", "30px");
                        $(".box").css("height", "348px");
                        $('.box_block1 .block_right input').val(data.data.total_money + "元");
                        $('.box_block2 .block_right input').val(data.data.discount_money + "元");
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

    $(".bot input:nth-child(1)").click(function() {
        var tabLen = document.getElementById("tableid");
        var jsonT = "[";
        for (var i = 1; i < tabLen.rows.length; i++) {
            var quantity = tabLen.rows[i].cells[3].innerHTML.replace(/[^0-9]/ig, "");
            quantity = quantity.substring(1);
            jsonT += '{"id":' + tabLen.rows[i].cells[0].innerHTML + ',"name":"' + tabLen.rows[i].cells[1].innerHTML + '","price":' + tabLen.rows[i].cells[2].innerHTML + ',"quantity":' + quantity + ',"type":' + tabLen.rows[i].cells[4].innerHTML + '},'
        }
        jsonT = jsonT.substr(0, jsonT.length - 1);
        jsonT += "]";
        // console.log(jsonT);
        var totalMoney = $('.box_block1 input').attr("data-totalMoney");
        var payment = 0;
        var list = $('.box_block3 input:radio:checked').val();
        totalMoney = $('.totalMoney').html();
        var user_id = '';
        payment = $('.box_block3 input:radio:checked').attr('data-type');
        if (list == null) {
            layer.alert("请选中支付方式!");
            return false;
        } else {
            $.ajax({
                url: "https://pay.imbatv.cn/api/goods/buy",
                type: "POST",
                data: {
                    user_id: user_id,
                    total: AllMoney,
                    cartList: jsonT,
                    payment: payment,
                    user_coupon_id: user_coupon_id
                },
                dataType: 'json',
                success: function(data) {
                    if (data.code == 200) {
                        // console.log(data);
                        layer.msg(data.message, { time: 2000 }, function() {
                            //回调
                            window.location.reload();
                        })
                    } else {
                        layer.msg(data.message);
                    }

                },
                error: function(err) {
                    console.log(err);
                }
            });
        }
        // }
        // console.log(payment);

        // 判断支付方式是否选择

    })


    $(".bot input:nth-child(2)").click(function() {
        $(".mask_box").hide();
        $('.box_block2 .block_right input').val(0);
    })

    $(".card_reading").on("click", function() {
        var val = $(this).siblings(".layui-input-inline").children().val();
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
            // 读取会员卡信息
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
                        // console.log(data);
                        $(".td1").html(data.data.username);
                        $(".td1").attr('uid', data.data.uid);
                        $(".td2").html(data.data.name);
                        $(".td3").html(data.data.level);
                        $(".td4").html(data.data.balance);

                        // 获取会员可用优惠劵
                        $.ajax({
                            type: "GET",
                            catch: true,
                            dataType: "jsonp",
                            url: "https://pay.imbatv.cn/api/coupon/user_coupon_list_by_uid?user_id=" + data.data.uid + "&type=2",
                            error: function(request) {
                                console.log(request);
                            },
                            success: function(res) {
                                console.log(res);
                                var html = '';
                                var data = res.data;
                                // // 判断优惠劵类型
                                var datatype = $(".item4").attr("type");
                                html = '<option value=""></option>';
                                for (var i = 0; i < data.length; i++) {
                                    html += "<option user_coupon_id=" + data[i].user_coupon_id + " discount=" + data[i].discount + " num=" + data[i].num + " title=" + data[i].good_ids + " value=" + data[i].user_coupon_id + ">" + data[i].name + "</option>";
                                };
                                $(".item1 .layui-input-block").html(data.name);
                                $(".item2 .layui-input-block").html(data.balance);
                                $(".item3 .layui-input-block").html(data.machine_name);
                                $(".cc").html(html);
                                form.render();
                                // 使用优惠劵
                                form.on("select", function(data) {
                                    var tabLen = document.getElementById("tableid");
                                    // 获取购物车里商品列表
                                    var jsonT = "[";
                                    for (var i = 1; i < tabLen.rows.length; i++) {
                                        var quantity = tabLen.rows[i].cells[3].innerHTML.replace(/[^0-9]/ig, "");
                                        quantity = quantity.substring(1);
                                        jsonT += '{"id":' + tabLen.rows[i].cells[0].innerHTML + ',"name":"' + tabLen.rows[i].cells[1].innerHTML + '","price":' + tabLen.rows[i].cells[2].innerHTML + ',"quantity":' + quantity + ',"type":' + tabLen.rows[i].cells[4].innerHTML + '},'
                                    }
                                    jsonT = jsonT.substr(0, jsonT.length - 1);
                                    jsonT += "]";
                                    // 购物车列表
                                    arr1 = JSON.parse(jsonT);
                                    // 优惠劵可以使用商品id
                                    arr2 = data.elem[data.elem.selectedIndex].title.split(',');
                                    // 优惠劵可以使用的数量
                                    num = data.elem[data.elem.selectedIndex].getAttribute("num");
                                    // 优惠劵可以使用的折扣
                                    discount = data.elem[data.elem.selectedIndex].getAttribute("discount");
                                    user_coupon_id = data.elem[data.elem.selectedIndex].getAttribute("user_coupon_id");
                                });
                            },
                        });
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
})

var totalQuantity = 0; //总数量
var totalMoney = 0; //总金额
var totalIntegral = 0; //总积分
function onNodeClick(data, index) {
    //获取选中节点的值
    var flag = false;
    // var tree=mini.get("tree1");
    node = data[index];
    if (!node.end) {
        // alert(1);
        /*树结构选中商品，table列表变化 - 开始*/
        totalQuantity++;
        $('.totalQuantity').html(totalQuantity);

        this_price = node.price; //获取单价
        this_price = parseFloat(this_price);
        totalMoney += this_price;
        $('.totalMoney').html(totalMoney.toFixed(2));

        this_integral = node.integral; //获取积分  
        this_integral = parseFloat(this_integral);
        totalIntegral += this_integral;
        // $('.totalIntegral').html(totalIntegral.toFixed(0));
        // $('.totalIntegral').html(totalIntegral.toFixed(0));
        /*树结构选中商品，table列表变化 - 结束*/

        if ($("#myTbody tr").length <= 0) {
            var addtr = '<tr class="mytr">';
            addtr += '<td>' + node.id + '</td>';

            addtr += '<td>' + node.name + '</td>';
            addtr += '<td class="kbj danjia">' + node.price + '</td>';
            addtr += '<td class="numberTd"><div class="jiajian"><span class="jian" onclick="num_sub(this)">-</span><input type="text" value="1" data-num="1" class="num"><span class="jia" onclick="num_add(this)">+</span></div></td>';
            addtr += '<td>' + node.type + '</td>';
            addtr += '<td><button class="delete_btn">删除</button></td>';
            addtr += '</tr>';
            $("#myTbody").append(addtr);
            return;
        } else {
            $("#myTbody tr").each(function() {
                //找到商品的名称与上面获取到的商品名称进行对比
                if ($(this).children("td:eq(0)").html() == node.id) {
                    //找到此商品的数量
                    var count = parseInt($(this).children("td:eq(3)").find("input").val());
                    count++;
                    $(this).children("td:eq(3)").find("input").val(count); //对商品的数量进行重新赋值
                    $(this).children("td:eq(3)").find("input").attr("data-num", count); //对商品的数量进行重新赋值
                    flag = true;
                    return false;
                } else {
                    flag = false;
                }
            })
        }
        //如果为默认值也就是说里面没有此商品，所以添加此商品。
        if (flag == false) {
            var addtr = '<tr class="mytr">';
            addtr += '<td>' + node.id + '</td>';

            addtr += '<td>' + node.name + '</td>';
            addtr += '<td class="danjia">' + node.price + '</td>';
            addtr += '<td><div class="jiajian"><span class="jian" onclick="num_sub(this)">-</span><input type="text" value="1" data-num="1" class="num"><span class="jia" onclick="num_add(this)">+</span></div></td>';
            addtr += '<td>' + node.type + '</td>';
            // addtr += '<td class="remarks"></td>';
            addtr += '<td><button class="delete_btn">删除</button></td>';
            addtr += '</tr>';
            $("#myTbody").append(addtr);
        }
    }
}
/*miniui - tree 插件 - 结束*/
function HtmlTableToJson(jsonT) {
    var tabLen = document.getElementById("tableid");
    var jsonT = "[";
    for (var i = 1; i < tabLen.rows.length; i++) {
        var quantity = tabLen.rows[i].cells[3].innerHTML.replace(/[^0-9]/ig, "");
        quantity = quantity.substring(1);

        jsonT += '{"id":' + tabLen.rows[i].cells[0].innerHTML + ',"name":"' + tabLen.rows[i].cells[1].innerHTML + '","price":' + tabLen.rows[i].cells[2].innerHTML + ',"quantity":' + quantity + '},'
    }
    jsonT = jsonT.substr(0, jsonT.length - 1);
    jsonT += "]";
    // console.log(jsonT);
};


// 支付方式
$.ajax({
    url: "https://pay.imbatv.cn/api/config",
    type: "GET",
    dataType: 'json',
    success: function(data) {
        if (data.code == 200) {
            var html = "";
            for (var i = 0; i < data.data.pay_type.length; i++) {
                html += '<div class="block_left">';
                html += '<input type="radio" name="payment" data-type="' + data.data.pay_type[i].id + '" />';
                html += '<label for="use_coupon" data-type="' + data.data.pay_type[i].id + '">' + data.data.pay_type[i].value + '</label>';
                html += '</div>';
            }
            $(".box_block3").html(html);
        } else {
            layer.msg(data.message);
        }

    },
    error: function(err) {
        console.log(err);
    }
});


//加的效果 
function num_add(on_this) {
    var totalQuantity = 0; //总数量
    var totalMoney = 0; //总金额
    var totalIntegral = 0; //总积分
    $("#myTbody tr").each(function() {

        //获取当前行的单价
        this_price = $(this).children(".danjia").text();
        this_price = parseFloat(this_price);

        //获取当前行的积分
        this_integral = $(this).children(".jifen").text();
        this_integral = parseFloat(this_integral);

        //获取当前行的数量
        this_num = $(this).find(".num").val();
        this_num = parseInt(this_num);

        //获取当前行的总价格、总积分
        var trmoney = this_price * this_num;
        var trIntegral = this_integral * this_num;

        //总金额、总数量、总积分
        totalQuantity += this_num * 1; //总数量
        totalMoney += trmoney * 1 //总金额
        totalIntegral += trIntegral * 1 //总积分
    })
    $(".totalQuantity").html(totalQuantity);
    $(".totalMoney").html(totalMoney);
    // $(".totalIntegral").html(totalIntegral);

    this_price = $(on_this).parents("td").siblings("td.danjia").text(); //获取单价
    this_price = parseFloat(this_price);
    totalMoney += this_price;
    $('.totalMoney').html(totalMoney.toFixed(2));

    this_integral = $(on_this).parents("td").siblings("td.jifen").text(); //获取积分  
    this_integral = parseFloat(this_integral);
    totalIntegral += this_integral;
    // $('.totalIntegral').html(totalIntegral.toFixed(0));

    //当前商品数量
    this_num = $(on_this).siblings('.num');
    var get_this_num = parseInt(this_num.val()) + 1;
    this_num.attr('data-num', get_this_num);
    this_num.val(get_this_num);

    totalQuantity++;
    $('.totalQuantity').html(totalQuantity);
}

//减的效果  
function num_sub(on_this) {
    var totalQuantity = 0; //总数量
    var totalMoney = 0; //总金额
    var totalIntegral = 0; //总积分
    $("#myTbody tr").each(function() {

        //获取当前行的单价
        this_price = $(this).children(".danjia").text();
        this_price = parseFloat(this_price);

        //获取当前行的积分
        this_integral = $(this).children(".jifen").text();
        this_integral = parseFloat(this_integral);

        //获取当前行的数量
        this_num = $(this).find(".num").val();
        this_num = parseInt(this_num);

        //获取当前行的总价格、总积分
        var trmoney = this_price * this_num;
        var trIntegral = this_integral * this_num;

        //总金额、总数量、总积分
        totalQuantity += this_num * 1; //总数量
        totalMoney += trmoney * 1 //总金额
        totalIntegral += trIntegral * 1 //总积分
    })
    $(".totalQuantity").html(totalQuantity);
    $(".totalMoney").html(totalMoney);
    // $(".totalIntegral").html(totalIntegral);

    //当前商品数量
    this_num = $(on_this).siblings('.num');
    if (this_num.val() <= 1) {
        layer.msg("如有需要,点击删除");
        // this_num.siblings('.jian').removeAttr('onclick');
        // return;
    } else {
        var get_this_num = this_num.val() - 1;
        this_num.val(get_this_num);

        this_price = $(on_this).parents("td").siblings("td.danjia").text(); //获取单价
        totalMoney -= this_price;
        $('.totalMoney').html(totalMoney.toFixed(2));

        this_integral = $(on_this).parents("td").siblings("td.jifen").text(); //获取积分  
        totalIntegral -= this_integral;
        $('.totalIntegral').html(totalIntegral.toFixed(0));

        this_num.attr('data-num', get_this_num);

        totalQuantity--;
        $('.totalQuantity').html(totalQuantity);
    }
}

//输入商品数量时改变合计的内容
$("#myTbody").on("keyup", ".num", function() {
    if ($(this).val() == '') {
        $(this).val('1');
    }
    $(this).val($(this).val().replace(/\D|^0/g, ''));
    setTotal();
})
//table tr 点击删除
$("#myTbody").on("click", ".delete_btn", function() {
    if ($("#myTbody tr").length < 1) {
        $(".totalQuantity").html("0");
        $(".totalMoney").html("0");
        $(".totalIntegral").html("0");
        return;
    }

    $(this).parents("#myTbody tr").remove();
    setTotal();
})
// 验证手机号
function isPhoneNo(phone) {
    var pattern = /^1[34578]\d{9}$/;
    return pattern.test(phone);
}
// 验证身份证 
function isCardNo(card) {
    var pattern = /(^\d{15}$)|(^\d{18}$)|(^\d{17}(\d|X|x)$)/;
    return pattern.test(card);
}

function setTotal() {
    var totalQuantity = 0; //总数量
    var totalMoney = 0; //总金额
    var totalIntegral = 0; //总积分
    $("#myTbody tr").each(function() {

        //获取当前行的单价
        this_price = $(this).children(".danjia").text();
        this_price = parseFloat(this_price);

        //获取当前行的积分
        this_integral = $(this).children(".jifen").text();
        this_integral = parseFloat(this_integral);

        //获取当前行的数量
        this_num = $(this).find(".num").val();
        this_num = parseInt(this_num);

        //获取当前行的总价格、总积分
        var trmoney = this_price * this_num;
        var trIntegral = this_integral * this_num;

        //总金额、总数量、总积分
        totalQuantity += this_num * 1; //总数量
        totalMoney += trmoney * 1 //总金额
        totalIntegral += trIntegral * 1 //总积分
    })
    $(".totalQuantity").html(totalQuantity);
    $(".totalMoney").html(totalMoney);
    $(".totalIntegral").html(totalIntegral);
}