layui.use(['form', 'layer', 'laydate', 'table', 'laytpl'], function() {
    var form = layui.form;
    var laypage = layui.laypage;
    layer = parent.layer === undefined ? layui.layer : top.layer,
        $ = layui.jquery,
        laydate = layui.laydate,
        laytpl = layui.laytpl,
        table = layui.table;

    var tableIns = table.render({
        elem: '#newsList',
        url: 'https://pay.imbatv.cn/api/user/get_user_list',
        limit: 15,
        limits: [15, 30, 45, 60],
        page: true,
        //,…… //其他参数
        cols: [
            [
                { field: 'id', title: 'ID', align: 'center', width: 50 },
                { field: 'state', title: '状态', align: 'center', width: 50, hide: false },
                { field: 'username', title: '会员号', width: 150, align: "center" },
                { field: 'name', title: '姓名', width: 150, align: "center" },
                { field: 'level', title: '会员等级', align: 'center',width: 150 },
                { field: 'balance', title: '余额', align: 'center',width: 150 },
                { field: 'phone', title: '手机号', align: 'center', width: 200},
                { field: 'idcard', title: '身份证号', align: 'center' },
                { title: '操作', width: 400, templet: '#newsListBar', fixed: "right", align: "center" }
            ]
        ],
        done: function(res, curr, count) {
            console.log(res);
            $(".layui-table-box").find("[data-field='state']").css("display", "none");
            // $(".layui-table-box").find("[data-field='id']").css("display", "none");
        }
    });
    // 搜索
    var $ = layui.$,
        active = {
            reload: function() {
                var searchVal = $(".searchVal").val();
                if (isPhoneNo(searchVal)) {
                    username = '';
                    phone = searchVal;
                    name = '';
                    idcard = '';
                } else {
                    username = searchVal;
                    phone = '';
                    name = '';
                    idcard = '';
                }
                table.reload('newsList', {
                    url: 'https://pay.imbatv.cn/api/user/get_user_list',
                    where: {
                        username: username,
                        phone: phone,
                        name: name,
                        idcard: idcard
                    },
                    page: {
                        curr: 1 //重新从第 1 页开始
                    }
                });
            }
        };

    $('.search_btn').on('click', function() {
        var type = $(this).data('type');
        active[type] ? active[type].call(this) : '';
    });
    // 验证手机号
    function isPhoneNo(phone) {
        var pattern = /^1[34578]\d{9}$/;
        return pattern.test(phone);
    }


    //列表操作
    table.on('tool(newsList)', function(obj) {
        var layEvent = obj.event,
            data = obj.data;
        console.log(data);
        var userid = obj.data.id;
        var username = obj.data.username;
        var name = data.name;
        var phone = data.phone;
        var idcard = data.idcard;
        var level = data.level;
        console.log(name);
        console.log(phone);
        console.log(idcard);
        if (layEvent === 'edit') { //充值
            layer.open({
                type: 2,
                title: '',
                shadeClose: true,
                shade: 0.8,
                area: ['1000px', '720px'],
                content: 'page/recharge/recharge.html?userid=' + userid, //iframe的url
                end: function() {
                    var searchVal = $(".searchVal").val();
                    if (searchVal != '') {
                        if (isPhoneNo(searchVal)) {
                            username = '';
                            phone = searchVal;
                            name = '';
                            idcard = '';
                        } else {
                            username = searchVal;
                            phone = '';
                            name = '';
                            idcard = '';
                        }
                        tableIns.reload({
                            url: 'https://pay.imbatv.cn/api/user/get_user_list',
                            where: {
                                username: username,
                                phone: phone,
                                name: name,
                                idcard: idcard
                            },
                            page: {
                                curr: 1 //重新从第 1 页开始
                            }
                        });
                    } else {
                        tableIns.reload({});
                    }
                }
            });
        } else if (layEvent === 'op-cp') { //上机
            layer.open({
                type: 2,
                title: '',
                shadeClose: true,
                shade: 0.8,
                area: ['1200px', '880px'],
                content: 'page/alert_2/recharge.html?userid=' + userid, //iframe的url
            });
        } else if (layEvent === 'down-cp') { //下机
            layer.open({
                type: 2,
                title: '',
                shadeClose: true,
                shade: 0.8,
                area: ['800px', '500px'],
                content: 'page/alert_6/give.html?userid=' + userid, //iframe的url
                success: function(layero, index) {
                    var body = layer.getChildFrame('body', index);
                    var iframeWin = window[layero.find('iframe')[0]['name']]; //得到iframe页的窗口对象，执行iframe页的方法：iframeWin.method();
                    body.find('.cz').attr('userid', userid);
                },
                end: function() {
                    var searchVal = $(".searchVal").val();
                    if (searchVal != '') {
                        if (isPhoneNo(searchVal)) {
                            username = '';
                            phone = searchVal;
                            name = '';
                            idcard = '';
                        } else {
                            username = searchVal;
                            phone = '';
                            name = '';
                            idcard = '';
                        }
                        tableIns.reload({
                            url: 'https://pay.imbatv.cn/api/user/get_user_list',
                            where: {
                                username: username,
                                phone: phone,
                                name: name,
                                idcard: idcard
                            },
                            page: {
                                curr: 1 //重新从第 1 页开始
                            }
                        });
                    } else {
                        tableIns.reload({});
                    }
                }
            });
        } else if (layEvent === 'information') { //绑定信息
            layer.open({
                type: 2,
                title: '',
                shadeClose: true,
                shade: 0.8,
                area: ['600px', '300px'],
                content: 'page/alert_3/recharge.html?userid=' + userid, //iframe的url
                success: function(layero, index) {
                    var body = layer.getChildFrame('body', index);
                    var iframeWin = window[layero.find('iframe')[0]['name']]; //得到iframe页的窗口对象，执行iframe页的方法：iframeWin.method();
                    body.find('input.name').val(name);
                    body.find('input.phone').val(phone);
                    body.find('input.idcard').val(idcard);
                    body.find('.cz').attr('userid', userid);
                },
                end: function() {
                    var searchVal = $(".searchVal").val();
                    if (searchVal != '') {
                        if (isPhoneNo(searchVal)) {
                            username = '';
                            phone = searchVal;
                            name = '';
                            idcard = '';
                        } else {
                            username = searchVal;
                            phone = '';
                            name = '';
                            idcard = '';
                        }
                        tableIns.reload({
                            url: 'https://pay.imbatv.cn/api/user/get_user_list',
                            where: {
                                username: username,
                                phone: phone,
                                name: name,
                                idcard: idcard
                            },
                            page: {
                                curr: 1 //重新从第 1 页开始
                            }
                        });
                    } else {
                        tableIns.reload({});
                    }
                }
            });
        } else if (layEvent === 'give') { //赠送优惠劵
            var user_id = obj.data.id;
            layer.open({
                type: 2,
                title: '',
                shadeClose: true,
                shade: 0.8,
                area: ['600px', '325px'],
                content: 'page/alert_5/give.html?userid=' + userid, //iframe的url
                success: function(layero, index) {
                    var body = layer.getChildFrame('body', index);
                    var iframeWin = window[layero.find('iframe')[0]['name']]; //得到iframe页的窗口对象，执行iframe页的方法：iframeWin.method();
                    // body.find('input.name').val(name);
                    // body.find('input.phone').val(phone);
                    // body.find('input.idcard').val(idcard);
                    body.find('.cz').attr('userid', userid);
                },
                end: function() {
                    var searchVal = $(".searchVal").val();
                    if (searchVal != '') {
                        if (isPhoneNo(searchVal)) {
                            username = '';
                            phone = searchVal;
                            name = '';
                            idcard = '';
                        } else {
                            username = searchVal;
                            phone = '';
                            name = '';
                            idcard = '';
                        }
                        tableIns.reload({
                            url: 'https://pay.imbatv.cn/api/user/get_user_list',
                            where: {
                                username: username,
                                phone: phone,
                                name: name,
                                idcard: idcard
                            },
                            page: {
                                curr: 1 //重新从第 1 页开始
                            }
                        });
                    } else {
                        tableIns.reload({});
                    }
                }
            });
        }else if (layEvent === 'vip') { //赠送特殊VIP
            layer.open({
                type: 2,
                title: '',
                shadeClose: true,
                shade: 0.8,
                area: ['600px', '300px'],
                content: 'page/alert_7/recharge.html?userid=' + userid, //iframe的url
                success: function(layero, index) {
                    var body = layer.getChildFrame('body', index);
                    var iframeWin = window[layero.find('iframe')[0]['name']]; //得到iframe页的窗口对象，执行iframe页的方法：iframeWin.method();
                    console.log(iframeWin);
                    body.find('input.name').val(name);
                    body.find('input.level').val(level);
                    // body.find('input.time').val(idcard);
                    body.find('.cz').attr('userid', userid);
                },
                end: function() {
                    var searchVal = $(".searchVal").val();
                    if (searchVal != '') {
                        if (isPhoneNo(searchVal)) {
                            username = '';
                            phone = searchVal;
                            name = '';
                            idcard = '';
                        } else {
                            username = searchVal;
                            phone = '';
                            name = '';
                            idcard = '';
                        }
                        tableIns.reload({
                            url: 'https://pay.imbatv.cn/api/user/get_user_list',
                            where: {
                                username: username,
                                phone: phone,
                                name: name,
                                idcard: idcard
                            },
                            page: {
                                curr: 1 //重新从第 1 页开始
                            }
                        });
                    } else {
                        tableIns.reload({});
                    }
                }
            });
        }
    });

})