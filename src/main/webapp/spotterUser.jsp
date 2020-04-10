<%@ page contentType="text/html; charset=utf-8" language="java"
         import="org.ecocean.servlet.ServletUtilities,
org.ecocean.*
" %>
<% request.setAttribute("pageTitle", "Account Creation"); %>
<jsp:include page="header.jsp" flush="true"/>
<div class="container maincontent">
<%

String email = request.getParameter("email");

if (email != null) {
    String context = ServletUtilities.getContext(request);
    Shepherd myShepherd = new Shepherd(context);
    myShepherd.setAction("spotterUser.jsp");
    myShepherd.beginDBTransaction();

    //unfortunately, i didnt squash case on generating this! so lets check both.  :(
    User user = myShepherd.getUser(SpotterConserveIO.hashFromEmail(email.toLowerCase()));
    if (user == null) user = myShepherd.getUser(SpotterConserveIO.hashFromEmail(email.toUpperCase()));
    if (user != null) {
        boolean sentReset = false;
        if (user.getEmailAddress() == null) {
            SystemValue.set(myShepherd, "TMP_EMAIL_" + user.getUUID(), email);
            sentReset = org.ecocean.servlet.UserResetPasswordSendEmail.sendPasswordResetEmail(context, user, email);
        }
        myShepherd.commitDBTransaction();
        myShepherd.closeDBTransaction();
%>
<h2>A user for <b><%=email%></b> exists.</h2>
<% if (sentReset) { %>
<p>An email confirmation has been sent to this address.  Use it to <b>set a new password</b>.</p>
<% } %>
<p>You can <a href="login.jsp?username=<%=email%>">login here</a>.</p>
<%
    } else {
        //SpotterConserveIO.init("context0");
        //SpotterConserveIO.testLogin("wildbook-test", "password-fail")
        myShepherd.rollbackAndClose();

%>
<h2>
We are sorry, but we <b>do not</b> have an account associated with this email address.
</h2>

<%
    }
} else {  //main form
%>

<h1>Welcome Whale Alert users!</h1>

<p>
Thanks for using <a target="_new" href="http://www.whalealert.org/">Whale Alert</a> to help us spot and identify whales.
If you're interested in contributing further, you can use your Whale Alert email to create a Flukebook account.
</p>

<p>
With a Flukebook account, you'll be able to contribute data and assist in tracking individual whales as they move across the oceans.
<br />
<b>Enter your email below to get started!</b>
</p>

<form method="post">
    <p><input name="email" /> <b>Whale Alert email address</b></p>
    <input type="submit" value="Create Account" />
</form>

<p>
By creating an account, you agree to the terms and conditions of Flukebook.
</p>


<%
}
%>
</div>
