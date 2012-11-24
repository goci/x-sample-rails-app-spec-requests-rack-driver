$(function() {
  $('#micropost_content').on("input", function() {
    var chars = parseInt($(this).val().length),
        charsLeft = 140 - chars,
        $charsIndicator = $('.chars-indicator');
    $charsIndicator.removeClass('chars-indicator-negative');
    if (charsLeft == 140) {
      $charsIndicator.empty();
    } else {
      if (charsLeft < 0) {
       $charsIndicator.addClass('chars-indicator-negative');
      }
      $charsIndicator.html(charsLeft);
    }
  });
});