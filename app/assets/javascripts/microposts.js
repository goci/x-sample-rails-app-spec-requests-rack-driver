$(function() {
  $('#micropost_content').keyup(function() {
    var chars = parseInt($(this).val().length),
        charsLeft = Math.max(0,140 - chars) + " characters left";
    $('.chars-indicator').html(charsLeft);
  });
});