layui.use(['form','layer','jquery'],function(){
    var form = layui.form,
        layer = parent.layer === undefined ? layui.layer : top.layer
        $ = layui.jquery;
        
        const ipcRenderer = require('electron').ipcRenderer;
        ipcRenderer.on('change-user',(e,m)=>{
            $(".show_user_name").html(m);
        })
        ipcRenderer.on('checkin',(e,m,h)=>{
            if(m != 'st'){
                var class_name = '.'+m;
                $(class_name).html(h);
            }else{
                if(h == 1){
                    $(".show_checkin").show();
                }else{
                    $(".show_checkin").hide();
                }
            }
            
        })

        ipcRenderer.on('checkout',(e,m,h)=>{
            if(m == 1){
                console.log(h);
                $(".checkout_machine_num").html(h.data.machine_info.machine_name);
                $(".checkout_machine_box").html(h.data.machine_info.box_id);
                if(h.message == '无扣款记录'){
                    $(".checkout_time").html(0);
                    $(".checkout_money").html(0);
                }else{
                    $(".checkout_time").html(h.data.deduct_info.total_time);
                    $(".checkout_money").html(h.data.deduct_info.total_money);
                }
                
                $(".checkout_peripheral_1").html(h.data.peripheral_last_data[1].desc);
                $(".checkout_peripheral_2").html(h.data.peripheral_last_data[2].desc);
                $(".checkout_peripheral_3").html(h.data.peripheral_last_data[3].desc);
                $(".checkout_peripheral_4").html(h.data.peripheral_last_data[4].desc);
                $(".show_checkout").show();
            }else{
                $(".show_checkout").hide();
            }
        })

        ipcRenderer.on('recharge',(e,st,num)=>{
            if(st == 1){
                $(".show_money").show();
                $(".money_num").html(num);
            }else{
                $(".show_money").hide();
            }
        })

        ipcRenderer.on('sale',(e,st,data,money)=>{
            if(st == 1){
                console.log(data);
                var obj = eval('(' + data + ')');
                var html ='';
                var first = true;
                for (var key in obj) {
                    if (data.hasOwnProperty(key)) {
                        var element = obj[key];
                        if(first){
                            first=false;
                            html += '<li class="a1">'+element.name+' '+element.quantity+' 包：'+element.price+'元</li>';
                        }else{
                            html += '<li>'+element.name+' '+element.quantity+' 包：'+element.price+'元</li>';
                        }
                    }
                }
                $(".show_sale").show();
                $(".con ul").html(html);
                $(".show_sale_money").html(money)
            }else{
                $(".show_sale").hide();
            }
        })
})
