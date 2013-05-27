<%-- 
    Document   : index
    Created on : Mar 26, 2013, 7:32:51 AM
    Author     : leons
--%>

<%@taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions"%>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql"%>

<c:set var="total_fixed_amount" />
<c:set var="total_per_distance_amount" />

<c:set var="sql_get_total_fixed_amount">
    SELECT
        COALESCE(SUM(amount),0) AS 'total_amount'
    FROM maw.donation d
    LEFT JOIN maw.person pr ON pr.id = d.id_personSponsor
    LEFT JOIN maw.person pe ON pe.id = d.id_personSponsoree
    WHERE (
        d.confirmed = 1 AND
        pr.enabled = 1 AND
        pe.enabled = 1 AND
        d.donationType = 'flatFee'
    );
</c:set>
    
<c:set var="sql_get_per_distance_amount">
    SELECT
        p.givenName AS 'givenName',
        COALESCE(SUM(IF(d.id IS NULL OR d.confirmed = 0 OR d.donationType != 'distance',0,d.amount)),0) AS 'amount' 
    FROM maw.person p
    LEFT JOIN maw.donation d ON d.id_personSponsoree = p.id
    WHERE (
        p.type = 'runner' AND
        p.enabled = '1'
    )
    GROUP BY p.id;
</c:set>
    
<c:set var="sql_get_runners">
    SELECT
        id AS "id",
        givenName AS "givenName",
        surname AS "surname"
    FROM maw.person
    WHERE (
        type = "runner" AND
        enabled = 1
    );
</c:set>

<sql:query var="result_get_total_fixed_amount" dataSource="jdbc/mawdb">
    <c:out escapeXml="false" value="${sql_get_total_fixed_amount}" default="" />
</sql:query>

<sql:query var="result_get_per_distance_amount" dataSource="jdbc/mawdb">
    <c:out escapeXml="false" value="${sql_get_per_distance_amount}" default="" />
</sql:query>
    
<sql:query var="result_get_runners" dataSource="jdbc/mawdb">
    <c:out escapeXml="false" value="${sql_get_runners}" default="" />
</sql:query>

<c:forEach var="row" items="${result_get_total_fixed_amount.rows}" begin="0" end="0">
    <c:set var="total_fixed_amount">
        <c:out value="${row.total_amount}" default="0"/>
    </c:set>
