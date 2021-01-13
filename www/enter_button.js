$(document).keyup(function(event) {
    if ($("#address").is(":focus") && (event.key == "Enter")) {
        $("#go").click();
    }
});