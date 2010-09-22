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
        Controller.input("open_file_request", $(event.target).attr('data-file'), $(event.target).attr('data-line'))
      catch e
        alert(e.message)

  $("form").submit (e) ->
    e.preventDefault()
    value = input.val()
    output.append "<span class=\"stdout\">" + value + "<br></span>"
    # Just push the data, output comes from debugger
    try
      # Call the Controller. FIXME: Why is the Controller const not available here?
      Controller.input("stdin_ready", value)
    catch error
      alert error.message
    input.val ""
    input.focus()

  $(".rerun").click (event) ->
    event.preventDefault
    Controller.input("rerun")

  $(window).resize composite_layout_function
  composite_layout_function()

  $("input").keydown (event) ->
    event = event || window.event
    # interesting events are 38 (keyup) and 40 (keydown)
    if (event.keyCode == 38)
      Controller.input("stdin_keypress", "up")
    else if (event.keyCode == 40)
      Controller.input("stdin_keypress", "down")

composite_layout_function = ->
    if ($(window).width() > $(window).height())
      # Make horizontal
      $(".composite").addClass("horizontal")
      $(".composite").removeClass("vertical")
    else
      # Make vertical
      $(".composite").removeClass("horizontal")
      $(".composite").addClass("vertical")
