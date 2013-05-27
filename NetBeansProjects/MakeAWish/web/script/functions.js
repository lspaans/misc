/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

var displaySponsorBox   = 0;
var strURLStatsRandom   = 'get.jsp';
var strURLDonate        = 'update.jsp';
var strURLSubscribe     = 'update.jsp';

function init() {
    drawClock();
    drawStatsRandom();
}

function formatInt(i,l) {
        while ((i+"").length < l) {
                i = "0" + i;
        }
        return(i);
}

function drawClock() {
        updateClock();
        window.setInterval("updateClock()",1000);    
}

function drawStatsRandom() {
    updateStatsRandom();
    window.setInterval("updateStatsRandom()",5000);  
}

function updateClock() {
        var time_now	= new Date();
        var time_then	= new Date("September 22, 2013 11:40:00");
        var time_diff	= Math.floor((time_then - time_now) / 1000);

        var dateStamp	= "" + formatInt(Math.floor(time_diff/86400),2) + ":" +
            formatInt(Math.floor((time_diff%86400)/3600),2) + ":" +
            formatInt(Math.floor((time_diff%3600)/60),2) + ":" +
            formatInt(Math.floor(time_diff%60),2);

        updateContainer("clock",dateStamp);
}

function updateStatsRandom() {
    xmlhttpPost(strURLStatsRandom,'statsRandomBoxData');
}

function updateDonation() {
    var strURLDonationDyn   = createURLDonation();
    if (
        strURLDonationDyn != null
    ) {
        xmlhttpPost(strURLDonationDyn,'donationInfo');
        resetSponsorBox();
        toggleDisplaySponsorBox();
    }
}

function updateSubscription() {
    var strURLSubscribeDyn   = createURLSubscription();
    if (
        strURLSubscribeDyn != null
    ) {
        xmlhttpPost(strURLSubscribeDyn,'newsletterInfo');
    }
}

function resetSponsorBox() {
    var donateVars          = new Array('a','b','c','r','o');
    var boxForm             = document.forms['sponsorForm'];
    var radioDonationType   = boxForm.n;
    if ( boxForm != null ) {
        for(var n=0;n<donateVars.length;n++) {
            boxForm.elements[donateVars[n]].value   = "";
        }
    }
}

function updateContainer(containerId,text) {
        var textContainer	= document.getElementById(containerId);
        if ( textContainer != null ) {
                if ( textContainer.lastChild != null ) {
                        textContainer.removeChild( textContainer.lastChild );
                }
                var textNode = document.createTextNode(text);
                textContainer.appendChild(textNode);
        }
}

function replaceClass(obj,srcClass,dstClass) {
    if ( obj != null ) {
        var srcClassStr = obj.getAttribute("class");
        var dstClassStr = "";
        if ( srcClassStr != null ) {
            var n = srcClassStr.split(" ");
            for(var i=0;i<n.length;i++) {
                if ( n[i] == srcClass ) {
                    dstClassStr += " " + dstClass;
                } else {
                    dstClassStr += " " + n[i];                    
                }
            }
            if ( dstClassStr != srcClassStr ) {
                obj.setAttribute("class",dstClassStr);
            }
        }
    }
}

function toggleVisibility(obj) {
    if ( obj != null ) {
        var classStr = obj.getAttribute("class");
        if ( classStr != null ) {
            var n = classStr.split(" ");
            for(var i=0;i<n.length;i++) {
                if ( n[i] == 'visible' ) {
                    replaceClass(obj,'visible','invisible');
                } else if ( n[i] == 'invisible' ) {
                    replaceClass(obj,'invisible','visible');
                }
            }
        }
    }
}

function toggleVisibilityById(id) {
    var obj = document.getElementById(id);
    if ( obj != null ) {
        toggleVisibility(obj);
    }
}

