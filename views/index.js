(function() {
  var composite_layout_function;
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
    $("span").click(function(event) {
      if ($(event.target).is(".file_link")) {
        try {
          return Controller.input("open_file_request", $(event.target).attr('data-file'), $(event.target).attr('data-line'));
        } catch (e) {
          return alert(e.message);
        }
      }
    });
    $("form").submit(function(e) {
      var value;
      e.preventDefault();
      value = input.val();
      output.append("<span class=\"stdout\">" + value + "<br></span>");
      try {
        Controller.input("stdin_ready", value);
      } catch (error) {
        alert(error.message);
      }
      input.val("");
      return input.focus();
    });
    $(".rerun").click(function(event) {
      event.preventDefault;
      return Controller.input("rerun");
    });
    $(window).resize(composite_layout_function);
    composite_layout_function();
    return $("input").keydown(function(event) {
      event = event || window.event;
      if ((event.keyCode === 38)) {
        return Controller.input("stdin_keypress", "up");
      } else if ((event.keyCode === 40)) {
        return Controller.input("stdin_keypress", "down");
      }
    });
  });
  composite_layout_function = function() {
    if (($(window).width() > $(window).height())) {
      $(".composite").addClass("horizontal");
      return $(".composite").removeClass("vertical");
    } else {
      $(".composite").removeClass("horizontal");
      return $(".composite").addClass("vertical");
    }
  };
})();
