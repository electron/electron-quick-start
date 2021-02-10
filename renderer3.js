// This file is required by the index.html file and will
// be executed in the renderer process for that window.
// No Node.js APIs are available in this process because
// `nodeIntegration` is turned off. Use `preload.js` to
// selectively enable features needed in the rendering
// process.
var canvas = document.getElementById("myCanvas");
var ctx = canvas.getContext("2d");
var x = canvas.width/2;
var y = canvas.height-30;
var dx = 2;
var dy = -2;
var ballRadius = 10;
var paddleHeight = 10;
var paddleWidth = 125;
var paddleX = (canvas.width-paddleWidth) / 2;
var brickRowCount = 5;
var brickColumnCount = 5;
var total = 17;
var brickWidth = 133;
var brickHeight = 20;
var brickPadding = 20;
var brickOffsetTop = 30;
var brickOffsetLeft = 30;
var bricksDest = 0;

var bricks = [];
for(var c=0; c<brickColumnCount; c++) {
    bricks[c] = [];
    for(var r=0; r<brickRowCount; r++) {
        bricks[c][r] = { x: 0, y: 0, type: 1, status: 1 };
    }
}
var xlol = 1;
for(var c=0; c<brickColumnCount; c++) {
    if (xlol+c < 5) {
        if(xlol+c == 2){
            bricks[c][3] = { x: 0, y: 0, type: xlol+c, status: 2 };
        }
        else{
            bricks[c][3] = { x: 0, y: 0, type: xlol+c, status: 1 };
        }
    }
    else{
        bricks[c][3] = { x: 0, y: 0, type: 5, status: 1 };
    }
}
for (r=0; r<brickRowCount; r++) {
    if(bricks[1][r].type == 1) {
        bricks[1][r] = { x: 0, y: 0, type: 1, status: -1};
    }
    if(bricks[3][r].type == 1) {
        bricks[3][r] = { x: 0, y: 0, type: 1, status: -1};
    }
}
bricks[0][3] = { x: 0, y: 0, type: 1, status: 1 };

document.addEventListener("keydown", keyDownHandler, false);
document.addEventListener("keyup", keyUpHandler, false);

function setDxy(amt){
    dx = amt;
    dy = dx;
}
function drawBall() {
    ctx.beginPath();
    ctx.arc(x, y, ballRadius, 0, Math.PI*2);
    ctx.fillStyle = "#0095DD";
    ctx.fill();
    ctx.closePath();
}

function drawBricks() {
    for(var c=0; c<brickColumnCount; c++) {
        for(var r=0; r<brickRowCount; r++) {
            if(bricks[c][r].status >= 1) {
                var brickX = (c*(brickWidth+brickPadding))+brickOffsetLeft;
                var brickY = (r*(brickHeight+brickPadding))+brickOffsetTop;
                bricks[c][r].x = brickX;
                bricks[c][r].y = brickY;
                ctx.beginPath();
                ctx.rect(brickX, brickY, brickWidth, brickHeight);
                if (bricks[c][r].type == 2) {
                    ctx.fillStyle = "#C0C0C0";
                }
                else if (bricks[c][r].type == 3) {
                    ctx.fillStyle = "#00FF00";
                }
                else if (bricks[c][r].type == 4) {
                    ctx.fillStyle = "#8B008B";
                }
                else if (bricks[c][r].type == 5) {
                    ctx.fillStyle = "#FF0000";
                }
                else {
                    ctx.fillStyle = "#0095DD";
                }
                ctx.fill();
                ctx.closePath();
            }
        }
    }
}