function toggleDisplaySponsorBox() {
    var outerBox = document.getElementById("outerBox");
    var innerBox = document.getElementById("innerBox");    
    if (
        outerBox != null &&
        innerBox != null &&
        sponsorBox != null
    ) {
        toggleVisibilityById("outerBox");
        toggleVisibilityById("innerBox");
        if (displaySponsorBox==0) {
            displaySponsorBox=1;
            resizeBox('outerBox',450,250,50,50,500,250,320,100,10);
        } else {
            resizeBox('outerBox',500,250,320,100,450,250,50,50,10);
            displaySponsorBox=0;
        }
    }
    return(displaySponsorBox);
}

function resizeBox(
    boxId,
    x_old,y_old,width_old,height_old,
    x_new,y_new,width_new,height_new,
    steps
) {    
    var box	= document.getElementById(boxId);
    if ( box != null ) {
        if (steps > 0) {
            var width = width_old+((width_new-width_old)/steps);
            var height = height_old+((height_new-height_old)/steps);
            var x = x_old+((x_new-x_old)/steps);
            var y = y_old+((y_new-y_old)/steps);
            box.style.top = "" + Math.floor(y-(0.5*height)) + "px";
            box.style.left = "" + Math.floor(x-(0.5*width)) + "px";
            box.style.width = "" + Math.floor(width) + "px";
            //box.style.height = "" + Math.floor(height) + "px";
            steps--;
            setTimeout('resizeBox("'+boxId+'",'+x+','+y+','+width+','+height+','+x_new+','+y_new+','+width_new+','+height_new+','+steps+')',5);
        }
        return(0);
    } else {
        return(1);
    }
};

function xmlhttpPost(strURL,resultContainerId) {
    var xmlHttpReq = false;
    var self = this;
    // Mozilla/Safari
    if (window.XMLHttpRequest) {
        self.xmlHttpReq = new XMLHttpRequest();
    }
    // IE
    else if (window.ActiveXObject) {
        self.xmlHttpReq = new ActiveXObject("Microsoft.XMLHTTP");
    }
    self.xmlHttpReq.open('POST', strURL, true);
    self.xmlHttpReq.setRequestHeader('Content-Type','application/x-www-form-urlencoded');
    self.xmlHttpReq.onreadystatechange = function() {
        if (self.xmlHttpReq.readyState == 4) {
            updatepage(self.xmlHttpReq.responseText,resultContainerId);
        }
    }
    self.xmlHttpReq.send();
}

function updatepage(str,resultContainerId){
    document.getElementById(resultContainerId).innerHTML = str;
}

function createURLDonation() {
    var strURLDonateDyn     = strURLDonate;
    var donateVars          = new Array('a','b','c','r','o');
    var boxForm             = document.forms['sponsorForm'];
    var radioDonationType   = boxForm.n;
    if ( boxForm != null ) {
        strURLDonateDyn = strURLDonateDyn + '?t=d';
        for(var n=0;n<donateVars.length;n++) {
            var value   = boxForm.elements[donateVars[n]].value;
            if ( value == "" ) {
                value = "";
            }
            strURLDonateDyn = strURLDonateDyn + '&' + donateVars[n] + '=' +
                encodeURIComponent(value);
        }
        for(var m=0;m<radioDonationType.length;m++) {
            if ( radioDonationType[m].checked) {
                strURLDonateDyn = strURLDonateDyn + '&n=' +
                    radioDonationType[m].value;
                break;
            }
            
        }
    }
    return(strURLDonateDyn);
}

function createURLSubscription() {
    var strURLSubscribeDyn  = strURLSubscribe;
    var subscribeVars       = new Array('e');
    var boxForm             = document.forms['newsletterForm'];
    if ( boxForm != null ) {
        strURLSubscribeDyn = strURLSubscribeDyn + '?t=n';
        for(var n=0;n<subscribeVars.length;n++) {
            var value   = boxForm.elements[subscribeVars[n]].value;
            if ( value == "" ) {
                value = "";
            }
            strURLSubscribeDyn = strURLSubscribeDyn + '&' +
                subscribeVars[n] + '=' + encodeURIComponent(value);
        }
    }
    return(strURLSubscribeDyn);
}
