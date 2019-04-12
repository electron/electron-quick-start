layui.use(['form', 'layer', 'laydate', 'table', 'laytpl', 'element'], function() {
    var form = layui.form,
        layer = parent.layer === undefined ? layui.layer : top.layer,
        $ = layui.jquery,
        laydate = layui.laydate,
        laytpl = layui.laytpl,
        table = layui.table;
    element = layui.element;
        num = 0;
    $.ajax({
        url: "https://pay.imbatv.cn/api/machine/all",
        type: "GET",
        dataType: 'json',
        success: function(data) {
            console.log(data);
            var data = data.data.machines;
            var html_1 = '';
            var html_2 = '';
            var html_3 = '';
            var html_4 = '';
            var html_5 = '';
            var html_6 = '';
            var html_7 = '';
            var html_8 = '';
            var html_9 = '';
            var html_10 = '';
            var html_11 = '';
            var html_12 = '';
            var html_13 = '';
            var html_14 = '';
            var html_15 = '';
            var html_16 = '';
            var html_17 = '';
            var html_18 = '';
            var html_19 = '';
            var html_20 = '';
            var html_21 = '';
            var html_22 = '';
            var html_23 = '';
            var html_24 = '';
            var html_25 = '';
            var html_26 = '';
            var html_27 = '';
            var html_28 = '';
            var html_29 = '';
            var html_30 = '';
            var html_31 = '';
            var html_32 = '';
            var html_33 = '';
            var html_34 = '';
            var html_35 = '';
            var html_36 = '';
            var html_37 = '';
            var html_38 = '';
            for (var i = 0; i < 17; i++) {
                if (data[i].state == 1) {
                    html_1 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='a" + (i + 1) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }else if(data[i].state == 4){
                    html_1 += "<span  mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='damage a" + (i + 1) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                } else {
                    html_1 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='cur a" + (i + 1) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }
            }
            for (var i = 17; i < 18; i++) {
                if (data[i].state == 1) {
                    html_2 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='a" + (i + 1) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }else if (data[i].state == 4) {
                    html_2 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "'  class='damage a" + (i - 57) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                } else {
                    html_2 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='cur a" + (i + 1) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }
            }
            for (var i = 18; i < 23; i++) {
                if (data[i].state == 1) {
                    html_3 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='a" + (i - 17) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }else if (data[i].state == 4) {
                    html_3 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "'  class='damage a" + (i - 57) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                } else {
                    html_3 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='cur a" + (i - 17) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }
            }
            for (var i = 23; i < 28; i++) {
                if (data[i].state == 1) {
                    html_4 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='a" + (i - 22) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }else if (data[i].state == 4) {
                    html_4 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "'  class='damage a" + (i - 57) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                } else {
                    html_4 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='cur a" + (i - 22) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }
            }
            for (var i = 28; i < 33; i++) {
                if (data[i].state == 1) {
                    html_5 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='a" + (i - 27) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }else if (data[i].state == 4) {
                    html_5 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "'  class='damage a" + (i - 57) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                } else {
                    html_5 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='cur a" + (i - 27) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }
            }
            for (var i = 33; i < 38; i++) {
                if (data[i].state == 1) {
                    html_6 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='a" + (i - 32) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }else if (data[i].state == 4) {
                    html_6 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "'  class='damage a" + (i - 57) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                } else {
                    html_6 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='cur a" + (i - 32) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }
            }
            for (var i = 38; i < 43; i++) {
                if (data[i].state == 1) {
                    html_7 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='a" + (i - 37) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }else if (data[i].state == 4) {
                    html_7 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "'  class='damage a" + (i - 57) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                } else {
                    html_7 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='cur a" + (i - 37) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }
            }
            for (var i = 43; i < 48; i++) {
                if (data[i].state == 1) {
                    html_8 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='a" + (i - 42) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }else if (data[i].state == 4) {
                    html_8 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "'  class='damage a" + (i - 57) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                } else {
                    html_8 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='cur a" + (i - 42) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }
            }
            for (var i = 48; i < 53; i++) {
                if (data[i].state == 1) {
                    html_9 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='a" + (i - 47) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }else if (data[i].state == 4) {
                    html_9 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "'  class='damage a" + (i - 57) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                } else {
                    html_9 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='cur a" + (i - 47) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }
            }
            for (var i = 53; i < 58; i++) {
                if (data[i].state == 1) {
                    html_10 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='a" + (i - 52) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }else if (data[i].state == 4) {
                    html_10 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "'  class='damage a" + (i - 57) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                } else {
                    html_10 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='cur a" + (i - 52) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }
            }

            for (var i = 58; i < 63; i++) {
                if (data[i].state == 1) {
                    html_11 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "'  class='a" + (i - 57) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }else if (data[i].state == 4) {
                    html_11 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "'  class='damage a" + (i - 57) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }  else {
                    html_11 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='cur a" + (i - 57) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }
            }

            for (var i = 63; i < 68; i++) {
                if (data[i].state == 1) {
                    html_12 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "'  class='a" + (i - 62) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }else if (data[i].state == 4) {
                    html_12 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "'  class='damage a" + (i - 57) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                } else {
                    html_12 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='cur a" + (i - 62) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }
            }

            for (var i = 68; i < 73; i++) {
                if (data[i].state == 1) {
                    html_13 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='a" + (i - 67) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }else if (data[i].state == 4) {
                    html_13 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "'  class='damage a" + (i - 57) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                } else {
                    html_13 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='cur a" + (i - 67) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }
            }
            for (var i = 73; i < 78; i++) {
                if (data[i].state == 1) {
                    html_14 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='a" + (i - 72) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }else if (data[i].state == 4) {
                    html_14 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "'  class='damage a" + (i - 57) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                } else {
                    html_14 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='cur a" + (i - 72) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }
            }

            for (var i = 78; i < 83; i++) {
                if (data[i].state == 1) {
                    html_15 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='a" + (i - 77) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }else if (data[i].state == 4) {
                    html_15 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "'  class='damage a" + (i - 57) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                } else {
                    html_15 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='cur a" + (i - 77) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }
            }
            for (var i = 83; i < 88; i++) {
                if (data[i].state == 1) {
                    html_16 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='a" + (i - 82) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }else if (data[i].state == 4) {
                    html_16 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "'  class='damage a" + (i - 57) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                } else {
                    html_16 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='cur a" + (i - 82) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }
            }

            for (var i = 88; i < 93; i++) {
                if (data[i].state == 1) {
                    html_17 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='a" + (i - 87) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }else if (data[i].state == 4) {
                    html_17 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "'  class='damage a" + (i - 57) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                } else {
                    html_17 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='cur a" + (i - 87) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }
            }

            for (var i = 93; i < 98; i++) {
                if (data[i].state == 1) {
                    html_18 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='a" + (i - 92) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }else if (data[i].state == 4) {
                    html_18 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "'  class='damage a" + (i - 57) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                } else {
                    html_18 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='cur a" + (i - 92) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }
            }

            for (var i = 98; i < 103; i++) {
                if (data[i].state == 1) {
                    html_19 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='a" + (i - 97) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }else if (data[i].state == 4) {
                    html_19 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "'  class='damage a" + (i - 57) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                } else {
                    html_19 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='cur a" + (i - 97) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }
            }
            for (var i = 103; i < 108; i++) {
                if (data[i].state == 1) {
                    html_19 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='a" + (i - 102) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }else if (data[i].state == 4) {
                    html_19 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "'  class='damage a" + (i - 57) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                } else {
                    html_19 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='cur a" + (i - 102) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }
            }

            for (var i = 108; i < 113; i++) {
                if (data[i].state == 1) {
                    html_20 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='a" + (i - 107) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }else if (data[i].state == 4) {
                    html_20 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "'  class='damage a" + (i - 57) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                } else {
                    html_20 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='cur a" + (i - 107) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }
            }
            for (var i = 113; i < 118; i++) {
                if (data[i].state == 1) {
                    html_21 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='a" + (i - 112) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }else if (data[i].state == 4) {
                    html_21 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "'  class='damage a" + (i - 57) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                } else {
                    html_21 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='cur a" + (i - 112) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }
            }

            for (var i = 118; i < 123; i++) {
                if (data[i].state == 1) {
                    html_22 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='a" + (i - 117) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }else if (data[i].state == 4) {
                    html_22 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "'  class='damage a" + (i - 57) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                } else {
                    html_22 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='cur a" + (i - 117) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }
            }
            for (var i = 123; i < 128; i++) {
                if (data[i].state == 1) {
                    html_23 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='a" + (i - 122) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }else if (data[i].state == 4) {
                    html_23 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "'  class='damage a" + (i - 57) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                } else {
                    html_23 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='cur a" + (i - 122) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }
            }

            for (var i = 128; i < 133; i++) {
                if (data[i].state == 1) {
                    html_24 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "'class='a" + (i - 127) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }else if (data[i].state == 4) {
                    html_24 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "'  class='damage a" + (i - 57) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                } else {
                    html_24 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='cur a" + (i - 127) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }
            }
            for (var i = 133; i < 138; i++) {
                if (data[i].state == 1) {
                    html_25 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='a" + (i - 132) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }else if (data[i].state == 4) {
                    html_25 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "'  class='damage a" + (i - 57) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                } else {
                    html_25 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='cur a" + (i - 132) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }
            }

            for (var i = 138; i < 143; i++) {
                if (data[i].state == 1) {
                    html_26 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='a" + (i - 137) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }else if (data[i].state == 4) {
                    html_26 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "'  class='damage a" + (i - 57) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                } else {
                    html_26 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='cur a" + (i - 137) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }
            }
            for (var i = 143; i < 148; i++) {
                if (data[i].state == 1) {
                    html_27 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='a" + (i - 142) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }else if (data[i].state == 4) {
                    html_27 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "'  class='damage a" + (i - 57) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                } else {
                    html_27 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='cur a" + (i - 142) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }
            }

            for (var i = 148; i < 153; i++) {
                if (data[i].state == 1) {
                    html_28 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='a" + (i - 147) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }else if (data[i].state == 4) {
                    html_28 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "'  class='damage a" + (i - 57) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                } else {
                    html_28 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='cur a" + (i - 147) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }
            }
            for (var i = 153; i < 158; i++) {
                if (data[i].state == 1) {
                    html_29 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='a" + (i - 152) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }else if (data[i].state == 4) {
                    html_29 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "'  class='damage a" + (i - 57) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                } else {
                    html_29 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='cur a" + (i - 152) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }
            }

            for (var i = 158; i < 163; i++) {
                if (data[i].state == 1) {
                    html_30 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='a" + (i - 157) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }else if (data[i].state == 4) {
                    html_30 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "'  class='damage a" + (i - 57) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                } else {
                    html_30 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='cur a" + (i - 157) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }
            }
            for (var i = 163; i < 168; i++) {
                if (data[i].state == 1) {
                    html_31 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='a" + (i - 162) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }else if (data[i].state == 4) {
                    html_31 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "'  class='damage a" + (i - 57) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                } else {
                    html_31 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='cur a" + (i - 162) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }
            }
            for (var i = 168; i < 174; i++) {
                if (data[i].state == 1) {
                    html_32 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='a" + (i - 167) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }else if (data[i].state == 4) {
                    html_32 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "'  class='damage a" + (i - 57) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                } else {
                    html_32 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='cur a" + (i - 167) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }
            }
            for (var i = 174; i < 180; i++) {
                if (data[i].state == 1) {
                    html_33 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='a" + (i - 173) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }else if (data[i].state == 4) {
                    html_33 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "'  class='damage a" + (i - 57) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                } else {
                    html_33 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='cur a" + (i - 173) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }
            }
            for (var i = 180; i < 186; i++) {
                if (data[i].state == 1) {
                    html_34 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='a" + (i - 179) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }else if (data[i].state == 4) {
                    html_34 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "'  class='damage a" + (i - 57) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                } else {
                    html_34 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='cur a" + (i - 179) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }
            }
            for (var i = 186; i < 196; i++) {
                if (data[i].state == 1) {
                    html_35 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='a" + (i - 185) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }else if (data[i].state == 4) {
                    html_35 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "'  class='damage a" + (i - 57) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                } else {
                    html_35 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='cur a" + (i - 185) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }
            }
            for (var i = 196; i < 206; i++) {
                if (data[i].state == 1) {
                    html_36 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='a" + (i - 195) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }else if (data[i].state == 4) {
                    html_36 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "'  class='damage a" + (i - 57) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                } else {
                    html_36 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='cur a" + (i - 195) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }
            }
            for (var i = 206; i < 226; i++) {
                if (data[i].state == 1) {
                    html_37 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='a" + (i - 205) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }else if (data[i].state == 4) {
                    html_37 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "'  class='damage a" + (i - 57) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                } else {
                    html_37 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='cur a" + (i - 205) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }
            }
            for (var i = 226; i < 236; i++) {
                if (data[i].state == 1) {
                    html_38 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='a" + (i - 225) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }else if (data[i].state == 4) {
                    html_38 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "'  class='damage a" + (i - 57) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                } else {
                    html_38 += "<span mid='" + data[i].mid + "' data-uid='" + data[i].uid + "' class='cur a" + (i - 225) + " m" + data[i].mid + "'>" + data[i].machine_name + "</span>";
                }
            }
            $("li.n31").html(html_1);
            $("li.n32").html(html_2);
            $("li.n17").html(html_3);
            $("li.n22").html(html_4);
            $("li.n23").html(html_5);
            $("li.n24").html(html_6);
            $("li.n33").html(html_7);
            $("li.n34").html(html_8);
            $("li.n35").html(html_9);
            $("li.n36").html(html_10);
            $("li.n1").html(html_11);
            $("li.n2").html(html_12);
            $("li.n3").html(html_13);
            $("li.n4").html(html_14);
            $("li.n5").html(html_15);
            $("li.n6").html(html_16);
            $("li.n7").html(html_17);
            $("li.n8").html(html_18);
            $("li.n9").html(html_19);
            $("li.n10").html(html_20);
            $("li.n11").html(html_21);
            $("li.n12").html(html_22);
            $("li.n13").html(html_23);
            $("li.n14").html(html_24);
            $("li.n15").html(html_25);
            $("li.n19").html(html_26);
            $("li.n25").html(html_27);
            $("li.n26").html(html_28);
            $("li.n27").html(html_29);
            $("li.n28").html(html_30);
            $("li.n29").html(html_31);
            $("li.n18").html(html_32);
            $("li.n20").html(html_33);
            $("li.n21").html(html_34);
            $("li.n30").html(html_35);
            $("li.n37").html(html_36);
            $("li.n16").html(html_37);
            $("li.n38").html(html_38);
            window.addEventListener("load", init, false);
            // 获取呼叫列表
            $.ajax({
                url: "https://pay.imbatv.cn/api/service",
                type: "GET",
                dataType: 'json',
                success: function(data) {
                    var arr1 = new Array();
                    console.log(data.data);
                    console.log(data);
                    for (var i = 0; i < data.data.length; i++) {
                        arr1.push(data.data[i]);
                        $(".m" + data.data[i]).addClass("call");
                    }
                    // console.log(arr1);
                },
                error: function(err) {
                    console.log(err)
                }
            });
            // 获取呼叫列表
            // 点击查看使用者信息
            $(".computer ul").on('click', 'span.cur', function() {
                var uid = $(this).attr("data-uid");
                var machine_numbe = $(this).html();
                // 判断是否需要显示取消呼叫按钮
                if ($(this).hasClass('call')) {
                    $.ajax({
                        url: "https://pay.imbatv.cn/api/user/get_active_user_info",
                        type: "POST",
                        data: {
                            user_id: uid,
                        },
                        dataType: 'json',
                        success: function(data) {
                            $(".box .box_cn h1").html(machine_numbe + '使用中');
                            $(".box .box_cn .cn span.cn1").html('会员号:' + data.data.username);
                            $(".box .box_cn .cn span.cn2").html('姓名:' + data.data.name);
                            $(".box .box_cn .cn span.cn3").html('余额:' + data.data.balance);
                            $(".box .box_cn .cn span.cn4").html('手机号:' + data.data.phone);
                            $(".box .box_cn .cn span.cn5").html('会员等级:' + data.data.level);
                            $(".box .box_cn .cn span.cn6").html('上机时长:' + formatDuring(data.data.duration));
                            $(".box .box_cn .cn span.cn7").html('本次消费:' + data.data.phone);

                            layer.open({
                                type: 1,
                                closeBtn: 0,
                                title: false,
                                shadeClose: true,
                                area: ['780px', '480px'],
                                content: $('.box'), //这里content是一个DOM，注意：最好该元素要存放在body最外层，否则可能被其它的相对元素所影响
                                btn: ['取消呼叫'],
                                yes: function(cms) {
                                    console.log(cms);
                                    $.ajax({
                                        url: "https://pay.imbatv.cn/api/service/cancel",
                                        type: "POST",
                                        data: {
                                            user_id: uid,
                                        },
                                        dataType: 'json',
                                        success: function(data) {
                                            console.log(data);
                                            $(".m" + data.data).removeClass('call');
                                            layer.closeAll();
                                        },
                                        error: function(err) {
                                            console.log(err)
                                        }
                                    });
                                }
                            });
                        },
                        error: function(err) {
                            console.log(err)
                        }
                    });
                } else {
                    $.ajax({
                        url: "https://pay.imbatv.cn/api/user/get_active_user_info",
                        type: "POST",
                        data: {
                            user_id: uid,
                        },
                        dataType: 'json',
                        success: function(data) {
                            $(".box .box_cn h1").html(machine_numbe + '使用中');
                            $(".box .box_cn .cn span.cn1").html('会员号:' + data.data.username);
                            $(".box .box_cn .cn span.cn2").html('姓名:' + data.data.name);
                            $(".box .box_cn .cn span.cn3").html('余额:' + data.data.balance);
                            $(".box .box_cn .cn span.cn4").html('手机号:' + data.data.phone);
                            $(".box .box_cn .cn span.cn5").html('会员等级:' + data.data.level);
                            $(".box .box_cn .cn span.cn6").html('上机时长:' + formatDuring(data.data.duration));
                            $(".box .box_cn .cn span.cn7").html('本次消费:' + data.data.phone);

                            layer.open({
                                type: 1,
                                closeBtn: 0,
                                title: false,
                                shadeClose: true,
                                area: ['780px', '418px'],
                                content: $('.box'), //这里content是一个DOM，注意：最好该元素要存放在body最外层，否则可能被其它的相对元素所影响

                            });
                        },
                        error: function(err) {
                            console.log(err)
                        }
                    });
                }



            });

            $.ajax({
                url: "https://pay.imbatv.cn/api/appointment/num",
                type: "GET",
                dataType: 'json',
                success: function(data) {
                    console.log(data);
                    $(".information .sp1").html('5人包厢:' + data.data['5人包厢']);
                    $(".information .sp2").html('6人包厢:' + data.data['6人包厢']);
                    $(".information .sp3").html('10人包厢:' + data.data['10人包厢']);
                    $(".information .sp4").html('20人包厢:' + data.data['20人包厢']);
                    $(".information .sp5").html('散座:' + data.data['散座']);
                },
                error: function(err) {
                    console.log(err)
                }
            });
        },
        error: function(err) {
            console.log(err);
        }
    });
});

// 转化时长
function formatDuring(mss) {
    var days = parseInt(mss / (60 * 60 * 24));
    var hours = parseInt((mss % (60 * 60 * 24)) / (60 * 60));
    var minutes = parseInt((mss % (60 * 60)) / (60));
    var seconds = (mss % (1000 * 60)) / 1000;
    console.log(seconds);
    return days + " 天 " + hours + " 小时 " + minutes + " 分钟 ";
}

// 实时更新状态
var wsUri = "wss://pay.imbatv.cn:10444";
var output;

function init() {
    output = document.getElementById("output");
    testWebSocket();
}

function testWebSocket() {
    websocket = new WebSocket(wsUri);
    websocket.onopen = function(evt) {
        onOpen(evt)
    };
    websocket.onclose = function(evt) {
        onClose(evt)
    };
    websocket.onmessage = function(evt) {
        onMessage(evt)
    };
    websocket.onerror = function(evt) {
        onError(evt)
    };
}

function onOpen(evt) {
    // writeToScreen("CONNECTED");
    // doSend(); 
}

function onClose(evt) {
    writeToScreen("DISCONNECTED");
}

function onMessage(evt) {
    var arr = new Array();
    $(".computer ul li span").each(function() {
        var mid = $(this).attr("mid");
        arr.push(mid);

    });
    var res = JSON.parse(evt.data);
    console.log(res);
    if (res.cmd == 'open') {
        $(".m" + res.mid).addClass('cur');

    } else if (res.cmd == 'down') {
        $(".m" + res.mid).removeClass('cur');
        $(".m" + res.mid).removeClass('call');
    } else if (res.cmd == 'call_service') {
        $(".m" + res.mid).addClass('call');
        // 获取机器号
        var machineid = $(".m" + res.mid).html() + "呼叫中";
        // 呼叫弹框
        layer.msg('<span style="font-size:20px;display:block;height:195px;line-height:195px;">' + machineid + '</span>', {
            area: ['320px', '220px'],
            offset: 'rb',
            anim: 8
        });
    } else if(res.cmd == 'not_enough_money'){
         var machineid = $(".m" + res.mid).html() + "账户余额不足";
         layer.msg('<span style="font-size:20px;display:block;height:195px;line-height:195px;">' + machineid + '</span>', {
            area: ['320px', '220px'],
            offset: 'rb',
            anim: 8
        });
    }else if(res.cmd == 'new_order'){
        $(".new_order").html("您有新订单未处理！");
        num = num + 1;
    }else if(res.cmd == 'order_down'){
        num = num - 1;
    }
    $(".m" + res.mid).attr('data-uid', res.uid);
    console.log(num);
    if (num == 0) {
       $(".new_order").html(""); 
    }
}

function onError(evt) {
    console.log(evt.data);
}

function doSend(message) {
    writeToScreen("SENT: " + message);
    websocket.send(message);
}

function writeToScreen(message) {
    var pre = document.createElement("p");
    pre.style.wordWrap = "break-word";
    pre.innerHTML = message;
    output.appendChild(pre);
}
window.addEventListener("load", init, false);