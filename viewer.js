$( function() {
    $( "#slider" ).slider({
        step: 1,
        change: on_tick_change
    });

    var url = window.location.search;

    // If the parameter is present, enter to the remote mode
    var param = url.slice(1);
    if (param.length > 0) {
        $( "#jsonFile" ).hide();
        var canvas = document.getElementById("canvas");
        var ctx = canvas.getContext('2d');
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        ctx.font = "20px Arial";
        ctx.fillStyle = 'black';
        ctx.fillText("Downloading from " + param + "...",
                     10,
                     40);
        load_url(param);
    }
} );

var DATA = null;
var TIMER = null;
var SOURCE = null;

function load_file() {
    var input, file, fr;

    if (typeof window.FileReader !== 'function') {
        alert("The file API isn't supported on this browser yet.");
        return;
    }

    input = document.getElementById('fileinput');
    if (!input) {
        alert("Um, couldn't find the fileinput element.");
    }
    else if (!input.files) {
        alert("This browser doesn't seem to support the `files` property of file inputs.");
    }
    else if (!input.files[0]) {
        alert("Please select a file before clicking 'Load'");
    }
    else {
        file = input.files[0];
        fr = new FileReader();
        fr.onload = received_text;
        fr.readAsText(file);
    }

    function received_text(e) {
        let lines = e.target.result;
        DATA = JSON.parse(lines);
        $( "#slider" ).slider("option", "min", 0);
        $( "#slider" ).slider("option", "max", DATA.length - 1);
        var canvas = document.getElementById("canvas");
        var ctx = canvas.getContext('2d');
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        on_tick_change(null, null);
    }
}


function load_url(url) {
    $.ajax({
        url:url,
        type:'GET',
        converters: {}
    }).done( (data) => {
        if (typeof(data) === "string") {
            data = JSON.parse(data);
        }
        DATA = data;
        $( "#slider" ).slider("option", "min", 0);
        $( "#slider" ).slider("option", "max", DATA.length - 1);
        var canvas = document.getElementById("canvas");
        var ctx = canvas.getContext('2d');
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        on_tick_change(null, null);
    });
}

function start_animation() {
    if (TIMER) {
        stop_animation();
        return;
    }
    TIMER = setInterval(function(){
        var cur = $( "#slider" ).slider( "option", "value" );
        var next = cur + 1;
        if (next > $( "#slider" ).slider( "option", "max" )) {
            stop_animation();
            return;
        }
        $( "#slider" ).slider("option", "value", next);
    },10);
}

function stop_animation() {
    if (TIMER) {
        clearInterval(TIMER);
        TIMER = null;
    }
}

function on_tick_change(ev, ui) {
    var tick = $( "#slider" ).slider( "option", "value" );
    var info = DATA[tick];

    var canvas = document.getElementById("canvas");
    var ctx = canvas.getContext('2d');
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    var liftWidth = 18;
    var liftSkip = 25;
    var liftHeight = 18;
    var floorHeight = 25;
    var baseline = 650;
    var leftOff = 30;
    var buttonLeftOff = leftOff + liftSkip * info.locations.length + 10;

    $("#tick").html("" + tick);
    $("#reward").html("" + info.acc_rewards);
    $("#npeople").html("" + info.acc_npeople);
    $("#avgreward").html("" + (info.acc_rewards / info.acc_npeople));

    // draw floor nums
    for (var i = 0; i < 25; ++ i) {
        ctx.font = "14px Arial";
        ctx.fillStyle = 'black';
        ctx.fillText(i, 5,
                     baseline - i * floorHeight - 5);
    }

    // draw target
    for (var i = 0; i < info.locations.length; ++ i) {
        if (info.goals[i] == "STOP") {
            continue;
        }
        var floorR = info.goals[i];
        ctx.beginPath();
        ctx.rect(leftOff + liftSkip * i - 2,
                 baseline - floorR * floorHeight - liftHeight - 2,
                 liftWidth + 4,
                 liftHeight + 4);
        ctx.fillStyle = 'pink';
        ctx.fill();
    }

    // draw lifts
    for (var i = 0; i < info.locations.length; ++ i) {
        ctx.beginPath();
        var floorR = info.locations[i][0] / info.locations[i][1];
        ctx.rect(leftOff + liftSkip * i,
                 baseline - floorR * floorHeight - liftHeight,
                 liftWidth,
                 liftHeight);
        ctx.fillStyle = 'yellow';
        ctx.fill();
        ctx.lineWidth = 2;
        ctx.strokeStyle = 'black';
        ctx.stroke();
        if (info.stop_time[i] > 0) {
            ctx.font = "6px Arial";
            ctx.fillStyle = 'black';
            ctx.fillText(info.stop_time[i],
                         leftOff + liftSkip * i + liftWidth - 5,
                         baseline - floorR * floorHeight - 2);

        }
    }

    // draw wait states
    for (var i = 0; i < 25; ++ i) {
        var f = "";
        f += "\uD83D\uDEB6".repeat(info.wait_up[i] + info.wait_dn[i]);

        var s = "";
        s += "\uD83D\uDD3C".repeat(info.wait_up[i]);
        s += "\uD83D\uDD3D".repeat(info.wait_dn[i]);
        ctx.font = "9px Arial";
        ctx.fillStyle = 'black';

        ctx.fillText(f,
                     buttonLeftOff,
                     baseline - i * floorHeight - 10);
        ctx.fillText(s,
                     buttonLeftOff,
                     baseline - i * floorHeight + 1);
    }

    // draw statuses
    for (var i = 0; i < info.statuses.length; ++ i) {
        var s = "";
        if (info.statuses[i] == "up") {
            s = "\uD83D\uDD3C";
        } else if (info.statuses[i] == "down") {
            s = "\uD83D\uDD3D";
        } else if (info.statuses[i] == "both") {
            s = "\u23F9";
        }
        ctx.beginPath();
        ctx.font = "12px Arial";
        ctx.fillStyle = 'black';
        ctx.fillText(s,
                     leftOff + liftSkip * i + 2,
                     baseline + 16);
    }

    // draw in-lifts
    for (var i = 0; i < info.inlift_p.length; ++ i) {
        var s = "";
        var liftloc = info.locations[i][0] / info.locations[i][1];
        var person = "\uD83D\uDE4B";
        var up = "\uD83D\uDD3C";
        var down = "\uD83D\uDD3D";
        var stop = "\u23F9";

        var yskip = 24;
        var yoff = baseline + 16 + 24;
        var line1 = "";
        var line2 = "";
        for (var j = 0; j < info.inlift_p[i].length; ++ j) {
            if (info.inlift_p[i][j].df > liftloc) {
                line1 += person;
                line2 += up;
            } else if (info.inlift_p[i][j].df == liftloc) {
                line1 += person;
                line2 += stop;
            } else {
                line1 += person;
                line2 += down;
            }
            if (j % 2 == 1) {
                ctx.font = "9px Arial";
                ctx.fillText(line1,
                             leftOff + liftSkip * i + 2,
                             yoff);
                ctx.fillText(line2,
                             leftOff + liftSkip * i + 2,
                             yoff + 11);
                line1 = "";
                line2 = "";
                yoff += yskip;
            }
        }
        if (line1 != "") {
            ctx.font = "9px Arial";
            ctx.fillText(line1,
                         leftOff + liftSkip * i + 2,
                         yoff);
            ctx.fillText(line2,
                         leftOff + liftSkip * i + 2,
                         yoff + 11);
        }
    }

}
