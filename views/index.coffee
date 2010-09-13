$(document).ready ->
  input = $("#input")
  output = $("#output")
  input.focus()

  $(".notebook").children(".tab").click (e) ->
    e.preventDefault()
    $(this).siblings().addClass("disabled")
    $(this).removeClass("disabled")
    $(this).parent().children(".window").children("span").hide()
    output_buffer = "#" + $(this).attr("id").replace("-tab","")
    $(output_buffer).show()

  $("span").click (event) ->
    if $(event.target).is(".file_link")
      try
        rubyCall "input", ["open_file_request", $(event.target).attr('data-file'), $(event.target).attr('data-line')]
      catch e
        alert(e.message)

  $("form").submit (e) ->
    e.preventDefault()
    value = input.val()
    output.append "<span class=\"stdout\">" + value + "<br></span>"
    # Just push the data, output comes from debugger
    try
      # Call the Controller. FIXME: Why is the Controller const not available here?
      rubyCall "input", ["stdin_ready", value]
    catch error
      alert error.message
    input.val ""
    input.focus()

  $("a").click (event) ->
    event.preventDefault
    try
      rubyCall "input", ["open_file_request", $(this).attr('data-file'), $(this).attr('data-line')]
    catch e
      alert(e.message)

  $(window).resize composite_layout_function
  composite_layout_function()

  $("input").keydown (event) ->
    event = event || window.event
    # interesting events are 38 (keyup) and 40 (keydown)
    if (event.keyCode == 38)
      rubyCall "input", ["stdin_keypress", "up"]
    else if (event.keyCode == 40)
      rubyCall "input", ["stdin_keypress", "down"]

composite_layout_function = ->
    if ($(window).width() > $(window).height())
      # Make horizontal
      $(".composite").addClass("horizontal")
      $(".composite").removeClass("vertical")
    else
      # Make vertical
      $(".composite").removeClass("horizontal")
      $(".composite").addClass("vertical")