</c:forEach>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <title>- IDentity.Next - Make-A-Wish -</title>
        <link rel="shortcut icon" href="image/favicon.ico" />
        <link rel="StyleSheet" type="text/css" href="style/main.css" media="screen" />
        <script type="text/javascript" language="javascript" src="script/functions.js"></script>
    </head>

    <body onLoad="init();">
        <div name="screen" id="screen" class="screen">

            <div name="screenHeader" id="screenHeader" class="screenHeader">
                <img name="logoMAW" id="logoMAW" class="logoMAW" src="image/logo_MAW.png" />
                <span id="clock" class="clock"></span>
                <img name="logoIDN" id="logoIDN" class="logoIDN" src="image/logo_IDNext.png" />
            </div>

                
            <div id="screenLeft" class="screenLeft">
                <div id="newsletterBox" class="menuBox">
                    <span class="formalTitleText">Nieuwsbrief:</span><br/>
                    <span class="formalText">Schrijf u in voor onze nieuwsbrief en ontvang maximaal X keer een informatieve e-mail</span><br/>
                    <br/>
                    <span class="formalText">E-mail adres:</span>
                    <form name="newsletterForm">
                        <input class="newsletterInput" name="e" type="text"></input><br/>
                        <button type="button" onClick="updateSubscription();">Verstuur</button>
                    </form>
                    <span id="newsletterInfo"></span>
                </div>
                
                <div id="donateButtonBox" class="menuBox">
                    <span class="formalTitleText">Doneer Nu:</span><br/>
                    <span class="formalText">En maak een kind blij!</span><br/>
                    <br/>
                    <form name="donateButtonForm">
                        <button type="button" onClick="toggleDisplaySponsorBox();">Doneer</button>
                    </form>
                    <span id="donationInfo"></span>
                </div>
            </div>

            <div id="screenMain" class="screenMain">
                
                <div id="mainBox" class="mainBox">
                    <span id="mainTitleText" class="mainTitleText">IDentity.Next steunt Make-A-Wish&copy; Nederland</span><br/>
                    <br/>
                    <span id="mainText" class="mainText">IDentity.Next en Make-A-Wish Nederland willen elk op hun eigen manier de wereld een beetje beter maken. IDentity.Next zoekt dat met name in het bieden van een platform waarop professionals elkaar treffen, ervaringen uitwisselen en met elkaar discussiëren hoe deontwikkeling van de digitale identiteit voor de huidge, maar ook voor de toekomstige generaties en alles wat daarmee samenhangt, nog verder verbeterd kan worden voor een (veiliger) digitale wereld.</span><br/>
                    <br/>
                    <span id="mainText" class="mainText">Make-A-Wish Nederland geeft wenskinderen  door het vervullen van hun liefste wens weer de kracht om kind te zijn, kijkt naar wat wél kan in plaats van wat niet meer kan en geeft het wenskind en zijn of haar familie een langdurende positieve herinnering mee.</span><br/>
                    <br/>
                    <span id="mainText" class="mainText">Zo vervulde Make-A-Wish, voorheen Doe Een Wens, de wens van campagnekanjer Alexander. Alexander was drie jaar toen de artsen acute lymfatische leukemie bij hem vaststelden. Een lange en zware behandelperiode volgde. Na twee jaar was de behandeling ten einde en werd Alexander verrast toen zijn grote wens in vervulling ging: hij kreeg een eigen boomhut in de tuin. ‘De wensdag was groots en bijna onbeschrijfbaar’, legt moeder Yvonne uit.  Na ruim vier jaar geniet Alexander nog steeds van zijn boomhut.</span><br/>
                    <br/>
                    <span id="mainText" class="mainText">In 2013 wil Make-A-Wish 520 liefste wensen vervullen en daar is geld voor nodig, véél geld. Juist daarom zijn we zo blij dat het IDentity.Next team net als vele andere teams deelnemen aan de Dam-Dam goede doelen loop. Een loop waar meer dan 55000 deelnemers aan meedoen. Het IDentity.Next team streeft (net als voorgaande keren)  om zoveel mogelijk geld in te zamelen. En daar is uw hulp bij nodig. Dus steun ons - het vervullen van een kinderwens is in uw handen!</span><br/>
                    <br/>
                    <span id="mainText" class="mainText">Alvast bedankt voor jouw donatie. Namens het IDentity.Next team - Robert, Sjoerd, Nico en Chris.</span><br/>
                </div>

                <br/>
                <div name="outerBox" id="outerBox" class="outerBox invisible">
                    <div name="innerBox" id="innerBox" class="innerBox invisble">
                        <div name="sponsorBox" id="sponsorBox">
                            <form name="sponsorForm" id="sponsorForm" action="update.jsp" class="formalText">
                                <table class="boxForm">
                                    <thead>
                                        <tr>
                                            <th colspan="2">
                                                <span class="formalLargeText">Donatie</span>
                                            </th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td colspan="2">
                                                <span class="formalTitleText">Uw informatie:</span>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="formalNameText">Voornaam:</td>
                                            <td class="formalText">
                                                <input name="a" id="sponsor_givenName"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="formalNameText">Achternaam:</td>
                                            <td class="formalText">
                                                <input name="b" id="sponsor_surname"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="formalNameText">E-mailadres:</td>
                                            <td class="formalText">
                                                <input name="c" id="sponsor_mailAddress"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="2">
                                                <span class="formalTitleText">Wie wilt u sponsoren?</span>
                                            </td>
                                        </tr>

                                        <tr>
                                            <td class="formalNameText" colspan="3">
                                                <select name="r">
                                                    <c:forEach var="row" items="${result_get_runners.rows}">
                                                        <option value="${row.id}">
                                                            <c:out value="${row.givenName}" default="" />
                                                            <c:out value=" " />
                                                            <c:out value="${row.surname}" default="" />
                                                        </option>
                                                    </c:forEach>
                                                </select>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="formalNameText">Soort donatie:</td>
                                            <td class="formalText">
                                                <input type="radio" name="n" value="flatFee" id="donation_type" checked="checked">Vast bedrag</input>
                                                <input type="radio" name="n" value="distance" id="donation_type">Per km.</input>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="formalNameText">Donatie bedrag:</td>
                                            <td class="formalText">
                                                <input name="o" id="donation_amount"/>
                                            </td>
                                        </tr>
                                    </tbody>
                                    <tfoot>
                                        <tr>
                                            <td>
                                                <button type="button" onClick="updateDonation();">Verstuur</button>
                                            </td>
                                            <td>
                                                <button type="button" onClick="toggleDisplaySponsorBox();">Annuleer</button>
                                            </td>
                                        </tr>
                                    </tfoot>
                                </table>
                            </form>
                        </div>
                    </div>
                </div>
                
            </div>
            
            <div id="screenRight" class="screenRight">
                <div id="statsTotalBox" class="statsBox">

                    <span class="formalTitleText">Toegezegd bedrag:</span><br/>
                    <span class="formalText">
                        <span class="formalKey"><c:out value="Totaal: " /></span>
                        <span class="formalVal">&euro; <c:out value="${total_fixed_amount}" /></span>
                    </span><br/>
                    
                </div>
                    
               <div id="statsPersonBox" class="statsBox">
                    
                    <span class="formalTitleText">Per km. bedrag:</span><br/>
                    <c:forEach var="row" items="${result_get_per_distance_amount.rows}">
                        <span class="formalText">
                            <span class="formalKey"><c:out value="${row.givenName}" default="" /></span>
                            <span class="formalVal"><c:out value=" " default="" />&euro; <c:out value="${row.amount}" default="" /></span>
                        </span><br/>
                    </c:forEach>
                </div>
                    
                <div id="statsRandomBox" class="statsBox">
                    <span class="formalTitleText">Wie sponsort wie:</span><br/>
                    <div id="statsRandomBoxData"></div>
                </div>

            </div>
                    
            
            <div id="screenFooter" class="screenFooter">
                test-3
            </div>
        </div>
    </body>
</html>