function draw() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    drawBricks();
    drawBall();
    drawPaddle();
    collisionDetection();
    if(x + dx > canvas.width-ballRadius || x + dx < ballRadius) {
        dx = -dx;
    }
    if(y + dy < ballRadius) {
        dy = -dy;
    } else if(y + dy > canvas.height-ballRadius) {
        if(x > paddleX && x < paddleX + paddleWidth) {
            dy = -dy;
        }
        else {
            window.location.replace("gameover.html");
            clearInterval(interval);
        }
    }
    if(rightPressed) {
        paddleX += 5;
        if (paddleX + paddleWidth > canvas.width){
            paddleX = canvas.width - paddleWidth;
        }
    }
    else if(leftPressed) {
        paddleX -= 5;
        if (paddleX < 0){
            paddleX = 0;
        }
    }
    x += dx;
    y += dy;
}

function drawPaddle() {
    ctx.beginPath();
    ctx.rect(paddleX, canvas.height-paddleHeight, paddleWidth, paddleHeight);
    ctx.fillStyle = "#0095DD";
    ctx.fill();
    ctx.closePath();
}

function collisionDetection() {
    for(var c=0; c<brickColumnCount; c++) {
        for(var r=0; r<brickRowCount; r++) {
            var b = bricks[c][r];
            if(b.status >= 1) {
                if(x > b.x && x < b.x+brickWidth && y > b.y && y < b.y+brickHeight) {
                    dy = -dy;
                    b.status--;
                    checkType(b.type);
                    if (b.type == 5) {
                        if (c-1>-1 && r-1>-1){
                            bricks[c-1][r-1].status--;
                            if (bricks[c-1][r-1].status == 0){
                                bricksDest++;
                                checkType(bricks[c-1][r-1].type);
                            }
                        }
                        if (r-1>-1){
                            bricks[c][r-1].status--;
                            if (bricks[c][r-1].status == 0){
                                bricksDest++;
                                checkType(bricks[c][r-1].type);
                            }
                        }
                        if (c+1 < brickColumnCount && r-1>-1){
                            bricks[c+1][r-1].status--;
                            if (bricks[c+1][r-1].status == 0){
                                bricksDest++;
                                checkType(bricks[c+1][r-1].type);
                            }
                        }
                        if (c-1>-1){
                            bricks[c-1][r].status--;
                            if (bricks[c-1][r].status == 0){
                                bricksDest++;
                                checkType(bricks[c-1][r].type);
                            }
                        }
                        if (c+1<brickColumnCount){
                            bricks[c+1][r].status--;
                            if (bricks[c+1][r].status == 0){
                                bricksDest++;
                                checkType(bricks[c+1][r].type);
                            }
                        }
                        if (c-1>-1 && r+1 < brickRowCount){
                            bricks[c-1][r+1].status--;
                            if (bricks[c-1][r+1].status == 0){
                                bricksDest++;
                                checkType(bricks[c-1][r+1].type);
                            }
                        }
                        if (r+1< brickRowCount){
                            bricks[c][r+1].status--;
                            if (bricks[c][r+1].status == 0){
                                bricksDest++;
                                checkType(bricks[c][r-1].type);
                            }
                        }
                        if (c+1< brickColumnCount && r+1 < brickRowCount){
                            bricks[c+1][r+1].status--;
                            if (bricks[c+1][r+1].status == 0){
                                bricksDest++;
                                checkType(bricks[c+1][r+1].type);
                            }
                        }
                    }
                    if (b.status == 0){
                        bricksDest++;
                    }
                    if(bricksDest == total) {
                        window.location.replace("levelfour.html");
                        clearInterval(interval); // Needed for Chrome to end game
                    }
                }
            }
        }
    }
}

function checkType(typ) {
    if (typ == 3) {
        setDxy(2.5);
    }
    else if (typ == 4) {
        setDxy(1.5);
    }
}

function keyDownHandler(e) {
    if(e.key == "Right" || e.key == "ArrowRight") {
        rightPressed = true;
    }
    else if(e.key == "Left" || e.key == "ArrowLeft") {
        leftPressed = true;
    }
}

function keyUpHandler(e) {
    if(e.key == "Right" || e.key == "ArrowRight") {
        rightPressed = false;
    }
    else if(e.key == "Left" || e.key == "ArrowLeft") {
        leftPressed = false;
    }
}

var interval = setInterval(draw, 10);