(function() {
  $(document).ready(function() {
    var input, output;
    input = $("#input");
    output = $("#output");
    input.focus();
    $(".notebook").children(".tab").click(function(e) {
      var output_buffer;
      e.preventDefault();
      $(this).siblings().addClass("disabled");
      $(this).removeClass("disabled");
      $(this).parent().children(".window").children("span").hide();
      output_buffer = "#" + $(this).attr("id").replace("-tab", "");
      return $(output_buffer).show();
    });
    return $("form").submit(function(e) {
      var value;
      e.preventDefault();
      value = input.val();
      output.append("<span class=\"stdout\">" + value + "<br></span>");
      try {
        rubyCall("input", ["stdin_ready", value]);
      } catch (error) {
        alert(error.message);
      }
      input.val("");
      return input.focus();
    });
  });
})();
