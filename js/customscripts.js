
$( document ).ready(function() {

    // activate tooltips. although this is a bootstrap js function, it must be activated this way in your theme.
    $('[data-toggle="tooltip"]').tooltip({
        placement : 'top'
    });

    /**
     * AnchorJS
     */
    anchors.add('h2,h3,h4,h5');

    // Algolia docsearch styling
    $("#algolia-docsearch").css("width", "0px");

    $( "#algolia-toggle" ).click(function() {
        $("#algolia-docsearch").css("width", "250px");
        $("#algolia-docsearch").css("background", "#ffffff");
        $("#algolia-docsearch").focus();
        $(".navbar-toggle").hide();
    });

    $("#algolia-docsearch").focusout(function() {
        $("#algolia-docsearch").attr("style", "");
        $(".navbar-toggle").show();
    });

    $('#sidebar ul.nav li.dropdown').hover(function() {
        if (window.innerWidth > 1023){
            $(this).find('.dropdown-menu').stop(true, true).fadeIn(300);
            }
        }, function() {
            if (window.innerWidth > 1023){
            $(this).find('.dropdown-menu').stop(true, true).fadeOut(300);
        }
    });

});

// needed for nav tabs on pages. See Formatting > Nav tabs for more details.
// script from http://stackoverflow.com/questions/10523433/how-do-i-keep-the-current-tab-active-with-twitter-bootstrap-after-a-page-reload
$(function() {
    var hash = window.location.hash;
    if ($("#sidebar " + hash).length == 1 && hash.length > 0) {
        $("#sidebar .active").removeClass('active');
        $("#sidebar .selected").removeClass('selected');
        $('#sidebar .nav ul').css('display', 'none');
        $("#sidebar " + hash).parents('li').addClass('active');
        $('#sidebar .nav .active>ul').css('display', 'block');
    }

    var json, tabsState;
    $('a[data-toggle="pill"], a[data-toggle="tab"]').on('shown.bs.tab', function(e) {
        var href, json, parentId, tabsState;

        tabsState = localStorage.getItem("tabs-state");
        json = JSON.parse(tabsState || "{}");
        parentId = $(e.target).parents("ul.nav.nav-pills, ul.nav.nav-tabs").attr("id");
        href = $(e.target).attr('href');
        json[parentId] = href;

        return localStorage.setItem("tabs-state", JSON.stringify(json));
    });

    tabsState = localStorage.getItem("tabs-state");
    json = JSON.parse(tabsState || "{}");

    $.each(json, function(containerId, href) {
        return $("#" + containerId + " a[href=" + href + "]").tab('show');
    });

    $("ul.nav.nav-pills, ul.nav.nav-tabs").each(function() {
        var $this = $(this);
        if (!json[$this.attr("id")]) {
            return $this.find("a[data-toggle=tab]:first, a[data-toggle=pill]:first").tab("show");
        }
    });

});
