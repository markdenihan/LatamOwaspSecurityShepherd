<%@ page contentType="text/html; charset=iso-8859-1" language="java" import="java.sql.*,java.io.*,java.net.*,org.owasp.esapi.ESAPI, org.owasp.esapi.Encoder, dbProcs.*, utils.*" errorPage="" %>

<%
	ShepherdLogManager.logEvent(request.getRemoteAddr(), request.getHeader("X-Forwarded-For"), "DEBUG: openCloseByCategory.jsp *************************");

/**
 * This file is part of the Security Shepherd Project.
 * 
 * The Security Shepherd project is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.<br/>
 * 
 * The Security Shepherd project is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.<br/>
 * 
 * You should have received a copy of the GNU General Public License
 * along with the Security Shepherd project.  If not, see <http://www.gnu.org/licenses/>. 
 * 
 * @author Mark Denihan
 */
 
if (request.getSession() != null)
{
HttpSession ses = request.getSession();
Getter get = new Getter();
//Getting CSRF Token from client
Cookie tokenCookie = null;
try
{
	tokenCookie = Validate.getToken(request.getCookies());
}
catch(Exception htmlE)
{
	ShepherdLogManager.logEvent(request.getRemoteAddr(), request.getHeader("X-Forwarded-For"), "DEBUG(openCloseByCategory.jsp): tokenCookie Error:" + htmlE.toString());
}
// validateAdminSession ensures a valid session, and valid administrator credentials
// Also, if tokenCookie != null, then the page is good to continue loading
if (Validate.validateAdminSession(ses) && tokenCookie != null)
{
	//Logging Username
	ShepherdLogManager.logEvent(request.getRemoteAddr(), request.getHeader("X-Forwarded-For"), "Accessed by: " + ses.getAttribute("userName").toString(), ses.getAttribute("userName"));
// Getting Session Variables
//This encoder should escape all output to prevent XSS attacks. This should be performed everywhere for safety
Encoder encoder = ESAPI.encoder();
String csrfToken = encoder.encodeForHTMLAttribute(tokenCookie.getValue());
String ApplicationRoot = getServletContext().getRealPath("");
%>
	<div id="formDiv" class="post">
		<h1 class="title">Open and Close Levels</h1>
		<div class="entry">
			<div id="badData"></div>
			<form id="theForm" action="javascript:;">
				<p>Use this form to open and close levels by entire categories. Levels that are closed will not appear in any level listings.</p>
				<div id="badData"></div>
				<input type="hidden" id="csrfToken" value="<%= csrfToken %>"/>
				<div id="submitButton" align="center">
					<div>
						<table>
						<tr><td colspan="2">
						<%= Getter.getOpenCloseCategoryMenu(ApplicationRoot) %>
						</td></tr>
						<tr><td>
						<input type="submit" value="Close Categories">
						</td><td>
						<input type="button" id="openCategories" value="Open Categories">
						</td></tr>
						</table>
					</div>
				</div>
			</form>
			<div id="loadingSign" style="display: none;"><p>Loading...</p></div> 
			
			<div id="resultDiv"></div>
			<script>					
			$("#theForm").submit(function(){
				var toDo = $("#toDo").val();
				var theCsrfToken = $('#csrfToken').val();
				//The Ajax Operation
				$("#badData").hide("fast");
				$("#submitButton").hide("fast");
				$("#loadingSign").show("slow");
				$("#resultDiv").hide("fast", function(){
					var ajaxCall = $.ajax({
						type: "POST",
						url: "openCloseModuleCategories",
						data: {
							toOpenOrClose: toDo,
							openOrClose: "closed",
							csrfToken: theCsrfToken
						},
						async: false
					});
					if(ajaxCall.status == 200)
					{
						$("#resultDiv").html(ajaxCall.responseText);
						$("#resultDiv").show("fast");
					}
					else
					{
						$("#badData").html("<div id='errorAlert'><p> Sorry but there was an error: " + ajaxCall.status + " " + ajaxCall.statusText + "</p></div>");
						$("#badData").show("slow");
					}
				});
				$("#loadingSign").hide("fast", function(){
					$("#submitButton").show("slow");
				});
			});
			
			$("#openCategories").click(function(){
				var toDo = $("#toDo").val();
				var theCsrfToken = $('#csrfToken').val();
				//The Ajax Operation
				$("#badData").hide("fast");
				$("#submitButton").hide("fast");
				$("#loadingSign").show("slow");
				$("#resultDiv").hide("fast", function(){
					var ajaxCall = $.ajax({
						type: "POST",
						url: "openCloseModuleCategories",
						data: {
							toOpenOrClose: toDo,
							openOrClose: "open",
							csrfToken: theCsrfToken
						},
						async: false
					});
					if(ajaxCall.status == 200)
					{
						$("#resultDiv").html(ajaxCall.responseText);
						$("#resultDiv").show("fast");
					}
					else
					{
						$("#badData").html("<div id='errorAlert'><p> Sorry but there was an error: " + ajaxCall.status + " " + ajaxCall.statusText + "</p></div>");
						$("#badData").show("slow");
					}
				});
				$("#loadingSign").hide("fast", function(){
					$("#submitButton").show("slow");
				});
			});
			</script>
			<% if(Analytics.googleAnalyticsOn) { %><%= Analytics.googleAnalyticsScript %><% } %>
		</div>
	</div>
	<%
}
else
{
response.sendRedirect("../../loggedOutSheep.html");
}
}
else
{
response.sendRedirect("../../loggedOutSheep.html");
}
%>